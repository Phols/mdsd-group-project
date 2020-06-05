package dk.sdu.mmmi.generator

import dk.sdu.mmmi.springBoard.Security
import dk.sdu.mmmi.springBoard.SecOption
import dk.sdu.mmmi.springBoard.Encoder
import dk.sdu.mmmi.springBoard.DetailService
import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.springBoard.Model
import java.util.List
import dk.sdu.mmmi.springBoard.Role
import dk.sdu.mmmi.springBoard.SecurityOptions
import java.util.ArrayList
import java.util.Iterator
import dk.sdu.mmmi.springBoard.Protocol
import dk.sdu.mmmi.springBoard.Ipaddress
import dk.sdu.mmmi.springBoard.Service
import dk.sdu.mmmi.springBoard.Local
import dk.sdu.mmmi.springBoard.Post
import dk.sdu.mmmi.springBoard.Get
import dk.sdu.mmmi.springBoard.Put
import dk.sdu.mmmi.springBoard.Delete
import dk.sdu.mmmi.springBoard.SecurityConfig

class SecurityGenerator {
	boolean httpBasic = false;
	boolean https = false;
	List<Role> roleCandidates = new ArrayList();
	Iterator<Role> iterator = roleCandidates.iterator();
	val mavenSrcStructure = "src/main/java/"
	
	def CharSequence generateSecurityConfigFile(String packageName, SecurityConfig securityConfig, Security security, List<Service> services, IFileSystemAccess2 fsa) '''
	package «packageName».security;
	
	import org.springframework.context.annotation.Bean;
	import org.springframework.context.annotation.Configuration;
	import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
	import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
	import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
	import org.springframework.security.config.annotation.web.builders.HttpSecurity;
	import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
	«EncodeImports(securityConfig)»
	«containsRestrictions(security)»
	
	@Configuration
	@EnableWebSecurity
	public class WebSecurityConfig extends WebSecurityConfigurerAdapter {
		
	«DetailService(securityConfig, security, fsa, packageName)»
		«generateRoleEnum(fsa, packageName, security)»
	
		@Override
		protected void configure(final AuthenticationManagerBuilder auth) {
			auth.authenticationProvider(authenticationProvider());	
		}
	
		«PasswordEncoder(securityConfig)»
	
		@Override
		protected void configure(HttpSecurity http) throws Exception {
		http.authorizeRequests()
		«ipRestrictions(securityConfig, services)»
		«invariantRestrictions(security)»
		«httpChoice(securityConfig)»
		
		}
		
		@Bean
		public DaoAuthenticationProvider authenticationProvider() {
			DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
			authProvider.setUserDetailsService(detailService);
			authProvider.setPasswordEncoder(passwordEncoder());
			return authProvider;
		}	
	}
	'''
	def CharSequence containsRestrictions(Security security){
		'''
		«FOR invariantCandidate: security.securities.filter(invariant | invariant.requestRestrictions !== null)»
			«IF invariantCandidate.requestRestrictions.size() > 0»
			import org.springframework.http.HttpMethod;		
			«ENDIF»
		«ENDFOR»
		'''
	}
	def CharSequence ipRestrictions(SecurityConfig security, List<Service> services){
		'''
		«FOR secoption: security.optionalSetting.filter(secopt | secopt instanceof Ipaddress)»
				.antMatchers
				«FOR service : services.filter(methods | methods !== null)»
					«FOR method : service.methods.filter(candidate | candidate.name.equals((secoption as Ipaddress).base.name))»
				«method.apipath».hasIpAddress("«(secoption as Ipaddress).ipAddress»")
					«ENDFOR»
				«ENDFOR»
		«ENDFOR»		
		'''
		
	}
	def CharSequence httpChoice(SecurityConfig security){
		'''
		«FOR secoption: security.optionalSetting.filter(secopt | secopt instanceof Protocol)»
				«IF (secoption as Protocol).http.toLowerCase().equals("basic") || (secoption as Protocol).http.toLowerCase().equals("simple")».and().requiresChannel().anyRequest().requiresInsecure(); «ENDIF»
				«IF (secoption as Protocol).http.toLowerCase().equals("secure") || (secoption as Protocol).http.toLowerCase().equals("safe") ».and().requiresChannel().anyRequest().requiresSecure(); «ENDIF»
		«ENDFOR»
		'''
	}
	
	def CharSequence invariantRestrictions(Security security){
		'''
		«FOR invariantCandidate: security.securities.filter(invariant | invariant.requestRestrictions !== null)»
			«FOR invariant : invariantCandidate.requestRestrictions.filter(rule | !(rule.request instanceof Local))»
				«IF invariant.request instanceof Post»			
				 .antMatchers(HttpMethod.POST, "/api/**").hasRole("«invariant.role.name»")
				 «ELSEIF invariant.request instanceof Get»
				 .antMatchers(HttpMethod.GET, "/api/**").hasRole("«invariant.role.name»")
				 «ELSEIF invariant.request instanceof Put»
				 .antMatchers(HttpMethod.PUT, "/api/**").hasRole("«invariant.role.name»")
				 «ELSEIF invariant.request instanceof Delete»
				 .antMatchers(HttpMethod.DELETE, "/api/**").hasRole("«invariant.role.name»")
				 «ENDIF»
			«ENDFOR»
		«ENDFOR»
		'''
	}
	def CharSequence PasswordEncoder(SecurityConfig securityConfig) {
		'''
		«IF securityConfig !== null && securityConfig.optionalSetting !== null»
				«FOR option: securityConfig.optionalSetting.filter(option | option instanceof SecOption)»
					«IF option instanceof Encoder»
						@Bean
						public PasswordEncoder passwordEncoder() {
							return new 
						«IF option.encode.toLowerCase.equals("bcrypt")»
								BCryptPasswordEncoder();
						«ELSEIF option.encode.toLowerCase.equals("scrypt")»
								SCryptPasswordEncoder();
						«ELSEIF option.encode.toLowerCase.equals("pbkdf2")»
								Pbkdf2PasswordEncoder();
«««	Probably Fix			«ELSEIF option.encode.toLowerCase.equals("abstract")» 
«««							«option.encode»PasswordEncoder
						«ENDIF»
					«ENDIF»	
				«ENDFOR»
			}
		«ENDIF»
		'''
	}
	
	def DetailService(SecurityConfig securityConfig, Security security, IFileSystemAccess2 fsa, String packname) {
		'''
		«IF securityConfig !==null»
						«FOR option: securityConfig.optionalSetting.filter(option | option.detailSerivce!==null)»					
						«generateDetailServiceImpl(fsa, packname, option.detailSerivce)»
						«generatePrincipal(fsa, packname, option.detailSerivce, security)»
						private «option.detailSerivce.base.name»DetailServiceImpl detailService;
						
						public WebSecurityConfig(«option.detailSerivce.base.name»DetailServiceImpl detailService){
							this.detailService = detailService;
						}
						«ENDFOR»
		«ENDIF»
		'''
		
	}
	
	
	def CharSequence EncodeImports(SecurityConfig securityConfig) {
		'''
		«IF securityConfig !== null»
				«FOR option: securityConfig.optionalSetting.filter(option | option instanceof SecOption)»
				«IF option instanceof Encoder»
				import org.springframework.security.crypto.password.PasswordEncoder;
					«IF option.encode.toLowerCase.equals("bcrypt")»
				import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
					«ELSEIF option.encode.toLowerCase.equals("scrypt")»
				import org.springframework.security.crypto.scrypt;
					«ELSEIF option.encode.toLowerCase.equals("abstract")»
				import org.springframework.security.crypto.password.AbstractPasswordEncoder;
					«ELSEIF option.encode.toLowerCase.equals("pbkdf2")»
				import org.springframework.security.crypto.password.Pbkdf2PasswordEncoder;			
					«ENDIF»
				«ENDIF»
				«ENDFOR»
		«ENDIF»
		'''
	}
	
	def CharSequence generateDetailServiceImplFile(String packageName, DetailService service){
		'''
		package «packageName».security;
		
		import org.springframework.security.core.userdetails.UserDetails;
		import org.springframework.security.core.userdetails.UserDetailsService;
		import org.springframework.security.core.userdetails.UsernameNotFoundException;
		import org.springframework.stereotype.Service;
		import «packageName».repositories.«service.base.name»Repository;
		import «packageName».models.«service.base.name»;
		
		@Service
		public class «service.base.name»DetailServiceImpl implements UserDetailsService {
			
			private «service.base.name»Repository repository;
			
			public «service.base.name»DetailServiceImpl(«service.base.name»Repository repository) {
				super();
				this.repository = repository;
			}
				
				@Override
			    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
			        «service.base.name» _«service.base.name» = repository.findBy_username(username);
			        if (_«service.base.name» == null) {
			            throw new UsernameNotFoundException(
			                    "No «service.base.name» found with username: " + username);
			        }
			        return new «service.base.name»Principal(_«service.base.name»);
			    }
		}
		'''
	}
	def CharSequence generateRoleEnumFile(IFileSystemAccess2 fsa, String packageName, Security security){
		gatherRoles(security);
		'''
		package «packageName».security;
		import com.fasterxml.jackson.annotation.JsonFormat;
		@JsonFormat(shape = JsonFormat.Shape.STRING)
		public enum Role {
		«FOR securityOption : security.securities.filter(securities | securities !== null)»
			«FOR roles : securityOption.roles.filter(role | role.name !==null)»
		«roles.name.toUpperCase()»,
			«ENDFOR»
		«ENDFOR»

		}
			
		'''
	}
	
	
	def CharSequence generatePrincipalFile(IFileSystemAccess2 fsa, String packageName, DetailService service, Security security){
		'''
		package «packageName».security;
		
		import «packageName».models.«service.base.name»;
		import org.springframework.security.core.GrantedAuthority;
		import org.springframework.security.core.authority.SimpleGrantedAuthority;
		import org.springframework.security.core.userdetails.UserDetails;
		import java.util.ArrayList;
		import java.util.Collection;
		import java.util.List;
		
		public class «service.base.name»Principal implements UserDetails {
			private final «service.base.name» _«service.base.name»;
			
			public «service.base.name»Principal(«service.base.name» _«service.base.name») {this._«service.base.name» = _«service.base.name»;}
			
		    @Override
		      public Collection<? extends GrantedAuthority> getAuthorities() {
		          String rolePrefix = "ROLE_";
		          List<GrantedAuthority> authorities = new ArrayList<>();
		          for(Role role : _«service.base.name».getRoles()) {
		          	authorities.add(new SimpleGrantedAuthority(rolePrefix + role.name()));	
		          }
		          return authorities;
		      }
			
		 @Override
		    public String getPassword() {
		        return _«service.base.name».getPassword();
		    }
		
		    @Override
		    public String getUsername() {
		        return _«service.base.name».getUsername();
		    }
		
		    @Override
		    public boolean isAccountNonExpired() {
		        return true;
		    }
		
		    @Override
		    public boolean isAccountNonLocked() {
		        return true;
		    }
		
		    @Override
		    public boolean isCredentialsNonExpired() {
		        return true;
		    }
		
		    @Override
		    public boolean isEnabled() {
		        return true;
		    }
		
		    public «service.base.name» get«service.base.name»() {
		        return _«service.base.name»;
		    }
		}
		'''
	}
	
	
	def List<Role> gatherRoles(Security security){
		for(SecurityOptions secOpt: security.securities){
			if(secOpt.roles !== null && secOpt.roles.size()>0){
				for(Role role : secOpt.roles){
					roleCandidates.add(role)
				}					
			}
		}
		return roleCandidates;			
		}
	def generateRoleEnum(IFileSystemAccess2 fsa, String packName, Security security){
		if(security !== null){
		fsa.generateFile(
			mavenSrcStructure + packName.replace('.', '/') + "/security/"+"Role"+".java",
				generateRoleEnumFile(fsa, packName, security)
		)
		
		}
	}
	
	def generateDetailServiceImpl(IFileSystemAccess2 fsa, String packName, DetailService service) {
		if(service !== null){
		fsa.generateFile(
			mavenSrcStructure + packName.replace('.', '/') + "/security/"+service.base.name+"DetailServiceImpl"+".java",
				generateDetailServiceImplFile(packName, service)
		)
		
		}
	}
	
	def generatePrincipal(IFileSystemAccess2 fsa, String packName, DetailService service, Security security){
		if(security !== null){
		fsa.generateFile(
			mavenSrcStructure + packName.replace('.', '/') + "/security/"+service.base.name+"Principal"+".java",
				generatePrincipalFile(fsa, packName, service, security)
		)
		}
		
	}
	
	def generateSecurityConfig(IFileSystemAccess2 fsa, String packName,List<Service> services, Security security, SecurityConfig securityConfig){
		if(security !== null){
			fsa.generateFile(
				mavenSrcStructure + packName.replace('.', '/') + "/security/"+"WebSecurityConfig.java",
					generateSecurityConfigFile(packName,securityConfig, security, services, fsa)
			)
		}
	
	}
}
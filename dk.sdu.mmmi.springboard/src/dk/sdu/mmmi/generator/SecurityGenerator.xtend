package dk.sdu.mmmi.generator

import dk.sdu.mmmi.springBoard.Security
import dk.sdu.mmmi.springBoard.SecOption
import dk.sdu.mmmi.springBoard.Encoder
import dk.sdu.mmmi.springBoard.DetailService
import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.springBoard.Model

class SecurityGenerator {
	boolean httpBasic = false;
	boolean https = false;
	
	val mavenSrcStructure = "src/main/java/"
	
	def CharSequence generateSecurityConfigFile(String packageName, Security security, IFileSystemAccess2 fsa) '''
	package «packageName».security;
	
	import org.springframework.context.annotation.Bean;
	import org.springframework.context.annotation.Configuration;
	import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
	import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
	import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
	import org.springframework.security.config.annotation.web.builders.HttpSecurity;
	import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
	«EncodeImports(security)»

	@Configuration
	@EnableWebSecurity
	public class WebSecurityConfig extends WebSecurityConfigurerAdapter {
		
		«DetailService(security, fsa, packageName)»
	
		@Override
		protected void configure(final AuthenticationManagerBuilder auth) {
			auth.authenticationProvider(authenticationProvider());	
		}
	
		«PasswordEncoder(security)»
	
		@Override
		protected void configure(HttpSecurity http) throws Exception {
		
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
	
	def CharSequence PasswordEncoder(Security security) {
		'''
		«FOR sec:security.securities.filter(sec | sec.option !== null && sec.option.size != 0)»
						«FOR option: sec.option.filter(option | option instanceof SecOption)»
						«IF option instanceof Encoder»
						@Bean
						public PasswordEncoder passwordEncoder() {
							return new 
					«IF option instanceof Encoder»
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
						} 
						
						«ENDIF»
						«ENDFOR»
					«ENDFOR»
		'''
	}
	
	def DetailService(Security security, IFileSystemAccess2 fsa, String packname) {
		'''
		«FOR sec:security.securities.filter(sec | sec.option !== null && sec.option.size != 0)»
						«FOR option: sec.option.filter(option | option instanceof SecOption)»
						«IF option instanceof DetailService»
						«generateDetailServiceImpl(fsa, packname, option)»
						«generatePrincipal(fsa, packname, option)»
						private «option.base.name»DetailServiceImpl detailService;
						
						public WebSecurityConfig(«option.base.name»DetailServiceImpl detailService){
							this.detailService = detailService;
						}
						«ENDIF»
						«ENDFOR»
					«ENDFOR»
		'''
		
	}
	
	
	def CharSequence EncodeImports(Security security) {
		'''
		«FOR sec:security.securities.filter(sec | sec.option !== null && sec.option.size != 0)»
				«FOR option: sec.option.filter(option | option instanceof SecOption)»
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
			«ENDFOR»
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
	
	def CharSequence generatePrincipalFile(IFileSystemAccess2 fsa, String packageName, DetailService service){
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
«««		          for (Role role :
«««		                  userAccount.getRoles()) {
«««		              authorities.add(new SimpleGrantedAuthority(rolePrefix + role.name()));
«««		          }
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
	
	def generateDetailServiceImpl(IFileSystemAccess2 fsa, String packName, DetailService service) {
		fsa.generateFile(
			mavenSrcStructure + packName.replace('.', '/') + "/security/"+service.base.name+"DetailServiceImpl"+".java",
				generateDetailServiceImplFile(packName, service)
		)
	}
	
	def generatePrincipal(IFileSystemAccess2 fsa, String packName, DetailService service){
		fsa.generateFile(
			mavenSrcStructure + packName.replace('.', '/') + "/security/"+service.base.name+"Principal"+".java",
				generatePrincipalFile(fsa, packName, service)
		)
	}
	
	def generateSecurityConfig(IFileSystemAccess2 fsa, String packName,Security security){
		fsa.generateFile(
			mavenSrcStructure + packName.replace('.', '/') + "/security/"+"WebSecurityConfig.java",
				generateSecurityConfigFile(packName, security, fsa)
		)
		
	
	}
}
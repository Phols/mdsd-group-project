package dk.sdu.mmmi.generator

import dk.sdu.mmmi.springBoard.Security
import dk.sdu.mmmi.springBoard.SecOption
import dk.sdu.mmmi.springBoard.Encoder
import dk.sdu.mmmi.springBoard.DetailService

class SecurityGenerator {
	boolean httpBasic = false;
	boolean https = false;
	
	val mavenSrcStructure = "src/main/java/"
	
	def CharSequence generateSecurityConfig(String packageName, Security security) '''
	package «packageName».security;
	
	import org.springframework.context.annotation.Bean;
	import org.springframework.context.annotation.Configuration;
	import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
	import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
	import org.springframework.security.config.annotation.web.builders.HttpSecurity;
	«EncodeImports(security)»

	@Configuration
	@EnableWebSecurity
	public class WebSecurityConfig extends WebSecurityConfigurerAdapter {
		
	«DetailService(security)»
	
	@Override
	protected void configure(final AuthenticationManagerBuilder auth) throws Exception {
		auth.authenticationProvider(authenticationProvider())	
	}
	
	«PasswordEncoder(security)»
	
	@Override
	protected void configure(HttpSecurity http) throws Exception {
		
	}
	
	'''
	
	def CharSequence PasswordEncoder(Security security) {
		'''
		«FOR sec:security.securities.filter(sec | sec.option !== null && sec.option.size != 0)»
						«FOR option: sec.option.filter(option | option instanceof SecOption)»
						«IF option instanceof Encoder»
						@Bean
						public PasswordEncoder() {
							return new 
						«IF option instanceof Encoder»
							«IF option.encode.toLowerCase.equals("bcrypt")»
							BCryptPasswordEncoder
							«ELSEIF option.encode.toLowerCase.equals("scrypt")»
							SCryptPasswordEncoder
							«ELSEIF option.encode.toLowerCase.equals("pbkdf2")»
							Pbkdf2PasswordEncoder
«««	Probably Fix			«ELSEIF option.encode.toLowerCase.equals("abstract")» 
«««							«option.encode»PasswordEncoder
							«ENDIF»
						«ENDIF»
						();
						} 
						
						«ENDIF»
						«ENDFOR»
					«ENDFOR»
		'''
	}
	
	def DetailService(Security security) {
		'''
		«FOR sec:security.securities.filter(sec | sec.option !== null && sec.option.size != 0)»
						«FOR option: sec.option.filter(option | option instanceof SecOption)»
						«IF option instanceof DetailService»
						«CreateDetailServiceImpl(option)»
						private «option.base»DetailServiceImpl _«option.base»;
						
						public WebSecurityConifg(«option.base»DetailServiceImpl _«option.base»){
							this._«option.base» = _«option.base»;
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
	
	def CreateDetailServiceImpl(DetailService service) {
		// Create DetailServiceImpl file
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}
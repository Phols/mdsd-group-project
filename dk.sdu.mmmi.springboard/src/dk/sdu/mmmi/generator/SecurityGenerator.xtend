package dk.sdu.mmmi.generator

class SecurityGenerator {
	
	val mavenSrcStructure = "src/main/java/"
	
	def CharSequence generateSecurityConfig(String packageName) '''
	package «packageName».config
	
	
	'''
	
}
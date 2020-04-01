package dk.sdu.mmmi.generator

import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import dk.sdu.mmmi.springBoard.Service
import dk.sdu.mmmi.springBoard.CRUDActions

class ServiceGenerator {
	
	val mavenSrcStructure = "src/main/java/"
	
	def CharSequence generateService(String packageName, Service service) '''
		package «packageName»;
		
		import java.util.List;
		
		public interface I«service.base.name» {
			«IF service.crud != null»
				«generateCrud(service)»
			«ENDIF»
			«FOR m:service.methods»
				public «m.type.toString()» «m.name»(«FOR a:m.inp.args» «a.type.toString()» «a.name» «ENDFOR»); //Fix type
				 
			«ENDFOR»
		}
	'''
	
	def CharSequence generateCrud(Service ser)'''
		«FOR a:ser.crud.act»
			«IF a == CRUDActions.C»
				public boolean create(«ser.base.name» _«ser.base.name»);
				
			«ENDIF»
			«IF a == CRUDActions.R»
				public List<«ser.base.name»> findAll();
				
				public «ser.base.name» find(long id);
				
			«ENDIF»
			«IF a == CRUDActions.U»
				public boolean update(long id);
				
				public boolean update(«ser.base.name» _«ser.base.name»);
				
			«ENDIF»
			«IF a == CRUDActions.D»
				public boolean delete(long id);
				
				public boolean delete(«ser.base.name» _«ser.base.name»);
				
			«ENDIF»
		«ENDFOR»
	'''
	
	def createService(IFileSystemAccess2 fsa, String packageName, Service service) {
		fsa.generateFile(mavenSrcStructure+packageName.replace('.', '/')+"/services/I"+service.base.name+'.java', generateService(packageName, service))
	}
}
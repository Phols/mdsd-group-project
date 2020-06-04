package dk.sdu.mmmi.generator

import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.springBoard.Model
import java.util.List

class RepositoryGenerator {

	def CharSequence generateRepository(Model model, String packName, List<Model> modelsWithSubClasses, boolean isSecurityChosen) {
		'''
			package «packName».repositories;
			
			import «packName».models.«model.name»; 
			import org.springframework.data.repository.CrudRepository;
			«IF modelsWithSubClasses.contains(model)»
			import org.springframework.data.repository.NoRepositoryBean;
			import java.util.Optional;
			
			@NoRepositoryBean
			«IF model.inh !== null»
			public interface «model.name»Repository<T extends «model.name»> 
				extends «model.inh.base.name»Repository<«model.name»> {
				«checkSecurityAdditions(model, isSecurityChosen)»
			}
			«ELSE»
			public interface «model.name»Repository<T extends «model.name»> 
				extends CrudRepository<T, Long> {
				«checkSecurityAdditions(model, isSecurityChosen)»
			}
			«ENDIF»
			«ELSE»
			«IF model.inh!==null»
			public interface «model.name»Repository extends «model.inh.base.name»Repository<«model.name»> {
				«checkSecurityAdditions(model, isSecurityChosen)»
			}
			«ENDIF»
			«IF model.inh === null && !modelsWithSubClasses.contains(model) »
			
			public interface «model.name»Repository extends CrudRepository<«model.name», Long> {
				«checkSecurityAdditions(model, isSecurityChosen)»
			}
			«ENDIF»
			«ENDIF»
		'''
	}
	
	def CharSequence checkSecurityAdditions(Model model, Boolean SecurityIsChosen){
		'''
		«FOR field: model.fields.filter(Field | Field.name.toLowerCase() == "username")»
		«IF SecurityIsChosen»
		«model.name» findBy_username(String username);
		«ENDIF»
		«ENDFOR»
		'''
	}

	def createRepository(Model model, IFileSystemAccess2 fsa, String packName, List<Model> modelsWithSubClasses, boolean security) {
		generateFile(model, fsa, packName, modelsWithSubClasses,
			generateRepository(model, packName, modelsWithSubClasses, security));
	}

	def generateFile(Model model, IFileSystemAccess2 access2, String packName, List<Model> modelsWithSubClasses,
		CharSequence contents) {
		access2.generateFile(
			"src/main/java/" + packName.replace('.', '/') + "/repositories/" + model.name + "Repository.java",
			contents);
	}

}

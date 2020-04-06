package dk.sdu.mmmi.generator

import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.springBoard.Model
import dk.sdu.mmmi.springBoard.Str
import dk.sdu.mmmi.springBoard.Int
import dk.sdu.mmmi.springBoard.Dt
import dk.sdu.mmmi.springBoard.Lon
import dk.sdu.mmmi.springBoard.Bool
import dk.sdu.mmmi.springBoard.ModelType
import dk.sdu.mmmi.springBoard.ListOf
import dk.sdu.mmmi.springBoard.Identifier
import java.util.ArrayList

class RepositoryGenerator {

	def CharSequence generateRepository(Model model, String packName, ArrayList<Model> modelsWithSubClasses) {
		'''
			package «packName».repositories;
			
			import «packName».models.«model.name»; 
			import org.springframework.data.repository.CrudRepository;
			«IF modelsWithSubClasses.contains(model)»
				import org.springframework.data.repository.NoRepositoryBean;
				import java.util.Optional;
				
				@NoRepositoryBean 
				public interface «model.name»BaseRepository<T extends «model.name»> 
					extends CrudRepository<T, String> {
						 
					}
				«ENDIF»
				«IF model.inh!==null»
				
			public interface «model.name»Repository extends «model.inh.base.name»BaseRepository<«model.name»> {
				
			}
				«ENDIF»
				
				«IF model.inh == null && !modelsWithSubClasses.contains(model) »
			public interface «model.name»Repository extends CrudRepository<«model.name», String> {

			}
				«ENDIF»
				
				
		'''
	}

	def createRepository(Model model, IFileSystemAccess2 fsa, String packName, ArrayList<Model> modelsWithSubClasses) {
		generateFile(model, fsa, packName, modelsWithSubClasses,
			generateRepository(model, packName, modelsWithSubClasses));
	}

	def generateFile(Model model, IFileSystemAccess2 access2, String packName, ArrayList<Model> modelsWithSubClasses,
		CharSequence contents) {
		if (modelsWithSubClasses.contains(model)) {
			access2.generateFile(
				"src/main/java/" + packName.replace('.', '/') + "/repositories/" + model.name + "BaseRepository.java",
				contents);
		} else {
			access2.generateFile(
				"src/main/java/" + packName.replace('.', '/') + "/repositories/" + model.name + "Repository.java",
				contents);
		}
	}

}

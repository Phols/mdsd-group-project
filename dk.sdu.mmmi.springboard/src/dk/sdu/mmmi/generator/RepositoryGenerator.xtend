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

class RepositoryGenerator {
		
		def CharSequence generateRepository(Model model, String packName, boolean hasSubclasses){
		'''
		package «packName».repositories;
		
		import «packName».models.«model.name»; 
		import org.springframework.data.jpa.repository.JpaRepository;
		public interface «model.name»Repository extends JpaRepository<«model.name», String>{
			«model.name» find«model.name»ById(String id);	
		}
		'''	
		}
	
		def createRepository(Model model, IFileSystemAccess2 fsa, String packName, boolean hasSubclasses) {
		fsa.generateFile("src/main/java/"+packName.replace('.', '/')+"/repositories/"+model.name+"Repository.java", 
			generateRepository(model, packName, hasSubclasses)
		)
	}
	
}
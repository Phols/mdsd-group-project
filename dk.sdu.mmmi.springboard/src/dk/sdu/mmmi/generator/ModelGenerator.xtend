package dk.sdu.mmmi.generator

import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.springBoard.Model

class ModelGenerator {
	
	val mavenSrcStructure = "src/main/java/"
	/**
	 * TODO: instead of importing all models, we could check for inheritance and fields using a model type!
	 */
	def CharSequence generateModel(Model model, String packName)'''
	package «packName»;
	
	import java.util.*;
	import «packName».model.*;
	
	public class «model.name»«IF model.inh!==null» extends «model.inh.base.name»«ENDIF» {
		
		
	}
	
	'''
	
	def createModel(Model model, IFileSystemAccess2 fsa, String packName) {
		fsa.generateFile(mavenSrcStructure+packName.replace('.', '/')+"/model/"+model.name+".java", 
			generateModel(model, packName)
		)
	}
	
}
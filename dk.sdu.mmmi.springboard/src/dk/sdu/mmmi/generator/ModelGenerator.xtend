package dk.sdu.mmmi.generator

import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.springBoard.Model
import dk.sdu.mmmi.springBoard.Field
import dk.sdu.mmmi.springBoard.Type
import dk.sdu.mmmi.springBoard.Str
import dk.sdu.mmmi.springBoard.Int
import dk.sdu.mmmi.springBoard.Dt
import dk.sdu.mmmi.springBoard.Lon
import dk.sdu.mmmi.springBoard.Bool
import dk.sdu.mmmi.springBoard.ModelType
import dk.sdu.mmmi.springBoard.ListOf
import dk.sdu.mmmi.springBoard.Identifier

class ModelGenerator {
	
	val mavenSrcStructure = "src/main/java/"
	/**
	 * TODO: instead of importing all models, we could check for inheritance and fields using a model type!
	 */
	def CharSequence generateModel(Model model, String packName)'''
	package «packName»;
	
	import java.util.*;
	import java.time.*;
	import «packName».model.*;
	
	public class «model.name»«IF model.inh!==null» extends «model.inh.base.name»«ENDIF» {
	«FOR f:model.fields»
		private «computeType(f.type)» _«f.name»;
	«ENDFOR»
	}
	
	'''
	
	def dispatch computeType(Str type) {
		"String"
	}
	
	def dispatch computeType(Int type) {
		"Integer"
	}
	
	def dispatch computeType(Dt type) {
		"LocalDateTime"
	}
	
	def dispatch computeType(Lon type) {
		"long"
	}
	
	def dispatch computeType(Bool type) {
		"boolean"
	}
	
	def dispatch computeType(ModelType type) {
		type.base.name
	}
	
	def dispatch computeType(ListOf typeCheck) {
		"List<" + typeCheck.type.computeType + ">"
	}
	
	def dispatch computeType(Identifier type) {
		"long"
	}
	
	
	def createModel(Model model, IFileSystemAccess2 fsa, String packName) {
		fsa.generateFile(mavenSrcStructure+packName.replace('.', '/')+"/model/"+model.name+".java", 
			generateModel(model, packName)
		)
	}
	
}
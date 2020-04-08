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
import dk.sdu.mmmi.springBoard.Field
import dk.sdu.mmmi.springBoard.Lt
import dk.sdu.mmmi.springBoard.Neq
import dk.sdu.mmmi.springBoard.Gteq
import dk.sdu.mmmi.springBoard.Lteq
import dk.sdu.mmmi.springBoard.Eq
import dk.sdu.mmmi.springBoard.Gt
import dk.sdu.mmmi.springBoard.Flt

class ModelGenerator {
	
	val mavenSrcStructure = "src/main/java/"
	/**
	 * TODO: instead of importing all models, we could check for inheritance and fields using a model type!
	 */
	def CharSequence generateModel(Model model, String packName, boolean hasSubclasses)'''
	package «packName».models;
	
	import javax.persistence.*;
	import java.util.*;
	import java.time.*;
	import «packName».models.*;
	
	@Entity
	@Table(name = "T_«model.name.toUpperCase»")
	«IF hasSubclasses && model.inh === null»@Inheritance«ENDIF»
	public class «model.name»«IF model.inh!==null» extends «model.inh.base.name»«ENDIF» {
		
		«FOR f:model.fields»
		«IF f.type instanceof Identifier»
		@Id
		@GeneratedValue(strategy = GenerationType.AUTO)
		«ENDIF»
		«IF f.type instanceof ListOf»
		«generateTypeAnnotation(f.type as ListOf)»
		«ENDIF»
		«IF f.type instanceof ModelType»
		«generateTypeAnnotation(f.type as ModelType)»
		«ENDIF»
		private «computeType(f.type)» _«f.name»;
		«ENDFOR»
		
		public «model.name»() { }
		
		«FOR f:model.fields»
		public «computeType(f.type)» get«f.name.toFirstUpper»() {
			return _«f.name»;
		}
		
		«ENDFOR»
		«FOR f:model.fields»
		public void set«f.name.toFirstUpper» («computeType(f.type)» «f.name») «IF f.inv !== null»throws IllegalArgumentException«ENDIF» {
			«IF f.inv !== null»
			«generateInvariant(f)»
			«ENDIF»
			this._«f.name» = «f.name»;
		}
		
		«ENDFOR»
	}
	
	'''
	
	/**
	 * TODO: hardcoded length
	 */
	def CharSequence generateInvariant(Field f)'''
	if (!(«f.name».«f.inv.prop»() «generateOperator(f.inv.op)» «f.inv.value»)) {
		throw new IllegalArgumentException("«f.inv.prop» of «f.name» must be «generateOperator(f.inv.op)» «f.inv.value».");
	}
	'''
	
	def dispatch CharSequence generateOperator(Lt operator) {
		return "<"
	}
	
	def dispatch CharSequence generateOperator(Gt operator) {
		return ">"
	}
	
	def dispatch CharSequence generateOperator(Eq operator) {
		return "=="
	}
	
	def dispatch CharSequence generateOperator(Lteq operator) {
		return "<="
	}
	
	def dispatch CharSequence generateOperator(Gteq operator) {
		return ">="
	}
	
	def dispatch CharSequence generateOperator(Neq operator) {
		return "!="
	}
	
	def dispatch CharSequence generateTypeAnnotation(ListOf f)'''
	«IF f.type instanceof ModelType»
	@OneToMany(targetEntity = «computeType(f.type)».class, cascade = CascadeType.ALL)
	«ELSE»
	@ElementCollection
	«ENDIF»
	'''
	
	def dispatch CharSequence generateTypeAnnotation(ModelType f)'''
	«IF f.direction == "*"» 
	@ManyToOne(targetEntity = «f.base.name».class, cascade = CascadeType.ALL)
	«ELSE»
	@OneToOne(targetEntity = «f.base.name».class, cascade = CascadeType.ALL)
	«ENDIF»
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
		"Long"
	}
	
	def dispatch computeType(Flt type) {
		"Float"
	}
	
	/**
	 * Ignore warning, seems to be a bug?
	 */
	def dispatch computeType(Bool type) {
		"Boolean"
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
	
	
	def createModel(Model model, IFileSystemAccess2 fsa, String packName, boolean hasSubclasses) {
		fsa.generateFile(mavenSrcStructure+packName.replace('.', '/')+"/models/"+model.name+".java", 
			generateModel(model, packName, hasSubclasses)
		)
	}
	
}
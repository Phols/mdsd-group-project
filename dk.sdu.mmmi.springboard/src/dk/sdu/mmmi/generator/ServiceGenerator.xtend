package dk.sdu.mmmi.generator

import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.springBoard.Service
import dk.sdu.mmmi.springBoard.CRUDActions
import dk.sdu.mmmi.springBoard.Dt
import dk.sdu.mmmi.springBoard.ListOf
import dk.sdu.mmmi.springBoard.Str
import dk.sdu.mmmi.springBoard.Int
import dk.sdu.mmmi.springBoard.Lon
import dk.sdu.mmmi.springBoard.Bool
import dk.sdu.mmmi.springBoard.Identifier
import dk.sdu.mmmi.springBoard.ModelType
import dk.sdu.mmmi.springBoard.Args
import dk.sdu.mmmi.springBoard.Lt
import dk.sdu.mmmi.springBoard.Neq
import dk.sdu.mmmi.springBoard.Gt
import dk.sdu.mmmi.springBoard.Lteq
import dk.sdu.mmmi.springBoard.Eq
import dk.sdu.mmmi.springBoard.Gteq
import dk.sdu.mmmi.springBoard.Model
import dk.sdu.mmmi.springBoard.Flt
import dk.sdu.mmmi.springBoard.Method
import dk.sdu.mmmi.springBoard.LogicAnd
import dk.sdu.mmmi.springBoard.LogicOr
import dk.sdu.mmmi.springBoard.Comp
import dk.sdu.mmmi.springBoard.Logic

class ServiceGenerator {
	
	val mavenSrcStructure = "src/main/java/"
	
	def CharSequence generateService(String packageName, Service service) '''
		package �packageName�.services;
		
		import java.util.List;
		import java.time.LocalDateTime;
		import �packageName�.models.*;
		
		public interface I�service.base.name� {
			�IF service.crud !== null�
			�generateCrudInterface(service)�
			�ENDIF�
			�FOR m:service.methods�
			
			�m.type.show� �m.name�(�IF m.inp.args !== null��m.inp.args.show� �ENDIF�);
			�ENDFOR�
		}
	'''
	
	def CharSequence generateCrudInterface(Service ser)'''
		�FOR a:ser.crud.act�
			�IF a == CRUDActions.C�
			
			�ser.base.name� create(�ser.base.name� _�ser.base.name�);
			�ENDIF�
			�IF a == CRUDActions.R�
			
			List<�ser.base.name�> findAll();
			
			�ser.base.name� find(Long id);
			�ENDIF�
			�IF a == CRUDActions.U�

				�ser.base.name� update(�ser.base.name� �ser.base.name�);
			�ENDIF�
			�IF a == CRUDActions.D�
			
			void delete(Long id);
			
			void delete(�ser.base.name� _�ser.base.name�);
			�ENDIF�
		�ENDFOR�
	'''
	
	def CharSequence generateCrudImpl(Service ser) '''
		�FOR a:ser.crud.act�
			�IF a == CRUDActions.C�
			
			@Override
			public �ser.base.name� create(�ser.base.name� _�ser.base.name�) {
				return (�ser.base.name�)repository.save(_�ser.base.name�);
			}
			�ENDIF�
			�IF a == CRUDActions.R�
				
				@Override
				public List<�ser.base.name�> findAll() {
					List<�ser.base.name�> all = new ArrayList<>();
					repository.findAll().forEach(x -> all.add((�ser.base.name�) x));
					return all; 					
				}
				
				@Override
				public �ser.base.name� find(Long id) {
					return (�ser.base.name�)repository.findById(id).get();
				}
			�ENDIF�
			�IF a == CRUDActions.U�
				
				@Override
				public �ser.base.name� update(�ser.base.name� _�ser.base.name�) {
					return (�ser.base.name�)repository.save(_�ser.base.name�);
				}
			�ENDIF�
			�IF a == CRUDActions.D�
				
				@Override
				public void delete(Long id) {
					repository.deleteById(id);
				}
				
				@Override
				public void delete(�ser.base.name� _�ser.base.name�) {
					repository.delete(_�ser.base.name�);
				}
			�ENDIF�
		�ENDFOR�
	'''
	
	def CharSequence generateMethodStubs(String packageName, Service service)'''
		package �packageName�.services.impl;
		
		import java.util.*;
		import java.time.LocalDateTime;
		import �packageName�.repositories.*;
		import �packageName�.models.*;
		import �packageName�.services.*;
		import org.springframework.stereotype.Service;
		
		public abstract class Abstract�service.base.name�Impl implements I�service.base.name� {
			
			protected �service.base.name�Repository repository;
			
			public Abstract�service.base.name�Impl(�service.base.name�Repository repository) {
				this.repository = repository;
			}
			
			�IF service.crud !== null�
			�generateCrudImpl(service)�
			�ENDIF�
			
			�FOR m:service.methods.filter[m | m.res !== null]�
				@Override
				public �m.type.show� �m.name� (�IF m.inp.args !== null��m.inp.args.show� �ENDIF�) {
				�handleExpression(m, service)�
				}
			�ENDFOR�
		}
	'''
	def handleExpression(Method m, Service service){
		if(m.res.expression !==null){
		'''
		�IF m.type instanceof ListOf�
							�m.type.show� _return = new ArrayList<>();
							repository.findAll().forEach(_return::add);
							for (�service.base.name� temp : _return) {
								if (�generateLogic(m.res.expression)�) {
									_return.remove(temp);
								} 
							}
							
							return _return;
						�ELSEIF m.type instanceof Bool�
							�IF getTypeArgument(m.inp.args, service.base) !== null�
							�service.base.name� temp  = (�service.base.name�) repository.find(�getTypeArgument(m.inp.args, service.base)�).get();
							�ELSE�
							�service.base.name� temp = (�service.base.name�) repository.findById(�getIdentifierArgument(m.inp.args)�).get();	
							�ENDIF�
							return �comparisonFunction(m.res.expression.left as Comp)�
						�ELSE�
							�IF getTypeArgument(m.inp.args, service.base) !== null�
							�m.type.show� _return = (�service.base.name�) repository.find(�getTypeArgument(m.inp.args, service.base)�).get();
							�m.type.show� temp = _return;
							�ELSE�
							�m.type.show� _return = (�service.base.name�) repository.findById(�getIdentifierArgument(m.inp.args)�).get();
							�m.type.show� temp = _return;	
							�ENDIF�
							if (�generateLogic(m.res.expression)�) {
								return _return;
							}
							
							return null;	
						�ENDIF�
		'''
		
		}
		
	}
	
	
	def dispatch CharSequence generateLogic(Logic logic)'''
	�IF logic.left !==null��logic.left.generateLogic��ENDIF�
	�IF logic.comp !== null��comparisonFunction(logic.comp)��ENDIF�
	�IF logic.right !== null��logic.right.generateLogic��ENDIF�
	'''
	
	def dispatch CharSequence generateLogic(LogicOr logic) '''(�logic.left.generateLogic� || �logic.right.generateLogic�)'''
	def dispatch CharSequence generateLogic(LogicAnd logic)'''(�logic.left.generateLogic� && �logic.right.generateLogic�)'''
	
	def CharSequence getTypeArgument(Args a, Model t) {
		if (t.fields.filter[test | (test.type == a.type)].size !== 0){	
			return a.name
		} else if (a.next === null) {
			return null
		} else {
			return getTypeArgument(a.next, t)
		}
	}
	
	def CharSequence getIdentifierArgument(Args a) {
		if (a !== null && a.type instanceof Identifier) {
			return a.name
		} else if (a.next !== null) {
			return getIdentifierArgument(a.next)
		}
	}
	
	def CharSequence comparisonFunction(Comp comp) {
		switch comp.left.type {
			Lon,
			Flt,
			Int: numOperator(comp)
			Dt: dtOperator(comp)
			Identifier,
			Str,
			ListOf,
			ModelType: objOperator(comp)
			Bool: boolOperator(comp)
			default: ''
		}		
	}
	
	def CharSequence objOperator(Comp comp) {
		val right = '''temp.get�comp.right.name.toFirstUpper�())'''
		switch comp.op {
			Eq: comp.left.name+'.equals('+right
			Neq: '!'+comp.left.name+'.equals('+right
			default: ''
		}	
	}
	
	def CharSequence boolOperator(Comp comp) {
		val right = '''temp.get�comp.right.name.toFirstUpper�()'''
		switch comp.op {
			Eq: comp.left.name+'=='+right
			Neq: comp.left.name+'!='+right
		}		
	}
	
	def CharSequence dtOperator(Comp comp) {
		val right = '''temp.get�comp.right.name.toFirstUpper�())'''
		switch comp.op {
			Lt: comp.left.name+'.isBefore('+right
			Gt: comp.left.name+'.isAfter('+right
			Eq: comp.left.name+'.equals('+right
			Gteq: comp.left.name+'.equals('+right +'||'+comp.left.name+'.isAfter('+right 
			Lteq: comp.left.name+'.equals('+right +'||'+comp.left.name+'.isBefore('+right 
			Neq: '!'+comp.left.name+'.equals('+right
			default: ''
		}	
	}
	
	def CharSequence numOperator(Comp comp) {
		val right = '''temp.get�comp.right.name.toFirstUpper�()'''
		switch comp.op {
			Lt: comp.left.name+' < '+right
			Gt: comp.left.name+' > '+right
			Eq: comp.left.name+' == '+right
			Gteq: comp.left.name+' >= '+right
			Lteq: comp.left.name+' <= '+right
			Neq: comp.left.name+' != '+right
			default: ''
		}
	}
	
	def dispatch CharSequence show(Dt dt)'''LocalDateTime'''
	
	def dispatch CharSequence show(ListOf lo)'''List<�lo.type.show�>'''
	
	def dispatch CharSequence show(Str st)'''String'''
	
	def dispatch CharSequence show(Int in)'''Integer'''
	
	def dispatch CharSequence show(Lon l)'''Long'''
	
	def dispatch CharSequence show(Bool b)'''Boolean'''
	
	def dispatch CharSequence show(Identifier id)'''Long'''
	
	def dispatch CharSequence show(ModelType m) '''�m.base.name�'''
	
	def dispatch CharSequence show(Flt m) '''Float'''
	
	def dispatch CharSequence show(Args a)'''�a.type.show� �a.name� �IF a.next !== null�, �a.next.show� �ENDIF�'''
	
	def createService(IFileSystemAccess2 fsa, String packageName, Service service) {
		fsa.generateFile(mavenSrcStructure+packageName.replace('.', '/')+"/services/I"+service.base.name+'.java', generateService(packageName, service))
	}
	
	def createAbstractService(IFileSystemAccess2 fsa, String packageName, Service service) {
		fsa.generateFile(mavenSrcStructure+packageName.replace('.', '/')+"/services/impl/Abstract"+service.base.name+'Impl.java', generateMethodStubs(packageName, service))
	}
}
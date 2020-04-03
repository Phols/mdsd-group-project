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
import dk.sdu.mmmi.springBoard.Comp

class ServiceGenerator {
	
	val mavenSrcStructure = "src/main/java/"
	
	def CharSequence generateService(String packageName, Service service) '''
		package «packageName».services;
		
		import java.util.List;
		import java.time.LocalDateTime;
		import «packageName».models.*;
		
		public interface I«service.base.name» {
			
			«IF service.crud != null»
				«generateCrudInterface(service)»
			«ENDIF»
			«FOR m:service.methods»
				«m.type.show» «m.name»(«IF m.inp.args !== null» «m.inp.args.show» «ENDIF»);
				 
			«ENDFOR»
		}
	'''
	
	def CharSequence generateCrudInterface(Service ser)'''
		«FOR a:ser.crud.act»
			«IF a == CRUDActions.C»
				boolean create(«ser.base.name» _«ser.base.name»);
				
			«ENDIF»
			«IF a == CRUDActions.R»
				List<«ser.base.name»> findAll();
				
				«ser.base.name» find(Long id);
				
			«ENDIF»
			«IF a == CRUDActions.U»
				boolean update(Long id);
				
				boolean update(«ser.base.name» _«ser.base.name»);
				
			«ENDIF»
			«IF a == CRUDActions.D»
				boolean delete(Long id);
				
				boolean delete(«ser.base.name» _«ser.base.name»);
				
			«ENDIF»
		«ENDFOR»
	'''
	
	def CharSequence generateMethodStubs(String packageName, Service service)'''
		package «packageName».services.impl;
		
		import java.util.*;
		import java.time.LocalDateTime;
		import «packageName».repositories.*;
		import «packageName».models.*;
		import «packageName».services.*;
		
		public abstract class Abstract«service.base.name»Impl implements I«service.base.name» {
			
			protected «service.base.name»Repository repository;
			
			public Abstract«service.base.name»Impl(«service.base.name»Repository repository) {
				this.repository = repository;
			}
			
			«FOR m:service.methods.filter[m | m.res != null]»
				@Override
				public «m.type.show» «m.name» («IF m.inp.args !== null» «m.inp.args.show» «ENDIF») {
				
				«IF m.type instanceof ListOf»
					«m.type.show» _return = new ArrayList<>();
					_return = repository.findAll().forEach(_return::add);
					for («service.base.name» temp : _return) {
						if (!(«m.res.comp.show»)) {
							return null;
						}
					}
				«ENDIF»
				return _return;				
				}
			«ENDFOR»
		}
	'''
	
	def dispatch CharSequence show(Comp comp)'''«comp.left.type.comparison(comp.op, comp.right.type, comp.left.name, "temp.get"+comp.right.name.toFirstUpper+"()")»'''
	
	def dispatch CharSequence show(Dt dt)'''LocalDateTime'''
	
	def dispatch CharSequence show(ListOf lo)'''List<«lo.type.show»>'''
	
	def dispatch CharSequence show(Str st)'''String'''
	
	def dispatch CharSequence show(Int in)'''Integer'''
	
	def dispatch CharSequence show(Lon l)'''Long'''
	
	def dispatch CharSequence show(Bool b)'''boolean'''
	
	def dispatch CharSequence show(Identifier id)'''Long'''
	
	def dispatch CharSequence show(ModelType m) '''«m.base.name»'''
	
	def dispatch CharSequence show(Args a)'''«a.type.show» «a.name» «IF a.next !== null», «a.next.show» «ENDIF»'''
	
	def dispatch CharSequence comparison(Dt a, Lt lt, Dt b, String l, String r)'''«l».isBefore(«r»)'''
	
	def dispatch CharSequence comparison(Dt a, Gt lt, Dt b, String l, String r)'''«l».isAfter(«r»)'''
	
	/*def dispatch CharSequence comparison(Dt a, Lteq lt, Dt b)'''.isBefore(«b») || «a».equals(«b»)'''
	
	def dispatch CharSequence comparison(Dt a, Gteq lt, Dt b)'''.isAfter(«b») || «a».equals(«b»)'''
	
	def dispatch CharSequence comparison(Dt a, Eq lt, Dt b)'''.equals()'''
	
	def dispatch CharSequence comparison(Dt a, Neq lt, Dt b)'''.equals()'''*/
	
	def dispatch CharSequence comparison(Lon l, Neq o ,Lon m, String le, String r)'''!= '''
	
	def createService(IFileSystemAccess2 fsa, String packageName, Service service) {
		fsa.generateFile(mavenSrcStructure+packageName.replace('.', '/')+"/services/I"+service.base.name+'.java', generateService(packageName, service))
	}
	
	def createAbstractService(IFileSystemAccess2 fsa, String packageName, Service service) {
		fsa.generateFile(mavenSrcStructure+packageName.replace('.', '/')+"/services/impl/Abstract"+service.base.name+'Impl.java', generateMethodStubs(packageName, service))
	}
}
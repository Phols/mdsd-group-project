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
import dk.sdu.mmmi.springBoard.Service
import dk.sdu.mmmi.springBoard.CRUDActions
import dk.sdu.mmmi.springBoard.Args
import dk.sdu.mmmi.springBoard.Post
import dk.sdu.mmmi.springBoard.Get
import dk.sdu.mmmi.springBoard.Put
import dk.sdu.mmmi.springBoard.Delete
import dk.sdu.mmmi.springBoard.Local

class ControllerGenerator {

	val mavenSrcStructure = "src/main/java/"

	def CharSequence generateController(Model model, Service service, String packName, boolean isASubClass) {
		'''
package «packName».controllers;
import «packName».models.*;
import org.springframework.web.bind.annotation.*;
import «packName».services.I«model.name»;
import javax.validation.Valid;
import java.util.List;
import java.time.LocalDateTime;

@RestController
public class «model.name»Controller {
	
	private I«model.name» «model.name.toFirstLower»Service;
	
	public «model.name»Controller(I«model.name» «model.name.toFirstLower»Service) {
	    this.«model.name.toFirstLower»Service =  «model.name.toFirstLower»Service;
	}
	
	«IF service.crud !== null»
	«generateCRUDMethods(service, model)»
	«ENDIF»
	«generateServiceMethods(service, model)»
}
'''
	}

	def createController(Model model, Service service, IFileSystemAccess2 fsa, String packName, boolean isASubClass) {
		//if (!isASubClass) {
			fsa.generateFile(
				mavenSrcStructure + packName.replace('.', '/') + "/controllers/" + model.name + "Controller.java",
				generateController(model, service, packName, isASubClass)
			)
		//}
	}

	def generateCRUDMethods(Service service, Model model) {
		'''
			«FOR a : service.crud.act»
				«IF a == CRUDActions.C»
					@PostMapping("/api/«model.name.toLowerCase»")
					public «model.name» create«model.name»(@Valid @RequestBody «model.name» «model.name.toFirstLower») {
						return «model.name.toFirstLower»Service.create(«model.name.toFirstLower»);
					}
					
				«ENDIF»
				«IF a == CRUDActions.R»
					@GetMapping("/api/«model.name.toLowerCase»/{id}")
					public «model.name» find(@PathVariable Long id) {
						return «model.name.toFirstLower»Service.find(id);
					}
					
					@GetMapping("/api/«model.name.toLowerCase»/all")
					public List<«model.name»> findAll() {
						return «model.name.toFirstLower»Service.findAll();
					}
					
				«ENDIF»
				«IF a == CRUDActions.U»
					@PutMapping("/api/«model.name.toLowerCase»")
					@ResponseBody
					public void update(@RequestBody «model.name» «model.name.toFirstLower») {
						«model.name.toFirstLower»Service.update(«model.name.toFirstLower»);
					}
					
				«ENDIF»
				«IF a == CRUDActions.D»
					@DeleteMapping("/api/«model.name.toLowerCase»/{id}")
					@ResponseBody
					public void delete(@PathVariable Long id) {
					    «model.name.toFirstLower»Service.delete(id);
					}
					
				«ENDIF»
			«ENDFOR»
		'''
	}

	def generateServiceMethods(Service service, Model model)'''
			«FOR m : service.methods.filter[m | !(m.req instanceof Local)]»
			@«m.req.showReq»Mapping("/api/«model.name.toLowerCase»/«m.name.toLowerCase»")
			«m.type.show» «m.name»(«IF m.inp.args !== null»«m.inp.args.show»«ENDIF»){
				return 	«model.name.toFirstLower»Service.«m.name»(«IF m.inp.args !== null»«m.inp.args.showName»«ENDIF»);
			}
			
			«ENDFOR»
			'''
	

	def dispatch CharSequence show(Dt dt) '''LocalDateTime'''

	def dispatch CharSequence show(ListOf lo) '''List<«lo.type.show»>'''

	def dispatch CharSequence show(Str st) '''String'''

	def dispatch CharSequence show(Int in) '''Integer'''

	def dispatch CharSequence show(Lon l) '''Long'''

	def dispatch CharSequence show(Bool b) '''Boolean'''

	def dispatch CharSequence show(Identifier id) '''Long'''

	def dispatch CharSequence show(ModelType m) '''«m.base.name»'''

	def dispatch CharSequence show(Args a) '''@RequestParam «a.type.show» «a.name»«IF a.next !== null», «a.next.show»«ENDIF»'''

	def CharSequence showName(Args a) '''«a.name»«IF a.next!==null», «a.next.showName»«ENDIF»'''
	def CharSequence showType(Args a) '''«a.type.show»'''
	
	def dispatch CharSequence showReq(Post post)'''Post'''
	def dispatch CharSequence showReq(Get get)'''Get'''
	def dispatch CharSequence showReq(Put put)'''Put'''
	def dispatch CharSequence showReq(Delete del)'''Delete'''

}

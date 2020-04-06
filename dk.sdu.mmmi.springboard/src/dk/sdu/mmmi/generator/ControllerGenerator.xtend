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
import java.util.ArrayList
import dk.sdu.mmmi.springBoard.Service
import dk.sdu.mmmi.springBoard.CRUDActions

class ControllerGenerator {

	val mavenSrcStructure = "src/main/java/"

	def CharSequence generateController(Model model, Service service, String packName, boolean isASubClass) {
		'''
package «packName».controllers;
import «packName».models.«model.name»; 
import org.springframework.web.bind.annotation.*;
import dk.sdu.mmmi.project.services.I«model.name»;

import javax.validation.Valid;
import java.util.List;

@RestController
public class «model.name»Controller {
	private I«model.name» «model.name.toFirstLower»Service;
	
	public «model.name»Controller(I«model.name» «model.name.toFirstLower»Service) {
	        this.«model.name.toFirstLower»Service =  «model.name.toFirstLower»Service;
	}

	«generateCRUDMethods(service, model)»

}
'''
	}

	def createController(Model model, Service service, IFileSystemAccess2 fsa, String packName, boolean isASubClass) {
		if (!isASubClass) {
			fsa.generateFile(
				mavenSrcStructure + packName.replace('.', '/') + "/controllers/" + model.name + "Controller.java",
				generateController(model, service, packName, isASubClass)
			)
		}
	}

	def generateCRUDMethods(Service service, Model model) {
		'''
			«FOR a : service.crud.act»
				«IF a == CRUDActions.C»
				
					@PostMapping("/api/«model.name»")
					public boolean create«model.name»(@Valid @RequestBody «model.name» «model.name.toFirstLower») {
						return «model.name.toFirstLower»Service.create(«model.name.toFirstLower»);
					}	
				«ENDIF»
				«IF a == CRUDActions.R»
				
					@GetMapping("/api/«model.name»/{id}")
					public «model.name» find(Long id) {
						return «model.name.toFirstLower»Service.find(id);
					}						
				«ENDIF»
				«IF a == CRUDActions.U»
				
				    @PostMapping("/api/«model.name»/{id}")
				    public boolean update(Long id) {
				        return «model.name.toFirstLower»Service.update(id);
				    }
				    
				    @PostMapping("/api/«model.name»/{id}")
				    public boolean update(«model.name» «model.name.toFirstLower») {
				    	return «model.name.toFirstLower»Service.update(«model.name.toFirstLower»);
				    }						
				«ENDIF»
				«IF a == CRUDActions.D»
				
				    @PostMapping("/api/«model.name»/{id}")
				    public boolean delete(Long id) {
				        return «model.name.toFirstLower»Service.delete(id);
				    }
				    
				    @PostMapping("/api/«model.name»/{id}")
				    public boolean delete(«model.name» «model.name.toFirstLower») {
				    	return  «model.name.toFirstLower»Service.delete(«model.name.toFirstLower»);
				    }   	
				«ENDIF»
			«ENDFOR»
		'''
	}

}

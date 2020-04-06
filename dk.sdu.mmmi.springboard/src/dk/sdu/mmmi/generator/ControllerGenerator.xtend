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

class ControllerGenerator {

	val mavenSrcStructure = "src/main/java/"

	def CharSequence generateController(Model model, String packName, boolean isASubClass) {
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
}

'''
	}

	def createController(Model model, IFileSystemAccess2 fsa, String packName, boolean isASubClass) {
		if (!isASubClass) {
			fsa.generateFile(
				mavenSrcStructure + packName.replace('.', '/') + "/controllers/" + model.name + "Controller.java",
				generateController(model, packName, isASubClass)
			)
		}
	}



}

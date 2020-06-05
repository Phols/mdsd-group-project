/*
 * generated by Xtext 2.20.0
 */
package dk.sdu.mmmi.validation

import org.eclipse.xtext.validation.Check
import dk.sdu.mmmi.springBoard.CRUD
import java.util.regex.Pattern
import dk.sdu.mmmi.springBoard.Model
import dk.sdu.mmmi.springBoard.SpringBoardPackage
import dk.sdu.mmmi.springBoard.Identifier
import dk.sdu.mmmi.springBoard.ModelType
import dk.sdu.mmmi.springBoard.ListOf
import dk.sdu.mmmi.springBoard.Bool
import dk.sdu.mmmi.springBoard.Str
import dk.sdu.mmmi.springBoard.Gt
import dk.sdu.mmmi.springBoard.Lt
import dk.sdu.mmmi.springBoard.Lteq
import dk.sdu.mmmi.springBoard.Gteq
import dk.sdu.mmmi.springBoard.Comp
import dk.sdu.mmmi.springBoard.SecurityOptions
import dk.sdu.mmmi.springBoard.DetailService
import dk.sdu.mmmi.springBoard.SecurityConfig

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class SpringBoardValidator extends AbstractSpringBoardValidator {

	Pattern cPattern = Pattern.compile("([C]).*([C])")
	Pattern rPattern = Pattern.compile("([R]).*([R])")
	Pattern uPattern = Pattern.compile("([U]).*([U])")
	Pattern dPattern = Pattern.compile("([D]).*([D])")

	@Check
	def checkCrudActions(CRUD crud) {
		
		val matchString = crud.getAct().toString().replace(", ", "")

		val cMatcher = cPattern.matcher(matchString);
		
		if (cMatcher.find()) {
			error('Only one Create method allowed', crud, null);
		}
		
		val rMatcher = rPattern.matcher(matchString);
		
		if (rMatcher.find()) {
			error('Only one Read method allowed', crud, null);
		}
		
		val uMatcher = uPattern.matcher(matchString);
		
		if (uMatcher.find()) {
			error('Only one Update method allowed', crud , null);
		}
		
		val dMatcher = dPattern.matcher(matchString);
		
		if (dMatcher.find()) {
			error('Only one Delete method allowed', crud, null);
		}
		
	}
	
	/**
	 * Inspired by Bettini
	 */
	@Check
	def checkNoCycleInEntityHierarchy(Model model) {
		if (model.inh.base === null)
			return // nothing to check
		val visitedEntities = newHashSet(model)
		var current = model.inh.base
		while (current !== null) {
			if (visitedEntities.contains(current)) {
				error("Cycle in hierarchy of model '"+current.name+"'",
					SpringBoardPackage.Literals.MODEL__INH)
				return
			}
			visitedEntities.add(current)
			current = current.inh.base
		}
	}
	
	@Check
	def checkOnlySingleIdForModel(Model model) {
		if (model.inh !== null) {
			if (!model.fields.filter[ f | f.type instanceof Identifier].empty) {
				error("Subclasses must not have an ID field.", SpringBoardPackage.Literals.MODEL__FIELDS)
			}
		} else {
			if (model.fields.filter[ f | f.type instanceof Identifier].size != 1) {
				error("A model must have a single ID field.", SpringBoardPackage.Literals.MODEL__NAME)
			}
		}
	}
	
	@Check
	def checkComparisonOperator(Comp comp) {
		if (comp.left.type.class !== comp.right.type.class) {
			error("Type mismatch", comp, SpringBoardPackage.Literals.COMP__RIGHT)
		}
		switch comp.left.type {
			ModelType,
			ListOf,
			Bool,
			Str,
			Identifier: switch comp.op {
				Gt,
				Lt,
				Lteq,
				Gteq: error("Invalid operator for this type", comp, SpringBoardPackage.Literals.COMP__OP)
				default:''
			}
			default: ''
		}
	}
	
	@Check
	def checkServiceModelisChosen(SecurityConfig config){
		if(config.optionalSetting.filter[option | option.detailSerivce !== null].size !==1){
			error("A WebSecurityConfig can not have more than a single DetailService", SpringBoardPackage.Literals.SECURITY_CONFIG__OPTIONAL_SETTING)
		}	
	}
	
	@Check
	def checkServiceModelBaseClassContainsUsernameAndPassword(DetailService config){
		//for (detailServiceCandidate : config.optionalSetting.filter(option | option.detailSerivce !== null)){
			
			if(config.base.fields.filter[field | field.name.toLowerCase.equals("username")].empty ||
				(config.base.fields.filter[field | field.name.toLowerCase.equals("password")].empty)
			){
				error("A DetailService base model must have a username and password field", SpringBoardPackage.Literals.DETAIL_SERVICE__BASE)
			 }
		//}
		
	}

}

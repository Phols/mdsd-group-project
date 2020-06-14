/*
 * generated by Xtext 2.20.0
 */
package dk.sdu.mmmi.scoping

import org.eclipse.xtext.scoping.IScope
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import java.util.ArrayList
import org.eclipse.xtext.scoping.Scopes
import dk.sdu.mmmi.springBoard.Field
import dk.sdu.mmmi.springBoard.SpringBoardPackage.Literals
import dk.sdu.mmmi.springBoard.ListOf
import dk.sdu.mmmi.springBoard.ModelType
import dk.sdu.mmmi.springBoard.Comp
import dk.sdu.mmmi.springBoard.Method
import dk.sdu.mmmi.springBoard.Args
import dk.sdu.mmmi.springBoard.Type
import java.util.List
import dk.sdu.mmmi.springBoard.Input

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class SpringBoardScopeProvider extends AbstractSpringBoardScopeProvider {

	override IScope getScope(EObject context, EReference reference) {
			if (context instanceof Comp && reference == Literals.COMP__RIGHT) {
			var methods = EcoreUtil2.getContainerOfType(context, Method);
			val candidates = new ArrayList<Field>

			var type = methods.type;

			if (type instanceof ListOf) {
				type = (type as ListOf).type
			}
			if (type instanceof ModelType) {
				var model = (type as ModelType)
				candidates.addAll(model.base.getFields.filter(Field))
				if (model.base.inh !== null) {
					candidates.addAll(model.base.inh.base.getFields.filter(Field))
				}
			} else {
				return super.getScope(context, reference)
			}
			return Scopes.scopeFor(candidates)
		}
		return super.getScope(context, reference)
	}
}

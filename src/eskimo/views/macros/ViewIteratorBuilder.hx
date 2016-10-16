package eskimo.views.macros;
import eskimo.macros.TypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Type;

using haxe.macro.Tools;

/**
 * ...
 * @author PDeveloper
 */
class ViewIteratorBuilder
{
	
	public static var type_name = "ViewIterator";
	
    static var arityMap = new Map<String, Bool>();
	
    static function build():ComplexType
	{
        return switch (Context.getLocalType())
		{
            case TInst(_.get() => {name: type_name}, types):
                buildType(types);
            default:
                throw false;
        }
	}
	
	static function buildType(types:Array<Type>):ComplexType
	{
        var arity = types.length;
		
		var types_string = TypeTools.createString(types);
        var name = '${type_name}_${types_string}';
		
		if (!arityMap.exists(name)) {
			var pos = Context.currentPos();
			
			var viewDef = {
				pack: ['eskimo', 'views'],
				name: 'View',
				params: [for (t in types) TPType(t.toComplexType())]
			};
			var viewType = TPath(viewDef);
			
			var entityComponentsDef = {
				pack: ['eskimo', 'views'],
				name: 'EntityComponents',
				params: [for (t in types) TPType(t.toComplexType())]
			};
			var entityComponentsType = TPath(entityComponentsDef);
			
			var fields:Array<Field> = [];
			var constructorExprs:Array<Expr> = [];
			
			var indexName = 'index';
			fields.push(TypeTools.buildVar(indexName, [APrivate], macro : Int));
			
			var viewName = 'view';
			fields.push(TypeTools.buildVar(viewName, [APrivate], viewType));
			
			constructorExprs.push(macro {
				this.view = view;
				this.index = 0;
			});
			
			fields.push(TypeTools.buildFunction('new', [APublic, AInline],
				[{ name: 'view', type: viewType }],
				macro : Void,
				constructorExprs)
			);
			
			var entityComponentsNewExpr:Expr = {expr: ENew(entityComponentsDef, [macro view, macro entity]), pos: Context.currentPos() };
			
			var hasNextExpr = [macro return index < view.entities.length];
			var nextExpr = macro {
				var entity = view.entities[index++];
				return $entityComponentsNewExpr;
			};
			
			fields.push(TypeTools.buildFunction('hasNext', [APublic, AInline], [],
				macro : Bool,
				hasNextExpr));
			
			fields.push(TypeTools.buildFunction('next', [APublic, AInline], [],
				entityComponentsType,
				[nextExpr]));
			
			Context.defineType({
				pos: pos,
				pack: ['eskimo', 'views'],
				name: name,
				meta: [],
				kind: TDClass(),
				fields: fields
			});
			
			arityMap[name] = true;
		}
		
        return TPath({pack: ['eskimo', 'views'], name: name});
	}
	
}
package eskimo.core.macros;
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

class FactoryBuilder
{
	
	public static var type_name = "Factory";
	
    static var arityMap = new Map<String, Bool>();
	
    static function build():ComplexType
	{
        return switch (Context.getLocalType())
		{
            case TInst(_.get() => {name: type_name}, types):
                buildFactory(types);
            default:
                throw false;
        }
	}
	
    static function buildFactory(types:Array<Type>):ComplexType
	{
        var arity = types.length;
		
		var types_string = TypeTools.createString(types);
		var name = '${type_name}_${types_string}';
		
		if (!arityMap.exists(name)) {
			var pos = Context.currentPos();
			
			var fields:Array<Field> = [];
			var constructorExprs:Array<Expr> = [];
			var initializorExprs:Array<Expr> = [];
			
			constructorExprs.push(macro if (manager != null) initialize(manager));
			initializorExprs.push(macro this.manager = manager);
			
			var entityType = macro : eskimo.Entity;
			var entityManagerType = macro : eskimo.EntityManager;
			
			var entityManagerName = 'manager';
			fields.push(TypeTools.buildVar(entityManagerName, [APublic], entityManagerType));
			
			for (i in 0...arity) {
				var info = TypeTools.getPathInfo(types[i]);
				var componentType = TPath({pack: info.pack, name: info.module, sub: info.name});
				var classExpr = TypeTools.buildTypeExpr(info.pack, info.module, info.name);
				
				var accessorName = (info.name.substr( -9) == 'Component') ? info.name.substr(0, -9) : info.name;
				var camelName = TypeTools.camelCase(accessorName);
				
				var containerName = '${camelName}Container';
				var arrayName = '${camelName}Array';
				
				initializorExprs.push(macro $b{[
					macro this.$containerName = manager.components.getContainer($classExpr),
					macro this.$arrayName = this.$containerName.storage,
				]});
				
				var meta:Metadata = [];
				fields.push(TypeTools.buildVar(containerName, [APublic], TPath({
					pack: ['eskimo', 'containers'], name: 'Container',
					params: [TPType(macro : $componentType)]
				})));
				fields.push(TypeTools.buildVar(arrayName, [APublic], TPath({
					pack: [], name: 'Array',
					params: [TPType(macro : $componentType)]
				})));
				
				var entityArg = { name: 'entity', type: entityType };
				var componentArg = { name: '$camelName', type: componentType };
				
				fields.push(TypeTools.buildFunction(
					'get$accessorName', [APublic, AInline], [entityArg],
					componentType,
					[ macro return this.$arrayName[entity.id()] ]
				));
				
				fields.push(TypeTools.buildFunction(
					'has$accessorName', [APublic, AInline], [entityArg],
					macro : Bool,
					[ macro return this.$arrayName[entity.id()] != null ]
				));
				
				fields.push(TypeTools.buildFunction(
					'remove$accessorName', [APublic, AInline],
					[entityArg],
					macro : Void,
					[ macro this.$containerName.set(entity, null) ]
				));
				
				fields.push(TypeTools.buildFunction(
					'set$accessorName', [APublic, AInline],
					[entityArg, componentArg],
					macro : Void,
					[ macro this.$containerName.set(entity, $i{camelName}) ]
				));
			}
			
			var entityComponentsDef = {
				pack: ['eskimo', 'core'],
				name: 'EntityComponents',
				params: [for (t in types) TPType(t.toComplexType())]
			};
			var entityComponentsType = TPath(entityComponentsDef);
			
			var entity_components_create_expr:Expr = {expr: ENew(entityComponentsDef, [macro this, macro entity]), pos: Context.currentPos() };
			
			var entityArg = { name: 'entity', type: entityType, opt: false };
			var entityArgOpt = { name: 'entity', type: entityType, opt: true };
			
			fields.push(TypeTools.buildFunction(
				'create', [APublic], [entityArgOpt],
				macro : $entityComponentsType,
				[
					(macro if (entity == null) entity = manager.create()),
					macro return $entity_components_create_expr
				]
			));
			
			fields.push(TypeTools.buildFunction(
				'destroy', [APublic], [entityArg],
				macro : Void,
				[
					macro manager.destroy(entity)
				]
			));
			
			fields.push(TypeTools.buildFunction(
				'new', [APublic, AInline], [{name: 'manager', type: entityManagerType, opt: true}],
				macro : Void,
				constructorExprs
			));
			
			fields.push(TypeTools.buildFunction(
				'initialize', [APublic], [{name: 'manager', type: entityManagerType}],
				macro : Void,
				initializorExprs
			));
			
			Context.defineType({
				pos: pos,
				pack: ['eskimo', 'core'],
				name: name,
				meta: [],
				kind: TDClass(),
				fields: fields
			});
			
			arityMap[name] = true;
		}
		
        return TPath({pack: ['eskimo', 'core'], name: name});
	}
	
}
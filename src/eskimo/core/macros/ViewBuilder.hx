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

class ViewBuilder
{
	
	public static var type_name = "View";
	
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
			
			var fields:Array<Field> = [];
			var constructorExprs:Array<Expr> = [];
			var initializorExprs:Array<Expr> = [];
			var destructorExprs:Array<Expr> = [];
			
			var entityType = macro : eskimo.Entity;
			var entityManagerType = macro : eskimo.EntityManager;
			
			var entityArrayType = macro : eskimo.containers.EntityArray;
			var entityArrayArrayType = macro : Array<Entity>;
			var iFilterType = macro : eskimo.filters.IFilter;
			var entityDispatcherType = macro : eskimo.events.EntityDispatcher;
			
			var entityArrayName = 'entities_array';
			fields.push(TypeTools.buildVar(entityArrayName, [APrivate], entityArrayType));
			
			var entityArrayArrayName = 'entities';
			fields.push(TypeTools.buildVar(entityArrayArrayName, [APublic], entityArrayArrayType));
			
			var filterName = 'filter';
			fields.push(TypeTools.buildVar(filterName, [APublic], iFilterType));
			
			var dispatcherName = 'dispatcher';
			fields.push(TypeTools.buildVar(dispatcherName, [APublic], entityDispatcherType));
			
			constructorExprs.push(macro $b{[
				macro this.dispatcher = new eskimo.events.EntityDispatcher(),
				
				macro this.entities_array = new eskimo.containers.EntityArray(),
				macro this.entities = entities_array.entities,
				macro this.filter = filter != null ? filter : new eskimo.filters.BitFilter([]),
				
				macro super(manager)
			]});
			initializorExprs.push(macro super.initialize(manager));
			
			for (i in 0...arity) {
				var info = TypeTools.getPathInfo(types[i]);
				var componentType = TPath({pack: info.pack, name: info.module, sub: info.name});
				var classExpr = TypeTools.buildTypeExpr(info.pack, info.module, info.name);
				
				var accessorName = (info.name.substr( -9) == 'Component') ? info.name.substr(0, -9) : info.name;
				var camelName = TypeTools.camelCase(accessorName);
				
				var containerName = '${camelName}Container';
				
				initializorExprs.push(macro $b{[
					macro this.$containerName.listen(this),
					macro filter.include($classExpr)
				]});
				destructorExprs.push(macro this.$containerName.unlisten(this));
			}
			
			initializorExprs.push(macro filter.update(manager.components));
			initializorExprs.push(macro for (entity in manager.entities) check(entity));
			
			fields.push(TypeTools.buildFunction('new', [APublic, AInline],
				[{name: 'manager', type: entityManagerType, opt: true},
				{name: 'filter', type: iFilterType, opt: true}],
				macro : Void,
				constructorExprs)
			);
			
			fields.push(TypeTools.buildFunction('initialize', [AOverride, APublic],
				[{name: 'manager', type: entityManagerType}],
				macro : Void,
				initializorExprs)
			);
			
			fields.push(TypeTools.buildFunction('dispose', [APublic], [], macro : Void, destructorExprs));
			
			var checkExpr = macro {
				if (filter.contains(entity))
				{
					if (!entities_array.has(entity))
					{
						entities_array.push(entity);
						for (listener in dispatcher.listeners) listener.onAdd(entity);
					}
					else for (listener in dispatcher.listeners) listener.onUpdate(entity, type);
				}
				else if (entities_array.has(entity))
				{
					entities_array.remove(entity);
					for (listener in dispatcher.listeners) listener.onRemove(entity);
				}
			};
			var updateExprs = macro check(entity, type);
			
			var iComponentTypeType = macro : eskimo.ComponentManager.IComponentType;
			
			fields.push(TypeTools.buildFunction('check', [APrivate],
				[{name: 'entity', type: entityType},
				{name: 'type', type: iComponentTypeType, opt: true}],
				macro : Void,
				[checkExpr]));
			
			fields.push(TypeTools.buildFunction('update', [APublic],
				[{name: 'entity', type: entityType},
				{name: 'type', type: iComponentTypeType}],
				macro : Void,
				[updateExprs]));
				
			var viewIteratorDef = {
				pack: ['eskimo', 'core'],
				name: ViewIteratorBuilder.type_name,
				params: [for (t in types) TPType(t.toComplexType())]
			};
			var viewIteratorType = TPath(viewIteratorDef);
			var viewIteratorNewExpr:Expr = {expr: ENew(viewIteratorDef, [macro this]), pos: Context.currentPos() };
			
			fields.push(TypeTools.buildFunction('iterator', [APublic, AInline], [],
				viewIteratorType,
				[macro return $viewIteratorNewExpr]));
			
			Context.defineType({
				pos: pos,
				pack: ['eskimo', 'core'],
				name: name,
				meta: [],
				kind: TDClass({
					pack: ['eskimo', 'core'],
					name: FactoryBuilder.type_name,
					params: [for (t in types) TPType(t.toComplexType())]
				},
				[{
					pack: ['eskimo', 'containers'],
					name: 'IContainerListener'
				}]),
				fields: fields
			});
			
			arityMap[name] = true;
		}
		
        return TPath({pack: ['eskimo', 'core'], name: name});
	}
	
}
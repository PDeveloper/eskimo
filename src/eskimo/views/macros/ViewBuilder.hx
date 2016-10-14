package eskimo.views.macros;
import eskimo.ComponentManager;
import eskimo.EntityManager;
import eskimo.bits.BitFlag;
import eskimo.filters.BitFilter;
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
    static var arityMap = new Map<String, Bool>();
	
    static function build():ComplexType
	{
        return switch (Context.getLocalType())
		{
            case TInst(_.get() => {name: "View"}, types):
                buildView(types);
            default:
                throw false;
        }
	}
	
	static function createName(types:Array<Type>):String
	{
        var arity = types.length;
		var types_strings = [];
		
		for (i in 0...arity) {
			var typePack = switch (types[i])
			{
				case TInst(ref, types): ref.get().pack;
				default:
					throw false;
			}
			var typeName = switch (types[i])
			{
				case TInst(ref, types): ref.get().name;
				default:
					throw false;
			}
			typePack.push(typeName);
			var fullType = typePack.join('_');
			types_strings.push(fullType);
		}
		var types_string = types_strings.join('_');
        return 'View_$types_string';
	}
	
	static function buildTypeExpr(pack:Array<String>, module:String, name:String):Expr
	{
		var packModule = pack.concat([module, name]);
		
		var typeExpr = macro $i{packModule[0]};
		for (idx in 1...packModule.length){
			var field = $i{packModule[idx]};
			typeExpr = macro $typeExpr.$field;
		}
		
		return macro $typeExpr;
	}
	
    static function buildView(types:Array<Type>):ComplexType
	{
        var arity = types.length;
		
        var name = createName(types);
		
		if (!arityMap.exists(name)) {
			var pos = Context.currentPos();
			
			var fields:Array<Field> = [];
			var constructorExprs:Array<Expr> = [];
			var initializorExprs:Array<Expr> = [];
			var destructorExprs:Array<Expr> = [];
			
			constructorExprs.push(macro super(_entities, _filter));
			
			for (i in 0...arity) {
				var typePack:Array<String>;
				var typeModule:String;
				var typeName:String;
				
				switch (types[i])
				{
					case TInst(ref, types):
						typePack = ref.get().pack;
						typeModule = ref.get().module.split('.').pop();
						typeName = ref.get().name;
					default:
						throw false;
				}
				
				var fullType = typePack.concat([typeModule, typeName]);
				var typeString = fullType.join('.');
				
				var accessorName = typeName;
				if (accessorName.substr( -9) == 'Component') accessorName = accessorName.substr(0, accessorName.length - 9);
				
				var containerName = accessorName.substr(0, 1).toLowerCase() + accessorName.substr(1);
				
				var fieldName = '${containerName}Container';
				var arrayName = '${containerName}Array';
				
				var ct = TPath({pack: typePack, name: typeModule, sub: typeName});
				var typeExpr = buildTypeExpr(typePack, typeModule, typeName);
				
				initializorExprs.push(macro super.initialize(_entities));
				initializorExprs.push(macro this.$fieldName = _entities.components.getContainer($typeExpr));
				initializorExprs.push(macro this.$arrayName = this.$fieldName.storage);
				initializorExprs.push(macro this.$fieldName.listen(this));
				destructorExprs.push(macro this.$fieldName.unlisten(this));
				initializorExprs.push(macro filter.include($typeExpr));
				
				var meta:Metadata = [];
				fields.push({
					pos: pos,
					name: fieldName,
					access: [APublic],
					kind: FVar(TPath({
							pack: ['eskimo', 'containers'],
							name: 'Container',
							params: [TPType(macro : $ct)]
					})),
					meta: meta,
				});
				fields.push({
					pos: pos,
					name: arrayName,
					access: [APublic],
					kind: FVar(TPath({
							pack: [],
							name: 'Array',
							params: [TPType(macro : $ct)]
					})),
					meta: meta,
				});
				
				fields.push({
					pos: pos,
					name: 'get$accessorName',
					access: [APublic, AInline],
					kind: FFun({
						args: [{name: 'entity', type: TPath({pack: ['eskimo'], name: 'Entity'})}],
						ret: macro : $ct,
						expr: macro $b{[
							macro return this.$arrayName[entity.id()]
						]}
					}),
				});
				
				fields.push({
					pos: pos,
					name: 'has$accessorName',
					access: [APublic, AInline],
					kind: FFun({
						args: [{name: 'entity', type: TPath({pack: ['eskimo'], name: 'Entity'})}],
						ret: macro : Bool,
						expr: macro $b{[
							macro return this.$arrayName[entity.id()] != null
						]}
					}),
				});
				
				fields.push({
					pos: pos,
					name: 'remove$accessorName',
					access: [APublic, AInline],
					kind: FFun({
						args: [{name: 'entity', type: TPath({pack: ['eskimo'], name: 'Entity'})}],
						ret: macro : Void,
						expr: macro $b{[
							macro this.$fieldName.set(entity, null)
						]}
					}),
				});
				
				var camelTypeName = typeName.substr(0, 1).toLowerCase() + typeName.substr(1);
				
				fields.push({
					pos: pos,
					name: 'set$accessorName',
					access: [APublic, AInline],
					kind: FFun({
						args: [{name: 'entity', type: TPath({pack: ['eskimo'], name: 'Entity'})},
								{name: '$camelTypeName', type: macro : $ct }],
						ret: macro : Void,
						expr: macro $b{[
							macro this.$fieldName.set(entity, $i{camelTypeName})
						]}
					}),
				});
			}
			
			var entity_view_class = EntityViewBuilder.buildView(types);
			var entity_view_create_expr:Expr = {expr: ENew({
				pack: ['eskimo', 'views'],
				name: 'EntityView',
				params: [for (t in types) TPType(t.toComplexType())]
			}, [macro _entities, macro entity]), pos: Context.currentPos() };
			
			fields.push({
				pos: pos,
				name: 'create',
				access: [APublic, AInline],
				kind: FFun({
					args: [],
					ret: macro : $entity_view_class,
					expr: macro $b{[
						(macro var entity = _entities.create()),
						macro return $entity_view_create_expr
					]}
				}),
			});
			
			initializorExprs.push(macro filter.update(_entities.components));
			initializorExprs.push(macro for (entity in _entities.entities) check(entity));
			
			fields.push({
				pos: pos,
				name: "new",
				access: [APublic, AInline],
				kind: FFun({
					args: [	{name: '_entities', type: TPath({pack: ['eskimo'], name: 'EntityManager'}), opt: true},
							{name: '_filter', type: TPath({pack: ['eskimo', 'filters'], name: 'IFilter'}), opt: true}],
					ret: macro : Void,
					expr: macro $b{constructorExprs}
				})
			});
			
			fields.push({
				pos: pos,
				name: "initialize",
				access: [AOverride, APublic],
				kind: FFun({
					args: [	{name: '_entities', type: TPath({pack: ['eskimo'], name: 'EntityManager'})}],
					ret: macro : Void,
					expr: macro $b{initializorExprs}
				})
			});
			
			fields.push({
				pos: pos,
				name: "dispose",
				access: [AOverride, APublic],
				kind: FFun({
					args: [],
					ret: macro : Void,
					expr: macro $b{destructorExprs}
				})
			});
			
			Context.defineType({
				pos: pos,
				pack: ['eskimo', 'views'],
				name: name,
				meta: [],
				kind: TDClass({
					pack: ['eskimo', 'views'],
					name: 'View',
					sub: 'ViewBase'
				}),
				fields: fields
			});
			
			arityMap[name] = true;
		}
		
        return TPath({pack: ['eskimo', 'views'], name: name});
	}
	
}
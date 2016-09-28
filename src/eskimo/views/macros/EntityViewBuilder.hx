package eskimo.views.macros;
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

class EntityViewBuilder
{
    static var arityMap = new Map<String, Bool>();
	
    static function build():ComplexType
	{
        return switch (Context.getLocalType())
		{
            case TInst(_.get() => {name: "EntityView"}, types):
                buildView(types);
            default:
                throw false;
        }
	}
	
    static public function buildView(types:Array<Type>):ComplexType {
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
        var name = 'EntityView_$types_string';
		
		if (!arityMap.exists(types_string)) {
			var pos = Context.currentPos();
			
			var fields:Array<Field> = [];
			var constructorExprs:Array<Expr> = [
			macro this.entities = entities,
			macro this.entity = entity
			];
			var typeParams:Array<TypeParamDecl> = [];
			
			fields.push({
				pos: pos,
				name: 'entity',
				access: [APrivate],
				kind: FVar(TPath({
						pack: ['eskimo'],
						name: 'Entity'
				}))
			});
			
			fields.push({
				pos: pos,
				name: 'entities',
				access: [APublic],
				kind: FVar(TPath({
						pack: ['eskimo'],
						name: 'EntityManager'
				}))
			});
				
			fields.push({
				pos: pos,
				name: 'set',
				access: [APublic, AInline],
				kind: FFun({
					args: [{name: 'entity', type: TPath({pack: ['eskimo'], name: 'Entity'})}],
					ret: macro : Void,
					expr: macro $b{[
						macro this.entity = entity
					]}
				}),
			});
			
			fields.push({
				pos: pos,
				name: 'get',
				access: [APublic, AInline],
				kind: FFun({
					args: [],
					ret: macro : eskimo.Entity,
					expr: macro $b{[
						macro return entity
					]}
				}),
			});
			
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
				var fullType = typePack.concat([typeName]);
				var typeString = fullType.join('.');
				
				var accessorName = typeName;
				if (accessorName.substr( -9) == 'Component') accessorName = accessorName.substr(0, accessorName.length - 9);
				
				var containerName = accessorName.substr(0, 1).toLowerCase() + accessorName.substr(1);
				
				var fieldName = '${containerName}Container';
				var arrayName = '${containerName}Array';
				
				var ct = TPath({pack: typePack, name: typeName});
				
				var pack = typePack;
				var module = typeName;
				
				var typeExpr = macro $i{pack[0]};
				for (idx in 1...pack.length){
					var field = pack[idx];
					var field = $i{field};
					typeExpr = macro $typeExpr.$field;
				}
				var module_i = $i{module};
				typeExpr = macro $typeExpr.$module_i;
				
				constructorExprs.push(macro this.$fieldName = entities.components.getContainer($typeExpr));
				constructorExprs.push(macro this.$arrayName = this.$fieldName.storage);
				
				var meta:Metadata = [];
				fields.push({
					pos: pos,
					name: fieldName,
					access: [APrivate],
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
					access: [APrivate],
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
						args: [],
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
						args: [],
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
						args: [],
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
						args: [{name: '$camelTypeName', type: macro : $ct }],
						ret: macro : Void,
						expr: macro $b{[
							macro this.$fieldName.set(entity, $i{camelTypeName})
						]}
					}),
				});
			}
			
			fields.push({
				pos: pos,
				name: "new",
				access: [APublic, AInline],
				kind: FFun({
					args: [	{name: 'entities', type: TPath({pack: ['eskimo'], name: 'EntityManager'})},
						{name: 'entity', type: TPath({pack: ['eskimo'], name: 'Entity'}), opt: true}],
					ret: macro : Void,
					expr: macro $b{constructorExprs}
				})
			});
			
			Context.defineType({
				pos: pos,
				pack: [],
				name: name,
				meta: [],
				kind: TDClass(),
				fields: fields
			});
			
			arityMap[types_string] = true;
		}
		
        return TPath({pack: [], name: name});
	}
	
}
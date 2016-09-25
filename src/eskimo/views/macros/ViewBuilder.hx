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
	
    static function buildView(types:Array<Type>):ComplexType {
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
        var name = 'View_$types_string';
		
		if (!arityMap.exists(types_string)) {
			var pos = Context.currentPos();
			
			var fields:Array<Field> = [];
			var constructorExprs:Array<Expr> = [];
			var initializorExprs:Array<Expr> = [];
			var destructorExprs:Array<Expr> = [];
			var typeParams:Array<TypeParamDecl> = [];
			
			constructorExprs.push(macro super(_entities, _filter));
			
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
						args: [{name: 'entity', type: TPath({pack: ['eskimo'], name: 'Entity'})}],
						ret: macro : $ct,
						expr: macro $b{[
							macro return this.$arrayName[entity]
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
							macro return this.$fieldName.set(entity, $i{camelTypeName})
						]}
					}),
				});
			}
			
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
				pack: [],
				name: name,
				meta: [],
				//params: typeParams,
				kind: TDClass({
					pack: ['eskimo', 'views'],
					name: 'View',
					sub: 'ViewBase'
				}),
				fields: fields
			});
			
			arityMap[types_string] = true;
		}
		
        //return TPath({pack: [], name: name, params: [for (t in types) TPType(t.toComplexType())]});
        return TPath({pack: [], name: name});
	}
	
}
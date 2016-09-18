package eskimo.views.macros;
import eskimo.bits.BitFlag;
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
			var destructorExprs:Array<Expr> = [];
			var typeParams:Array<TypeParamDecl> = [];
			
			constructorExprs.push(macro super(_entities));
			constructorExprs.push(macro this.filter = new eskimo.filters.Filter([]));
			
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
				
				var fieldName = 'container$i';
				var genericName = 'T$i';
				typeParams.push({name: genericName});
				var ct = TPath({pack: typePack, name: typeName});
				
				constructorExprs.push(macro this.$fieldName = cast _entities.components.getContainer(Type.resolveClass( $v{typeString} )));
				constructorExprs.push(macro _entities.components.getContainer(Type.resolveClass( $v{typeString} )).listen(this));
				destructorExprs.push(macro _entities.components.getContainer(Type.resolveClass( $v{typeString} )).unlisten(this));
				constructorExprs.push(macro filter.include(Type.resolveClass( $v{typeString} )));
				
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
					name: 'get$typeName',
					access: [APublic, AInline],
					kind: FFun({
						args: [{name: 'entity', type: TPath({pack: ['eskimo'], name: 'Entity'})}],
						ret: macro : $ct,
						expr: macro $b{[
							macro return this.$fieldName.get(entity)
						]}
					}),
					meta: meta,
				});
				
				var camelTypeName = typeName.substr(0, 1).toLowerCase() + typeName.substr(1);
				
				fields.push({
					pos: pos,
					name: 'set$typeName',
					access: [APublic, AInline],
					kind: FFun({
						args: [{name: 'entity', type: TPath({pack: ['eskimo'], name: 'Entity'})},
								{name: '$camelTypeName', type: macro : $ct }],
						ret: macro : Void,
						expr: macro $b{[
							macro return this.$fieldName.set(entity, $i{camelTypeName})
						]}
					}),
					meta: meta,
				});
			}
			
			constructorExprs.push(macro filter.update(_entities.components));
			constructorExprs.push(macro for (entity in _entities.entities) check(entity));
			
			fields.push({
				pos: pos,
				name: "new",
				access: [APublic],
				kind: FFun({
					args: [{name: '_entities', type: TPath({pack: ['eskimo'], name: 'EntityManager'})}],
					ret: macro : Void,
					expr: macro $b{constructorExprs}
				})
			});
			
			fields.push({
				pos: pos,
				name: "dispose",
				access: [APublic],
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
				params: typeParams,
				kind: TDClass({
					pack: ['eskimo', 'views'],
					name: 'View',
					sub: 'ViewBase'
				}),
				fields: fields
			});
			
			arityMap[types_string] = true;
		}
		
        return TPath({pack: [], name: name, params: [for (t in types) TPType(t.toComplexType())]});
	}
	
}
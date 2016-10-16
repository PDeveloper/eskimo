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

class EntityComponentsBuilder
{
	
    static var arityMap = new Map<String, Bool>();
	
    static function build():ComplexType
	{
        return switch (Context.getLocalType())
		{
            case TInst(_.get() => {name: base_name}, types):
                buildType(types);
            default:
                throw false;
        }
	}
	
    static public function buildType(types:Array<Type>):ComplexType {
        var arity = types.length;
		
		var types_string = TypeTools.createString(types);
        var name = 'EntityComponents_$types_string';
		
		var entityType = macro : eskimo.Entity;
		
		if (!arityMap.exists(name)) {
			var pos = Context.currentPos();
			
			var fields:Array<Field> = [];
			var constructorExprs:Array<Expr> = [
				macro this.factory = factory,
				macro this.entity = entity
			];
			
			var factoryType = TPath({
				pack: ['eskimo', 'core'],
				name: 'Factory',
				params: [for (t in types) TPType(t.toComplexType())]
			});
			
			fields.push(TypeTools.buildVar('factory', [APublic], factoryType));
			fields.push(TypeTools.buildVar('entity', [APrivate], entityType));
				
			fields.push(TypeTools.buildFunction('set',
				[APublic, AInline], [{name: 'entity', type: entityType }],
				macro : Void,
				[
					macro this.entity = entity
				])
			);
				
			fields.push(TypeTools.buildFunction('get',
				[APublic, AInline], [],
				entityType,
				[
					macro return entity
				])
			);
			
			for (i in 0...arity) {
				var info = TypeTools.getPathInfo(types[i]);
				var componentType = TPath({pack: info.pack, name: info.module, sub: info.name});
				
				var accessorName = (info.name.substr( -9) == 'Component') ? info.name.substr(0, -9) : info.name;
				var camelName = TypeTools.camelCase(accessorName);
				
				var containerName = '${camelName}Container';
				var arrayName = '${camelName}Array';
				
				var getter:Function = { 
					expr: macro return factory.$arrayName[entity.id()],
					ret: (macro : $componentType),
					args:[]
				}
				var setter:Function = { 
					expr: macro return factory.$containerName.set(entity, $i{camelName}),
					ret: (macro : $componentType),
					args:[{name: '$camelName', type: macro : $componentType }]
				}
				
				var propertyField:Field = {
					name:  camelName,
					access: [APublic],
					kind: FProp("get", "set", getter.ret), 
					pos: pos,
				};
				
				var getterField:Field = {
					name: "get_" + camelName,
					access: [APrivate, AInline],
					kind: FFun(getter),
					pos: pos,
				};
				var setterField:Field = {
					name: "set_" + camelName,
					access: [APrivate, AInline],
					kind: FFun(setter),
					pos: pos,
				};
				
				fields.push(propertyField);
				fields.push(getterField);
				fields.push(setterField);
			}
			
			fields.push(TypeTools.buildFunction('new', [APublic, AInline], [
					{ name: 'factory', type: factoryType },
					{ name: 'entity', type: entityType, opt: true, value: macro null }
				], macro : Void,
				constructorExprs));
			
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
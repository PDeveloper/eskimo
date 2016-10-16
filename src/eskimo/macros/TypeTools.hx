package eskimo.macros;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * ...
 * @author PDeveloper
 */

typedef PathInfo = {
	var pack:Array<String>;
	var module:String;
	var name:String;
}

class TypeTools
{
	
	static public function createString(types:Array<Type>, delimiter:String = '_'):String
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
			var fullType = typePack.join(delimiter);
			types_strings.push(fullType);
		}
		return types_strings.join(delimiter);
	}
	
	static public function buildTypeExpr(pack:Array<String>, module:String, name:String):Expr
	{
		var packModule = pack.concat([module, name]);
		
		var typeExpr = macro $i{packModule[0]};
		for (idx in 1...packModule.length){
			var field = $i{packModule[idx]};
			typeExpr = macro $typeExpr.$field;
		}
		
		return macro $typeExpr;
	}
	
	static public inline function camelCase(name:String):String
	{
		return name.substr(0, 1).toLowerCase() + name.substr(1);
	}
	
	static public function buildVar(name:String, access:Array<Access>, type:ComplexType):Field
	{
		return {
			pos: Context.currentPos(),
			name: name,
			access: access,
			kind: FVar(type),
			meta: [],
		};
	}
	
	static public function buildFunction(name:String, access:Array<Access>, args:Array<FunctionArg>, ret:ComplexType, exprs:Array<Expr>):Field
	{
		return {
			pos: Context.currentPos(),
			name: name,
			access: access,
			kind: FFun({
				args: args,
				ret: ret,
				expr: macro $b{exprs}
			}),
		};
	}
	
	static public function getPathInfo(type:Type):PathInfo
	{
		var data:PathInfo = {
			pack: null,
			module: null,
			name: null
		}
		switch (type)
		{
			case TInst(ref, types):
				data.pack = ref.get().pack;
				data.module = ref.get().module.split('.').pop();
				data.name = ref.get().name;
			default:
				throw false;
		}
		
		return data;
	}
	
	static public function subclasses(type:ClassType, root:String):Bool
	{
		var name = type.module + '.' + type.name;
		return (name.substr(0, root.length) == root || type.superClass != null && subclasses(type.superClass.t.get(), root));
	}
	
}
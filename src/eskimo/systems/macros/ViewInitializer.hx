package eskimo.systems.macros;
import eskimo.views.View;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * ...
 * @author PDeveloper
 */

using haxe.macro.Tools;

class ViewInitializer
{
	
	macro static public function build2():Array<Field>
	{
        var fields = Context.getBuildFields();
        //var inits = [];
        //for (f in fields) {
        //    switch (f.kind) {
        //        case FVar(t, e):
		//			//if (t != null) trace (t.toType().toString());
		//			//else trace(Context.typeof(e).toString());
		//			
        //            if ((t != null && t.toType().toString() == "eskimo.views.EventView") || Context.typeof(e).toString() == "eskimo.views.EventView") {
        //                var fieldName = f.name;
        //                inits.push(macro this.$fieldName.initialize(systems.entities));
        //            }
        //        default:
        //    }
        //}
        //fields.push({
        //    name: "onInitialize",
        //    access: [AOverride, APublic],
        //    pos: Context.currentPos(),
        //    kind: FFun({
        //        ret: null,
        //        args: [{name: "systems", type: macro : SystemManager}],
        //        expr: macro $b{inits}
        //    })
        //});
		
		return fields;
	}
	
	macro static public
	function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		trace(fields);
		
		var tp:TypePath;
		
		var view_type = Context.getType('eskimo.views.View');
		var view_class_name:String = switch (view_type)
		{
			case TInst(ref, params):
				ref.get().pack.join('.') + '.' + ref.get().name;
			default:
				null;
		}
		
		var view_fields = new Array<Expr>();
		for (field in fields)
		{
			var f:Field;
			var isView = switch (field.kind)
			{
				case FieldType.FVar(t, e):
					switch (t)
					{
						case ComplexType.TPath(path):
							var type = Context.getType(path.name);
							switch (type)
							{
								case Type.TInst(ref, params):
									var ref0:Ref<ClassType>;
									var result = false;
									while (ref != null)
									{
										var class_name = ref.get().pack.join('.') + '.' + ref.get().name;
										
										if (class_name == view_class_name)
										{
											result = true;
											break;
										}
										else if (ref.get().superClass != null)
										{
											ref = ref.get().superClass.t;
										}
										else ref = null;
									}
									
									result;
								default: false;
							}
						default: false;
					}
				default: false;
			}
			
			if (isView)
			{
				view_fields.push(
					macro $i{field.name}
				);
			}
		}
		
		trace(view_fields);
		
		var view_array:Field = {
			name: '___system_views___',
			doc: null,
			meta: [],
			access: [APrivate],
			kind: FVar(macro : Array<eskimo.views.View>, macro $a{view_fields}),
			pos: Context.currentPos()
		};
		fields.push(view_array);
		
		return fields;
	}
	
}
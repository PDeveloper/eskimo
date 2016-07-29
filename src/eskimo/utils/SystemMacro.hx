package eskimo.utils;
import eskimo.views.View;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * ...
 * @author PDeveloper
 */

class SystemMacro
{
	
	macro static public
	function initializeViews():Array<Field>
	{
		var fields = Context.getBuildFields();
		
		var tp:TypePath;
		
		var view_type = Context.getType('kuo.View');
		var view_class_name:String = switch (view_type)
		{
			case TInst(ref, params):
				ref.get().pack.join('.') + '.' + ref.get().name;
			default:
				null;
		}
		
		var view_fields = new Array<Field>();
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
				view_fields.push(field);
			}
		}
		
		var view_array:Field = {
			name: '___system_views___',
			doc: null,
			meta: [],
			access: [APrivate],
			kind: FVar(macro : Array<eskimo.views.View>, macro []),
			pos: Context.currentPos()
		};
		fields.push(view_array);
		
		return fields;
	}
}
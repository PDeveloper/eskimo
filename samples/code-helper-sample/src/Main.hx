package;
import eskimo.views.BufferView;
import eskimo.Context;
import eskimo.Entity;
import eskimo.views.EventView;
import eskimo.views.View;
import eskimo.filters.Filter;
import eskimo.filters.NoFilter;
import eskimo.utils.SystemCreator;
import haxe.Json;
import Components;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;
using EntityHelper;

using eskimo.utils.ContextTools;

class Main 
{
	
	static function main():Void
	{
		var context = new Context();
		
		var creator = new SystemCreator(context);
		
		var e0 = context.create();
		var e1 = context.create();
		
		e0.addA('entity 0').addB(3);
		e1.addA('entity 1').addC( {
			prop: 'Hello'
		});
		
		creator.added(function (e) {
			var ca = e.get(ComponentA);
			trace(ca.string);
		}, new Filter([ComponentA]));
		
		creator.added(function (e) {
			var ca = e.get(ComponentA);
			var cb = e.get(ComponentB);
			
			var string = '';
			for (i in 0...cb.int) string += ca.string;
			trace(string);
		}, new Filter([ComponentA, ComponentB]));
		
		creator.entities(function (e) {
			trace(e.flag);
		}, new NoFilter());
	}
	
}
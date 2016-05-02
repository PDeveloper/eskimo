package;
import cpp.vm.Thread;
import eskimo.EventView;
import eskimo.ThreadContext;
import eskimo.View;
import Components;

/**
 * NOTE
 * For consistent thread-safety, logic MUST treat components as immutable, i.e. you cannot modify fields of a component, instead you
 * must create a new component with the new values, and set it to the entity once finished.
 * 
 * @author PDeveloper
 */

using eskimo.utils.ContextTools;

class Main 
{
	
	static function main():Void
	{
		var context = new ThreadContext();
		var threadContext = new ThreadContext();
		
		context.add(threadContext);
		
		var thread = Thread.create(run.bind(threadContext));
		
		for (i in 0...10)
		{
			var e = context.create();
			var c = new ComponentB(i);
			
			e.set(c);
		}
		
		var view = new EventView([ComponentA], context);
		
		var isRunning = true;
		while (isRunning)
		{
			context.update();
			
			for (e in view.added)
			{
				var string = e.get(ComponentA).string;
				trace('String: $string');
				
				if (string == '9') isRunning = false;
			}
			
			view.clear();
		}
	}
	
	private static function run(context:ThreadContext):Void
	{
		var view = new EventView([ComponentB], context);
		
		var isThreadRunning = true;
		while (isThreadRunning)
		{
			context.update();
			
			for (e in view.added)
			{
				var int = e.get(ComponentB).int;
				trace('Int: $int');
				
				var c = new ComponentA(Std.string(int));
				e.set(c);
				
				if (int == 9) isThreadRunning = false;
			}
			
			view.clear();
		}
	}
	
}
package;

import cpp.Lib;

/**
 * ...
 * @author PDeveloper
 */

class Main 
{
	
	static function main():Void
	{
		var basic = new BasicSample();
		basic.run();
		
		var thread = new ThreadSample();
		thread.run();
	}
	
}
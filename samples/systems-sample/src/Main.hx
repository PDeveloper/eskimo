package;
import eskimo.ComponentManager;
import eskimo.Entity;
import eskimo.EntityManager;
import eskimo.systems.SystemManager;
import haxe.Json;

import Components;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;

class Main 
{
	
	static function main():Void
	{
		trace('Systems API Tests');
		
		var components = new ComponentManager();
		var entities = new EntityManager(components);
		var systems = new SystemManager(entities);
		
		var systemA = new SystemA();
		var systemB = new SystemB();
		var systemC = new SystemC();
		
		systems.add(systemB);
		
		if (!systemB.isActive()) trace('Test 1 Succeeded :: SystemB is added but inactive');
		else trace('Test 1 Failed :: SystemB is added and became active');
		
		trace('System Update Start');
		systems.update(0.0);
		trace('System Update Finish');
		
		systems.add(systemA);
		
		if (systemA.isActive() && systemB.isActive()) trace('Test 2 Succeeded :: SystemA was added and active, and SystemB became active');
		else
		{
			trace('Test 2 Failed :: SystemA was added but not all systems became active');
			trace('SystemA: ${systemA.isActive()}, SystemB: ${systemB.isActive()}');
		}
		
		trace('System Update Start');
		systems.update(0.0);
		trace('System Update Finish');
		
		systems.add(systemC);
		
		if (systemA.isActive() && systemB.isActive() && systemC.isActive()) trace('Test 3 Succeeded :: SystemC was added and became active');
		else
		{
			trace('Test 3 Failed :: SystemC was added but not all systems became active');
			trace('SystemA: ${systemA.isActive()}, SystemB: ${systemB.isActive()}, SystemC: ${systemC.isActive()}');
		}
		
		trace('System Update Start');
		systems.update(0.0);
		trace('System Update Finish');
		
		systems.remove(systemA);
		
		if (!systemB.isActive() && !systemC.isActive()) trace('Test 4 Succeeded :: SystemA was removed, all systems became inactive');
		else
		{
			trace('Test 4 Failed :: SystemA was removed, but some systems were still active');
			trace('SystemB: ${systemB.isActive()}, SystemC: ${systemC.isActive()}');
		}
		
		trace('System Update Start');
		systems.update(0.0);
		trace('System Update Finish');
	}
	
}
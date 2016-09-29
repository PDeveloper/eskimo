## eskimo [0.2.x]
Eskimo is an entity-component system written in haxe, focused on having a small codebase, and functionality over performance. While this is still mildly true, version 0.2.x has been focused on optimizing the framework, and restricting the api to always be fast.

##### Install
* git `haxelib git eskimo https://github.com/PDeveloper/eskimo.git`
* haxelib `haxelib install eskimo`

##### Features
* Assign any class object as a component to an `Entity`.
* Filter entities based on which components they have using a `View`.
* Use an `EventView` to get lists of added, updated, or removed entities. Clear the events after processing with `.clear()`.
* `View`s generate fast component access functions. `MyComponentType => view.getMyComponentType(entity)/setMyComponentType(entity, myComponentType)`. If the typename ends with "Component", that will be omitted: `TransformComponent => view.getTransform(entity)/setTransform(entity, transform)`.

##### API Overview
* `ComponentManager` - component management.
  * `.set(entity, myComponent):Void` - set an object of any class to an `Entity`.
  * `.get(entity, MyComponentClass):MyComponentClass` - get a component of an `Entity` by class.
  * `.remove(entity, MyComponentClass):Void` - remove a component of an `Entity` by class.
  * `.has(entity, MyComponentClass):Bool` - check if an `Entity` has a component type.
  * `.clear(entity):Void` - remove all components of an `Entity`.
* `EntityManager(components:ComponentManager)` - entity management.
  * `.create(?[components]):Entity` - create an `Entity`.
  * `.destroy(entity):Void` - destroy an `Entity`.
  * `.clear():Void` - destroy all `Entity` objects.
* `Entity`
  * `.id():Int` - returns the raw id.
* `View<ComponentClass..>(entities:EntityManager, ?filter:IFilter)` - maintains a list of `Entity` objects corresponding to the `IncludeComponents` criteria.
  * `.entities:Array<Entity>` - an array of entities currently meeting the criteria of this `View`.
  * `.dispose():Void` - destroy this `View` when no longer used.
  * `.getComponentType(entity:Entity):ComponentType` - generated component getter.
  * `.setComponentType(entity:Entity, componentType:ComponentType):Void` - generated component setter.
* `EventView(dispatcher:EntityDispatcher, ?filter:IFilter)` - pass a `View` object to track entity changes. Optionally filter component updates.
  * `.added:Array<Entity>` - an array of added entities to this `View`.
  * `.updated:Array<Entity>` - an array of updated entities.
  * `.removed:Array<Entity>` - an array of removed entities.
  * `.clear():Void` - clears `added`/`updated`/`removed` arrays.
* `IFilter` - filter objects to filter entities
  * `Filter([IncludeComponents..], ?[ExcludeComponents], ?entities:EntityManager)` - basic filtering based on entity components.
  * `CallbackFilter(callback:Entity->Bool, [IncludeComponents..], ?[ExcludeComponents], ?entities:EntityManager)` - like `Filter`, with an additional callback that gets called after passing component requirements.
* `SystemManager(entities:EntityManager)` - system management and updating.
  * `.add(system:System):Void` - adds a `System` to this manager.
  * `.removes(system:System):Void` - removes a `System` to this manager.
  * `.has(SystemClass):Void` - check if this manager has a `System` type.
  * `.get(SystemClass):SystemClass` - get a `System` by class.
  * `.update(delta:Float):Void` - update all active `System` objects.
* `System(?[SystemDependencies..])` - base class for all systems, can require other `System` types from the manager before becoming active.
  * `.onInitialize(systems:SystemManager)` - gets called when system is added to the SystemManager.
  * `.onActivate(systems:SystemManager)` - gets called when system is activated to run by the SystemManager.
  * `.onUpdate(delta)` - override to handle `System` update, with delta time as argument.
  * `.onDeactivate(systems:SystemManager)` - gets called when system is deactivated.
  * `.onDispose(systems:SystemManager)` - gets called when system is removed.

##### Basic Usage
```haxe
package ;
import eskimo.ComponentManager;
import eskimo.EntityManager;
import eskimo.views.View;

class ComponentA {
	public var string:String;
	public function new(string:String):Void {
		this.string = string;
	}
}
class ComponentB {
	public var int:Int;
	public function new(int:Int):Void {
		this.int = int;
	}
}

class Main {

	static function main():Void {
		var components = new ComponentManager();
		var entities = new EntityManager(components);
		
		var viewab = new View<ComponentA, ComponentB>(entities);
		var eventsab = new EventView(viewab);
		var viewb = new View<ComponentB>(entities);
		
		var component0a = new ComponentA('Entity 0 with Component A');
		var component0b = new ComponentB(7);
		
		var entity0 = viewab.create();
		entity0.setComponentA(component0a);
		entity0.setComponentB(component0b);
		
		var component1b = new ComponentB(13);
		
		var entity1 = viewb.create();
		entity1.set(component1b);
		
		trace('Entities added: ${eventsab.added.length}');
		
		for (entity in viewab.entities) {
			trace('Entity id: ${entity.id}');
			trace(viewab.getComponentA(entity).string);
			trace(viewab.getComponentB(entity).int);
		}
		
		for (entity in viewb.entities) {
			trace('Entity id: ${entity.id}');
			trace(viewb.getComponentB(entity).int);
		}
	}
}
```

##### License
MIT as in free. Use it as you wish. Hopefully ethically and morally.

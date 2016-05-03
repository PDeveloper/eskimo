## eskimo
Eskimo is an entity-component system written in haxe, focused on having a small codebase, and functionality over performance.

##### Install
* git `haxelib git eskimo https://github.com/PDeveloper/eskimo.git`
* haxelib `haxelib install eskimo`

##### Features
* Create and destroy `Entity` objects through an instance of the `Context` class.
* Assign any class object as a component to an `Entity`.
* Filter entities based on which components they have using a `View`.
* Use an `EventView` to get lists of added, updated, or removed entities. Clear the events after processing with `.clear()`.
* Use a `BufferView` to maintain a cache of entity components. Update the buffer with `.buffer()`.

##### API Overview
* `Context` - entry point to using eskimo.
  * `entities.create():Entity` - creates and returns a new `Entity`.
  * `entities.destroy(entity):Void` - destroys the passed `Entity`.
  * `using eskimo.utils.ContextTools` - for faster access for basic functions on a Context object.
* `Entity`
  * `.set(myComponent):Void` - set an object of any class to this `Entity`.
  * `.get(MyComponentClass):MyComponentClass` - get a component of this `Entity` by class.
  * `.remove(MyComponentClass):Void` - remove a component of this `Entity` by class.
  * `.has(MyComponentClass):Bool` - check if this `Entity` has a component type.
* `View([IncludeComponents..], ?[ExcludeComponents..], ?context)` - maintains a list of `Entity` objects corresponding to the `IncludeComponents` and `ExcludeComponents` criteria.
  * `.entities:Array<Entity>` - an array of entities currently meeting the criteria of this `View`.
  * `.destroy():Void` - destroy this `View` when no longer used.
* `EventView([IncludeComponents..], ?[ExcludeComponents..], ?context)` - extends `View` with entity changes.
  * `.added:Array<Entity>` - an array of added entities to this `View`.
  * `.updated:Array<Entity>` - an array of updated entities.
  * `.removed:Array<Entity>` - an array of removed entities.
  * `.clear():Void` - clears `added`/`updated`/`removed` arrays.
* `BufferView([IncludeComponents..], ?[ExcludeComponents..], ?context)` - extends `View` with a component buffer.
  * `.previous(entity, MyComponentClass):MyComponentClass` - previous component of the passed `Entity` as buffered by this `BufferView`.
  * `.buffer():Void` - buffers the current components of all entities in this `View`.
* `SystemCreator(context)` - fast way to define some functionality with callbacks.
  * `entities(onEntity:Entity->Void, [IncludeComponents..], ?[ExcludeComponents..]):Void` - calls the callback for all valid entities.
  * `added/updated/removed(onEntity:Entity->Void, [IncludeComponents..], ?[ExcludeComponents..], clear = true):Void` - calls the callback for all valid entities, also clears the event queue if `clear` is set to true.

##### Usage
```haxe
package ;
import eskimo.Context;
import eskimo.View;

using eskimo.utils.ContextTools;

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
		var context = new Context();
		var entity0 = context.create();
		var entity1 = context.create();
		
		var component0a = new ComponentA('Entity 0 with Component A');
		var component0b = new ComponentB(7);
		entity0.set(component0a);
		entity0.set(component0b);
		
		var component1b = new ComponentB(13);
		entity1.set(component1b);
		
		var viewab = new View([ComponentA, ComponentB], context);
		var viewb = new View([ComponentB], context);
		
		for (entity in viewab.entities) {
			trace('Entity id: ${entity.id}');
			trace(entity.get(ComponentA).string);
			trace(entity.get(ComponentB).int);
		}
		
		for (entity in viewb.entities) {
			trace('Entity id: ${entity.id}');
			trace(entity.get(ComponentB).int);
		}
	}
}
```

##### Multi-Threading
While Eskimo's core is focused on being single-threaded, using the ThreadContext creates a threadsafe barrier, as long as 1 golden rule is followed:

**Components are immutable.**

You cannot modify a component directly, instead, create a new one, assign the new values to it, and set it to the `Entity`. This ensures component consistency across threads.

For a basic example of threading using Eskimo, see thread-sample in the samples folder.

##### Overview
Eskimo is currently focused on single-threaded execution. hxE2 attempted to address this, but with overkill; every single View would be threadsafe, which is unnecessary (multiple systems running on 1 thread, multiple views in a single system, etc.)

Another problem addressed by Eskimo is the entry point to modifying entity components. Although probably less efficient, it is much clearer than hxE2. Setting and getting components *always* happens through the Entity instance itself, not through a `View`. In the future I'll add more performant methods in accessing components, but the concept will be the same - always directly setting/getting to/from the ComponentManager. This means that under the hood, event management becomes simpler and consistent, with views still able to control which events they process.

Components no longer have a base class, and can be any object at all. Systems also are defined only by the `ISystem` interface. Like hxE2, using the provided systems and the SystemManager class to run them is completely optional, and considered a utility more than anything else. In the future, I am working on helper macros to save users from tedious house keeping, so that you can get right to coding system logic.

Views have a better defined role in eskimo than in hxE2 - at the core they *only* manage a list of entities that correspond to its filters. Previous iterations would have Views managing local component storage which only bloated things. I will add several types of views, starting with a basic "state" view, that only manages a list of entities, an "event" view, that will also manage a list of added/updated/removed entities, and a "buffer" view, that will store the previous component state of entities.

Phew. Any questions, make an issue. I'll work on a few samples and a short code demo right here in the description, meanwhile there's already a sample demonstrating the basic functionality. I'll be using this for my own projects and will update as I find things/add things.

##### Previous Efforts:
* hxE - lacked functionality, as a system could only process 1 type of Entity by default.
* hxE2 - had functionality, but was inconsistent, messy codebase due to a bad design choice, and because of this was hard to maintain or debug.

##### License
MIT as in free. Use it as you wish. Hopefully ethically and morally.

package eskimo;

import massive.munit.Assert;

@:access(eskimo.Entity)
class EntityTest
{
    @Test
    public function constructorSetsContextAndId()
    {
        var context:Context = new Context();
        var expectedId:Int = 37;
        var e:Entity = new Entity(context, expectedId);
        Assert.areEqual(context, e.context);
        Assert.areEqual(expectedId, e.id);
    }
    
    @Test
    public function getGetsLastSetComponent()
    {
        var context:Context = new Context();
        var e:Entity = context.create();
        
        var expected:IntComponent = new IntComponent(261);
        e.set(new IntComponent(37));
        e.set(expected);
        var actual = e.get(IntComponent);
        Assert.areEqual(expected, actual);
        Assert.areEqual(expected.value, actual.value);
    }
    
    @Test
    public function hasReturnsTrueIfComponentExists()
    {
        var context:Context = new Context();
        var e:Entity = context.create();
        Assert.isFalse(e.has(StringComponent));
        e.set(new StringComponent("hi!"));
        Assert.isTrue(e.has(StringComponent));        
    }
    
    @Test
    public function removeRemovesComponent()
    {
        var context:Context = new Context();
        var e:Entity = context.create();
        
        var expected:IntComponent = new IntComponent(987);
        e.set(expected);
        e.remove(IntComponent);
        Assert.isFalse(e.has(IntComponent));
        Assert.isNull(e.get(IntComponent));
    }
    
    @Test
    public function clearClearsAllComponents()
    {
        var context:Context = new Context();
        var e:Entity = context.create();
        e.set(new IntComponent(121));
        e.set(new StringComponent("hello!"));
        Assert.isTrue(e.has(IntComponent));
        Assert.isTrue(e.has(StringComponent));
        
        e.clear();
        Assert.isFalse(e.has(IntComponent));
        Assert.isFalse(e.has(StringComponent));
    }
}

// Helper components

class StringComponent
{
    public var value:String;
    public function new(value:String):Void
    {
        this.value = value;
    }
}

class IntComponent
{
    public var value:Int;
    public function new(value:Int):Void
    {
        this.value = value;
    }
}
package gameObjects;

//import haxe.Json;
//import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import data.CharacterData.DoidoOffsets;

using StringTools;

class Character extends FlxSprite
{
	public function new() {
		super();
	}

	public var curChar:String = "bf";
	public var isPlayer:Bool = false;

	public var holdTimer:Float = Math.NEGATIVE_INFINITY;
	public var holdLength:Float = 0.7;
	public var holdLoop:Int = 4;

	public var idleAnims:Array<String> = [];

	public var quickDancer:Bool = false;
	public var specialAnim:Bool = false;

	// warning, only uses this
	// if the current character doesnt have game over anims
	public var deathChar:String = "bf";

	public var globalOffset:FlxPoint = new FlxPoint();
	public var cameraOffset:FlxPoint = new FlxPoint();
	public var ratingsOffset:FlxPoint = new FlxPoint();
	private var scaleOffset:FlxPoint = new FlxPoint();

	public function reloadChar(curChar:String = "bf"):Character
	{
		this.curChar = curChar;

		holdLoop = 4;
		holdLength = 0.7;
		idleAnims = ["idle"];

		quickDancer = false;

		flipX = flipY = false;
		scale.set(1,1);
		antialiasing = FlxSprite.defaultAntialiasing;
		isPixelSprite = false;
		deathChar = "bf";

		var storedPos:Array<Float> = [x, y];
		globalOffset.set();
		cameraOffset.set();
		ratingsOffset.set();

		animOffsets = []; // reset it

		// what
		switch(curChar)
		{
			case "alexa":
				frames = Paths.getSparrowAtlas("characters/alexa/alexa");
				
				animation.addByPrefix('idle', 		'idle', 24, true);
				animation.addByPrefix('singLEFT', 	'left', 24, false);
				animation.addByPrefix('singDOWN', 	'down', 24, false);
				animation.addByPrefix('singUP', 	'up', 24, false);
				animation.addByPrefix('singRIGHT', 	'right', 24, false);
				animation.addByPrefix('spell', 	'spell', 24, false);

			case "gf":
				frames = Paths.getSparrowAtlas("characters/gf/gf");

				animation.addByPrefix('idle', 		'idle', 24, true);
				animation.addByPrefix('singLEFT', 	'left', 24, false);
				animation.addByPrefix('singDOWN', 	'down', 24, false);
				animation.addByPrefix('singUP', 	'up', 24, false);
				animation.addByPrefix('singRIGHT', 	'right', 24, false);

				animation.addByPrefix('singLEFTmiss', 	'MISSleft', 24, false);
				animation.addByPrefix('singDOWNmiss', 	'MISSdown', 24, false);
				animation.addByPrefix('singUPmiss', 	'MISSup', 24, false);
				animation.addByPrefix('singRIGHTmiss', 	'MISSright', 24, false);

				flipX = true;

			default:
				return reloadChar(isPlayer ? "gf" : "alexa");
		}
		
		// offset gettin'
		switch(curChar)
		{
			default:
				try {
					var charData:DoidoOffsets = cast Paths.json('images/characters/_offsets/${curChar}');
					
					for(i in 0...charData.animOffsets.length)
					{
						var animData:Array<Dynamic> = charData.animOffsets[i];
						addOffset(animData[0], animData[1], animData[2]);
					}
					globalOffset.set(charData.globalOffset[0], charData.globalOffset[1]);
					cameraOffset.set(charData.cameraOffset[0], charData.cameraOffset[1]);
					ratingsOffset.set(charData.ratingsOffset[0], charData.ratingsOffset[1]);
				} catch(e) {
					trace('$curChar offsets not found');
				}
		}
		
		playAnim(idleAnims[0]);

		updateHitbox();
		scaleOffset.set(offset.x, offset.y);

		if(isPlayer)
			flipX = !flipX;

		dance();

		setPosition(storedPos[0], storedPos[1]);

		return this;
	}

	private var curDance:Int = 0;

	public function dance(forced:Bool = false)
	{
		if(specialAnim) return;

		switch(curChar)
		{
			default:
				playAnim(idleAnims[curDance]);
				curDance++;

				if (curDance >= idleAnims.length)
					curDance = 0;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(animation.getByName(animation.curAnim.name + '-loop') != null)
			if(animation.curAnim.finished)
				playAnim(animation.curAnim.name + '-loop');
	}

	// animation handler
	public var animOffsets:Map<String, Array<Float>> = [];

	public function addOffset(animName:String, offX:Float = 0, offY:Float = 0):Void
		return animOffsets.set(animName, [offX, offY]);

	public function playAnim(animName:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0)
	{
		animation.play(animName, forced, reversed, frame);

		try
		{
			var daOffset = animOffsets.get(animName);
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		catch(e)
			offset.set(0,0);

		// useful for pixel notes since their offsets are not 0, 0 by default
		offset.x += scaleOffset.x;
		offset.y += scaleOffset.y;
	}
}
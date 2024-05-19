package gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
//import flixel.addons.effects.FlxSkewedSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import states.PlayState;

class Stage extends FlxGroup
{
	public var curStage:String = "";

	// things to help your stage get better
	public var bfPos:FlxPoint  = new FlxPoint();
	public var dadPos:FlxPoint = new FlxPoint();
	public var foreground:FlxGroup;

	public function new() {
		super();
		foreground = new FlxGroup();
	}

	public function reloadStageFromSong(song:String = "test"):Void
	{
		var stageList:Array<String> = [];
		
		stageList = switch(song)
		{
			default: ["world"];
		};
		
		/*
		*	makes changing stages easier by preloading
		*	a bunch of stages at the create function
		*	(remember to put the starting stage at the last spot of the array)
		*/
		for(i in stageList)
			reloadStage(i);
	}

	public function reloadStage(curStage:String = "")
	{
		this.clear();
		foreground.clear();
		
		dadPos.set(239.4, 245.55);
		bfPos.set(1235.25, 316.85);
		// setting gf to "" makes her invisible
		
		
		this.curStage = curStage;
		switch(curStage)
		{
			default:
				this.curStage = "world";
				PlayState.defaultCamZoom = 0.6;
				
				var sky = new FlxSprite(-488, -157.65).loadGraphic(Paths.image("backgrounds/sky"));
				sky.scrollFactor.set(0.3,0.5);
				add(sky);

				var bhill = new FlxSprite(-133.25, 251.25).loadGraphic(Paths.image("backgrounds/backhill"));
				bhill.scrollFactor.set(0.5,0.6);
				add(bhill);

				var mntn = new FlxSprite(-493.25, -137.55).loadGraphic(Paths.image("backgrounds/mountains"));
				mntn.scrollFactor.set(0.7,0.7);
				add(mntn);

				var mhill = new FlxSprite(-495.15, 293.95).loadGraphic(Paths.image("backgrounds/midhill"));
				mhill.scrollFactor.set(0.9,0.9);
				add(mhill);

				var land = new FlxSprite(-561.5, -242.7).loadGraphic(Paths.image("backgrounds/land"));
				add(land);
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	public function stepHit(curStep:Int = -1)
	{
		// put your song stuff here
		
		// beat hit
		if(curStep % 4 == 0)
		{
			
		}
	}
}
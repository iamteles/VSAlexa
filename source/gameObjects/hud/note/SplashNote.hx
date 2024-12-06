package gameObjects.hud.note;

import flixel.FlxG;
import flixel.FlxSprite;

class SplashNote extends FlxSprite
{
	public function new()
	{
		super();
		visible = false;
	}

	/*
	**	these are used so each note gets their own splash
	**	but if that splash already exists, then it spawns
	**	the same splash, so there are not
	** 	8204+ splashes created each song
	*/
	public static var existentModifiers:Array<String> = [];
	public static var existentTypes:Array<String> = [];

	public static function resetStatics()
	{
		existentModifiers = [];
		existentTypes = [];
	}

	public var assetModifier:String = "";
	public var noteType:String = "";
	public var noteData:Int = 0;

	public var holdSpl:Bool = false;

	public function reloadSplash(note:Note)
	{
		var direction:String = CoolUtil.getDirection(note.noteData);

		assetModifier = note.assetModifier;
		noteType = note.noteType;
		noteData = note.noteData;

		var splashtoplay = assetModifier;

		if(noteType == "bomb")
			splashtoplay = "bomb";

		if(note.isHoldEnd) {
			splashtoplay = "end";
			holdSpl = true;
		}

		switch(splashtoplay)
		{
			case 'doido':
				frames = Paths.getSparrowAtlas('notes/doido/splashes');
				animation.addByPrefix('splash', '$direction splash', 24, false);
				scale.set(0.95,0.95);
				updateHitbox();
			
			case "bomb":
				frames = Paths.getSparrowAtlas('notes/base/bomb_splash');
				animation.addByPrefix('splash', 'bombexplode', 24, false);
				scale.set(0.95,0.95);
				updateHitbox();

			case "end":
				frames = Paths.getSparrowAtlas("notes/base/holdSplashes");
				
				direction = direction.toUpperCase();
				animation.addByPrefix("splash",	'holdCoverEnd$direction', 	24, false);

				for(anim in ["start", "loop", "splash"])
					addOffset(anim, 6, -28);
				
				scale.set(0.7,0.7);
				updateHitbox();
			default:
				frames = Paths.getSparrowAtlas("notes/base/splashes");
			
				animation.addByPrefix("splash1", '$direction splash', 24, false);
				//animation.addByPrefix("splash2", 'note impact 2', 24, false);

				scale.set(0.75,0.75);
				updateHitbox();
		}

		playAnim();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(animation.finished)
		{
			visible = false;
		}
	}

	public var animOffsets:Map<String, Array<Float>> = [];
	public function addOffset(animName:String, offsetX:Float, offsetY:Float) {
		animOffsets.set(animName, [offsetX, offsetY]);
	}
	public function playAnim()
	{
		visible = true;
		var animList = animation.getNameList();
		var anim:String = animList[FlxG.random.int(0, animList.length - 1)];
		animation.play(anim, true, false, 0);
		updateHitbox();
		offset.x += frameWidth * scale.x / 2;
		offset.y += frameHeight* scale.y / 2;
		if(animOffsets.exists(anim))
		{
			var daOffset = animOffsets.get(anim);
			offset.x += daOffset[0];
			offset.y += daOffset[1];
		}
	}
}
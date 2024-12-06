package gameObjects.hud.note;

import flixel.FlxG;
import flixel.FlxSprite;

class HoldCover extends FlxSprite
{
	public function new()
	{
		super();
		visible = false;
	}

	public var assetModifier:String = "";
	public var noteType:String = "";
	public var noteData:Int = 0;

	public function reloadCover(note:Note)
	{
		var direction:String = CoolUtil.getDirection(note.noteData);

		assetModifier = note.assetModifier;
		noteType = note.noteType;
		noteData = note.noteData;
		
		switch(note.assetModifier)
		{
			default:
				frames = Paths.getSparrowAtlas('notes/base/covers/$direction');
			
				animation.addByPrefix("cover", 'hold0', 24, true);
				animation.play("cover", true, false, 0);
				
				scale.set(0.6,0.6);
				updateHitbox();

				offset.set(20, 20);
		}

		if(isPixelSprite)
			antialiasing = false;

		visible = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		//if(animation.finished)
		//	visible = false;
	}
}
package subStates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import data.GameData.MusicBeatSubState;
import gameObjects.Character;
import flixel.FlxBasic;
import states.*;

class GameOverSubState extends MusicBeatSubState
{
	public function new()
	{
		super();
	}
	
	override function create()
	{
		super.create();

		var bg = new FlxSprite(0, 0).loadGraphic(Paths.image("menu/bad-end"));
		bg.screenCenter();
		add(bg);
		
		// death sound
		FlxG.sound.play(switch(PlayState.SONG.song)
		{
			default: Paths.music("death/deathSound");
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lastCam = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		for(item in members)
		{
			if(Std.isOfType(item, FlxBasic))
				cast(item, FlxBasic).cameras = [lastCam];
		}

		if(!ended)
		{
			if(Controls.justPressed("BACK"))
			{
				FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function()
				{
					//Main.switchState(new MenuState());
					PlayState.sendToMenu();
				}, true);
				
			}

			if(Controls.justPressed("ACCEPT"))
				endBullshit();
		}
	}

	public var ended:Bool = false;

	public function endBullshit()
	{
		ended = true;

		CoolUtil.playMusic();
		FlxG.sound.play(Paths.music("death/deathMusicEnd"));

		new FlxTimer().start(1.0, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 1.0, false, null, true);

			new FlxTimer().start(2.0, function(tmr:FlxTimer)
			{
				Main.skipClearMemory = true;
				Main.resetState();
			});

		});
	}
}
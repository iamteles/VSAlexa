package states.story;

import data.Discord.DiscordClient;
import data.GameTransition;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import gameObjects.menu.Alphabet;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

//lets all love lain

class Love extends MusicBeatState
{
	override function create()
	{
		super.create();
		CoolUtil.playMusic("power");

		SaveData.data.set("lain", true);
		SaveData.save();

		var bg = new FlxSprite(0, 0);
		bg.frames = Paths.getSparrowAtlas('menu/intros/lain');
		bg.animation.addByPrefix('idle', 'Symbol 1', 24, true);
		bg.animation.play('idle');

		bg.setGraphicSize(1022.75, 720);
		bg.updateHitbox();
		bg.screenCenter();

		bg.alpha = 0.7;
		
		add(bg);

		// Updating Discord Rich Presence
		DiscordClient.changePresence("let's all love lain", null);
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
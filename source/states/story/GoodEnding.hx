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

class GoodEnding extends MusicBeatState
{
	override function create()
	{
		super.create();
		CoolUtil.playMusic();
		FlxG.sound.play(Paths.sound("youwin"));

		var bg = new FlxSprite(0, 0).loadGraphic(Paths.image("menu/good-end"));
		bg.screenCenter();
		add(bg);

		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus...", null);
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

        var accept:Bool = Controls.justPressed("ACCEPT");

		if(accept)
		{
			Main.switchState(new states.menu.MainState());
		}
	}
}
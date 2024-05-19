package states;

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

class DebugState extends MusicBeatState
{
	var optionShit:Array<String> = ["freeplay", "options"];
	static var curSelected:Int = 0;

	var optionGroup:FlxTypedGroup<Alphabet>;

	override function create()
	{
		super.create();
		CoolUtil.playMusic("mainmenu");

		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Debug Menu...", null);

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(80,80,80));
		bg.screenCenter();
		add(bg);

		optionGroup = new FlxTypedGroup<Alphabet>();
		add(optionGroup);

		for(i in 0...optionShit.length)
		{
			var item = new Alphabet(0,0, "nah", false);
			item.align = CENTER;
			item.text = optionShit[i].toUpperCase();
			item.x = FlxG.width / 2;
			item.y = 50 + ((item.height + 100) * i);
			item.ID = i;
			optionGroup.add(item);
		}

		changeSelection();
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var up:Bool = Controls.justPressed("UI_UP");
        var down:Bool = Controls.justPressed("UI_DOWN");
        var back:Bool = Controls.justPressed("BACK");
        var accept:Bool = Controls.justPressed("ACCEPT");

		if(up)
			changeSelection(-1);
		if(down)
			changeSelection(1);

		if(accept)
		{
			switch(optionShit[curSelected])
			{
				case "freeplay":
					Main.switchState(new states.menu.FreeplayState());
				case "options":
					Main.switchState(new states.menu.OptionsState());
			}
		}
	}

	public function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);

		for(item in optionGroup.members)
		{
			var daText:String = optionShit[item.ID].toUpperCase().replace("-", " ");

			var daBold = (curSelected == item.ID);

			if(item.bold != daBold)
			{
				item.bold = daBold;
				if(daBold)
					item.text = '> ' + daText + ' <';
				else
					item.text = daText;
				item.x = FlxG.width / 2;
			}
		}
	}
}
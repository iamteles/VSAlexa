package states.menu;

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
import flixel.addons.display.FlxBackdrop;
import data.SongData;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainState extends MusicBeatState
{
	var curSelected:Int = 0;
	var hand:FlxSprite;
	var noteSpr:FlxSprite;

	override function create()
	{
		super.create();
		CoolUtil.playMusic("mainmenu");

		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus...", null);

		var bg = new FlxSprite(0, 0).loadGraphic(Paths.image("menu/main/menu-bg"));
		bg.screenCenter();
		add(bg);

		var tiles = new FlxBackdrop(Paths.image('menu/main/menu-tiles'), XY, 0, 0);
        tiles.velocity.set(30, 0);
        tiles.screenCenter();
		//tiles.alpha = 0.7;
        add(tiles);

		var borders = new FlxSprite(0, 0).loadGraphic(Paths.image("menu/main/menu-borders"));
		borders.screenCenter();
		add(borders);

		var logo = new FlxSprite().loadGraphic(Paths.image("menu/main/logo"));
		logo.setGraphicSize(615.3, 475.75);
		logo.updateHitbox();
		logo.x = 23.7;
		logo.y = 128.95;
		add(logo);

		var play = new FlxSprite(863.85, 234.75-30);
		play.frames = Paths.getSparrowAtlas('menu/main/buttons');
		play.animation.addByPrefix('idle', 'play', 24, true);
		play.animation.play('idle');
		add(play);

		var options = new FlxSprite(863.5, 423.8-30);
		options.frames = Paths.getSparrowAtlas('menu/main/buttons');
		options.animation.addByPrefix('idle', 'options', 24, true);
		options.animation.play('idle');
		add(options);

		hand = new FlxSprite(692.15, 133.05).loadGraphic(Paths.image("menu/main/pointer"));
		add(hand);

		var skipTxt = new FlxText(0,0,0,"Made by: Coco Puffs, teles and CharaWhy\nPress CTRL to see our other mods!");
		skipTxt.setFormat(Main.gFont, 24, 0xFFFFFFFF, CENTER);
		skipTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        skipTxt.y = FlxG.height - skipTxt.height - 10;
		skipTxt.screenCenter(X);
		add(skipTxt);

		noteSpr = new FlxSprite(0, FlxG.height).loadGraphic(Paths.image("menu/main/note"));
		noteSpr.scale.set(0.7,0.7);
		noteSpr.updateHitbox();
		noteSpr.screenCenter(X);
		add(noteSpr);

		changeSelection();
	}

	var note:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var up:Bool = Controls.justPressed("UI_UP");
        var down:Bool = Controls.justPressed("UI_DOWN");
        var back:Bool = Controls.justPressed("BACK");
        var accept:Bool = Controls.justPressed("ACCEPT");

		if(!note) {
			if(up)
				changeSelection(-1);
			if(down)
				changeSelection(1);
	
			if(accept)
			{
				switch(curSelected)
				{
					case 0:
						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							note=true;
						});

						FlxTween.tween(noteSpr, {y: (FlxG.height/2) - (noteSpr.height/2)}, 0.5, {ease: FlxEase.cubeOut});
					case 1:
						Main.switchState(new states.menu.OptionsState());
				}
			}

			if(FlxG.keys.justPressed.CONTROL)
				FlxG.openURL("https://shatterdisk.neocities.org/mods");
		}

		if(note) {
			if(accept) {
				Main.switchState(new states.story.Dialog());
				/*
				var diff = CoolUtil.getDiffs()[0];
				PlayState.playList = [];
				PlayState.SONG = SongData.loadFromJson("evildoer-beware", diff);	
				PlayState.songDiff = diff;
				Main.switchState(new LoadSongState());
				*/
			}
		}

		var handY:Float = 133.05;
		if(curSelected == 1)
			handY = 317.3;

		hand.y = FlxMath.lerp(hand.y, handY+86, elapsed*6);

		if (FlxG.keys.firstJustPressed() != FlxKey.NONE && !note)
		{
			var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
			var keyName:String = Std.string(keyPressed);
			if(allowedKeys.contains(keyName)) {
				keysBuffer += keyName;
				if(keysBuffer.length >= 32) keysBuffer = keysBuffer.substring(1);
				for (wordRaw in easterEggKeys)
				{
					var word:String = wordRaw.toUpperCase();
					if (keysBuffer.contains(word))
					{
						switch (word) {
							case "LOVE":
								Main.switchState(new states.story.Love());
						}
						keysBuffer = '';
					}
				}
			}
		}
	}

	var keysBuffer:String = "";
    var easterEggKeys:Array<String> = [
		'LOVE'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

	public function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, 1);

		FlxG.sound.play(Paths.sound('menu/scrollMenu'));
	}
}
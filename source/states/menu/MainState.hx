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
import data.Highscore;
import data.Highscore.ScoreData;
import data.Timings;

using StringTools;

class MainState extends MusicBeatState
{
	var curSelected:Int = 0;
	var hand:FlxSprite;
	var play:FlxSprite;
	var options:FlxSprite;
	var noteSpr:FlxSprite;
	var texts:FlxGroup;
	var scores:FlxGroup;

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

		play = new FlxSprite(863.85, 234.75-30);
		play.frames = Paths.getSparrowAtlas('menu/main/buttons');
		play.animation.addByPrefix('idle', 'play', 24, true);
		play.animation.play('idle');
		add(play);

		options = new FlxSprite(863.5, 423.8-30);
		options.frames = Paths.getSparrowAtlas('menu/main/buttons');
		options.animation.addByPrefix('idle', 'options', 24, true);
		options.animation.play('idle');
		options.updateHitbox();
		add(options);

		hand = new FlxSprite(692.15, 133.05).loadGraphic(Paths.image("menu/main/pointer"));
		add(hand);

		var skipTxt = new FlxText(0,0,0,"Made by: Coco Puffs, teles and CharaWhy\nPress CTRL to see our other mods!");
		skipTxt.setFormat(Main.gFont, 24, 0xFFFFFFFF, CENTER);
		skipTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        skipTxt.y = FlxG.height - skipTxt.height - 10;
		//skipTxt.x = FlxG.width - skipTxt.width - 10;
		skipTxt.screenCenter(X);
		add(skipTxt);

		scores = new FlxGroup();
		add(scores);

		texts = new FlxGroup();
		add(texts);

		final middle:Float = options.x + (options.width / 2);

		var awesomeCounter:Int = 0;
		var otherCounter:Int = 0;
		for (i in ["0", "0%", "0"]) {
			var score = new FlxText(0,0,0,i);
			score.setFormat(Main.gFont, 24, 0xFFFFFFFF, LEFT);
			score.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			score.y = options.y + options.height + 15 + (score.height * awesomeCounter);
			score.x = middle + 5;
			score.alpha = 0;

			score.ID = awesomeCounter;
			awesomeCounter++;

			scores.add(score);
		}

		for (i in ["SCORE:", "ACCURACY:", "BREAKS:"]) {
			var score = new FlxText(0,0,0,i);
			score.setFormat(Main.gFont, 24, 0xFFFFFFFF, LEFT);
			score.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			score.y = options.y + options.height + 15 + (score.height * otherCounter);
			score.x = middle - score.width - 5;
			score.alpha = 0;

			score.ID = otherCounter;
			otherCounter++;

			texts.add(score);
		}

		noteSpr = new FlxSprite(0, FlxG.height).loadGraphic(Paths.image("menu/main/note"));
		noteSpr.scale.set(0.7,0.7);
		noteSpr.updateHitbox();
		noteSpr.screenCenter(X);
		add(noteSpr);

		changeSelection();

		realValues = Highscore.getScore('evildoer-beware-normal');
		lerpValues = {score: 0, accuracy: 0, misses: 0};
	}

	var note:Bool = false;

	public var realValues:ScoreData;
	public var lerpValues:ScoreData;
	var scoreAlpha = 1;
	var rank:String = "N/A";
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for(rawscore in scores.members)
		{
			if(Std.isOfType(rawscore, FlxText))
			{
				var score = cast(rawscore, FlxText);

				score.alpha = FlxMath.lerp(score.alpha, scoreAlpha, elapsed * 6);
				score.text = "";

				switch(score.ID) {
					case 0:
						score.text += Math.floor(lerpValues.score);
					case 1:
						score.text += (Math.floor(lerpValues.accuracy * 100) / 100) + "%" + ' [$rank]';
					case 2:
						score.text += Math.floor(lerpValues.misses);
				}
			}
		}

		for(rawtext in texts.members)
		{
			if(Std.isOfType(rawtext, FlxText))
			{
				var text = cast(rawtext, FlxText);
				text.alpha = FlxMath.lerp(text.alpha, scoreAlpha, elapsed * 6);
			}
		}

		lerpValues.score 	= FlxMath.lerp(lerpValues.score, 	realValues.score, 	 elapsed * 8);
		lerpValues.accuracy = FlxMath.lerp(lerpValues.accuracy, realValues.accuracy, elapsed * 8);
		lerpValues.misses 	= FlxMath.lerp(lerpValues.misses, 	realValues.misses, 	 elapsed * 8);

		rank = Timings.getRank(
			lerpValues.accuracy,
			Math.floor(lerpValues.misses),
			false,
			lerpValues.accuracy == realValues.accuracy
		);

		if(Math.abs(lerpValues.score - realValues.score) <= 10)
			lerpValues.score = realValues.score;
		if(Math.abs(lerpValues.accuracy - realValues.accuracy) <= 0.4)
			lerpValues.accuracy = realValues.accuracy;
		if(Math.abs(lerpValues.misses - realValues.misses) <= 0.4)
			lerpValues.misses = realValues.misses;

		if(curSelected == 0)
			scoreAlpha = 1;
		else
			scoreAlpha = 0;

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
			if(back) {
				new FlxTimer().start(0.1, function(tmr:FlxTimer){note=false;});

				FlxTween.tween(noteSpr, {y: FlxG.height}, 0.5, {ease: FlxEase.cubeIn});
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

		var song:String = (curSelected == 0 ? "evildoer-beware" : "none");

		realValues = Highscore.getScore('${song}-normal');
	}
}
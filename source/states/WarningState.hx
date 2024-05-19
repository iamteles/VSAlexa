package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class WarningState extends MusicBeatState
{
	override public function create():Void 
	{
		super.create();
		var tex:String = "Warning!\n\nThis mod features flashing lights that may\nbe harmful to those with photosensitivity.\nYou can disable them in the Options menu.\n\nPress ACCEPT";
		var popUpTxt = new FlxText(0,0,0,tex);
		popUpTxt.setFormat(Main.gFont, 36, 0xFFFFFFFF, CENTER);
		popUpTxt.screenCenter();
		add(popUpTxt);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		if(Controls.justPressed("ACCEPT"))
		{
            Main.switchState(new Intro());

            FlxG.save.data.beenWarned = true;
            FlxG.save.flush();
        }
	}
}

class Intro extends MusicBeatState
{
	var sprite:FlxSprite;
	var spriteSD:FlxSprite;
	override public function create():Void 
	{
		super.create();

        var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFFFFFFF);
		color.screenCenter();
		add(color);
        
		sprite = new FlxSprite();
		sprite.frames = Paths.getSparrowAtlas("menu/intros/flixel");
		sprite.animation.addByPrefix('start', 		'haxe', 24, false);
		sprite.animation.addByPrefix('startI', 		'haxe0000', 24, false);
		sprite.animation.play('startI');
		sprite.updateHitbox();
		sprite.screenCenter();
		//sprite.x += 30;
		sprite.alpha = 0;
		add(sprite);

		spriteSD = new FlxSprite();
		spriteSD.frames = Paths.getSparrowAtlas("menu/intros/shatterdisk");
		spriteSD.animation.addByPrefix('start', 		'opening', 24, false);
		spriteSD.animation.addByPrefix('startI', 		'opening0000', 24, false);
		spriteSD.animation.play('startI');
		spriteSD.updateHitbox();
		spriteSD.screenCenter();
		spriteSD.x -= 110;
		spriteSD.alpha = 0;
		add(spriteSD);


		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			sprite.alpha = 1;
			sprite.animation.play('start');
			FlxG.sound.play(Paths.sound("intro/haxe"), 1, false, null, true);
		});

		new FlxTimer().start(3.2, function(tmr:FlxTimer)
		{
			FlxTween.tween(sprite, {alpha: 0}, 0.5, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(spriteSD, {alpha: 1}, 0.4);
				spriteSD.animation.play('start');
				FlxG.sound.play(Paths.sound("intro/shatterdisk"), 1, false, null, true);

				new FlxTimer().start(5.4, function(tmr:FlxTimer)
				{
					finish();
				});
			}});
		});
	
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		var click:Bool = FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed;

		if (click)
		{
			finish();
		}
	}
	
	private function finish():Void
	{
		Main.skipClearMemory = true;
		Main.switchState(new states.menu.MainState());
	}
	
}
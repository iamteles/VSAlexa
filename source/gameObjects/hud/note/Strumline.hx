package gameObjects.hud.note;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import gameObjects.Character;

class Strumline extends FlxGroup
{
	public var strumGroup:FlxTypedGroup<StrumNote>;
	public var noteGroup:FlxTypedGroup<Note>;
	public var holdGroup:FlxTypedGroup<Note>;
	public var allNotes:FlxTypedGroup<Note>;

	public var splashGroup:FlxTypedGroup<SplashNote>;
	public var coverGroup:FlxTypedGroup<HoldCover>;
	
	public var x:Float = 0;
	public var downscroll:Bool = false;
	
	public var pauseNotes:Bool = false;
	public var scrollSpeed:Float = 2.8;
	public var scrollTween:FlxTween;

	public var isPlayer:Bool = false;
	public var botplay:Bool = false;
	public var customData:Bool = false;

	public var character:Character;

	public function new(x:Float, ?character:Character, ?downscroll:Bool, ?isPlayer = false, ?botplay = true, ?assetModifier:String = "base")
	{
		super();
		this.x = x;
		this.downscroll = downscroll;
		this.isPlayer 	= isPlayer;
		this.botplay 	= botplay;
		this.character 	= character;
		
		allNotes = new FlxTypedGroup<Note>();
		
		add(strumGroup 	= new FlxTypedGroup<StrumNote>());
		add(holdGroup 	= new FlxTypedGroup<Note>());
		add(coverGroup = new FlxTypedGroup<HoldCover>());
		add(splashGroup = new FlxTypedGroup<SplashNote>());
		add(noteGroup 	= new FlxTypedGroup<Note>());
		
		for(i in 0...4)
		{
			var strum = new StrumNote();
			strum.reloadStrum(i, assetModifier);
			strumGroup.add(strum);
		}

		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	public function addNote(note:Note)
	{
		allNotes.add(note);
		if(note.isHold)
			holdGroup.add(note);
		else
			noteGroup.add(note);
	}

	public function removeNote(note:Note)
	{
		allNotes.remove(note);
		if(note.isHold)
			holdGroup.remove(note);
		else
			noteGroup.remove(note);
	}

	// only one splash per note
	public var spawnedSplashes:Array<String> = [];
	public function addSplash(note:Note)
	{
		if(note.isHold && !note.isHoldEnd) return;

		// left-base-none
		var splashName:String
		= CoolUtil.getDirection(note.noteData) + '-'
		+ note.assetModifier + '-'
		+ (note.isHoldEnd ? "hold" : "note") + '-'
		+ note.noteType;

		//trace(splashName);

		if(!spawnedSplashes.contains(splashName))
		{
			spawnedSplashes.push(splashName);
			
			var splash = new SplashNote();
			splash.reloadSplash(note);
			splash.visible = false;
			splashGroup.add(splash);
			
			//trace('added ${note.strumlineID} $splashName lol');
		}
	}

	public function playSplash(note:Note, isPlayer:Bool = false)
	{
		//trace("trying to play " + note.assetModifier + note.noteType + note.noteData + note.isHoldEnd);
		switch(SaveData.data.get("Note Splashes"))
		{
			case "PLAYER ONLY": if(!isPlayer) return;
			case "OFF": return;
		}
		for(splash in splashGroup.members)
		{
			if(splash.assetModifier == note.assetModifier
			&& splash.noteType == note.noteType
			&& splash.noteData == note.noteData 
			&& splash.holdSpl == note.isHoldEnd)
			{
				//trace("played");
				var thisStrum = strumGroup.members[splash.noteData];
				splash.x = thisStrum.x;
				splash.y = thisStrum.y;

				splash.playAnim();
			}
		}
	}

	public var spawnedCovers:Array<String> = [];
	public function addCover(note:Note)
	{
		var coverName:String
		= CoolUtil.getDirection(note.noteData) + '-'
		+ note.assetModifier + '-'
		+ note.noteType;

		//trace(coverName);

		if(!spawnedCovers.contains(coverName))
		{
			spawnedCovers.push(coverName);
			
			var cover = new HoldCover();
			cover.reloadCover(note);
			cover.visible = false;
			coverGroup.add(cover);
			
			//trace('added ${note.strumlineID} $splashName lol');
		}
	}

	public function playCover(note:Note, isPlayer:Bool = false)
	{
		//trace("trying to play " + note.assetModifier + note.noteType + note.noteData + note.isHoldEnd);
		switch(SaveData.data.get("Note Splashes"))
		{
			case "PLAYER ONLY": if(!isPlayer) return;
			case "OFF": return;
		}
		for(cover in coverGroup.members)
		{
			if(cover.assetModifier == note.assetModifier
			&& cover.noteType == note.noteType
			&& cover.noteData == note.noteData)
			{
				//trace("played");
				var thisStrum = strumGroup.members[cover.noteData];
				cover.x = thisStrum.x - cover.width / 2;
				cover.y = thisStrum.y - cover.height/ 2;

				cover.visible = true;
			}
		}
	}

	public function endCover(note:Note, isPlayer:Bool = false)
	{
		//trace("trying to play " + note.assetModifier + note.noteType + note.noteData + note.isHoldEnd);
		switch(SaveData.data.get("Note Splashes"))
		{
			case "PLAYER ONLY": if(!isPlayer) return;
			case "OFF": return;
		}
		for(cover in coverGroup.members)
		{
			if(cover.assetModifier == note.assetModifier
			&& cover.noteType == note.noteType
			&& cover.noteData == note.noteData)
			{
				cover.visible = false;
			}
		}
	}
	
	/*
	*	sets up the notes positions
	*	you can change it but i dont recommend it
	*/
	public function updateHitbox()
	{
		for(strum in strumGroup)
		{
			strum.y = (!downscroll ? 110 : FlxG.height - 110);
			
			strum.x = x;
			strum.x += CoolUtil.noteWidth() * strum.strumData;
			
			strum.x -= (CoolUtil.noteWidth() * (strumGroup.members.length - 1)) / 2;
			
			strum.initialPos.set(strum.x, strum.y);
		}
	}
}
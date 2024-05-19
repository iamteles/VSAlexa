package states;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import data.ChartLoader;
import data.GameData.MusicBeatState;
import data.SongData.SwagSong;
import gameObjects.*;
import gameObjects.hud.*;
import gameObjects.hud.note.*;

#if !html5
import sys.thread.Mutex;
import sys.thread.Thread;
#end

import flixel.text.FlxText;

/*
*	preloads all the stuff before going into playstate
*	i would advise you to put your custom preloads inside here!!
*/
#if html5
class LoadSongState extends MusicBeatState
{
	var threadActive:Bool = true;

	var behind:FlxGroup;
	
	var loadBar:FlxSprite;
	var loadPercent:Float = 0;
	
	function addBehind(item:FlxBasic)
	{
		behind.add(item);
		behind.remove(item);
	}
	
	override function create()
	{
		super.create();

		behind = new FlxGroup();
		add(behind);
		
		var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		color.screenCenter();
		add(color);

		var botplayTxt = new FlxText(0,0,0,"Loading...");
		botplayTxt.setFormat(Main.gFont, 40, 0xFFFFFFFF, LEFT);
		botplayTxt.y = FlxG.height - botplayTxt.height - 5;
		add(botplayTxt);
		
		var oldAnti:Bool = FlxSprite.defaultAntialiasing;
		FlxSprite.defaultAntialiasing = false;
		
		PlayState.resetStatics();
		var assetModifier = PlayState.assetModifier;
		var SONG = PlayState.SONG;
		
		Paths.preloadPlayStuff();
		Rating.preload(assetModifier);
		Paths.preloadGraphic('hud/base/healthBar');
		var stageBuild = new Stage();
		addBehind(stageBuild);
		stageBuild.reloadStageFromSong(SONG.song);
		
		trace('preloaded stage and hud');
		loadPercent = 0.2;
		
		var charList:Array<String> = [SONG.player1, SONG.player2];
		for(i in charList)
		{
			var char = new Character();
			char.isPlayer = (i == SONG.player1);
			char.reloadChar(i);
			addBehind(char);
			
			//trace('preloaded $i');
			
			var icon = new HealthIcon();
			icon.setIcon(i, false);
			addBehind(icon);
			
			loadPercent += (0.6 - 0.2) / charList.length;
		}
		
		trace('preloaded characters');
		loadPercent = 0.6;
		
		Paths.preloadSound('songs/${SONG.song}/Inst');
		if(SONG.needsVoices)
			Paths.preloadSound('songs/${SONG.song}/Voices');
		
		trace('preloaded music');
		loadPercent = 0.75;
		
		var thisStrumline = new Strumline(0, null, false, false, true, assetModifier);
		thisStrumline.ID = 0;
		addBehind(thisStrumline);
		
		var noteList:Array<Note> = ChartLoader.getChart(SONG);
		for(note in noteList)
		{
			note.reloadNote(note.songTime, note.noteData, note.noteType, assetModifier);
			addBehind(note);
			
			thisStrumline.addSplash(note);
			
			loadPercent += (0.9 - 0.75) / noteList.length;
		}
		
		trace('preloaded notes');
		loadPercent = 0.9;
		
		// add custom preloads here!!
		switch(SONG.song)
		{
			default:
				//trace('loaded lol');
		}
		
		loadPercent = 1.0;
		trace('finished loading');
		FlxSprite.defaultAntialiasing = oldAnti;

		Main.skipClearMemory = true;
		Main.switchState(new PlayState());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
#else
class LoadSongState extends MusicBeatState
{
	var threadActive:Bool = true;
	var mutex:Mutex;
	
	var behind:FlxGroup;

	var loadPercent:Float = 0;
	
	function addBehind(item:FlxBasic)
	{
		behind.add(item);
		behind.remove(item);
	}
	
	override function create()
	{
		super.create();
		mutex = new Mutex();
		
		behind = new FlxGroup();
		add(behind);
		
		var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		color.screenCenter();
		add(color);

		var botplayTxt = new FlxText(0,0,0,"Loading...");
		botplayTxt.setFormat(Main.gFont, 40, 0xFFFFFFFF, LEFT);
		botplayTxt.y = FlxG.height - botplayTxt.height - 5;
		add(botplayTxt);
		
		var oldAnti:Bool = FlxSprite.defaultAntialiasing;
		FlxSprite.defaultAntialiasing = false;
		
		PlayState.resetStatics();
		var assetModifier = PlayState.assetModifier;
		var SONG = PlayState.SONG;
		
		var preloadThread = Thread.create(function()
		{
			mutex.acquire();
			Paths.preloadPlayStuff();
			Rating.preload(assetModifier);
			Paths.preloadGraphic('hud/base/healthBar');
			var stageBuild = new Stage();
			addBehind(stageBuild);
			stageBuild.reloadStageFromSong(SONG.song);
			
			trace('preloaded stage and hud');
			loadPercent = 0.2;
			
			var charList:Array<String> = [SONG.player1, SONG.player2];
			for(i in charList)
			{
				var char = new Character();
				char.isPlayer = (i == SONG.player1);
				char.reloadChar(i);
				addBehind(char);
				
				//trace('preloaded $i');
	
				var icon = new HealthIcon();
				icon.setIcon(i, false);
				addBehind(icon);
				
				loadPercent += (0.6 - 0.2) / charList.length;
			}
			
			trace('preloaded characters');
			loadPercent = 0.6;
			
			Paths.preloadSound('songs/${SONG.song}/Inst');
			if(SONG.needsVoices)
				Paths.preloadSound('songs/${SONG.song}/Voices');
			
			trace('preloaded music');
			loadPercent = 0.75;
			
			var thisStrumline = new Strumline(0, null, false, false, true, assetModifier);
			thisStrumline.ID = 0;
			addBehind(thisStrumline);
			
			var noteList:Array<Note> = ChartLoader.getChart(SONG);
			for(note in noteList)
			{
				note.reloadNote(note.songTime, note.noteData, note.noteType, assetModifier);
				addBehind(note);
				
				thisStrumline.addSplash(note);
				
				loadPercent += (0.9 - 0.75) / noteList.length;
			}
			
			trace('preloaded notes');
			loadPercent = 0.9;
			
			// add custom preloads here!!
			switch(SONG.song)
			{
				default:
					//trace('loaded lol');
			}

			Paths.preloadGraphic('hud/base/bars');
			Paths.preloadGraphic('hud/spells/spell1');
			Paths.preloadGraphic('hud/spells/spell2');
			Paths.preloadGraphic('hud/spells/spell3');
			Paths.preloadGraphic('hud/spells/spell4');
			
			loadPercent = 1.0;
			trace('finished loading');
			threadActive = false;
			FlxSprite.defaultAntialiasing = oldAnti;
			mutex.release();
		});
	}
	
	var byeLol:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(!threadActive && !byeLol)
		{
			byeLol = true;

			Main.skipClearMemory = true;
			Main.switchState(new PlayState());
		}
	}
}
#end
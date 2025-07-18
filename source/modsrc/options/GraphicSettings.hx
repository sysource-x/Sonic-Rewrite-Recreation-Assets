package options;

import backend.MusicBeatState;
import backend.DiscordClient;
import backend.Controls;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import Reflect;

class GraphicSettings extends MusicBeatState {
    var bg:FlxSprite;
    var menuTitle:FlxSprite;
    var leaving:Bool = false;
    var blueFade:FlxSprite;
    var curSelected:Int = 0;
    var curValue:Dynamic;
    var options:Array<Dynamic> = [
        ["Low Quality", "lowQuality", "If checked, disables some events such as noteskin changes,\nimproves performance.", "bool"],
        ["Anti-aliasing", "antialiasing", "If unchecked, disables anti-aliasing.\nWhile not used for most of the mod, disabling it can improve performance.", "bool"],
        ["Shaders", "shaders", "If unchecked, disables shaders.\nThey're used for some visual effects, disable this if game is crashing and you have an AMD GPU.", "bool"],
        ["GPU Caching", "cacheOnGPU", "If checked, allows the GPU to be used for caching textures, decreasing RAM usage.\nDon't turn this on if you have a low-end GPU.", "bool"],
        ["Framerate", "framerate", "Changes the game's framerate. Can improve performance at lower rates.", "int", [30, 240, 1, 50, "FPS"]]
    ];

    var descriptionText:FlxText;
    var hitMinMax:Bool = false;
    var optionsAssetsArray:Array<Array<Dynamic>> = [];
    var holdTime:Float = 0;

    override public function create():Void {
        super.create();

        DiscordClient.changePresence("Graphic Settings Menu", null);

        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        new FlxTimer().start(0.001, function(tmr) {
            FlxG.camera.alpha = 1;
            FlxG.camera.flash(0xFF000000, 0.6);
        });

        bg = new FlxSprite().loadGraphic(Paths.image("menus/options/bg"));
        bg.scale.set(3.25, 3.25);

        menuTitle = new FlxSprite().loadGraphic(Paths.image("menus/options/settings"));
        menuTitle.scale.set(2.5, 2.5);

        for (i in [bg, menuTitle]) {
            i.screenCenter();
            add(i);
        }

        menuTitle.y -= 310;

        for (i in 0...options.length) {
            var text:FlxText = new FlxText(90, 115 + i * 50, FlxG.width, options[i][0].toUpperCase());
            text.setFormat(Paths.font("sonic2HUD.ttf"), 44, 0xFFFFFFFF, "left", FlxTextBorderStyle.SHADOW, 0xFF000000);
            text.shadowOffset.x += 1;
            text.shadowOffset.y += 3;
            add(text);

            var assetArray:Array<Dynamic> = [text];

            switch (options[i][3]) {
                case "bool":
                    var checkbox = new FlxSprite(text.x + 550, text.y + 10);
                    checkbox.frames = Paths.getSparrowAtlas("menus/options/checkbox");
                    checkbox.animation.addByPrefix("on", "checkboxYES", 1, true);
                    checkbox.animation.addByPrefix("off", "checkboxNO", 1, true);
                    checkbox.animation.play(Reflect.getProperty(ClientPrefs.data, options[i][1]) ? "on" : "off");
                    checkbox.scale.set(2.2, 2.2);
                    add(checkbox);
                    assetArray.push(checkbox);

                case "percent":
                    var percent = new FlxSprite(text.x + 490, text.y);
                    percent.frames = Paths.getSparrowAtlas("menus/options/percent");
                    percent.animation.addByPrefix("0", "percent00", 1, true);
                    percent.animation.addByPrefix("0.1", "percent01", 1, true);
                    percent.animation.addByPrefix("0.2", "percent02", 1, true);
                    percent.animation.addByPrefix("0.3", "percent03", 1, true);
                    percent.animation.addByPrefix("0.4", "percent04", 1, true);
                    percent.animation.addByPrefix("0.5", "percent05", 1, true);
                    percent.animation.addByPrefix("0.6", "percent06", 1, true);
                    percent.animation.addByPrefix("0.7", "percent07", 1, true);
                    percent.animation.addByPrefix("0.8", "percent08", 1, true);
                    percent.animation.addByPrefix("0.9", "percent09", 1, true);
                    percent.animation.addByPrefix("1", "percent10", 1, true);
                    percent.animation.play(Std.string(Reflect.getProperty(ClientPrefs.data, options[i][1])));
                    add(percent);
                    assetArray.push(percent);

                case "int", "float":
                    var valueText:FlxText = new FlxText(text.x + 530, text.y, text.width, Reflect.getProperty(ClientPrefs.data, options[i][1]) + " " + options[i][4][4]);
                    valueText.setFormat(Paths.font("sonic2HUD.ttf"), 44, 0xFFFFFFFF, "left", FlxTextBorderStyle.SHADOW, 0xFF000000);
                    valueText.shadowOffset.x += 1;
                    valueText.shadowOffset.y += 3;
                    add(valueText);
                    assetArray.push(valueText);
            }

            optionsAssetsArray.push(assetArray);
        }

        descriptionText = new FlxText(0, 0, FlxG.width, "hello!");
        descriptionText.setFormat(Paths.font("sonic-1-hud-font.ttf"), 32, 0xFFFFFFFF, "center", FlxTextBorderStyle.SHADOW, 0xFF000000);
        descriptionText.screenCenter(0x01);
        descriptionText.y = 640;
        descriptionText.shadowOffset.x += 1;
        descriptionText.shadowOffset.y += 3;
        add(descriptionText);

        blueFade = new FlxSprite(0, 0).makeGraphic(100, 100, 0xFF0000FF);
        blueFade.scale.set(100, 100);
        blueFade.screenCenter();
        blueFade.blend = 9;
        blueFade.alpha = 0.001;
        add(blueFade);

        changeSelection(0, true);
    }

    function changeSelection(change:Int, silent:Bool) {
        if (!silent) FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);

        curSelected += change;
        if (curSelected > options.length - 1) curSelected = 0;
        if (curSelected < 0) curSelected = options.length - 1;

        for (i in 0...optionsAssetsArray.length) {
            if (i == curSelected) {
                optionsAssetsArray[i][0].color = 0xFFFCFC00;
            } else {
                optionsAssetsArray[i][0].color = 0xFFFFFFFF;
            }
        }

        descriptionText.text = options[curSelected][2];
        switch (options[curSelected][1]) {
            case "antialiasing", "shaders": descriptionText.y = 600;
            default: descriptionText.y = 640;
        }
        curValue = Reflect.getProperty(ClientPrefs.data, options[curSelected][1]);
    }

    function changeSetting(change:Float, ?silent:Bool = false) {
        switch (options[curSelected][3]) {
            case "bool":
                if (!silent) FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
                Reflect.setProperty(ClientPrefs.data, options[curSelected][1], !curValue);
                curValue = Reflect.getProperty(ClientPrefs.data, options[curSelected][1]);
                optionsAssetsArray[curSelected][1].animation.play(Reflect.getProperty(ClientPrefs.data, options[curSelected][1]) ? "on" : "off");

            case "percent":
                if (change == 0) return;
                var actualChange:Float = curValue + change;
                if (actualChange > options[curSelected][4][1] || actualChange < options[curSelected][4][0]) {
                    return;
                } else {
                    Reflect.setProperty(ClientPrefs.data, options[curSelected][1], actualChange);
                    curValue = Reflect.getProperty(ClientPrefs.data, options[curSelected][1]);
                }
                if (!silent) FlxG.sound.play(Paths.sound(options[curSelected][1] == "hitsoundVolume" ? "hitsound" : "scrollMenu"), options[curSelected][1] == "hitsoundVolume" ? ClientPrefs.data.hitsoundVolume : 0.8);
                optionsAssetsArray[curSelected][1].animation.play(Std.string(Reflect.getProperty(ClientPrefs.data, options[curSelected][1])));

            case "int", "float":
                if (change == 0) return;
                var actualChange:Float = curValue + change;
                if (actualChange > options[curSelected][4][1] || actualChange < options[curSelected][4][0]) {
                    hitMinMax = true;
                    return;
                } else {
                    hitMinMax = false;
                    Reflect.setProperty(ClientPrefs.data, options[curSelected][1], actualChange);
                    curValue = Reflect.getProperty(ClientPrefs.data, options[curSelected][1]);
                }
                if (!silent) FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
                optionsAssetsArray[curSelected][1].text = Reflect.getProperty(ClientPrefs.data, options[curSelected][1]) + " " + options[curSelected][4][4];
        }

        switch (options[curSelected][1]) {
            case "framerate":
                if(ClientPrefs.data.framerate > FlxG.drawFramerate) {
                    FlxG.updateFramerate = ClientPrefs.data.framerate;
                    FlxG.drawFramerate = ClientPrefs.data.framerate;
                } else {
                    FlxG.drawFramerate = ClientPrefs.data.framerate;
                    FlxG.updateFramerate = ClientPrefs.data.framerate;
                }
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (leaving) return;

        if (controls.BACK) {
            leaving = true;
            FlxG.sound.play(Paths.sound("cancelMenu"));
            FlxTween.tween(blueFade, {alpha: 1}, 0.5);
            FlxG.camera.fade(0xFF000000, 0.7);
            new FlxTimer().start(0.75, function(tmr) {
                // Troque pelo seu estado de opções principal:
                MusicBeatState.switchState(new modsrc.options.OptionsState());
            });
        }

        if (controls.UI_UP_P || controls.UI_DOWN_P) changeSelection(controls.UI_UP_P ? -1 : 1, false);
        if (controls.ACCEPT) changeSetting(0);
        if ((controls.UI_LEFT || controls.UI_RIGHT)) {
            var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
            var value = options[curSelected][4] == null ? 1 : options[curSelected][4][2];
            var actValue = controls.UI_LEFT ? -value : value;
            if (options[curSelected][3] != "bool") {
                holdTime += elapsed;
                if (pressed || holdTime > 0.5) {
                    changeSetting(actValue, holdTime > 0.5 ? true : false);
                }
            } else if (pressed) {
                changeSetting(actValue, false);
            }
        } else if ((controls.UI_LEFT_R || controls.UI_RIGHT_R)) {
            if (holdTime > 0.5 && !hitMinMax && options[curSelected][1] != "hitsoundVolume") FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
            holdTime = 0;
        }
    }
}

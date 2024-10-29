package settings;

import haxe.Json;
import sys.io.File;
import settings.SettingsFormat;

class Settings {

    private final settingsJson:SettingsFormat;

    public var codeRepoURL(get, null):String;
    public var codeCommitHash(get, null):String;
    public var dirForCode(get, null):String;

    public function new(settingsFile:String) {
        var content = File.getContent(settingsFile);
        settingsJson = cast Json.parse(content);
    }   

    function get_codeRepoURL():String {
        return settingsJson.codeRepoURL;
    }

    function get_codeCommitHash():String {
        return settingsJson.codeCommitHash;
    }

    function get_dirForCode():String {
        return settingsJson.dirForCode;
    }
}
package;

import settings.Settings;
import haxe.io.Path;
import sys.FileSystem;
import git.Commit;
import sys.io.Process;
import sys.io.File;

using StringTools;

class FnFork {

    static var settings:Settings;

    public static function main() {

        if (!FileSystem.exists('fnfork.properties')) {
            throw "FnFork properties file does not exists!";
        }

        settings = new Settings('fnfork.properties');

        if (!FileSystem.exists('patches'))
            FileSystem.createDirectory('patches');

        var args = Sys.args();
        switch (args[0]) {
            case "rebuildPatches":
                rebuildPatches();
            case "applyPatches":
                applyPatches();
            default:
                throw "Unknown arg " + args[0];
        }
    }

    private static function applyPatches() {
        if (FileSystem.exists('./.caches/lastFnfCommitHash.txt')) {
            if (settings.codeCommitHash == File.getContent('./.caches/lastFnfCommitHash.txt')) return;
        }

        //clonning code repo
        var gitClone = new Process('git clone ${settings.codeRepoURL} ./.caches/fnf');
        trace(gitClone.stdout.readAll().toString());
        trace(gitClone.stderr.readAll().toString());
        while (gitClone.exitCode(false) == null) {}
        gitClone.close();

        final cwd = Sys.getCwd();
        Sys.setCwd('./.caches/fnf');
        Sys.command('git reset --hard ${settings.codeCommitHash}');
        Sys.setCwd(cwd);

        File.saveContent('./.caches/lastFnfCommitHash.txt', settings.codeCommitHash);

        copyDirectory('./.caches/fnf', './${settings.dirForCode}');

        var patches = FileSystem.readDirectory('./patches');
        patches.sort((s1, s2) -> {
            var i1 = Std.parseInt(s1.split('-')[0]);
            var i2 = Std.parseInt(s2.split('-')[0]);
            if (i1 == i2) return 0;
            if (i1 > i2) return 1;
            return -1;
        });
        for (patch in patches) {
            var gitApply = new Process('git apply --reject "./patches/$patch"');
            while (gitApply.exitCode(false) == null) {
                trace(gitApply.stdout.readAll());
                trace(gitApply.stderr.readAll());
            }
            gitApply.close();
        }
    }

    private static function rebuildPatches() {
        final patchesDir = FileSystem.absolutePath('./patches/');
        Sys.setCwd('./${settings.dirForCode}');
        var gitLog = new Process("git --no-pager log");
        File.saveContent("a.txt", gitLog.stdout.readAll().toString());
        gitLog.close();

        var fileContent = File.getContent("a.txt");
        var commitsStr = readCommitsFromFileString(fileContent);
        var commits:Array<Commit> = [];
        for (commit in commitsStr) {
            commits.push(new Commit(commit));
        }

        FileSystem.deleteFile("a.txt");
        
        if (!FileSystem.exists(patchesDir))
            FileSystem.createDirectory(patchesDir);
        for (i in 0...commits.length) {
            var path = new Path('$patchesDir/${buildCommitNumber(i+1)}-${commits[i].commitName}.patch');
            trace(path.toString());
            var gitPatch = new Process('git format-patch -1 ${commits[i].hash} --stdout > "${path.toString()}"');
            gitPatch.close();
        }
    }

    private inline static function buildCommitNumber(i:Int):String {
        var retStr:String = Std.string(i);

        while (retStr.length != 4) {
            retStr = '0' + retStr;
        }

        return retStr;
    }

    private static function readCommitsFromFileString(fileStr:String):Array<String> {
        var ret:Array<String> = [];
        var lines = fileStr.split('\n');
        var commitStr:String = "";
        for (line in lines) {
            if (line.startsWith("commit")) { // Reading new commit
                if (commitStr != "")
                    ret.push(commitStr);
                commitStr = "";
                if (line.contains(File.getContent('.././.caches/lastFnfCommitHash.txt'))) // No need to create patch files for base repo commits
                    break;
            }
            commitStr += line + '\n';
        }
        if (commitStr != "")
            ret.push(commitStr);

        ret.reverse(); // From oldest to newest

        return ret;
    }

    private static function copyDirectory(src:String, dest:String) {
        if (!FileSystem.exists(dest))
            FileSystem.createDirectory(dest);

        for (file in FileSystem.readDirectory(src)) {
            final srcPath = '$src/$file';
            final destPath = '$dest/$file';

            if (FileSystem.isDirectory(srcPath)) {
                copyDirectory(srcPath, destPath);
            } else {
                File.saveBytes(destPath, File.getBytes(srcPath));
            }
        }
    }
}
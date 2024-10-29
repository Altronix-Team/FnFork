package git;

using StringTools;

class Commit {
    public final hash:String;
    public final authorNick:String;
    public final authorMail:String;
    public final commitDate:Date;
    public final commitName:String;

    public function new(commitString:String) {
        hash = parseHash(commitString);
        authorNick = parseAuthorNick(commitString);
        authorMail = parseAuthorMail(commitString);
        commitDate = parseCommitDate(commitString);
        commitName = parseCommitName(commitString);
    }

    function parseCommitName(commitString:String):String {
        return commitString.split("Date:")[1].split("\n")[2].trim();
    }

    function parseCommitDate(commitString:String):Date {
        var dateStr = commitString.split("Date:")[1].split("\n")[0].trim();
        var dateArr = dateStr.split(" ");
        var month = getMonth(dateArr[1]);
        var day = Std.parseInt(dateArr[2]);
        var dateTime = dateArr[3].split(':');
        var hour = Std.parseInt(dateTime[0]);
        var minute = Std.parseInt(dateTime[1]);
        var second = Std.parseInt(dateTime[2]);
        var year = Std.parseInt(dateArr[4]);
        var delta = dateArr[5].substr(0, 1);
        var deltaHours = Std.parseInt(dateArr[5].substr(1, 2));
        var deltaMinutes = Std.parseInt(dateArr[5].substr(2));
        hour += delta == "+" ? deltaHours : -deltaHours;
        minute += delta == "+" ? deltaMinutes : -deltaMinutes;

        return new Date(year, month, day, hour, minute, second);
    }

    function parseAuthorMail(commitString:String):String {
        return commitString.split("Author:")[1].split("<")[1].split(">")[0].trim();
    }

    function parseAuthorNick(commitString:String):String {
        return commitString.split("Author:")[1].split("<")[0].trim();
    }

    function parseHash(commitString:String):String {
        var str = commitString.split("Author")[0].replace("commit ", "");
        if (str != "" || !str.isSpace(0)) {
            return str.replace('\n', '');
        }

        throw "Unknown commit hash for: \n" + commitString;
    }

    function getMonth(monthString:String):Int {
        return switch (monthString) {
            case "Jan": 0;
            case "Feb": 1;
            case "Mar": 2;
            case "Apr": 3;
            case "May": 4;
            case "Jun": 5;
            case "Jul": 6;
            case "Aug": 7;
            case "Sep": 8;
            case "Oct": 9;
            case "Nov": 10;
            case "Dec": 11;
            default: -1; //Unknown Month
        };
    }

    public function toString():String {
        return '$hash\t$authorNick\t$authorMail\t$commitDate\t$commitName';
    }
}
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class Time extends WatchUi.Drawable {
    var hideSeconds = false;
    private var bebasNumbersFont, bebasNumbersSmallFont;

    function initialize() {
        var dictionary = {
            :identifier => "Time"
        };
        bebasNumbersFont = WatchUi.loadResource(Rez.Fonts.BebasNeueNumbersFont);
        bebasNumbersSmallFont = WatchUi.loadResource(Rez.Fonts.BebasNeueNumbersSmallFont);
        
        Drawable.initialize(dictionary);
    }

    public function setHideSeconds(flag) {
        hideSeconds = flag;
    }

    function drawSeconds(dc, isPartialUpdate) as Void {
        var x = dc.getWidth() / 2;
        var y = dc.getHeight() / 2;
        var clockTime = System.getClockTime();
		var seconds = clockTime.sec.format("%02d");

		if (isPartialUpdate && !hideSeconds) {
			dc.setClip(
				x - 26,
				y + 35,
				52,
				40
			);

			dc.clear();
		}

        if (!hideSeconds) {
            dc.setColor(AppBase.getProperty("secondsColor"), Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                x,
                y + 50,
                bebasNumbersSmallFont,
                seconds,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
        dc.clearClip();
    }

    function draw(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var hours = clockTime.hour.format("%02d");
        var mins = clockTime.min.format("%02d");
        var x = dc.getWidth() / 2;
        var y = dc.getHeight() / 2;
        

        dc.setAntiAlias(true);
        drawSeconds(dc, false);
        
        dc.setClip(
            x - 25,
            y - 45,
            50,
            85
        );
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(
            x - 1,
            y - 20,
            bebasNumbersFont,
            hours,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(AppBase.getProperty("minutesColor"), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x - 1,
            y + 20,
            bebasNumbersFont,
            mins,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.clearClip();
    }

}

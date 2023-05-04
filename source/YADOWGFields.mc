import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class Fields extends WatchUi.Drawable {
  private var sourceSansProFont;
  private var iconsFont;

  // TYPES
  enum {
    HEART,
    BATTERY,
    STEPS,
    STRESS,
  }

  function initialize() {
    var dictionary = {
      :identifier => "Fields"
    };
    sourceSansProFont = WatchUi.loadResource(Rez.Fonts.SourceSansProFont);
    iconsFont = WatchUi.loadResource(Rez.Fonts.IcoFont);

    Drawable.initialize(dictionary);
  }

  function getValue(type) as String {
    var value = "";
    var info = ActivityMonitor.getInfo();
    
    switch (type) {
      case HEART:
        var activityInfo = Activity.getActivityInfo();
        var sample = activityInfo.currentHeartRate;
        if (sample != null) {
          value = sample.format("%d");
        } else if (ActivityMonitor has :getHeartRateHistory) {
          sample = ActivityMonitor.getHeartRateHistory(1, /* newestFirst */ true)
            .next();
          if ((sample != null) && (sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
            value = sample.heartRate.format("%d");
          }
        }
        break;
      case STEPS:
        value = info.steps;
        break;
      case STRESS:
          if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getStressHistory)) {
          sample = SensorHistory.getStressHistory({:period => 1})
            .next();
          if ((sample != null)) {
            value = sample.data.format("%d");
          }
        }
        break;
    }   

    return value;
  }

  function updateHR(dc, isPartialUpdate) {
    var height = dc.getHeight();
    var width = dc.getWidth();

    var x = width / 2 - 45;
    var y = height / 2 - 20;

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    if (isPartialUpdate) {
			dc.setClip(
				width / 2 - 85,
				height / 2 - 35,
				25,
				30
			);

      dc.clear();
		}

    dc.drawText(
      width / 2 - 75,
      height / 2 - 20,
      sourceSansProFont,
      getValue(HEART),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      x,
      y,
      iconsFont,
      60447.toChar().toString(),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.clearClip();
  }

  function update(dc, isPartialUpdate) {
    var height = dc.getHeight();
    var width = dc.getWidth();

    updateHR(dc, isPartialUpdate);

    if (isPartialUpdate) {
      return;
    }

    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(1);
    dc.drawLine(35, height / 2 + 1, width / 2 - 40, height / 2 + 1);
    dc.drawLine(width / 2 + 40, height / 2 + 1, width - 35, height / 2 + 1);

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      width / 2 + 75,
      height / 2 - 20,
      sourceSansProFont,
      getValue(STEPS),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.setColor(Application.Properties.getValue("ydgBrightBlue"), Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      width / 2 + 45,
      height / 2 - 20,
      iconsFont,
      61239.toChar().toString(),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    var battery = Math.floor(System.getSystemStats().battery);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      width / 2 - 75,
      height / 2 + 20,
      sourceSansProFont,
      battery.format("%d") + "%",
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    ); 

    var batteryIconCharNumber;
    if (battery < 25) {
      dc.setColor(Application.Properties.getValue("ydgOrange"), Graphics.COLOR_TRANSPARENT);
      batteryIconCharNumber = 61108;
    } else if (battery < 50) {
      dc.setColor(Application.Properties.getValue("ydgYellow"), Graphics.COLOR_TRANSPARENT);
      batteryIconCharNumber = 61107;
    } else {
      dc.setColor(Application.Properties.getValue("ydgBrightGreen"), Graphics.COLOR_TRANSPARENT);
      batteryIconCharNumber = 61106;
    }
    dc.drawText(
      width / 2 - 45,
      height / 2 + 20,
      iconsFont,
      batteryIconCharNumber.toChar().toString(),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );


    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      width / 2 + 75,
      height / 2 + 20,
      sourceSansProFont,
      getValue(STRESS),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    ); 

    dc.setColor(Application.Properties.getValue("ydgLime"), Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      width / 2 + 45,
      height / 2 + 20,
      iconsFont,
      60426.toChar().toString(),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function draw(dc as Dc) as Void {
    update(dc, false);
  }
}

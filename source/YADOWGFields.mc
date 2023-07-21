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
    RESPIRATION,
    CALORIES,
    DISTANCE,
    ACTIVEMINUTES,
  }

  private var fields = [
    HEART,
    BATTERY,
    STEPS,
    STRESS,
    RESPIRATION,
    CALORIES,
    DISTANCE,
    ACTIVEMINUTES, 
  ];

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
      case BATTERY:
          var battery = Math.floor(System.getSystemStats().battery);
          value = battery.format("%d") + "%";
        break;
      case RESPIRATION:
          value = info.respirationRate;
        break;
      case CALORIES:
          value = info.calories;
        break;
      case DISTANCE:
          value = info.distance;
        break;
      case ACTIVEMINUTES:
          value = info.activeMinutesDay.total;
        break;
    }   

    return value;
  }

  function updateHR(dc, isPartialUpdate, coords, leftSide) {
    var clockTime = System.getClockTime();
		var seconds = clockTime.sec;
    if (isPartialUpdate && seconds % 5) {
      return;
    }

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    if (isPartialUpdate) {
			dc.setClip(
				coords[0] - 10,
				coords[1] - 10,
				25,
				30
			);

      dc.clear();
		}

    updateLambdaField(dc, false, HEART, coords, leftSide);

    dc.clearClip();
  }

  function getBatteryIcon() {
    var battery = Math.floor(System.getSystemStats().battery);

    var batteryIconCharNumber;
    if (battery < 25) {
      batteryIconCharNumber = 61108;
    } else if (battery < 50) {
      batteryIconCharNumber = 61107;
    } else {
      batteryIconCharNumber = 61106;
    }

    return batteryIconCharNumber.toChar().toString();
  }

  function getBatteryIconColor() as Number {
    var battery = Math.floor(System.getSystemStats().battery);

    if (battery < 25) {
      return Application.Properties.getValue("ydgOrange");
    } else if (battery < 50) {
      return Application.Properties.getValue("ydgYellow");
    } else {
      return Application.Properties.getValue("ydgBrightGreen");
    }
  }

  function getIcon(key) as String {
    switch (key) {
      case HEART:
        return 60447.toChar().toString();
      case STEPS:
        return 61239.toChar().toString();
      case STRESS:
        return 60426.toChar().toString();
      case BATTERY:
        return getBatteryIcon();
      case RESPIRATION: 
        return 61315.toChar().toString();
      case CALORIES: 
        return 61226.toChar().toString();
      case DISTANCE: 
        return 60860.toChar().toString();
      case ACTIVEMINUTES: 
        return 61234.toChar().toString();  
      default:
        return "";
    }
  }

  function getIconColor(key) as Number {
    switch (key) {
      case HEART:
        return Graphics.COLOR_DK_RED;
      case STEPS:
        return Application.Properties.getValue("ydgBrightBlue");
      case STRESS:
        return Application.Properties.getValue("ydgLime");
      case BATTERY:
        return getBatteryIconColor();
      case RESPIRATION: 
        return Application.Properties.getValue("ydgTeal");
      case CALORIES: 
        return Application.Properties.getValue("ydgOrange");
      case DISTANCE: 
        return Application.Properties.getValue("ydgBlue");
      case ACTIVEMINUTES: 
        return Application.Properties.getValue("ydgBrightRed");
      default:
        return Graphics.COLOR_WHITE;
    }
  }

  function updateLambdaField(dc, isPartialUpdate, fieldKey, coords, leftSide) {
    if (isPartialUpdate) {
      return;
    }

    var icon = getIcon(fieldKey);
    var iconColor = getIconColor(fieldKey);
    var value = getValue(fieldKey);

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      coords[0],
      coords[1],
      sourceSansProFont,
      value,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    var offset = leftSide == true ? 30 : -30 as Number;

    dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      coords[0] + offset,
      coords[1],
      iconsFont,
      icon,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawField(field, dc, isPartialUpdate, coords, leftSide) {
    if (field == HEART) {
      updateHR(dc, isPartialUpdate, coords, leftSide);
    } else {
      updateLambdaField(dc, isPartialUpdate, fields[field], coords, leftSide);
    }
  }

  function drawTLField(dc, isPartialUpdate) {
    var height = dc.getHeight();
    var width = dc.getWidth();

    var field = Application.Properties.getValue("topLeftMetric");
    drawField(field, dc, isPartialUpdate, [width / 2 - 75, height / 2 - 20], true);
  }

  function drawTRField(dc, isPartialUpdate) {
    var height = dc.getHeight();
    var width = dc.getWidth();

    var field = Application.Properties.getValue("topRightMetric");
    drawField(field, dc, isPartialUpdate, [width / 2 + 75, height / 2 - 20], false);
  }

  function drawBLField(dc, isPartialUpdate) {
    var height = dc.getHeight();
    var width = dc.getWidth();

    var field = Application.Properties.getValue("bottomLeftMetric");
    drawField(field, dc, isPartialUpdate, [width / 2 - 75, height / 2 + 20], true);
  }

  function drawBRField(dc, isPartialUpdate) {
    var height = dc.getHeight();
    var width = dc.getWidth();

    var field = Application.Properties.getValue("bottomRightMetric");
    drawField(field, dc, isPartialUpdate, [width / 2 + 75, height / 2 + 20], false);
  }

  function update(dc, isPartialUpdate) {
    var height = dc.getHeight();
    var width = dc.getWidth();
  
    drawTLField(dc, isPartialUpdate);
    drawTRField(dc, isPartialUpdate);
    drawBLField(dc, isPartialUpdate);
    drawBRField(dc, isPartialUpdate);

    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(1);
    dc.drawLine(35, height / 2 + 1, width / 2 - 40, height / 2 + 1);
    dc.drawLine(width / 2 + 40, height / 2 + 1, width - 35, height / 2 + 1);
  }

  function draw(dc as Dc) as Void {
    update(dc, false);
  }
}

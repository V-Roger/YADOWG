import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.SensorHistory;
import Toybox.ActivityMonitor;

class Gauges extends WatchUi.Drawable {
    private var iconsFont;

    function initialize() {
        var dictionary = {
            :identifier => "Gauges"
        };
        iconsFont = WatchUi.loadResource(Rez.Fonts.IcoFont);

        Drawable.initialize(dictionary);
    }

    function getWatchBattery() as Float {
      return Math.ceil(System.getSystemStats().battery);
    }

    function getSteps() as Float {
      var info = ActivityMonitor.getInfo();
      if (info.steps == null || info.steps == 0) {
        return 0.01;
      }

      return info.steps * 0.01;
    }

    function getBodyBattery() as Float {
      if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
        return SensorHistory.getBodyBatteryHistory({ :period => 1 }).next().data;
      }

      return 0.01;
    }

    function drawMoveBar(dc as Dc, innerRadius as Float, outerRadius as Number, startA as Number, offset as Number, width as Float) as Void {
      var info = ActivityMonitor.getInfo();
      var moveLvl = info.moveBarLevel;

      if (moveLvl == null) {
        return;
      }

      var max = ActivityMonitor.MOVE_BAR_LEVEL_MAX;
      var colors = [
        Application.Properties.getValue("ydgMossGreen"),
        Application.Properties.getValue("ydgTeal"),
        Application.Properties.getValue("ydgYellow"),
        Application.Properties.getValue("ydgOrange"),
        Application.Properties.getValue("ydgViolet"),
      ];


      dc.setAntiAlias(true);
      dc.setPenWidth(width);

      var i = 0;
      while (i < max && i < moveLvl) {
        dc.setColor(colors[i], Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(outerRadius + Math.cos((150 - startA - 2 * i + (startA - i * (offset / 10))) / 57.2958) * (outerRadius - width - 2), outerRadius + Math.sin((150 - startA - 2 * i + (startA - i * (offset / 10))) / 57.2958) * (outerRadius - width - 2), width / 2 + i);
        i++;
      }

      dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
      dc.drawText(
        outerRadius - innerRadius + 15,
        outerRadius + innerRadius - 15,
        iconsFont,
        60973.toChar().toString(),
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }

    function draw(dc as Dc) as Void {
      var outerRadius = dc.getWidth() / 2;
      var width = outerRadius * 0.06;
      var innerRadius = outerRadius - 6 * width;
      var startA = 215;
      var startB = 250;
      var startC = 295; 
      var offset = 90;
      var gaugeB = Math.ceil(getSteps() * 35 / 100);
      var gaugeC = Math.ceil(getBodyBattery() * 30 / 100);
      var coordsB = [outerRadius + Math.sin((startB + offset + gaugeB) / 57.2958) * (outerRadius - width - 2), outerRadius + Math.cos((startB + offset + gaugeB) / 57.2958) * (outerRadius - width - 3)];
      var coordsC = [outerRadius + Math.sin((startC + offset + gaugeC) / 57.2958) * (outerRadius - width - 1), outerRadius + Math.cos((startC + offset + gaugeC) / 57.2958) * (outerRadius - width - 3)];
      var colors = [
        Application.Properties.getValue("ydgBrightBlue"),
        Application.Properties.getValue("ydgViolet"),
      ];

      drawMoveBar(dc, innerRadius, outerRadius, startA, offset * 70/100, width);
      
      dc.setAntiAlias(true);
      dc.setPenWidth(width);

      dc.setColor(colors[0], Graphics.COLOR_TRANSPARENT);
      dc.drawArc(outerRadius, outerRadius, outerRadius - width - 2, Graphics.ARC_COUNTER_CLOCKWISE, startB, startB + gaugeB);
      dc.fillCircle(outerRadius + Math.sin((startB + offset) / 57.2958) * (outerRadius - width - 2), outerRadius + Math.cos((startB + offset) / 57.2958) * (outerRadius - width - 3), width / 2);
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      dc.fillCircle(coordsB[0], coordsB[1], width);
      dc.setColor(colors[0], Graphics.COLOR_TRANSPARENT);
      dc.fillCircle(coordsB[0], coordsB[1], width / 2);
      dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
      dc.drawText(
        outerRadius,
        outerRadius + innerRadius + 10,
        iconsFont,
        61239.toChar().toString(),
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );

      dc.setColor(colors[1], Graphics.COLOR_TRANSPARENT);
      dc.drawArc(outerRadius, outerRadius, outerRadius - width - 2, Graphics.ARC_COUNTER_CLOCKWISE, startC, startC + gaugeC);
      dc.fillCircle(outerRadius + Math.sin((startC + offset) / 57.2958) * (outerRadius - width - 1), outerRadius + Math.cos((startC + offset) / 57.2958) * (outerRadius - width - 3), width / 2);
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      dc.fillCircle(coordsC[0], coordsC[1], width);
      dc.setColor(colors[1], Graphics.COLOR_TRANSPARENT);
      dc.fillCircle(coordsC[0], coordsC[1], width / 2);
      dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
      dc.drawText(
        outerRadius + innerRadius - 15,
        outerRadius + innerRadius - 15,
        iconsFont,
        60247.toChar().toString(),
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }

}

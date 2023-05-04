import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class Footer extends WatchUi.Drawable {

  function initialize() {
    var dictionary = {
      :identifier => "Footer"
    };

    Drawable.initialize(dictionary);
  }

  function draw(dc as Dc) as Void {
    var height = dc.getHeight();
    var width = dc.getWidth();

    dc.setAntiAlias(true);

    var settings = System.getDeviceSettings();
    var hasBT = settings.phoneConnected;
    var hasNotifications = settings.notificationCount > 0;
    var hasAlarms = settings.alarmCount > 0;
    var badgesCount = 0;
    if (hasBT) {
      badgesCount++;
    }
    if (hasNotifications) {
      badgesCount++;
    }
    if (hasAlarms) {
      badgesCount++;
    }

    var offset = -3;
    if (badgesCount > 1) {
      offset = badgesCount == 2 ? -9 : -2;
    }

    dc.setPenWidth(3);
    if (hasBT) {
      dc.setColor(Application.Properties.getValue("ydgBlue"), Graphics.COLOR_TRANSPARENT);
      dc.fillRoundedRectangle(width / 2 + offset,  height / 2 + 65, 6, 6, 2);
      offset = badgesCount == 3 ? -12 : 3;
    }
    if (hasAlarms) {
      dc.setColor(Application.Properties.getValue("ydgOrange"), Graphics.COLOR_TRANSPARENT);
      dc.fillRoundedRectangle(width / 2 + offset,  height / 2 + 65, 6, 6, 2);
      offset = badgesCount == 3 ? 8 : 3;
    }
    if (hasNotifications) {
      dc.setColor(Application.Properties.getValue("ydgBrightGreen"), Graphics.COLOR_TRANSPARENT);
      dc.fillRoundedRectangle(width / 2 + offset,  height / 2 + 65, 6, 6, 2);
    }
  }

}

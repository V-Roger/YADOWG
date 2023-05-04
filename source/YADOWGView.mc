import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Time;
import Toybox.Time.Gregorian;

class YADOWGView extends WatchUi.WatchFace {
    private var dataFields;
    private var clock;
    private var ring;
    private var header;
    var lastKnownPosition = null;

    function initialize() {
        if ( Application has :Storage ) {
            Application.Storage.clearValues();
        } else {
            Application.AppBase.clearProperties();
        }
        WatchFace.initialize();
    }

    function cacheDrawables() {
        clock = View.findDrawableById("Time");
        dataFields = View.findDrawableById("Fields");
        ring = View.findDrawableById("Ring");
        header = View.findDrawableById("Header");

        ring.setWatch(self);
        header.setWatch(self);
    }

    function setHideSeconds(hideSeconds) {
		clock.setHideSeconds(hideSeconds);  
	}

    function onPartialUpdate(dc) {
		dataFields.update(dc, /* isPartialUpdate */ true);
        clock.drawSeconds(dc, /* isPartialUpdate */ true);
	}

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        getAndStorePosition();
        setLayout(Rez.Layouts.WatchFace(dc));
        cacheDrawables();
    }


    function persistValue(key as String, value) as Void {
        if ( Application has :Storage ) {
            Application.Storage.setValue(key, value);
        } else {
            Application.AppBase.setProperty(key, value);
        }
    }

    function retrievePersistedValue(key as String) {
        if ( Application has :Storage ) {
            Application.Storage.getValue(key);
        } else {
            Application.AppBase.getProperty(key);
        }
    }

    function clearPersistedValue(key as String) as Void {
        if ( Application has :Storage ) {
            Application.Storage.deleteValue(key);
        } else {
            Application.AppBase.deleteProperty(key);
        }
    }

    function getAndStorePosition() as Boolean {
        var currentPositionInfo = Position.getInfo();
        if (currentPositionInfo.position != null) {
            var currentPosition = currentPositionInfo.position;
            storePositionInfo(currentPosition);
        } else {
            var currentLocation= Activity.Info.currentLocation;
            if (currentLocation != null) {
                storePositionInfo(currentLocation);
            } else {
                var lastPositionCoords =retrievePersistedValue("last-position");
                if (lastPositionCoords != null) {
                    var lastPosition = new Toybox.Position.Location({ :latitude => lastPositionCoords[0], :longitude => lastPositionCoords[1], :format => :degrees });
                    storePositionInfo(lastPosition);
                } else {
                    clearPersistedValue("last-position");
                }
            }
        }

        return lastKnownPosition != null;
    }

    function storePositionInfo(position as Position.Location) as Void {
        var now = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
        var today = Gregorian.moment({ :year => now.year, :month => now.month, :day => now.day, :hour => 0 });

        lastKnownPosition = position;
        persistValue("last-position", position.toDegrees());

        var sunrise = Weather.getSunrise(lastKnownPosition, today); 
        var sunset = Weather.getSunset(lastKnownPosition, today);

        if (sunrise != null && sunset != null) {
            persistValue("sunrise", sunrise.value());
            persistValue("sunset", sunset.value());
            persistValue("sunriseSunsetSetAt", Time.now().value());
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        getAndStorePosition();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        setHideSeconds(false);
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        setHideSeconds(true);
    }
}

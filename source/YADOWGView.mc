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
    var units = Application.Properties.getValue("units") == 0 ? "metric" : "imperial";
    var lastKnownPosition = null;

    function initialize() {
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
        setLayout(Rez.Layouts.WatchFace(dc));
        cacheDrawables();
        getAndStorePosition();
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
                var lastPositionCoords = retrievePersistedValue("last-position");
                if (lastPositionCoords != null) {
                    var lastPosition = new Toybox.Position.Location({ :latitude => lastPositionCoords[0], :longitude => lastPositionCoords[1], :format => :degrees });
                    storePositionInfo(lastPosition);
                }
            }
        }

        return lastKnownPosition != null;
    }

    function storePositionInfo(position as Position.Location) as Void {
        lastKnownPosition = position;
        persistValue("last-position", position.toDegrees());
        WatchUi.requestUpdate();
    }

    function onStart(state as Dictionary) as Void {
        if (getAndStorePosition()) {
            storePositionInfo(lastKnownPosition);
        }
    }

    function onStop(state as Dictionary) as Void {
        if (getAndStorePosition()) {
            storePositionInfo(lastKnownPosition);
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        if (getAndStorePosition()) {
            storePositionInfo(lastKnownPosition);
        }
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
        if (getAndStorePosition()) {
            storePositionInfo(lastKnownPosition);
        }
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

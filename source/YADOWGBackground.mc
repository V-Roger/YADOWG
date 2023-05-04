using Toybox.WatchUi;
using Toybox.Graphics;

class Background extends WatchUi.Drawable {

	function initialize() {
		Drawable.initialize({ :identifier => "Background" });
	}

	function draw(dc) {
		dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
		dc.clear();
	}
}
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class PripiatView extends WatchUi.WatchFace {
    var width = 0;
    var height = 0;
    var centerX = 0;
    var centerY = 0;
    var radius = 0;
    var rotationOffset = Math.PI / 2; // Make 0 the top value instead of pi/2.
    var font20 = null;
    var font20Height = 0;
    var font17 = null;
    var font17Height = 0;
    var palette1 = null;
    var palette2 = null;
    var palette3 = null;

    /* -------- CORE FUNCTIONS -------- */
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        width = dc.getWidth();
        height = dc.getHeight();
        centerX = width / 2;
        centerY = width / 2;
        radius = centerY;
        if (centerX <= centerY) { // Math.min
            radius = centerX;
        }
        // radius = radius * 0.97; // x% decrease.
        font20 = Graphics.getVectorFont({:face=>["RobotoRegular"], :size=>20});
        font20Height = dc.getFontHeight(font20);
        font17 = Graphics.getVectorFont({:face=>["RobotoRegular"], :size=>17});
        font17Height = dc.getFontHeight(font17);
        palette1 = Graphics.COLOR_BLUE; // Graphics.COLOR_WHITE; or Graphics.COLOR_GREEN;
        palette2 = Graphics.COLOR_RED;
        palette3 = Graphics.COLOR_WHITE;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Enable antialiasing
        dc.setAntiAlias(true);

        // Draw the clock face
        drawClockFace(dc);

        // Draw the hands
        drawHands(dc);

        // Draw progress bars
        drawProgressBars(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    /* -------- AUX FUNCTIONS -------- */
    function drawClockFace(dc) as Void {
        // Draw 60 ticks
        for (var i = 0; i < 60; i++) {
            var angle = i * Math.PI / 30 - rotationOffset; // Convert tick number to radians with 90 dregrees rotation
            
            // Draw numbers at 5, 15, 25, 35, 45, 55
            if (i % 5 == 0 && i % 10 != 0) {
                var number = i;
                var text = number.format("%02d");
                dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
                dc.drawRadialText(centerX, centerY, font20, text, Graphics.TEXT_JUSTIFY_CENTER,radiansToDegrees(angle), radius - font20Height + 3, 0);
            } else if (i == 10 || i == 29 || i == 30 || i ==  31) { // Skip these for making room.
                continue;
            } else {
                var tickLength = radius * 0.07; // Default tick length
                var tickWidth = 1; // Default tick width
                if (i % 5 == 0) {
                    tickLength = radius * 0.08; // Longer ticks for hour markers
                    tickWidth = 4; // Thicker ticks for hour markers
                }

                var startX = centerX + (radius * Math.cos(angle));
                var startY = centerY + (radius * Math.sin(angle));
                var endX = centerX + ((radius - tickLength) * Math.cos(angle));
                var endY = centerY + ((radius - tickLength) * Math.sin(angle));

                dc.setPenWidth(tickWidth);
                dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(startX, startY, endX, endY);
            }
        }
        
        // Text at the bottom.
        dc.drawText(centerX, height - font20Height - 1, font20, "RobCo", Graphics.TEXT_JUSTIFY_CENTER);
        // Two red lines in the 10" mark.
        var angle = 10 * Math.PI / 30 - rotationOffset;
        var tickLength = radius * 0.07;
        dc.setPenWidth(3);
        dc.setColor(palette2, Graphics.COLOR_TRANSPARENT);
        var startX = centerX + (radius * Math.cos(angle-0.02));
        var startY = centerY + (radius * Math.sin(angle-0.02));
        var endX = centerX + ((radius - tickLength) * Math.cos(angle-0.02));
        var endY = centerY + ((radius - tickLength) * Math.sin(angle-0.02));
        dc.drawLine(startX, startY, endX, endY);
        startX = centerX + (radius * Math.cos(angle+0.02));
        startY = centerY + (radius * Math.sin(angle+0.02));
        endX = centerX + ((radius - tickLength) * Math.cos(angle+0.02));
        endY = centerY + ((radius - tickLength) * Math.sin(angle+0.02));
        dc.drawLine(startX, startY, endX, endY);
    }

    function drawHands(dc) as Void {
        var time = System.getClockTime();
        var hours = time.hour % 12;
        var minutes = time.min;
        var seconds = time.sec;

        // Calculate hand angles
        var hourAngle = (hours + minutes / 60.0) * Math.PI / 6;
        var minuteAngle = minutes * Math.PI / 30;
        var secondAngle = seconds * Math.PI / 30;

        // Draw hour hand
        var hourLength = radius * 0.5;
        var hourEndX = centerX + (hourLength * Math.cos(hourAngle - Math.PI / 2));
        var hourEndY = centerY + (hourLength * Math.sin(hourAngle - Math.PI / 2));
        dc.setPenWidth(6);
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, centerY, hourEndX, hourEndY);

        // Draw minute hand
        var minuteLength = radius * 0.7;
        var minuteEndX = centerX + (minuteLength * Math.cos(minuteAngle - Math.PI / 2));
        var minuteEndY = centerY + (minuteLength * Math.sin(minuteAngle - Math.PI / 2));
        dc.setPenWidth(4);
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, centerY, minuteEndX, minuteEndY);

        // Draw second hand
        var secondLength = radius * 0.8;
        var secondEndX = centerX + (secondLength * Math.cos(secondAngle - Math.PI / 2));
        var secondEndY = centerY + (secondLength * Math.sin(secondAngle - Math.PI / 2));
        dc.setPenWidth(2);
        dc.setColor(palette2, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, centerY, secondEndX, secondEndY);

        // Draw center dot
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, 5);
    }

    function drawProgressBars(dc) as Void {
        var offset = -45;
        var useOffset = false;

        // Define start and end angles for each bar (80o degrees).
        var angles = [
            [220, 140],
            [130, 50],
            [400, 320] // start always have to be greater to simplify math.
        ];

        // Draw the progress bars
        drawProgressBar(dc, useOffset ? angles[0][0] - offset : angles[0][0], useOffset ? angles[0][1] - offset : angles[0][1], 0, 21);
        drawProgressBar(dc, useOffset ? angles[1][0] - offset : angles[1][0], useOffset ? angles[1][1] - offset : angles[1][1], 80, 101);
        drawProgressBar(dc, useOffset ? angles[2][0] - offset : angles[2][0], useOffset ? angles[2][1] - offset : angles[2][1], 0, 0);
    }

    function drawProgressBar(dc, startAngle, endAngle, altColorStart, altColorEnd) as Void { // start always have to be greater to simplify math.
        var barRadius = radius * 0.7;  // Radius of the progress bars
        var barWidth = 3;              // Width of the progress bar lines
        var tickLength = barRadius * 0.05; // Length of the ticks

        // Draw the outer arc of the progress bar
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(barWidth);
        dc.drawArc(centerX, centerY, barRadius, Graphics.ARC_CLOCKWISE, startAngle, endAngle);
        if (altColorStart != 0 || altColorEnd != 0) {
            dc.setColor(palette2, Graphics.COLOR_TRANSPARENT);
            var altArcStart = startAngle - 80*altColorStart/100.0;
            var altArcEnd = startAngle - (80 * ((altColorEnd-1))/100);
            dc.drawArc(centerX, centerY, barRadius, Graphics.ARC_CLOCKWISE, altArcStart, altArcEnd);
        }

        var radianStart = degreesToRadians(startAngle);
        var radianEnd = degreesToRadians(endAngle);

        // Draw ticks and numbers
        var tickAngle, tickX, tickY, textAngle, text;
        for (var i = 0; i <= 100; i += 10) {
            // Calculate tick angle
            tickAngle = radianStart + (radianEnd - radianStart) * (i / 100.0);
            if (tickAngle > 2 * Math.PI) {
                tickAngle = tickAngle - 2 * Math.PI;
            }

            // Calculate tick coordinates
            tickX = centerX + (barRadius * Math.cos(tickAngle));
            tickY = centerY + (barRadius * Math.sin(tickAngle));

            // Draw the tick
            dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
            if (i >= altColorStart && i < altColorEnd) {
                dc.setColor(palette2, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(tickX, tickY, tickX - tickLength * Math.cos(tickAngle), tickY - tickLength * Math.sin(tickAngle));

            // Draw numbers for every 20%
            if (i % 20 == 0) {
                textAngle = radiansToDegrees(tickAngle);

                // Draw the number
                text = i.toString();
                dc.drawRadialText(centerX, centerY, font17, text, Graphics.TEXT_JUSTIFY_CENTER, textAngle, barRadius - font17Height - 10, 0);
            }
        }
    }

    /* -------- STATIC FUNCTIONS -------- */
    function radiansToDegrees(angle) { // take a radian and return a degree.
        return angle * 180 / Math.PI * -1; // * -1 because garmin is inverted for some reason.
    }

    function degreesToRadians(angle) { // take a degree and return a radian.
        return angle * Math.PI / 180.0 * -1;
    }
}

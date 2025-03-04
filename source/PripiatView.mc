import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.WatchUi;

class PripiatView extends WatchUi.WatchFace {
    var width = 0;
    var height = 0;
    var centerX = 0;
    var centerY = 0;
    var radius = 0;
    var innerRadius = 0;
    var rotationOffset = Math.PI / 2.0; // Make 0 the top value instead of pi/2.
    
    var font20 = null;
    var font20Height = 0;
    var font17 = null;
    var font17Height = 0;
    var ledFont = null;
    var ledFontSmall = null;
    var ledFontBig = null;
    var ledFontSmol = null;
    var ledFontStorre = null;

    var palette1 = null;
    var palette1dark = null;
    var palette1darker = null;
    var palette1light = null;
    var palette2 = null;
    var palette2dark = null;

    var bodyBat = 0;
    var stress = 0;
    var step = 0;
    var stepGoal = 0;
    var calories = "";
    var distance = "";
    var heartRate = "";

    /* -------- CORE FUNCTIONS -------- */
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        width = dc.getWidth();
        height = dc.getHeight();
        centerX = width / 2.0;
        centerY = width / 2.0;
        radius = centerY;
        if (centerX <= centerY) { // Math.min
            radius = centerX;
        }
        innerRadius = radius * 0.72;
        // radius = radius * 0.97; // x% decrease.
        ledFont = Application.loadResource( Rez.Fonts.id_led );
        ledFontSmall = Application.loadResource( Rez.Fonts.id_led_small );
        ledFontBig = Application.loadResource( Rez.Fonts.id_led_big );
        ledFontSmol = Application.loadResource( Rez.Fonts.id_smol );
        ledFontStorre = Application.loadResource( Rez.Fonts.id_storre );
        font20 = Graphics.getVectorFont({:face=>["RobotoRegular"], :size=>20});
        font20Height = dc.getFontHeight(font20);
        font17 = Graphics.getVectorFont({:face=>["RobotoRegular"], :size=>17});
        font17Height = dc.getFontHeight(font17);
        palette1 = Graphics.COLOR_BLUE; // Graphics.COLOR_WHITE; or Graphics.COLOR_GREEN;
        // palette1dark = Graphics.COLOR_DK_BLUE;
        palette1dark = Graphics.createColor(255, 41, 91, 255);
        palette1darker = Graphics.createColor(255, 0, 0, 120);
        palette1light = Graphics.createColor(255, 135, 173, 247);
        palette2 = Graphics.COLOR_RED;
        palette2dark = Graphics.COLOR_DK_RED;
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
        dc.setAntiAlias(true);

        updateMetrics();

        drawClockFace(dc);
        drawProgressBars(dc);
        drawDate(dc);
        drawMetrics(dc);
        drawHands(dc);
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
        var time = System.getClockTime();
        var seconds = time.sec;
        // Draw 60 ticks
        for (var i = 0; i < 60; i++) {
            var angle = i * Math.PI / 30.0 - rotationOffset; // Convert tick number to radians with 90 dregrees rotation
            
            // Draw numbers at 5, 15, 25, 35, 45, 55
            if (i % 5 == 0 && i % 10 != 0) {
                var number = i;
                var text = number.format("%02d");
                dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
                if (i == seconds) {
                    dc.setColor(palette2, Graphics.COLOR_TRANSPARENT);
                }
                dc.drawRadialText(centerX, centerY, font20, text, Graphics.TEXT_JUSTIFY_CENTER,radiansToDegrees(angle), radius - font20Height + 2, 0);
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
                if (i == seconds) {
                    dc.setColor(palette2, Graphics.COLOR_TRANSPARENT);
                }
                dc.drawLine(startX, startY, endX, endY);
            }
        }
        
        // Text at the bottom.
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height - font20Height - 1, font20, "RobCo", Graphics.TEXT_JUSTIFY_CENTER);
        // Two red lines in the 10" mark.
        var angle = 10 * Math.PI / 30.0 - rotationOffset;
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
        var hourAngle = (hours + minutes / 60.0) * Math.PI / 6.0;
        var minuteAngle = minutes * Math.PI / 30.0;
        var secondAngle = seconds * Math.PI / 30.0;

        // Draw hour hand
        var hourLength = radius * 0.35;
        var hourEndX = centerX + (hourLength * Math.cos(hourAngle - rotationOffset));
        var hourEndY = centerY + (hourLength * Math.sin(hourAngle - rotationOffset));
        dc.setPenWidth(6);
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, centerY, hourEndX, hourEndY);

        // Draw minute hand
        var minuteLength = radius * 0.5;
        var minuteEndX = centerX + (minuteLength * Math.cos(minuteAngle - rotationOffset));
        var minuteEndY = centerY + (minuteLength * Math.sin(minuteAngle - rotationOffset));
        dc.setPenWidth(4);
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, centerY, minuteEndX, minuteEndY);

        // Draw second hand
        var secondLength = radius * 0.54;
        var secondEndX = centerX + (secondLength * Math.cos(secondAngle - rotationOffset));
        var secondEndY = centerY + (secondLength * Math.sin(secondAngle - rotationOffset));
        dc.setPenWidth(2);
        dc.setColor(palette2, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, centerY, secondEndX, secondEndY);

        // Draw center dot
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, 5);
    }

    function drawProgressBars(dc) as Void {
        // Define start and end angles for each bar (80o degrees).
        var angles = [
            [220, 140],
            [130, 50],
            [400, 320] // start always have to be greater to simplify math.
        ];

        // Draw the progress bars
        drawProgressBar(dc, angles[0][0], angles[0][1], 0, 21, bodyBat);
        drawProgressBar(dc, angles[1][0], angles[1][1], 80, 101, stress);
        drawProgressBar(dc, angles[2][0], angles[2][1], 0, 0, 100.0 * step / stepGoal);
    }

    function drawProgressBar(dc, startAngle, endAngle, altColorStart, altColorEnd, fill) as Void { // start always have to be greater to simplify math.
        var tickLength = innerRadius * 0.05; // Length of the ticks
        var radianStart = degreesToRadians(startAngle);
        var radianEnd = degreesToRadians(endAngle);
        var tickAngle, tickX, tickY, textAngle, text;
        
        // Draw progress ticks.
        dc.setPenWidth(1);
        for (var i = 0; i <= 100; i += 2.5) {
            tickAngle = radianStart + (radianEnd - radianStart) * (i / 100.0);
            if (tickAngle > 2 * Math.PI) {
                tickAngle = tickAngle - 2 * Math.PI;
            }

             // Calculate tick coordinates
            tickX = centerX + ((innerRadius + 10) * Math.cos(tickAngle));
            tickY = centerY + ((innerRadius + 10) * Math.sin(tickAngle));

            // Draw the tick
            dc.setColor(palette1dark, Graphics.COLOR_TRANSPARENT);
            if (i <= fill) {
                dc.setColor(palette1light, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(tickX, tickY, tickX - tickLength * Math.cos(tickAngle), tickY - tickLength * Math.sin(tickAngle));
        }

        // Draw the outer arc of the progress bar
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        if (altColorStart != 0 || altColorEnd != 0) {
            var altArcStart = startAngle - 80*altColorStart/100.0;
            var altArcEnd = startAngle - (80 * ((altColorEnd-1))/100);
            if (altArcStart < startAngle) {
                dc.drawArc(centerX, centerY, innerRadius, Graphics.ARC_CLOCKWISE, startAngle, altArcStart);
            }
            dc.setColor(palette2dark, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(centerX, centerY, innerRadius, Graphics.ARC_CLOCKWISE, altArcStart, altArcEnd);
            if (altArcEnd > endAngle) {
                dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(centerX, centerY, innerRadius, Graphics.ARC_CLOCKWISE, altArcEnd, endAngle);
            }
        } else {
            dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(centerX, centerY, innerRadius, Graphics.ARC_CLOCKWISE, startAngle, endAngle);
        }

        // Draw ticks and numbers
        dc.setPenWidth(3);
        for (var i = 0; i <= 100; i += 10) {
            // Calculate tick angle
            tickAngle = radianStart + (radianEnd - radianStart) * (i / 100.0);
            if (tickAngle > 2 * Math.PI) {
                tickAngle = tickAngle - 2 * Math.PI;
            }

            // Calculate tick coordinates
            tickX = centerX + (innerRadius * Math.cos(tickAngle));
            tickY = centerY + (innerRadius * Math.sin(tickAngle));

            // Draw the tick
            dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
            if (i >= altColorStart && i < altColorEnd) {
                dc.setColor(palette2dark, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(tickX, tickY, tickX - tickLength * Math.cos(tickAngle), tickY - tickLength * Math.sin(tickAngle));

            // Draw numbers for every 20%
            if (i % 20 == 0) {
                textAngle = radiansToDegrees(tickAngle);

                // Draw the number
                text = i.toString();
                if (i >= altColorStart && i < altColorEnd) {
                    dc.setColor(palette2, Graphics.COLOR_TRANSPARENT);
                }
                dc.drawRadialText(centerX, centerY, font17, text, Graphics.TEXT_JUSTIFY_CENTER, textAngle, innerRadius - font17Height - 10, 0);
            }
        }
    }

    function drawDate(dc) as Void {
        var angles = [220, 320]; // Angles in the same height.
        var yOffset = 17;

        var points = lineFromAngles(innerRadius, angles[0], angles[1]);
        var x = (points[0][0]+ points[1][0])/2;
        var y = points[0][1] + yOffset;

        dc.setColor(palette1light, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font20, "32C TUE, 4 MAR 2025", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawMetrics(dc) as Void {
        var angles = [180, 0]; // Angles in the same height.
        var xOffset = 50;
        var yOffset = 13;
        var hrYOffset = 65;
        var textYOffset = 13;

        var points = lineFromAngles(innerRadius, angles[0], angles[1]);
        var y = points[0][1] - yOffset;

        // Backgrounds.
        dc.setColor(palette1darker, Graphics.COLOR_TRANSPARENT);
        dc.drawText(points[0][0]+xOffset, y, ledFontBig, "####", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(points[1][0]-xOffset, y, ledFontBig, "####", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(centerX, centerY + hrYOffset, ledFontBig, "####", Graphics.TEXT_JUSTIFY_CENTER);

        // Values.
        dc.setColor(palette1light, Graphics.COLOR_TRANSPARENT);
        dc.drawText(points[0][0]+xOffset, y, ledFontBig, calories, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(points[1][0]-xOffset, y, ledFontBig, distance, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(centerX, centerY + hrYOffset, ledFontBig, heartRate, Graphics.TEXT_JUSTIFY_CENTER);

        // Text.
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(points[0][0]+xOffset+2, y - textYOffset, ledFontStorre, "DLY CALORIES:", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(points[1][0]-xOffset, y - textYOffset, ledFontStorre, "KM TODAY:", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(centerX, centerY + hrYOffset - textYOffset, ledFontStorre, "LIVE HR:", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, centerY - 1.5*hrYOffset, ledFontBig, "&", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function updateMetrics() as Void {
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory) && (Toybox.SensorHistory has :getStressHistory)) {
            var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
            var stIterator = Toybox.SensorHistory.getStressHistory({:period => 1});
            var bb = bbIterator.next();
            var st = stIterator.next();

            if(bb != null) {
                bodyBat = bb.data;
            }
            if(st != null) {
                stress = st.data;
            }
        }
        var monitorInfo = ActivityMonitor.getInfo();
        var activityInfo = Activity.getActivityInfo();
        step = monitorInfo.steps;
        stepGoal = monitorInfo.stepGoal;
        calories = monitorInfo.calories.format("%04d");
        var km = monitorInfo.distance / 100000.0; // km / day.
        if (km >= 10) {
            distance = km.format("%.1f");
        } else {
            distance = km.format("%.2f");
        }
        var hrSample = activityInfo.currentHeartRate;
        if (hrSample != null) {
            heartRate = hrSample.format("%04d");
        } else if (ActivityMonitor has :getHeartRateHistory) {
            // Falling back to historical HR from ActivityMonitor
            var hist = ActivityMonitor.getHeartRateHistory(1, /* newestFirst */ true).next();
            if ((hist != null) && (hist.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
                heartRate = hist.heartRate.format("%04d");
            }
        } 
    }

    /* -------- STATIC FUNCTIONS -------- */
    function radiansToDegrees(angle) { // take a radian and return a degree.
        return angle * 180.0 / Math.PI * -1; // * -1 because garmin is inverted for some reason.
    }

    function degreesToRadians(angle) { // take a degree and return a radian.
        return angle * Math.PI / 180.0 * -1;
    }

    function lineFromAngles(radius, startAngle, endAngle) as Lang.Array<Lang.Array<Lang.Number>> {
        // Convert angles to radians
        var startRadian = degreesToRadians(startAngle);
        var endRadian = degreesToRadians(endAngle);
    
        // Calculate start point coordinates
        var startX = centerX + radius * Math.cos(startRadian);
        var startY = centerY + radius * Math.sin(startRadian);

        // Calculate end point coordinates
        var endX = centerX + radius * Math.cos(endRadian);
        var endY = centerY + radius * Math.sin(endRadian);

        return [[startX, startY], [endX, endY]];
    }
}

import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Weather;

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

    var lastDateUpdate = null;
    var bodyBat = 0;
    var stress = 0;
    var step = 0;
    var sunset = 0;
    var sunrise = 0;
    var sunPosition = 0;
    var battery = 0;
    var stepGoal = 0;
    var stepGoalPercentage = 0.0;
    var calories = "";
    var distance = "";
    var heartRate = "";
    var date = "";

    var lastUpdate = 0;

    var colorTheme;
    var useRedAccent;
    var circleAroundTheSeconds;
    var showSecondHand;
    var smallClockHands;
    var flipRightBar;
    var rightBarMetric;
    var leftBarMetric;
    var topBarMetric;

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
        innerRadius = radius * 0.75;
        // radius = radius * 0.97; // x% decrease.
        ledFont = Application.loadResource( Rez.Fonts.id_led );
        ledFontSmall = Application.loadResource( Rez.Fonts.id_led_small );
        ledFontBig = Application.loadResource( Rez.Fonts.id_led_big );
        ledFontSmol = Application.loadResource( Rez.Fonts.id_smol );
        ledFontStorre = Application.loadResource( Rez.Fonts.id_storre );
        font20 = Graphics.getVectorFont({:face=>["RobotoRegular"], :size=>20});
        font20Height = dc.getFontHeight(font20);
        getSettings();
        setColorTheme();
        dc.setAntiAlias(true);
    }

    function onSettingsChanged() {
        getSettings();
        setColorTheme();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        updateDate();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var now = Time.now().value();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        if(lastUpdate == null or now - lastUpdate > 30 or clockTime.sec % 60 == 0) {
            lastUpdate = now;
            updateMetrics();
        }

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
        getSettings();
        setColorTheme();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    /* -------- AUX FUNCTIONS -------- */
    function drawClockFace(dc) as Void {
        // Draw 60 ticks
        var tickLength = radius * 0.07;
        var tickWidth = 2; // Default tick width
        for (var i = 0; i < 60; i++) {
            var angle = i * Math.PI / 30.0 - rotationOffset; // Convert tick number to radians with 90 dregrees rotation
            
            if (i == 10 || i == 29 || i == 30 || i ==  31) { // Skip these for making room.
                continue;
            } else if (i % 5 == 0) { // Draw numbers at 5, 15, 25, 35, 45, 55.
                var number = i;
                var text = number.format("%02d");
                dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
                dc.drawRadialText(centerX, centerY, font20, text, Graphics.TEXT_JUSTIFY_CENTER, radiansToDegrees(angle + 2*Math.PI), radius - font20Height + 4, 0);
            } else {

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
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        if (circleAroundTheSeconds == 1) {
            dc.drawArc(centerX, centerY, radius-0.5, Graphics.ARC_CLOCKWISE, 0, 360);
        } else if (circleAroundTheSeconds == 2) {
            dc.drawArc(centerX, centerY, radius-tickLength-1, Graphics.ARC_CLOCKWISE, 0, 360);
        }
        dc.drawText(centerX, height - font20Height - 1, font20, "RobCo", Graphics.TEXT_JUSTIFY_CENTER);
        // Two red lines in the 10" mark.
        var angle = 10 * Math.PI / 30.0 - rotationOffset;
        dc.setColor(useRedAccent ? palette2 : palette1, Graphics.COLOR_TRANSPARENT);
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
        var hourLength = smallClockHands ? radius * 0.4 : radius * 0.55;
        var hourEndX = centerX + (hourLength * Math.cos(hourAngle - rotationOffset));
        var hourEndY = centerY + (hourLength * Math.sin(hourAngle - rotationOffset));
        dc.setPenWidth(6);
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, centerY, hourEndX, hourEndY);

        // Draw minute hand
        var minuteLength = smallClockHands ? radius * 0.50 : radius * 0.83;
        var minuteEndX = centerX + (minuteLength * Math.cos(minuteAngle - rotationOffset));
        var minuteEndY = centerY + (minuteLength * Math.sin(minuteAngle - rotationOffset));
        dc.setPenWidth(4);
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, centerY, minuteEndX, minuteEndY);

        // Draw second hand
        if (showSecondHand) {
            var secondLength = smallClockHands ? radius * 0.55 : radius * 0.9;
            var secondEndX = centerX + (secondLength * Math.cos(secondAngle - rotationOffset));
            var secondEndY = centerY + (secondLength * Math.sin(secondAngle - rotationOffset));
            dc.setPenWidth(2);
            dc.setColor(useRedAccent ? palette2 : palette1, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(centerX, centerY, secondEndX, secondEndY);
        }

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
        drawProgressBar(dc, angles[0][0], angles[0][1], 0, 21, metricForProgressBar(leftBarMetric), false);
        drawProgressBar(dc, angles[1][0], angles[1][1], 80, 101, metricForProgressBar(topBarMetric), false);
        drawProgressBar(dc, angles[2][0], angles[2][1], 0, 0, metricForProgressBar(rightBarMetric), flipRightBar);
    }

    function drawProgressBar(dc, startAngle, endAngle, altColorStart, altColorEnd, fill, flip) as Void { // start always have to be greater to simplify math.
        var radianStart = degreesToRadians(startAngle + 360);
        var radianEnd = degreesToRadians(endAngle + 360);
        var tickLength, tickAngle, tickX, tickY, tickXend, tickYend, textAngle, text;
        
        // Draw external progress ticks.
        dc.setPenWidth(3);
        tickLength = 12;
        for (var i = 0; i <= 100; i += 4) {
            tickAngle = radianStart + (radianEnd - radianStart) * (i / 100.0);
            if (tickAngle > 2 * Math.PI) {
                tickAngle = tickAngle - 2 * Math.PI;
            }

             // Calculate tick coordinates
            tickX = centerX + ((innerRadius + tickLength) * Math.cos(tickAngle));
            tickY = centerY + ((innerRadius + tickLength) * Math.sin(tickAngle));
            tickXend = centerX + (innerRadius * Math.cos(tickAngle));
            tickYend = centerY + (innerRadius * Math.sin(tickAngle));

            // Draw the tick
            dc.setColor(palette1dark, Graphics.COLOR_TRANSPARENT);
            if (flip ? 100 - i <= fill : i <= fill) {
                dc.setColor(palette1light, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(tickX, tickY, tickXend, tickYend);
        }

        // Draw the outer arc of the progress bar
        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(8);
        if (altColorStart != 0 || altColorEnd != 0) {
            var altArcStart = startAngle - (80*(altColorStart)/100.0);
            var altArcEnd = startAngle - (80 * ((altColorEnd-1))/100.0);
            if (flip) {
                altArcStart = startAngle - (80*(100 - altColorEnd)/100.0);
                altArcEnd = startAngle - (80 * ((100 - altColorStart))/100.0);
            }
            if (altArcStart < startAngle) {
                dc.drawArc(centerX, centerY, innerRadius, Graphics.ARC_CLOCKWISE, startAngle, altArcStart);
            }
            dc.setColor(useRedAccent ? palette2dark : palette1, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(centerX, centerY, innerRadius, Graphics.ARC_CLOCKWISE, altArcStart, altArcEnd);
            if (altArcEnd > endAngle) {
                dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(centerX, centerY, innerRadius, Graphics.ARC_CLOCKWISE, altArcEnd, endAngle);
            }
        } else {
            dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(centerX, centerY, innerRadius, Graphics.ARC_CLOCKWISE, startAngle, endAngle);
        }

        // Draw inner ticks and numbers
        dc.setPenWidth(3);
        tickLength = 15;
        for (var i = 0; i <= 100; i += 10) {
            // Calculate tick angle
            tickAngle = radianStart + (radianEnd - radianStart) * (i / 100.0);
            if (tickAngle > 2 * Math.PI) {
                tickAngle = tickAngle - 2 * Math.PI;
            }

            // Calculate tick coordinates
            tickX = centerX + ((innerRadius+2) * Math.cos(tickAngle));
            tickY = centerY + ((innerRadius+2) * Math.sin(tickAngle));
            tickXend = centerX + ((innerRadius - tickLength) * Math.cos(tickAngle));
            tickYend = centerY + ((innerRadius - tickLength) * Math.sin(tickAngle));

            // Draw the tick
            dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
            if ((!flip && i >= altColorStart && i < altColorEnd) || (flip && i > 100 - altColorEnd && i <= 100 - altColorStart)) {
                dc.setColor(useRedAccent ? palette2dark : palette1, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(tickX, tickY, tickXend, tickYend);

            // Draw numbers for every 20%
            if (i % 20 == 0) {
                textAngle = radiansToDegrees(tickAngle);
                if (!flip && i == 100) {
                    textAngle += 3.5;
                } else if (flip && i == 0) {
                    textAngle -= 3;
                }

                // Draw the number
                text = i.toString();
                if (flip) {
                    text = (100 - i).toString();
                }
                if ((!flip && i >= altColorStart && i < altColorEnd) || (flip && i > 100 - altColorEnd && i <= 100 - altColorStart)) {
                    dc.setColor(useRedAccent ? palette2 : palette1, Graphics.COLOR_TRANSPARENT);
                }
                dc.drawRadialText(centerX, centerY, font20, text, Graphics.TEXT_JUSTIFY_CENTER, textAngle, innerRadius - font20Height - tickLength, 0);
            }
        }
    }

    function drawDate(dc) as Void {
        var angles = [220, 320]; // Angles in the same height.
        var yOffset = 20;

        var points = lineFromAngles(innerRadius, angles[0], angles[1]);
        var x = (points[0][0]+ points[1][0])/2;
        var y = points[0][1] + yOffset;

        dc.setColor(palette1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, ledFontSmall, date, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawMetrics(dc) as Void {
        var angles = [180, 0]; // Angles in the same height.
        var xOffset = 53;
        var yOffset = 5;
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
        stepGoalPercentage = 100.0 * step / stepGoal;
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
        battery = System.getSystemStats().battery;
    }

    function updateDate() as Void {
        var weather = null;
        var chance = "";
        var temp = "";
        var now = Time.now();
        var halfHour = new Time.Duration(1800);

        if (lastDateUpdate != null  && (now - lastDateUpdate).lessThan(halfHour)) {
            return; // early return to avoid too much time updates.
        }
        lastDateUpdate = now;

        if (Weather.getCurrentConditions != null) {
            weather = Weather.getCurrentConditions();
        }

        // Safely check precipitation chance
        if(weather != null) {
            if (weather has :precipitationChance &&
                weather.precipitationChance != null &&
                weather.precipitationChance instanceof Number) {
                if(weather.precipitationChance > 0) {
                    chance = Lang.format(" ($1$%)", [weather.precipitationChance.format("%02d")]);
                }
            }
            if (weather has :temperature && weather.temperature != null) {
                temp = weather.temperature.format("%01d");
            }
            var loc = weather.observationLocationPosition;
            if(loc != null) {
                sunrise = Weather.getSunrise(loc, now).value();
                sunset = Weather.getSunrise(loc, now).value();
                sunPosition = 100 * (now.value() - sunrise) / (sunset - sunrise);
                if (sunPosition > 100) {
                    sunPosition = 100;
                } else if (sunPosition < 0) {
                    sunPosition = 0;
                }
            }
        }
        
        var today = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        date = Lang.format("$1$, $2$ $3$ $4$", [
                    day_name(today.day_of_week),
                    today.day,
                    month_name(today.month),
                    today.year
                ]);

        if (temp != "") {
            date = Lang.format("$1$C $2$", [temp, date]);
        }
        if (chance != "") {
            date = Lang.format("$1$ $2$", [chance, date]);
        }
    }

    function getSettings() as Void {
        colorTheme = Application.Properties.getValue("colorTheme");
        useRedAccent = Application.Properties.getValue("useRedAccent");
        circleAroundTheSeconds = Application.Properties.getValue("circleAroundTheSeconds");
        showSecondHand = Application.Properties.getValue("showSecondHand");
        smallClockHands = Application.Properties.getValue("smallClockHands");
        flipRightBar = Application.Properties.getValue("flipRightBar");
        rightBarMetric = Application.Properties.getValue("rightBarMetric");
        leftBarMetric = Application.Properties.getValue("leftBarMetric");
        topBarMetric = Application.Properties.getValue("topBarMetric");
    }

    function setColorTheme() as Void {
        palette2 = Graphics.COLOR_RED;
        palette2dark = Graphics.COLOR_DK_RED;
        if (colorTheme == 1) { // Green.
            palette1 = Graphics.createColor(255, 0, 160, 0);
            palette1dark = Graphics.createColor(255, 0, 100, 0);
            palette1darker = Graphics.createColor(255, 0, 50, 0);
            palette1light = Graphics.createColor(255, 0, 255, 0);
        } else if (colorTheme == 2) { // Amber.
            palette1 = Graphics.createColor(255, 250, 108, 0);
            palette1dark = Graphics.createColor(255, 153, 66, 0);
            palette1darker = Graphics.createColor(255, 97, 45, 6);
            palette1light = Graphics.createColor(255, 252, 137, 50);
        } else if (colorTheme == 3) { // White.
            palette1 = Graphics.COLOR_WHITE;
            palette1dark = Graphics.createColor(255, 155, 155, 155);
            palette1darker = Graphics.createColor(255, 55, 55, 55);
            palette1light = Graphics.COLOR_WHITE;
        } else if (colorTheme == 4) { // Red.
            palette1 = Graphics.createColor(255, 190, 30, 30);
            palette1dark = Graphics.createColor(255, 120, 0, 0);
            palette1darker = Graphics.createColor(255, 70, 0, 0);
            palette1light = Graphics.createColor(255, 255, 0, 0);
        } else if (colorTheme == 5) { // Purple 1.
            palette1 = Graphics.createColor(255, 162, 0, 255);
            palette1dark = Graphics.createColor(255, 108, 0, 171);
            palette1darker = Graphics.createColor(255, 63, 0, 99);
            palette1light = Graphics.createColor(255, 187, 69, 255);
        } else if (colorTheme == 6) { // Purple 2.
            palette1 = Graphics.createColor(255, 119, 0, 255);
            palette1dark = Graphics.createColor(255, 80, 0, 171);
            palette1darker = Graphics.createColor(255, 47, 0, 99);
            palette1light = Graphics.createColor(255, 157, 71, 255);
        } else if (colorTheme == 7) { // Purple 3.
            palette1 = Graphics.createColor(255, 70, 70, 190);
            palette1dark = Graphics.createColor(255, 30, 30, 120);
            palette1darker = Graphics.createColor(255, 0, 0, 70);
            palette1light = Graphics.createColor(255, 90, 90, 255);
        }else { // Default Theme, Blue colorTheme == 0.
            palette1 = Graphics.COLOR_BLUE;
            palette1dark = Graphics.createColor(255, 41, 91, 255);
            palette1darker = Graphics.createColor(255, 0, 0, 120);
            palette1light = Graphics.createColor(255, 135, 173, 247);
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

    function day_name(day_of_week) {
        var names = [
            "SUN",
            "MON",
            "TUE",
            "WED",
            "THU",
            "FRI",
            "SAT",
        ];
        return names[day_of_week - 1];
    }

    function month_name(month) {
        var names = [
            "JAN",
            "FEB",
            "MAR",
            "APR",
            "MAY",
            "JUN",
            "JUL",
            "AUG",
            "SEP",
            "OCT",
            "NOV",
            "DEC"
        ];
        return names[month - 1];
    }

    function metricForProgressBar(n) {
        if (n == 0) {
            return stepGoalPercentage;
        } else if (n == 1) {
            return battery;
        } else if (n == 2) {
            return bodyBat;
        } else if (n == 3) {
            return stress;
        } else if (n == 4) {
            return sunPosition;
        }
        return battery;
    }
}

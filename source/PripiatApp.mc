import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class PripiatApp extends Application.AppBase {

    var mView;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        mView = new PripiatView();
        onSettingsChanged();
        return [ mView ];
    }

    function onSettingsChanged() as Void {
        mView.onSettingsChanged();
        WatchUi.requestUpdate();
    }

}

function getApp() as PripiatApp {
    return Application.getApp() as PripiatApp;
}
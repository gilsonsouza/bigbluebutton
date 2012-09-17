package org.bigbluebutton.main.views.layout
{
  import flash.utils.Dictionary;
  
  import flexlib.mdi.containers.MDIWindow;
  
  import org.bigbluebutton.common.IBbbModuleWindow;
  import org.bigbluebutton.common.LogUtil;
  import org.bigbluebutton.common.Role;
  import org.bigbluebutton.main.views.MainDisplay;

  public class ViewLayout
  {
    static private var _ignoredWindows:Array = new Array("PublishWindow", "VideoWindow", "DesktopPublishWindow", 
      "DesktopViewWindow", "LogWindow");
    
    private var _windows:Dictionary = new Dictionary();
    
    private var _role:String = Role.ALL; 
    
    public function get role():String {
      return _role;
    }

    static public function ignoreWindow(window:MDIWindow):Boolean {
      var type:String = WindowLayout.getType(window);
      return ignoreWindowByType(type);
    }
    
    static private function ignoreWindowByType(type:String):Boolean {
      return (_ignoredWindows.indexOf(type) != -1);
    }
    
    public function parseViewLayouts(wl:XML):void {
      if (wl.@role != undefined && Role.roles.indexOf(wl.@role.toString().toUpperCase()) != -1) {
        _role = wl.@role.toString().toUpperCase();
      }
      
      LogUtil.debug("ViewLayout = [" + wl.@role + "]\n" + wl.toXMLString());
      for each (var n:XML in wl.window) {
        var window:WindowLayout = new WindowLayout();
        LogUtil.debug("ViewLayout = [" + n.@name + "]\n" + n.toXMLString());
        window.parseWindow(n);
        _windows[window.name] = window;
      }
    }
    
    public function displayWindow(window:IBbbModuleWindow, display:MainDisplay):void {
      var windowType:String = WindowLayout.getType(window as MDIWindow);
      if (!ignoreWindowByType(windowType) && _windows.hasOwnProperty(windowType)) {
        var windowLayout:WindowLayout = _windows[windowType]; 
        windowLayout.displayWindow(window, display);
      }
      
      
    }
  }
}
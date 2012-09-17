package org.bigbluebutton.main.views.layout
{
  import flash.utils.Dictionary;
  
  import org.bigbluebutton.common.LogUtil;
  import org.bigbluebutton.common.Role;

  public class ViewLayout
  {
    private var _windows:Dictionary = new Dictionary();
    
    private var _role:String = Role.ALL; 
    
    public function get role():String {
      return _role;
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
  }
}
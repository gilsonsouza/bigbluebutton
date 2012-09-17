package org.bigbluebutton.main.views.layout
{
  import flash.utils.Dictionary;
  
  import org.bigbluebutton.common.LogUtil;

  public class ViewLayout
  {
    private var _windows:Dictionary = new Dictionary();
    
    public function ViewLayout()
    {
    }
    
    public function parseViewLayouts(wl:XML):void {
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
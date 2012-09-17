/**
 * BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
 *
 * Copyright (c) 2012 BigBlueButton Inc. and by respective authors (see below).
 *
 * This program is free software; you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation; either version 2.1 of the License, or (at your option) any later
 * version.
 *
 * BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along
 * with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
 * 
 * Author: Felipe Cecagno <felipe@mconf.org>
 */
package org.bigbluebutton.core.layout.model {
  import org.bigbluebutton.common.IBbbModuleWindow;
  import org.bigbluebutton.core.user.model.MeetingModel;
  import org.bigbluebutton.main.views.MainDisplay;
  import org.bigbluebutton.main.views.layout.ViewLayout;
  import org.bigbluebutton.main.views.layout.WindowLayout;

  public class LayoutDefinition {
    import flash.utils.Dictionary;
    import flexlib.mdi.containers.MDIWindow;    
    import org.bigbluebutton.common.LogUtil;
    import org.bigbluebutton.common.Role;
    import org.bigbluebutton.core.layout.managers.OrderManager;
    
    public var meetingModel:MeetingModel;
    
    [Bindable] public var name:String;
    // default is a reserved word in actionscript
    [Bindable] public var isDefaultLayout:Boolean = false;
    
    private var _views:Dictionary = new Dictionary();
    
    static private var _ignoredWindows:Array = new Array("PublishWindow", "VideoWindow", "DesktopPublishWindow", 
                                                          "DesktopViewWindow", "LogWindow");
    
    
    public function displayWindow(window:IBbbModuleWindow, display:MainDisplay):void {
      LogUtil.warn("LayoutDefinition: Displaying Window [" + window.getWindowID() + "]");
      var myLayout:ViewLayout = getMyLayout();
      if (myLayout != null) {
        LogUtil.debug("Displaying window using layout [" + name + "] role=[" + myLayout.role + "]");
        myLayout.displayWindow(window, display);
      }
    }
    
    private function loadLayout(vxml:XML):void {
      if (vxml.@name != undefined) {
        name = vxml.@name.toString();
      }
      
      if (vxml.@default != undefined) {
        isDefaultLayout = (vxml.@default.toString().toUpperCase() == "TRUE") ? true : false;
      }
           
      for each (var n:XML in vxml.view) {      
        var viewLayout:ViewLayout = new ViewLayout();
        viewLayout.parseViewLayouts(n);
        _views[viewLayout.role] = viewLayout;        
      }   
    }
    
    public function parseLayout(vxml:XML):void {
      if (vxml == null)
        return;
      
      if (vxml.name().localName == "layout")
        loadLayout(vxml);
      else if (vxml.name().localName == "layout-block") {
        for each (var tmp:XML in vxml.layout)
          loadLayout(tmp);
      }
    }

    private function getMyLayout():ViewLayout {
      var hasAllLayout:Boolean = _views.hasOwnProperty(Role.ALL);
      var hasViewerLayout:Boolean = _views.hasOwnProperty(Role.VIEWER);
      var hasModeratorLayout:Boolean = _views.hasOwnProperty(Role.MODERATOR);
      var hasPresenterLayout:Boolean = _views.hasOwnProperty(Role.PRESENTER);
      
      LogUtil.debug("Determining my layout - presenter?=" + meetingModel.amIPresenter() + ", hasPresenterLayout?=" 
            + hasPresenterLayout + ", moderator?=" + meetingModel.amIModerator() + ", hasModeratorLayout?=" 
            + hasModeratorLayout);
      if (meetingModel.amIPresenter() && hasPresenterLayout)
        return _views[Role.PRESENTER];
      else if (meetingModel.amIModerator() && hasModeratorLayout)
        return _views[Role.MODERATOR];
      else if (hasViewerLayout) 
        return _views[Role.VIEWER];
      else if (hasModeratorLayout)
        return _views[Role.MODERATOR];
      else if (hasPresenterLayout)
        return _views[Role.PRESENTER];
      else if (hasAllLayout)
        return _views[Role.ALL];
      else {
        LogUtil.error("There's no layout that fits the participants profile");
        return null;
      }
    }
/*    
    public function windowLayout(name:String):ViewLayout {
      return myLayout[name];
    }
*/    
    private function windowsToXml(windows:Dictionary):XML {
      var xml:XML = <layout/>;
      xml.@name = name;
      if (isDefaultLayout)
        xml.@default = true;
      for each (var value:WindowLayout in windows) {
        xml.appendChild(value.toXml());
      }
      return xml;
    }
    
    public function toXml():XML {
      var xml:XML = <layout-block/>;
      var tmp:XML;
//      for each (var value:String in _roles) {
//        if (_views.hasOwnProperty(value)) {
//          tmp = windowsToXml(_views[value]);
//          if (value != Role.VIEWER)
//            tmp.@role = value;
//          xml.appendChild(tmp);
//        }
//      }
      return xml;
    }
    
    /*
     * 0 if there's no order
     * 1 if "a" should appears after "b"
     * -1 if "a" should appears before "b"
     */
    private function sortWindows(a:Object, b:Object):int {
      // ignored windows are positioned in front
      if (a.ignored && b.ignored) return 0;
      if (a.ignored) return 1;
      if (b.ignored) return -1;
      // then comes the windows that has no layout definition
      if (!a.hasLayoutDefinition && !b.hasLayoutDefinition) return 0;
      if (!a.hasLayoutDefinition) return 1;
      if (!b.hasLayoutDefinition) return -1;
      // then the focus order is used to sort
      if (a.order == b.order) return 0;
      if (a.order == -1) return 1;
      if (b.order == -1) return -1;
      return (a.order < b.order? 1: -1);
    }
    /*      
    private function adjustWindowsOrder(canvas:MainDisplay):void {
      var orderedList:Array = new Array();
      var type:String;
      var order:int;
      var ignored:Boolean;
      var hasLayoutDefinition:Boolean;
      
//      LogUtil.debug("=> Before sort");
      for each (var window:MDIWindow in canvas.windowManager.windowList) {
        type = WindowLayout.getType(window);
        hasLayoutDefinition = myLayout.hasOwnProperty(type);
        if (hasLayoutDefinition)
          order = myLayout[type].order;
        else
          order = -1;
        ignored = ignoreWindowByType(type);
        var item:Object = { window:window, order:order, type:type, ignored:ignored, hasLayoutDefinition:hasLayoutDefinition };
        orderedList.push(item);
//        LogUtil.debug("===> type: " + item.type + " ignored? " + item.ignored + " hasLayoutDefinition? " + item.hasLayoutDefinition + " order? " + item.order);
      }
      orderedList.sort(this.sortWindows);
//      LogUtil.debug("=> After sort");
      for each (var obj:Object in orderedList) {
//        LogUtil.debug("===> type: " + obj.type + " ignored? " + obj.ignored + " hasLayoutDefinition? " + obj.hasLayoutDefinition + " order? " + obj.order);
        if (!obj.ignored)
          OrderManager.getInstance().bringToFront(obj.window);
        canvas.windowManager.bringToFront(obj.window);
      }
    }
    
    public function applyToCanvas(canvas:MainDisplay):void {
      if (canvas == null)
        return;

      adjustWindowsOrder(canvas);

      for each (var window:MDIWindow in canvas.windowManager.windowList) {
        applyToWindow(canvas, window);
      }
    }
    
     
    public function applyToWindow(canvas:MainDisplay, window:MDIWindow, type:String=null):void {
      LogUtil.debug("LayoutDefinition: applyToWindow");
      if (type == null) {
        type = WindowLayout.getType(window);
      }
        
      LogUtil.debug("LayoutDefinition: applyToWindow - type=[" + type + "]");
      
      if (!ignoreWindowByType(type)) {
        LogUtil.debug("LayoutDefinition: applyToWindow - setLayout [" + type + "] mylayout [" + myLayout[type] + "]");
        WindowLayout.setLayout(canvas, window, myLayout[type]);
      }
        
    }
   
    static private function ignoreWindowByType(type:String):Boolean {
      return (_ignoredWindows.indexOf(type) != -1);
    }
    
    static public function ignoreWindow(window:MDIWindow):Boolean {
      var type:String = WindowLayout.getType(window);
      return ignoreWindowByType(type);
    }
    
    static public function getLayout(canvas:MainDisplay, name:String):LayoutDefinition {
      //LogUtil.debug("CHAD: Canvas is " + (canvas == null ? "null" : "not null") + ", Name is " + (name == null ? "null" : "not null"));
      var layoutDefinition:LayoutDefinition = new LayoutDefinition();
      layoutDefinition.name = name;
      layoutDefinition._views[Role.VIEWER] = new Dictionary();
      for each (var window:MDIWindow in canvas.windowManager.windowList) {
        var layout:WindowLayout = WindowLayout.getLayout(canvas, window);
        if (!ignoreWindowByType(layout.name))
          layoutDefinition._views[Role.VIEWER][layout.name] = layout;
      }
      return layoutDefinition;
    }
*/
  }
}

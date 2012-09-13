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
package org.bigbluebutton.main.views.layout {
  import org.bigbluebutton.common.IBbbModuleWindow;
  import org.bigbluebutton.main.views.MainDisplay;

  public class WindowLayout {
    import flexlib.mdi.containers.MDIWindow;
    import mx.effects.Fade;
    import mx.effects.Move;
    import mx.effects.Parallel;
    import mx.effects.Resize;
    import mx.events.EffectEvent;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import org.bigbluebutton.common.LogUtil;
    import org.bigbluebutton.core.layout.managers.OrderManager;

    private var _name:String;
    private var _width:Number;
    private var _height:Number;
    private var _x:Number;
    private var _y:Number;
    private var _minimized:Boolean = false;
    private var _maximized:Boolean = false;
    private var _hidden:Boolean = false;
    private var _order:int = -1;
   
    static private var EVENT_DURATION:int = 500;

    private var wlm:WindowLayoutModel = new WindowLayoutModel();
    
    public function get name():String {
      return _name;
    }
    
    public function parseWindow(vxml:XML):void {
//      LogUtil.debug("******** WindowLayout View = \n" + vxml.toXMLString());
      if (vxml != null) {
        if (vxml.@name != undefined) {
          _name = vxml.@name.toString();
        }
        if (vxml.@width != undefined) {
          _width = Number(vxml.@width);
        }
        if (vxml.@height != undefined) {
          _height = Number(vxml.@height);
        }
        if (vxml.@x != undefined) {
          _x = Number(vxml.@x);
        }
        if (vxml.@y != undefined) {
          _y = Number(vxml.@y);
        }
        if (vxml.@minimized != undefined) {
          _minimized = (vxml.@minimized.toString().toUpperCase() == "TRUE") ? true : false;
        }
        if (vxml.@maximized != undefined) {
          _maximized = (vxml.@maximized.toString().toUpperCase() == "TRUE") ? true : false;
        }
        if (vxml.@hidden != undefined) {
          _hidden = (vxml.@hidden.toString().toUpperCase() == "TRUE") ? true : false;
        }
        if (vxml.@order != undefined) {
          _order = int(vxml.@order);
        }
      }
    }
    
    public function displayWindow(window:IBbbModuleWindow, display:MainDisplay):void {
      determineHowToDisplayWindow(window as MDIWindow, display);
      applyToWindow(window as MDIWindow, display);
    }
    
    private function determineHowToDisplayWindow(window:MDIWindow, display:MainDisplay):void {      
//      wlm.name = getType(window);
      wlm.width = window.width / display.width;
      wlm.height = window.height / display.height;
      wlm.x = window.x / display.width;
      wlm.y = window.y / display.height;
      wlm.minimized = window.minimized;
      wlm.maximized = window.maximized;
      wlm.hidden = !window.visible;
      wlm.order = OrderManager.getInstance().getOrderByRef(window);   
    }

    /*
    static public function getLayout(canvas:MainDisplay, window:MDIWindow):WindowLayout {
      var layout:WindowLayout = new WindowLayout();
      layout.name = getType(window);
      layout.width = window.width / canvas.width;
      layout.height = window.height / canvas.height;
      layout.x = window.x / canvas.width;
      layout.y = window.y / canvas.height;
      layout.minimized = window.minimized;
      layout.maximized = window.maximized;
      layout.hidden = !window.visible;
      layout.order = OrderManager.getInstance().getOrderByRef(window);
      return layout;
    }
    
    static public function setLayout(canvas:MainDisplay, window:MDIWindow, layout:WindowLayout):void {
      if (layout == null) {
        LogUtil.info("WindowLayout: layout is null!");
        return;
      }
      LogUtil.info("WindowLayout: layout is NOT null!");
      layout.applyToWindow(canvas, window);
    }
*/    
    private var _delayedEffects:Array = new Array();
    private function delayEffect(canvas:MainDisplay, window:MDIWindow):void {
      var obj:Object = {canvas:canvas, window:window};
      _delayedEffects.push(obj);
      var timer:Timer = new Timer(150,1);
      timer.addEventListener(TimerEvent.TIMER, onTimerComplete);
      timer.start();
    }
    
    private function onTimerComplete(event:TimerEvent = null):void {
      var obj:Object = _delayedEffects.pop();
      applyToWindow(obj.canvas, obj.window);
    }
    
    private function applyToWindow(window:MDIWindow, display:MainDisplay):void {
      LogUtil.info("WindowLayout: Try to display window!");
      var effect:Parallel = new Parallel();
      effect.duration = EVENT_DURATION;
      effect.target = window;
      
      if (_minimized) {
        LogUtil.info("WindowLayout: Window is minimized!");
        if (!window.minimized) {
          LogUtil.info("WindowLayout: Minimizing window!");
          window.minimize();
        }
      } else if (_maximized) {
        LogUtil.info("WindowLayout: Window is maximized!");
        if (!window.maximized) {
          LogUtil.info("WindowLayout: Maximizing window!");
          window.maximize();
        }
      } else if (window.minimized && !_minimized && !_hidden) {
        LogUtil.info("WindowLayout: Unminimizing window!");
        window.unMinimize();
        delayEffect(display, window);
        return;
      } else if (window.maximized && !_maximized && !_hidden) {
        LogUtil.info("WindowLayout: Restoring window!");
        window.maximizeRestore();
        delayEffect(display, window);
        return;
      } else {
        if (!_hidden) {
          LogUtil.info("WindowLayout: Window not hidden!");
//          var newWidth:int = int(wlm.width * display.width);
//          var newHeight:int = int(wlm.height * display.height);
//          var newX:int = int(wlm.x * display.width);
//          var newY:int = int(wlm.y * display.height);
          var newWidth:int = int(_width * display.width);
          var newHeight:int = int(_height * display.height);
          var newX:int = int(_x * display.width);
          var newY:int = int(_y * display.height);          
          if (newX != window.x || newY != window.y) {
            var mover:Move = new Move();
            mover.xTo = newX;
            mover.yTo = newY;
            effect.addChild(mover);
          }
          
          if (newWidth != window.width || newHeight != window.height) {
            LogUtil.info("WindowLayout: Resizing window!");
            var resizer:Resize = new Resize();
            resizer.widthTo = newWidth;
            resizer.heightTo = newHeight;
            effect.addChild(resizer)
          }
        }
      }
      
      var layoutHidden:Boolean = _hidden;
//      var windowVisible:Boolean = (window.alpha == 1);
      var windowVisible:Boolean = window.visible;
      if (windowVisible == layoutHidden) {
        LogUtil.info("WindowLayout: Layout hidden!");
        var fader:Fade = new Fade();
        fader.alphaFrom = (layoutHidden? 1: 0);
        fader.alphaTo = (layoutHidden? 0: 1);
        fader.addEventListener(EffectEvent.EFFECT_START, function(e:EffectEvent):void {
          if (!windowVisible)
            window.enabled = window.visible = true;
        });
        fader.addEventListener(EffectEvent.EFFECT_END, function(e:EffectEvent):void {
          if (windowVisible)
            window.enabled = window.visible = false;
        });
        effect.addChild(fader);
      }
      
      if (effect.children.length > 0)
        effect.play();
    }
    
    static public function getType(obj:Object):String {
      var qualifiedClass:String = String(getQualifiedClassName(obj));
      var pattern:RegExp = /(\w+)::(\w+)/g;
      if (qualifiedClass.match(pattern)) {
        return qualifiedClass.split("::")[1];
      } else { 
        return String(Object).substr(String(Object).lastIndexOf(".") + 1).match(/[a-zA-Z]+/).join();
      }
    }
    
    public function toAbsoluteXml(canvas:MainDisplay):XML {
      var xml:XML = <window/>;
      xml.@name = wlm.name;
      if (wlm.minimized)
        xml.@minimized = true;
      else if (wlm.maximized)
        xml.@maximized = true;
      else if (wlm.hidden)
        xml.@hidden = true;
      else {
        xml.@width = int(wlm.width * canvas.width);
        xml.@height = int(wlm.height * canvas.height);
        xml.@x = int(wlm.x * canvas.width);
        xml.@y = int(wlm.y * canvas.height);
      }
      xml.@order = wlm.order;
      return xml;
    }
    
    public function toXml():XML {
      var xml:XML = <window/>;
      xml.@name = wlm.name;
      if (wlm.minimized)
        xml.@minimized = true;
      else if (wlm.maximized)
        xml.@maximized = true;
      else if (wlm.hidden)
        xml.@hidden = true;
      else {
        xml.@width = wlm.width;
        xml.@height = wlm.height;
        xml.@x = wlm.x;
        xml.@y = wlm.y;
      }
      xml.@order = wlm.order;
      return xml;      
    }  
  }
}

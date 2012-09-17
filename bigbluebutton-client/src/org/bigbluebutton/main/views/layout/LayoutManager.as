package org.bigbluebutton.main.views.layout
{
  import com.asfusion.mate.events.Dispatcher;  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IEventDispatcher;
  import flash.events.TimerEvent;
  import flash.net.FileReference;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.utils.Dictionary;
  import flash.utils.Timer; 
  import flexlib.mdi.containers.MDICanvas;
  import flexlib.mdi.containers.MDIWindow;
  import flexlib.mdi.events.MDIManagerEvent;  
  import mx.controls.Alert;
  import mx.events.ResizeEvent;  
  import org.bigbluebutton.common.IBbbModuleWindow;
  import org.bigbluebutton.common.LogUtil;
  import org.bigbluebutton.core.EventBroadcaster;
  import org.bigbluebutton.core.layout.events.LayoutEvent;
  import org.bigbluebutton.core.layout.events.LayoutsLoadedEvent;
  import org.bigbluebutton.core.layout.events.RedefineLayoutEvent;
  import org.bigbluebutton.core.layout.events.UpdateLayoutEvent;
  import org.bigbluebutton.core.layout.managers.OrderManager;
  import org.bigbluebutton.core.layout.model.LayoutDefinition;
  import org.bigbluebutton.core.layout.model.LayoutDefinitionFile;
  import org.bigbluebutton.core.layout.model.LayoutLoader;
  import org.bigbluebutton.core.layout.model.LayoutModel;
  import org.bigbluebutton.core.managers.UserManager;
  import org.bigbluebutton.core.model.Config;
  import org.bigbluebutton.main.views.MainDisplay;
  import org.bigbluebutton.util.i18n.ResourceUtil;
  
  public class LayoutManager {
    private var _canvas:MainDisplay = null;
    private var _locked:Boolean = false;
    private var _currentLayout:LayoutDefinition = null;
    private var _detectContainerChange:Boolean = true;
    private var _containerDeactivated:Boolean = false;
    private var _sendCurrentLayoutUpdateTimer:Timer = new Timer(500,1);
    private var _applyCurrentLayoutTimer:Timer = new Timer(150,1);
    private var _customLayoutsCount:int = 0;
    private var _eventsToDelay:Array = new Array(MDIManagerEvent.WINDOW_RESTORE,
                                              MDIManagerEvent.WINDOW_MINIMIZE, MDIManagerEvent.WINDOW_MAXIMIZE);
    
    public var layoutModel:LayoutModel;
    public var dispatcher:IEventDispatcher;
    
    public function LayoutManager() {
      LogUtil.debug("****************************** Layout Manager constructor! *************************");
      _applyCurrentLayoutTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
        applyLayout(_currentLayout);
      });
      _sendCurrentLayoutUpdateTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
        sendLayoutUpdate(updateCurrentLayout());
      });
    }
    
        
    public function setupCanvasListeners(canvas:MainDisplay):void { 
      LogUtil.debug("****************************** Layout Manager setupCanvasListeners! *************************");
      _canvas = canvas;
      // this is to detect changes on the container
      _canvas.windowManager.container.addEventListener(ResizeEvent.RESIZE, onContainerResized);
      //          _canvas.windowManager.container.addEventListener(Event.ACTIVATE, onContainerActivated);
      //          _canvas.windowManager.container.addEventListener(Event.DEACTIVATE, onContainerDeactivated);
      
      _canvas.windowManager.addEventListener(MDIManagerEvent.WINDOW_RESIZE_END, onActionOverWindowFinished);
      _canvas.windowManager.addEventListener(MDIManagerEvent.WINDOW_DRAG_END, onActionOverWindowFinished);
      _canvas.windowManager.addEventListener(MDIManagerEvent.WINDOW_MINIMIZE, onActionOverWindowFinished);
      _canvas.windowManager.addEventListener(MDIManagerEvent.WINDOW_MAXIMIZE, onActionOverWindowFinished);
      _canvas.windowManager.addEventListener(MDIManagerEvent.WINDOW_RESTORE, onActionOverWindowFinished);
      _canvas.windowManager.addEventListener(MDIManagerEvent.WINDOW_ADD, function(e:MDIManagerEvent):void {
        checkPermissionsOverWindow(e.window);
        applyLayout(_currentLayout);
      });
      
      _canvas.windowManager.addEventListener(MDIManagerEvent.WINDOW_FOCUS_START, function(e:MDIManagerEvent):void {
        OrderManager.getInstance().bringToFront(e.window);
      });
      
      for each (var window:MDIWindow in _canvas.windowManager.windowList.reverse()) {
        OrderManager.getInstance().bringToFront(window);
      }
    }
    
    public function displayWindow(window:IBbbModuleWindow, display:MainDisplay):void {
      var curLayout:LayoutDefinition = layoutModel.getCurrentLayout();
      curLayout.displayWindow(window, display);
    }
    
    public function applyDefaultLayout():void {
      applyLayout(layoutModel.getDefaultLayout());
      sendLayoutUpdate(_currentLayout);
    }
    
    public function lockLayout():void {
      _locked = true;
      LogUtil.debug("LayoutManager: layout locked by myself");
      sendLayoutUpdate(_currentLayout);
    }
    
    private function sendLayoutUpdate(layout:LayoutDefinition):void {
      if (_locked && UserManager.getInstance().getConference().amIModerator()) {
        LogUtil.debug("LayoutManager: sending layout to remotes");
        var e:UpdateLayoutEvent = new UpdateLayoutEvent();
        e.layout = layout;
        dispatcher.dispatchEvent(e);
      }
    }
    
    private function applyLayout(layout:LayoutDefinition):void {
      _detectContainerChange = false;
      if (layout != null) {
//        layout.applyToCanvas(_canvas);
      }
        
      updateCurrentLayout(layout);
      _detectContainerChange = true;
    }
    
    public function redefineLayout(e:RedefineLayoutEvent):void {
      var layout:LayoutDefinition = e.layout;
      applyLayout(layout);
      if (!e.remote)
        sendLayoutUpdate(layout);
    }
    
    public function remoteLockLayout():void {
      LogUtil.debug("LayoutManager: remote lock received");
      _locked = true;
      checkPermissionsOverWindow();
    }
    
    public function remoteUnlockLayout():void {
      LogUtil.debug("LayoutManager: remote unlock received");
      _locked = false;
      checkPermissionsOverWindow();
    }
    
    private function checkPermissionsOverWindow(window:MDIWindow=null):void {
      if (window != null) {
//        if (!UserManager.getInstance().getConference().amIModerator() && !LayoutDefinition.ignoreWindow(window)) {
//          window.draggable = window.resizable = window.showControls = !_locked;
//        }
      } else {
        for each (window in _canvas.windowManager.windowList) {
          checkPermissionsOverWindow(window);
        }
      }
    }
    
    private function onContainerResized(e:ResizeEvent):void {
      /*
      *  the main canvas has been resized
      *  while the user is resizing the window, this event is dispatched 
      *  multiple times, so we use a timer to re-apply the current layout
      *  only once, when the user finished his action
      */
      _applyCurrentLayoutTimer.reset();
      _applyCurrentLayoutTimer.start();
    }
    
    //    private function onContainerActivated(e:Event):void {
    //      printSomething("onContainerActivated");
    //    }
    //
    //    private function onContainerDeactivated(e:Event = null):void {
    //      printSomething("onContainerDeactivated");
    //    }
    
    private function onActionOverWindowFinished(e:MDIManagerEvent):void {
//      if (LayoutDefinition.ignoreWindow(e.window))
//        return;
      
      checkPermissionsOverWindow(e.window);
      if (_detectContainerChange) {
        dispatcher.dispatchEvent(new LayoutEvent(LayoutEvent.INVALIDATE_LAYOUT_EVENT));
        /*
        *   some events related to animated actions must be delayed because if it's not the 
        *   current layout doesn't get properly updated
        */
        if (_eventsToDelay.indexOf(e.type) != -1) {
          LogUtil.debug("LayoutManager: waiting the end of the animation to update the current layout");
          _sendCurrentLayoutUpdateTimer.reset();
          _sendCurrentLayoutUpdateTimer.start();
        } else {
          sendLayoutUpdate(updateCurrentLayout());
        }
      }
    }
    
    private function updateCurrentLayout(layout:LayoutDefinition=null):LayoutDefinition {
//      _currentLayout = (layout != null? layout: LayoutDefinition.getLayout(_canvas, ResourceUtil.getInstance().getString('bbb.layout.combo.customName')));
//      return _currentLayout;
      return null;
    }
    
    /*
    * this is because a unique layout may have multiple definitions depending
    * on the role of the participant
    */ 
    public function presenterChanged():void {
      if (_canvas != null)
        applyLayout(_currentLayout);
    }
  }
}
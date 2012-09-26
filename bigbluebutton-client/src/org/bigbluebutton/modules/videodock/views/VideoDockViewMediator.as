package org.bigbluebutton.modules.videodock.views
{
  import flash.events.IEventDispatcher;
  
  import org.bigbluebutton.common.events.OpenWindowEvent;
  import org.bigbluebutton.modules.videodock.models.VideoDockOptions;

  public class VideoDockViewMediator
  {    
    public var dispatcher:IEventDispatcher;
    public var configOptions:VideoDockOptions;
    
    private var _dockWindow:VideoDockView = new VideoDockView();
    
    public function start():void {
      _dockWindow.options = configOptions;
      
      var windowEvent:OpenWindowEvent = new OpenWindowEvent(OpenWindowEvent.OPEN_WINDOW_EVENT);
      windowEvent.window =  _dockWindow;
      dispatcher.dispatchEvent(windowEvent);     
    }
  }
}
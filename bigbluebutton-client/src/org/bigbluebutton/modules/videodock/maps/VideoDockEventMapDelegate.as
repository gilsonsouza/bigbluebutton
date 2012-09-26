package org.bigbluebutton.modules.videodock.maps
{
  import flash.events.IEventDispatcher;
  
  import org.bigbluebutton.common.LogUtil;
  import org.bigbluebutton.common.events.OpenWindowEvent;
  import org.bigbluebutton.core.modules.events.ModuleEvent;
  import org.bigbluebutton.modules.videodock.views.VideoDockViewMediator;

  public class VideoDockEventMapDelegate
  {   
    public var videoDockViewMediator:VideoDockViewMediator;
    
    public function moduleStart(event:ModuleEvent):void {      
      if (event.name == "VideodockModule") {
        videoDockViewMediator.start();
      }      
    }
  }
}
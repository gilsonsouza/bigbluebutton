package org.bigbluebutton.modules.videoconf.maps
{
  import org.bigbluebutton.common.LogUtil;
  import org.bigbluebutton.core.modules.events.ModuleEvent;

  public class VideoEventMapDelegate
  {
    public function VideoEventMapDelegate()
    {
    }
    
    public function moduleStart(event:ModuleEvent):void {
      
      if (event.name != "VideoModule") return;
      LogUtil.debug("VideoEventMapDelegate: Starting [" + event.name + "]");
      LogUtil.debug("Starting VideoModule");
      LogUtil.debug("Opening Video Dock Window");
//      var windowEvent:OpenWindowEvent = new OpenWindowEvent(OpenWindowEvent.OPEN_WINDOW_EVENT);
//      windowEvent.window = new VideoDock();
//      dispatcher.dispatchEvent(windowEvent);      
    }
  }
}
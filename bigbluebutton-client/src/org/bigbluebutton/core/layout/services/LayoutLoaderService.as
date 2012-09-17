package org.bigbluebutton.core.layout.services
{
  import flash.events.IEventDispatcher;
  
  import org.bigbluebutton.common.LogUtil;
  import org.bigbluebutton.core.BBB;
  import org.bigbluebutton.core.config.model.ConfigModel;
  import org.bigbluebutton.core.layout.events.LayoutConfigEvent;
  import org.bigbluebutton.core.layout.events.LayoutsLoadedEvent;
  import org.bigbluebutton.core.layout.model.LayoutLoader;
  import org.bigbluebutton.core.layout.model.LayoutModel;

  public class LayoutLoaderService
  {
    public var layoutModel:LayoutModel;
    public var configModel:ConfigModel;
    public var dispatcher:IEventDispatcher;
    
    private var _loader:LayoutLoader;
    
    public function loadServerLayouts():void {
      var layoutUrl:String = "conf/layout.xml";
      var vxml:XML = configModel.config.layout;
      if (vxml.@layoutConfig != undefined) {
        layoutUrl = vxml.@layoutConfig.toString();
      }
            
      LogUtil.debug("LayoutLoaderService: loading server layouts from " + layoutUrl);
      _loader = new LayoutLoader();
      _loader.layoutModel = layoutModel;
      _loader.addEventListener(LayoutsLoadedEvent.LAYOUTS_LOADED_EVENT, onLayoutLoadedHandler);
      _loader.loadFromUrl(layoutUrl);
    }
    
    private function onLayoutLoadedHandler(event:LayoutsLoadedEvent):void {
      if (event.success) {
        layoutModel.layouts = event.layouts;
        LogUtil.debug("LayoutLoaderService: layouts loaded successfully");
        dispatcher.dispatchEvent(new LayoutConfigEvent(LayoutConfigEvent.LAYOUT_CONFIG_LOADED));
      } else {
        LogUtil.error("LayoutLoaderService: layouts not loaded (" + event.error.message + ")");
      }      
    }   
  }
}
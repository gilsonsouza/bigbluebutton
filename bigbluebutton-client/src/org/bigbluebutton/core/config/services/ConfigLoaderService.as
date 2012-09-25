package org.bigbluebutton.core.config.services
{
  import flash.events.Event;
  import flash.events.IEventDispatcher;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  
  import mx.core.FlexGlobals;
  import mx.utils.URLUtil;
  
  import org.bigbluebutton.common.LogUtil;
  import org.bigbluebutton.core.config.events.ConfigEvent;
  import org.bigbluebutton.core.config.model.ConfigModel;
  import org.bigbluebutton.core.model.Config;

  public class ConfigLoaderService
  {
    private static const CONFIG_XML:String = "client/conf/config.xml";
    
    public var dispatcher:IEventDispatcher;    
    public var model:ConfigModel;
       
    public function loadConfig():void {
      LogUtil.debug("ConfigLoaderService: Loading config.xml");
      var urlLoader:URLLoader = new URLLoader();
      urlLoader.addEventListener(Event.COMPLETE, handleComplete);
      var date:Date = new Date();
      var localeReqURL:String = buildRequestURL() + "?a=" + date.time;
      urlLoader.load(new URLRequest(localeReqURL));			
    }		
    
    private function handleComplete(e:Event):void{
      LogUtil.debug("ConfigLoaderService: handling loaded config.xml");
      model.config =  new Config(new XML(e.target.data));
      dispatcher.dispatchEvent(new ConfigEvent(ConfigEvent.CONFIG_LOADED));	
    } 
    
    private function buildRequestURL():String {
      var swfURL:String = FlexGlobals.topLevelApplication.url;
      var protocol:String = URLUtil.getProtocol(swfURL);
      var serverName:String = URLUtil.getServerNameWithPort(swfURL);        
      return protocol + "://" + serverName + "/" + CONFIG_XML;
    }
  }
}
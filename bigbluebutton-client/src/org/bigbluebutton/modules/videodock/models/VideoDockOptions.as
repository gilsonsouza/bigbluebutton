package org.bigbluebutton.modules.videodock.models
{
	import org.bigbluebutton.core.BBB;
	import org.bigbluebutton.core.config.model.ConfigModel;

	public class VideoDockOptions
	{
    public var configModel:ConfigModel;
		    
    public static const LAYOUT_NONE:String = "NONE";
    public static const LAYOUT_HANGOUT:String = "HANGOUT";
    public static const LAYOUT_SMART:String = "SMART";
    
    public function get autoDock():Boolean {
      var vxml:XML = configModel.config.getConfigFor("VideodockModule");
      
      var autoDock:Boolean = true;
      
      if (vxml != null) {
        if (vxml.@autoDock != undefined) {
          autoDock = (vxml.@autoDock.toString().toUpperCase() == "TRUE") ? true : false;
        }
      }     
      
      return autoDock;
    }
    
    public function get layout():String {
      var layout:String = LAYOUT_SMART;
      
      var vxml:XML = configModel.config.getConfigFor("VideodockModule");
      if (vxml != null) {
        if (vxml.@layout != undefined) {
          layout = vxml.@layout.toString().toUpperCase();
          if (layout != LAYOUT_NONE && layout != LAYOUT_HANGOUT && layout != LAYOUT_SMART)
            layout = LAYOUT_NONE;					
        }
      }
      
      return layout;
    }
      
    public function get oneAlwaysBigger():Boolean {
      var oneAlwaysBigger:Boolean = true;
      
      var vxml:XML = configModel.config.getConfigFor("VideodockModule");
      if (vxml != null) {
        if (vxml.@oneAlwaysBigger != undefined) {
          oneAlwaysBigger = (vxml.@oneAlwaysBigger.toString().toUpperCase() == "TRUE") ? true : false;
        }
      } 
      
      return oneAlwaysBigger;
    }
    
    public function get position():String {
      var position:String = "bottom-right";
      
      var vxml:XML = configModel.config.getConfigFor("VideodockModule");
      if (vxml.@position != undefined) {
        position = vxml.@position.toString();
      }
      
      return position;    
    }
	}
}
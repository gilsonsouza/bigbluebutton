package org.bigbluebutton.modules.videodock.models
{
  public class VideoDockViewModel
  {
    [Bindable]
    public var autoDock:Boolean = true;
    
    [Bindable]
    public var maximize:Boolean = false;
    
    [Bindable]
    public var position:String = "bottom-right";
    
    [Bindable]
    public var width:int = 172;
    
    [Bindable]
    public var height:int = 179;
    
    [Bindable]
    public var layout:String = LAYOUT_SMART;
    static public const LAYOUT_NONE:String = "NONE";
    static public const LAYOUT_HANGOUT:String = "HANGOUT";
    static public const LAYOUT_SMART:String = "SMART";
    
    [Bindable]
    public var oneAlwaysBigger:Boolean = false;
    
    public function VideoDockViewModel()
    {
    }
  }
}
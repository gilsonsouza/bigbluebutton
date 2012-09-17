package org.bigbluebutton.main.views.layout
{
  public class WindowLayoutModel
  {
    [Bindable] public var name:String;
    [Bindable] public var width:Number;
    [Bindable] public var height:Number;
    [Bindable] public var x:Number;
    [Bindable] public var y:Number;
    [Bindable] public var minimized:Boolean = false;
    [Bindable] public var maximized:Boolean = false;
    [Bindable] public var hidden:Boolean = false;
    [Bindable] public var order:int = -1;
    
    public function WindowLayoutModel()
    {
    }
  }
}
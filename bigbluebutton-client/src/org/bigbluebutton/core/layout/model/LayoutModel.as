package org.bigbluebutton.core.layout.model
{
  import mx.collections.ArrayList;
  
  import org.bigbluebutton.common.LogUtil;
  import org.bigbluebutton.core.user.model.MeetingModel;

  public class LayoutModel
  {    
    public var meetingModel:MeetingModel;
    
    private var _layouts:LayoutDefinitionFile;    
    private var _currentLayout:LayoutDefinition;
    
    public function set layouts(l:LayoutDefinitionFile):void {
      _layouts = l;
    }
    
    public function getDefaultLayout():LayoutDefinition {
      return _layouts.getDefault();
    }
    
    public function setCurrentLayout(id:String):void {
      // TODO: Find layout based on ID
    }
    
    public function getCurrentLayout():LayoutDefinition {
      return _currentLayout = _layouts.getDefault();
    }
  }
}
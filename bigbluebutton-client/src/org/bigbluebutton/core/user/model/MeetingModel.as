package org.bigbluebutton.core.user.model
{
  import org.bigbluebutton.common.Role;
  import org.bigbluebutton.core.user.model.vo.Meeting;
  import org.bigbluebutton.core.user.model.vo.User;

  public class MeetingModel
  {
    public var meeting:Meeting;    
    public var myUserID:String;
    public var usersModel:UsersModel;
    
    public function amIPresenter():Boolean {
      var me:User = usersModel.getUser(myUserID);
      if (me != null) {
        return me.presenter;
      }
      return false;
    }
    
    public function amIModerator():Boolean {
      var me:User = usersModel.getUser(myUserID);
      if (me != null) {
        return me.role == Role.MODERATOR
      }
      return false;
    }
    

    
  }
}
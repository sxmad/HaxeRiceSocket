package com.rice.models;
import awe6.core.Entity;
import awe6.interfaces.EScene;
import awe6.interfaces.IKernel;
import com.rice.interfaces.EExtendedScene;
import com.rice.interfaces.msg.EMsg;
import com.rice.managers.Session;
import com.rice.managers.XLog;
import com.rice.models.vo.ChaVO;
import com.rice.models.vo.LoginVO;
import com.rice.utils.XTools;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

/**
 * ...
 * @author sxmad
 */
	
class LoginModel extends Entity 
{	
	private var _session:Session;
	//TODO	
	public function new( p_kernel:IKernel,p_session:Session ) 
	{
		super( p_kernel );
		_session = p_session;
	}
	
	override private function _init():Void 
	{
		super._init();
		// extend here
	}
	//发送登录信息
	public function requestLogin(p_loginVO:LoginVO):Void {
		//测试信息
		_kernel.scenes.setScene(EScene.SUB_TYPE(EExtendedScene.CREATE_ROLE));
		var l_out:BytesOutput = new BytesOutput();
		XTools.writeString(l_out, p_loginVO.name+":xiaolan");
		XTools.writeString(l_out, p_loginVO.pass+":nimei");
		_session.socket.send(Cmd.CMD_LOGIN_USERLOGIN, l_out);
	}	
}
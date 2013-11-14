package com.rice.net;
import awe6.core.Entity;
import awe6.interfaces.IKernel;
import com.rice.interfaces.msg.EMsg;
import com.rice.managers.Session;
import com.rice.managers.XLog;
import com.rice.models.Cmd;
import com.rice.models.vo.ChaVO;
import haxe.ds.IntMap.IntMap;
import haxe.ds.StringMap.StringMap;
import haxe.io.BytesInput;
/**
 * ...
 * @author sxmad
 * socket 返回数据分发处理
 */
class ResponseService extends Entity implements IResponseService
{

	private var _session:Session;
	
	public function new( p_kernel:IKernel,p_session:Session ) 
	{
		super(p_kernel);
		_session = p_session;
	}
	override private function _init():Void 
	{
		super._init();
	}
	
	//==============================================
	//======接口方法实现============================
	//==============================================
	public function onConnect():Void {}	
	public function onSend(p_cmd:Int):Void {}	
	public function onClose():Void {}	
	public function onCloseManually():Void {}	
	public function onIOError(p_e:Dynamic):Void { XLog.log("Error : " + p_e); }
	public function onBadProtocolVersion():Void {}	
	public function onTimeOut():Void {}
	
	public function onData(p_cmd:Int, p_data:BytesInput):Void {
		//XLog.log("commandId:"+p_cmd);
		switch(p_cmd) {
			case Cmd.CMD_LOGIN_USERLOGIN 					: _responseLogin(p_data);
			case Cmd.CMD_SCENE_CREATE_PLAYER 				: _responseSceneCreate(p_data);
			case Cmd.CMD_SCENE_UPDATE_PLAYER 				: _responseSceneUpdate(p_data);
			
			default : XLog.log("no such commandId:" + p_cmd);
		}
	}
	
	//=========================================
	//======指令返回处理=======================
	//=========================================
	//登录信息返回
	private function _responseLogin(p_data:BytesInput):Void {
		var l_chaVO:ChaVO = new ChaVO();
		l_chaVO.name = p_data.readLine();
		l_chaVO.pass = p_data.readLine();
		XLog.log("login:" + l_chaVO.name + " --- " + l_chaVO.pass);
		_kernel.messenger.sendMessage(EMsg.LOGIN_SUCCEED(l_chaVO), this, false, false, true);
	}
	//创建场景中的角色
	private function _responseSceneCreate(p_data:BytesInput):Void {
		var l_arr:Array<ChaVO> = new Array<ChaVO>();
		//TODO
		_kernel.messenger.sendMessage(EMsg.SCENE_CREATE_PLAYER(l_arr), this, false, false, true);
	}
	//更新场景中的角色
	private function _responseSceneUpdate(p_data:BytesInput):Void {
		var l_arr:Array<ChaVO> = new Array<ChaVO>();
		//TODO
		_kernel.messenger.sendMessage(EMsg.SCENE_UPDATE_PLAYER(l_arr), this, false, false, true);
	}
	
}
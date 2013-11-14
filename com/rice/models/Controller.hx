package com.rice.models;

import awe6.interfaces.IKernel;
import com.rice.interfaces.IController;
import com.rice.managers.Session;
import com.rice.models.vo.LoginVO;
import flash.utils.ByteArray;

/**
 * ...
 * @author sxmad
 * 控制器，负责部分逻辑处理
 * 负责所有Model中的消息分发
 * 相当于proxy
 */
class Controller implements IController
{
	
	private var _kernel:IKernel;
	private var _session:Session;
	
	private var _loginModel:LoginModel;

	public function new(p_kernel:IKernel,p_session:Session) 
	{
		_kernel = p_kernel;
		_session = p_session;
		
		_initModel();
	}
	private function _initModel():Void {
		_loginModel = new LoginModel(_kernel,_session);
	}
	
	public function requestLogin(p_loginVO:LoginVO):Void 
	{
		_loginModel.requestLogin(p_loginVO);
	}
	public function responseLogin(p_data:ByteArray):Void {
		//_loginModel.responseLogin(p_data);
	}
	
}
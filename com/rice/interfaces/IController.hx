package com.rice.interfaces;
import com.rice.models.vo.LoginVO;
import flash.utils.ByteArray;

/**
 * ...
 * @author sxmad
 */
interface IController
{
	function requestLogin(p_loginVO:LoginVO):Void;//发送登录信息
	function responseLogin(p_data:ByteArray):Void;//接收登录返回信息
}
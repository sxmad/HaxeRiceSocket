package com.rice.net;
import haxe.io.BytesInput;
/**
 * ...
 * @author sxmad
 * 返回数据 接口
 */
interface IResponseService
{
	//soket建立连接
	function onConnect():Void;
	
	//数据发送
	function onSend(p_cmd:Int):Void;
	
	//数据接收
	function onData(p_cmd:Int, p_data:BytesInput):Void;
	
	//关闭连接
	function onClose():Void;
	
	//手动关闭
	function onCloseManually():Void;
	
	//IO错误
	function onIOError(p_e:Dynamic):Void;
	
	//客户端与服务端版本不一致
	function onBadProtocolVersion():Void;
	
	//超时或网络中断处理
	function onTimeOut():Void;
	
}
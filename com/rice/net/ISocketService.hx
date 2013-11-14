package com.rice.net;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

/**
 * ...
 * @author sxmad
 */
interface ISocketService
{
	//socket 连接，IP，端口，返回处理接口
	function connect(p_host:String, p_port:Int, p_responseService:IResponseService):Void;
	
	//发送数据
	function send(p_cmd:Int, p_data:BytesOutput):Void;
	
	//关闭连接
	function close():Void;
}
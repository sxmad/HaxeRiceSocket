package com.rice.net;
import awe6.interfaces.IKernel;
import com.rice.managers.XLog;
import com.rice.managers.Session;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.Output;
import haxe.io.Input;
import haxe.Timer;
import sys.net.Socket;
import sys.net.Host;
/**
 * ...
 * @author sxmad
 * socket 消息处理类
 */
	
class SocketService implements ISocketService
{	
	private var _kernel:IKernel;
	private var _session:Session;
	
	private var _responseService:IResponseService;										//回调处理
	private var _socket:Socket;															//socket 实例
	
	private static inline var _CLOSE_MANUALLY:String = "CloseManually";					//手动关闭
	private static inline var _BAD_PROTOCOL_VERSION:String = "badProtocolVersion";		//服务端与客户端版本号不一致
	
	private var _sendQueue:List<Bytes>;													//发送队列
	private var _receiveQueue:List<Input>;												//接收队列
	private var _sendTimer:Timer;														//发送队列处理计时器
	private var _receiveTimer:Timer;													//接收队列处理计时器
	private var _checkDataTimer:Timer;													//检查数据接收计时器
	private static inline var _SEND_INTERVAL:Int = 200;									//发送队列处理频率
	private static inline var _RECEIVE_INTERVAL:Int = 100;								//接收队列处理频率
	private static inline var _CHECK_DATA_INTERVAL:Int = 200;							//检查数据接收处理频率
	
	//private var _toNextSend:Bool = true;												//允许发送下一条待发送的数据
	private var _toNextData:Bool = true;												//允许处理下一条接收到的数据
	
	private static inline var _HEAD0:Int = 2;
	private static inline var _HEAD1:Int = 2;
	private static inline var _HEAD2:Int = 2;
	private static inline var _HEAD3:Int = 2;
	private static inline var _HEAD_LENGTH:Int = 4;										//协议头长度
	private static inline var _HEADER_CHUNK_LENGTH:Int = 36;							//协议头缓冲块长度
	private static inline var _PROTOCOL_VERSION:Int = 2;								//当前协议版本号(通信)
	private var _serverVersion:Int = 2;													//服务端的版本号(显示发布版本)
		
	public function new( p_kernel:IKernel,p_session:Session ) 
	{
		_kernel = p_kernel;
		_session = p_session;
		
		_sendQueue = new List<Bytes>();
		_receiveQueue = new List<Input>();
	}
	//socket 连接，IP，端口，返回处理接口
	public function connect(p_host:String, p_port:Int, p_responseService:IResponseService):Void 
	{
		return;
		_responseService = p_responseService;
		
		try {
			_socket = new Socket();
			_socket.connect(new Host(p_host), p_port);
			_onConnect();
		}catch (p_e:Dynamic) {
			_onIOError(p_e);
		}
	}
	//socket 建立连接
	private function _onConnect():Void {
		_responseService.onConnect();
		_startSendTimer();
		_startReceiveTimer();
		_startCheckDataTimer();
	}
	//socket 数据接收
	private function _onData(p_input:Input):Void {
		_processData(p_input);	
	}
	//发送数据
	public function send(p_cmd:Int, p_data:BytesOutput):Void 
	{
		var l_bytes:Bytes = p_data.getBytes();
		var l_dataLength:Int = l_bytes.length;											//获取消息内容长度
		var l_packageData:BytesOutput = new BytesOutput();								//组织数据包
		l_packageData.bigEndian = true;
		l_packageData.writeInt32(_HEAD0);												//添加包头
		l_packageData.writeInt32(_HEAD1);
		l_packageData.writeInt32(_HEAD2);
		l_packageData.writeInt32(_HEAD3);
		l_packageData.writeInt32(_PROTOCOL_VERSION);									//协议版本号
		l_packageData.writeInt32(_serverVersion);										//服务器版本号，上行(xing)传输中无效
		l_packageData.writeInt32(p_cmd);												//指令ID
		l_packageData.writeInt32(l_dataLength);											//数据长度
		l_packageData.writeBytes(l_bytes, 0, l_dataLength);								//写入指令数据
		
		var l_bytesTemp:Bytes = l_packageData.getBytes();
		_sendQueue.add(l_bytesTemp);													//添加到发送队列
		//for (i in 0...10000) {
			//_sendQueue.add(l_bytesTemp);
		//}
	}
	private function _checkDataReceived():Void {
		var l_isDataReceived = false;
        while (true) {
            var l_sockets = Socket.select([_socket], null, null, 0);
			//XLog.log("..........l_sockets.read.length : "+l_sockets.read.length);
            if(l_sockets.read.length > 0) {												//此处直接退出处理下一步？
                try {
                    l_isDataReceived = true;
					break;
                } catch (p_e:Dynamic) {
                    _onIOError(p_e);
                }
            } else {
                break;
            }
        }
		if (l_isDataReceived) {
			_receiveQueue.add(_socket.input);											//添加到接收队列
			//_onData();
		}
	}
	//处理接收到的数据
	private function _processData(p_input:Input):Void {
		_toNextData = false;															//暂时仅处理一条数据
		try {
			//var l_input:Input = _socket.input;
			//l_input.bigEndian = true;
			p_input.bigEndian = true;
			var l_head0:Int = p_input.readInt32();										//得到协议头
			var l_head1:Int = p_input.readInt32();
			var l_head2:Int = p_input.readInt32();
			var l_head3:Int = p_input.readInt32();
			
			var l_protoVersion:Int = p_input.readInt32();								//得到协议版本号
			_serverVersion = p_input.readInt32();										//得到服务器版本号
			var l_cmd:Int = p_input.readInt32();										//得到指令号
			var l_dataLength:Int = p_input.readInt32();									//得到数据长度
						
			var l_cmdData:Bytes = Bytes.alloc(l_dataLength);							//得到指令数据								
			p_input.readBytes(l_cmdData, 0, l_dataLength);
			var l_inputData:BytesInput = new BytesInput(l_cmdData);
			
			if (l_protoVersion != _PROTOCOL_VERSION) {									//协议版本不匹配
				_onBadProtocolVersion();
			}
			_toNextData = true;															//可以处理下一条数据
			_responseService.onData(l_cmd, l_inputData);								//数据传出处理
		}catch (p_e:Dynamic) {
			_onIOError(p_e);
		}
		
	}
	//发送队列处理
	private function _startSendTimer():Void {
		_sendTimer = new Timer(_SEND_INTERVAL);
		_sendTimer.run = _sendTimerHandler;
	}
	private function _sendTimerHandler():Void {
		//XLog.log(".........._sendQueue.length : "+_sendQueue.length);
		//处理请求数据
		if (_sendQueue.length > 0) {
			try {
				var l_bytes:Bytes = _sendQueue.pop();
				_socket.output.writeBytes(l_bytes , 0, l_bytes.length);					//发送数据
				_socket.output.flush();
			} catch (p_e:Dynamic) {
				_onIOError(p_e);
			}
		}
	}
	//接收队列处理
	private function _startReceiveTimer():Void {
		_receiveTimer = new Timer(_RECEIVE_INTERVAL);
		_receiveTimer.run = _receiveTimerHandler;
	}
	private function _receiveTimerHandler():Void {
		//XLog.log(".........._receiveQueue.length : "+_receiveQueue.length);
		//处理接收数据
		if (_receiveQueue.length > 0 && _toNextData) {
			var l_input:Input = _receiveQueue.pop();
			_onData(l_input);
		}
	}
	//检查接收数据处理
	private function _startCheckDataTimer():Void {
		_checkDataTimer = new Timer(_CHECK_DATA_INTERVAL);
		_checkDataTimer.run = _checkDataTimerHandler;
	}
	private function _checkDataTimerHandler():Void {
		_checkDataReceived();
	}
	//关闭连接
	public function close():Void 
	{
		if (_socket != null) {
			_socket.shutdown(false, false);
			_socket.close();
			_onClose();
		}
	}
	//socket 关闭连接接口
	private function _onClose():Void { _responseService.onClose(); }
	//socket 手动关闭连接接口
	private function _onCloseManually() { _responseService.onCloseManually(); }
	//socket 创建IO错误接口
	private function _onIOError(p_e:Dynamic):Void { _responseService.onIOError(p_e); }
	//socket 服务端与客户端版本号不一致
	private function _onBadProtocolVersion():Void { _responseService.onBadProtocolVersion(); }
}
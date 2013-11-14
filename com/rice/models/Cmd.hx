package com.rice.models;

/**
 * ...
 * @author sxmad
 * 指令ID
 * 命名规范：CMD_模块名_指令名
 */
class Cmd
{

	public function new() 
	{
		
	}
	
	public static inline var CMD_LOGIN_USERLOGIN:Int = 1001;				//登录
	
	public static inline var CMD_SCENE_CREATE_PLAYER:Int = 1101;				//创建玩家
	public static inline var CMD_SCENE_UPDATE_PLAYER:Int = 1102;				//更新场景中的玩家状态
	
}
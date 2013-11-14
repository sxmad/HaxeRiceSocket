package com.rice.models.vo;

/**
 * ...
 * @author sxmad
 */
class ChaVO
{

	public function new() 
	{
		
	}
	
	public var name:String = "";								//名字
	public var pass:String = "";								//密码
	public var id:String = "";									//id
	public var chaProfessionId:String = "";						//角色形象ID
	public var direction:Int = 1;								//角色方向1,2,3,4,5,6,7,8
	public var action:Int;										//角色动作
	public var posX:Int;										//角色所在X坐标
	public var posY:Int;										//角色所在Y坐标
	public var isMyself:Int = 1;								//1--自己，2--其他玩家
	public var chaType:Int = 1;									//1--角色，2--怪物，3--NPC等
	public var hpCurrent:Int;									//角色当前HP
	public var hpTotal:Int;										//角色总HP
	
}
package com.rice.interfaces.msg;
import com.rice.models.vo.ChaVO;
import com.rice.models.vo.LoginVO;

/**
 * ...
 * @author sxmad
 */
enum EMsg
{
	LOGIN(?p_loginVo:LoginVO);							//登录
	LOGIN_SUCCEED(?p_chaVO:ChaVO);						//登录成功返回信息
	
	SCENE_CREATE_PLAYER(?p_chaArr:Array<ChaVO>);		//创建场景中的角色
	SCENE_UPDATE_PLAYER(?p_chaArr:Array<ChaVO>);		//更新场景中的角色
}
package com.rice.utils;
import awe6.interfaces.IKernel;
import flash.geom.Point;
import haxe.io.BytesOutput;

/**
 * ...
 * @author sxmad
 */
class XTools
{
	public static inline var CHA_PRE:String = "cha";		//角色资源前缀
	public static inline var CHA_JOIN_STR:String = "_";		//角色资源名字中间连接符
	public static inline var STAND:Int = 1;					//站立
	public static inline var MOVE:Int = 2;					//移动
	public static inline var ATTACK:Int = 3;				//攻击
	
	public static inline var CHA_TYPE_PLAYER:Int = 1;		//角色类型是玩家
	public static inline var CHA_TYPE_MONSTER:Int = 2;		//角色类型是怪物
	
	public function new() { }
	
	public static inline function convertAngleToRadians(l_angle:Float):Float {
		return l_angle*Math.PI/180;
	}
	
	public static inline function convertRadiansToAngle(l_radians:Float):Float {
		return l_radians*180/Math.PI;
	}
	/**
	 * 根据两点获取角度
	 * @param	p_p1
	 * @param	p_p2
	 * @return	角度
	 */
	public static inline function getAngleFromPoint(p_p1:Point, p_p2:Point):Int {
		var l_x:Float = p_p2.x - p_p1.x;
		var l_y:Float = p_p2.y - p_p1.y;
		var l_radian:Float = Math.sqrt(l_x * l_x + l_y * l_y);
		var l_cos:Float = l_x / l_radian;
		var l_angle:Int = Math.floor(Math.acos(l_cos) * 180 / Math.PI);
		if (l_y < 0) {
			l_angle = 360 - l_angle;
		}
		return l_angle;
	}
	/**
	 * 根据角色所在点和鼠标点击点，获取角色动作
	 * @param	p_p1 角色所在点
	 * @param	p_p2 鼠标点击点
	 * @return	角色动作类型
	 * 角色动作范围角度分界点(从水平向右为0和360度)：337-22-67-112-157-202-247-292-337
	 * 
	 * (<248)     (<293)    (<338)
	 *        6     7     8
	 *          ↖  ↑  ↗
	 * (<203) 5 ←   +   → 1 (<23 || >337)
	 *          ↙  ↓  ↘
	 *        4     3     2
	 * (<158)     (<113)    (<68)
	 */
	public static inline function getDirection(p_p1:Point, p_p2:Point):Int {
		var l_direction:Int = 0;
		var l_angle:Int = getAngleFromPoint(p_p1, p_p2);
		if (l_angle < 23 || l_angle > 337) {
			l_direction = 1;
		}else if (l_angle < 68) {
			l_direction = 2;
		}else if (l_angle < 113) {
			l_direction = 3;
		}else if (l_angle < 158) {
			l_direction = 4;
		}else if (l_angle < 203) {
			l_direction = 5;
		}else if (l_angle < 248) {
			l_direction = 6;
		}else if (l_angle < 293) {
			l_direction = 7;
		}else if (l_angle < 338) {
			l_direction = 8;
		}
		return l_direction;
	}
	public static inline function writeString(p_data:BytesOutput,p_string:String):Void {
		p_data.writeString(p_string + "\n");
	}
	/**
	 * 
	 * @param	p_p1
	 * @param	p_p2
	 * @param	p_everyDistance
	 * @return
	 */
	public static function getPathPoint(p_p1:Point, p_p2:Point, p_everyDistance:Int=20):Array<Point> {
		var l_dis:Int = Math.ceil(getDis(p_p1.x, p_p1.y, p_p2.x, p_p2.y));//两点间的距离，取小值不会越界
		var l_disCount:Int=0;//分成多少段
		if (l_dis > p_everyDistance) {
			l_disCount = Math.ceil(l_dis / p_everyDistance); 
		}
		return getPointsArr(p_p1, p_p2, l_disCount);
	}
	/**
	 * 两点间的距离
	 * @param	p_startX 起始点X坐标
	 * @param	p_startY 起始点Y坐标
	 * @param	p_endX	 终点X坐标
	 * @param	p_endY	 终点Y坐标
	 * @param	p_isSquared
	 * @return
	 */
	public static function getDis( p_startX:Float, p_startY:Float, p_endX:Float, p_endY:Float, p_isSquared:Bool = false ):Float
	{
		var l_dx:Float = p_endX - p_startX;
		var l_dy:Float = p_endY - p_startY;
		var l_distance:Float = ( l_dx * l_dx ) + ( l_dy * l_dy );
		return p_isSquared ? l_distance : Math.sqrt( l_distance );
	}
	/**
	 * 获取和存储直线上的所有轨迹点,都是从起始点坐标开始出发
	 * @param p1 起始点坐标对象
	 * @param p2 终止点坐标对象
	 * @param g  要把确定的线段分割成几份(ge)
	 * @return	 (Array) 返回以直线上面的轨迹点对象为元素的数组
	 */
	public static function getPointsArr(p1:Point, p2:Point, ?g:Int=2):Array<Point>{
		//if(p1 == null || p2 == null)return null;
		var arr:Array<Point> = new Array<Point>();
		var m:Float = p1.x;    //起始点x值
		var n:Float = p1.y;    //起始点y值
		var c:Float = p2.x;    //终止点x值
		var d:Float = p2.y;    //终止点y值
		var w:Float = Math.sqrt(Math.pow(m - c, 2) + Math.pow(n - d, 2)) / g;    //[只读]二维平面内相邻点之间的直线距离
		var a:Float = 0;
		var t:Point = createLine(p1, p2);
		arr[0] = new Point(Math.ceil(m), Math.ceil(n));    //起始点坐标
		var i:Int = 1;
		while(i <= g){
			a = w * i;
			var p:Point = null;
			if(t != null){
				var k:Float = t.x;
				var b:Float = t.y;
				var f:Float = 4 * (Math.pow(m - k * b + n * k, 2) - (1 + Math.pow(k, 2)) * (Math.pow(m, 2) + Math.pow(n, 2) + Math.pow(b, 2) - 2 * n * b - Math.pow(a, 2)));
				if(f > 0){    //两个值
					var x1:Float = (2 * (m - k * b + n * k) + Math.sqrt(f)) / (2 * (1 + Math.pow(k, 2)));
					var y1:Float = k * (2 * (m - k * b + n * k) + Math.sqrt(f)) / (2 * (1 + Math.pow(k, 2))) + b;
					var x2:Float = (2 * (m - k * b + n * k) - Math.sqrt(f)) / (2 * (1 + Math.pow(k, 2)));
					var y2:Float = k * (2 * (m - k * b + n * k) - Math.sqrt(f)) / (2 * (1 + Math.pow(k, 2))) + b;
					if(c > m){    //此种情况下x1和x2是不可能相等的
						if(x1 > x2){
							p = new Point(x1, y1);
						}else if(x1 < x2){
							p = new Point(x2, y2);
						}
					}else if(c < m){    //此种情况下x1和x2是不可能相等的
						if(x1 > x2){
							p = new Point(x2, y2);
						}else if(x1 < x2){
							p = new Point(x1, y1);
						}
					}else{    //竖直的线
						if(n > d){    //此种情况下y1和y2是不可能相等的
							if(y1 > y2){
								p = new Point(x2, y2);
							}else{
								p = new Point(x1, y1);
							}
						}else{
							if(y1 > y2){
								p = new Point(x1, y1);
							}else{
								p = new Point(x2, y2);
							}
						}
					}
				}else if(f == 0){    //一个值
					p.x = 2 * (m - k * b + n * k) / (2 * (1 + Math.pow(k, 2)));
					p.y = k * (2 * (m - k * b + n * k) / (2 * (1 + Math.pow(k, 2)))) + b;
				}
			}else{    //起始点和终止点的x值相等
				if(n > d){    //下 --> 上
					p = new Point(m, n - a);
				}else{    //上 --> 下
					//trace(i, n, w, n + w);
					p = new Point(m, n + a);
				}
			}
			arr[i] = new Point(Math.ceil(p.x), Math.ceil(p.y));    //包含了终止点坐标了
			i++;
		}
		return arr;
	}
	/**
	 * 直线公式，已知指定的两个点，确定一条直线
	 * y = k * x + b，此函数即返回k = point.x和b = point.y
	 * @param p1 一个点对象
	 * @param p2 另外一个点对象
	 * @return (Point) 返回直线公式的两个参数，组合成一个Point对象存储
	 */
	private static function createLine(p1:Point, p2:Point):Point{
		if(p1.x != p2.x){
			var k:Float = (p1.y - p2.y) / (p1.x - p2.x);
			var b:Float = p1.y - (p1.y - p2.y) / (p1.x - p2.x) * p1.x;
			return new Point(k, b);
		}else{
			return null;
		}
	}
	
}
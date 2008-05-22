/* 
 * PROJECT: FLARToolKit
 * --------------------------------------------------------------------------------
 * This work is based on the NyARToolKit developed by
 *   R.Iizuka (nyatla)
 * http://nyatla.jp/nyatoolkit/
 *
 * The FLARToolKit is ActionScript 3.0 version ARToolkit class library.
 * Copyright (C)2008 Saqoosha
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this framework; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * For further information please contact.
 *	http://www.libspark.org/wiki/saqoosha/FLARToolKit
 *	<saq(at)saqoosha.net>
 * 
 */

package com.libspark.flartoolkit.core {
	
	import com.libspark.flartoolkit.FLARException;
	import com.libspark.flartoolkit.core.raster.FLARBitmapData;
	import com.libspark.flartoolkit.util.ArrayUtil;
	
	/**
	 * 24ビットカラーのマーカーを保持するために使うクラスです。
	 * このクラスは、ARToolkitのパターンと、ラスタから取得したパターンを保持します。
	 * 演算順序を含む最適化をしたもの
	 *
	 */
	public class FLARColorPatt_O3 implements IFLARColorPatt {
		
	    private static const AR_PATT_SAMPLE_NUM:int = 64;//#define   AR_PATT_SAMPLE_NUM   64
	    private var extpat:Array;
	    private var width:int;
	    private var height:int;
	    
	    public function FLARColorPatt_O3(i_width:int, i_height:int) {
			this.width = i_width;
			this.height = i_height;
			this.extpat = ArrayUtil.createMultidimensionalArray(i_height, i_width, 3);//new int[i_height][i_width][3];
	    }
	    
	//    public void setSize(int i_new_width,int i_new_height)
	//    {
	//	int array_w=this.extpat[0].length;
	//	int array_h=this.extpat.length;
	//	//十分なサイズのバッファがあるか確認
	//	if (array_w>=i_new_width && array_h>=i_new_height) {
	//	    //OK 十分だ→サイズ調整のみ
	//	} else {
	//	    //足りないよ→取り直し
	//	    this.extpat=new int[i_new_height][i_new_width][3];
	//	}
	//        this.width =i_new_width;
	//        this.height=i_new_height;
	//        return;
	//    }    
	
	    public function getPatArray():Array {
			return extpat;
	    }
	    
	    public function getWidth():int {
			return width;
	    }
	    
	    public function getHeight():int {
			return height;
	    }
	    
	    private const wk_get_cpara_a:FLARMat = new FLARMat(8,8);
	    private const wk_get_cpara_b:FLARMat = new FLARMat(8,1);
	
	    /**
	     * @param world
	     * @param vertex
	     * @param o_para
	     * @throws FLARException
	     */
	    private function get_cpara(vertex_0:Array, vertex_1:Array, o_para:FLARMat):Boolean {
			var world:Array = this.wk_pickFromRaster_world;
			var a:FLARMat = wk_get_cpara_a;//次処理で値を設定するので、初期化不要// new FLARMat(8, 8);
			var a_array:Array = a.getArray();
			var b:FLARMat = wk_get_cpara_b;//次処理で値を設定するので、初期化不要// new FLARMat(8, 1);
			var b_array:Array = b.getArray();
			var a_pt0:Array, a_pt1:Array, world_pti:Array;
	
			for (var i:int = 0; i < 4; i++) {
			    a_pt0 = a_array[i*2];
			    a_pt1 = a_array[i*2+1];
			    world_pti = world[i];
		
			    a_pt0[0] = world_pti[0];//a->m[i*16+0]  = world[i][0];
			    a_pt0[1] = world_pti[1];//a->m[i*16+1]  = world[i][1];
			    a_pt0[2] = 1.0;//a->m[i*16+2]  = 1.0;
			    a_pt0[3] = 0.0;//a->m[i*16+3]  = 0.0;
			    a_pt0[4] = 0.0;//a->m[i*16+4]  = 0.0;
			    a_pt0[5] = 0.0;//a->m[i*16+5]  = 0.0;
			    a_pt0[6] = -world_pti[0] * vertex_0[i];//a->m[i*16+6]  = -world[i][0] * vertex[i][0];
			    a_pt0[7] = -world_pti[1] * vertex_0[i];//a->m[i*16+7]  = -world[i][1] * vertex[i][0];
			    a_pt1[0] = 0.0;//a->m[i*16+8]  = 0.0;
			    a_pt1[1] = 0.0;//a->m[i*16+9]  = 0.0;
			    a_pt1[2] = 0.0;//a->m[i*16+10] = 0.0;
			    a_pt1[3] = world_pti[0];//a->m[i*16+11] = world[i][0];
			    a_pt1[4] = world_pti[1];//a->m[i*16+12] = world[i][1];
			    a_pt1[5] = 1.0;//a->m[i*16+13] = 1.0;
			    a_pt1[6] = -world_pti[0] * vertex_1[i];//a->m[i*16+14] = -world[i][0] * vertex[i][1];
			    a_pt1[7] = -world_pti[1] * vertex_1[i];//a->m[i*16+15] = -world[i][1] * vertex[i][1];
			    b_array[i*2+0][0] = vertex_0[i];//b->m[i*2+0] = vertex[i][0];
			    b_array[i*2+1][0] = vertex_1[i];//b->m[i*2+1] = vertex[i][1];
			}
			if (!a.matrixSelfInv()) {
			    return false;
			}	    
		
			o_para.matrixMul(a, b);
			return true;
	    }
	
	  //   private final double[] wk_pickFromRaster_para=new double[9];//[3][3];
	    private const wk_pickFromRaster_world:Array = [//double    world[4][2];
		    [100.0,     100.0],
		    [100.0+10.0,100.0],
		    [100.0+10.0,100.0 + 10.0],
		    [100.0,     100.0 + 10.0]
	    ];
	    /**
	     * pickFromRaster関数から使う変数です。
	     *
	     */
	    private static function initValue_wk_pickFromRaster_ext_pat2(i_ext_pat2:Array, i_width:int, i_height:int):void {
			var i:int, i2:int;
			var pt2:Array;
			var pt1:Array;
			for (i = i_height - 1; i >= 0; i--) {
			    pt2 = i_ext_pat2[i];
			    for (i2 = i_width - 1; i2 >= 0; i2--) {
					pt1 = pt2[i2];
					pt1[0] = 0;
					pt1[1] = 0;
					pt1[2] = 0;
			    }
			}
	    }
	    
	    private const wk_pickFromRaster_local:Array = ArrayUtil.createMultidimensionalArray(2, 4);//new double[2][4];
	    private const wk_pickFromRaster_cpara:FLARMat = new FLARMat(8,1);
	    /**
	     * imageから、i_markerの位置にあるパターンを切り出して、保持します。
	     * Optimize:STEP[769->750]
	     * @param image
	     * @param i_marker
	     * @throws Exception
	     */
	    public function pickFromRaster(image:FLARBitmapData, i_marker:FLARMarker):Boolean {
			var cpara:FLARMat = this.wk_pickFromRaster_cpara;
			//localの計算
			var x_coord:Array = i_marker.x_coord;
			var y_coord:Array = i_marker.y_coord;
			var vertex:Array = i_marker.mkvertex;
			var local_0:Array = wk_pickFromRaster_local[0];//double    local[4][2];	
			var local_1:Array = wk_pickFromRaster_local[1];//double    local[4][2];	
			for (var i:int = 0; i < 4; i++) {
			    local_0[i] = x_coord[vertex[i]];
			    local_1[i] = y_coord[vertex[i]];
			}
			//xdiv2,ydiv2の計算
			var xdiv2:int, ydiv2:int;
			var l1:int, l2:int;
			var w1:Number, w2:Number;
		
			//x計算
			w1 = local_0[0] - local_0[1];
			w2 = local_1[0] - local_1[1];
			l1 = int(w1*w1+w2*w2);
			w1 = local_0[2] - local_0[3];
			w2 = local_1[2] - local_1[3];
			l2 = int(w1*w1+w2*w2);
			if (l2 > l1) {
			    l1 = l2;
			}
			l1 = l1 / 4;
			xdiv2 = this.width;
			while(xdiv2*xdiv2 < l1) {
			    xdiv2 *= 2;
			}
			if (xdiv2 > AR_PATT_SAMPLE_NUM) {
			    xdiv2 = AR_PATT_SAMPLE_NUM;
			}
			
			//y計算
			w1 = local_0[1] - local_0[2];
			w2 = local_1[1] - local_1[2];
			l1 = int(w1*w1+ w2*w2);
			w1 = local_0[3] - local_0[0];
			w2 = local_1[3] - local_1[0];
			l2 = int(w1*w1+ w2*w2);
			if (l2 > l1) {
			    l1 = l2;
			}
			ydiv2 =this.height;
			l1 = l1 / 4;
			while (ydiv2*ydiv2 < l1) {
			    ydiv2*=2;
			}
			if (ydiv2 >AR_PATT_SAMPLE_NUM) {
			    ydiv2 = AR_PATT_SAMPLE_NUM;
			}	
			
			//cparaの計算
			if (!get_cpara(local_0,local_1,cpara)) {
			    return false;
			}
			updateExtpat(image,cpara,xdiv2,ydiv2);
		
			return true;
	    }
	    
	    //かなり大きいワークバッファを取るな…。
	    private var wk_updateExtpat_para00_xw:Array;
	    private var wk_updateExtpat_para10_xw:Array;
	    private var wk_updateExtpat_para20_xw:Array;
	    private var wk_updateExtpat_rgb_buf:Array;
	    private var wk_updateExtpat_x_rgb_index:Array;
	    private var wk_updateExtpat_y_rgb_index:Array;
	    private var wk_updateExtpat_i_rgb_index:Array;
	    private var wk_updateExtpat_buffer_size:int = 0;
	
	    /**
	     * ワークバッファを予約する
	     * @param i_xdiv2
	     */
	    private function reservWorkBuffers(i_xdiv2:int):void {
	        if (this.wk_updateExtpat_buffer_size < i_xdiv2) {
	            wk_updateExtpat_para00_xw = new Array(i_xdiv2);//new double[i_xdiv2];
	            wk_updateExtpat_para10_xw = new Array(i_xdiv2);//new double[i_xdiv2];
	            wk_updateExtpat_para20_xw = new Array(i_xdiv2);//new double[i_xdiv2];
	            wk_updateExtpat_rgb_buf = new Array(i_xdiv2 * 3);//new int[i_xdiv2*3];
	            wk_updateExtpat_x_rgb_index = new Array(i_xdiv2);//new int[i_xdiv2];
	            wk_updateExtpat_y_rgb_index = new Array(i_xdiv2);//new int[i_xdiv2];
	            wk_updateExtpat_i_rgb_index = new Array(i_xdiv2);//new int[i_xdiv2];
	            this.wk_updateExtpat_buffer_size = i_xdiv2;
	        }
			//十分なら何もしない。
			return;
	    }
	    
	    private function updateExtpat(image:FLARBitmapData, i_cpara:FLARMat, i_xdiv2:int, i_ydiv2:int):void {
			var img_x:int = image.getWidth();
			var img_y:int = image.getHeight();
			const L_extpat:Array = this.extpat;
			const L_WIDTH:int = this.width;
			const L_HEIGHT:int = this.height;
			/*wk_pickFromRaster_ext_pat2ワーク変数を初期化する。*/
			//int[][][] ext_pat2=wk_pickFromRaster_ext_pat2;//ARUint32  ext_pat2[AR_PATT_SIZE_Y][AR_PATT_SIZE_X][3];
			var extpat_j:Array, extpat_j_i:Array;
			//int ext_pat2_j[][],ext_pat2_j_i[];
		
			initValue_wk_pickFromRaster_ext_pat2(L_extpat, L_WIDTH, L_HEIGHT);
		
			var cpara_array:Array = i_cpara.getArray();
			var para21_x_yw:Number, para01_x_yw:Number, para11_x_yw:Number;
			var para00:Number, para01:Number, para02:Number, para10:Number, para11:Number, para12:Number, para20:Number, para21:Number;
		        para00 = cpara_array[0*3+0][0];//para[i][0] = c->m[i*3+0];
		        para01 = cpara_array[0*3+1][0];//para[i][1] = c->m[i*3+1];
		        para02 = cpara_array[0*3+2][0];//para[i][2] = c->m[i*3+2];
		        para10 = cpara_array[1*3+0][0];//para[i][0] = c->m[i*3+0];
		        para11 = cpara_array[1*3+1][0];//para[i][1] = c->m[i*3+1];
		        para12 = cpara_array[1*3+2][0];//para[i][2] = c->m[i*3+2];
		        para20 = cpara_array[2*3+0][0];//para[2][0] = c->m[2*3+0];
		        para21 = cpara_array[2*3+1][0];//para[2][1] = c->m[2*3+1];
		
			
			var d:Number, yw:Number;
			var xc:int, yc:int;
			var i:int, j:int;
			//   	arGetCode_put_zero(ext_pat2);//put_zero((ARUint8 *)ext_pat2, AR_PATT_SIZE_Y*AR_PATT_SIZE_X*3*sizeof(ARUint32));
			var xdiv:int = i_xdiv2 / L_WIDTH;//xdiv = xdiv2/Config.AR_PATT_SIZE_X;
			var ydiv:int = i_ydiv2 / L_HEIGHT;//ydiv = ydiv2/Config.AR_PATT_SIZE_Y;
			
			//計算バッファを予約する
			this.reservWorkBuffers(i_xdiv2);	
			var para00_xw:Array = this.wk_updateExtpat_para00_xw;
			var para10_xw:Array = this.wk_updateExtpat_para10_xw;
			var para20_xw:Array = this.wk_updateExtpat_para20_xw;
			var x_rgb_index:Array = this.wk_updateExtpat_x_rgb_index;
			var y_rgb_index:Array = this.wk_updateExtpat_y_rgb_index;
			var i_rgb_index:Array = this.wk_updateExtpat_i_rgb_index;
			var rgb_buf:Array = this.wk_updateExtpat_rgb_buf;
			var xw:Number;
			for (i = 0; i < i_xdiv2; i++) {
			    xw = 102.5 + 5.0 * (i + 0.5) /i_xdiv2;
			    para20_xw[i] = para20*xw;
			    para00_xw[i] = para00*xw;
			    para10_xw[i] = para10*xw;
			}
		
			var index_num:int;
			
			for (j = 0; j < i_ydiv2; j++) {
			    yw = 102.5 + 5.0 * (j + 0.5) / i_ydiv2;
			    para21_x_yw = para21*yw+1.0;
			    para11_x_yw = para11*yw+para12;
			    para01_x_yw = para01*yw+para02;
			    extpat_j = L_extpat[int(j / ydiv)];
			    index_num = 0;
			    //ステップ１．RGB取得用のマップを作成
			    for (i = 0; i < i_xdiv2; i++) {
					d = para20_xw[i] + para21_x_yw;
					if (d == 0) {
					    throw new FLARException();
					}
					xc = int((para00_xw[i] + para01_x_yw)/d);
					yc = int((para10_xw[i] + para11_x_yw)/d);
					//範囲外は無視
					if (xc<0 || xc >=img_x || yc<0 || yc >=img_y) {
					    continue;
					}
			//		ピクセル値の計算
			//		image.getPixel(xc,yc,rgb_buf);
			//                ext_pat2_j_i=ext_pat2_j[i/xdiv];
			//                ext_pat2_j_i[0] += rgb_buf[0];//R
			//                ext_pat2_j_i[1] += rgb_buf[1];//G
			//                ext_pat2_j_i[2] += rgb_buf[2];//B
			
					x_rgb_index[index_num] = xc;
					y_rgb_index[index_num] = yc;
					i_rgb_index[index_num] = int(i / xdiv);
					index_num++;
			    }
		//	    //ステップ２．ピクセル配列を取得
			    image.getPixelSet(x_rgb_index,y_rgb_index,index_num,rgb_buf);
		//	    //ピクセル値の計算
			    for (i = index_num-1; i >= 0; i--) {
	                extpat_j_i = extpat_j[i_rgb_index[i]];
	                extpat_j_i[0] += rgb_buf[i*3+0];//R
	                extpat_j_i[1] += rgb_buf[i*3+1];//G
	                extpat_j_i[2] += rgb_buf[i*3+2];//B
			    }
			}
			/*<Optimize>*/
			var xdiv_x_ydiv:int = xdiv * ydiv;
			for (j = L_HEIGHT-1; j >= 0; j--) {
			    extpat_j = L_extpat[j];
			    for (i = L_WIDTH-1; i >= 0; i--) {				// PRL 2006-06-08.
					extpat_j_i = extpat_j[i];
					extpat_j_i[0] /= (xdiv_x_ydiv);//ext_pat[j][i][0] = (byte)(ext_pat2[j][i][0] / (xdiv*ydiv));
					extpat_j_i[1] /= (xdiv_x_ydiv);//ext_pat[j][i][1] = (byte)(ext_pat2[j][i][1] / (xdiv*ydiv));
					extpat_j_i[2] /= (xdiv_x_ydiv);//ext_pat[j][i][2] = (byte)(ext_pat2[j][i][2] / (xdiv*ydiv));
			    }
			}
			return;	
	    }
	    
	}
	
}
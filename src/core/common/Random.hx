package common;

/**
 * ...
 * @author shohei909
 */
class Random{
	static public inline var MT_N 		= 624;
	static public inline var MT_M 		= 397;
	static public inline var MATRIX_A	= 0x9908b0df;
	static public inline var UPPER_MASK	= 0x80000000;
	static public inline var LOWER_MASK	= 0x7fffffff;
	
	var value:Int;
	var array:Array<Int>;
	public var seed(default, null):Int;
	
	public function new( seed:Int ) {
		reset( seed );
	}
	
	public function reset( seed:Int ) {
		this.seed = seed;
		
		var a,b,al,ah,bl,bh,cl,ch;
		
		value = MT_N + 1;
		array = [];
		
		array[0] = seed & 0xffffffff;
		
		for ( value in 1...MT_N ) {
			a  = 1812433253;
			b  = array[value-1] ^ (array[value-1] >>> 30);
			al = a & 0xFFFF;
			ah = a >>> 16;
			bl = b & 0xFFFF;
			bh = b >>> 16;
			cl = (al * bl) + value;
			ch = (cl >>> 16) + ((al * bh) & 0xFFFF)  + ((ah * bl) & 0xFFFF);
			array[value] = ((ch << 16) | (cl & 0xFFFF)); 
			array[value] &= 0xffffffff;
		}
	}
	
	public function int():Int {
		var y;
		var mag01 = [0x0, MATRIX_A];

		if ( value >= MT_N) {
			if (value == MT_N + 1)
				reset(5489);
			
			for (kk in 0...(MT_N - MT_M)) {
				y = (array[kk] & UPPER_MASK) | (array[kk+1] & LOWER_MASK);
				array[kk] = array[kk+MT_M] ^ (y >>> 1) ^ mag01[y & 0x1];
			}
			for (kk in (MT_N - MT_M)...(MT_N-1)) {
				y = (array[kk] & UPPER_MASK) | (array[kk+1] & LOWER_MASK);
				array[kk] = array[kk+(MT_M-MT_N)] ^ (y >>> 1) ^ mag01[y & 0x1];
			}
			
			y = (array[MT_N-1] & UPPER_MASK) | (array[0] & LOWER_MASK);
			array[MT_N-1] = array[MT_M-1] ^ (y >>> 1) ^ mag01[y & 0x1];
			
			value = 0;
		}
	  
		y = array[value++];
		
		y ^= (y >>> 11);
		y ^= (y <<  7) & 0x9d2c5680;
		y ^= (y << 15) & 0xefc60000;
		y ^= (y >>> 18);
		
		return y;
	}
	
	public function range( start:Int, end:Int ) {
		return _range( int(), start, end );
	}
	
	public function _range( i:Int, start:Int, end:Int ) {
		var sign = (i & UPPER_MASK) == 0;
		i = i & LOWER_MASK;
		
		var length = start - end;
		
		if ( start >= end ) {
			throw "end must be larger than start.";
		}
		
		return 
			if ( sign )
				start + i % (length);
			else
				start + i % (-length);
	}
}
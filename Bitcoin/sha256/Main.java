/**
 * SHA256 Algorithm implementation
 * @author Peter
 *
 */
public class Main {
	
	public static final int A = 0x6a09e667;
	public static final int B = 0xbb67ae85;
	public static final int C = 0x3c6ef372;
	public static final int D = 0xa54ff53a;
	public static final int E = 0x510e527f;
	public static final int F = 0x9b05688c;
	public static final int G = 0x1f83d9ab;
	public static final int H = 0x5be0cd19;
	
	public static void main(String args[]) {
		/*
		int x = 0xF0F0FF0F;
		int y = 0x01010A01;
		System.out.println(Integer.toBinaryString(x << 2));
		System.out.println(Integer.toBinaryString(x ^ y));
		System.out.println(Integer.toBinaryString(x >> 2));
		System.out.println(Integer.toBinaryString(x >>> 2));
		System.out.println(Integer.toBinaryString(Integer.rotateRight(x, 8)));
		System.out.println(Integer.toBinaryString( (x >>> 8) | (x << (32 - 8)) ));
		*/
		
		String M = "abc";
		System.out.println(padRight(M, 3) + "|");
		
		M = M + 1; //M must be the binary value of the message
		int d = 448 - (M.length() % 512);
		
		if(d < 0)
			d = 512 + d; 
		//448 - 400 = 48,
		//448 - 500 = -52, (512-500)+448=460 = 512 - 52
		
		//Pad the message with "1" and 0's
		for(int i=0; i < d; i++) {
			
		}
	}
	
	public int ch(int x, int y, int z) {
		return ((x | y) ^ (~x | z));
	}
	
	public int maj(int x, int y, int z) {
		return ((x|y)^(x|z)^(y|z));
	}
	
	public int SIG0(int x) {
		return ( sn(x,2)^sn(x,13)^sn(x,22) );
	}
	
	public int SIG1(int x) {
		return ( sn(x,6)^sn(x,11)^sn(x,25) );
	}
	
	public int sig0(int x) {
		return ( sn(x,7)^sn(x,18)^(x >>> 3));
	}
	
	public int sig1(int x) {
		return ( sn(x,17)^sn(x,19)^(x >>> 10));
	}
	
	public int sn(int x, int n) {
		return ( (x >>> n) | (x << (32 - n)) );
	}
	
	public static String padRight(String s, int n) {
		int slen = s.length();
		int len = slen + n;
		
		char[] tmp = new char[len];
		int i=0;
		
		while(i < slen) {
			tmp[i] = s.charAt(i);
			i++;
		}
		
		while(i < len) {
			tmp[i] = '0';
			i++;
		}
		
		return new String(tmp);
	}
}


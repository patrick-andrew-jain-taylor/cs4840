/**
 * SHA256 Algorithm implementation
 * @author Peter
 *
 */
import java.util.ArrayList;

public class Main {
	
	public static final int H0 = 0x6a09e667;
	public static final int H1 = 0xbb67ae85;
	public static final int H2 = 0x3c6ef372;
	public static final int H3 = 0xa54ff53a;
	public static final int H4 = 0x510e527f;
	public static final int H5 = 0x9b05688c;
	public static final int H6 = 0x1f83d9ab;
	public static final int H7 = 0x5be0cd19;
	
	/* First 32 bits of the fractional parts of the cube roots
	 * of the first 64 primes 2..311 
	 */
	public static final int[] K = {
		0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
		0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
		0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
		0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
		0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
		0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
		0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
		0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
	};
	
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
		
		//System.out.println((int) Long.parseLong("11000000000000000000000000011001", 2));
		
		String msg = "011000010110001001100011";
		String msgTmp = msg;
		//Pad the message with "1" and 0's until multiple of 512 bits
		msgTmp += 1; //M must be the binary representation of the message
		
		int diff = 448 - (msgTmp.length() % 512);
		
		if(diff < 0)
			diff = 512 + diff; 

		msgTmp = padRight(msgTmp, diff);
		msgTmp += lenTo64bit((long)msg.length());
		
		// Split msg into multiples of 512 bit blocks
		ArrayList<String> M = new ArrayList<String>();
		M = parseMsg512(msgTmp);
		
		//System.out.println(M.toString() + "|" + M.get(0).length());
		
		// Main Loop
		int h0 = H0;
		int h1 = H1;
		int h2 = H2;
		int h3 = H3;
		int h4 = H4;
		int h5 = H5;
		int h6 = H6;
		int h7 = H7;
		int a,b,c,d,e,f,g,h;
		
		for(int i=0; i < M.size(); i++) {
			a = h0;
			b = h1;
			c = h2;
			d = h3;
			e = h4;
			f = h5;
			g = h6;
			h = h7;
			
			String[] W = new String[64];
			W = getExpBlocks(M.get(i));
			

			System.out.println("init) " + 
					Integer.toHexString(a) + " " +
					Integer.toHexString(b) + " " +
					Integer.toHexString(c) + " " +
					Integer.toHexString(d) + " " +
					Integer.toHexString(e) + " " +
					Integer.toHexString(f) + " " +
					Integer.toHexString(g) + " " +
					Integer.toHexString(h));
			
			for(int j=0; j < 64; j++) {
				int tmp1 = h + SIG1(e) + ch(e,f,g) + K[j] + (int) Long.parseLong(W[j], 2);
				int tmp2 = SIG0(a) + maj(a, b, c);
				h = g;
				g = f;
				f = e;
				e = d + tmp1;
				d = c;
				c = b;
				b = a;
				a = tmp1 + tmp2;
				
				System.out.println(j + ") " + 
						Integer.toHexString(a) + " " +
						Integer.toHexString(b) + " " +
						Integer.toHexString(c) + " " +
						Integer.toHexString(d) + " " +
						Integer.toHexString(e) + " " +
						Integer.toHexString(f) + " " +
						Integer.toHexString(g) + " " +
						Integer.toHexString(h));
			}
			
			h0 += a;
			h1 += b;
			h2 += c;
			h3 += d;
			h4 += e;
			h5 += f;
			h6 += g;
			h7 += h;
		}
		
		// Digest
		String digest = Integer.toHexString(h0) +
				Integer.toHexString(h1) +
				Integer.toHexString(h2) +
				Integer.toHexString(h3) +
				Integer.toHexString(h4) +
				Integer.toHexString(h5) +
				Integer.toHexString(h6) +
				Integer.toHexString(h7);
		
		
		System.out.println(digest);
		System.out.println(digest.length());
	}
	
	public static int ch(int x, int y, int z) {
		return ((x | y) ^ (~x | z));
	}
	
	public static int maj(int x, int y, int z) {
		return ((x|y)^(x|z)^(y|z));
	}
	
	public static int SIG0(int x) {
		return ( sn(x,2)^sn(x,13)^sn(x,22) );
	}
	
	public static int SIG1(int x) {
		return ( sn(x,6)^sn(x,11)^sn(x,25) );
	}
	
	public static int sig0(int x) {
		return ( sn(x,7)^sn(x,18)^(x >>> 3));
	}
	
	public static int sig1(int x) {
		return ( sn(x,17)^sn(x,19)^(x >>> 10));
	}
	
	public static int sn(int x, int n) {
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
	
	public static String lenTo64bit(long length) {
		String s = Long.toBinaryString(length);
		int slen = s.length();
		if(slen >= 64)
			return s;
		
		char[] tmp = new char[64];
		int d = 64 - slen;
		int i = 0;
		
		while(i < d) {
			tmp[i] = '0';
			i++;
		}
		
		int j=0;
		while(i < 64) {
			tmp[i] = s.charAt(j);
			i++;
			j++;
		}
		
		return new String(tmp);
	}
	
	public static ArrayList<String> parseMsg512(String msg) {
		ArrayList<String> M = new ArrayList<String>();
		int i=0;
		int mlen = msg.length();
		
		while(i < mlen) {
			M.add(msg.substring(i, i+512));
			i += 512;
		}
		
		return M;
	}
	
	public static String[] getExpBlocks(String mi) {
		// Each entry in W is a 32-bit binary string
		String[] W = new String[64];
		
		for(int j=0; j < 16; j++) {
			W[j] = mi.substring(j, j+32);
		}
		
		for(int j=16; j < 64; j++) {
			int t1 = sig1((int)Long.parseLong(W[j-2], 2));
			int t2 = (int) Long.parseLong(W[j-7],2);
			int t3 = sig0((int) Long.parseLong(W[j-15], 2));
			int t4 = (int) Long.parseLong(W[j-16], 2);
			W[j] =  Integer.toBinaryString(t1 + t2 + t3 + t4);
		}
		
		return W;
	}
}


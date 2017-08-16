import logical.crypto.blowfish.Blowfish;

public class BlowfishWrapper {
    public static void main (String[] args) {
		Blowfish bf = new Blowfish();
		String out = "";
 	    if (args[0].equals("encrypt")){
 	    	out = bf.encryptStrWithPass(args[1], args[2]);
		} else if(args[0].equals("decrypt")){
			out = bf.decryptStrWithPass(args[1], args[2]);
 	    }
		// return out;
        System.out.println(out);
    }
}
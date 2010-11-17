/* ------------------------------------
 *
 * Project:	OAC 4.0
 *
 * Task:	To provide a static method that will provide the hex-
 *		encoded md5 hash of a given string.
 *
 * Name:	Md5Hash
 *
 * Acknowledgement:  The code was lifted from web page
 *		"http://snippets.dzone.com/posts/show/3686":
 *		import java.security.*;
 *		import java.math.*;
 *
 *		public class MD5 {
 *		    public static void main(String args[]) throws Exception{
 *			String s="This is a test";
 *			MessageDigest m=MessageDigest.getInstance("MD5");
 *			m.update(s.getBytes(),0,s.length());
 *			System.out.println("MD5: "+new BigInteger(1,m.digest()).
 *			    toString(16));
 *		    }
 *		}
 *
 * Command line parameters:  (when invoked from the command line, so that
 *		the "static void main" method is invoked)
 *		any number of parameters, each is passed to the static
 *		method, that takes strings as input, one at a time.
 *		
 * Author:	Michael A. Russell
 *
 * Revision History:
 *		2008/9/18 - MAR - Initial writing
 *		2008/9/18 - MAR - Initialization of bigInt is not necessary.
 * ------------------------------------
 */

package org.cdlib.dsc.util;

import java.math.BigInteger;
import java.security.MessageDigest;

public class Md5Hash {

    public static void main(String[ ] arg) {
	int i;
	String results;

	for (i = 0; i < arg.length; i++) {
	    results = md5Hash(arg[i]);
	    System.out.println("input = \"" + arg[i] + "\", output = \"" +
		results + "\"");
	    }
	}

    /* The static method which is the raison d'etre of this class.  */
    public static String md5Hash(String inputString) {
	/* Get an md5 message digest object.  */
	MessageDigest msgDigest;
	try {
	    msgDigest = MessageDigest.getInstance("MD5");
	    }
	catch (Exception e) {
	    /* NoSuchAlgorithmException probably.  Return a zero-length
	     * string.
	     */
	    return("");
	    }

	/* Calculate the md5 digest for the input string.  */
	msgDigest.update(inputString.getBytes( ), 0, inputString.length( ));

	/* Get a BigInteger version of the md5 digest.  */
	BigInteger bigInt;
	try {
	    bigInt = new BigInteger(1, msgDigest.digest( ));
	    }
	catch (Exception e) {
	    /* NumberFormatException probably.  Return a zero-length string.  */
	    return("");
	    }

	/* Convert the BigInteger to a hex string.  */
	String outputString = bigInt.toString(16);

	/* If the number of characters is odd, then prefix a zero.  */
	if (outputString.length( ) % 2 == 1)
	    outputString = "0" + outputString;

	/* Return the result.  */
	return(outputString);
	}
    }

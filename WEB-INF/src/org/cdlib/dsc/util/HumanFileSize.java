/* ------------------------------------
 *
 * Project:	OAC 4.0
 *
 * Task:	To provide a static method that will convert the size of
 *		a file to a human-readable string.
 *
 * Name:	HumanFileSize
 *
 * Note:	This will be used by our XSLT, so I'm not sure whether it
 *		will be passing the file size as an Integer, as a Long, or
 *		as a String.  That's the reason for there being three
 *		static methods here.
 *
 * Note:	If the input is not a valid file size, the method returns
 *		the zero-length string.
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
 *		2008/9/18 - MAR - Stictly less than 512 is probably better
 *			than less than or equal to 511.
 * ------------------------------------
 */

package org.cdlib.dsc.util;

import java.text.DecimalFormat;
import java.text.FieldPosition;

public class HumanFileSize {

    public static void main(String[ ] arg) {
	int i;
	String results;

	for (i = 0; i < arg.length; i++) {
	    results = humanFileSize(arg[i]);
	    System.out.println("input = \"" + arg[i] + "\", output = \"" +
		results + "\"");
	    }
	}

    /* The static methods which are the raisons d'etre of this class.  */
    public static String humanFileSize(String inputFileSize) {
	/* Attempt to convert the string input to a long integer.  */
	Long longFileSize;
	longFileSize = new Long(0);
	try {
	    longFileSize = new Long(inputFileSize);
	    }
	catch (Exception e) {
	    /* If the parsing failed, the input is not a valid integer,
	     * so return the zero-length string.
	     */
	    return("");
	    }

	/* Pass the long integer value to the other static method.  */
	return(humanFileSize(longFileSize));
	}

    public static String humanFileSize(Integer intFileSize) {
	/* I thought Java would promote an Integer to a Long, but I guess
	 * not.  I have to do it myself.
	 */
	return(humanFileSize(intFileSize.longValue( )));
	}

    public static String humanFileSize(Long longFileSize) {
	/* If the input is negative, return a zero-length string.  */
	if (longFileSize < 0) return("");

	/* If it's up to 512, use the number itself.  */
	if (longFileSize < 512) return(longFileSize.toString( ));

	/* Provide a place to put the result of the division.  */
	double doubleBytes;

	/* We want at most two digits to the right of the decimal point.  */
	DecimalFormat outputFormat = new DecimalFormat("0.00");

	/* Provide a place to put the converted value.  */
	StringBuffer outputStrBuf = new StringBuffer( );

	/* Provide a "FieldPosition" object.  It looks like it's returned
	 * by the "format( )" method, but I don't really care about it.
	 * I haven't been able to find an example of how to use it, so
	 * I'll just try using zero, and see what that does.
	 */
	FieldPosition fieldPos = new FieldPosition(0);

	/* If it's up to 1024 * 512, express in terms of kilobytes.  */
	if (longFileSize < (1024L * 512L)) {
	    doubleBytes = longFileSize.doubleValue( ) / 1024.0;
	    outputFormat.format(doubleBytes, outputStrBuf, fieldPos);
	    return(outputStrBuf.toString( ) + " Kb");
	    }

	/* If it's up to 1024 * 1024 * 512, express in terms of megabytes.  */
	if (longFileSize < (1024L * 1024L * 512L)) {
	    doubleBytes = longFileSize.doubleValue( ) / (1024.0 * 1024.0);
	    outputFormat.format(doubleBytes, outputStrBuf, fieldPos);
	    return(outputStrBuf.toString( ) + " Mb");
	    }

	/* If it's up to 1024 * 1024 * 1024 * 512, express in terms of
	 * gigabytes.
	 */
	if (longFileSize < (1024L * 1024L * 1024L * 512L)) {
	    doubleBytes = longFileSize.doubleValue( ) / (1024.0 * 1024.0 *
		1024.0);
	    outputFormat.format(doubleBytes, outputStrBuf, fieldPos);
	    return(outputStrBuf.toString( ) + " Gb");
	    }

	/* If it's up to 1024 * 1024 * 1024 * 1024 * 512, express in terms of
	 * terabytes.
	 */
	if (longFileSize < (1024L * 1024L * 1024L * 1024L * 512L)) {
	    doubleBytes = longFileSize.doubleValue( ) / (1024.0 * 1024.0 *
		1024.0 * 1024.0);
	    outputFormat.format(doubleBytes, outputStrBuf, fieldPos);
	    return(outputStrBuf.toString( ) + " Tb");
	    }

	/* If it's up to 1024 * 1024 * 1024 * 1024 * 1024 * 512, express in
	 * terms of petabytes.
	 */
	if (longFileSize < (1024L * 1024L * 1024L * 1024L * 1024L * 512L)) {
	    doubleBytes = longFileSize.doubleValue( ) / (1024.0 * 1024.0 *
		1024.0 * 1024.0 * 1024.0);
	    outputFormat.format(doubleBytes, outputStrBuf, fieldPos);
	    return(outputStrBuf.toString( ) + " Pb");
	    }

	/* Express in exabytes.  A long integer can be at most 2**63 - 1,
	 * and that's about 9 exabytes, so we don't need to go higher.
	 */
	doubleBytes = longFileSize.doubleValue( ) / (1024.0 * 1024.0 *
		1024.0 * 1024.0 * 1024.0 * 1024.0);
	outputFormat.format(doubleBytes, outputStrBuf, fieldPos);
	return(outputStrBuf.toString( ) + " Eb");
	}
    }

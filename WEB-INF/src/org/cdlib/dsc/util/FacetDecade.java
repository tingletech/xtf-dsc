/* ------------------------------------
 *
 * Project:	OAC 4.0
 *
 * Task:	To provide a static method that can take a string, interpret
 *		the values within it as dates, and generate a list of decades
 *		that span those dates.
 *
 * Name:	FacetDecade
 *
 * Command line parameters:  (when invoked from the command line, so that
 *		the "static void main" method is invoked)
 *		any number of parameters, each is passed to the static
 *		facet decade method one at a time.
 *		
 * Author:	Michael A. Russell
 *
 * Revision History:
 *		2008/5/7 - MAR - Initial writing
 *		2008/5/7 - bct - added package, tweaked output
 *		2008/9/15 - MAR - It looks like Saxon is choking on
 *			when the output is the zero-length string.
 *			Always return valid XML.
 *		2009/3/4 - MAR - Ignore year "0000".  Use the current
 *			year as the absolute maximum.  Ignore any year
 *			less than 1000.
 * ------------------------------------
 */

package org.cdlib.dsc.util;

import java.util.Calendar;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class FacetDecade {

    public static void main(String[ ] arg) {
	int i;
	String results;

	for (i = 0; i < arg.length; i++) {
	    results = facetDecade(arg[i]);
	    System.out.println("input = \"" + arg[i] + "\", output = \"" +
		results + "\"");
	    }
	}

    /* The static method which is the heart.  */
    public static String facetDecade(String input) {
	/* At this point, all we're seeking is a sequence of exactly 4
	 * decimal digits.  Find all of them in the string, and keep
	 * track of the minimum and maximum values.
	 *
	 * The string we seek must not have a digit preceding it, and must
	 * not have a digit following it.  (The lookbehind and lookahead
	 * assertions, while within parentheses, are not "capturing".)
	 */
	Pattern p = Pattern.compile("(?<!\\d)(\\d{4})(?!\\d)");
	Matcher m = p.matcher(input);

	/* Get the current date and time.  */
	Calendar now = Calendar.getInstance( );

	/* Set a reasonable minimum and maximum, given that our strings
	 * are exactly 4 decimal digits.
	 */
	int min, max;
	min = 10000;
	max = -1;

	/* Process the matches.  */
	while (m.find( )) {
	    /* Retrieve the string matched by the pattern within the
	     * second set of parens.  (It is first group, group 1,
	     * because the lookbehind and lookahead assertions, while
	     * within parentheses, are not "capturing".)
	     */
	    String syear = m.group(1);

	    int iyear = Integer.parseInt(syear);

	    /* If it's "0000", ignore it.  */
	    /* if (iyear == 0) continue; */

	    /* If the year is less than 1000, ignore it.  */
	    if (iyear < 1000) continue;

	    /* If the year is greater than the current year, use the
	     * current year.
	     */
	    if (iyear > now.get(Calendar.YEAR)) iyear = now.get(Calendar.YEAR);

	    if (iyear < min) min = iyear;
	    if (iyear > max) max = iyear;
	    }

	/* If we didn't find any years, don't return anything.  */
	if (max < 0) return("<decades></decades>");

	/* Set the minimum to a decade boundary.  */
	min = (min / 10) * 10;

	/* Start off the output string we'll want.  */
	String facets = "<decades>";

	/* Build the set of decades.  */
	for (; min <= max; min += 10)
		facets += "<decade>" + min + "s</decade>";
	
	/* Put on the closing.  */
	facets += "</decades>";

	return(facets);
	}
    }

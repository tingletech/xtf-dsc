/*
 * Created on Aug 5, 2005
 *
 */
package org.cdlib.xtf.marc;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * @author Colleen Whitney
 * 
 */
public class SysDataGrabber {
    private FileWriter localIDFileWriter;
    private FileWriter isbnFileWriter;
    private FileWriter OCLCFileWriter;

    
    public SysDataGrabber(String outDir, int numToSkip) throws IOException {
        DateFormat df = new SimpleDateFormat("yyyy_MM_dd");
        String date = df.format(new Date());
        
        String localIDFileName = date + "_" + numToSkip + "_localID" + ".txt";
        String isbnFileName = date + "_" + numToSkip + "_isbn" + ".txt";
        String OCLCFileName = date + "_" + numToSkip + "_OCLC" + ".txt";

        try {
            localIDFileWriter = new FileWriter( new File(outDir+localIDFileName));
            localIDFileWriter.write("sysID\tlocalID\tmaintCode\n");
            localIDFileWriter.flush();
            
            isbnFileWriter = new FileWriter( new File(outDir+isbnFileName));
            isbnFileWriter.write("sysID\tisbn\n");
            isbnFileWriter.flush();
            
            OCLCFileWriter = new FileWriter( new File(outDir+OCLCFileName));
            OCLCFileWriter.write("sysID\tOCLC\n");
            OCLCFileWriter.flush();
        }
       
        catch(IOException e) {
            System.out.println("Unable to create the data file.");
            return;
        }
    }

 
    public void writeMoreData(String mods, String sysID) {
        
        writeLocalInfo(mods,sysID);
         
        writeIsbn(mods,sysID);
        
        writeOCLC(mods,sysID);
     
    }

 	public void writeLocalInfo(String mods, String sysID) {
        	String localinfo = getFieldValue(mods,"<recordIdentifier source=\"");

      		if (!localinfo.equals("")){
	
			String[] result = localinfo.split("\">");

			if (result.length==2) {
				String localID=result[1];
				String maintcode=result[0];	
	
              			try {
					localIDFileWriter.write(sysID + "\t" + localID + "\t" + maintcode + "\n");
                    			localIDFileWriter.flush();



				} catch (IOException e) {
                  			System.out.println("Could not write to the local info files (sysID: " + sysID + ").");
                  			return;
              			}

			} else return;
      		}
    	}
    

	public void writeIsbn(String mods, String sysID) {
        	String isbn = getFieldValue(mods,"<identifier type=\"isbn\">");
      
      		if (!isbn.equals("")){
	      	try {
	            isbnFileWriter.write(sysID + "\t" + isbn + "\n");
	            isbnFileWriter.flush();
	
	      	} catch (IOException e) {
	          System.out.println("Could not write to the isbn file (sysID: " + sysID + ").");
	          return;
	      	}
      }
    }

    
    public void writeOCLC(String mods, String sysID) {
        String oclcNum = getFieldValue(mods,"<identifier type=\"OCLC\">");
        
      
      if (!oclcNum.equals("")){
	      try {
	            OCLCFileWriter.write(sysID + "\t" + oclcNum + "\n");
	            OCLCFileWriter.flush();
	
	      } catch (IOException e) {
	          System.out.println("Could not write to the OCLC file (sysID: " + sysID + ").");
	          return;
	      }
      }
    }
     
    public String getFieldValue(String mods, String pattern) {
        
        int p1 = mods.indexOf( pattern );
        if( p1 < 0 ) {
            
            return "";

        }
        int p2 = mods.indexOf( '<', p1+pattern.length() );
        if( p2 < 0 ) {
            
            return "";
        }
        String value = mods.substring(p1 + pattern.length(), p2).trim();

        
        return value;
        
    }

}

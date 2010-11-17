package org.cdlib.xtf.cms;

/**
 * Copyright (c) 2004, Regents of the University of California
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *   this list of conditions and the following disclaimer in the documentation 
 *   and/or other materials provided with the distribution.
 * - Neither the name of the University of California nor the names of its
 *   contributors may be used to endorse or promote products derived from this 
 *   software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 */

import java.io.IOException;
import java.io.StringReader;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.stream.StreamResult;

import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.tree.TreeBuilder;

import org.cdlib.xtf.crossQuery.CrossQuery;
import org.cdlib.xtf.crossQuery.QueryRoute;
import org.cdlib.xtf.servletBase.TextConfig;
import org.cdlib.xtf.textEngine.QueryProcessor;
import org.cdlib.xtf.textEngine.QueryRequest;
import org.cdlib.xtf.textEngine.QueryResult;
import org.cdlib.xtf.util.AttribList;
import org.cdlib.xtf.util.EasyNode;
import org.cdlib.xtf.util.Tester;
import org.cdlib.xtf.util.XMLFormatter;
import org.cdlib.xtf.util.XMLWriter;
import org.cdlib.xtf.util.XTFSaxonErrorListener;

/**
 * The CMS servlet coordinates the process of parsing a URL query,
 * activating the textEngine to find all occurrences, and finally formatting
 * the results.
 */
public class CMS extends CrossQuery
{
    // inherit JavaDoc
    public String getConfigName() { return "conf/cms.conf"; }
    

    // inherit JavaDoc
    protected TextConfig readConfig( String configPath )
    {
        // Load the configuration file.
        config = new CMSConfig( this, configPath );
        
        // And we're done.
        return config;
    } // readConfig()


    // inherit JavaDoc
    public TextConfig getConfig() { return config; }

        
    // inherit JavaDoc
    public String getServletInfo() {
        return "CMS servlet";
    } // getServletInfo()

    
    // inherit JavaDoc
    protected void apply( AttribList          attribs,
                          HttpServletRequest  req, 
                          HttpServletResponse res )
        throws Exception
    {
        // Make a default route, but set up to do CQL parsing on the query
        // parameter instead of the default tokenization.
        //
        QueryRoute route = QueryRoute.createDefault( config.queryParserSheet );
        
        // Generate a query request document from the queryParser stylesheet.
        QueryRequest queryReq = runQueryParser( req, res, route, attribs );
        if( queryReq == null )
            return;
        
        // Process it to generate result document hits
        QueryProcessor proc     = createQueryProcessor();
        QueryResult    result   = proc.processRequest( queryReq );
        
        // Convert from XTF format to CMS format. Include the <parameters> 
        // block and the actual query request for the stylesheet's reference.
        //
        Result cmsOut;
        if( queryReq.displayStyle == null ) {
            res.setContentType("text/xml");
            cmsOut = new StreamResult( res.getOutputStream() );
        }
        else
            cmsOut = new TreeBuilder();
        
        convertXTFToCMS( req, attribs, result, 
                         queryReq.parserInput + queryReq.parserOutput,
                         cmsOut );
        
        String step = req.getParameter( "debugStep" );
        if( queryReq.displayStyle != null && "4b".equals(step) ) {
            res.setContentType("text/xml");
            res.getOutputStream().println( XMLWriter.toString(((TreeBuilder)cmsOut).getCurrentRoot()) );
            return;
        }
        
        // If a CMS formatting stylesheet was specified, run the results
        // through that.
        //
        if( queryReq.displayStyle != null ) {
            formatCMS( queryReq.displayStyle, attribs,
                       ((TreeBuilder)cmsOut).getCurrentRoot(),
                       new StreamResult(res.getOutputStream()) );
        }
    } // apply()
    
    
    /** Add additional stuff to the usual debug step mode */
    protected String stepSetup( HttpServletRequest  req,
                                HttpServletResponse res ) 
        throws IOException
    {
        String stepStr = super.stepSetup( req, res );
        if( stepStr != null ) {
            stepStr = stepStr.replaceAll( "rows=\"195", "rows=\"215" );
            stepStr = stepStr.replaceAll( "crossQuery", "CMS" );
            String escapedPath = ((CMSConfig)config).xtfToCmsSheet.replaceAll( "\\\\", "/" );
            stepStr = stepStr.replaceAll( "raw search results, shown below",
                "raw search results, which were then fed through the XTF to CMS " +
                "stylesheet, <code><b>" + escapedPath +
                "</b></code>, with the results shown below" );
            stepStr = stepStr.replaceAll( "feeding the raw search results",
                "feeding the raw (CMS-style) search results" );
        }

        return stepStr;
    }
    

    /**
     * Uses a stylesheet to convert from XTF result format to CMS result format.
     * 
     * @param req         The HTTP request
     * @param attribs     Attribute form of the request
     * @param result      Query results to convert
     * @param extraStuff  Extra stuff to pass to the conversion stylesheet
     * @param out         Receives the converted results
     */
    private void convertXTFToCMS( HttpServletRequest req,
                                  AttribList         attribs,
                                  QueryResult        result,
                                  String             extraStuff,
                                  Result             out )
        throws Exception
    {
        // Locate the display stylesheet.
        Templates displaySheet = stylesheetCache.find( 
            ((CMSConfig)config).xtfToCmsSheet );

        // Make a transformer for this specific query.
        Transformer trans = displaySheet.newTransformer();

        // Stuff all the common config properties into the transformer in
        // case the query generator needs access to them.
        //
        stuffAttribs( trans, config.attribs );

        // Also stuff the URL parameters (in case stylesheet wants them)
        stuffAttribs( trans, attribs );

        // Add the special computed parameters.
        stuffSpecialAttribs( req, trans );

        // Make an input document for it based on the document hits.
        Source sourceDoc = result.hitsToSource( "CMSResult", extraStuff );

        // Make sure errors get directed to the right place.
        if( !(trans.getErrorListener() instanceof XTFSaxonErrorListener) )
            trans.setErrorListener( new XTFSaxonErrorListener() );

        // Do it!
        trans.transform( sourceDoc, out );
        
    } // convertXTFToCMS
    
    
    /**
     * Run the CMS formatted results through a stylesheet to create the
     * final servlet output.
     * 
     * @param displayStyle  Stylesheet to use for formatting
     * @param in            Source data
     * @param out           Where to send the formatted result
     */
    private void formatCMS( String displayStyle,
                            AttribList attribs,
                            Source in,
                            Result out )
        throws Exception
    {
        // Locate the display stylesheet.
        Templates displaySheet = stylesheetCache.find( displayStyle );

        // Make a transformer for this specific query.
        Transformer trans = displaySheet.newTransformer();

        // Stuff all the common config properties into the transformer in
        // case the query generator needs access to them.
        //
        stuffAttribs( trans, config.attribs );

        // Also stuff the URL parameters (in case stylesheet wants them)
        stuffAttribs( trans, attribs );

        // Make sure errors get directed to the right place.
        if( !(trans.getErrorListener() instanceof XTFSaxonErrorListener) )
            trans.setErrorListener( new XTFSaxonErrorListener() );

        // Do it!
        trans.transform( in, out );
        
    } // formatCMS
    
    
    /**
     * Break 'val' up into its component tokens and add elements for them.
     * Also tries to parse each parameter as a CMS query.
     * 
     * @param fmt formatter to add to
     * @param name Name of the URL parameter
     * @param val value to tokenize
     */
    protected void defaultTokenize( XMLFormatter fmt, String name, String val )
    {
        // First, tokenize normally.
        fmt.beginTag( "tokenized" );
        super.defaultTokenize( fmt, name, val );
        fmt.endTag();

        // Now pass the same value through our secondary parser that handles 
        // complex nested constructs.
        //
        CMSParser parser = new CMSParser( new StringReader(val) );
        fmt.beginTag( "parsed" );
        try {
            String parsedVal = parser.parse();
            fmt.rawText( parsedVal );
        }
        catch( ParseException e ) 
        {
            // Simply record the error, with some basic formatting modifications
            // to make it useful. If the parser cares, it can pass it on. However,
            // it may not care if this isn't actually a query field.
            //
            String message = e.getMessage();
            message = message.replaceAll( "\"<EOF>\"", "end of query" );
            message = message.replaceAll( "\\\\'", "&apos;" );
            message = message.replaceAll( "<", "[" );
            message = message.replaceAll( ">", "]" );
            message = message.replaceAll( "at line \\d+, ", "at " );
            fmt.beginTag( "error", 
                          "message='Error parsing field \"" + name + 
                          "\": " + message + "'" );
            fmt.endTag();
        }
        fmt.endTag();
    } // tokenize()

    /**
     * Called right after the raw query request has been generated, but
     * before it is parsed. Gives us a chance to stop processing here in
     * if an error tag has been generated.
     */
    protected boolean shuntQueryReq( HttpServletRequest req,
                                     HttpServletResponse res,
                                     Source queryReqDoc )
        throws IOException
    {
        // If it actually contains an error tag, throw an exception.
        EasyNode node = new EasyNode( (NodeInfo)queryReqDoc );
        scanForError( node );
        return super.shuntQueryReq( req, res, queryReqDoc );
    } // shuntQueryReq()
    
    
    /**
     * Scans the node and its descendants for an 'error' node. If found, we throw
     * an exception.
     * 
     * @param node    Node to scan
     */
    private void scanForError( EasyNode node ) 
    {
        // If the node matches what we're looking for, throw an exception.
        // directly.
        //
        if( "error".equals(node.name()) ) {
            String message = node.attrValue( "message" );
            throw new CMSParseException( message );
        }
        
        // Scan the children.
        for( int i = 0; i < node.nChildren(); i++ )
            scanForError( node.child(i) );
              
    } // scanForError()
    
      
    // inherit JavaDoc
    protected void genErrorPage( HttpServletRequest  req, 
                                 HttpServletResponse res, 
                                 Exception           exc )
    {
        // Switch the default output mode to HTML for the error page.
        res.setContentType("text/html");
        
        // And do the usual.
        super.genErrorPage( req, res, exc );
    } // genErrorPage()
    
    /**
     * Basic regression test
     */
    public static final Tester tester = new Tester("CMS") {
      
      void test( String in, String expectedOut )
      {
          CMSParser parser = new CMSParser( new StringReader(in) );
          try {
              String out = parser.parse();
              assert out.equals( expectedOut );
          }
          catch( ParseException e ) {
              String errMsg = e.getMessage();
              assert expectedOut.equals("ERROR");
          }
      }
  
      /**
       * Run the test.
       */
      protected void testImpl() {
          //Trace.setOutputLevel( Trace.debug );
          
          // Test plain term parsing
          test( "foo", "<term>foo</term>" );
          test( "foo bar", "ERROR" );
          
          // Make sure wildcards and digits are included in terms
          test( "foo*", "<term>foo*</term>" );
          test( "foo29", "<term>foo29</term>" );
          test( "298F", "<term>298F</term>" );
          
          // Test parsing of quoted phrases
          test( "\"foo\"", "<phrase><term>foo</term></phrase>" );
          test( "\"foo bar\"", "<phrase><term>foo</term><term>bar</term></phrase>" );
          test( "'foo'", "<phrase><term>foo</term></phrase>" );
          test( "'foo bar'", "<phrase><term>foo</term><term>bar</term></phrase>" );
          test( "\"foo'", "ERROR" );
          test( "'foo\"", "ERROR" );
          
          // Test OR
          test( "foo or bar", "<or><term>foo</term><term>bar</term></or>" );
          test( "foo or bar or wow", 
                "<or><term>foo</term><term>bar</term><term>wow</term></or>" );
    
          // Test AND
          test( "foo and bar", "<and><term>foo</term><term>bar</term></and>" );
          test( "foo and bar and wow", 
                "<and><term>foo</term><term>bar</term><term>wow</term></and>" );
    
          // Test precedence of OR vs AND
          test( "foo and bar or baz and wow", 
                "<or><and><term>foo</term><term>bar</term></and>" + 
                "<and><term>baz</term><term>wow</term></and></or>" );
          
          // Test NOT
          test( "foo not bar", 
                "<and><term>foo</term><not><term>bar</term></not></and>" );
          test( "foo not bar not baz",
                "<and><term>foo</term><not><term>bar</term></not><not><term>baz</term></not></and>" );
          
          // Test precedence of AND vs NOT
          test( "foo not bar and wow not baz",
                "<and><and><term>foo</term><not><term>bar</term></not></and>" +
                     "<and><term>wow</term><not><term>baz</term></not></and>" +
                "</and>" );
          
      } // testImpl()
    };
    
} // class CMS

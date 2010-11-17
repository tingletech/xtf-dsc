//////////////////////////////////////////////////////////////////////////////
//
// Recommend: handles sending off asynchronous recommendation requests, and
//            displaying the results.
//
//////////////////////////////////////////////////////////////////////////////

// Pre-declare URLs that might get assigned by the stylesheet.
var awsURL;
var localRecsURL;

// Keeps track of our asynchronous requests
var loaders = [];

// Current recommendation display test
var curText = "";

// Called when one of the loaders changes state. We update the text in the
// recommendation area appropriately.
//  
update = function() {
  var i;
  var nRecs = 0;
  
  // Display the status of each request.
  for( i = 0; i < loaders.length; i++ ) {
    var loader = loaders[i];
    var newText = "Searching for recommendations...";
    if( !loader.isLoading() ) {
      newText = loader.req.responseText;
      if( newText.indexOf("<li") < 0 ) newText = "<ol><li style=\"list-style-type: none\"><i>Sorry, no recommendations found.</i></li></ol>"
    }
    
    if( loader.curText != newText ) {
      var target = document.getElementById(loader.elementID);
      target.innerHTML = newText;
      loader.curText = newText;
    }
  } 
}

// The main entry point, called when the page has finished loaded. Fires off 
// the asynchronous recommendation requests.
//
window.onload = function() 
{
  var loader;

  // Always fire up a request for CDL recommendations.
  loader = new net.AsyncLoader(localRecsURL, update, update);
  loader.elementID = "recommendations";
  loaders[loaders.length] = loader;

  // If Amazon Web Services was requested, fire that up
  if( awsURL ) {
    loader = new net.AsyncLoader(awsURL, update, update);
    loader.elementID = "amazon";
    loaders[loaders.length] = loader;
  }

  // Do the first update, since the loaders might have called before it was
  // ready to go.
  //
  update();
}

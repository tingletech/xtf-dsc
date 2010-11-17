//////////////////////////////////////////////////////////////////////////////
//
// Assess: functions to handle the assessment interface tasks
//
//////////////////////////////////////////////////////////////////////////////

// Change xxQUOTExx to a real quote mark
mapQuotes = function( inStr )
{
    return inStr.replace( /xxQUOTExx/g, "\"" );
}

// Process selections made by the user
selectObjects = function() 
{
  // First, figure out which objects have been selected.
  var numChecked = 0;
  var checkedSysIDs = new Array(0);
  for( var i=1; i<arguments.length; i++ )
  {
      var sysID = arguments[i];
      var checkbox = document.getElementById( "keep_" + sysID );
      if( checkbox.checked ) {
         ++numChecked;
         checkedSysIDs[checkedSysIDs.length] = sysID;
      }
  }
  
  // Verify that the proper number have been selected.
  if( numChecked < 1 || numChecked > 3 ) {
     alert( "Please select 2-3 objects." );
     return;
  }
  
  // Form a request to go to the object view of the first object. Record the
  // selected sysIDs so they'll get saved to the session state.
  //
  var baseURL = mapQuotes( arguments[0] );
  var url = baseURL;
  url += "&object=" + checkedSysIDs[0] + "&selectedSysIDs=";
  for( var i=0; i<checkedSysIDs.length; i++ ) {
      if( i > 0 )
          url += "|";
      url += checkedSysIDs[i];
  }
  
  // Go to the new URL.
  window.location = url;
}


// Process radio button assessments
getSingleAnswer = function() 
{
  // First, figure out which objects have been selected.
  var answers = new Array(0);
  for( var i=1; i<arguments.length; i++ )
  {
      var sysID = arguments[i];
      for( var j = 1; j <= 5; j++ ) {
         var checkbox = document.getElementById( "answer_" + sysID + "_" + j );
         if( checkbox.checked )
             break;
      }
      if( j > 5 ) {
          alert( "Please answer all questions." );
          return;
      }
      answers[answers.length] = sysID + "::" + j;
  }
  
  // Form a request to go to the next page. Record the selected sysIDs 
  // and corresponding answers so they'll get saved to the session state.
  //
  var baseURL = mapQuotes( arguments[0] );
  var url = baseURL;
  url += "&assessAnswers=";
  for( var i=0; i<answers.length; i++ ) {
      if( i > 0 )
          url += "|";
      url += answers[i];
  }
  
  // Go to the new URL.
  window.location = url;
}

// Process check box assessments
getMultiAnswer = function() 
{
  // First, figure out which objects have been selected.
  var answers = new Array(0);
  for( var i=1; i<arguments.length; i++ )
  {
      var sysID = arguments[i];
      for( var j = 1; j <= 6; j++ ) {
         var checkbox = document.getElementById( "answer_" + sysID + "_" + j );
         if( checkbox.checked )
             break;
      }
      if( j > 6 ) {
          alert( "Please answer all questions." );
          return;
      }
      answers[answers.length] = sysID + "::" + j;
  }
  
  // Form a request to go to the next page. Record the selected sysIDs 
  // and corresponding answers so they'll get saved to the session state.
  //
  var baseURL = mapQuotes( arguments[0] );
  var url = baseURL;
  url += "&assessAnswers=";
  for( var i=0; i<answers.length; i++ ) {
      if( i > 0 )
          url += "|";
      url += answers[i];
  }
  
  // Go to the new URL.
  window.location = url;
}

// Process assessments made by the user
getLastAnswer = function( baseURL ) 
{
  // Which box was checked?
  for( var j = 1; j <= 5; j++ ) {
     var checkbox = document.getElementById( "answer_" + j );
     if( checkbox.checked )
         break;
  }
  if( j > 5 ) {
      alert( "Please answer the question." );
      return;
  }
  
  // Form a request to go to the next page. Record the answer so it'll
  // get saved to the session state.
  //
  var url = mapQuotes(baseURL) + "&assessAnswers=" + j;
  
  // Go to the new URL.
  window.location = url;
}

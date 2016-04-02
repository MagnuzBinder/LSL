// Hypergrid1
//
// Permits selecting and teleporting
// to hypergrid-enabled destinations.
//
// LSL for OpenSimulator
// by Magnuz Binder @hypergrid.org:8002 2016-04-02
// free to use, modify, and distribute
//
// Requires a data file at dstDataURL,
// LSL script permissions and OSSL permissions
// for osTeleportAgent.
// Data file format should be one line/destination,
// with pipe-separated parameters:
// parameter 2: destination name
// parameter 3: destination address host:port[:region]
// e.g.
// mpg|Metropolis Metaversum|hypergrid.org:8002|gibberish
// mbg|Binders World|binders.world:8002:welcome|more gibberish

// Destination data URL and HTTP parameters
string dataURL = "http://binders.world/gridstats/hga.txt";
list httpParams = [
    HTTP_METHOD, "GET",
    HTTP_MIMETYPE, "text/plain;charset=utf-8",
    HTTP_BODY_MAXLENGTH, 16384,
    HTTP_VERIFY_CERT, TRUE,
    HTTP_VERBOSE_THROTTLE, TRUE,
    //HTTP_CUSTOM_HEADER, "Pragma", "no-cache",
    HTTP_PRAGMA_NO_CACHE, TRUE
];
key httpReq;

// Global variables
list data;
key toucherId;
integer dialogChannel;
integer dialogHandle;

// Menu constants
integer menuDiv = 10;
string mainMenuOpt = "1-10";

// Main program
default
{
    // Start initializing
    state_entry()
    {
        // Set hover text
        llSetText("Hypergrid Transporter\ntouch to select destination and teleport", <1.0,0.0,1.0>, 1.0);
        // Create dialog channel
        dialogChannel = llFloor(-1-llFrand(2147483647));
        dialogHandle = llListen(dialogChannel, "", NULL_KEY, "");
    }

    // Handle touch
    touch_start(integer num)
    {
        // Store toucher
        toucherId = llDetectedKey(0);
        // Request all destination data
        httpReq = llHTTPRequest(dataURL, httpParams, "");
    }

    // Get data by HTTP
    http_response(key req, integer status, list metadata, string body)
    {
        // Skip if wrong request
        if ( req != httpReq )
            return;
        // Skip if wrong response
        if ( status != 200 )
            return;
        // Parse all destination data
        data = llParseString2List(body, ["\n"], []);
        // Forward touch
        llMessageLinked(LINK_THIS, dialogChannel, mainMenuOpt, toucherId);
    }

    // Forward dialog input
    listen(integer channel, string name, key id, string str)
    {
        llMessageLinked(LINK_THIS, channel, str, id);
    }

    // Handle touch and dialog input
    link_message(integer src, integer num, string str, key id)
    {
        // Parse input
        list tokens = llParseStringKeepNulls(str, [], ["-", " "]);
        // Sanity check input
        integer iHi = llGetListLength(data);
        integer i = (integer)llList2String(tokens, 0)-1;
        if ( i < 0 || i >= iHi )
            return;
        // Initialize variables
        list params;
        string dstName;
        string dstAddr;
        // Handle teleport request
        if ( llList2String(tokens, 1) == " " ) {
            // Parse destination data
            params = llParseStringKeepNulls(llList2String(data, i), ["|"], []);
            dstName = llList2String(params, 1);
            dstAddr = llList2String(params, 2);
            // Notify in chat
            llSay(0, "HG to "+dstName+", "+dstAddr);
            // Actual teleport only works with OSSL
            osTeleportAgent(id, dstAddr, <128.0,128.0,32.0>, <1.0,0.0,0.0>);
        }
        // Calculate present grid listing indices
        integer iBeg = i/menuDiv*menuDiv;
        integer iEnd = iBeg+menuDiv;
        if ( iEnd > iHi )
            iEnd = iHi;
        // Calculate previous grid listing indices
        integer i9Beg = iBeg-menuDiv;
        if ( i9Beg < 0 )
            i9Beg = (iHi-1)/menuDiv*menuDiv;
        integer i9End = i9Beg+menuDiv;
        if ( i9End > iHi )
            i9End = iHi;
        // Calculate next grid listing indices
        integer i1Beg = iBeg+menuDiv;
        if ( i1Beg >= iHi )
            i1Beg = 0;
        integer i1End = i1Beg+menuDiv;
        if ( i1End > iHi )
            i1End = iHi;
        // Initialize dialog data
        string dstOpt;
        string dialogText = "Destinations ordered by names alphabetically.\nSelect destination to hypergrid.";
        list dialogOpts = [];
        // Add dialog data for each present destination listed
        for ( i = iBeg; i < iEnd; i++ ) {
            // Parse destination data
            params = llParseStringKeepNulls(llList2String(data, i), ["|"], []);
            dstName = llList2String(params, 1);
            dstOpt = (string)(i+1)+" "+dstName;
            // Add dialog text for destination
            dialogText += "\n"+dstOpt;
            // Add dialog button for destination
            dialogOpts += [llGetSubString(dstOpt, 0, 16)];
        }
        // Add dialog buttons for previous and next destination listings
        dialogOpts += [(string)(i9Beg+1)+"-"+(string)(i9End), (string)(i1Beg+1)+"-"+(string)(i1End)];
        // Re-order dialog buttons downn-up to up-down
        dialogOpts =
            llList2List(dialogOpts, -3, -1)+
            llList2List(dialogOpts, -6, -4)+
            llList2List(dialogOpts, -9, -7)+
            llList2List(dialogOpts, -12, -10);
        // Send dialog
        llDialog(id, dialogText, dialogOpts, dialogChannel);
    }
}

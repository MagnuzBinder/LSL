// TerrainReader1
//
// Creates sculpts from terrains.
//
// LSL for OpenSimulator
// by Magnuz Binder @hypergrid.org:8002 2017-03-08
// public domain / CC0
//
// Requires a 256x256 m region,
// backend cgi at serviceURL and
// LSL script permissions.
// Returns a sculpt texture as TGA,
// to be uploaded and applied to a prim,
// with prim type: sculpt, sculpt type: plane.

// Service URL and HTTP parameters
string serviceURL="http://binders.world/cgi-bin/terrain2sculpt1.cgi";
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

// Constants and global variables
string chars = "0123456789abcdefghijklmnopqrstuvwxyz";
integer cHi;
string id;
integer max = 32;
integer row;
vector pos;
integer uStep = 32;
integer vStep = 2;
float size = 256.0;
float att = 2.0;

// Main program
default
{
    // Set some global variables
    state_entry()
    {
        cHi = llStringLength(chars);
    }

    // Handle touch
    touch_start(integer num)
    {
        // Owner only
        if ( llDetectedKey(0) != llGetOwner() )
            return;
        // Create unique file ID
        id = "";
        integer c;
        integer lHi = 8;
        integer l;
        for ( l = 0; l < lHi; l++ ) {
            c = llFloor(llFrand((float)cHi));
            id += llGetSubString(chars, c, c);
        }
        // Start reading by dummy HTTP request
        row = -vStep;
        pos = llGetPos();
        httpReq = llHTTPRequest(serviceURL, httpParams, "");
    }

    // Handle HTTP response
    http_response(key req, integer status, list metadata, string body)
    {
        // Skip if bad response
        if ( req != httpReq )
            return;
        if ( status != 200 )
            return;
        // Initialize terrain reading
        string data = "";
        integer c;
        row += vStep;
        // Read chunks while in terrain
        if ( row < max ) {
            // Set terrain chunk limits and some variables
            integer uLo = 0;
            integer uHi = max;
            integer u;
            integer u1;
            float x;
            integer vLo = row;
            integer vHi = row+vStep;
            integer v;
            integer v1;
            float y;
            integer w1;
            // For each row in chunk
            for ( v = vLo; v < vHi; v++ ) {
                y = (size-1.0)*(float)v/(float)(max-1);
                v1 = llRound(y);
                y = (float)v1-pos.y;
                // For each column in chunk
                for ( u = uLo; u < uHi; u++ ) {
                    x = (size-1.0)*(float)u/(float)(max-1);
                    u1 = llRound(x);
                    x = (float)u1-pos.x;
                    // Get terrain height
                    w1 = llRound(att*llGround(<x,y,0.0>));
                    if ( w1 > 255 )
                        w1 = 255;
                    // Hex-code integer position and height
                    c = u1 >> 4;
                    data += llGetSubString(chars, c, c);
                    c = u1 & 15;
                    data += llGetSubString(chars, c, c);
                    c = v1 >> 4;
                    data += llGetSubString(chars, c, c);
                    c = v1 & 15;
                    data += llGetSubString(chars, c, c);
                    c = w1 >> 4;
                    data += llGetSubString(chars, c, c);
                    c = w1 & 15;
                    data += llGetSubString(chars, c, c);
                }
            }
        }
        // Send HTTP requests with data (row<max)
        // Send HTTP request to finish (row=max)
        if ( row <= max ) {
            httpReq = llHTTPRequest(serviceURL+
                "?id="+llEscapeURL(id)+
                "&max="+llEscapeURL((string)max)+
                "&row="+llEscapeURL((string)row)+
                "&data="+data,
            httpParams, "");
        }
        // Link to sculpt texture
        if ( row == max ) {
            llLoadURL(llGetOwner(), "Get terrain sculpt map.\nUpload to OpenSimulator and apply to prim, with prim type: sculpt, sculpt type: plane.\nApply map tile as texture with repeats 32/31*<1,1,0>, offsets (1/31-1/255)*<0.5,0.5,0>, rotation 0.", serviceURL+"?id="+llEscapeURL(id));
        }
    }
}

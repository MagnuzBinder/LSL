////////////////////////////////////////////////////////////
// Visibility Toggler 1 in LSL v0.01
// by Magnuz Binder in hypergrid.org CC0 2015
//
// toggles visibility between two groups of linked prims
// using a dummy llSensorRepeat as a fast timer
////////////////////////////////////////////////////////////

// A (hopefully) non-matching key)
key NO_KEY = (key)"fedcba98-7654-3210-fedc-ba9876543210";

// Time in s between toggles
float period = 0.2;

// Names of prims in groups (change to actual names, 1 - many)
list names1 = ["Part 11", "Part 12", "Part 13"];
list names2 = ["Part 21", "Part 22", "Part 23"];

// Group parameter lists for invisible and visible
list params10;
list params11;
list params20;
list params21;

// Control variables
integer on;
integer part;

default
{
    state_entry()
    {
        // Reset parameter lists
        params10 = [];
        params11 = [];
        params20 = [];
        params21 = [];
        list params_0;
        list params_1;
        list params;
        string name;
        integer fHi;
        integer f;

        // Parse linked prims for targets
        integer lHi = llGetNumberOfPrims();
        integer l;
        for ( l = 1; l <= lHi; l++ ) {
            name = llGetLinkName(l);
            if ( llListFindList(names1+names2, [name]) < 0 )
                jump next_l;

            // Build parameter lists to make invisible and visible
            params_0 = [PRIM_LINK_TARGET, l];
            params_1 = [PRIM_LINK_TARGET, l];

            // Color and transparency needed per face
            fHi = llGetLinkNumberOfSides(l);
            for ( f = 0; f < fHi; f++ ) {
                params = llGetLinkPrimitiveParams(l, [PRIM_COLOR, f]);
                params_1 += [PRIM_COLOR, f]+params;
                params = llListReplaceList(params, [0.0], 1, 1);
                params_0 += [PRIM_COLOR, f]+params;
            }

            // Add to group parameter lists
            if ( llListFindList(names1, [name]) >= 0 ) {
                params10 += params_0;
                params11 += params_1;
            }
            if ( llListFindList(names2, [name]) >= 0 ) {
                params20 += params_0;
                params21 += params_1;
            }
            @next_l;
        }

        // Initialize control variables
        on = FALSE;
        part = 1;
    }

    touch_start(integer num)
    {
        // Start or stop toggling visibility on touch
        on = !on;
        if ( on )
            llSensorRepeat("", NO_KEY, AGENT, 0.1, PI, period);
        else
            llSensorRemove();
    }

    no_sensor()
    {
        // Toggle visibility of groups
        part = 3-part;
        if ( part == 1 )
            llSetLinkPrimitiveParamsFast(1, params11+params20);
        if ( part == 2 )
            llSetLinkPrimitiveParamsFast(1, params21+params10);
    }
}

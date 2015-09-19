////////////////////////////////////////////////////////////
// Online Messager in LSL v0.01
// by Magnuz Binder in hypergrid.org CC0 2015
// after an idea by Neovo Geesink
//
// sends chat on channel 8 from the owner
// to those on a list of recipients who are online
// uses llRequestAgentData since llKey2Name is only sim-wide
// uses explicit type casting from llList2String
// to avoid some implicit type casting problems
////////////////////////////////////////////////////////////

// List of IDs for message recipients (change to real IDs)
list recipientIds = [
    "00000000-0000-0000-0000-000000000000",
    "11111111-1111-1111-1111-111111111111",
    "22222222-2222-2222-2222-222222222222"
];

// Listener data
integer listenChannel = 8;
integer listenHandle;

// Help variables for persistence
string sender;
string message;
integer idNo;
key onlineReq;
key nameReq;

default
{
    state_entry()
    {
        // Listen for messages
        listenHandle = llListen(listenChannel, "", llGetOwner(), "");
    }

    on_rez(integer num)
    {
        // Reset script when rezzed
        llResetScript();
    }

    listen(integer channel, string name, key id, string str)
    {
        // Persist variables
        sender = name;
        message = str;
        idNo = 0;
        // Check recipient online status
        onlineReq = llRequestAgentData((key)llList2String(recipientIds, idNo), DATA_ONLINE);
    }

    dataserver(key req, string str)
    {
        // Get recipient name if online
        if ( req == onlineReq  &&  (integer)str ) {
            nameReq = llRequestAgentData((key)llList2String(recipientIds, idNo), DATA_NAME);
            return;
        }
        // Message recipient with name if online
        else if ( req == nameReq )
            llInstantMessage((key)llList2String(recipientIds, idNo), "From "+sender+" to " +str+": "+message);
        // Check next recipient online status
        idNo++;
        if ( idNo < llGetListLength(recipientIds) )
            onlineReq = llRequestAgentData((key)llList2String(recipientIds, idNo), DATA_ONLINE);
    }
}

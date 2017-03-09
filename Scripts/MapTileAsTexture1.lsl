// MapTileAsTexture1
//
// Applies a map tile as texture
// on a terrain sculpt prim.
//
// LSL for OpenSimulator
// by Magnuz Binder @hypergrid.org:8002 2017-03-09
// public domain / CC0
//
// Requires LSL script permissions and
// OSSL permissions for osGetMapTexture.
// Terrain sculpts can be created by
// e.g. TerrainReader1 or similar.

// Main program
default
{
    state_entry()
    {
        // Get map tile for present region,
        // apply as texture to sculpted prim
        // with texture placement adjustments.
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXTURE, ALL_SIDES, osGetMapTexture(), 32.0/31.0*<1.0,1.0,0.0>, 1.0/31.0*<0.5,0.5,0.0>, 0.0]);
    }
}

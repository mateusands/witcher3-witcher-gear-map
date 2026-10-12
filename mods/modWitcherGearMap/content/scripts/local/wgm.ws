// Witcher Upgrade Gear Map. Adapted from Gwent Players Map 1.0.6.
// Learned diagram state is read from the vanilla player. No mod facts are written.
function wgm_Version() : string
{
    return "1.0.0";
}
struct wgm_Item
{
    var schematic : name;
    var ngpSchematic : name;
    var school : int;
    var tier : int;
    var piece : int;
    var english : string;
    var locKey : string;
}
struct wgm_Pin
{
    var id : int;
    var world : string;
    var x : float;
    var y : float;
    var hintKey : string;
    var hintEnglish : string;
    var items : array< wgm_Item >;
}
class wgm_Data
{
    public var pins : array< wgm_Pin >;
    public function Init()
    {
        pins.Clear();
        wgm_LoadData( this );
    }
    public function AddPin( id : int, world : string, x : float, y : float, hintKey : string, hintEnglish : string )
    {
        var pin : wgm_Pin;
        pin.id = id;
        pin.world = world;
        pin.x = x;
        pin.y = y;
        pin.hintKey = hintKey;
        pin.hintEnglish = hintEnglish;
        pins.PushBack( pin );
    }
    public function AddItem( schematic : name, ngpSchematic : name, school : int, tier : int, piece : int, english : string, locKey : string )
    {
        var item : wgm_Item;
        var pin : wgm_Pin;
        var idx : int = pins.Size() - 1;
        item.schematic = schematic;
        item.ngpSchematic = ngpSchematic;
        item.school = school;
        item.tier = tier;
        item.piece = piece;
        item.english = english;
        item.locKey = locKey;
        pin = pins[ idx ];
        pin.items.PushBack( item );
        pins[ idx ] = pin;
    }
    public function IsTracked( schematic : name ) : bool
    {
        var i, j : int;
        for ( i = 0; i < pins.Size(); i += 1 )
        {
            for ( j = 0; j < pins[ i ].items.Size(); j += 1 )
            {
                if ( pins[ i ].items[ j ].schematic == schematic || pins[ i ].items[ j ].ngpSchematic == schematic )
                {
                    return true;
                }
            }
        }
        return false;
    }
}
@addField( CR4Game ) var wgm_dataStore : wgm_Data;
@addMethod( CR4Game ) function wgm_GetData() : wgm_Data
{
    if ( !wgm_dataStore )
    {
        wgm_InitConfig();
        wgm_dataStore = new wgm_Data in this;
        wgm_dataStore.Init();
    }
    return wgm_dataStore;
}
function wgm_InitConfig()
{
    var config : CInGameConfigWrapper = theGame.GetInGameConfigWrapper();
    var changed : bool;
    if ( config.GetVarValue( 'wgm_Settings', 'wgm_ShowPins' ) == "" )
    {
        config.SetVarValue( 'wgm_Settings', 'wgm_ShowPins', "true" );
        changed = true;
    }
    if ( config.GetVarValue( 'wgm_Settings', 'wgm_HideObtained' ) == "" )
    {
        config.SetVarValue( 'wgm_Settings', 'wgm_HideObtained', "false" );
        changed = true;
    }
    if ( config.GetVarValue( 'wgm_Settings', 'wgm_Notify' ) == "" )
    {
        config.SetVarValue( 'wgm_Settings', 'wgm_Notify', "false" );
        changed = true;
    }
    if ( config.GetVarValue( 'wgm_Settings', 'wgm_IconStyle' ) == "" )
    {
        config.SetVarValue( 'wgm_Settings', 'wgm_IconStyle', "0" );
        changed = true;
    }
    if ( config.GetVarValue( 'wgm_Settings', 'wgm_Debug' ) == "" )
    {
        config.SetVarValue( 'wgm_Settings', 'wgm_Debug', "false" );
        changed = true;
    }
    if ( config.GetVarValue( 'wgm_Settings', 'wgm_School' ) == "" )
    {
        config.SetVarValue( 'wgm_Settings', 'wgm_School', "0" );
        changed = true;
    }
    if ( config.GetVarValue( 'wgm_Settings', 'wgm_Tier' ) == "" )
    {
        config.SetVarValue( 'wgm_Settings', 'wgm_Tier', "0" );
        changed = true;
    }
    if ( changed ) { theGame.SaveUserSettings(); }
}
function wgm_Loc( key : string, english : string ) : string
{
    var text : string = GetLocStringByKeyExt( key );
    if ( StrLen( text ) == 0 || StrBeginsWith( text, "#" ) )
    {
        return english;
    }
    return text;
}
function wgm_ConfigBool( key : name, fallback : bool ) : bool
{
    var value : string = theGame.GetInGameConfigWrapper().GetVarValue( 'wgm_Settings', key );
    if ( value == "" ) { return fallback; }
    value = StrLower( value );
    return value == "true" || value == "1";
}
function wgm_ConfigInt( key : name ) : int
{
    var value : string = theGame.GetInGameConfigWrapper().GetVarValue( 'wgm_Settings', key );
    if ( value == "" ) { return 0; }
    return StringToInt( value );
}
function wgm_WorldKey( path : string ) : string
{
    path = StrLower( path );
    if ( StrContains( path, "winter" ) ) { return ""; }
    if ( StrContains( path, "novigrad" ) ) { return "novigrad"; }
    if ( StrContains( path, "skellige" ) ) { return "skellige"; }
    if ( StrContains( path, "prolog_village" ) ) { return "prolog_village"; }
    if ( StrContains( path, "kaer_morhen" ) ) { return "kaer_morhen"; }
    if ( StrContains( path, "bob" ) ) { return "bob"; }
    return "";
}
function wgm_SchematicName( item : wgm_Item ) : name
{
    // NG+ diagrams must not be marked by the original campaign's learned recipes.
    if ( FactsQuerySum( "NewGamePlus" ) > 0 && IsNameValid( item.ngpSchematic ) )
    {
        return item.ngpSchematic;
    }
    return item.schematic;
}
function wgm_MarkerTitle( item : wgm_Item ) : string
{
    var text : string = wgm_Loc( "wgm_marker_title", "{school} School · {tier} {piece}" );
    var school, tier, piece : string;
    if ( item.school == 1 ) { school = "Cat"; }
    else if ( item.school == 2 ) { school = "Griffin"; }
    else if ( item.school == 3 ) { school = "Bear"; }
    else if ( item.school == 4 ) { school = "Wolf"; }
    else if ( item.school == 5 ) { school = "Viper"; }
    else { school = "Manticore"; }
    if ( item.tier == 1 ) { tier = "Basic"; }
    else if ( item.tier == 2 ) { tier = "Enhanced"; }
    else if ( item.tier == 3 ) { tier = "Superior"; }
    else if ( item.tier == 4 ) { tier = "Mastercrafted"; }
    else if ( item.tier == 5 ) { tier = "Grandmaster"; }
    else { tier = "Hearts of Stone"; }
    if ( item.piece == 1 ) { piece = "Steel Sword"; }
    else if ( item.piece == 2 ) { piece = "Silver Sword"; }
    else if ( item.piece == 3 ) { piece = "Crossbow"; }
    else if ( item.piece == 4 ) { piece = "Armor"; }
    else if ( item.piece == 5 ) { piece = "Gauntlets"; }
    else if ( item.piece == 6 ) { piece = "Trousers"; }
    else { piece = "Boots"; }
    text = StrReplace( text, "{school}", wgm_Loc( "preset_value_wgm_school_" + item.school, school ) );
    text = StrReplace( text, "{tier}", wgm_Loc( "preset_value_wgm_tier_" + item.tier, tier ) );
    return StrReplace( text, "{piece}", wgm_Loc( "wgm_piece_" + item.piece, piece ) );
}
function wgm_IconSuffix( school : int ) : string
{
    var style : int = wgm_ConfigInt( 'wgm_IconStyle' );
    if ( style != 1 && style != 2 ) { return ""; }
    if ( school == 1 ) { return "Cat"; }
    if ( school == 2 ) { return "Griffin"; }
    if ( school == 3 ) { return "Bear"; }
    if ( school == 4 ) { return "Wolf"; }
    if ( school == 5 ) { return "Viper"; }
    return "Manticore";
}
@wrapMethod( W3PlayerWitcher ) function AddCraftingSchematic( nam : name, optional isSilent : bool, optional skipTutorialUpdate : bool ) : bool
{
    var learned : bool;
    var text : string;
    // The 5.01 compiler only finds the wrappedMethod token in a statement, not in a
    // variable initializer.
    learned = wrappedMethod( nam, isSilent, skipTutorialUpdate );
    if ( learned && !isSilent && wgm_ConfigBool( 'wgm_Notify', false ) && theGame.wgm_GetData().IsTracked( nam ) )
    {
        text = wgm_Loc( "wgm_notify", "Diagram learned: {item}" );
        text = StrReplace( text, "{item}", GetLocStringByKeyExt( inv.GetItemLocalizedNameByName( nam ) ) );
        theGame.GetGuiManager().ShowNotification( text );
    }
    return learned;
}
@wrapMethod( CR4MapMenu ) function UpdateEntityPins( out flashArray : CScriptedFlashArray ) : void
{
    var data : wgm_Data;
    var mapManager : CCommonMapManager;
    var player : W3PlayerWitcher;
    var known : array< name >;
    var worldPath, worldKey : string;
    var i, j, added, shownItems : int;
    var school, tier, pinSchool : int;
    var hideObtained, obtained, allObtained, showDebug : bool;
    var pos, playerPos : Vector;
    var obj : CScriptedFlashObject;
    var item : wgm_Item;
    var description, itemText, pinType, debugText, pinTitle : string;
    var marker : C2dArray;

    wrappedMethod( flashArray );
    if ( !wgm_ConfigBool( 'wgm_ShowPins', true ) ) { return; }
    player = (W3PlayerWitcher)thePlayer;
    if ( !player ) { return; }
    data = theGame.wgm_GetData();
    known = player.GetCraftingSchematicsNames();
    mapManager = theGame.GetCommonMapManager();
    worldPath = mapManager.GetWorldPathFromAreaType( m_shownArea );
    worldKey = wgm_WorldKey( worldPath );
    if ( worldKey == "" ) { return; }
    school = wgm_ConfigInt( 'wgm_School' );
    tier = wgm_ConfigInt( 'wgm_Tier' );
    hideObtained = wgm_ConfigBool( 'wgm_HideObtained', false );
    showDebug = wgm_ConfigBool( 'wgm_Debug', false );
    playerPos = player.GetWorldPosition();
    for ( i = 0; i < data.pins.Size(); i += 1 )
    {
        if ( data.pins[ i ].world != worldKey ) { continue; }
        description = "";
        shownItems = 0;
        allObtained = true;
        for ( j = 0; j < data.pins[ i ].items.Size(); j += 1 )
        {
            item = data.pins[ i ].items[ j ];
            if ( item.tier == 5 && !theGame.GetDLCManager().IsEP2Available() ) { continue; }
            if ( item.tier == 6 && !theGame.GetDLCManager().IsEP1Available() ) { continue; }
            if ( school != 0 && school != item.school ) { continue; }
            if ( tier != 0 && tier != item.tier ) { continue; }
            obtained = known.Contains( wgm_SchematicName( item ) );
            if ( hideObtained && obtained ) { continue; }
            if ( shownItems == 0 )
            {
                pinTitle = wgm_MarkerTitle( item );
                pinSchool = item.school;
            }
            allObtained = allObtained && obtained;
            if ( shownItems > 0 ) { description += "<br>"; }
            itemText = wgm_Loc( player.inv.GetItemLocalizedNameByName( wgm_SchematicName( item ) ), item.english );
            description += itemText + " - ";
            if ( obtained ) { description += wgm_Loc( "wgm_obtained", "Diagram learned." ); }
            else { description += wgm_Loc( "wgm_not_obtained", "Diagram not learned yet." ); }
            shownItems += 1;
        }
        if ( shownItems == 0 ) { continue; }
        description += "<br>" + wgm_Loc( data.pins[ i ].hintKey, data.pins[ i ].hintEnglish );
        pinType = "WitcherGear";
        if ( allObtained ) { pinType = "WitcherGearObtained"; }
        pinType += wgm_IconSuffix( pinSchool );
        if ( wgm_ConfigInt( 'wgm_IconStyle' ) == 1 ) { pinType += "Ring"; }
        if ( shownItems > 1 ) { pinTitle += " (+" + ( shownItems - 1 ) + ")"; }
        pos = Vector( data.pins[ i ].x, data.pins[ i ].y, 0 );
        obj = GetMenuFlashValueStorage().CreateTempFlashObject( "red.game.witcher3.data.StaticMapPinData" );
        obj.SetMemberFlashUInt( "id", 1464287232 + data.pins[ i ].id );
        obj.SetMemberFlashUInt( "areaId", NameToFlashUInt( m_shownArea ) );
        obj.SetMemberFlashUInt( "journalAreaId", NameToFlashUInt( mapManager.GetJournalAreaByPosition( m_shownArea, pos ) ) );
        obj.SetMemberFlashNumber( "posX", pos.X );
        obj.SetMemberFlashNumber( "posY", pos.Y );
        obj.SetMemberFlashString( "type", pinType );
        obj.SetMemberFlashString( "filteredType", "WitcherGear" );
        obj.SetMemberFlashNumber( "radius", 0 );
        obj.SetMemberFlashBool( "isFastTravel", false );
        obj.SetMemberFlashBool( "isQuest", false );
        obj.SetMemberFlashBool( "isPlayer", false );
        obj.SetMemberFlashBool( "isUserPin", false );
        if ( IsCurrentAreaShown() ) { obj.SetMemberFlashNumber( "distance", VecDistanceSquared2D( playerPos, pos ) ); }
        else { obj.SetMemberFlashNumber( "distance", 0 ); }
        // One legend row counts locations. Each diagram keeps its own state in the tooltip.
        obj.SetMemberFlashString( "label", pinTitle );
        obj.SetMemberFlashString( "description", description );
        flashArray.PushBackFlashObject( obj );
        added += 1;
    }
    if ( showDebug )
    {
        debugText = wgm_Loc( "wgm_debug_message", "Witcher Gear {version}: {count} locations on {world}." );
        debugText = StrReplace( debugText, "{version}", wgm_Version() );
        debugText = StrReplace( debugText, "{count}", "" + added );
        debugText = StrReplace( debugText, "{world}", worldKey );
        marker = LoadCSV( "gameplay\gui_new\swf\worldmap\wgm_gear_icons.csv" );
        if ( !marker ) { debugText += " " + wgm_Loc( "wgm_missing_map", "Map icon bundle not found." ); }
        theGame.GetGuiManager().ShowNotification( debugText );
    }
}

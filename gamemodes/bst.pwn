//----------------------------------------------------------
//
//  Name: Basic Server Template (BST)
//  Description: This is a very simple script that does the basics that you'd expect from a server.
//               I developed this over a weekend of having nothing to do and haven't used it in a real-server environment.
//               I have not played this game in 4+ years, but I do enjoy programming in Pawno so I thought I'd make an open source project.
//               I have no interest in being an admin/developer on any server so please do not ask. If you need help, let me know; do not assume I'll write code for you. I will only advice you on how to do it.
//               This script was made to mess around with mates, so it went from a random/stunt GM to a RolePlay one. It has both features, just edit to what you need.
//  Authors: Aaron
//  URL: http://aaron-welsh.co.uk
//  Twitter: https://twitter.com/_aaronwelsh
//  GitHub: https://github.com/aarogrammer
//
// -------------------------DISCLAIMER-------------------------
//  BST is not a finished gamemode and never will be.
//  BST is here to help players create thier own SA-MP server.
//  This means that YOU can help improve this script for others.
// 	I take no responsibility if there is bugs in this script.
// 	Create an issue on GitHub and if I can, I will fix it.
//	This is on GitHub so that others can improve it.
// ------------------------------------------------------------
//
//
//----------------------------------------------------------

//Includes needed
#include <a_samp>
#include <core>
#include <float>
#include <sscanf2>
#include <a_mysql>
#include "../include/izcmd.inc"


#pragma tabsize 0 //Removes warnings that are not important

//----------------Definitions------------------//

//Colors - if you want to define a color, add it here.
#define white 0xFFFFFFFF
#define red 0xFF0000FF
#define orange 0xFF9900AA
#define green 0x33FF33AA
#define COLOR_WHITE         0xFFFFFFFF
#define COLOR_NORMAL_PLAYER 0xFFBB7777

//Dialoge
#define DIALOG_TELEPORT 1
#define DIALOG_REGISTER 2
#define DIALOG_LOGIN 3

//MySQL
#define db_host "127.0.0.1" //your host, usually localhost (127.0.0.1)
#define db_user "root" //your MySQL database username
#define db_pass "" //your MySQL database password
#define db_db "samp" //your MySQL database name

//-----------------------------------------//

//groups of data, easy way to modify constants quickly
enum playerInfo{
    logged,
    level,
    id,
    alevel
}

enum buildingsEnum{
	//building xyz cords
	Float:b_x,
	Float:b_y,
	Float:b_z,
	//interior xyz cords
	Float:b_ix,
	Float:b_iy,
	Float:b_iz,
	b_interior //interior set

}

//global variables
new dbhandle;
new sInfo[MAX_PLAYERS][playerInfo];
// An array of buildings with interiors. Just add to the list if you want more.
new bInfo[][buildingsEnum] = {
//bulding X         Y       Z   	Interior X      		Y           Z       ID
	{-19.1612,	1175.4408,	19.5634, 	378.026, 		-190.5155, 	1000.6328, 	17}, //cow place
	{13.8883,	1229.3590,	19.3414, 	244.411987, 	305.032989, 999.148437, 1}, //hotel room 1
	{13.8883,	1220.1478,	19.3387, 	302.180999,		300.722991,	999.148437,	4}, //hotel room 2
	{13.7326,	1210.6266,	22.5032,	244.411987, 	305.032989, 999.148437, 1}, //hotel room 3
	{13.8880,	1220.1233,	22.5032,	244.411987, 	305.032989, 999.148437, 1}, //hotel room 4
	{13.8875,	1228.9574,	22.5032,	244.411987, 	305.032989, 999.148437, 1}  //hotel room 5


};
new total_vehicles_from_files=0;


//Forwards
forward OnUserCheck(playerid);
forward OnPasswordResponse(playerid);

//stocks

//used to replace a string
stock strreplace(string[], find, replace)
{
    for(new i=0; string[i]; i++)
    {
        if(string[i] == find)
        {
            string[i] = replace;
        }
    }
	return replace;
}


//----------------------------------------------------------

main()
{
    print("\n---------------------------------------");
    print("The gamemode has started...............\n");
    print("---------------------------------------\n");
}

//----------------------------------------------------------

//Logic for when the gamemode starts
public OnGameModeInit()
{

    SetGameModeText("BST");
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    ShowNameTags(1); //True
    SetNameTagDrawDistance(40.0);
    EnableStuntBonusForAll(0); //Null
    DisableInteriorEnterExits(); //remove the yellow arrow things to enter/exit buildings, make our own way
    SetWeather(0); //EXTRASUNNY_LA, this is static but could easily be made dynamic
    SetWorldTime(12); //Time set to noon. Again, this is static but could be made dynamic.

    //AddPlayerClass(162,2495.0625,-1687.0334,13.5143,358.0464,0,0,0,0,0,0); //spawn location, cj's mumma house
    AddPlayerClass(162,9.3781,1222.6980,19.3464,134.5224,0,0,0,0,0,0); //player spawn in fort carson
    
    //object mapping - Kept really simple
	
	//car object mapping
	
	//Grove street
	CreateVehicle(481, 2497.1523, -1655.1219, 12.9200, 178.0000, -1, -1, 100); //bmx
	CreateVehicle(481, 2496.1353, -1654.9486, 12.9274, 178.0000, -1, -1, 100); //bmx
	CreateVehicle(481, 2498.1282, -1655.2997, 12.9274, 178.0000, -1, -1, 100); //bmx

    AddStaticVehicleEx(520,2504.1257,-1676.9163,14.3019,62.7200,-1, -1, 15); // first plane
    AddStaticVehicleEx(520,2505.3486,-1663.2703,14.1212,111.6702,-1, -1, 15); // second plane
    AddStaticVehicleEx(429,2491.9456,-1681.3020,13.0165,4.2274,-1, -1, 15); // banshee 1
    AddStaticVehicleEx(429,2488.2483,-1681.6946,13.0151,6.2221,-1, -1, 15); // banshee 2
    AddStaticVehicleEx(432,2479.5183,-1680.1135,13.3452,354.5234,-1, -1, 15); // rhino 1
    AddStaticVehicleEx(432,2464.0352,-1684.6555,13.5369,314.5980,-1, -1, 15); // rhino 2
    
    // Fort Carson Hotel
    AddStaticVehicleEx(506,10.4118,1233.6954,19.0474,90.7545,-1, -1, 15); // 1st car
	AddStaticVehicleEx(451,10.9596,1224.3494,19.0505,90.7647,-1, -1, 15); // 2nd car
	AddStaticVehicleEx(480,-13.0174,1218.9308,19.1261,270.9335,-1, -1, 15); // 3rd car
	AddStaticVehicleEx(600,-12.9322,1222.3958,19.0762,270.5302,-1, -1, 15); // 4th car
	AddStaticVehicleEx(549,-3.2907,1237.7736,19.0510,177.9776,-1, -1, 15); // 5th car
	AddStaticVehicleEx(602,4.4347,1237.8474,19.1527,185.4404,-1, -1, 15); // 6th car


    printf("Total vehicles from files: %d",total_vehicles_from_files); //may remove this
    
    //Load buildings, iterate arrays.
	for(new i=0; i<sizeof(bInfo); i++)
	{
		//          model  type         x               y               z
		CreatePickup(1559, 1, bInfo[i][b_x], bInfo[i][b_y], bInfo[i][b_z]); //loop through our bInfo variable and place our picksup at our defined buildings
		Create3DTextLabel("/enter to press Y", 0xFFFFFFFF, bInfo[i][b_x], bInfo[i][b_y], bInfo[i][b_z], 50.0, 0, 1); //display text on pickup

	}

    dbhandle = mysql_connect(db_host,db_user,db_db,db_pass); //connect to database
    return 1;
}
public OnGameModeExit()
{
    mysql_close(dbhandle); //close the connection between the gamemode and our database
    return 1;
}

//We'll check if a user is already registered or not. If they are, they need to enter the password for said account.
public OnUserCheck(playerid)
{   new num_rows,num_fields;
    cache_get_data(num_rows,num_fields,dbhandle);
    if(num_rows==0)
    {
        //Make them register
        ShowPlayerDialog(playerid,DIALOG_REGISTER,DIALOG_STYLE_PASSWORD,"{FFFFFF}Register","{3CB860}Welcome to the server \n{FFFFFF}It appears that you {FF0000}do not{FFFFFF} have an account. This server requires an account to play \nPlease register!","Register","Cancel");
    }
    else
    {
        //Username exists, make them login
        ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Login","Please enter your password:","Login","Cancel");
    }
    return 1;
}

public OnPlayerConnect(playerid)
{

    SendClientMessage(playerid,COLOR_WHITE,"Welcome to {FF9900}B{CCFFCC}S{333333}T");
    if(isAdmin(playerid, 3)){ //admin level 3+
    	SetPlayerColor(playerid,0x800080AA);
    }
    else if(isAdmin(playerid, 2)){ //admin level 2
    	SetPlayerColor(playerid,0x33FF33AA);
    }
	else if(!isAdmin(playerid,1)){
	    SetPlayerColor(playerid,0xFFFFFFFF);
	}
    
    new name[MAX_PLAYER_NAME], string[24+MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    format(string, sizeof(string), "%s has joined the server.", name);
    SendClientMessageToAll(0xC4C4C4FF, string);

    new qName[MAX_PLAYER_NAME],query[128];
    GetPlayerName(playerid,qName,sizeof(qName));
    format(query,sizeof(query),"SELECT id FROM user WHERE username='%s'",qName);
    mysql_function_query(dbhandle,query,true,"OnUserCheck","i",playerid);

    return 1;
}

//function to save player, called when player disconnected
savePlayer(playerid)
{
    if(sInfo[playerid][logged] == 0)return 1;
    //store level, money
    new query[128]; //new query
    //save current account info to database when disconnected
    format(query,sizeof(query),"UPDATE user SET level='%i',money='%i',alevel='%i' WHERE id='%i'",GetPlayerScore(playerid),GetPlayerMoney(playerid),sInfo[playerid][alevel],sInfo[playerid][id]);
    mysql_function_query(dbhandle,query,false,"",""); // send the info
    return 1;
}
resetPlayer(playerid)
{
    sInfo[playerid][level]=0;
    sInfo[playerid][logged]=0;
    sInfo[playerid][id]=0;
    sInfo[playerid][alevel]=0;
    return 1;
}
public OnPlayerDisconnect(playerid, reason)
{

    savePlayer(playerid);
    resetPlayer(playerid); //make sure database is the players record
    return 1;
}

// Let's do some funky key presses
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    //check if player is in a car, then allow nos when fire key clicked
    if(IsPlayerInAnyVehicle(playerid))
    {
        if (newkeys & KEY_NO)
        {
        cmd_nos(playerid, "");
        }
    }
    //check if player is in car, then fix it on button press
    if(IsPlayerInAnyVehicle(playerid))
    {
        if (newkeys & KEY_LOOK_BEHIND)
        {
        cmd_fix(playerid, "");
        }
    }
   	for (new i=0; i<sizeof(bInfo); i++) //iterate through pick ups
	{
	    if(IsPlayerInRangeOfPoint(playerid, 2, bInfo[i][b_x], bInfo[i][b_y], bInfo[i][b_z])){ //if in range to enter, allow to press "y" to enter
		    if(newkeys & KEY_YES)
		    {
				cmd_enter(playerid, "");
				SendClientMessage(playerid, white, "You have entered the building");
		    }
		}
  		if(IsPlayerInRangeOfPoint(playerid, 2, bInfo[i][b_ix], bInfo[i][b_iy], bInfo[i][b_iz])){ //if in range to exit, allow to press "y" to exit
		    if(newkeys & KEY_YES)
		    {
				cmd_exit(playerid, "");
 				SendClientMessage(playerid, white, "You have exited the building");
		    }
	    }
    }
    return 1;
}

//------------------------------------------------------
// COMMANDS

//Player help
COMMAND:help(playerid, params[])
{
   SendClientMessage(playerid, 0xFFFFFFFF, "These are the commands you can do!");
   SendClientMessage(playerid, 0xFFFFFFFF, "----------------------------------");
   SendClientMessage(playerid, 0xFFFFFFFF, "/teleport");
   SendClientMessage(playerid, 0xFFFFFFFF, "/die");
   SendClientMessage(playerid, 0xFFFFFFFF, "/enter");
   SendClientMessage(playerid, 0xFFFFFFFF, "/exit");
   SendClientMessage(playerid, 0xFFFFFFFF, "/ooc");
   SendClientMessage(playerid, 0xFFFFFFFF, "----------------------------------");
   return 1;
}
//Admin help
COMMAND:ahelp(playerid, params[])
{
   if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
   SendClientMessage(playerid, 0xFFFFFFFF, "These are the commands you can do depending on your level");
   SendClientMessage(playerid, 0xFFFFFFFF, "--------------------------------------------------------------------");
   SendClientMessage(playerid, 0xFFFFFFFF, "/kick");
   SendClientMessage(playerid, 0xFFFFFFFF, "/ban");
   SendClientMessage(playerid, 0xFFFFFFFF, "/warning");
   SendClientMessage(playerid, 0xFFFFFFFF, "/afk");
   SendClientMessage(playerid, 0xFFFFFFFF, "/back");
   SendClientMessage(playerid, 0xFFFFFFFF, "/setlevel");
   SendClientMessage(playerid, 0xFFFFFFFF, "/setadmin");
   SendClientMessage(playerid, 0xFFFFFFFF, "/jetpack");
   SendClientMessage(playerid, 0xFFFFFFFF, "/money");
   SendClientMessage(playerid, 0xFFFFFFFF, "/givemoney");
   SendClientMessage(playerid, 0xFFFFFFFF, "/restart");
   
   SendClientMessage(playerid, 0xFFFFFFFF, "/tp");
   SendClientMessage(playerid, 0xFFFFFFFF, "/veh");
   SendClientMessage(playerid, 0xFFFFFFFF, "/dveh - destroy the vehicle");
   SendClientMessage(playerid, 0xFFFFFFFF, "/weapon");
   SendClientMessage(playerid, 0xFFFFFFFF, "/tp");
   SendClientMessage(playerid, 0xFFFFFFFF, "/fix");
   SendClientMessage(playerid, 0xFFFFFFFF, "/nos");
   SendClientMessage(playerid, 0xFFFFFFFF, "/heal");
   SendClientMessage(playerid, 0xFFFFFFFF, "/rpg");
   SendClientMessage(playerid, 0xFFFFFFFF, "/ak47");
   SendClientMessage(playerid, 0xFFFFFFFF, "/minigun");
   SendClientMessage(playerid, 0xFFFFFFFF, "/dildo");
   SendClientMessage(playerid, 0xFFFFFFFF, "--------------------------------------------------------------------");
   return 1;
}

COMMAND:enter(playerid, params[])
{
	for (new i=0; i<sizeof(bInfo); i++)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 2, bInfo[i][b_x], bInfo[i][b_y], bInfo[i][b_z])) continue;//if not in range of any buildings ints we make, skip (continue) this loop iteration
     	SetPlayerPos(playerid, bInfo[i][b_ix], bInfo[i][b_iy], bInfo[i][b_iz]); //set the players position when entering building
     	SetPlayerInterior(playerid, bInfo[i][b_interior]); //set the interior
     	SetPlayerVirtualWorld(playerid, i); //set v world, increments throughout loop so can use same interiors again but not have same world
     	return 1;
	}
	return 1;
}

COMMAND:exit(playerid, params[])
{
	for (new i=0; i<sizeof(bInfo); i++)
	{
	    if(GetPlayerVirtualWorld(playerid) != i)continue; //if they aren't in a virtual world, skip loop iteration
	    if(!IsPlayerInRangeOfPoint(playerid, 2, bInfo[i][b_ix], bInfo[i][b_iy], bInfo[i][b_iz])) continue;//if not in range of exit point, skip loop iteration
     	SetPlayerPos(playerid, bInfo[i][b_x], bInfo[i][b_y], bInfo[i][b_z]); //ser the players position when entering building
     	SetPlayerInterior(playerid, 0); //set the interior
     	SetPlayerVirtualWorld(playerid, 0); //set v world, increments throughout loop so can use same interiors again but not have same world
     	return 1;
	}
	return 1;
}
//implemented in case this turns in to a roleplay server. OOC = Out Of Character.Comment out if not needed.
COMMAND:ooc(playerid, params[])
{
    new sendername[MAX_PLAYER_NAME], string[128];
    if(sscanf(params, "s", sendername)) return SendClientMessage(playerid, 0xFFFFFFFF, "Tip: /ooc <message>");
    GetPlayerName(playerid, sendername, sizeof(sendername));
    strreplace(sendername, '_', ' ');
	if(isAdmin(playerid, 3)) //if highest admin (whatever we decide for it to be, have the ooc chat display this
	{
	    format(string, sizeof(string), "((OOC: {ff0000}Community Manager {ffffff}%s: %s ))", sendername, params);
    	SendClientMessageToAll(COLOR_WHITE, string);
	}
	else if(isAdmin(playerid, 1)) //if normal admin, display this in ooc
	{
	 	format(string, sizeof(string), "((OOC: {FFFF00}Admin {ffffff}%s:%s ))", sendername, params);
	    SendClientMessageToAll(COLOR_WHITE, string);
	}
	else //display normal ooc message
	{
 		format(string, sizeof(string), "((OOC: %s: %s ))", sendername, params);
    	SendClientMessageToAll(COLOR_WHITE, string);
	}
    return 1;
}

COMMAND:veh(playerid, params[])
{
	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
    new vehid, vehcolor;

    if(sscanf(params, "ii", vehid, vehcolor))
    {
        SendClientMessage(playerid, 0xFFFFFFFF, "Tip: /veh <carid> <color>");
    }
   	else if (vehid < 400 || vehid > 611)
    {
        SendClientMessage(playerid, 0xff0000ff, "Tip: Invalid car id! [ Car ID's range from 400 - 611 ]");
    }
   	else if (vehcolor < 0 || vehcolor > 126)
    {
        SendClientMessage(playerid, 0xff0000ff, "Tip: Invalid color id! [ Color ID's range from 0 - 126 ]");
    }
    else
    {   //spawn the car just beside the player
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        CreateVehicle(vehid, x + 3, y, z, 0, vehcolor,vehcolor, -1);
        SendClientMessage(playerid, 0x00ff00ff, "Car spawned at your location!");
    }
    return 1;
}
COMMAND:dveh(playerid, params[])
{
	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
	
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, red, "You need to be in the car to delete it.");
	DestroyVehicle(GetPlayerVehicleID(playerid));
	SendClientMessage(playerid, green, "You have deleted the car");
	return 1;
}
COMMAND:weapon(playerid, params[])
{
	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
    new wepid;

    if(sscanf(params, "i", wepid))
    {
        SendClientMessage(playerid, 0xFFFFFFFF, "Tip: /weapon <weaponid>");
    }
    else if (wepid < 1 || wepid > 46)
    {
        SendClientMessage(playerid, 0xff0000ff, "Tip: Invalid weapon id! [ Weapon ID's range from 1 - 46 ]");
    }
    else
    {   //give the player the weapon
        GivePlayerWeapon(playerid, wepid, 1000);
        SendClientMessage(playerid, 0x00ff00ff, "Murica'");
    }
    return 1;
}


COMMAND:tp(playerid,params[])
{
	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
    new teleid;
    if(sscanf(params,"u",teleid))
    {
        return SendClientMessage(playerid, red, "Tip: /tp [playerid]");
    }
    if(!IsPlayerConnected(teleid))
    {
        return SendClientMessage(playerid, red, "Player is not connected");
    }

    if(teleid == INVALID_PLAYER_ID)
    {
        return SendClientMessage(playerid, red, "This isn't a valid player ID");
    }

    new Float:telex,Float:teley,Float:telez,int;
    GetPlayerPos(teleid,telex,teley,telez);
    int = GetPlayerInterior(teleid);

    if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        //teleport and bring your car
        new vid = GetPlayerVehicleID(playerid);
        SetVehiclePos(vid, telex, teley, telez+1);
        LinkVehicleToInterior(vid, int);
        return SendClientMessage(playerid, 0x00ff00ff, "You have been teleported [car]");
    }
    else
    {
        //teleport to player
        SetPlayerPos(playerid,telex,teley,telez+1);
        SetPlayerInterior(playerid,int);
        return SendClientMessage(playerid, 0x00ff00ff, "You have been teleported");
    }
}


//Vehicle cmds

COMMAND:fix(playerid, params[])
{
	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
    if(!IsPlayerInAnyVehicle(playerid))
    {
    return SendClientMessage(playerid,0xff0000ff,"You must be in a vehicle!");
    }
    RepairVehicle(GetPlayerVehicleID(playerid));
    SendClientMessage(playerid, 0xFFFFFFFF, "The vehicles has been repaired.");

    return CMD_SUCCESS;
}

COMMAND:nos(playerid, params[])
{
	if(!isAdmin(playerid,1))return false;  //if not admin, do nothing
    if(!IsPlayerInAnyVehicle(playerid))
    {
    return SendClientMessage(playerid,0xff0000ff,"You must be in a vehicle!");
    }


    AddVehicleComponent(GetPlayerVehicleID(playerid),1010);
    SendClientMessage(playerid,0x00ff00ff,"Nos added to your vehicle! Press ALT or left click to activate.");

    return CMD_SUCCESS;

}

COMMAND:die(playerid)
{
    SetPlayerHealth(playerid, 0);
    new name[MAX_PLAYER_NAME], string[24+MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(string, sizeof(string), "%s chose the easy way out.", name);
    SendClientMessageToAll(0xFFFFFFFF, string);
    return CMD_SUCCESS;
}

COMMAND:teleport(playerid,params[])
{
    ShowPlayerDialog(playerid,DIALOG_TELEPORT,DIALOG_STYLE_LIST,"Teleport","Spawn\nFarm","Teleport","Cancel"); //bring up dialog for easy spawn
    return 1;
}


//Function to check if admin, then do admin commands
isAdmin(playerid, a_level)
{
    if(sInfo[playerid][alevel]>=a_level) return 1; //check if admin
    
    return 0;
}
//GUNS
COMMAND:ak47(playerid, params[])
{
 	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
    GivePlayerWeapon(playerid, 30, 10000);
    SendClientMessage(playerid, 0xFFFFFFFF, "You have spawned an AK-47");
    return CMD_SUCCESS;
}
COMMAND:rpg(playerid, params[])
{
 	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
    GivePlayerWeapon(playerid, 35, 10000);
    SendClientMessage(playerid, 0xFFFFFFFF, "You have spawned an RPG.");
    return CMD_SUCCESS;
}
COMMAND:minigun(playerid, params[])
{
 	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
    GivePlayerWeapon(playerid, 38, 100000);
    SendClientMessage(playerid, 0xFFFFFFFF, "You have spawned a minigun.");
    return CMD_SUCCESS;
}
COMMAND:dildo(playerid, params[])
{
 	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
    GivePlayerWeapon(playerid, 10, 0);
    SendClientMessage(playerid, 0xFFFFFFFF, "You have spawned a didlo. Dirty.");
    return CMD_SUCCESS;
}
//heal
COMMAND:heal(playerid)
{
 	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
    new Float:health;
    GetPlayerHealth(playerid, health);
    if (health >= 100.0)
    {
        SendClientMessage(playerid, 0xff0000ff, "Seems like you have full health already?");
        return 1;
    }
    SetPlayerHealth(playerid, 100);
    SendClientMessage(playerid, 0xFFFFFFFF, "You have been healed");
    return CMD_SUCCESS;
}
//send a warning to a player
COMMAND:warning(playerid,params[])
{
	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
    new pID,text[128];
    if(sscanf(params,"us[128]",pID,text))return SendClientMessage(playerid,red,"Tip: /warning [playerid] [text]");
    SendClientMessage(pID,red,text);
    return 1;
}
//Set yourself as AFK. Stops you from dying!
COMMAND:afk(playerid, params[])
{
  if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
  new name[MAX_PLAYER_NAME], string[128]; //new name, carry 120 chars
  GetPlayerName(playerid, name, MAX_PLAYER_NAME); //Get name, assign to name.
  format(string, sizeof(string), "Admin: %s is now AFK", name); //format string to display
  SendClientMessageToAll(green, string); //Send message to everyone
  TogglePlayerControllable(playerid, 0); //lock the player still
  return 1;
}
//Set yourself as back, you can now move around.
COMMAND:back(playerid, params[])
{
	if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
 	new name[MAX_PLAYER_NAME], string[128]; //new name, carry 120 chars
 	GetPlayerName(playerid, name, MAX_PLAYER_NAME); //Get name, assign to name.
	format(string, sizeof(string), "Admin: %s is now back from AFK", name); //format string to display
 	SendClientMessageToAll(green, string); //Send message to everyone
 	TogglePlayerControllable(playerid, 1); //Unlock player - allow them to move again
 	return 1;
}
//Give yourself a jetpack
COMMAND:jetpack(playerid,params[])
{
    if(!isAdmin(playerid,2))return SendClientMessage(playerid,red,"You cannot do this.");  //check if admin, if not don't run cmd
    //get users name so we can log it
    new name[MAX_PLAYER_NAME], string[24+MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(string, sizeof(string), "%s spawned a jetpack. Their id: %i", name, playerid);
    printf(string);

    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
    SendClientMessage(playerid, 0xFFFFFFFF, "You have spawned a jetpack.");
    return CMD_SUCCESS;
}
//Give yourself money
COMMAND:money(playerid, params[])
{
    if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this."); //check if admin, if not don't run cmd
    new money;

    if(sscanf(params, "i", money)) //if no params, display tip
    {
        SendClientMessage(playerid, 0xFFFFFFFF, "Tip: /money <amount>");
    }
    else {
        GivePlayerMoney(playerid, money); //give the money asked for
        SendClientMessage(playerid, 0x00ff00ff, "$$$$$$$$$$$ Free moneyyyyyy $$$$$$$$$$$'");
    }
    return CMD_SUCCESS;
}
//Give someone money
COMMAND:givemoney(playerid, params[]) //give money to a certain player
{
    if(!isAdmin(playerid,1))return SendClientMessage(playerid,red,"You cannot do this."); //check if admin, if not don't run cmd
    new pID, money;

    if(sscanf(params, "ii", pID, money)) //if no params, display tip
    {
        SendClientMessage(playerid, 0xFFFFFFFF, "Tip: /money <playerid> <amount>");
    }
    else {
        GivePlayerMoney(pID, money); //give the money asked for
        SendClientMessage(pID, green, "$$$$$$$$$$$ Free moneyyyyyy $$$$$$$$$$$'");
		SendClientMessage(playerid, green, "Money given to player");
    }
    return CMD_SUCCESS;
}
//Set players level
COMMAND:setlevel(playerid, params[])
{
    if(!isAdmin(playerid,3))return SendClientMessage(playerid,red,"You cannot do this."); //check if admin, if not don't run cmd
    new pID, p_level;
    if(sscanf(params, "ui", pID, p_level)) return SendClientMessage(playerid,red,"Tip: /setlevel [playerid] [level]"); //incorect syntax
    sInfo[pID][level] = p_level; //set the level entered as the level to be inserted to db on leave
    savePlayer(pID); //save to database when player leaves
    SetPlayerScore(pID, p_level); //Actually give them the level in this session
    SendClientMessage(pID,green,"Your level has been changed");
    SendClientMessage(playerid,green,"You have change the users level.");
    return 1;
}
//Set admin level
COMMAND:setadmin(playerid, params[])
{
    if(!isAdmin(playerid,3))return SendClientMessage(playerid,red,"You cannot do this."); //check if admin, if not don't run cmd
    new pID, a_level;
    if(sscanf(params, "ui", pID, a_level)) return SendClientMessage(playerid,red,"Tip: /setadmin [playerid] [adminlevel]"); //incorect syntax
    sInfo[pID][alevel] = a_level; //set the admin level of player to be inserted to db on leave
    savePlayer(pID); //save to the databse
    SendClientMessage(pID,green,"Your admin level has been changed.");
    SendClientMessage(playerid,green,"You have changed the admin level.");
    return 1;
}
//Kick a player, give a reason
COMMAND:kick(playerid, params[])
{
    if(isAdmin(playerid,3)) { //check if admin, if not don't run cmd
        new PID;
        new reason[64];
        new str[128];
        new Playername[MAX_PLAYER_NAME], Adminname[MAX_PLAYER_NAME]; //players name
        GetPlayerName(playerid, Adminname, sizeof(Adminname));
        GetPlayerName(PID, Playername, sizeof(Playername));
        if(sscanf(params, "us[64]", PID,reason)) return SendClientMessage(playerid, white, "Tip: /kick [playerid] [reason]"); //give tip
        if(!IsPlayerConnected(PID)) // check if id is connected
            return SendClientMessage(playerid, red, "Player is not connected!");

        format(str, sizeof(str), "'%s' has been kicked by administrator '%s'. Reason: %s ", Playername, Adminname, reason); //format string
        SendClientMessageToAll(red, str); //let the server know
        format(str, sizeof(str), "You have been kicked by '%s'. Reason: '%s' ", Adminname, reason);
        SendClientMessage(playerid, red, str);
        Kick(PID); //kick the player
    }
    else //if not admin
    {
        SendClientMessage(playerid, red, "You cannot do this!"); //return this message
    }
    return 1;
}
COMMAND:ban(playerid, params[])
{
	if(isAdmin(playerid,3)) {
	 	new PID;
	 	new reason[64];
	  	new str[128];
    	new Playername[MAX_PLAYER_NAME], Adminname[MAX_PLAYER_NAME];
     	GetPlayerName(playerid, Adminname, sizeof(Adminname));
		GetPlayerName(PID, Playername, sizeof(Playername));
  		if(sscanf(params, "us[64]", PID,reason)) return SendClientMessage(playerid, white, "Tip: /ban [playerid] [reason]"); //Give tip
		if(!IsPlayerConnected(PID)) // check if id is connected
  			return SendClientMessage(playerid, white, "Player is not connected!");

		format(str, sizeof(str), "'%s' has been banned by administrator '%s'. Reason: %s ", Playername, Adminname, reason); //format the string we've defined to send the message, playername and adminname are used to receive the information about the names
		SendClientMessageToAll(red, str); //let the server know
  		Ban(PID); //Ban the player

        }
        else //if not admin
        {
            SendClientMessage(playerid, red, "You have to be level 5 to use that command!"); //return this message
        }
        return 1;
}
//restart server. Only allow high admins to do this.
COMMAND:restart(playerid,params[])
{
    if(!isAdmin(playerid, 3)) return SendClientMessage(playerid, red, "you're not an admin"); //check if admin, if not don't run cmd
    SendRconCommand("gmx"); //rcon command to restart game
    return 1;
}

//----------------------------------------------------------

public OnPlayerSpawn(playerid)
{
    if(IsPlayerNPC(playerid)) return 1;

    SetPlayerInterior(playerid,0);
    TogglePlayerClock(playerid,0);
    SetPlayerArmour(playerid, 100.0);

    //TogglePlayerClock(playerid, 0);
    return 1;
}

//----------------------------------------------------------

public OnPlayerDeath(playerid, killerid, reason)
{

    if(killerid != INVALID_PLAYER_ID)
    {
        SetPlayerScore(killerid, GetPlayerScore(killerid) + 1);
    }
    return 1;
}



//----------------------------------------------------------

public OnPlayerUpdate(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(IsPlayerNPC(playerid)) return 1;

    return 1;
}

SetPlayerMoney(playerid,money)
{
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid,money);
    return 1;
}


//check password

public OnPasswordResponse(playerid)
{
    new num_fields,num_rows;
    cache_get_data(num_rows,num_fields,dbhandle);
    if(num_rows==1)
    {
        //Password correct
        sInfo[playerid][logged] = 1;
        sInfo[playerid][level] = cache_get_field_content_int(0,"level",dbhandle);
        SetPlayerScore(playerid, sInfo[playerid][level]);
        sInfo[playerid][id] = cache_get_field_content_int(0, "id", dbhandle); //save player id
        SetPlayerMoney(playerid, cache_get_field_content_int(0, "money", dbhandle)); //give player money from accont
        sInfo[playerid][alevel] = cache_get_field_content_int(0, "alevel", dbhandle);
    }
    else
    {
        //Password false
        SendClientMessage(playerid,red,"This password does not match this account");
        ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Login","Please enter your password:","Login","Cancel");
    }
    return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{

    //login dialog logic
    if(dialogid==DIALOG_LOGIN)
    {
        if(response)
        {
            new name[MAX_PLAYER_NAME],query[128],password[35];
            GetPlayerName(playerid,name,sizeof(name));
            if(strlen(inputtext)>0)
            {
                mysql_escape_string(inputtext,password,dbhandle);
                format(query,sizeof(query),"SELECT * FROM user WHERE username='%s' AND password=SHA1('%s')",name,password);
                mysql_function_query(dbhandle,query,true,"OnPasswordResponse","i",playerid);
            }
            else
            {
                //nothing was inputed
                SendClientMessage(playerid,red,"Please enter your password");
                ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Login","Please enter your password:","Login","Cancel");
            }
        }
        else
        {
            Kick(playerid);
        }
        return 1;
    }

 	//dialog to regitser
    if(dialogid==DIALOG_REGISTER)
    {
        if(response)
        {
            new name[MAX_PLAYER_NAME],query[128],password[35];
            GetPlayerName(playerid,name,sizeof(name));
            //if input is more than 3, check if the password matched the account name
            if(strlen(inputtext)>3)
            {
                //register
                mysql_escape_string(inputtext,password,dbhandle); //escapes string, wee bit safer i guess
                format(query,sizeof(query),"INSERT INTO user (username,password, level, money) VALUES ('%s',SHA1('%s'), 1, 1000) ",name,password); //format of insert username and password to database and starting money, level
                mysql_function_query(dbhandle,query,false,"",""); //insert it
                SetPlayerMoney(playerid, 1000); //give registered player 1000 moneys
                SetPlayerScore(playerid, 1); //give them an id of 1

            }
            //else, if the pass is less than 4 chars show the dialog to log in again and a message
            else
            {
                SendClientMessage(playerid,red,"Your password must be at least 4 characlease provide a password"); //bring back dialog
                ShowPlayerDialog(playerid,DIALOG_REGISTER,DIALOG_STYLE_INPUT,"{FFFFFF}Register","{FF0000}Your password is less than 4 characters{FFFFFF}\nPlease enter a password that is at least 4 characters!","Register","Cancel");

            }
        }
        else
        {
            Kick(playerid); // if they pree cancel, kick.
        }
        return 1;
    }
	//list dialog of locations. WIll add a lot more soon for easy trasnporting
    if(dialogid==DIALOG_TELEPORT)
    {
        if(response)
        {
            if(listitem==0)
            {
                //Spawn
                SetPlayerPos(playerid,2495.0625,-1687.0334,13.5143);
            }
            if(listitem==1)
            {
                //Farm
                SetPlayerPos(playerid,0.0,0.0,6.0);
            }
        }
        else
        {
            SendClientMessage(playerid,red,"You have been disconnected");
        }
        return 1;
    }
    return 1;
}



public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    return 1;
}

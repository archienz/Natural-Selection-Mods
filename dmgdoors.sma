/*
DMG Doors v0.1
Copyright (C) 2007 Ian (Juan) Cammarata

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; go to http://www.opensource.org/licenses/gpl-license.php
*/
/*
*===============================================================================
*	DMG Doors v0.1
*	Created by Ian (Juan) Cammarata
*	http://ian.cammarata.us
*	AMXX 1.76d
*	5/2/2007 5:34:33 AM
*===============================================================================
*	Description:
*		When enabled this plugin adds damage to sliding doors, or sliding and hinged
*		doors.  The amount of damage dealt is also configurable.
*===============================================================================
*	Cvars: (* indicates default)
*		dmgdoors < 2 (all doors*) | 0 (disabled) | 1 (only sliding doors) >
*		dmgdoors_dmg < 9999 | ... > : How much damage the doors will do.
*/
#include <amxmodx>
#include <engine>

#define VERSION "0.1"

public pfn_keyvalue(ent){
	static old_ent=0,key_val[20],mode,dmg[6]
	new ent_class[1],key_name[1]
	
	if(!old_ent){
		mode=get_cvar_num("dmgdoors")
		get_cvar_string("dmgdoors_dmg",dmg,5)
		server_print("Debug: mode %d, dmg %s",mode,dmg)
	}
	else if(ent!=old_ent){
		if(equal(key_val,"func_door")&&mode>0)
			DispatchKeyValue(old_ent,"dmg",dmg)
		else if(equal(key_val,"func_door_rotating")&&mode>1)
			DispatchKeyValue(old_ent,"dmg",dmg)
		copy_keyvalue(ent_class,0,key_name,0,key_val,19)
	}
	
	old_ent=ent
}

public plugin_init(){
	register_plugin("DMG Doors",VERSION,"Ian Cammarata")
	register_cvar("dmgdoors_version",VERSION,FCVAR_SERVER)
	register_cvar("dmgdoors","2")
	register_cvar("dmgdoors_dmg","9999")
}
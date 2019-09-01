#include <amxmodx>
#include <engine>
#include <engine_stocks>
#include <fun>
public plugin_init() {
	register_plugin("AutoGlow","0.2","devicenull")
	new cc, hive, ccount, hcount
	cc = find_ent_by_class(0,"team_command")
	while (cc != 0) { 
		ccount++
		cc = find_ent_by_class(cc,"team_command")
	}
	hive = find_ent_by_class(0,"team_hive")
	while (hive != 0) {
		hcount++
		hive = find_ent_by_class(hive,"team_hive")
	}
	server_print("Glow: %i CC's and %i hives",ccount,hcount)
	if (ccount == 2 || hcount == 2) {
		register_event("ResetHUD","doglow","b")
		register_event("PlayHUDNot","glowb","b")
		glowb()
	}
}
public doglow(id) {
	set_task(Float:0.5,"glowme",id)
}
public glowme(id) {
	new team[32]
	get_user_team(id,team,32)
	if (equal(team,"marine1team") || equal(team,"alien1team"))
		set_user_rendering(id,kRenderFxGlowShell,0,0,255,kRenderNormal,10)
	if (equal(team,"marine2team") || equal(team,"alien2team"))
		set_user_rendering(id,kRenderFxGlowShell,0,255,0,kRenderNormal,10)
	if (equal(team,"undefinedteam") || strlen(team) == 0)
		set_user_rendering(id,kRenderFxNone,0,0,0,kRenderNormal,16)
}
public glowb() {
	glowall("team_command")
	glowall("team_armory")
	glowall("team_advarmory")
	glowall("team_hive")
	glowall("phasegate")
}
glowall(object[62]) {
	new team, obj
	obj = find_ent_by_class(obj,object)
	while (obj != 0) {
		team = entity_get_int(obj, EV_INT_team)
		if (equal(object,"team_armory")) {
			if (team == 1) 
				set_rendering(obj,kRenderFxGlowShell,0,0,255,kRenderNormal,10)
			if (team == 2)
				set_rendering(obj,kRenderFxGlowShell,0,255,0,kRenderNormal,10)
		}else{
			if (team == 1) 
				set_rendering(obj,kRenderFxGlowShell,0,0,255,kRenderNormal,10)
			if (team == 3)
				set_rendering(obj,kRenderFxGlowShell,0,255,0,kRenderNormal,10)
		}
		obj = find_ent_by_class(obj,object)
	}
}
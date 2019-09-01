// Savage Timmi's monster mod map cfg creator v1.0
//
// I just seen someone needing this and I needed it to so here it is.

///////********DO NOT CHANGE THIS*********///////////

#include <amxmodx>
#include <amxmisc>
#include <engine>

#define HMCHAN_PLAYERINFO 1089
new monstername[33]
new delay
new ammount

public makemapfile(id) {
  new vaultdata2[512] 
  new vaultdata1[512]
  new directory[200]
  new allowfilepath[251]
  
  new i_origin[3]
  new mapname[32]
  get_mapname(mapname,32)
  get_user_origin( id, i_origin )
  //
  //Writes the Precache.cfg for the map
 
  format(directory,199,"/addons/monster/config/%s_precache.cfg", mapname) 

  format ( vaultdata1, 511, "%s", monstername )
  write_file(directory,vaultdata1,-1)
  //
  // Writes the monster.cfg for the map
  format(allowfilepath,250,"/addons/monster/config/%s_monster.cfg", mapname) 
  format (vaultdata2, 511, " { ")
  write_file(allowfilepath,vaultdata2,-1)
 
  format (vaultdata2, 511, "origin/%d %d %d", i_origin[0], i_origin[1], i_origin[2] )
  write_file(allowfilepath,vaultdata2,-1)
  if (delay ==0 ) delay = 20
  format (vaultdata2, 511, "delay/%d" ,delay)
  write_file(allowfilepath,vaultdata2,-1)
  
  format (vaultdata2, 511, "monster/%s ",monstername)
  if ( ammount >= 1 ) write_file(allowfilepath,vaultdata2,-1)
  if ( ammount >= 2 ) write_file(allowfilepath,vaultdata2,-1)
  if ( ammount >= 3 ) write_file(allowfilepath,vaultdata2,-1)
  if ( ammount >= 4 ) write_file(allowfilepath,vaultdata2,-1)
  if ( ammount >= 5 ) write_file(allowfilepath,vaultdata2,-1)
  if ( ammount >= 6 ) write_file(allowfilepath,vaultdata2,-1)
  if ( ammount >= 7 ) write_file(allowfilepath,vaultdata2,-1)
  if ( ammount >= 8 ) write_file(allowfilepath,vaultdata2,-1)
  if ( ammount >= 9 ) write_file(allowfilepath,vaultdata2,-1)
   
  format (vaultdata2, 511, " } ")
  write_file(allowfilepath,vaultdata2,-1)

  set_hudmessage(75,200,200,-1.0,0.86,0,6.0,2.0,0.1,0.5,HMCHAN_PLAYERINFO)
  show_hudmessage(id, "Coordinates and monster name written.^n %s.cfg  in the monster config folder.^n /cstrike/addons/monster/configs.  ", mapname)

  return PLUGIN_CONTINUE 
}


public monsternames(id) {
	new szMenuBody9[250]
	new keys
	format(szMenuBody9, 249, "Choose a monster to add to the file:")
	add( szMenuBody9, 249, "^n1. Snark" )
	add( szMenuBody9, 249, "^n2. Head crab" )
	add( szMenuBody9, 249, "^n3. Bullsquid" )
	add( szMenuBody9, 249, "^n4. Bigmomma" )
	add( szMenuBody9, 249, "^n5. Hgrunt" )
	add( szMenuBody9, 249, "^n6. Hassassin" )
	add( szMenuBody9, 249, "^n7. scientist" )
	add( szMenuBody9, 249, "^n8. barney"  )
	add( szMenuBody9, 249, "^n^n9. Next page" )
	keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	show_menu( id, keys, szMenuBody9, 5 )
	return PLUGIN_CONTINUE
}

public monsternames2(id) {
	new szMenuBody9[250]
	new keys
	format(szMenuBody9, 249, "Remember you can only have 4 to 5 monsters a map:")
	add( szMenuBody9, 249, "^n1. Zombie" )
	add( szMenuBody9, 249, "^n2. Houndeye" )
	add( szMenuBody9, 249, "^n3. Islave" )
	add( szMenuBody9, 249, "^n4. Apache" )
	add( szMenuBody9, 249, "^n5. Agrunt" )
	add( szMenuBody9, 249, "^n6. Gargantua --- (not supported yet)" )
	add( szMenuBody9, 249, "^n7. Nihilanth --- (not supported yet)" )
	add( szMenuBody9, 249, "^n8. Icthyosaur -- (not supported yet)"  )
	add( szMenuBody9, 249, "^n9. Leech ------- (not supported yet)" )
	keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	show_menu( id, keys, szMenuBody9, 5 )
	return PLUGIN_CONTINUE
}

public selectdelay(id) {
	new szMenuBody9[250]
	new keys
	format(szMenuBody9, 249, "What delay do you want it to spawn at? :")
	add( szMenuBody9, 249, "^n1. 5 sec" )
	add( szMenuBody9, 249, "^n2. 10 " )
	add( szMenuBody9, 249, "^n3. 15 " )
	add( szMenuBody9, 249, "^n4. 20 " )
	add( szMenuBody9, 249, "^n5. 25 " )
	add( szMenuBody9, 249, "^n6. 30 " )
	add( szMenuBody9, 249, "^n7. 35 " )
	add( szMenuBody9, 249, "^n8. 40 "  )
	add( szMenuBody9, 249, "^n9. 45 " )
	keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	show_menu( id, keys, szMenuBody9, 5 )
	return PLUGIN_CONTINUE
}

public ammounttospawn(id) {
	new szMenuBody9[250]
	new keys
	format(szMenuBody9, 249, "How many monsters do you want to spawn here? :")
	add( szMenuBody9, 249, "^n1. 1 " )
	add( szMenuBody9, 249, "^n2. 2 " )
	add( szMenuBody9, 249, "^n3. 3 " )
	add( szMenuBody9, 249, "^n4. 4 " )
	add( szMenuBody9, 249, "^n5. 5 " )
	add( szMenuBody9, 249, "^n6. 6 " )
	add( szMenuBody9, 249, "^n7. 7 " )
	add( szMenuBody9, 249, "^n8. 8 " )
	add( szMenuBody9, 249, "^n9. 9 " )
	keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	show_menu( id, keys, szMenuBody9, 5 )
	return PLUGIN_CONTINUE
}

public ammounttospawnkey(id, key) {
	switch(key) {
		case 0: ammount = 1 
		case 1: ammount = 2 
		case 2: ammount = 3 
		case 3: ammount = 4
		case 4: ammount = 5 
		case 5: ammount = 6
		case 6: ammount = 7
		case 7: ammount = 8
		case 8: ammount = 9
	}
	makemapfile(id)
	return PLUGIN_CONTINUE
}

public selectdelaykey(id, key) {
	switch(key) {
		case 0: delay = 5 
		case 1: delay = 10 
		case 2: delay = 15 
		case 3: delay = 20
		case 4: delay = 25 
		case 5: delay = 30
		case 6: delay = 35
		case 7: delay = 40
		case 8: delay = 45
	}
	ammounttospawn(id)
	return PLUGIN_CONTINUE
}

public monsterkey(id, key) {
	switch(key) {
		case 0: monstername = "snark" 
		case 1: monstername = "headcrab" 
		case 2: monstername = "bullsquid" 
		case 3: monstername = "bigmomma"
		case 4: monstername = "hgrunt" 
		case 5: monstername = "hassassin"
		case 6: monstername = "scientist"
		case 7: monstername = "barney"
		case 8: monsternames2(id)
	}
	selectdelay(id)
	return PLUGIN_CONTINUE
}

public monsterkey1(id, key) {
	switch(key) {
		case 0: monstername = "zombie"
		case 1: monstername = "houndeye" 
		case 2: monstername = "islave" 
		case 3: monstername = "apache" 
		case 4: monstername = "agrunt" 
		case 5: monstername = "gargantua" 
		case 6: monstername = "nihilanth"
		case 7: monstername = "icthyosaur" 
		case 8: monstername = "leech" 
		
		case 9:	return PLUGIN_CONTINUE
	}
	selectdelay(id)
	return PLUGIN_CONTINUE
}

public writehandler(id) {
	set_hudmessage(75,200,200,-1.0,0.86,0,6.0,2.0,0.1,0.5,HMCHAN_PLAYERINFO)
	show_hudmessage(id, "Where ever you are standin will be the new coordinates^n for the monster you pick to place into you .cfg . ")
	monsternames(id)
	return PLUGIN_CONTINUE
}

public plugin_init() {
	register_concmd("say write", "writehandler")
	register_concmd("say makecfg", "writehandler")
	register_concmd("say makemapcfg", "writehandler")
	register_concmd("say createcfg", "writehandler")
	register_menucmd(register_menuid("Choose a monster to add to the file:"), 1023, "monsterkey" )
	register_menucmd(register_menuid("Remember you can only have 4 to 5 monsters a map:"), 1023, "monsterkey1" )
	register_menucmd(register_menuid("What delay do you want it to spawn at? :"), 1023, "selectdelaykey" )
	register_menucmd(register_menuid("How many monsters do you want to spawn here? :"), 1023, "ammounttospawnkey" )
	register_plugin("Monster Map Cfg creator", "1.0", "Timmi the savage")
}
/* CoBalancer
 *
 * MODIFIED FROM (c) 2005 Joe "Lord Skitch" Jackson
 * By SilverSquirrl of 2Frag4Fun.com   Thanks Lord Skitch for the original coding!
 *
 * This plugin is designed to balance combat maps, in which players 
 * will immediately choose specific upgrades at first chance, thereby 
 * eliminating the chance for the other team to get points.
 *
 *  
 *  This Plugin now will restrict a player from going Onos/Fade
 *  Until the player has reached the minimum level.  If below that lvl
 *  a message will be displayed, and the gestation will be denied. 
 *  Otherwise, the impulse will proceed as usual, with no messages.
 *
 * 
 *	Configuration cvars:
 *		combat_fade - The Min level to go Fade.
 *			Default: 7
 *		combat_onos - The Min Level to go Onos.
 *			Default: 10
 *
 *
 */

#define USE_PERCENTAGE		0	//	Uncoded, use minute percentage instead of hard coded mintues

#include <amxmodx>
#include <ns>
#include <engine>



enum {
	XP_LEVEL_1	=     0,
	XP_LEVEL_2	=   100,
	XP_LEVEL_3	=   250,
	XP_LEVEL_4	=   450,
	XP_LEVEL_5	=   700,
	XP_LEVEL_6	=  1000,
	XP_LEVEL_7	=  1350,
	XP_LEVEL_8	=  1750,
	XP_LEVEL_9	=  2200,
	XP_LEVEL_10	=  2700,
	XP_LEVEL_11	=  3250,
	XP_LEVEL_12	=  3850,
	XP_LEVEL_13	=  4500,
	XP_LEVEL_14	=  5200,
	XP_LEVEL_15	=  5950,
	XP_LEVEL_16	=  6750,
	XP_LEVEL_17	=  7600,
	XP_LEVEL_18	=  8500,
	XP_LEVEL_19	=  9450,
	XP_LEVEL_20	= 10450,
	XP_LEVEL_21	= 11500,
	XP_LEVEL_22	= 12600,
	XP_LEVEL_23	= 13800,
	XP_LEVEL_24	= 15050,
	XP_LEVEL_25	= 16350,
	XP_LEVEL_26	= 17750,
	XP_LEVEL_27	= 19200,
	XP_LEVEL_28	= 20700,
	XP_LEVEL_29	= 22250,
	XP_LEVEL_30	= 23850,
	XP_LEVEL_31	= 25500,
	XP_LEVEL_32	= 27200,
	XP_LEVEL_33	= 28950,
	XP_LEVEL_34	= 30750,
	XP_LEVEL_35	= 32600,
	XP_LEVEL_36	= 34500,
	XP_LEVEL_37	= 36450,
	XP_LEVEL_38	= 38450,
	XP_LEVEL_39	= 40500,
	XP_LEVEL_40	= 42600,
	XP_LEVEL_41	= 44750,
	XP_LEVEL_42	= 46950,
	XP_LEVEL_43	= 49200,
	XP_LEVEL_44	= 51500,
	XP_LEVEL_45	= 53850,
	XP_LEVEL_46	= 56250,
	XP_LEVEL_47	= 58700,
	XP_LEVEL_48	= 61300,
	XP_LEVEL_49	= 63950,
	XP_LEVEL_50	= 66650
}



public plugin_init()
{
	if(ns_is_combat())
	{
		register_plugin("CoBalancer","2.0","SilverSquirrl -2F4F")
		register_cvar("combat_fade","6",FCVAR_SERVER)
		register_cvar("combat_onos","7",FCVAR_SERVER)
		register_impulse(116,"checkFade")
		register_impulse(117,"checkOnos")
	}
	else {
		register_plugin("CoBalancer (OFF)","2.0","SilverSquirrl -2F4F")
	}
}

public checkOnos(id) {
	new x
	x = checkBlock(id,0)
	if (x == 0)
		return PLUGIN_HANDLED
	else
		return PLUGIN_CONTINUE
	return PLUGIN_CONTINUE
}

public checkFade(id) {
	new x
	x = checkBlock(id,1)
	if (x == 0)
		return PLUGIN_HANDLED
	else
		return PLUGIN_CONTINUE
	return PLUGIN_CONTINUE
}

public get_level(index) {
	new userxp = get_xp(index)

	if (userxp > XP_LEVEL_50)	return 50
	if (userxp > XP_LEVEL_49)	return 49
	if (userxp > XP_LEVEL_48)	return 48
	if (userxp > XP_LEVEL_47)	return 47
	if (userxp > XP_LEVEL_46)	return 46
	if (userxp > XP_LEVEL_45)	return 45
	if (userxp > XP_LEVEL_44)	return 44
	if (userxp > XP_LEVEL_43)	return 43
	if (userxp > XP_LEVEL_42)	return 42
	if (userxp > XP_LEVEL_41)	return 41
	if (userxp > XP_LEVEL_40)	return 40
	if (userxp > XP_LEVEL_39)	return 39
	if (userxp > XP_LEVEL_38)	return 38
	if (userxp > XP_LEVEL_37)	return 37
	if (userxp > XP_LEVEL_36)	return 36
	if (userxp > XP_LEVEL_35)	return 35
	if (userxp > XP_LEVEL_34)	return 34
	if (userxp > XP_LEVEL_33)	return 33
	if (userxp > XP_LEVEL_32)	return 32
	if (userxp > XP_LEVEL_31)	return 31
	if (userxp > XP_LEVEL_30)	return 30
	if (userxp > XP_LEVEL_29)	return 29
	if (userxp > XP_LEVEL_28)	return 28
	if (userxp > XP_LEVEL_27)	return 27
	if (userxp > XP_LEVEL_26)	return 26
	if (userxp > XP_LEVEL_25)	return 25
	if (userxp > XP_LEVEL_24)	return 24
	if (userxp > XP_LEVEL_23)	return 23
        if (userxp > XP_LEVEL_22)	return 22
	if (userxp > XP_LEVEL_21)	return 21
	if (userxp > XP_LEVEL_20)	return 20
	if (userxp > XP_LEVEL_19)	return 19
	if (userxp > XP_LEVEL_18)	return 18
	if (userxp > XP_LEVEL_17)	return 17
	if (userxp > XP_LEVEL_16)	return 16
	if (userxp > XP_LEVEL_15)	return 15
	if (userxp > XP_LEVEL_14)	return 14
	if (userxp > XP_LEVEL_13)	return 13
	if (userxp > XP_LEVEL_12)	return 12
	if (userxp > XP_LEVEL_11)	return 11
	if (userxp > XP_LEVEL_10)	return 10
	if (userxp > XP_LEVEL_9)	return 9
	if (userxp > XP_LEVEL_8)	return 8
	if (userxp > XP_LEVEL_7)	return 7
	if (userxp > XP_LEVEL_6)	return 6
	if (userxp > XP_LEVEL_5)	return 5
	if (userxp > XP_LEVEL_4)	return 4
	if (userxp > XP_LEVEL_3)	return 3
	if (userxp > XP_LEVEL_2)	return 2
	if (userxp >= XP_LEVEL_1)	return 1

	return 0
}

get_xp(index) {
	return floatround(ns_get_exp(index))

}

public checkBlock(id, impulVar)
{
	new plevel, minlevel, class[16]
	plevel = get_level(id)

	switch (impulVar) {
		case 0: minlevel = get_cvar_num("combat_onos");
		case 1: minlevel = get_cvar_num("combat_fade");

		}

	switch (impulVar) {
		case 0: class = "ONOS";
		case 1: class = "FADE";
		}



	if (plevel < minlevel) {
		client_print(id,print_chat,"[CoBalancer] You must be level %d before you can go %s.",minlevel,class)
		entity_set_int(id,EV_INT_impulse,0) 
		return 0
	}
	else	{
		return 1
	}
	return 1
}

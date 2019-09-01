#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <ns>

#include <hitloc>


#define	FORWARD_ATTACK		"ns_attack"

#define MAX_EVENTS		128
#define FMHOOK_POST		1

enum _:NS_IUSER3 {
	IUSER3_NONE = 0,
	IUSER3_MARINE,		//and yes, this includes HA and JP as well...
	//Commander?
	IUSER3_SKULK = 3,
	IUSER3_GORGE,
	IUSER3_LERK,
	IUSER3_FADE,
	IUSER3_ONOS,
	IUSER3_GESTATE,
	
	IUSER3_HIVE = 17,
	
	IUSER3_ARMORY = 25,
	IUSER3_ADVANCED_ARMORY,
	
	IUSER3_CHAMBER_DEFENSE = 42,
	IUSER3_CHAMBER_MOVEMENT,
	IUSER3_CHAMBER_OFFENSE,
	IUSER3_CHAMBER_SENSORY,
	IUSER3_ALIENRESTOWER,
	IUSER3_MAX
}

new const g_krsEventFiles[HLWT_MAX][] = 
{
	"Claws",
	"SpikeGun",
	"Bite",
	"Bite2",
	"Swipe",
	"ParasiteGun",
	"Knife",
	"Pistol",
	"MachineGun",
	"SonicGun",
	"HeavyMachineGun",
	"Welder",
	"HealingSpray",
	"Devour"
}

new g_riEventType[MAX_EVENTS]
new g_eCurAttacker
new g_iCurWeap
new g_iPendingShots
new g_iShotsToSkip
new bool:g_bUntilHit, bool:g_bUntilEnt
new g_pcvarFriendlyFire

public plugin_init()
{
	register_plugin("HitLoc", "1.0", "Darkns.xf")
	
	g_pcvarFriendlyFire = get_cvar_pointer("mp_friendlyfire")
	
	register_forward(FM_TraceLine, "fmhook_TraceLine_Post", FMHOOK_POST)
	register_forward(FM_PlaybackEvent, "fmhook_PlaybackEvent")
	
	register_forward(FM_PlayerPostThink, "fmhook_PlayerPostThink_Post", FMHOOK_POST)
	
	for (new i = 0; i < MAX_EVENTS; i++)
		g_riEventType[i] = -1
	
	for (new i = 0; i < HLWT_MAX; i++)
	{
		new sEventFile[64]
		format(sEventFile, 63, "events/%s.sc", g_krsEventFiles[i])
		new iEventID = precache_event(1, sEventFile)
		g_riEventType[iEventID] = i
	}
}

public fmhook_PlayerPostThink_Post(ePlayer)
{
	//reset after every shot burst
	g_iCurWeap = -1
	g_eCurAttacker = -1
	g_iShotsToSkip = 0
	g_iPendingShots = 0
	g_bUntilHit = false
	g_bUntilEnt = false
	
	return FMRES_IGNORED
}

public fmhook_TraceLine_Post(Float:oStart[3], Float:oEnd[3], iNoMonsters, eIgnore, trHit)
{
	if (g_iCurWeap != -1)
	{
		if (g_iShotsToSkip)
		{
			g_iShotsToSkip--
		}
		else if (g_iPendingShots)
		{
			new Float:oHit[3]
			get_tr2(trHit, TraceResult:TR_vecEndPos, oHit)
			
			new eHit = get_tr2(trHit, TraceResult:TR_pHit)
			new iHitGroup = get_tr2(trHit, TraceResult:TR_iHitgroup)
			
			if (!pev_valid(eHit))
			{
				if (VectorEqual(oEnd, oHit))
					eHit = -1
				else
					eHit = 0
			}
			
			BroadcastAttack(g_eCurAttacker, g_iCurWeap, eHit, iHitGroup, oStart, oEnd, oHit)
			
			g_iPendingShots--
			
			if (g_bUntilEnt && (eHit > 0))
			{
				g_iPendingShots = 0
			}
			else if (g_bUntilHit && (eHit > -1))
			{
				g_iPendingShots = 0
			}
			
			if (g_iPendingShots)	//if there are more to come...
			{
				g_iShotsToSkip = ShotsToSkip(g_eCurAttacker, eHit, g_iCurWeap)
			}
			else
			{
				g_iCurWeap = -1
				g_eCurAttacker = -1
				g_iShotsToSkip = 0
				g_bUntilHit = false
			}
		}
	}
	
	return FMRES_IGNORED
}

public fmhook_PlaybackEvent(flags, entid, eventid, Float:delay, Float:Origin[3], Float:Angles[3], Float:fparam1, Float:fparam2, iparam1, iparam2, bparam1, bparam2)
{
	if (g_riEventType[eventid] != -1)
	{
		g_iCurWeap = g_riEventType[eventid]
		g_eCurAttacker = entid
		switch (g_iCurWeap)
		{
			case HLWT_GORE:
			{
				g_iPendingShots = 3
				g_bUntilEnt = true
			}
			case HLWT_SPIKES:
			{
				g_iPendingShots = 2
				g_bUntilHit = true
			}
			case HLWT_BITE:
			{
				g_iPendingShots = 3
				g_bUntilEnt = true
			}
			case HLWT_BITE2:
			{
				g_iPendingShots = 3
				g_bUntilEnt = true
			}
			case HLWT_SWIPE:
			{
				g_iPendingShots = 3
				g_bUntilEnt = true
			}
			case HLWT_PARASITE:
			{
				g_iShotsToSkip = 1	//this might end up being a preliminary shot, like spikes
				g_iPendingShots = 1
			}
			case HLWT_KNIFE:
			{
				g_iPendingShots = 3
				g_bUntilEnt = true
			}
			case HLWT_SHOTGUN:
				g_iPendingShots = 10
			case HLWT_HEALSPRAY:
			{
				g_iPendingShots = 2	//ShotsToSkip() handles the blank trace in the middle
			}
			case HLWT_DEVOUR:
			{
				g_iShotsToSkip = 1
				g_iPendingShots = 1
			}
			default:
				g_iPendingShots = 1
		}
	}
		
	return FMRES_IGNORED
}

ShotsToSkip(eAttacker, eVictim, iWeaponType)
{
	if (iWeaponType == HLWT_HEALSPRAY)
	{
		return 1	//hax!
	}
	else if (ShouldBleed(eVictim))
	{
		if (pev(eVictim, pev_team) == pev(eAttacker, pev_team))
		{
			if (get_pcvar_num(g_pcvarFriendlyFire))
				return 1
			else
				return 0
		}
		else
			return 2
	}
	
	return 0
}

ShouldBleed(eEnt)
{
	if (pev_valid(eEnt))
	{
		new iUser3 = pev(eEnt, pev_iuser3)
		switch (iUser3)
		{
			case IUSER3_MARINE:
			{
				if (ns_get_mask(eEnt, MASK_HEAVYARMOR))
					return 0
				else
					return 1
			}
			case IUSER3_SKULK:
				return 1
			case IUSER3_GORGE:
				return 1
			case IUSER3_LERK:
				return 1
			case IUSER3_FADE:
				return 1
			case IUSER3_ONOS:
				return 1
			case IUSER3_GESTATE:
				return 1
			
			case IUSER3_HIVE:
				return 1
			case IUSER3_CHAMBER_DEFENSE:
				return 1
			case IUSER3_CHAMBER_MOVEMENT:
				return 1
			case IUSER3_CHAMBER_OFFENSE:
				return 1
			case IUSER3_CHAMBER_SENSORY:
				return 1
			case IUSER3_ALIENRESTOWER:
				return 1
		}
	}
	
	return 0
}


BroadcastAttack(eAttacker, iWeaponType, eVictim, iHitGroup, Float:oStart[3], Float:oEnd[3], Float:oHit[3])
{
	new iPluginCount = get_pluginsnum()
	for (new i = 1; i <= iPluginCount; i++)
	{
		new iFuncID = get_func_id(FORWARD_ATTACK, i)
		if (iFuncID != -1)
		{
			SendAttack(i, iFuncID, eAttacker, iWeaponType, eVictim, iHitGroup, oStart, oEnd, oHit)
		}
	}
}

SendAttack(iPluginID, iFuncID, eAttacker, iWeaponType, eVictim, iHitGroup, Float:oStart[3], Float:oEnd[3], Float:oHit[3])
{ 
	if (callfunc_begin_i(iFuncID, iPluginID) == 1)
	{
		callfunc_push_int(eAttacker)
		callfunc_push_int(iWeaponType)
		callfunc_push_int(eVictim)
		callfunc_push_int(iHitGroup)
		callfunc_push_array(_:oStart, 3, false)	//don't bother
		callfunc_push_array(_:oEnd, 3, false)	//don't bother
		callfunc_push_array(_:oHit, 3, false)	//don't bother
		callfunc_end()
	}
}

bool:VectorEqual(Float:oA[3], Float:oB[3])
{
	if ( (oA[0] == oB[0])
	  && (oA[1] == oB[1])
	  && (oA[2] == oB[2]) )
		return true;
	
	return false;
}

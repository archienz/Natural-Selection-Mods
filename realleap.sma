//==================================================================================================
//==================================================================================================
//	Configuration

/*
INT (0)
0 - Do use default helper output
1 - Use the "Helper" plugin (recommended)
*/
#define HELPER 1

//==================================================================================================
//==================================================================================================
//	Includes
#include <amxmodx>
#include <fakemeta>
#include <ns>

#if HELPER == 1
	#include <helper>
#else
	#define help_add(%1) 	float(0)
#endif

//==================================================================================================
//==================================================================================================
//	Pragmas
#pragma tabsize 0

//==================================================================================================
//==================================================================================================
//	Defines
#define		VERSION			"1.00"

#define		LEAP_RANGE		60.0	//same as bite range
#define		LEAP_SIDERANGE		24.0	//same as bite siderange
#define		LEAP_DAMAGE		80.0
#define		LEAP_AVGSPEED		800.0
#define		DAMAGE_PER_SPEED	LEAP_DAMAGE / LEAP_AVGSPEED
#define		VOL_PER_SPEED		1.0 / LEAP_AVGSPEED

#define		PDATA_LEAPEND		471
#define		LINOFF_PLAYER		5

#define		SOUND_HIT		"weapons/bitehit3.wav"	//bite uses hit1 and hit2, but not hit3

// <3 BLOOD
#define		BLOOD_PER_DAMAGE	0.2
#define		MIN_BLOODSIZE		3		//if (fDamage < 15.0)
#define		MAX_BLOODSIZE		16		//if (fDamage > 80.0)
//blood colors
#define		DONT_BLEED		-1
#define		BLOOD_COLOR_RED		247
#define		BLOOD_COLOR_YELLOW	195

//teams
#define TEAM_OTHER		0
#define TEAM_MARINE		1
#define TEAM_ALIEN		2
//angles
#define PITCH	0

//==================================================================================================
//==================================================================================================
//	Macros
#define	Clamp(%1,%2,%3)		(\
					(%1 < %2)?\
					(\
						%1 = %2\
					)\
					:\
					(\
						(%1 > %3)?\
						(\
							%1 = %3\
						)\
						:\
							0\
					)\
				)
#define	VectorAddSelf(%1,%2)	%1[0] += %2[0];\
				%1[1] += %2[1];\
				%1[2] += %2[2]
#define	VectorSub(%1,%2,%3)	%3[0] = %1[0] - %2[0];\
				%3[1] = %1[1] - %2[1];\
				%3[2] = %1[2] - %2[2]
#define	VectorScal(%1,%2,%3)	%3[0] = %1[0] * %2;\
				%3[1] = %1[1] * %2;\
				%3[2] = %1[2] * %2
#define	VectorMultSelf(%1,%2)	%1[0] *= %2[0];\
				%1[1] *= %2[1];\
				%1[2] *= %2[2]
#define	VectorSubSelf(%1,%2)	%1[0] -= %2[0];\
				%1[1] -= %2[1];\
				%1[2] -= %2[2]
#define	floor(%1)		floatround(%1, floatround_floor)
#define write_fangle(%1)	engfunc(EngFunc_WriteAngle, %1)
#define write_fcoord(%1)	engfunc(EngFunc_WriteCoord, %1)
#define	GetDamageMult(%1,%2)	(\
					(%2 && pev_valid(%2))?\
					(\
						(pev(%2, pev_flags) & (FL_GODMODE | FL_WORLDBRUSH))?\
							0.0\
						:\
						(\
							(fpev(%2, pev_max_health) <= 0.0)?\
								0.0\
							:\
							(\
								(pev(%1, pev_team) == pev(%2, pev_team))?\
								(\
									(get_pcvar_num(g_pcvarFriendlyFire))?\
										0.25\
									:\
										0.0\
								)\
								:\
									1.0\
							)\
						)\
					)\
					:\
						0.0\
				)
#define	get_team(%1)		pev(%1, pev_team)
#define	get_teamtype(%1)	get_team_teamtype(get_team(%1))
//==================================================================================================
//==================================================================================================
//	Enums
enum _:{
	IUSER3_NONE = 0,
	IUSER3_MARINE,		//and yes, this includes HA and JP as well...
	IUSER3_COMMANDER,
	IUSER3_SKULK,
	IUSER3_GORGE,
	IUSER3_LERK,
	IUSER3_FADE,
	IUSER3_ONOS,
	IUSER3_GESTATE,
	
	IUSER3_HIVE = 17,
	
	IUSER3_CHAMBER_DEFENSE = 42,
	IUSER3_CHAMBER_MOVEMENT,
	IUSER3_CHAMBER_OFFENSE,
	IUSER3_CHAMBER_SENSORY,
	IUSER3_ALIENRESTOWER
}

//==================================================================================================
//==================================================================================================
//	Globals
new g_iMaxPlayers, g_iMaxEnts
new g_pcvarFriendlyFire, g_pcvarLeapDamageMult
//Sprite IDs
new g_iSprite_BloodSpray, g_iSprite_Blood

//==================================================================================================
//==================================================================================================
//	Main Forwards
public plugin_precache()
{
	g_iSprite_BloodSpray = precache_model("sprites/bloodspray.spr")
	g_iSprite_Blood = precache_model("sprites/blood.spr")
	
	precache_sound(SOUND_HIT)
}

public plugin_init()
{
	register_plugin("Real Leap", VERSION, "Darkns.xf")
	register_cvar("v_realleap", VERSION, FCVAR_SERVER)
	
	g_pcvarLeapDamageMult = register_cvar("leap_damagemult", "1.0")
	
	g_pcvarFriendlyFire = get_cvar_pointer("mp_friendlyfire")
	
	register_forward(FM_Touch, "fmhook_Touch")
	
	g_iMaxPlayers = global_get(glb_maxClients)
	g_iMaxEnts = global_get(glb_maxEntities)
}

//==================================================================================================
//==================================================================================================
//	Helper Interface

public client_help(ePlayer)
{
	help_add("Information","This plugin changes leap to do damage based on how hard the skulk collides with an enemy.");
	if (get_teamtype(ePlayer) == TEAM_ALIEN)
	{
		help_add("Tip","Combine leap with bite to tear through marines!");
	}
	else
	{
		
	}
}

public client_advertise()
{
	return PLUGIN_CONTINUE;
}

//==================================================================================================
//==================================================================================================
//	Secondary Forwards
public fmhook_Touch(ePlayer, eOther)
{
	if (is_user_connected(ePlayer) && (pev(ePlayer, pev_iuser3) == IUSER3_SKULK) )	// && pev_valid(eOther))
	{
		new Float:fNow
		global_get(glb_time, fNow)
		new Float:fLeapEnd = get_pdata_float(ePlayer, PDATA_LEAPEND, LINOFF_PLAYER)
		
		//touch is called multiple times per frame, so since it sets fLeapEnt to fNow, it can't use '<='
		if (fNow < fLeapEnd)	
		{
			LeapHit(ePlayer, eOther)
			
			set_pdata_float(ePlayer, PDATA_LEAPEND, fNow, LINOFF_PLAYER)	//done with leap
		}
	}
	
	return FMRES_IGNORED
}

//==================================================================================================
//==================================================================================================
//	Main Functions
LeapHit(ePlayer, eVictim)
{
	new Float:oAim[3], Float:aAim[3]
	GetAimOrigin(ePlayer, oAim)
	GetAimAngle(ePlayer, aAim)
	
	new Float:vAim[3], Float:vAimRight[3]
	AngleToVector(aAim, vAim, vAimRight)
	
	new Float:oFar[3]
	VectorScal(vAim, LEAP_RANGE, oFar)
	VectorAddSelf(oFar, oAim)
	
	new trTrace
	engfunc(EngFunc_TraceLine, oAim, oFar, 0, ePlayer, trTrace)
	
	new Float:fFraction
	get_tr2(trTrace, TR_flFraction, fFraction)
	if (fFraction == 1.0)
	{
		new Float:oFarRight[3]
		VectorScal(vAimRight, LEAP_SIDERANGE, oFarRight)
		VectorAddSelf(oFarRight, oFar)
		
		engfunc(EngFunc_TraceLine, oAim, oFarRight, 0, ePlayer, trTrace)
		get_tr2(trTrace, TR_flFraction, fFraction)
	}
	
	if (fFraction == 1.0)
	{
		new Float:oFarLeft[3]
		VectorScal(vAimRight, LEAP_SIDERANGE * -1.0, oFarLeft)
		VectorAddSelf(oFarLeft, oFar)
		
		engfunc(EngFunc_TraceLine, oAim, oFarLeft, 0, ePlayer, trTrace)
		get_tr2(trTrace, TR_flFraction, fFraction)
	}
	
	new eHit = get_tr2(trTrace, TR_pHit)
	if ((eHit == -1) && (fFraction < 1.0))
		eHit = 0
	
	if (eHit == eVictim)
	{
		new Float:oHit[3], Float:vHit[3]
		get_tr2(trTrace, TR_vecEndPos, oHit)
		get_tr2(trTrace, TR_vecPlaneNormal, vHit)
		VectorAddSelf(oHit, vHit)
		
		
		new Float:vPlayerRelVel[3]
		pev(ePlayer, pev_velocity, vPlayerRelVel)
		VectorMultSelf(vPlayerRelVel, vAim)	//component-wise multiply
		
		new Float:vVictimRelVel[3]
		pev(eVictim, pev_velocity, vVictimRelVel)
		VectorMultSelf(vVictimRelVel, vAim)	//component-wise multiply
		
		new Float:vRelVel[3]
		VectorSub(vPlayerRelVel, vVictimRelVel, vRelVel)
		
		new Float:fSpeed = vector_length(vRelVel)
		
		
		new Float:fVolume = fSpeed * VOL_PER_SPEED
		if (fVolume > 1.0)
			fVolume = 1.0	//if this is over 1.0, it crashes the game
		
		//the sound should be attached to the player's weapon, but that'd be more work...this'll do:
		emit_sound(ePlayer, CHAN_AUTO, SOUND_HIT, fVolume, ATTN_NORM, 0, random_num(PITCH_LOW, PITCH_HIGH))
		
		
		new Float:fDamage = fSpeed * DAMAGE_PER_SPEED
		fDamage *= get_pcvar_float(g_pcvarLeapDamageMult)
		fDamage *= GetDamageMult(ePlayer, eVictim)
		
		if (fDamage > 0.0)
		{
			MakeBleed(eVictim, oHit, fDamage)
			ns_takedamage(eVictim, GetPlayerWeapEnt(ePlayer, "weapon_leap"), ePlayer, fDamage, DMG_SLASH)
		}
		else
		{
			TE_Sparks(oHit)
		}
	}
}

//==================================================================================================
//==================================================================================================
//	Secondary Functions
MakeBleed(eVictim, Float:oHit[3], Float:fDamage)
{
	new iBloodColor = GetBloodColor(eVictim)
	if (iBloodColor == DONT_BLEED)
		TE_Sparks(oHit)
	else
	{
		new iBloodSize = floor(fDamage * BLOOD_PER_DAMAGE)
		Clamp(iBloodSize, MIN_BLOODSIZE, MAX_BLOODSIZE)
		
		TE_BloodSprite(oHit, g_iSprite_BloodSpray, g_iSprite_Blood, iBloodColor, iBloodSize)
	}
}

GetPlayerWeapEnt(ePlayer, sWeapClass[])
{
	static eEnt
	for (eEnt = g_iMaxPlayers + 1; eEnt <= g_iMaxEnts; eEnt++)
	{
		if (pev_valid(eEnt))
		{
			if (pev(eEnt, pev_owner) == ePlayer)
			{
				static sClassname[32]
				pev(eEnt, pev_classname, sClassname, 31)
				
				if (equal(sClassname, sWeapClass))
					return eEnt
			}
		}
	}
	
	return ePlayer
}
/* Macro'd
Float:GetDamageMult(ePlayer, eOther)
{
	if (eOther && pev_valid(eOther))
	{
		if (pev(eOther, pev_flags) & (FL_GODMODE | FL_WORLDBRUSH))
			return 0.0
		
		if (fpev(eOther, pev_max_health) <= 0.0)
			return 0.0
		
		if (pev(ePlayer, pev_team) == pev(eOther, pev_team))
		{
			if (get_pcvar_num(g_pcvarFriendlyFire))
				return 0.25
			else
				return 0.0
		}
		
		return 1.0
	}
	//else
	return 0.0
}
*/

GetBloodColor(eEnt)	//assumes valid eEnt
{
	static iUser3
	iUser3 = pev(eEnt, pev_iuser3)
	switch (iUser3)
	{
		case IUSER3_MARINE:
		{
			if (pev(eEnt, pev_iuser4) & MASK_HEAVYARMOR)
				return DONT_BLEED
			else
				return BLOOD_COLOR_RED
		}
		case IUSER3_SKULK:
			return BLOOD_COLOR_YELLOW
		case IUSER3_GORGE:
			return BLOOD_COLOR_YELLOW
		case IUSER3_LERK:
			return BLOOD_COLOR_YELLOW
		case IUSER3_FADE:
			return BLOOD_COLOR_YELLOW
		case IUSER3_ONOS:
			return BLOOD_COLOR_YELLOW
		case IUSER3_GESTATE:
			return BLOOD_COLOR_YELLOW
		
		case IUSER3_HIVE:
			return BLOOD_COLOR_YELLOW
		case IUSER3_CHAMBER_DEFENSE:
			return BLOOD_COLOR_YELLOW
		case IUSER3_CHAMBER_MOVEMENT:
			return BLOOD_COLOR_YELLOW
		case IUSER3_CHAMBER_OFFENSE:
			return BLOOD_COLOR_YELLOW
		case IUSER3_CHAMBER_SENSORY:
			return BLOOD_COLOR_YELLOW
		case IUSER3_ALIENRESTOWER:
			return BLOOD_COLOR_YELLOW
	}
	
	return DONT_BLEED
}

TE_Sparks(Float:oPos[3])
{
	message_fbegin(MSG_PVS, SVC_TEMPENTITY, oPos)
	write_byte(TE_SPARKS)// coord coord coord (position)
	write_fcoord(oPos[0])
	write_fcoord(oPos[1])
	write_fcoord(oPos[2])
	message_end()
}

TE_BloodSprite(Float:oPos[3], iSprite_BloodSpray, iSprite_Blood, iColor, iScale)
{
	message_fbegin(MSG_PVS, SVC_TEMPENTITY, oPos)
	write_byte(TE_BLOODSPRITE)// coord coord coord (position)
	write_fcoord(oPos[0])
	write_fcoord(oPos[1])
	write_fcoord(oPos[2])
	write_short(iSprite_BloodSpray)
	write_short(iSprite_Blood)
	write_byte(iColor)
	write_byte(iScale)
	message_end()
}

//==================================================================================================
//==================================================================================================
//	Util Functions
AngleToVector(Float:aAngle[3], Float:nForward[3], Float:nRight[3] = {0.0,0.0,0.0}, Float:nUp[3] = {0.0,0.0,0.0})
{
	aAngle[PITCH] *= -1.0;	//What the Valve?
	engfunc(EngFunc_AngleVectors, aAngle, nForward, nRight, nUp);
	aAngle[PITCH] *= -1.0;	//and back again...
}

GetAimOrigin(ePlayer, Float:oAim[3])
{
	pev(ePlayer, pev_origin, oAim);
	static Float:vOffset[3];
	pev(ePlayer, pev_view_ofs, vOffset);
	VectorAddSelf(oAim, vOffset);
}

GetAimAngle(ePlayer, Float:aAim[3])
{
	pev(ePlayer, pev_v_angle, aAim);
	aAim[PITCH] *= -1.0;
	static Float:aPunchAngle[3];
	pev(ePlayer, pev_punchangle, aPunchAngle);
	VectorSubSelf(aAim, aPunchAngle);	//was add
}

message_fbegin(iDestType, iMessageID, Float:oPos[3] = {0.0, 0.0, 0.0}, eTarget = 0)
	engfunc(EngFunc_MessageBegin, iDestType, iMessageID, oPos, eTarget);

Float:fpev(eEnt, iPevVar)
{
	static Float:fVal;
	pev(eEnt, iPevVar, fVal);
	return fVal;
}

get_team_teamtype(iTeam)	//MvM support...
{
	switch (iTeam)
	{
		case 1:
			return TEAM_MARINE;
		case 2:
			return TEAM_ALIEN;
		case 3:
			return TEAM_MARINE;
		case 4:
			return TEAM_ALIEN;
	}
	return TEAM_OTHER;
}
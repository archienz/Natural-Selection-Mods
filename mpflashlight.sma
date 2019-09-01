#include <amxmodx>
#include <fakemeta>

#define	VERSION		"1.01"

#define FL_RADIUS	8	//in 10s
#define FL_LIFE		2	//in 0.1s
#define FL_DECAY	0	//in 0.1s
#define FL_RED		255 >> FL_LIFE	//1->127, 2->63
#define FL_GREEN	255 >> FL_LIFE
#define FL_BLUE		255 >> FL_LIFE

#define DF_DEAD		2

//MACROs:
//util.inc:
#define fm_write_coord(%1)	engfunc(EngFunc_WriteCoord, %1)

new Float:g_rfNextLightTime[33]
new g_riIsFlashlightOn[33]

public plugin_init()
{
	register_plugin("MP Flashlight", VERSION, "Darkns.xf")
	register_cvar("v_mpflashlight", VERSION)
	
	register_forward(FM_PlayerPostThink, "fmhook_PlayerPostThink")
}

public client_connect(ePlayer)
	g_riIsFlashlightOn[ePlayer] = 0

public client_disconnect(ePlayer)
	g_riIsFlashlightOn[ePlayer] = 0

public client_changeteam(ePlayer)
	g_riIsFlashlightOn[ePlayer] = 0


public fmhook_PlayerPostThink(ePlayer)
{
	new iEffects = pev(ePlayer, pev_effects)
	if (iEffects & EF_DIMLIGHT)
	{
		g_riIsFlashlightOn[ePlayer] = !g_riIsFlashlightOn[ePlayer]
		set_pev(ePlayer, pev_effects, iEffects & ~EF_DIMLIGHT)
	}
	
	if (g_riIsFlashlightOn[ePlayer])
		if ( !(pev(ePlayer, pev_deadflag) & DF_DEAD))
			DrawFlashlight(ePlayer)
	
	return FMRES_IGNORED
}

DrawFlashlight(ePlayer)
{
	new Float:fNow
	global_get(glb_time, fNow)
	
	if (fNow >= g_rfNextLightTime[ePlayer])
	{
		new Float:oAim[3], Float:aAim[3]
		GetAimOrigin(ePlayer, oAim)
		GetAimAngle(ePlayer, aAim)
		
		new Float:vAim[3]
		angle_to_vector(aAim, vAim)
		
		new Float:oFar[3]
		VectorScal(vAim, 8192.0, oFar)
		VectorAddSelf(oFar, oAim)
		
		new trTrace
		engfunc(EngFunc_TraceLine, oAim, oFar, 0, ePlayer, trTrace)
		new Float:oHit[3], Float:vHit[3]
		get_tr2(trTrace, TR_vecEndPos, oHit)
		get_tr2(trTrace, TR_vecPlaneNormal, vHit)
		
		if (!VectorEqual(oFar, oHit))
		{
			VectorAddSelf(oHit, vHit)
			TE_DLight(oHit)
			g_rfNextLightTime[ePlayer] = fNow + 0.050
		}
	}
}

TE_DLight(Float:oPoint[3])
{
	new ioPoint[3]
	VectorFloatround(oPoint, ioPoint)
	message_begin(MSG_PVS, SVC_TEMPENTITY, ioPoint)
	
	write_byte(TE_DLIGHT)
	fm_write_coord(oPoint[0])
	fm_write_coord(oPoint[1])
	fm_write_coord(oPoint[2])
	write_byte(FL_RADIUS)
	write_byte(FL_RED)
	write_byte(FL_GREEN)
	write_byte(FL_BLUE)
	write_byte(FL_LIFE)
	write_byte(FL_DECAY)
	message_end()
}

//util.inc:
angle_to_vector(Float:aAngle[3], Float:nForward[3], Float:nRight[3] = {0.0,0.0,0.0}, Float:nUp[3] = {0.0,0.0,0.0})
{
	engfunc(EngFunc_AngleVectors, aAngle, nForward, nRight, nUp);
}

bool:VectorEqual(Float:oA[3], Float:oB[3])
{
	if ( (oA[0] == oB[0])
	  && (oA[1] == oB[1])
	  && (oA[2] == oB[2]) )
		return true;
	
	return false;
}

VectorFloatround(Float:vVect[3], ivVect[3], floatround_method:method = floatround_round)
{
	ivVect[0] = floatround(vVect[0], method);
	ivVect[1] = floatround(vVect[1], method);
	ivVect[2] = floatround(vVect[2], method);
}

VectorAddSelf(Float:vA[3], Float:vB[3])
{
	vA[0] += vB[0];
	vA[1] += vB[1];
	vA[2] += vB[2];
}

VectorScal(Float:vVect[3], Float:fMul, Float:vRes[3])
{
	vRes[0] = vVect[0] * fMul;
	vRes[1] = vVect[1] * fMul;
	vRes[2] = vVect[2] * fMul;
}

GetAimOrigin(ePlayer, Float:oAim[3])
{
	pev(ePlayer, pev_origin, oAim);
	new Float:vOffset[3];
	pev(ePlayer, pev_view_ofs, vOffset);
	VectorAddSelf(oAim, vOffset);
}

GetAimAngle(ePlayer, Float:aAim[3])
{
	pev(ePlayer, pev_v_angle, aAim);
}
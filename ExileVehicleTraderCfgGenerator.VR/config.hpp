//// EVTCG config.hpp

// === FILTERING ===
EVTCG_modName = "";
EVTCG_vehicleType = [];		// if not empty, this will filter by condition (_className isKindOf _x) // e.g. ["Helicopter","Tank"] will only output helicopters and tanks. // IF empty, it defaults to ["Car", "Tank", "Air", "Ship", "Static"] // CASE SENSITIVE!!
EVTCG_exceptions = [];	// Filters will first and foremost skip classes added to this array	//e.g. ["B_MRAP_01_F"]
// or you can just specify vehicles in this array (skips above checks)
EVTCG_userArray = [
	#include "config_EVTCG_userArray.hpp"
];
EVTCG_customFilter = {
	true
};


// === SCORE ADJUSTMENT ===

EVTCG_DS_perEffectiveHP = 10;				// EHP = armor * armorStructural
EVTCG_DS_explosionShieldingMult = 0;			// Best leave it at 0, unless you know how this param works (msg me!)
EVTCG_DS_crewExplosionProtectionMult = 0.1;	// Best leave it at 10 - the larger the number, the more expensive armored vehicles are.

EVTCG_US_healBonus = 5000;					// Note: Medical vehicles healing ability does not work with Exile (unless you install a patch)
EVTCG_US_refuelBonus = 10000;				// If a vehicle has the ability to refuel other vehicles, how much more expensive should it be?
EVTCG_US_repairBonus = 15000;				// If a vehicle has the ability to repair other vehicles, how much more expensive should it be?
EVTCG_US_rearmBonus = 20000;					// If a vehicle has the ability to rearm other vehicles, how much more expensive should it be?

EVTCG_MS_perSpeed = 15;						// How much poptabs per km/h (maxSpeed)?
EVTCG_MS_terrainCoefMult = 20;				// How much more for vehicles can drive well off-road? Recommended to keep between 1 and 2 (e.g. 1.5)

EVTCG_CS_perLoad = 1;						// How much poptabs per maximumLoad?
EVTCG_CS_perSeat = 500;						// How much poptabs per PASSENGER (non-functional) seat?

EVTCG_AS_classnameList = [
	#include "config_EVTCG_classnameList.hpp"
];

EVTCG_AS_keywordList = [
	#include "config_EVTCG_keywordList.hpp"
];

EVTCG_TS_perVehTypeMult = [
	["Plane",			5],
	["Tank",			2],
	["Helicopter",		4],
	["Ship",			0.8],
	["Static",			1],
	["Car",				1]
];

// === RESPECT ADJUSTMENT ===

EVTCG_Respect_allLevelOne = false;			// Sets all vehicles respect requirements to level 1 - skips fn_calculateRespect.sqf


// === DEBUG OPTIONS ===

EVTCG_DebugMode = true;
EVTCG_DebugLimit = false;
EVTCG_skipXLoops = 16008;
EVTCG_displayXLoops = 12;


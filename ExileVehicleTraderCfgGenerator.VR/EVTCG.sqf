#include "config.hpp"

private _vehArray = [];
private _vehParentArray = [];

private _cfgVehicles = if ((count EVTCG_userArray) == 0) then {
    "true" configClasses (configFile >> "CfgVehicles")
} else {
    EVTCG_userArray apply { configFile >> "CfgVehicles" >> _x }
};

private _total = count _cfgVehicles;
private _chunk = _total / 10; // 10% chunk
private _progressStep = 0;

// Iterate through each vehicle in CfgVehicles
// ================= LOOP STARTS HERE =================
{
	private _idx = _forEachIndex;
	
	private _progress = count _cfgVehicles;
	

	private _className = configName _x;
    private _correctClassname = [_className] call EVTCG_fnc_applyFilters;
	if !(_correctClassname) then { continue };
	
    if (EVTCG_DebugLimit && {_idx < EVTCG_skipXLoops}) then { continue };
    if (EVTCG_DebugLimit && {_idx >= EVTCG_skipXLoops + EVTCG_displayXLoops}) exitWith {};
	if (EVTCG_DebugMode) then { diag_log "====================================";};
	if (EVTCG_DebugMode) then { diag_log format ["[DEBUG] Loop %1 started",_forEachIndex + 1];};
	if (EVTCG_DebugMode) then { diag_log format ["[DEBUG] Classname: %1",_className];};
	if (EVTCG_DebugMode) then {
		private _modDisplay = if (EVTCG_modName isNotEqualTo "") then {EVTCG_modName} else {"n/a"};
		diag_log format ["[DEBUG] EVTCG_modName: %1", _modDisplay];
	};
    private _configPath = configFile >> "CfgVehicles" >> _className;

	private _transportAmmo = getNumber (_configPath >> "transportAmmo");
	private _transportFuel = getNumber (_configPath >> "transportFuel");
	private _transportRepair = getNumber (_configPath >> "transportRepair");
	private _attendant = getNumber (_configPath >> "attendant");
		
	// HERE we need to add an if condition. But first, we need to get the parent class of the _className
	private _parentConfig = inheritsFrom (configFile >> "CfgVehicles" >> _className);
	private _parentClass = if (isNull _parentConfig) then { "" } else { configName _parentConfig };
	// THEN we need to check if the parent class can be found in _vehParentArray

	//if there is no such parent in the array, we need to add it first

	// Then we can proceed to get all data
	private _displayName = getText (_configPath >> "displayName");
	private _textSingular = getText (_configPath >> "textSingular");
	private _scope = getNumber (_configPath >> "scope");
	private _armor = getNumber (_configPath >> "armor");
	private _armorHull = 0.0;
	if (isClass (_configPath >> "HitPoints" >> "HitHull")) then {
		_armorHull = configProperties [_configPath >> "HitPoints" >> "HitHull"];
	};
	private _armorStructural = getNumber (_configPath >> "armorStructural");
	private _crewExplosionProtection = getNumber (_configPath >> "crewExplosionProtection");
	private _explosionShielding = getNumber (_configPath >> "explosionShielding");
	private _maxSpeed = getNumber (_configPath >> "maxSpeed");
	private _canFloat = getNumber (_configPath >> "canFloat");
	private _maxOmega = getNumber (_configPath >> "maxOmega");
	private _terrainCoef = getNumber (_configPath >> "terrainCoef");
	private _maximumLoad = getNumber (_configPath >> "maximumLoad");
	private _transportSoldier = getNumber (_configPath >> "transportSoldier");
	private _hiddenSelectionsTextures = "";
	if (isArray (_configPath >> "hiddenSelectionsTextures")) then {
		_hiddenSelectionsTextures = getArray (_configPath >> "hiddenSelectionsTextures");
	};

	private _armamentsArray = [_className] call EVTCG_fnc_getArmaments;

	private _defenseScore = -1;
	private _utilityScore = -1;
	private _mobilityScore = -1;
	private _cargoScore = -1;
	private _armamentScore = -1;
	private _finalScore = -1;
	
	if (isNil "EVTCG_fnc_calculateDefenseScore") then {
		diag_log "Function EVTCG_fnc_calculateDefenseScore not defined!";
	} else {
		_defenseScore = [_armor, _armorStructural, _explosionShielding, _crewExplosionProtection] call EVTCG_fnc_calculateDefenseScore;
	};
	if (_defenseScore < 0) then {diag_log format ["[ERROR] Defense score calculation failed! Turn on Debug Mode in config"];};

	if (isNil "EVTCG_fnc_calculateUtilityScore") then {
		diag_log "Function EVTCG_fnc_calculateUtilityScore not defined!";
	} else {
		_utilityScore = [_transportAmmo, _transportFuel, _transportRepair, _attendant] call EVTCG_fnc_calculateUtilityScore;
	};
	if (_utilityScore < 0) then {diag_log format ["[ERROR] Utility score calculation failed! Turn on Debug Mode in config"];};

	if (isNil "EVTCG_fnc_calculateMobilityScore") then {
		diag_log "Function EVTCG_fnc_calculateMobilityScore not defined!";
	} else {
		_mobilityScore = [_maxSpeed, _terrainCoef] call EVTCG_fnc_calculateMobilityScore;
	};
	if (_mobilityScore < 0) then {diag_log format ["[ERROR] Mobility score calculation failed! Turn on Debug Mode in config"];};

	if (isNil "EVTCG_fnc_calculateCargoScore") then {
		diag_log "Function EVTCG_fnc_calculateCargoScore not defined!";
	} else {
		_cargoScore = [_maximumLoad, _transportSoldier] call EVTCG_fnc_calculateCargoScore;
	};
	if (_cargoScore < 0) then {diag_log format ["[ERROR] Cargo score calculation failed! Turn on Debug Mode in config"];};

	// Score Multiplier per vehicle type (see EVTCG_TS_perVehTypeMult in config.hpp)
	private _partialScore = _defenseScore + _utilityScore + _mobilityScore + _cargoScore;
	private _multipliedScore = [_partialScore, _className] call EVTCG_fnc_vehTypeMultiplier;
	

	if (isNil "EVTCG_fnc_calculateArmamentScore") then {
		diag_log "Function EVTCG_fnc_calculateArmamentScore not defined!";
	} else {
		_armamentScore = [_armamentsArray, _className] call EVTCG_fnc_calculateArmamentScore;
	};
	if (_armamentScore < 0) then {diag_log format ["[ERROR] Armament score calculation failed! Turn on Debug Mode in config"];};

	if (isNil "EVTCG_fnc_calculateTotalScore") then {
		diag_log "Function EVTCG_fnc_calculateTotalScore not defined!";
	} else {
		_finalScore = [_multipliedScore, _armamentScore] call EVTCG_fnc_calculateTotalScore;
	};
	if (_finalScore < 0) then {diag_log format ["[ERROR] Final score calculation failed! Turn on Debug Mode in config"];};
	
	private _respectLevel = 1;
	
	if (EVTCG_Respect_allLevelOne == false ) then {
		private _attributeArray = [
			_className,
			_displayName,
			_armor,
			_armorStructural,
			_transportAmmo,
			_transportFuel,
			_transportRepair,
			_maxSpeed,
			_armamentsArray
		];	
		_respectLevel = _attributeArray call EVTCG_fnc_calculateRespect;
	};
	
	private _classArray = [];
	if !(_parentClass in _vehParentArray) then {
		_vehParentArray pushback _parentClass;

		_classArray = format [
			"%1;%2;%3;%4;%5;%6;%7;%8;%9;%10;%11;%12;%13;%14;%15;%16;%17;%18;%19;%20;%21;%22;%23;%24;%25;%26;%27",
			_className,					//1
			_respectLevel,				//2
			_finalScore,				//3
			_parentClass,               //4
			_displayName,               //5
			_textSingular,              //6 
			_armor,                     //7 
			_armorStructural,           //8 
			_crewExplosionProtection,   //9 
			_explosionShielding,		//10
			_transportAmmo,             //11
			_transportFuel,             //12
			_transportRepair,           //13
			_attendant,                 //14
			_canFloat,                  //15
			_maxSpeed,                  //16
			_maxOmega,                  //17
			_terrainCoef,               //18
			_maximumLoad,               //19
			_armamentsArray,            //20
			_scope,                     //21
			_hiddenSelectionsTextures,  //22
			_defenseScore,				//23
			_utilityScore,				//24
			_mobilityScore,				//25
			_cargoScore,				//26
			_armamentScore				//27
		];
	} else {
		_classArray = format [
			"%1;%2;%3;%4;%5;%6;%7;%8;%9;%10;%11;%12;%13;%14;%15;%16;%17;%18;%19;%20;%21;%22;%23;%24;%25;%26;%27",
			_className,					//1
			_respectLevel,				//2
			_finalScore,				//3
			_parentClass,               //4
			_displayName,               //5
			"",                         //6 _textSingular
			"",                         //7 _armor
			"",                         //8 _armorStructural
			"",                         //9 _crewExplosionProtection
			"",                         //10 _explosionShielding
			_transportAmmo,             //11
			_transportFuel,             //12
			_transportRepair,           //13
			_attendant,                 //14
			"",                         //15 _canFloat
			"",                         //16 _maxSpeed
			"",                         //17 _maxOmega
			"",                         //18 _terrainCoef
			"",                         //19 _maximumLoad
			_armamentsArray,   			//20
			_scope,                     //21
			_hiddenSelectionsTextures,  //22
			_defenseScore,				//23
			_utilityScore,				//24
			_mobilityScore,				//25
			_cargoScore,				//26
			_armamentScore				//27
		];
	};				
		
	_vehArray pushBack _classArray;

	if (_idx >= _progressStep * _chunk) then {
		systemChat format ["Progress: %1%% (%2 / %3)", _progressStep * 10, _idx, _total];
		_progressStep = _progressStep + 1;
	};

	if (EVTCG_DebugMode) then { diag_log format ["Iteration %1: %2", _forEachIndex + 1, _x];};
	if (EVTCG_DebugMode) then { diag_log format ["[DEBUG] Loop %1 finished",_forEachIndex + 1];};
} forEach _cfgVehicles;


// Export the array to the clipboard
//copyToClipboard str _vehArray;
copyToClipboard (_vehArray joinString (toString [10]));

// Notify the user
_outputLog = format ["%1 %2 vehicles have been copied to the clipboard.", count _vehArray, EVTCG_modName];
systemChat _outputLog;
diag_log _outputLog;

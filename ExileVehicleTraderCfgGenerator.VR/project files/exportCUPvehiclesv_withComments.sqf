// Initialize the variables
private [
    "_modName", "_vehArray", "_cfgVehicles", "_userArray", "_className", "_correctClassname",
    "_configPath", "_scope", "_maxSpeed", "_displayName", "_armor", "_armorStructural",
    "_crewExplosionProtection","_explosionShielding", "_transportAmmo", "_transportFuel", "_transportRepair",
    "_attendant", "_canFloat", "_maxOmega", "_terrainCoef", "_maximumLoad", "_hasMainTurret",
    "_hiddenSelectionsTextures", "_classArray"
];
private _vehArray = [];
private _vehParentArray = [];

// HERE we need to give user an option to input their classname array. If the array is empty or invalid, use the default method (get all classnames from cfgVehicles that match _modName

private _userArray = [];
private _debugLog = true;

// Function to determine the weapon type and base price based on the stats
private _calculateScore = {
/* 	
	TODO:
	1. set following params: _armor, _explosionShielding _armorStructural, _crewExplosionProtection, _transportAmmo, _transportFuel, _transportRepair, _attendant, _maxSpeed, _terrainCoef, _maximumLoad, _armaments
	
	2. Calculate defense score, based on _armor, _armorHull, _armorStructural, _crewExplosionProtection:
	Calculate _effectiveArmor by multiplying armor with (1 / _armorStructural)
	then calculate resistance based on how much damage is mitigated through _explosionShielding -> (_effectiveArmor * ((1 - _explosionShielding) + 1)) * 0.5 .
	then calculate resistance based on how much damage is mitigated through _crewExplosionProtection -> (_effectiveArmor * (_crewExplosionProtection + 1)) * 0.3 .
	then sum all numbers for armor score. Then multiply armor score with a new variable which will be used to subjectively inflate the score.
	
	
	3. Calculate supply score, based on _transportAmmo, _transportFuel, _transportRepair, _attendant
	If _transportFuel is 1000000000000 (or 1.00E+12), score should be 5000. If 0 (or 0.00E+00), score should be 0. Would be cool if any value between 0 and 1000000000000 would award points based on percentage (if that even happens, so let's assume it's either zero or trillion and if it is not - then we can calculate)
	_attendant should be calculated in similar manner to _transportFuel, with same max score of 5000
	_transportRepair should be calculated in similar manner to _transportFuel, with max score of 10000
	_transportAmmo should be calculated in similar manner to _transportFuel, with max score of 15000
	
	4. Calculate mobility score, based on _maxSpeed, _terrainCoef
	Speed below 66 is insignificant and should award 0 score.
	Speed between 66-99 is average and should award 2000 score.
	Speed between 100-150 is good and should award 5000 score.
	Speed above 150 is remarkeble and should award 8000 score.

	Then, the score should be multiplied by _terrainCoef divided by 3
	
	5. Calculate cargo score, based on _maximumLoad
	_maximumLoad below 500 should award no score.
	For any point above 500 it should award 10 score per point, up until a maximum of 30000 score.
	
	6. Calculate armament score, based on _armaments
	based on armaments, which need to be extracted from text:
	any VLMG, LMG - 1000
	any VHMG, HMG - 5000
	any VGMG, GMG - 8000
	any vacannon, cannon - 15000
	any missile, igla - 20000

	
	
	
	7. Sum all scores and convert that sum into a number that is rounded up to a ceiling of 100 if score is below 10000 and to ceiling of 1000 if score is above 10000
*/

/* 	General information regarding attributes:
	_armor - value calculated based on the unit armorinconfig * tgtradius. Bigger value does not equal tougher vehicle, but it does indicate amount of total hitpoints ("1 bullet will kill armor <=20" if there are no other damage mitigation stats)
	_armorStructural - acts as a divisor to global damage i.e. higher number = less damage taken. Default is 0.
	_explosionShielding - default 1 - lower number is better
	_crewExplosionProtection - % damage reduction if crew is within range of explosion. default 0 - higher number is better
	_transportAmmo - can rearm. number indicates how much resource it can give away, but the number is usually so high it does not matter (available resource never runs out)
	_transportFuel - can refuel. similar to _transportAmmo
	_transportRepair - can repair. similar to _transportAmmo
	_attendant - can heal wounded soldiers. similar to _transportAmmo
	_maxSpeed - maximum possible speed vehicle can reach while driving on a perfect road
	_terrainCoef - multiplier to maxSpeedCoef. Default is 3.0.
	_maximumLoad - how much units of mass a vehicle can carry. Higher is better, but there is no real default value, only lowest, which is 0.
	_armaments - what is the vehicle armed with. Default is [[[],"",[],""]] which 'isEqualTo 0'
	
*/
    params [
        ["_className", "undefined"],	
		["_displayName", "unnamed"],	
        ["_armor", 0],
        ["_armorStructural", 1],
        ["_explosionShielding", 1],
        ["_crewExplosionProtection", 0],
        ["_transportAmmo", 0],
        ["_transportFuel", 0],
        ["_transportRepair", 0],
        ["_attendant", 0],
        ["_maxSpeed", 0],
        ["_terrainCoef", 3],
        ["_maximumLoad", 0],
        ["_armaments", []]
    ];
	
	private _debugLog = true;
	
	// ========== 1. DEFENSE SCORE ==========
	private _effectiveArmor = 0;
	if (_armorStructural != 0) then {
		_effectiveArmor = _armor * (1 / _armorStructural);
		if (_debugLog) then {diag_log format ["Effective armor calculated: %1", _effectiveArmor];};
	} else {
		if (_debugLog) then {diag_log "ArmorStructural is 0 — cannot calculate effectiveArmor";};
	};

	private _resistanceExplosion = (_effectiveArmor * ((1 - _explosionShielding) + 1)) * 0.5;
	private _resistanceCrewExplosion = (_effectiveArmor * (_crewExplosionProtection + 1)) * 0.3;
	private _defenseMultiplier = 1.25;
	private _defenseScore = (_effectiveArmor + _resistanceExplosion + _resistanceCrewExplosion) * _defenseMultiplier;

	if (_debugLog) then {
		diag_log format ["Defense Score: %1", _defenseScore];
	};

	// ========== 2. SUPPLY SCORE ==========
	private _supplyScore = 0;

	private _ammoScore = 0;
	if (1e12 > 0) then {
		_ammoScore = (_transportAmmo / 1e12) * 15000;
		if (_ammoScore > 15000) then {_ammoScore = 15000};
	};

	private _fuelScore = 0;
	if (1e12 > 0) then {
		_fuelScore = (_transportFuel / 1e12) * 5000;
		if (_fuelScore > 5000) then {_fuelScore = 5000};
	};

	private _repairScore = 0;
	if (1e12 > 0) then {
		_repairScore = (_transportRepair / 1e12) * 10000;
		if (_repairScore > 10000) then {_repairScore = 10000};
	};

	private _attendantScore = 0;
	if (1e12 > 0) then {
		_attendantScore = (_attendant / 1e12) * 5000;
		if (_attendantScore > 5000) then {_attendantScore = 5000};
	};

	_supplyScore = _ammoScore + _fuelScore + _repairScore + _attendantScore;

	if (_debugLog) then {
		diag_log format ["Supply Score: %1", _supplyScore];
	};

	// ========== 3. MOBILITY SCORE ==========
	private _speedScore = 0;
	if (_maxSpeed >= 66 && _maxSpeed < 100) then {_speedScore = 2000};
	if (_maxSpeed >= 100 && _maxSpeed < 150) then {_speedScore = 5000};
	if (_maxSpeed >= 150) then {_speedScore = 8000};

	private _mobilityScore = _speedScore * (_terrainCoef / 3);
	if (_debugLog) then {
		diag_log format ["Mobility Score: %1", _mobilityScore];
	};

	// ========== 4. CARGO SCORE ==========
	private _cargoScore = 0;
	if (_maximumLoad > 500) then {
		_cargoScore = (_maximumLoad - 500) * 10;
		if (_cargoScore > 30000) then {_cargoScore = 30000};
	};

	if (_debugLog) then {
		diag_log format ["Cargo Score: %1", _cargoScore];
	};

	// ========== 5. ARMAMENT SCORE ==========
	private _armamentScore = 0;
	private _unmatchedArmaments = [];
	private _scorePatterns = [
		["vlmg", 1000],
		["lmg", 1000],
		["vhmg", 5000],
		["hmg", 5000],
		["vgmg", 8000],
		["gmg", 8000],
		["vacannon", 15000],
		["cannon", 15000],
		["missile", 20000],
		["igla", 20000]
	];

	private _allWeapons = [];

	{
		{
			if (_x isEqualType []) then {
				{
					if (_x isEqualType "" && {_x != ""}) then {
						_allWeapons pushBack _x;
						if (_debugLog) then {diag_log format ["Flattened weapon: %1", _x];};
					};
				} forEach _x;
			} else {
				if (_x isEqualType "" && {_x != ""}) then {
					_allWeapons pushBack _x;
				};
			};
		} forEach _x;
	} forEach _armaments;

	if (_debugLog) then {diag_log format ["All weapons collected: %1", _allWeapons];};

	{
		private _weap = toLower _x;
		private _matched = false;

		{
			private _pattern = _x select 0;
			private _score = _x select 1;

			if (_weap find _pattern > -1) exitWith {
				_armamentScore = _armamentScore + _score;
				_matched = true;
				if (_debugLog) then {
					diag_log format ["Matched weapon '%1' with pattern '%2' for score %3", _weap, _pattern, _score];
				};
			};
		} forEach _scorePatterns;

		if (!_matched && _debugLog) then {
			diag_log format ["Unmatched weapon: %1", _weap];
		};
	} forEach _allWeapons;

	// ========== 6. FINAL SCORING ==========
	private _totalScore = _defenseScore + _supplyScore + _mobilityScore + _cargoScore + _armamentScore;
	private _finalScore = if (_totalScore < 10000) then {
		ceil (_totalScore / 100) * 100
	} else {
		ceil (_totalScore / 1000) * 1000
	};

	if (_debugLog) then {
		diag_log format ["Total Score: %1 | Final Rounded Score: %2", _totalScore, _finalScore];
	};
	
    _finalScore
};


if ((count _userArray) == 0) then {
	// Determine the part of the classname that user is looking for. If need be, this should work for any other mod outside of vanilla A3
	_modName = "CUP";

	// Get the CfgVehicles class and convert it to an array of config entries
	_cfgVehicles = "true" configClasses (configFile >> "CfgVehicles");
	
} else {
	_cfgVehicles = _userArray;
};
diag_log format ["Before forEach - Type of _vehArray: %1", typeName _vehArray];
diag_log format ["Before forEach - Count of _vehArray: %1", count _vehArray];

// Iterate through each vehicle in CfgVehicles
// ================= LOOP STARTS HERE =================
{
    private _className = configName _x;
    private _correctClassname = true;

    // Check before adding to the array
 //   diag_log format ["Processing: %1", configName _x];  // DEBUG - LAGS!!

    // Filter through the classnames to exclude undesired vehicles
	if ((count _userArray) == 0) then {
		if !(_className find _modName == 0) then {_correctClassname = false;};
	};				  
    if !(toLower _className find "_base" == -1) then {_correctClassname = false;};
    if !(toLower _className find "_item_" == -1) then {_correctClassname = false;};
    if !(toLower _className find "_weapon_" == -1) then {_correctClassname = false;};
    if !(toLower _className find "_lhd_" == -1) then {_correctClassname = false;};
    if !(toLower _className find "_lpd_" == -1) then {_correctClassname = false;};
    if !(toLower _className find "_canopy" == -1) then {_correctClassname = false;};
    if !(toLower _className find "_ejectionseat" == -1) then {_correctClassname = false;};
    if !(toLower _className find "wreck" == -1) then {_correctClassname = false;};

	

    if (_correctClassname) then {
		
		//diag_log format ["Post _correctClassname check: %1", _className];
		
        // Now that we have a correct classname we can perform detailed checks
        private _configPath = configFile >> "CfgVehicles" >> _className;

        private _scope = getNumber (_configPath >> "scope");
        if (_scope isEqualTo 0) then {_correctClassname = false;};
		
		private _maxSpeed = getNumber (_configPath >> "maxSpeed");
        if (_maxSpeed isEqualTo 24) then {_correctClassname = false;};
		
		private _displayName = getText (_configPath >> "displayName");
        if !(toLower _displayName find "ground" == -1 ) then {_correctClassname = false;};
        if !(toLower _displayName find "building" == -1 ) then {_correctClassname = false;};
        if !(toLower _displayName find "house" == -1 ) then {_correctClassname = false;};
        if !(toLower _displayName find "test" == -1 ) then {_correctClassname = false;};
        if !(toLower _displayName find "wreck" == -1) then {_correctClassname = false;};
        //if (_displayName isEqualTo "Wreck") then {_correctClassname = false;};
        if !(toLower (getText (_configPath >> "textSingular")) find "unknown" == -1) then {_correctClassname = false;};


  
        if (_correctClassname) then {
 
			//diag_log format ["Post _correctClassname check: %1", _className];
 
			// we need to move these variables here so they can be read by both outcomes of if _parentClass
			private _transportAmmo = getNumber (_configPath >> "transportAmmo");
			private _transportFuel = getNumber (_configPath >> "transportFuel");
			private _transportRepair = getNumber (_configPath >> "transportRepair");
			private _attendant = getNumber (_configPath >> "attendant");
				
			// HERE we need to add an if condition. But first, we need to get the parent class of the _className
			private _parentConfig = inheritsFrom (configFile >> "CfgVehicles" >> _className);
			private _parentClass = if (isNull _parentConfig) then { "" } else { configName _parentConfig };
			// THEN we need to check if the parent class can be found in _vehParentArray
			if (!(_parentClass in _vehParentArray)) then {
			
				//if there is no such parent in the array, we need to add it first
				_vehParentArray pushback _parentClass;
				
				private _textSingular = getText (_configPath >> "textSingular");
				
				// Then we can proceed to get all data
				private _armor = getNumber (_configPath >> "armor");
				
				// HERE we need to check the stats under (_configPath >> "HitPoints" >> "HitHull")
				private _armorHull = 0.0;
				if (isClass (_configPath >> "HitPoints" >> "HitHull")) then {
					_armorHull = configProperties [_configPath >> "HitPoints" >> "HitHull"];
				};
				private _armorStructural = getNumber (_configPath >> "armorStructural");
				private _crewExplosionProtection = getNumber (_configPath >> "crewExplosionProtection");
				private _explosionShielding = getNumber (_configPath >> "explosionShielding");
				private _canFloat = getNumber (_configPath >> "canFloat");
				private _maxOmega = getNumber (_configPath >> "maxOmega");
				private _terrainCoef = getNumber (_configPath >> "terrainCoef");
				private _maximumLoad = getNumber (_configPath >> "maximumLoad");

				// HERE we need to check what guns are available
				private _armaments = [];
				private _mainTurret = [];
				private _commanderTurret = [];
				private _turretInfoTypeMain = "";
				private _turretInfoTypeCommander = "";
				if (isClass (_configPath >> "Turrets" >> "MainTurret")) then {
					_mainTurret = getArray (_configPath >> "Turrets" >> "MainTurret" >> "weapons");
					_turretInfoTypeMain = getText (_configPath >> "Turrets" >> "MainTurret" >> "turretInfoType");
				};
				
				if (isClass (_configPath >> "Turrets" >> "CommanderOptics")) then {
					_commanderTurret = getArray (_configPath >> "Turrets" >> "CommanderOptics" >> "weapons"); 
					_turretInfoTypeCommander = getText (_configPath >> "Turrets" >> "CommanderOptics" >> "turretInfoType");
				};
				
				_armaments pushback [_mainTurret, _turretInfoTypeMain, _commanderTurret, _turretInfoTypeCommander];

				// Get hiddenSelectionsTextures (if available)
				private _hiddenSelectionsTextures = "";
				if (isArray (_configPath >> "hiddenSelectionsTextures")) then {
					_hiddenSelectionsTextures = getArray (_configPath >> "hiddenSelectionsTextures");
				};

				// Get the score
				private _attributeArray = [
					_className,
					_displayName,
					_armor,
					_armorStructural,
					_explosionShielding,
					_crewExplosionProtection,
					_transportAmmo,
					_transportFuel,
					_transportRepair,
					_attendant,
					_maxSpeed,
					_terrainCoef,
					_maximumLoad,
					_armaments
				];
				
				private _unitScore = _attributeArray call _calculateScore;

				// Create class array and add to vehArray
				private _classArray = format [
					"%1;%2;%3;%4;%5;%6;%7;%8;%9;%10;%11;%12;%13;%14;%15;%16;%17;%18;%19;%20;%21",
					_className,					//1
					_parentClass,               //2
					_displayName,               //3
					_textSingular,              //4
					_armor,                     //5
					_armorStructural,           //6
					_crewExplosionProtection,   //7
					_explosionShielding,		//8
					_transportAmmo,             //9
					_transportFuel,             //10
					_transportRepair,           //11
					_attendant,                 //12
					_canFloat,                  //13
					_maxSpeed,                  //14
					_maxOmega,                  //15
					_terrainCoef,               //16
					_maximumLoad,               //17
					_armaments,                 //18
					_scope,                     //19
					_hiddenSelectionsTextures,  //20
					_unitScore					//21
				];

				_vehArray pushBack _classArray;
				
				// Mark the end of the _classArray for easier identification for search & replace actions
				//_vehArray pushBack ["END"];
			
			} else {	// If parent class has been found in the parents array, we just need some basic information back, since we already got most of it anyway
				
				// HERE we need to check what guns are available
				private _armaments = [];
				private _mainTurret = [];
				private _commanderTurret = [];
				private _turretInfoTypeMain = "";
				private _turretInfoTypeCommander = "";
				if (isClass (_configPath >> "Turrets" >> "MainTurret")) then {
					_mainTurret = getArray (_configPath >> "Turrets" >> "MainTurret" >> "weapons");
					_turretInfoTypeMain = getText (_configPath >> "Turrets" >> "MainTurret" >> "turretInfoType");
				};
				
				if (isClass (_configPath >> "Turrets" >> "CommanderOptics")) then {
					_commanderTurret = getArray (_configPath >> "Turrets" >> "CommanderOptics" >> "weapons"); 
					_turretInfoTypeCommander = getText (_configPath >> "Turrets" >> "CommanderOptics" >> "turretInfoType");
				};
				
				_armaments pushback [_mainTurret, _turretInfoTypeMain, _commanderTurret, _turretInfoTypeCommander];

				
				// Get hiddenSelectionsTextures (if available)
				private _hiddenSelectionsTextures = "";
				if (isArray (_configPath >> "hiddenSelectionsTextures")) then {
					_hiddenSelectionsTextures = getArray (_configPath >> "hiddenSelectionsTextures");
				};
				
				// Get the score
				private _attributeArray = [
					_className,
					_displayName,
					_armor,
					_armorStructural,
					_explosionShielding,
					_crewExplosionProtection,
					_transportAmmo,
					_transportFuel,
					_transportRepair,
					_attendant,
					_maxSpeed,
					_terrainCoef,
					_maximumLoad,
					_armaments
				];
				
				private _unitScore = _attributeArray call _calculateScore;
				
				// Create class array and add to vehArray
				private _classArray = format [
					"%1;%2;%3;%4;%5;%6;%7;%8;%9;%10;%11;%12;%13;%14;%15;%16;%17;%18;%19;%20;%21",
					_className,					//1
					_parentClass,               //2
					_displayName,               //3
					"",                         //4 _textSingular
					"",                         //5 _armor
					"",                         //6 _armorStructural
					"",                         //7 _crewExplosionProtection
					"",                         //8 _explosionShielding
					_transportAmmo,             //9
					_transportFuel,             //10
					_transportRepair,           //11
					_attendant,                 //12
					"",                         //13 _canFloat
					"",                         //14 _maxSpeed
					"",                         //15 _maxOmega
					"",                         //16 _terrainCoef
					"",                         //17 _maximumLoad
					_armaments,                 //18
					_scope,                     //19
					_hiddenSelectionsTextures,  //20
					_unitScore					//21
				];


				
				//diag_log format ["Adding to array: %1", _classArray];
				
				// Mark the end of the _classArray for easier identification for search & replace actions
				//_vehArray pushBack ["END"];
				//diag_log format ["Array after pushBack: %1", _vehArray];
			};
        };
    };
} forEach _cfgVehicles;


// Export the array to the clipboard
//copyToClipboard str _vehArray;
copyToClipboard (_vehArray joinString (toString [10]));

// Notify the user
hint format ["%1 %2 vehicles have been copied to the clipboard.", count _vehArray, _modName];
diag_log format ["%1 %2 vehicles have been copied to the clipboard.", count _vehArray, _modName];

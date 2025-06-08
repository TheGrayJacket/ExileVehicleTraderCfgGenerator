// Determine the part of the classname that user is looking for. If need be, this should work for any other mod outside of vanilla A3
private _modName = "CUP";

// Initialize the array to store CUP vehicle information arrays
private _vehArray = [];

// Get the CfgVehicles class and convert it to an array of config entries
private _cfgVehicles = "true" configClasses (configFile >> "CfgVehicles");

// Iterate through each vehicle in CfgVehicles
{
    private _className = configName _x;
    private _correctClassname = true;

    // Filter through the classnames to exclude undesired vehicles
    if !(_className find _modName == 0) then {_correctClassname = false;};
    if !(_className find "_BASE" == -1) then {_correctClassname = false;};
    if !(_className find "_base" == -1) then {_correctClassname = false;};
    if !(_className find "_Item_" == -1) then {_correctClassname = false;};
    if !(_className find "_item_" == -1) then {_correctClassname = false;};
    if !(_className find "_Weapon_" == -1) then {_correctClassname = false;};
    if !(_className find "_weapon_" == -1) then {_correctClassname = false;};
    if !(_className find "_LHD_" == -1) then {_correctClassname = false;};
    if !(_className find "_LPD_" == -1) then {_correctClassname = false;};
    if !(_className find "_Canopy" == -1) then {_correctClassname = false;};
    if !(_className find "_EjectionSeat" == -1) then {_correctClassname = false;};

	

    if (_correctClassname) then {
 
        // Now that we have a correct classname we can perform detailed checks
        private _configPath = configFile >> "CfgVehicles" >> _className;

        private _scope = getNumber (_configPath >> "scope");
        if (_scope isEqualTo 0) then {_correctClassname = false;};
		
		private _maxSpeed = getNumber (_configPath >> "maxSpeed");
        if (_maxSpeed isEqualTo 24) then {_correctClassname = false;};
		
		private _displayName = getText (_configPath >> "displayName");
        if (_displayName isEqualTo "Ground") then {_correctClassname = false;};
        if (_displayName isEqualTo "Building") then {_correctClassname = false;};
        if (_displayName isEqualTo "House") then {_correctClassname = false;};
        if (_displayName isEqualTo "TEST") then {_correctClassname = false;};
        if (_displayName isEqualTo "Wreck") then {_correctClassname = false;};



  
        if (_correctClassname) then {
 
 
 
            // Get vehicle parameters
            //private _displayName = getText (_configPath >> "displayName");
            private _armor = getNumber (_configPath >> "armor");
            private _armorStructural = getNumber (_configPath >> "armorStructural");
            private _crewExplosionProtection = getNumber (_configPath >> "crewExplosionProtection");
            private _transportAmmo = getNumber (_configPath >> "transportAmmo");
            private _transportFuel = getNumber (_configPath >> "transportFuel");
            private _transportRepair = getNumber (_configPath >> "transportRepair");
            private _attendant = getNumber (_configPath >> "attendant");
            private _canFloat = getNumber (_configPath >> "canFloat");
            //private _maxSpeed = getNumber (_configPath >> "maxSpeed");
            private _maxOmega = getNumber (_configPath >> "maxOmega");
            private _terrainCoef = getNumber (_configPath >> "terrainCoef");
            private _maximumLoad = getNumber (_configPath >> "maximumLoad");

            // Check if the vehicle has a MainTurret
            private _hasMainTurret = false;
            if (isClass (_configPath >> "Turrets" >> "MainTurret")) then {
                _hasMainTurret = true;
            };

            // Get hiddenSelectionsTextures (if available)
            private _hiddenSelectionsTextures = "";
            if (isArray (_configPath >> "hiddenSelectionsTextures")) then {
                _hiddenSelectionsTextures = getArray (_configPath >> "hiddenSelectionsTextures");
            };

            // Create class array and add to vehArray
            private _classArray = format ["%1;%2;%3;%4;%5;%6;%7;%8;%9;%10;%11;%12;%13;%14;%15;%16;%17", _className, _displayName, _armor, _armorStructural, _crewExplosionProtection, _transportAmmo, _transportFuel, _transportRepair, _attendant, _canFloat, _maxSpeed, _maxOmega, _terrainCoef, _maximumLoad, _hasMainTurret, _scope, _hiddenSelectionsTextures];
            _vehArray pushBack _classArray;
            
            // Mark the end of the _classArray for easier identification for search & replace actions
            _vehArray pushBack ["END"];
        };
    };
} forEach _cfgVehicles;


// Export the array to the clipboard
copyToClipboard str _vehArray;

// Notify the user
hint format ["%1 %2 vehicles have been copied to the clipboard.", (count _vehArray) / 2, _modName];

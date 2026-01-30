/*
 * IdleAI-Extended
 * A pure idle AI for OpenTTD
 * Author: TransshipmentEnvoy
 */

require("version.nut");

class IdleAIExtendedInfo extends AIInfo {
  function GetAuthor()      { return "TransshipmentEnvoy"; }
  function GetName()        { return "IdleAI-Extended"; }
  function GetShortName()   { return "IDLX"; }
  function GetVersion()     { return SELF_VERSION; }
  function GetDescription() { return "A pure idle AI that only sets company info then sleeps forever. Compatible with save/load."; }
  function GetAPIVersion()  { return "15"; }
  function CreateInstance() { return "IdleAIExtended"; }
  function UseAsRandomAI()  { return true; }
  
  function MinVersionToLoad() { return SELF_MINLOADVERSION; }
  
  function GetDate() { return SELF_DATE; }
}

/* Register the AI with OpenTTD */
RegisterAI(IdleAIExtendedInfo());

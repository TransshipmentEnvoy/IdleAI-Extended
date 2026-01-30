/*
 * IdleAI-Extended Main Controller
 * A pure idle AI that sets company info and sleeps forever
 * Author: TransshipmentEnvoy
 */

require("version.nut");

// Import ToyLib
require("dep/AIToyLib/main.nut")
import("Library.SCPLib", "SCPLib", 45);

class IdleAIExtended extends AIController {
  // State variables (persisted via Save/Load)
  company_name = null;
  manager_name = null;
  president_gender = null;
  primary_color = null;
  secondary_color = null;
  initialized = null;
  toy_lib = null;
  received_exemption = null;

  constructor() {
    this.company_name = "";
    this.manager_name = "";
    this.president_gender = AICompany.GENDER_MALE;
    this.primary_color = -1;
    this.secondary_color = -1;
    this.initialized = false;
    this.toy_lib = null;
    this.received_exemption = false;
  }

  /*
   * Callback for exemption confirmation from GS via AIToyLib
   */
  function ConfirmExemption(message, self) {
    local result = (message.Data[0] == 0);
    self.received_exemption = result;
    AILog.Info("Exemption status confirmed: " + (result ? "GRANTED" : "DENIED"));
    return result;
  }

  /*
   * Ask for exemption from GS. Returns true if request was sent, false otherwise.
   */
  function AskForExemption() {
    if (this.toy_lib == null) {
      AILog.Warning("AIToyLib not initialized, cannot ask for exemption");
      return false;
    }
    if (this.received_exemption) {
      AILog.Info("Already received exemption, skipping request");
      return false;
    }
    local status = true;
    AILog.Info("Requesting exemption with status: " + status);
    AIToyLib.AskExemption(status);
    return true;
  }
  
  /*
   * Main entry point - called by OpenTTD when the AI starts
   */
  function Start() {
    // Initialize company if not already done
    if (!this.initialized) {
      this.Init();
    }

    // Initialize AIToyLib for SCP communication
    this.toy_lib = AIToyLib(null, this);
    AILog.Info("AIToyLib initialized for exemption requests");
    this.AskForExemption();

    // Pure idle loop - sleep forever
    AILog.Info("IdleAI-Extended v" + SELF_MAJORVERSION + "." + SELF_MINORVERSION + " is now idle. Company: " + this.company_name);
    while (true) {
      // Process SCP events for AIToyLib
      AIToyLib.Check();
      AIController.Sleep(1000);  // Sleep for 1000 ticks
    }
  }
  
  /*
   * Initialize company settings (random names and colors)
   */
  function Init() {
    // Random company names (business-like)
    local company_names = [
      "Pacific Railway",
      "Continental Express",
      "Global Transport",
      "Atlantic Shipping",
      "Unity Logistics",
      "Horizon Freight",
      "Summit Transit",
      "Pioneer Lines",
      "Sterling Transport",
      "Meridian Cargo"
    ];
    
    // Random manager names with gender mapping
    local manager_pool = [
      {name = "John Smith", gender = AICompany.GENDER_MALE},
      {name = "Emma Wilson", gender = AICompany.GENDER_FEMALE},
      {name = "Michael Chen", gender = AICompany.GENDER_MALE},
      {name = "Sarah Johnson", gender = AICompany.GENDER_FEMALE},
      {name = "David Brown", gender = AICompany.GENDER_MALE},
      {name = "Lisa Anderson", gender = AICompany.GENDER_FEMALE},
      {name = "Robert Taylor", gender = AICompany.GENDER_MALE},
      {name = "Jennifer Lee", gender = AICompany.GENDER_FEMALE},
      {name = "William Davis", gender = AICompany.GENDER_MALE},
      {name = "Maria Garcia", gender = AICompany.GENDER_FEMALE}
    ];
    
    // Random color choices
    local color_pool = [
      AICompany.COLOUR_DARK_BLUE,
      AICompany.COLOUR_PALE_GREEN,
      AICompany.COLOUR_PINK,
      AICompany.COLOUR_YELLOW,
      AICompany.COLOUR_RED,
      AICompany.COLOUR_LIGHT_BLUE,
      AICompany.COLOUR_GREEN,
      AICompany.COLOUR_DARK_GREEN,
      AICompany.COLOUR_BLUE,
      AICompany.COLOUR_CREAM,
      AICompany.COLOUR_MAUVE,
      AICompany.COLOUR_PURPLE,
      AICompany.COLOUR_ORANGE,
      AICompany.COLOUR_BROWN,
      AICompany.COLOUR_GREY,
      AICompany.COLOUR_WHITE
    ];
    
    // Select random company name using AIBase.RandRange
    local company_idx = AIBase.RandRange(company_names.len());
    this.company_name = company_names[company_idx];
    AILog.Info("Selected company name: " + this.company_name + " (index: " + company_idx + ")");
    
    // Select random manager
    local manager_idx = AIBase.RandRange(manager_pool.len());
    local manager = manager_pool[manager_idx];
    this.manager_name = manager.name;
    this.president_gender = manager.gender;
    AILog.Info("Selected manager: " + this.manager_name + " (index: " + manager_idx + ")");
    
    // Select random colors (ensure they're different)
    local color_idx1 = AIBase.RandRange(color_pool.len());
    local color_idx2 = AIBase.RandRange(color_pool.len());
    // Keep generating random second color until it's different from first
    while (color_idx1 == color_idx2) {
      color_idx2 = AIBase.RandRange(color_pool.len());
    }
    this.primary_color = color_pool[color_idx1];
    this.secondary_color = color_pool[color_idx2];
    AILog.Info("Selected colors: primary index " + color_idx1 + ", secondary index " + color_idx2);
    
    // Apply settings
    AICompany.SetName(this.company_name);
    AICompany.SetPresidentName(this.manager_name);
    AICompany.SetPresidentGender(this.president_gender);
    
    // Apply colors to all livery schemes
    this.ApplyLiveryColors();
    
    // Set loan to 0 (repay all)
    this.RepayAllLoans();

    this.initialized = true;

    AILog.Info("Company initialized: " + this.company_name);
    AILog.Info("President: " + this.manager_name);
  }
  
  /*
   * Apply colors to all livery schemes
   */
  function ApplyLiveryColors() {
    // List of all livery schemes
    local schemes = [
      AICompany.LS_DEFAULT,
      AICompany.LS_STEAM,
      AICompany.LS_DIESEL,
      AICompany.LS_ELECTRIC,
      AICompany.LS_MONORAIL,
      AICompany.LS_MAGLEV,
      AICompany.LS_DMU,
      AICompany.LS_EMU,
      AICompany.LS_PASSENGER_WAGON_STEAM,
      AICompany.LS_PASSENGER_WAGON_DIESEL,
      AICompany.LS_PASSENGER_WAGON_ELECTRIC,
      AICompany.LS_PASSENGER_WAGON_MONORAIL,
      AICompany.LS_PASSENGER_WAGON_MAGLEV,
      AICompany.LS_FREIGHT_WAGON,
      AICompany.LS_BUS,
      AICompany.LS_TRUCK,
      AICompany.LS_PASSENGER_SHIP,
      AICompany.LS_FREIGHT_SHIP,
      AICompany.LS_HELICOPTER,
      AICompany.LS_SMALL_PLANE,
      AICompany.LS_LARGE_PLANE,
      AICompany.LS_PASSENGER_TRAM,
      AICompany.LS_FREIGHT_TRAM
    ];
    
    foreach (scheme in schemes) {
      AICompany.SetPrimaryLiveryColour(scheme, this.primary_color);
      AICompany.SetSecondaryLiveryColour(scheme, this.secondary_color);
    }
  }
  
  /*
   * Repay all loans (set to 0)
   */
  function RepayAllLoans() {
    local current_loan = AICompany.GetLoanAmount();
    if (current_loan > 0) {
      AICompany.SetLoanAmount(0);
      AILog.Info("Repaid all loans. Previous amount: " + current_loan);
    }
  }
  
  /*
   * Save state - called when game is saved
   */
  function Save() {
    AILog.Info("Saving AI state...");
    return {
      company_name = this.company_name,
      manager_name = this.manager_name,
      president_gender = this.president_gender,
      primary_color = this.primary_color,
      secondary_color = this.secondary_color,
      initialized = this.initialized,
      received_exemption = this.received_exemption
    };
  }
  
  /*
   * Load state - called when game is loaded
   */
  function Load(version, data) {
    AILog.Info("Loading AI state (save version " + version + ", AI version " + SELF_MAJORVERSION + "." + SELF_MINORVERSION + ")...");
    
    if (data == null) {
      AILog.Warning("No saved data found, will reinitialize");
      this.initialized = false;
      return;
    }
    
    // Restore all state variables
    if ("company_name" in data) {
      this.company_name = data.company_name;
    }
    if ("manager_name" in data) {
      this.manager_name = data.manager_name;
    }
    if ("president_gender" in data) {
      this.president_gender = data.president_gender;
    }
    if ("primary_color" in data) {
      this.primary_color = data.primary_color;
    }
    if ("secondary_color" in data) {
      this.secondary_color = data.secondary_color;
    }
    if ("initialized" in data) {
      this.initialized = data.initialized;
    }
    if ("received_exemption" in data) {
      this.received_exemption = data.received_exemption;
    }

    AILog.Info("State loaded successfully");
  }
}

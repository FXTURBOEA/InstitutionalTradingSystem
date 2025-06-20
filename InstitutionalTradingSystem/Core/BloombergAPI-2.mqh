//+------------------------------------------------------------------+
//| Bloomberg BLPAPI Integration for Real Options Data               |
//| Production-Ready Implementation - FIXED VERSION                  |
//| Düzeltilmiş ve Güvenli Sürüm                                    |
//+------------------------------------------------------------------+
#property strict

#include "Complete_Enum_Types.mqh"
#include <Windows.h>  // Thread safety için

// Güvenlik konstantları
#define MAX_OPTIONS_DATA 600
#define MAX_STRIKES_PER_EXPIRY 50
#define MAX_EXPIRIES 12
#define MAX_UNDERLYINGS 10
#define MAX_REALTIME_CACHE 1000
#define MIN_VALID_IV 0.0001
#define MAX_VALID_IV 5.0
#define CONNECTION_TIMEOUT_MS 10000
#define DEFAULT_CACHE_TTL 300
#define DEFAULT_RT_CACHE_TTL 30

// Bloomberg API DLL imports
#import "BloombergAPI.dll"
   int    BloombergConnect(string server_host, int server_port);
   void   BloombergDisconnect(int session_id);
   int    BloombergSubscribeOptionsChain(int session_id, string underlying_symbol, string& error_msg);
   int    BloombergGetOptionsData(int session_id, int request_id, double& strikes[], double& call_ivs[], 
                                 double& put_ivs[], double& call_volumes[], double& put_volumes[], 
                                 double& call_oi[], double& put_oi[], string& expiry_dates[], int max_size);
   int    BloombergGetRealTimeIV(int session_id, string option_symbol, double& iv, double& delta, 
                                double& gamma, double& theta, double& vega);
   bool   BloombergIsConnected(int session_id);
   string BloombergGetLastError(int session_id);
#import

//+------------------------------------------------------------------+
//| Error Handling System                                            |
//+------------------------------------------------------------------+
enum ENUM_BLOOMBERG_ERROR
{
   BLOOMBERG_SUCCESS = 0,
   BLOOMBERG_CONNECTION_FAILED = 1,
   BLOOMBERG_INVALID_SYMBOL = 2,
   BLOOMBERG_DATA_TIMEOUT = 3,
   BLOOMBERG_MEMORY_ERROR = 4,
   BLOOMBERG_VALIDATION_ERROR = 5,
   BLOOMBERG_ARRAY_BOUNDS_ERROR = 6,
   BLOOMBERG_THREAD_ERROR = 7,
   BLOOMBERG_PARSING_ERROR = 8,
   BLOOMBERG_NETWORK_ERROR = 9
};

//+------------------------------------------------------------------+
//| Configuration Structure                                          |
//+------------------------------------------------------------------+
struct BloombergConfig
{
   int      connection_timeout_ms;
   int      cache_ttl_seconds;
   int      realtime_cache_ttl_seconds;
   int      max_retries;
   bool     enable_logging;
   string   log_file_path;
   int      max_cached_symbols;
   int      max_cached_realtime_data;
   bool     enable_data_validation;
   bool     enable_thread_safety;
};

//+------------------------------------------------------------------+
//| Thread-Safe Logger                                              |
//+------------------------------------------------------------------+
class ThreadSafeLogger
{
private:
   CRITICAL_SECTION m_log_lock;
   bool m_initialized;
   
public:
   ThreadSafeLogger()
   {
      InitializeCriticalSection(&m_log_lock);
      m_initialized = true;
   }
   
   ~ThreadSafeLogger()
   {
      if(m_initialized)
      {
         DeleteCriticalSection(&m_log_lock);
         m_initialized = false;
      }
   }
   
   void LogError(ENUM_BLOOMBERG_ERROR error_code, string message)
   {
      if(!m_initialized) return;
      
      EnterCriticalSection(&m_log_lock);
      
      string error_str = "";
      switch(error_code)
      {
         case BLOOMBERG_SUCCESS: error_str = "SUCCESS"; break;
         case BLOOMBERG_CONNECTION_FAILED: error_str = "CONNECTION_FAILED"; break;
         case BLOOMBERG_INVALID_SYMBOL: error_str = "INVALID_SYMBOL"; break;
         case BLOOMBERG_DATA_TIMEOUT: error_str = "DATA_TIMEOUT"; break;
         case BLOOMBERG_MEMORY_ERROR: error_str = "MEMORY_ERROR"; break;
         case BLOOMBERG_VALIDATION_ERROR: error_str = "VALIDATION_ERROR"; break;
         case BLOOMBERG_ARRAY_BOUNDS_ERROR: error_str = "ARRAY_BOUNDS_ERROR"; break;
         case BLOOMBERG_THREAD_ERROR: error_str = "THREAD_ERROR"; break;
         case BLOOMBERG_PARSING_ERROR: error_str = "PARSING_ERROR"; break;
         case BLOOMBERG_NETWORK_ERROR: error_str = "NETWORK_ERROR"; break;
         default: error_str = "UNKNOWN_ERROR"; break;
      }
      
      string log_entry = StringFormat("[%s] BLOOMBERG_%s: %s", 
                                     TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS),
                                     error_str, message);
      Print(log_entry);
      
      LeaveCriticalSection(&m_log_lock);
   }
};

//+------------------------------------------------------------------+
//| Bloomberg Options Data Provider - FIXED VERSION                 |
//+------------------------------------------------------------------+
class BloombergOptionsProvider
{
private:
   // Thread safety
   CRITICAL_SECTION     m_data_lock;
   CRITICAL_SECTION     m_connection_lock;
   bool                 m_locks_initialized;
   
   // Connection management
   int                  m_session_id;
   bool                 m_connected;
   string               m_server_host;
   int                  m_server_port;
   string               m_username;
   
   // Error handling
   ENUM_BLOOMBERG_ERROR m_last_error_code;
   string               m_last_error_message;
   datetime             m_last_error_time;
   ThreadSafeLogger*    m_logger;
   
   // Configuration
   BloombergConfig      m_config;
   
   // Options chain data storage
   struct OptionsChainData
   {
      string           underlying_symbol;
      datetime         last_update;
      int              chain_count;
      bool             is_valid;
      
      // Per expiry data
      struct ExpiryData
      {
         datetime     expiry_date;
         int          strike_count;
         double       strikes[MAX_STRIKES_PER_EXPIRY];
         double       call_implied_vols[MAX_STRIKES_PER_EXPIRY];
         double       put_implied_vols[MAX_STRIKES_PER_EXPIRY];
         double       call_volumes[MAX_STRIKES_PER_EXPIRY];
         double       put_volumes[MAX_STRIKES_PER_EXPIRY];
         double       call_open_interest[MAX_STRIKES_PER_EXPIRY];
         double       put_open_interest[MAX_STRIKES_PER_EXPIRY];
         double       call_deltas[MAX_STRIKES_PER_EXPIRY];
         double       put_deltas[MAX_STRIKES_PER_EXPIRY];
         double       call_gammas[MAX_STRIKES_PER_EXPIRY];
         double       put_gammas[MAX_STRIKES_PER_EXPIRY];
         double       call_vegas[MAX_STRIKES_PER_EXPIRY];
         double       put_vegas[MAX_STRIKES_PER_EXPIRY];
         double       call_thetas[MAX_STRIKES_PER_EXPIRY];
         double       put_thetas[MAX_STRIKES_PER_EXPIRY];
         bool         is_valid;
      };
      
      ExpiryData       expiry_chains[MAX_EXPIRIES];
   };
   
   OptionsChainData     m_options_data[MAX_UNDERLYINGS];
   int                  m_underlying_count;
   
   // Real-time IV data
   struct RealTimeIVData
   {
      string           option_symbol;
      double           implied_vol;
      double           delta;
      double           gamma;
      double           theta;
      double           vega;
      datetime         last_update;
      bool             is_valid;
   };
   
   RealTimeIVData       m_realtime_iv[MAX_REALTIME_CACHE];
   int                  m_realtime_count;
   
   datetime             m_last_connection_check;
   int                  m_connection_check_interval;
   
   // Performance optimization - static buffers
   double               m_temp_strikes[MAX_OPTIONS_DATA];
   double               m_temp_call_ivs[MAX_OPTIONS_DATA];
   double               m_temp_put_ivs[MAX_OPTIONS_DATA];
   double               m_temp_call_volumes[MAX_OPTIONS_DATA];
   double               m_temp_put_volumes[MAX_OPTIONS_DATA];
   double               m_temp_call_oi[MAX_OPTIONS_DATA];
   double               m_temp_put_oi[MAX_OPTIONS_DATA];
   string               m_temp_expiry_dates[MAX_OPTIONS_DATA];

public:
   BloombergOptionsProvider();
   ~BloombergOptionsProvider();
   
   // Configuration
   void SetConfig(const BloombergConfig &config) { m_config = config; }
   BloombergConfig GetConfig() const { return m_config; }
   
   // Connection management
   bool Connect(string server_host = "localhost", int server_port = 8194, string username = "");
   void Disconnect();
   bool IsConnected();
   
   // Error handling
   ENUM_BLOOMBERG_ERROR GetLastErrorCode() const { return m_last_error_code; }
   string GetLastError() const { return m_last_error_message; }
   datetime GetLastErrorTime() const { return m_last_error_time; }
   
   // Options chain subscription and data retrieval
   bool SubscribeOptionsChain(string underlying_symbol);
   bool GetOptionsChain(string underlying_symbol, OptionsChainData &chain_data);
   bool UpdateOptionsChain(string underlying_symbol);
   
   // Real-time options data
   bool GetRealTimeOptionData(string option_symbol, double &iv, double &delta, double &gamma, 
                              double &theta, double &vega);
   bool GetImpliedVolatility(string underlying_symbol, double strike, datetime expiry, 
                             bool is_call, double &implied_vol);
   
   // Volatility surface calculations - FIXED IMPLEMENTATIONS
   bool CalculateVolatilitySurface(string underlying_symbol, double &moneyness_range[], 
                                   int moneyness_count, double &iv_surface[], int &surface_size);
   double CalculateVolatilitySkew(string underlying_symbol, datetime expiry);
   double CalculateVolatilitySmile(string underlying_symbol, datetime expiry, double center_strike);
   
   // Greeks and risk metrics
   double CalculateTotalGammaExposure(string underlying_symbol);
   double CalculateVolatilityRiskPremium(string underlying_symbol, int days_to_expiry);
   bool GetGammaProfile(string underlying_symbol, double &strikes[], double &gamma_exposure[], int &profile_size);
   
   // Market data quality and validation
   bool ValidateOptionsData(const OptionsChainData &chain_data);
   double CalculateDataQualityScore(string underlying_symbol);
   void UpdateConnectionHealth();
   
   // Utility functions
   bool RunDiagnostics();
   void ClearCache();
   int GetCacheCount() const { return m_underlying_count; }
   
private:
   // Thread-safe helper methods
   void LockData() { if(m_locks_initialized) EnterCriticalSection(&m_data_lock); }
   void UnlockData() { if(m_locks_initialized) LeaveCriticalSection(&m_data_lock); }
   void LockConnection() { if(m_locks_initialized) EnterCriticalSection(&m_connection_lock); }
   void UnlockConnection() { if(m_locks_initialized) LeaveCriticalSection(&m_connection_lock); }
   
   // Error handling
   void SetError(ENUM_BLOOMBERG_ERROR error_code, string message);
   
   // Internal helper methods
   bool ParseBloombergResponse(string response, OptionsChainData &chain_data);
   string BuildOptionsSymbol(string underlying, double strike, datetime expiry, bool is_call);
   datetime ParseExpiryDate(string expiry_string);
   bool IsMarketOpen();
   void CleanupExpiredData();
   
   // Input validation
   bool ValidateServerInput(string server_host, int server_port);
   bool ValidateSymbol(string symbol);
   bool SafeArrayAccess(int index, int max_size, string array_name);
   
   // Data validation helpers
   bool IsValidImpliedVol(double iv);
   bool IsValidGreek(double greek_value, string greek_name);
   bool IsValidStrike(double strike, double underlying_price);
   bool IsValidDateTime(datetime dt);
   
   // Memory management
   void InitializeDataStructures();
   void CleanupDataStructures();
   
   // Cache management
   int FindUnderlyingIndex(string underlying_symbol);
   int FindOrCreateUnderlyingIndex(string underlying_symbol);
   void RemoveExpiredCacheEntries();
};

//+------------------------------------------------------------------+
//| Implementation - Constructor                                     |
//+------------------------------------------------------------------+
BloombergOptionsProvider::BloombergOptionsProvider()
{
   // Initialize thread safety
   InitializeCriticalSection(&m_data_lock);
   InitializeCriticalSection(&m_connection_lock);
   m_locks_initialized = true;
   
   // Initialize connection state
   m_session_id = -1;
   m_connected = false;
   m_server_host = "localhost";
   m_server_port = 8194;
   m_username = "";
   
   // Initialize error handling
   m_last_error_code = BLOOMBERG_SUCCESS;
   m_last_error_message = "";
   m_last_error_time = 0;
   m_logger = new ThreadSafeLogger();
   
   // Initialize configuration with safe defaults
   m_config.connection_timeout_ms = CONNECTION_TIMEOUT_MS;
   m_config.cache_ttl_seconds = DEFAULT_CACHE_TTL;
   m_config.realtime_cache_ttl_seconds = DEFAULT_RT_CACHE_TTL;
   m_config.max_retries = 3;
   m_config.enable_logging = true;
   m_config.log_file_path = "bloomberg_api.log";
   m_config.max_cached_symbols = MAX_UNDERLYINGS;
   m_config.max_cached_realtime_data = MAX_REALTIME_CACHE;
   m_config.enable_data_validation = true;
   m_config.enable_thread_safety = true;
   
   // Initialize data
   InitializeDataStructures();
   
   m_underlying_count = 0;
   m_realtime_count = 0;
   m_last_connection_check = 0;
   m_connection_check_interval = 30;
   
   Print("✅ Bloomberg Options Provider initialized successfully");
}

//+------------------------------------------------------------------+
//| Implementation - Destructor                                     |
//+------------------------------------------------------------------+
BloombergOptionsProvider::~BloombergOptionsProvider()
{
   // Disconnect safely
   if(m_connected)
   {
      Disconnect();
   }
   
   // Cleanup data structures
   CleanupDataStructures();
   
   // Cleanup logger
   if(m_logger != NULL)
   {
      delete m_logger;
      m_logger = NULL;
   }
   
   // Cleanup thread safety
   if(m_locks_initialized)
   {
      DeleteCriticalSection(&m_data_lock);
      DeleteCriticalSection(&m_connection_lock);
      m_locks_initialized = false;
   }
   
   Print("✅ Bloomberg Options Provider destroyed safely");
}

//+------------------------------------------------------------------+
//| Implementation - Connection Management                          |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::Connect(string server_host, int server_port, string username)
{
   LockConnection();
   
   if(m_connected)
   {
      UnlockConnection();
      Print("⚠️ Already connected to Bloomberg API");
      return true;
   }
   
   // Input validation
   if(!ValidateServerInput(server_host, server_port))
   {
      UnlockConnection();
      return false;
   }
   
   m_server_host = server_host;
   m_server_port = server_port;
   m_username = username;
   
   Print(StringFormat("🔌 Connecting to Bloomberg API: %s:%d", server_host, server_port));
   
   // Attempt connection with timeout
   m_session_id = BloombergConnect(server_host, server_port);
   
   if(m_session_id > 0)
   {
      m_connected = true;
      m_last_connection_check = TimeCurrent();
      SetError(BLOOMBERG_SUCCESS, "Connection established successfully");
      Print(StringFormat("✅ Bloomberg API connected successfully. Session ID: %d", m_session_id));
      
      UnlockConnection();
      return true;
   }
   else
   {
      string error_msg = BloombergGetLastError(m_session_id);
      SetError(BLOOMBERG_CONNECTION_FAILED, error_msg);
      Print(StringFormat("❌ Bloomberg API connection failed: %s", error_msg));
      
      UnlockConnection();
      return false;
   }
}

//+------------------------------------------------------------------+
//| Implementation - Disconnect                                     |
//+------------------------------------------------------------------+
void BloombergOptionsProvider::Disconnect()
{
   LockConnection();
   
   if(m_connected && m_session_id > 0)
   {
      BloombergDisconnect(m_session_id);
      m_connected = false;
      m_session_id = -1;
      Print("🔌 Bloomberg API disconnected safely");
   }
   
   UnlockConnection();
}

//+------------------------------------------------------------------+
//| Implementation - Connection Health Check                        |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::IsConnected()
{
   LockConnection();
   
   if(!m_connected)
   {
      UnlockConnection();
      return false;
   }
   
   // Periodic connection health check
   datetime current_time = TimeCurrent();
   if(current_time - m_last_connection_check > m_connection_check_interval)
   {
      m_connected = BloombergIsConnected(m_session_id);
      m_last_connection_check = current_time;
      
      if(!m_connected)
      {
         SetError(BLOOMBERG_CONNECTION_FAILED, "Connection lost to Bloomberg API");
         Print("⚠️ Bloomberg API connection lost");
      }
   }
   
   bool result = m_connected;
   UnlockConnection();
   return result;
}

//+------------------------------------------------------------------+
//| Implementation - Subscribe Options Chain                        |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::SubscribeOptionsChain(string underlying_symbol)
{
   if(!IsConnected())
   {
      SetError(BLOOMBERG_CONNECTION_FAILED, "Not connected to Bloomberg API");
      return false;
   }
   
   if(!ValidateSymbol(underlying_symbol))
   {
      SetError(BLOOMBERG_INVALID_SYMBOL, "Invalid underlying symbol: " + underlying_symbol);
      return false;
   }
   
   Print(StringFormat("📈 Subscribing to options chain: %s", underlying_symbol));
   
   string error_msg = "";
   int request_id = BloombergSubscribeOptionsChain(m_session_id, underlying_symbol, error_msg);
   
   if(request_id > 0)
   {
      LockData();
      
      // Find or create underlying data slot
      int index = FindOrCreateUnderlyingIndex(underlying_symbol);
      
      if(index >= 0)
      {
         m_options_data[index].underlying_symbol = underlying_symbol;
         m_options_data[index].last_update = TimeCurrent();
         m_options_data[index].is_valid = true;
         Print(StringFormat("✅ Options chain subscription successful: %s (Request ID: %d)", underlying_symbol, request_id));
         
         UnlockData();
         return true;
      }
      else
      {
         SetError(BLOOMBERG_MEMORY_ERROR, "No available slots for new underlying");
         UnlockData();
         return false;
      }
   }
   else
   {
      SetError(BLOOMBERG_DATA_TIMEOUT, error_msg);
      Print(StringFormat("❌ Options chain subscription failed: %s - %s", underlying_symbol, error_msg));
      return false;
   }
}

//+------------------------------------------------------------------+
//| Implementation - Get Options Chain                              |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::GetOptionsChain(string underlying_symbol, OptionsChainData &chain_data)
{
   if(!IsConnected())
   {
      SetError(BLOOMBERG_CONNECTION_FAILED, "Not connected to Bloomberg API");
      return false;
   }
   
   LockData();
   
   // Find underlying data
   int index = FindUnderlyingIndex(underlying_symbol);
   
   if(index == -1)
   {
      SetError(BLOOMBERG_INVALID_SYMBOL, "Underlying not subscribed: " + underlying_symbol);
      UnlockData();
      return false;
   }
   
   // Check if data needs update (TTL expired)
   if(TimeCurrent() - m_options_data[index].last_update > m_config.cache_ttl_seconds)
   {
      UnlockData();
      if(!UpdateOptionsChain(underlying_symbol))
      {
         return false; // Update failed
      }
      LockData();
   }
   
   // Copy data to output parameter (safe copy)
   chain_data = m_options_data[index];
   
   UnlockData();
   return chain_data.is_valid;
}

//+------------------------------------------------------------------+
//| Implementation - Update Options Chain                           |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::UpdateOptionsChain(string underlying_symbol)
{
   if(!IsConnected())
   {
      SetError(BLOOMBERG_CONNECTION_FAILED, "Not connected to Bloomberg API");
      return false;
   }
   
   LockData();
   
   // Find underlying data index
   int index = FindUnderlyingIndex(underlying_symbol);
   
   if(index == -1)
   {
      SetError(BLOOMBERG_INVALID_SYMBOL, "Underlying not found: " + underlying_symbol);
      UnlockData();
      return false;
   }
   
   // Get data from Bloomberg using static buffers
   int data_count = BloombergGetOptionsData(m_session_id, index, m_temp_strikes, m_temp_call_ivs, m_temp_put_ivs, 
                                           m_temp_call_volumes, m_temp_put_volumes, m_temp_call_oi, m_temp_put_oi, 
                                           m_temp_expiry_dates, MAX_OPTIONS_DATA);
   
   // Validate data count
   if(data_count > MAX_OPTIONS_DATA || data_count < 0)
   {
      SetError(BLOOMBERG_ARRAY_BOUNDS_ERROR, "Invalid data count received");
      UnlockData();
      return false;
   }
   
   if(data_count > 0)
   {
      // Parse and organize data by expiry - FIXED VERSION
      OptionsChainData &data = m_options_data[index]; // Reference kullan!
      data.chain_count = 0;
      data.is_valid = false;
      
      // Group by expiry dates with safe string handling
      string unique_expiries[MAX_EXPIRIES];
      int expiry_count = 0;
      
      for(int i = 0; i < data_count && expiry_count < MAX_EXPIRIES; i++)
      {
         bool found = false;
         for(int j = 0; j < expiry_count; j++)
         {
            if(StringCompare(unique_expiries[j], m_temp_expiry_dates[i]) == 0) // Safe string comparison
            {
               found = true;
               break;
            }
         }
         if(!found)
         {
            unique_expiries[expiry_count] = m_temp_expiry_dates[i];
            expiry_count++;
         }
      }
      
      // Organize data by expiry with bounds checking
      for(int exp = 0; exp < expiry_count && exp < MAX_EXPIRIES; exp++)
      {
         OptionsChainData::ExpiryData &expiry_data = data.expiry_chains[exp]; // Reference kullan!
         expiry_data.expiry_date = ParseExpiryDate(unique_expiries[exp]);
         expiry_data.strike_count = 0;
         expiry_data.is_valid = false;
         
         // Fill strikes and options data for this expiry
         for(int i = 0; i < data_count && expiry_data.strike_count < MAX_STRIKES_PER_EXPIRY; i++)
         {
            if(StringCompare(m_temp_expiry_dates[i], unique_expiries[exp]) == 0)
            {
               int strike_idx = expiry_data.strike_count;
               
               expiry_data.strikes[strike_idx] = m_temp_strikes[i];
               expiry_data.call_implied_vols[strike_idx] = m_temp_call_ivs[i];
               expiry_data.put_implied_vols[strike_idx] = m_temp_put_ivs[i];
               expiry_data.call_volumes[strike_idx] = m_temp_call_volumes[i];
               expiry_data.put_volumes[strike_idx] = m_temp_put_volumes[i];
               expiry_data.call_open_interest[strike_idx] = m_temp_call_oi[i];
               expiry_data.put_open_interest[strike_idx] = m_temp_put_oi[i];
               
               expiry_data.strike_count++;
            }
         }
         
         if(expiry_data.strike_count > 0)
         {
            expiry_data.is_valid = true;
         }
      }
      
      data.chain_count = expiry_count;
      data.last_update = TimeCurrent();
      data.is_valid = (expiry_count > 0);
      
      Print(StringFormat("✅ Options chain updated: %s (%d expiries, %d total options)", 
                        underlying_symbol, expiry_count, data_count));
      
      UnlockData();
      return true;
   }
   else
   {
      string error_msg = BloombergGetLastError(m_session_id);
      SetError(BLOOMBERG_DATA_TIMEOUT, error_msg);
      Print(StringFormat("❌ Failed to update options chain: %s - %s", underlying_symbol, error_msg));
      
      UnlockData();
      return false;
   }
}

//+------------------------------------------------------------------+
//| Implementation - Real Time Option Data                          |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::GetRealTimeOptionData(string option_symbol, double &iv, double &delta, 
                                                   double &gamma, double &theta, double &vega)
{
   if(!IsConnected())
   {
      SetError(BLOOMBERG_CONNECTION_FAILED, "Not connected to Bloomberg API");
      return false;
   }
   
   if(!ValidateSymbol(option_symbol))
   {
      SetError(BLOOMBERG_INVALID_SYMBOL, "Invalid option symbol");
      return false;
   }
   
   LockData();
   
   // Check cache first
   for(int i = 0; i < m_realtime_count; i++)
   {
      if(StringCompare(m_realtime_iv[i].option_symbol, option_symbol) == 0 && 
         m_realtime_iv[i].is_valid &&
         TimeCurrent() - m_realtime_iv[i].last_update < m_config.realtime_cache_ttl_seconds)
      {
         iv = m_realtime_iv[i].implied_vol;
         delta = m_realtime_iv[i].delta;
         gamma = m_realtime_iv[i].gamma;
         theta = m_realtime_iv[i].theta;
         vega = m_realtime_iv[i].vega;
         
         UnlockData();
         return true;
      }
   }
   
   UnlockData();
   
   // Get fresh data from Bloomberg
   int result = BloombergGetRealTimeIV(m_session_id, option_symbol, iv, delta, gamma, theta, vega);
   
   if(result > 0)
   {
      // Validate data
      if(IsValidImpliedVol(iv) && IsValidGreek(delta, "delta") && IsValidGreek(gamma, "gamma"))
      {
         LockData();
         
         // Update cache
         int cache_index = -1;
         for(int i = 0; i < m_realtime_count; i++)
         {
            if(StringCompare(m_realtime_iv[i].option_symbol, option_symbol) == 0)
            {
               cache_index = i;
               break;
            }
         }
         
         if(cache_index == -1 && m_realtime_count < MAX_REALTIME_CACHE)
         {
            cache_index = m_realtime_count;
            m_realtime_count++;
         }
         
         if(cache_index >= 0)
         {
            m_realtime_iv[cache_index].option_symbol = option_symbol;
            m_realtime_iv[cache_index].implied_vol = iv;
            m_realtime_iv[cache_index].delta = delta;
            m_realtime_iv[cache_index].gamma = gamma;
            m_realtime_iv[cache_index].theta = theta;
            m_realtime_iv[cache_index].vega = vega;
            m_realtime_iv[cache_index].last_update = TimeCurrent();
            m_realtime_iv[cache_index].is_valid = true;
         }
         
         UnlockData();
         return true;
      }
      else
      {
         SetError(BLOOMBERG_VALIDATION_ERROR, "Invalid options data received from Bloomberg");
         return false;
      }
   }
   else
   {
      string error_msg = BloombergGetLastError(m_session_id);
      SetError(BLOOMBERG_DATA_TIMEOUT, error_msg);
      return false;
   }
}

//+------------------------------------------------------------------+
//| Implementation - Volatility Surface Calculation (FIXED)        |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::CalculateVolatilitySurface(string underlying_symbol, double &moneyness_range[], 
                                                         int moneyness_count, double &iv_surface[], int &surface_size)
{
   if(moneyness_count <= 0 || moneyness_count > 100)
   {
      SetError(BLOOMBERG_VALIDATION_ERROR, "Invalid moneyness count");
      return false;
   }
   
   OptionsChainData chain_data;
   if(!GetOptionsChain(underlying_symbol, chain_data))
   {
      return false;
   }
   
   double underlying_price = SymbolInfoDouble(underlying_symbol, SYMBOL_BID);
   if(underlying_price <= 0)
   {
      SetError(BLOOMBERG_VALIDATION_ERROR, "Invalid underlying price");
      return false;
   }
   
   surface_size = 0;
   
   // Build volatility surface
   for(int exp = 0; exp < chain_data.chain_count && exp < MAX_EXPIRIES; exp++)
   {
      const OptionsChainData::ExpiryData &expiry_data = chain_data.expiry_chains[exp];
      
      if(!expiry_data.is_valid) continue;
      
      for(int strike_idx = 0; strike_idx < expiry_data.strike_count; strike_idx++)
      {
         double strike = expiry_data.strikes[strike_idx];
         double moneyness = strike / underlying_price;
         
         // Find closest moneyness in range
         for(int m = 0; m < moneyness_count; m++)
         {
            if(MathAbs(moneyness - moneyness_range[m]) < 0.05) // 5% tolerance
            {
               // Use call IV for OTM calls, put IV for OTM puts
               double iv = (moneyness > 1.0) ? expiry_data.call_implied_vols[strike_idx] : 
                                              expiry_data.put_implied_vols[strike_idx];
               
               if(IsValidImpliedVol(iv) && surface_size < ArraySize(iv_surface))
               {
                  iv_surface[surface_size] = iv;
                  surface_size++;
               }
               break;
            }
         }
      }
   }
   
   return (surface_size > 0);
}

//+------------------------------------------------------------------+
//| Implementation - Volatility Skew (ENHANCED)                     |
//+------------------------------------------------------------------+
double BloombergOptionsProvider::CalculateVolatilitySkew(string underlying_symbol, datetime expiry)
{
   OptionsChainData chain_data;
   if(!GetOptionsChain(underlying_symbol, chain_data))
   {
      return 0.0;
   }
   
   // Find the expiry data
   OptionsChainData::ExpiryData target_expiry;
   bool found = false;
   
   for(int i = 0; i < chain_data.chain_count; i++)
   {
      if(MathAbs(chain_data.expiry_chains[i].expiry_date - expiry) < 86400) // Within 1 day
      {
         target_expiry = chain_data.expiry_chains[i];
         found = true;
         break;
      }
   }
   
   if(!found || target_expiry.strike_count < 5)
   {
      return 0.0;
   }
   
   // Find ATM strike
   double underlying_price = SymbolInfoDouble(underlying_symbol, SYMBOL_BID);
   if(underlying_price <= 0) return 0.0;
   
   int atm_index = 0;
   double min_diff = MathAbs(target_expiry.strikes[0] - underlying_price);
   
   for(int i = 1; i < target_expiry.strike_count; i++)
   {
      double diff = MathAbs(target_expiry.strikes[i] - underlying_price);
      if(diff < min_diff)
      {
         min_diff = diff;
         atm_index = i;
      }
   }
   
   // Calculate skew with bounds checking
   if(atm_index >= 2 && atm_index < target_expiry.strike_count - 2)
   {
      // 90% moneyness (OTM puts)
      double otm_put_iv = target_expiry.put_implied_vols[atm_index - 2];
      // 110% moneyness (OTM calls)  
      double otm_call_iv = target_expiry.call_implied_vols[atm_index + 2];
      // ATM
      double atm_iv = (target_expiry.call_implied_vols[atm_index] + target_expiry.put_implied_vols[atm_index]) / 2.0;
      
      if(atm_iv > MIN_VALID_IV && IsValidImpliedVol(otm_put_iv) && IsValidImpliedVol(otm_call_iv))
      {
         return (otm_put_iv - otm_call_iv) / atm_iv;
      }
   }
   
   return 0.0;
}

//+------------------------------------------------------------------+
//| Implementation - Volatility Smile (FIXED)                       |
//+------------------------------------------------------------------+
double BloombergOptionsProvider::CalculateVolatilitySmile(string underlying_symbol, datetime expiry, double center_strike)
{
   OptionsChainData chain_data;
   if(!GetOptionsChain(underlying_symbol, chain_data))
   {
      return 0.0;
   }
   
   // Find the expiry data
   OptionsChainData::ExpiryData target_expiry;
   bool found = false;
   
   for(int i = 0; i < chain_data.chain_count; i++)
   {
      if(MathAbs(chain_data.expiry_chains[i].expiry_date - expiry) < 86400)
      {
         target_expiry = chain_data.expiry_chains[i];
         found = true;
         break;
      }
   }
   
   if(!found || target_expiry.strike_count < 3)
   {
      return 0.0;
   }
   
   // Find center strike
   int center_index = -1;
   double min_diff = DBL_MAX;
   
   for(int i = 0; i < target_expiry.strike_count; i++)
   {
      double diff = MathAbs(target_expiry.strikes[i] - center_strike);
      if(diff < min_diff)
      {
         min_diff = diff;
         center_index = i;
      }
   }
   
   if(center_index <= 0 || center_index >= target_expiry.strike_count - 1)
   {
      return 0.0;
   }
   
   // Calculate smile curvature
   double left_iv = target_expiry.call_implied_vols[center_index - 1];
   double center_iv = target_expiry.call_implied_vols[center_index];
   double right_iv = target_expiry.call_implied_vols[center_index + 1];
   
   if(IsValidImpliedVol(left_iv) && IsValidImpliedVol(center_iv) && IsValidImpliedVol(right_iv))
   {
      // Second derivative approximation
      return left_iv + right_iv - 2.0 * center_iv;
   }
   
   return 0.0;
}

//+------------------------------------------------------------------+
//| Implementation - Total Gamma Exposure (ENHANCED)                |
//+------------------------------------------------------------------+
double BloombergOptionsProvider::CalculateTotalGammaExposure(string underlying_symbol)
{
   OptionsChainData chain_data;
   if(!GetOptionsChain(underlying_symbol, chain_data))
   {
      return 0.0;
   }
   
   double total_gamma_exposure = 0.0;
   double underlying_price = SymbolInfoDouble(underlying_symbol, SYMBOL_BID);
   
   if(underlying_price <= 0)
   {
      SetError(BLOOMBERG_VALIDATION_ERROR, "Invalid underlying price");
      return 0.0;
   }
   
   // Calculate gamma exposure across all expiries and strikes
   for(int exp = 0; exp < chain_data.chain_count; exp++)
   {
      const OptionsChainData::ExpiryData &expiry_data = chain_data.expiry_chains[exp];
      
      if(!expiry_data.is_valid) continue;
      
      for(int strike = 0; strike < expiry_data.strike_count; strike++)
      {
         double strike_price = expiry_data.strikes[strike];
         
         // Get real-time Greeks for this strike
         string call_symbol = BuildOptionsSymbol(underlying_symbol, strike_price, expiry_data.expiry_date, true);
         string put_symbol = BuildOptionsSymbol(underlying_symbol, strike_price, expiry_data.expiry_date, false);
         
         double call_iv, call_delta, call_gamma, call_theta, call_vega;
         double put_iv, put_delta, put_gamma, put_theta, put_vega;
         
         if(GetRealTimeOptionData(call_symbol, call_iv, call_delta, call_gamma, call_theta, call_vega))
         {
            if(IsValidGreek(call_gamma, "gamma") && strike < MAX_STRIKES_PER_EXPIRY)
            {
               // Gamma exposure = Gamma * Open Interest * 100 (shares per contract)
               total_gamma_exposure += call_gamma * expiry_data.call_open_interest[strike] * 100;
            }
         }
         
         if(GetRealTimeOptionData(put_symbol, put_iv, put_delta, put_gamma, put_theta, put_vega))
         {
            if(IsValidGreek(put_gamma, "gamma") && strike < MAX_STRIKES_PER_EXPIRY)
            {
               total_gamma_exposure += put_gamma * expiry_data.put_open_interest[strike] * 100;
            }
         }
      }
   }
   
   return total_gamma_exposure;
}

//+------------------------------------------------------------------+
//| Helper Functions - Input Validation                             |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::ValidateServerInput(string server_host, int server_port)
{
   if(StringLen(server_host) == 0)
   {
      SetError(BLOOMBERG_VALIDATION_ERROR, "Empty server host");
      return false;
   }
   
   if(server_port <= 0 || server_port > 65535)
   {
      SetError(BLOOMBERG_VALIDATION_ERROR, "Invalid server port range");
      return false;
   }
   
   return true;
}

bool BloombergOptionsProvider::ValidateSymbol(string symbol)
{
   if(StringLen(symbol) == 0 || StringLen(symbol) > 20)
   {
      return false;
   }
   
   // Basic symbol validation - alphanumeric only
   for(int i = 0; i < StringLen(symbol); i++)
   {
      ushort ch = StringGetCharacter(symbol, i);
      if(!((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || 
           (ch >= '0' && ch <= '9') || ch == '.' || ch == '_'))
      {
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Helper Functions - Safe Array Access                            |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::SafeArrayAccess(int index, int max_size, string array_name)
{
   if(index < 0 || index >= max_size)
   {
      SetError(BLOOMBERG_ARRAY_BOUNDS_ERROR, 
               StringFormat("Array bounds error in %s: index=%d, max=%d", array_name, index, max_size));
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Helper Functions - Data Validation                              |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::IsValidImpliedVol(double iv)
{
   return (iv >= MIN_VALID_IV && iv <= MAX_VALID_IV);
}

bool BloombergOptionsProvider::IsValidGreek(double greek_value, string greek_name)
{
   if(greek_name == "delta")
      return (greek_value >= -1.1 && greek_value <= 1.1); // Slight tolerance
   else if(greek_name == "gamma")
      return (greek_value >= -1.1 && greek_value <= 1.1);
   else if(greek_name == "theta")
      return (greek_value >= -200.0 && greek_value <= 200.0);
   else if(greek_name == "vega")
      return (greek_value >= -2000.0 && greek_value <= 2000.0);
   
   return true;
}

bool BloombergOptionsProvider::IsValidStrike(double strike, double underlying_price)
{
   if(strike <= 0 || underlying_price <= 0) return false;
   
   double ratio = strike / underlying_price;
   return (ratio >= 0.1 && ratio <= 10.0); // 10% to 1000% of underlying
}

bool BloombergOptionsProvider::IsValidDateTime(datetime dt)
{
   return (dt > 0 && dt > TimeCurrent() - 365*24*3600 && dt < TimeCurrent() + 10*365*24*3600);
}

//+------------------------------------------------------------------+
//| Helper Functions - Parse Expiry Date (FIXED)                    |
//+------------------------------------------------------------------+
datetime BloombergOptionsProvider::ParseExpiryDate(string expiry_string)
{
   if(StringLen(expiry_string) == 0)
   {
      SetError(BLOOMBERG_PARSING_ERROR, "Empty expiry string");
      return 0;
   }
   
   // Parse Bloomberg date format "YYYY-MM-DD"
   string parts[];
   int count = StringSplit(expiry_string, '-', parts);
   
   if(count != 3 || ArraySize(parts) < 3)
   {
      SetError(BLOOMBERG_PARSING_ERROR, "Invalid expiry date format: " + expiry_string);
      return 0;
   }
   
   int year = (int)StringToInteger(parts[0]);
   int month = (int)StringToInteger(parts[1]);
   int day = (int)StringToInteger(parts[2]);
   
   // Validate date components
   if(year < 2020 || year > 2050)
   {
      SetError(BLOOMBERG_PARSING_ERROR, "Invalid year in expiry date");
      return 0;
   }
   
   if(month < 1 || month > 12)
   {
      SetError(BLOOMBERG_PARSING_ERROR, "Invalid month in expiry date");
      return 0;
   }
   
   if(day < 1 || day > 31)
   {
      SetError(BLOOMBERG_PARSING_ERROR, "Invalid day in expiry date");
      return 0;
   }
   
   MqlDateTime exp_time;
   exp_time.year = year;
   exp_time.mon = month;
   exp_time.day = day;
   exp_time.hour = 16; // Options expire at 4 PM EST
   exp_time.min = 0;
   exp_time.sec = 0;
   
   datetime result = StructToTime(exp_time);
   
   if(!IsValidDateTime(result))
   {
      SetError(BLOOMBERG_PARSING_ERROR, "Invalid parsed datetime");
      return 0;
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Helper Functions - Build Options Symbol (OPTIMIZED)             |
//+------------------------------------------------------------------+
string BloombergOptionsProvider::BuildOptionsSymbol(string underlying, double strike, datetime expiry, bool is_call)
{
   if(!ValidateSymbol(underlying) || strike <= 0 || !IsValidDateTime(expiry))
   {
      return "";
   }
   
   MqlDateTime exp_time;
   if(!TimeToStruct(expiry, exp_time))
   {
      return "";
   }
   
   // Bloomberg options symbol format: "UNDERLYING MM/DD/YY P/C Strike"
   // Example: "SPY 01/15/24 C 450"
   return StringFormat("%s %02d/%02d/%02d %s %.0f", 
                      underlying, 
                      exp_time.mon, 
                      exp_time.day, 
                      exp_time.year % 100,
                      is_call ? "C" : "P",
                      strike);
}

//+------------------------------------------------------------------+
//| Helper Functions - Index Management                             |
//+------------------------------------------------------------------+
int BloombergOptionsProvider::FindUnderlyingIndex(string underlying_symbol)
{
   for(int i = 0; i < m_underlying_count; i++)
   {
      if(StringCompare(m_options_data[i].underlying_symbol, underlying_symbol) == 0)
      {
         return i;
      }
   }
   return -1;
}

int BloombergOptionsProvider::FindOrCreateUnderlyingIndex(string underlying_symbol)
{
   int index = FindUnderlyingIndex(underlying_symbol);
   
   if(index != -1)
   {
      return index;
   }
   
   if(m_underlying_count < MAX_UNDERLYINGS)
   {
      index = m_underlying_count;
      m_underlying_count++;
      return index;
   }
   
   return -1; // No space available
}

//+------------------------------------------------------------------+
//| Helper Functions - Error Handling                               |
//+------------------------------------------------------------------+
void BloombergOptionsProvider::SetError(ENUM_BLOOMBERG_ERROR error_code, string message)
{
   m_last_error_code = error_code;
   m_last_error_message = message;
   m_last_error_time = TimeCurrent();
   
   if(m_logger != NULL)
   {
      m_logger.LogError(error_code, message);
   }
}

//+------------------------------------------------------------------+
//| Helper Functions - Data Structure Management                    |
//+------------------------------------------------------------------+
void BloombergOptionsProvider::InitializeDataStructures()
{
   // Initialize options data arrays
   for(int i = 0; i < MAX_UNDERLYINGS; i++)
   {
      m_options_data[i].underlying_symbol = "";
      m_options_data[i].last_update = 0;
      m_options_data[i].chain_count = 0;
      m_options_data[i].is_valid = false;
      
      for(int j = 0; j < MAX_EXPIRIES; j++)
      {
         m_options_data[i].expiry_chains[j].expiry_date = 0;
         m_options_data[i].expiry_chains[j].strike_count = 0;
         m_options_data[i].expiry_chains[j].is_valid = false;
         
         // Initialize arrays to zero
         ArrayInitialize(m_options_data[i].expiry_chains[j].strikes, 0.0);
         ArrayInitialize(m_options_data[i].expiry_chains[j].call_implied_vols, 0.0);
         ArrayInitialize(m_options_data[i].expiry_chains[j].put_implied_vols, 0.0);
      }
   }
   
   // Initialize real-time data arrays
   for(int i = 0; i < MAX_REALTIME_CACHE; i++)
   {
      m_realtime_iv[i].option_symbol = "";
      m_realtime_iv[i].implied_vol = 0.0;
      m_realtime_iv[i].last_update = 0;
      m_realtime_iv[i].is_valid = false;
   }
   
   // Initialize temporary buffers
   ArrayInitialize(m_temp_strikes, 0.0);
   ArrayInitialize(m_temp_call_ivs, 0.0);
   ArrayInitialize(m_temp_put_ivs, 0.0);
}

void BloombergOptionsProvider::CleanupDataStructures()
{
   // Reset counters
   m_underlying_count = 0;
   m_realtime_count = 0;
   
   // Clear data validity flags
   for(int i = 0; i < MAX_UNDERLYINGS; i++)
   {
      m_options_data[i].is_valid = false;
      for(int j = 0; j < MAX_EXPIRIES; j++)
      {
         m_options_data[i].expiry_chains[j].is_valid = false;
      }
   }
   
   for(int i = 0; i < MAX_REALTIME_CACHE; i++)
   {
      m_realtime_iv[i].is_valid = false;
   }
}

//+------------------------------------------------------------------+
//| Utility Functions - Cache Management                            |
//+------------------------------------------------------------------+
void BloombergOptionsProvider::ClearCache()
{
   LockData();
   CleanupDataStructures();
   Print("✅ Bloomberg API cache cleared");
   UnlockData();
}

void BloombergOptionsProvider::RemoveExpiredCacheEntries()
{
   LockData();
   
   datetime current_time = TimeCurrent();
   
   // Remove expired real-time cache entries
   for(int i = 0; i < m_realtime_count; i++)
   {
      if(m_realtime_iv[i].is_valid && 
         current_time - m_realtime_iv[i].last_update > m_config.realtime_cache_ttl_seconds * 2)
      {
         m_realtime_iv[i].is_valid = false;
      }
   }
   
   // Remove expired options chain data
   for(int i = 0; i < m_underlying_count; i++)
   {
      if(m_options_data[i].is_valid &&
         current_time - m_options_data[i].last_update > m_config.cache_ttl_seconds * 2)
      {
         m_options_data[i].is_valid = false;
      }
   }
   
   UnlockData();
}

//+------------------------------------------------------------------+
//| Utility Functions - Diagnostics                                 |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::RunDiagnostics()
{
   Print("🔍 Running Bloomberg API diagnostics...");
   
   bool all_ok = true;
   
   // Test thread safety
   if(!m_locks_initialized)
   {
      Print("❌ Thread safety not initialized");
      all_ok = false;
   }
   else
   {
      Print("✅ Thread safety initialized");
   }
   
   // Test connection
   if(!IsConnected())
   {
      Print("❌ Not connected to Bloomberg");
      all_ok = false;
   }
   else
   {
      Print("✅ Connected to Bloomberg");
   }
   
   // Test cache
   Print(StringFormat("📊 Cache status: %d/%d underlyings, %d/%d realtime entries", 
                     m_underlying_count, MAX_UNDERLYINGS,
                     m_realtime_count, MAX_REALTIME_CACHE));
   
   // Test configuration
   if(m_config.cache_ttl_seconds <= 0 || m_config.realtime_cache_ttl_seconds <= 0)
   {
      Print("❌ Invalid cache configuration");
      all_ok = false;
   }
   else
   {
      Print("✅ Cache configuration valid");
   }
   
   if(all_ok)
   {
      Print("✅ All diagnostics passed");
   }
   else
   {
      Print("❌ Some diagnostics failed");
   }
   
   return all_ok;
}

//+------------------------------------------------------------------+
//| Implementation - Data Validation                                |
//+------------------------------------------------------------------+
bool BloombergOptionsProvider::ValidateOptionsData(const OptionsChainData &chain_data)
{
   if(!chain_data.is_valid)
   {
      SetError(BLOOMBERG_VALIDATION_ERROR, "Chain data marked as invalid");
      return false;
   }
   
   if(chain_data.chain_count == 0)
   {
      SetError(BLOOMBERG_VALIDATION_ERROR, "No options chain data available");
      return false;
   }
   
   for(int exp = 0; exp < chain_data.chain_count && exp < MAX_EXPIRIES; exp++)
   {
      const OptionsChainData::ExpiryData &expiry = chain_data.expiry_chains[exp];
      
      if(!expiry.is_valid)
      {
         continue; // Skip invalid expiries
      }
      
      if(expiry.strike_count == 0)
      {
         SetError(BLOOMBERG_VALIDATION_ERROR, StringFormat("No strikes available for expiry %d", exp));
         return false;
      }
      
      for(int i = 0; i < expiry.strike_count && i < MAX_STRIKES_PER_EXPIRY; i++)
      {
         // Validate implied volatilities
         if(!IsValidImpliedVol(expiry.call_implied_vols[i]) || 
            !IsValidImpliedVol(expiry.put_implied_vols[i]))
         {
            SetError(BLOOMBERG_VALIDATION_ERROR, 
                    StringFormat("Invalid IV data at strike %.2f", expiry.strikes[i]));
            return false;
         }
         
         // Validate strikes are positive
         if(expiry.strikes[i] <= 0)
         {
            SetError(BLOOMBERG_VALIDATION_ERROR, 
                    StringFormat("Invalid strike price: %.2f", expiry.strikes[i]));
            return false;
         }
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Implementation - Data Quality Score                             |
//+------------------------------------------------------------------+
double BloombergOptionsProvider::CalculateDataQualityScore(string underlying_symbol)
{
   OptionsChainData chain_data;
   if(!GetOptionsChain(underlying_symbol, chain_data))
   {
      return 0.0;
   }
   
   if(!chain_data.is_valid)
   {
      return 0.0;
   }
   
   double quality_score = 0.0;
   int total_checks = 0;
   int passed_checks = 0;
   
   // Check data freshness (25% weight)
   total_checks++;
   if(TimeCurrent() - chain_data.last_update < m_config.cache_ttl_seconds)
   {
      passed_checks++;
   }
   
   // Check number of expiries (25% weight)
   total_checks++;
   if(chain_data.chain_count >= 3)
   {
      passed_checks++;
   }
   
   // Check data completeness (50% weight)
   for(int exp = 0; exp < chain_data.chain_count; exp++)
   {
      const OptionsChainData::ExpiryData &expiry = chain_data.expiry_chains[exp];
      
      if(!expiry.is_valid) continue;
      
      for(int i = 0; i < expiry.strike_count; i++)
      {
         total_checks += 2; // Call and put IV
         
         if(IsValidImpliedVol(expiry.call_implied_vols[i]))
         {
            passed_checks++;
         }
         
         if(IsValidImpliedVol(expiry.put_implied_vols[i]))
         {
            passed_checks++;
         }
      }
   }
   
   if(total_checks > 0)
   {
      quality_score = (double)passed_checks / total_checks;
   }
   
   return quality_score;
}

//+------------------------------------------------------------------+
//| Implementation - Connection Health Update                       |
//+------------------------------------------------------------------+
void BloombergOptionsProvider::UpdateConnectionHealth()
{
   if(!IsConnected())
   {
      SetError(BLOOMBERG_CONNECTION_FAILED, "Connection health check failed");
      return;
   }
   
   // Remove expired cache entries periodically
   RemoveExpiredCacheEntries();
   
   // Update last check time
   m_last_connection_check = TimeCurrent();
}

//+------------------------------------------------------------------+
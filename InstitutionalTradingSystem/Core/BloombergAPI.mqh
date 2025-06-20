//+------------------------------------------------------------------+
//| Bloomberg BLPAPI Integration for Real Options Data               |
//| Production-Ready Implementation                                   |
//+------------------------------------------------------------------+
#property strict

#include "Complete_Enum_Types.mqh"

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
//| Bloomberg Options Data Provider                                  |
//+------------------------------------------------------------------+
class BloombergOptionsProvider
{
private:
    int                  m_session_id;
    bool                 m_connected;
    string               m_server_host;
    int                  m_server_port;
    string               m_username;
    string               m_last_error;
    
    // Options chain data storage
    struct OptionsChainData
    {
        string           underlying_symbol;
        datetime         last_update;
        int              chain_count;
        
        // Per expiry data
        struct ExpiryData
        {
            datetime     expiry_date;
            int          strike_count;
            double       strikes[50];
            double       call_implied_vols[50];
            double       put_implied_vols[50];
            double       call_volumes[50];
            double       put_volumes[50];
            double       call_open_interest[50];
            double       put_open_interest[50];
            double       call_deltas[50];
            double       put_deltas[50];
            double       call_gammas[50];
            double       put_gammas[50];
            double       call_vegas[50];
            double       put_vegas[50];
            double       call_thetas[50];
            double       put_thetas[50];
        };
        
        ExpiryData       expiry_chains[12]; // Up to 12 expiry months
    };
    
    OptionsChainData     m_options_data[10]; // Support up to 10 underlyings
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
    
    RealTimeIVData       m_realtime_iv[1000]; // Cache for frequently accessed options
    int                  m_realtime_count;
    
    datetime             m_last_connection_check;
    int                  m_connection_check_interval; // seconds
    
public:
    BloombergOptionsProvider();
    ~BloombergOptionsProvider();
    
    // Connection management
    bool Connect(string server_host = "localhost", int server_port = 8194, string username = "");
    void Disconnect();
    bool IsConnected();
    string GetLastError() const { return m_last_error; }
    
    // Options chain subscription and data retrieval
    bool SubscribeOptionsChain(string underlying_symbol);
    bool GetOptionsChain(string underlying_symbol, OptionsChainData &chain_data);
    bool UpdateOptionsChain(string underlying_symbol);
    
    // Real-time options data
    bool GetRealTimeOptionData(string option_symbol, double &iv, double &delta, double &gamma, 
                              double &theta, double &vega);
    bool GetImpliedVolatility(string underlying_symbol, double strike, datetime expiry, 
                             bool is_call, double &implied_vol);
    
    // Volatility surface calculations
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
    
private:
    // Internal helper methods
    bool ParseBloombergResponse(string response, OptionsChainData &chain_data);
    string BuildOptionsSymbol(string underlying, double strike, datetime expiry, bool is_call);
    datetime ParseExpiryDate(string expiry_string);
    bool IsMarketOpen();
    void LogBloombergError(string function_name, string error_msg);
    void CleanupExpiredData();
    
    // Data validation helpers
    bool IsValidImpliedVol(double iv);
    bool IsValidGreek(double greek_value, string greek_name);
    bool IsValidStrike(double strike, double underlying_price);
};

//+------------------------------------------------------------------+
//| Implementation                                                   |
//+------------------------------------------------------------------+

BloombergOptionsProvider::BloombergOptionsProvider()
{
    m_session_id = -1;
    m_connected = false;
    m_server_host = "localhost";
    m_server_port = 8194;
    m_username = "";
    m_last_error = "";
    m_underlying_count = 0;
    m_realtime_count = 0;
    m_last_connection_check = 0;
    m_connection_check_interval = 30; // 30 seconds
    
    // Initialize options data arrays
    for(int i = 0; i < 10; i++)
    {
        m_options_data[i].underlying_symbol = "";
        m_options_data[i].last_update = 0;
        m_options_data[i].chain_count = 0;
    }
    
    Print("Bloomberg Options Provider initialized");
}

BloombergOptionsProvider::~BloombergOptionsProvider()
{
    if(m_connected)
    {
        Disconnect();
    }
    Print("Bloomberg Options Provider destroyed");
}

bool BloombergOptionsProvider::Connect(string server_host, int server_port, string username)
{
    if(m_connected)
    {
        Print("Already connected to Bloomberg API");
        return true;
    }
    
    m_server_host = server_host;
    m_server_port = server_port;
    m_username = username;
    
    Print(StringFormat("Connecting to Bloomberg API: %s:%d", server_host, server_port));
    
    m_session_id = BloombergConnect(server_host, server_port);
    
    if(m_session_id > 0)
    {
        m_connected = true;
        m_last_connection_check = TimeCurrent();
        Print(StringFormat("✅ Bloomberg API connected successfully. Session ID: %d", m_session_id));
        return true;
    }
    else
    {
        m_last_error = BloombergGetLastError(m_session_id);
        Print(StringFormat("❌ Bloomberg API connection failed: %s", m_last_error));
        return false;
    }
}

void BloombergOptionsProvider::Disconnect()
{
    if(m_connected && m_session_id > 0)
    {
        BloombergDisconnect(m_session_id);
        m_connected = false;
        m_session_id = -1;
        Print("Bloomberg API disconnected");
    }
}

bool BloombergOptionsProvider::IsConnected()
{
    if(!m_connected) return false;
    
    // Periodic connection health check
    datetime current_time = TimeCurrent();
    if(current_time - m_last_connection_check > m_connection_check_interval)
    {
        m_connected = BloombergIsConnected(m_session_id);
        m_last_connection_check = current_time;
        
        if(!m_connected)
        {
            m_last_error = "Connection lost to Bloomberg API";
            Print("⚠️ Bloomberg API connection lost");
        }
    }
    
    return m_connected;
}

bool BloombergOptionsProvider::SubscribeOptionsChain(string underlying_symbol)
{
    if(!IsConnected())
    {
        m_last_error = "Not connected to Bloomberg API";
        return false;
    }
    
    Print(StringFormat("Subscribing to options chain: %s", underlying_symbol));
    
    string error_msg = "";
    int request_id = BloombergSubscribeOptionsChain(m_session_id, underlying_symbol, error_msg);
    
    if(request_id > 0)
    {
        // Find or create underlying data slot
        int index = -1;
        for(int i = 0; i < m_underlying_count; i++)
        {
            if(m_options_data[i].underlying_symbol == underlying_symbol)
            {
                index = i;
                break;
            }
        }
        
        if(index == -1 && m_underlying_count < 10)
        {
            index = m_underlying_count;
            m_options_data[index].underlying_symbol = underlying_symbol;
            m_underlying_count++;
        }
        
        if(index >= 0)
        {
            m_options_data[index].last_update = TimeCurrent();
            Print(StringFormat("✅ Options chain subscription successful: %s (Request ID: %d)", underlying_symbol, request_id));
            return true;
        }
    }
    
    m_last_error = error_msg;
    Print(StringFormat("❌ Options chain subscription failed: %s - %s", underlying_symbol, error_msg));
    return false;
}

bool BloombergOptionsProvider::GetOptionsChain(string underlying_symbol, OptionsChainData &chain_data)
{
    if(!IsConnected())
    {
        m_last_error = "Not connected to Bloomberg API";
        return false;
    }
    
    // Find underlying data
    int index = -1;
    for(int i = 0; i < m_underlying_count; i++)
    {
        if(m_options_data[i].underlying_symbol == underlying_symbol)
        {
            index = i;
            break;
        }
    }
    
    if(index == -1)
    {
        m_last_error = "Underlying not subscribed: " + underlying_symbol;
        return false;
    }
    
    // Copy data to output parameter
    chain_data = m_options_data[index];
    
    // Check if data needs update (older than 5 minutes)
    if(TimeCurrent() - chain_data.last_update > 300)
    {
        return UpdateOptionsChain(underlying_symbol);
    }
    
    return true;
}

bool BloombergOptionsProvider::UpdateOptionsChain(string underlying_symbol)
{
    if(!IsConnected())
    {
        m_last_error = "Not connected to Bloomberg API";
        return false;
    }
    
    // Find underlying data index
    int index = -1;
    for(int i = 0; i < m_underlying_count; i++)
    {
        if(m_options_data[i].underlying_symbol == underlying_symbol)
        {
            index = i;
            break;
        }
    }
    
    if(index == -1)
    {
        m_last_error = "Underlying not found: " + underlying_symbol;
        return false;
    }
    
    // Prepare arrays for Bloomberg API call
    double strikes[600];        // 50 strikes * 12 expiries = 600 max
    double call_ivs[600];
    double put_ivs[600];
    double call_volumes[600];
    double put_volumes[600];
    double call_oi[600];
    double put_oi[600];
    string expiry_dates[600];
    
    // Get data from Bloomberg
    int data_count = BloombergGetOptionsData(m_session_id, index, strikes, call_ivs, put_ivs, 
                                           call_volumes, put_volumes, call_oi, put_oi, 
                                           expiry_dates, 600);
    
    if(data_count > 0)
    {
        // Parse and organize data by expiry
        OptionsChainData data = m_options_data[index];
        data.chain_count = 0;
        
        // Group by expiry dates
        string unique_expiries[12];
        int expiry_count = 0;
        
        for(int i = 0; i < data_count; i++)
        {
            bool found = false;
            for(int j = 0; j < expiry_count; j++)
            {
                if(unique_expiries[j] == expiry_dates[i])
                {
                    found = true;
                    break;
                }
            }
            if(!found && expiry_count < 12)
            {
                unique_expiries[expiry_count] = expiry_dates[i];
                expiry_count++;
            }
        }
        
        // Organize data by expiry
        for(int exp = 0; exp < expiry_count; exp++)
        {
            OptionsChainData::ExpiryData expiry_data = data.expiry_chains[exp];
            expiry_data.expiry_date = ParseExpiryDate(unique_expiries[exp]);
            expiry_data.strike_count = 0;
            
            // Fill strikes and options data for this expiry
            for(int i = 0; i < data_count && expiry_data.strike_count < 50; i++)
            {
                if(expiry_dates[i] == unique_expiries[exp])
                {
                    int strike_idx = expiry_data.strike_count;
                    
                    expiry_data.strikes[strike_idx] = strikes[i];
                    expiry_data.call_implied_vols[strike_idx] = call_ivs[i];
                    expiry_data.put_implied_vols[strike_idx] = put_ivs[i];
                    expiry_data.call_volumes[strike_idx] = call_volumes[i];
                    expiry_data.put_volumes[strike_idx] = put_volumes[i];
                    expiry_data.call_open_interest[strike_idx] = call_oi[i];
                    expiry_data.put_open_interest[strike_idx] = put_oi[i];
                    
                    expiry_data.strike_count++;
                }
            }
        }
        
        data.chain_count = expiry_count;
        data.last_update = TimeCurrent();
        
        Print(StringFormat("✅ Options chain updated: %s (%d expiries, %d total options)", 
                          underlying_symbol, expiry_count, data_count));
        return true;
    }
    else
    {
        m_last_error = BloombergGetLastError(m_session_id);
        Print(StringFormat("❌ Failed to update options chain: %s - %s", underlying_symbol, m_last_error));
        return false;
    }
}

bool BloombergOptionsProvider::GetRealTimeOptionData(string option_symbol, double &iv, double &delta, 
                                                   double &gamma, double &theta, double &vega)
{
    if(!IsConnected())
    {
        m_last_error = "Not connected to Bloomberg API";
        return false;
    }
    
    // Check cache first
    for(int i = 0; i < m_realtime_count; i++)
    {
        if(m_realtime_iv[i].option_symbol == option_symbol && 
           m_realtime_iv[i].is_valid &&
           TimeCurrent() - m_realtime_iv[i].last_update < 30) // 30 second cache
        {
            iv = m_realtime_iv[i].implied_vol;
            delta = m_realtime_iv[i].delta;
            gamma = m_realtime_iv[i].gamma;
            theta = m_realtime_iv[i].theta;
            vega = m_realtime_iv[i].vega;
            return true;
        }
    }
    
    // Get fresh data from Bloomberg
    int result = BloombergGetRealTimeIV(m_session_id, option_symbol, iv, delta, gamma, theta, vega);
    
    if(result > 0)
    {
        // Validate data
        if(IsValidImpliedVol(iv) && IsValidGreek(delta, "delta") && IsValidGreek(gamma, "gamma"))
        {
            // Update cache
            int cache_index = -1;
            for(int i = 0; i < m_realtime_count; i++)
            {
                if(m_realtime_iv[i].option_symbol == option_symbol)
                {
                    cache_index = i;
                    break;
                }
            }
            
            if(cache_index == -1 && m_realtime_count < 1000)
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
            
            return true;
        }
        else
        {
            m_last_error = "Invalid options data received from Bloomberg";
            return false;
        }
    }
    else
    {
        m_last_error = BloombergGetLastError(m_session_id);
        return false;
    }
}

double BloombergOptionsProvider::CalculateVolatilitySkew(string underlying_symbol, datetime expiry)
{
    OptionsChainData chain_data;
    if(!GetOptionsChain(underlying_symbol, chain_data))
    {
        return 0.0;
    }
    
    // Find the expiry data
    OptionsChainData::ExpiryData target_expiry;
    for(int i = 0; i < chain_data.chain_count; i++)
    {
        if(MathAbs(chain_data.expiry_chains[i].expiry_date - expiry) < 86400) // Within 1 day
        {
            target_expiry = chain_data.expiry_chains[i];
            break;
        }
    }
    
    if(target_expiry.strike_count < 5)
    {
        return 0.0;
    }
    
    // Find ATM strike
    double underlying_price = SymbolInfoDouble(underlying_symbol, SYMBOL_BID);
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
    
    // Calculate skew (put IV - call IV at different strikes)
    if(atm_index >= 2 && atm_index < target_expiry.strike_count - 2)
    {
        // 90% moneyness (OTM puts)
        double otm_put_iv = target_expiry.put_implied_vols[atm_index - 2];
        // 110% moneyness (OTM calls)  
        double otm_call_iv = target_expiry.call_implied_vols[atm_index + 2];
        // ATM
        double atm_iv = (target_expiry.call_implied_vols[atm_index] + target_expiry.put_implied_vols[atm_index]) / 2.0;
        
        if(atm_iv > 0)
        {
            return (otm_put_iv - otm_call_iv) / atm_iv;
        }
    }
    
    return 0.0;
}

double BloombergOptionsProvider::CalculateTotalGammaExposure(string underlying_symbol)
{
    OptionsChainData chain_data;
    if(!GetOptionsChain(underlying_symbol, chain_data))
    {
        return 0.0;
    }
    
    double total_gamma_exposure = 0.0;
    double underlying_price = SymbolInfoDouble(underlying_symbol, SYMBOL_BID);
    
    // Calculate gamma exposure across all expiries and strikes
    for(int exp = 0; exp < chain_data.chain_count; exp++)
    {
        OptionsChainData::ExpiryData expiry_data = chain_data.expiry_chains[exp];
        
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
                // Gamma exposure = Gamma * Open Interest * 100 (shares per contract)
                total_gamma_exposure += call_gamma * expiry_data.call_open_interest[strike] * 100;
            }
            
            if(GetRealTimeOptionData(put_symbol, put_iv, put_delta, put_gamma, put_theta, put_vega))
            {
                total_gamma_exposure += put_gamma * expiry_data.put_open_interest[strike] * 100;
            }
        }
    }
    
    return total_gamma_exposure;
}

bool BloombergOptionsProvider::ValidateOptionsData(const OptionsChainData &chain_data)
{
    if(chain_data.chain_count == 0)
    {
        m_last_error = "No options chain data available";
        return false;
    }
    
    for(int exp = 0; exp < chain_data.chain_count; exp++)
    {
        const OptionsChainData::ExpiryData expiry = chain_data.expiry_chains[exp];
        
        if(expiry.strike_count == 0)
        {
            m_last_error = StringFormat("No strikes available for expiry %d", exp);
            return false;
        }
        
        for(int i = 0; i < expiry.strike_count; i++)
        {
            // Validate implied volatilities
            if(!IsValidImpliedVol(expiry.call_implied_vols[i]) || 
               !IsValidImpliedVol(expiry.put_implied_vols[i]))
            {
                m_last_error = StringFormat("Invalid IV data at strike %.2f", expiry.strikes[i]);
                return false;
            }
            
            // Validate strikes are positive
            if(expiry.strikes[i] <= 0)
            {
                m_last_error = StringFormat("Invalid strike price: %.2f", expiry.strikes[i]);
                return false;
            }
        }
    }
    
    return true;
}

string BloombergOptionsProvider::BuildOptionsSymbol(string underlying, double strike, datetime expiry, bool is_call)
{
    // Bloomberg options symbol format: "UNDERLYING MM/DD/YY P/C Strike"
    // Example: "SPY 01/15/24 C 450"
    
    MqlDateTime exp_time;
    TimeToStruct(expiry, exp_time);
    
    string option_type = is_call ? "C" : "P";
    
    return StringFormat("%s %02d/%02d/%02d %s %.0f", 
                       underlying, 
                       exp_time.mon, 
                       exp_time.day, 
                       exp_time.year % 100,
                       option_type,
                       strike);
}

datetime BloombergOptionsProvider::ParseExpiryDate(string expiry_string)
{
    // Parse Bloomberg date format "YYYY-MM-DD"
    string parts[];
    int count = StringSplit(expiry_string, '-', parts);
    
    if(count == 3)
    {
        int year = (int)StringToInteger(parts[0]);
        int month = (int)StringToInteger(parts[1]);
        int day = (int)StringToInteger(parts[2]);
        
        MqlDateTime exp_time;
        exp_time.year = year;
        exp_time.mon = month;
        exp_time.day = day;
        exp_time.hour = 16; // Options expire at 4 PM EST
        exp_time.min = 0;
        exp_time.sec = 0;
        
        return StructToTime(exp_time);
    }
    
    return 0;
}

bool BloombergOptionsProvider::IsValidImpliedVol(double iv)
{
    return (iv > 0.001 && iv < 5.0); // Between 0.1% and 500%
}

bool BloombergOptionsProvider::IsValidGreek(double greek_value, string greek_name)
{
    if(greek_name == "delta")
        return (greek_value >= -1.0 && greek_value <= 1.0);
    else if(greek_name == "gamma")
        return (greek_value >= -1.0 && greek_value <= 1.0);
    else if(greek_name == "theta")
        return (greek_value >= -100.0 && greek_value <= 100.0);
    else if(greek_name == "vega")
        return (greek_value >= -1000.0 && greek_value <= 1000.0);
    
    return true;
}

void BloombergOptionsProvider::LogBloombergError(string function_name, string error_msg)
{
    string full_error = StringFormat("[Bloomberg Error] %s: %s", function_name, error_msg);
    Print(full_error);
    m_last_error = full_error;
}
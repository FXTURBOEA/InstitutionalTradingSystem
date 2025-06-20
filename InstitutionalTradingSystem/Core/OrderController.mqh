//+------------------------------------------------------------------+
//| OrderController.mqh - Emir İletim Kontrol Sistemi               |
//| Sunucuya İletim Öncesi Kapsamlı Hata Kontrolleri                |
//| OOP Mimari Uyumlu Trade Validation Controller                   |
//+------------------------------------------------------------------+
#property strict

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

//+------------------------------------------------------------------+
//| Trade Validation Sonuç Enumları                                 |
//+------------------------------------------------------------------+
enum ENUM_TRADE_VALIDATION_RESULT
{
   TRADE_VALIDATION_OK = 0,              // Geçerli
   
   // Market durumu hataları
   TRADE_ERROR_MARKET_CLOSED = 1000,     // Market kapalı
   TRADE_ERROR_NO_QUOTES = 1001,         // Fiyat yok
   TRADE_ERROR_SYMBOL_NOT_FOUND = 1002,  // Sembol bulunamadı
   TRADE_ERROR_SYMBOL_DISABLED = 1003,   // Sembol devre dışı
   TRADE_ERROR_TRADING_DISABLED = 1004,  // Ticaret devre dışı
   TRADE_ERROR_INSUFFICIENT_RIGHTS = 1005, // Yetersiz izin
   
   // Fiyat ve seviye hataları
   TRADE_ERROR_INVALID_PRICE = 2000,     // Geçersiz fiyat
   TRADE_ERROR_INVALID_STOPS = 2001,     // Geçersiz stop seviyeleri
   TRADE_ERROR_INVALID_SL = 2002,        // Geçersiz SL
   TRADE_ERROR_INVALID_TP = 2003,        // Geçersiz TP
   TRADE_ERROR_INVALID_EXPIRATION = 2004, // Geçersiz son kullanma
   TRADE_ERROR_INVALID_VOLUME = 2005,    // Geçersiz hacim
   TRADE_ERROR_PRICE_CHANGED = 2006,     // Fiyat değişti
   TRADE_ERROR_REQUOTE = 2007,           // Requote
   
   // Margin ve bakiye hataları
   TRADE_ERROR_NO_MONEY = 3000,          // Para yok
   TRADE_ERROR_MARGIN_CHECK_FAILED = 3001, // Margin kontrolü başarısız
   TRADE_ERROR_TRADE_DISABLED = 3002,    // Ticaret yasaklı
   TRADE_ERROR_NOT_ENOUGH_MONEY = 3003,  // Yetersiz para
   TRADE_ERROR_POSITION_CLOSED = 3004,   // Pozisyon kapatıldı
   
   // Spread ve likidite hataları
   TRADE_ERROR_HIGH_SPREAD = 4000,       // Yüksek spread
   TRADE_ERROR_NO_LIQUIDITY = 4001,      // Likidite yok
   TRADE_ERROR_MARKET_BUSY = 4002,       // Market meşgul
   TRADE_ERROR_TOO_MANY_REQUESTS = 4003, // Çok fazla istek
   
   // Expert Advisor hataları
   TRADE_ERROR_EA_DISABLED = 5000,       // EA devre dışı
   TRADE_ERROR_TRADE_NOT_ALLOWED = 5001, // Ticaret izni yok
   TRADE_ERROR_LONGS_NOT_ALLOWED = 5002, // Long işlemler yasak
   TRADE_ERROR_SHORTS_NOT_ALLOWED = 5003, // Short işlemler yasak
   TRADE_ERROR_AUTO_TRADING_DISABLED = 5004, // Otomatik ticaret kapalı
   
   // Genel hatalar
   TRADE_ERROR_UNKNOWN = 9999            // Bilinmeyen hata
};

//+------------------------------------------------------------------+
//| Trade Request Yapısı                                            |
//+------------------------------------------------------------------+
struct TradeRequest
{
   ENUM_TRADE_REQUEST_ACTIONS action;    // İşlem türü
   ulong                     magic;      // Magic number
   ulong                     order;      // Emir numarası
   string                    symbol;     // Sembol
   double                    volume;     // Hacim
   double                    price;      // Fiyat
   double                    stoplimit;  // Stop limit fiyat
   double                    sl;         // Stop loss
   double                    tp;         // Take profit
   ulong                     deviation;  // Sapma
   ENUM_ORDER_TYPE           type;       // Emir türü
   ENUM_ORDER_TYPE_FILLING   type_filling; // Dolum türü
   ENUM_ORDER_TYPE_TIME      type_time;  // Zaman türü
   datetime                  expiration; // Son kullanma
   string                    comment;    // Yorum
   ulong                     position;   // Pozisyon numarası
   ulong                     position_by; // Karşı pozisyon
   
   // Constructor
   TradeRequest()
   {
      Reset();
   }
   
   // Copy constructor
   TradeRequest(const TradeRequest &other)
   {
      action = other.action;
      magic = other.magic;
      order = other.order;
      symbol = other.symbol;
      volume = other.volume;
      price = other.price;
      stoplimit = other.stoplimit;
      sl = other.sl;
      tp = other.tp;
      deviation = other.deviation;
      type = other.type;
      type_filling = other.type_filling;
      type_time = other.type_time;
      expiration = other.expiration;
      comment = other.comment;
      position = other.position;
      position_by = other.position_by;
   }
   
   // Assignment operator
   void operator=(const TradeRequest &other)
   {
      action = other.action;
      magic = other.magic;
      order = other.order;
      symbol = other.symbol;
      volume = other.volume;
      price = other.price;
      stoplimit = other.stoplimit;
      sl = other.sl;
      tp = other.tp;
      deviation = other.deviation;
      type = other.type;
      type_filling = other.type_filling;
      type_time = other.type_time;
      expiration = other.expiration;
      comment = other.comment;
      position = other.position;
      position_by = other.position_by;
   }
   
   void Reset()
   {
      action = TRADE_ACTION_DEAL;
      magic = 0;
      order = 0;
      symbol = _Symbol;
      volume = 0.01;
      price = 0.0;
      stoplimit = 0.0;
      sl = 0.0;
      tp = 0.0;
      deviation = 10;
      type = ORDER_TYPE_BUY;
      type_filling = ORDER_FILLING_FOK;
      type_time = ORDER_TIME_GTC;
      expiration = 0;
      comment = "";
      position = 0;
      position_by = 0;
   }
   
   string ToString() const
   {
      return StringFormat("Action: %d, Symbol: %s, Type: %d, Volume: %.2f, Price: %.5f, SL: %.5f, TP: %.5f",
                         (int)action,
                         symbol,
                         (int)type,
                         volume,
                         price,
                         sl,
                         tp);
   }
};

//+------------------------------------------------------------------+
//| Validation Result Yapısı                                        |
//+------------------------------------------------------------------+
struct ValidationResult
{
   ENUM_TRADE_VALIDATION_RESULT result_code;  // Sonuç kodu
   string                       message;      // Hata mesajı
   bool                         is_valid;     // Geçerli mi
   double                       corrected_price; // Düzeltilmiş fiyat
   double                       corrected_sl;    // Düzeltilmiş SL
   double                       corrected_tp;    // Düzeltilmiş TP
   double                       corrected_volume; // Düzeltilmiş hacim
   
   ValidationResult()
   {
      Reset();
   }
   
   // Copy constructor
   ValidationResult(const ValidationResult &other)
   {
      result_code = other.result_code;
      message = other.message;
      is_valid = other.is_valid;
      corrected_price = other.corrected_price;
      corrected_sl = other.corrected_sl;
      corrected_tp = other.corrected_tp;
      corrected_volume = other.corrected_volume;
   }
   
   // Assignment operator
   void operator=(const ValidationResult &other)
   {
      result_code = other.result_code;
      message = other.message;
      is_valid = other.is_valid;
      corrected_price = other.corrected_price;
      corrected_sl = other.corrected_sl;
      corrected_tp = other.corrected_tp;
      corrected_volume = other.corrected_volume;
   }
   
   void Reset()
   {
      result_code = TRADE_VALIDATION_OK;
      message = "";
      is_valid = false;
      corrected_price = 0.0;
      corrected_sl = 0.0;
      corrected_tp = 0.0;
      corrected_volume = 0.0;
   }
   
   string ToString() const
   {
      return StringFormat("Valid: %s, Code: %d, Message: %s",
                         (is_valid ? "YES" : "NO"),
                         result_code,
                         message);
   }
};

//+------------------------------------------------------------------+
//| Spread Limit Yapısı (Sembol Tipine Göre)                       |
//+------------------------------------------------------------------+
struct SpreadLimits
{
   double forex_major_points;      // Major forex çiftleri (EURUSD, GBPUSD vb.)
   double forex_minor_points;      // Minor forex çiftleri (EURJPY, GBPJPY vb.)
   double forex_exotic_points;     // Exotic forex çiftleri (USDTRY, USDZAR vb.)
   double metals_points;           // Altın, Gümüş
   double oil_points;              // Petrol, Doğalgaz
   double indices_points;          // Endeksler (DAX, SPX vb.)
   double crypto_points;           // Kripto paralar
   double stocks_points;           // Hisse senetleri
   double default_points;          // Diğer enstrümanlar
   
   SpreadLimits()
   {
      forex_major_points = 5.0;     // Major forex: 0.5-5 pip normal
      forex_minor_points = 15.0;    // Minor forex: 1.5-15 pip
      forex_exotic_points = 50.0;   // Exotic forex: 5-50 pip
      metals_points = 30.0;         // Altın/Gümüş: 3-30 pip
      oil_points = 10.0;            // Petrol: 1-10 pip
      indices_points = 20.0;        // Endeksler: değişken
      crypto_points = 100.0;        // Kripto: çok değişken
      stocks_points = 50.0;         // Hisse senetleri: değişken
      default_points = 25.0;        // Varsayılan
   }
};

//+------------------------------------------------------------------+
//| Trade Controller Konfigürasyonu (Güncellenmiş)                  |
//+------------------------------------------------------------------+
struct TradeControllerConfig
{
   bool     enable_market_check;        // Market kontrol etkin
   bool     enable_spread_check;        // Spread kontrol etkin
   bool     enable_margin_check;        // Margin kontrol etkin
   bool     enable_price_correction;    // Fiyat düzeltme etkin
   bool     enable_stop_correction;     // Stop düzeltme etkin
   bool     enable_volume_correction;   // Hacim düzeltme etkin
   bool     enable_dynamic_spread;      // Dinamik spread limiti
   
   SpreadLimits spread_limits;          // Sembol tipine göre spread limitleri
   double   max_spread_percent;         // Maksimum spread (%)
   double   min_margin_level;           // Minimum margin seviyesi
   double   max_slippage_points;        // Maksimum slippage
   int      max_retries;                // Maksimum deneme sayısı
   int      retry_delay_ms;             // Deneme arası bekleme (ms)
   
   TradeControllerConfig()
   {
      Reset();
   }
   
   void Reset()
   {
      enable_market_check = true;
      enable_spread_check = true;
      enable_margin_check = true;
      enable_price_correction = true;
      enable_stop_correction = true;
      enable_volume_correction = true;
      enable_dynamic_spread = true;      // Dinamik spread etkin
      
      spread_limits = SpreadLimits();    // Varsayılan spread limitleri
      max_spread_percent = 0.2;          // %0.2 maksimum spread
      min_margin_level = 100.0;
      max_slippage_points = 20.0;
      max_retries = 3;
      retry_delay_ms = 100;
   }
};

//+------------------------------------------------------------------+
//| Trade Controller Ana Sınıfı                                     |
//+------------------------------------------------------------------+
class CTradeController
{
private:
   TradeControllerConfig m_config;      // Konfigürasyon
   CSymbolInfo          m_symbol_info;  // Sembol bilgileri
   CAccountInfo         m_account_info; // Hesap bilgileri
   CPositionInfo        m_position_info; // Pozisyon bilgileri
   COrderInfo           m_order_info;   // Emir bilgileri
   CTrade               m_trade;        // Trade nesnesi
   
   string               m_current_symbol; // Aktif sembol
   bool                 m_initialized;    // Başlatılma durumu
   datetime             m_last_check_time; // Son kontrol zamanı
   
   // İç kontrol metodları
   ValidationResult CheckMarketStatus(const TradeRequest &request);
   ValidationResult CheckSymbolInfo(const TradeRequest &request);
   ValidationResult CheckTradingRights(const TradeRequest &request);
   ValidationResult CheckPriceValidity(const TradeRequest &request);
   ValidationResult CheckStopLevels(const TradeRequest &request);
   ValidationResult CheckVolumeValidity(const TradeRequest &request);
   ValidationResult CheckMarginRequirements(const TradeRequest &request);
   ValidationResult CheckSpreadLimits(const TradeRequest &request);
   ValidationResult CheckExpertAdvisorStatus();
   
   // Düzeltme metodları
   void CorrectPrices(TradeRequest &request, ValidationResult &result);
   void CorrectStopLevels(TradeRequest &request, ValidationResult &result);
   void CorrectVolume(TradeRequest &request, ValidationResult &result);
   
   // Yardımcı metodlar
   double NormalizePrice(const string symbol, const double price);
   double NormalizeLots(const string symbol, const double lots);
   bool IsMarketOpen(const string symbol);
   double GetMinStopLevel(const string symbol);
   double GetFreeMargin();
   double CalculateMarginRequired(const string symbol, const double volume, const ENUM_ORDER_TYPE type);
   
   // Spread yönetim metodları
   double GetMaxSpreadForSymbol(const string symbol);
   string GetSymbolType(const string symbol);
   bool IsForexMajor(const string symbol);
   bool IsForexMinor(const string symbol);
   bool IsForexExotic(const string symbol);
   bool IsMetal(const string symbol);
   bool IsOil(const string symbol);
   bool IsIndex(const string symbol);
   bool IsCrypto(const string symbol);
   bool IsStock(const string symbol);

public:
   CTradeController();
   ~CTradeController();
   
   // Başlatma ve sonlandırma
   bool Initialize(const TradeControllerConfig &config);
   bool Initialize();
   void Deinitialize();
   bool IsInitialized() const { return m_initialized; }
   
   // Konfigürasyon yönetimi
   void SetConfig(const TradeControllerConfig &config) { m_config = config; }
   TradeControllerConfig GetConfig() const { return m_config; }
   
   // Ana doğrulama metodları
   ValidationResult ValidateTradeRequest(const TradeRequest &request);
   ValidationResult ValidateAndCorrectRequest(TradeRequest &request);
   
   // Spesifik kontrol metodları
   bool CanTrade(const string symbol = "");
   bool CanOpenLong(const string symbol = "");
   bool CanOpenShort(const string symbol = "");
   bool HasSufficientMargin(const string symbol, const double volume, const ENUM_ORDER_TYPE type);
   bool IsSpreadAcceptable(const string symbol);
   bool IsPriceValid(const string symbol, const double price, const ENUM_ORDER_TYPE type);
   
   // Stop level kontrolleri
   bool IsStopLossValid(const string symbol, const ENUM_ORDER_TYPE type, const double price, const double sl);
   bool IsTakeProfitValid(const string symbol, const ENUM_ORDER_TYPE type, const double price, const double tp);
   double GetMinStopLossLevel(const string symbol, const ENUM_ORDER_TYPE type, const double price);
   double GetMinTakeProfitLevel(const string symbol, const ENUM_ORDER_TYPE type, const double price);
   
   // Bilgi metodları
   double GetCurrentSpread(const string symbol);
   double GetCurrentSpreadPercent(const string symbol);
   double GetCurrentMarginLevel();
   string GetMarketStatus(const string symbol);
   string GetTradingStatus(const string symbol);
   
   // Sembol değiştirme
   bool SetSymbol(const string symbol);
   string GetCurrentSymbol() const { return m_current_symbol; }
   
   // Trade execution metodları
   bool ExecuteValidatedTrade(const TradeRequest &request, ValidationResult &result);
   bool SafeOrderSend(const TradeRequest &request);
   bool SafePositionClose(const ulong ticket);
   bool SafePositionModify(const ulong ticket, const double sl, const double tp);
   
   // Debugging ve logging
   void LogValidationResult(const ValidationResult &result);
   void LogTradeRequest(const TradeRequest &request);
   string GetDetailedStatus();
   void PrintSystemInfo();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeController::CTradeController() : m_current_symbol(_Symbol), 
                                      m_initialized(false),
                                      m_last_check_time(0)
{
   m_config.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeController::~CTradeController()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CTradeController::Initialize(const TradeControllerConfig &config)
{
   m_config = config;
   
   // Sembol bilgilerini başlat
   if(!m_symbol_info.Name(m_current_symbol))
   {
      Print("ERROR: Symbol initialization failed for ", m_current_symbol);
      return false;
   }
   
   // Trade nesnesini başlat
   m_trade.SetExpertMagicNumber(0);
   m_trade.SetDeviationInPoints((ulong)m_config.max_slippage_points);
   
   m_initialized = true;
   m_last_check_time = TimeCurrent();
   
   Print("TradeController initialized successfully for symbol: ", m_current_symbol);
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CTradeController::Deinitialize()
{
   m_initialized = false;
   Print("TradeController deinitialized");
}

//+------------------------------------------------------------------+
//| Validate Trade Request                                           |
//+------------------------------------------------------------------+
ValidationResult CTradeController::ValidateTradeRequest(const TradeRequest &request)
{
   ValidationResult result;
   
   if(!m_initialized)
   {
      result.result_code = TRADE_ERROR_EA_DISABLED;
      result.message = "TradeController not initialized";
      result.is_valid = false;
      return result;
   }
   
   // Sembol kontrolü
   ValidationResult symbol_check = CheckSymbolInfo(request);
   if(!symbol_check.is_valid)
      return symbol_check;
   
   // Market durumu kontrolü
   if(m_config.enable_market_check)
   {
      ValidationResult market_check = CheckMarketStatus(request);
      if(!market_check.is_valid)
         return market_check;
   }
   
   // Trading rights kontrolü
   ValidationResult rights_check = CheckTradingRights(request);
   if(!rights_check.is_valid)
      return rights_check;
   
   // Expert Advisor durumu kontrolü
   ValidationResult ea_check = CheckExpertAdvisorStatus();
   if(!ea_check.is_valid)
      return ea_check;
   
   // Fiyat geçerliliği kontrolü
   ValidationResult price_check = CheckPriceValidity(request);
   if(!price_check.is_valid)
      return price_check;
   
   // Stop seviyeleri kontrolü
   ValidationResult stop_check = CheckStopLevels(request);
   if(!stop_check.is_valid)
      return stop_check;
   
   // Hacim kontrolü
   ValidationResult volume_check = CheckVolumeValidity(request);
   if(!volume_check.is_valid)
      return volume_check;
   
   // Margin kontrolü
   if(m_config.enable_margin_check)
   {
      ValidationResult margin_check = CheckMarginRequirements(request);
      if(!margin_check.is_valid)
         return margin_check;
   }
   
   // Spread kontrolü
   if(m_config.enable_spread_check)
   {
      ValidationResult spread_check = CheckSpreadLimits(request);
      if(!spread_check.is_valid)
         return spread_check;
   }
   
   // Tüm kontroller başarılı
   result.result_code = TRADE_VALIDATION_OK;
   result.message = "Trade request validation successful";
   result.is_valid = true;
   
   return result;
}

//+------------------------------------------------------------------+
//| Validate And Correct Request                                    |
//+------------------------------------------------------------------+
ValidationResult CTradeController::ValidateAndCorrectRequest(TradeRequest &request)
{
   ValidationResult result = ValidateTradeRequest(request);
   
   if(!result.is_valid)
   {
      // Düzeltme yapılabilir hatalar için düzeltme dene
      if(result.result_code == TRADE_ERROR_INVALID_PRICE && m_config.enable_price_correction)
      {
         CorrectPrices(request, result);
      }
      else if(result.result_code == TRADE_ERROR_INVALID_STOPS && m_config.enable_stop_correction)
      {
         CorrectStopLevels(request, result);
      }
      else if(result.result_code == TRADE_ERROR_INVALID_VOLUME && m_config.enable_volume_correction)
      {
         CorrectVolume(request, result);
      }
      
      // Düzeltme sonrası tekrar doğrula
      if(result.corrected_price > 0 || result.corrected_sl > 0 || result.corrected_tp > 0 || result.corrected_volume > 0)
      {
         result = ValidateTradeRequest(request);
         if(result.is_valid)
         {
            result.message += " (Auto-corrected)";
         }
      }
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Check Market Status                                              |
//+------------------------------------------------------------------+
ValidationResult CTradeController::CheckMarketStatus(const TradeRequest &request)
{
   ValidationResult result;
   
   if(!SetSymbol(request.symbol))
   {
      result.result_code = TRADE_ERROR_SYMBOL_NOT_FOUND;
      result.message = "Symbol not found: " + request.symbol;
      result.is_valid = false;
      return result;
   }
   
   // Market açık mı kontrol et
   if(!IsMarketOpen(request.symbol))
   {
      result.result_code = TRADE_ERROR_MARKET_CLOSED;
      result.message = "Market is closed for symbol: " + request.symbol;
      result.is_valid = false;
      return result;
   }
   
   // Bid/Ask fiyatları var mı
   double bid = m_symbol_info.Bid();
   double ask = m_symbol_info.Ask();
   
   if(bid <= 0.0 || ask <= 0.0)
   {
      result.result_code = TRADE_ERROR_NO_QUOTES;
      result.message = "No quotes available for symbol: " + request.symbol;
      result.is_valid = false;
      return result;
   }
   
   result.result_code = TRADE_VALIDATION_OK;
   result.message = "Market status OK";
   result.is_valid = true;
   return result;
}

//+------------------------------------------------------------------+
//| Check Symbol Info                                               |
//+------------------------------------------------------------------+
ValidationResult CTradeController::CheckSymbolInfo(const TradeRequest &request)
{
   ValidationResult result;
   
   if(!m_symbol_info.Name(request.symbol))
   {
      result.result_code = TRADE_ERROR_SYMBOL_NOT_FOUND;
      result.message = "Symbol not found: " + request.symbol;
      result.is_valid = false;
      return result;
   }
   
   // Sembol seçili mi
   if(!m_symbol_info.Select())
   {
      result.result_code = TRADE_ERROR_SYMBOL_DISABLED;
      result.message = "Symbol not selected: " + request.symbol;
      result.is_valid = false;
      return result;
   }
   
   result.result_code = TRADE_VALIDATION_OK;
   result.message = "Symbol info OK";
   result.is_valid = true;
   return result;
}

//+------------------------------------------------------------------+
//| Check Trading Rights                                             |
//+------------------------------------------------------------------+
ValidationResult CTradeController::CheckTradingRights(const TradeRequest &request)
{
   ValidationResult result;
   
   // Sembol üzerinde ticaret yapılabilir mi
   ENUM_SYMBOL_TRADE_MODE trade_mode = (ENUM_SYMBOL_TRADE_MODE)m_symbol_info.TradeMode();
   if(trade_mode == SYMBOL_TRADE_MODE_DISABLED || trade_mode == SYMBOL_TRADE_MODE_CLOSEONLY)
   {
      result.result_code = TRADE_ERROR_TRADING_DISABLED;
      result.message = "Trading disabled for symbol: " + request.symbol;
      result.is_valid = false;
      return result;
   }
   
   // Long pozisyonlar açılabilir mi
   if((request.type == ORDER_TYPE_BUY || request.type == ORDER_TYPE_BUY_LIMIT || 
       request.type == ORDER_TYPE_BUY_STOP) && !CanOpenLong(request.symbol))
   {
      result.result_code = TRADE_ERROR_LONGS_NOT_ALLOWED;
      result.message = "Long positions not allowed for symbol: " + request.symbol;
      result.is_valid = false;
      return result;
   }
   
   // Short pozisyonlar açılabilir mi
   if((request.type == ORDER_TYPE_SELL || request.type == ORDER_TYPE_SELL_LIMIT || 
       request.type == ORDER_TYPE_SELL_STOP) && !CanOpenShort(request.symbol))
   {
      result.result_code = TRADE_ERROR_SHORTS_NOT_ALLOWED;
      result.message = "Short positions not allowed for symbol: " + request.symbol;
      result.is_valid = false;
      return result;
   }
   
   result.result_code = TRADE_VALIDATION_OK;
   result.message = "Trading rights OK";
   result.is_valid = true;
   return result;
}

//+------------------------------------------------------------------+
//| Check Expert Advisor Status                                     |
//+------------------------------------------------------------------+
ValidationResult CTradeController::CheckExpertAdvisorStatus()
{
   ValidationResult result;
   
   // Otomatik ticaret etkin mi
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      result.result_code = TRADE_ERROR_AUTO_TRADING_DISABLED;
      result.message = "Auto trading disabled in terminal";
      result.is_valid = false;
      return result;
   }
   
   // Expert Advisor ticaret izni var mı
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
   {
      result.result_code = TRADE_ERROR_EA_DISABLED;
      result.message = "Expert Advisor trading not allowed";
      result.is_valid = false;
      return result;
   }
   
   result.result_code = TRADE_VALIDATION_OK;
   result.message = "Expert Advisor status OK";
   result.is_valid = true;
   return result;
}

//+------------------------------------------------------------------+
//| Check Price Validity                                            |
//+------------------------------------------------------------------+
ValidationResult CTradeController::CheckPriceValidity(const TradeRequest &request)
{
   ValidationResult result;
   
   if(request.price <= 0.0)
   {
      result.result_code = TRADE_ERROR_INVALID_PRICE;
      result.message = "Invalid price: " + DoubleToString(request.price);
      result.is_valid = false;
      return result;
   }
   
   // Market order için fiyat kontrolü
   if(request.action == TRADE_ACTION_DEAL)
   {
      double current_price = 0.0;
      
      if(request.type == ORDER_TYPE_BUY)
         current_price = m_symbol_info.Ask();
      else if(request.type == ORDER_TYPE_SELL)
         current_price = m_symbol_info.Bid();
      
      if(MathAbs(request.price - current_price) > m_config.max_slippage_points * m_symbol_info.Point())
      {
         result.result_code = TRADE_ERROR_PRICE_CHANGED;
         result.message = StringFormat("Price changed too much. Requested: %.5f, Current: %.5f", 
                                     request.price, current_price);
         result.is_valid = false;
         return result;
      }
   }
   
   result.result_code = TRADE_VALIDATION_OK;
   result.message = "Price validity OK";
   result.is_valid = true;
   return result;
}

//+------------------------------------------------------------------+
//| Check Stop Levels                                               |
//+------------------------------------------------------------------+
ValidationResult CTradeController::CheckStopLevels(const TradeRequest &request)
{
   ValidationResult result;
   
   double stop_level = GetMinStopLevel(request.symbol);
   
   // Stop Loss kontrolü
   if(request.sl > 0.0)
   {
      if(!IsStopLossValid(request.symbol, request.type, request.price, request.sl))
      {
         result.result_code = TRADE_ERROR_INVALID_SL;
         result.message = StringFormat("Invalid Stop Loss: %.5f (Min distance: %.1f points)", 
                                     request.sl, stop_level);
         result.is_valid = false;
         return result;
      }
   }
   
   // Take Profit kontrolü
   if(request.tp > 0.0)
   {
      if(!IsTakeProfitValid(request.symbol, request.type, request.price, request.tp))
      {
         result.result_code = TRADE_ERROR_INVALID_TP;
         result.message = StringFormat("Invalid Take Profit: %.5f (Min distance: %.1f points)", 
                                     request.tp, stop_level);
         result.is_valid = false;
         return result;
      }
   }
   
   result.result_code = TRADE_VALIDATION_OK;
   result.message = "Stop levels OK";
   result.is_valid = true;
   return result;
}

//+------------------------------------------------------------------+
//| Check Volume Validity                                           |
//+------------------------------------------------------------------+
ValidationResult CTradeController::CheckVolumeValidity(const TradeRequest &request)
{
   ValidationResult result;
   
   if(request.volume <= 0.0)
   {
      result.result_code = TRADE_ERROR_INVALID_VOLUME;
      result.message = "Invalid volume: " + DoubleToString(request.volume);
      result.is_valid = false;
      return result;
   }
   
   double min_volume = m_symbol_info.LotsMin();
   double max_volume = m_symbol_info.LotsMax();
   double step_volume = m_symbol_info.LotsStep();
   
   // Minimum hacim kontrolü
   if(request.volume < min_volume)
   {
      result.result_code = TRADE_ERROR_INVALID_VOLUME;
      result.message = StringFormat("Volume too small: %.2f (Min: %.2f)", request.volume, min_volume);
      result.is_valid = false;
      return result;
   }
   
   // Maksimum hacim kontrolü
   if(request.volume > max_volume)
   {
      result.result_code = TRADE_ERROR_INVALID_VOLUME;
      result.message = StringFormat("Volume too large: %.2f (Max: %.2f)", request.volume, max_volume);
      result.is_valid = false;
      return result;
   }
   
   // Hacim adımı kontrolü
   double normalized_volume = NormalizeLots(request.symbol, request.volume);
   if(MathAbs(request.volume - normalized_volume) > step_volume * 0.1)
   {
      result.result_code = TRADE_ERROR_INVALID_VOLUME;
      result.message = StringFormat("Invalid volume step: %.2f (Step: %.2f)", request.volume, step_volume);
      result.is_valid = false;
      return result;
   }
   
   result.result_code = TRADE_VALIDATION_OK;
   result.message = "Volume validity OK";
   result.is_valid = true;
   return result;
}

//+------------------------------------------------------------------+
//| Check Margin Requirements                                        |
//+------------------------------------------------------------------+
ValidationResult CTradeController::CheckMarginRequirements(const TradeRequest &request)
{
   ValidationResult result;
   
   // Gerekli margin hesapla
   double required_margin = CalculateMarginRequired(request.symbol, request.volume, request.type);
   double free_margin = GetFreeMargin();
   
   if(required_margin > free_margin)
   {
      result.result_code = TRADE_ERROR_NOT_ENOUGH_MONEY;
      result.message = StringFormat("Not enough money. Required: %.2f, Available: %.2f", 
                                   required_margin, free_margin);
      result.is_valid = false;
      return result;
   }
   
   // Margin seviyesi kontrolü
   double margin_level = GetCurrentMarginLevel();
   if(margin_level > 0 && margin_level < m_config.min_margin_level)
   {
      result.result_code = TRADE_ERROR_MARGIN_CHECK_FAILED;
      result.message = StringFormat("Margin level too low: %.2f%% (Min: %.2f%%)", 
                                   margin_level, m_config.min_margin_level);
      result.is_valid = false;
      return result;
   }
   
   result.result_code = TRADE_VALIDATION_OK;
   result.message = "Margin requirements OK";
   result.is_valid = true;
   return result;
}

//+------------------------------------------------------------------+
//| Check Spread Limits                                             |
//+------------------------------------------------------------------+
ValidationResult CTradeController::CheckSpreadLimits(const TradeRequest &request)
{
   ValidationResult result;
   
   double current_spread = GetCurrentSpread(request.symbol);
   double spread_percent = GetCurrentSpreadPercent(request.symbol);
   
   // Dinamik spread limiti kullan
   double max_allowed_spread = 0.0;
   if(m_config.enable_dynamic_spread)
   {
      max_allowed_spread = GetMaxSpreadForSymbol(request.symbol);
   }
   else
   {
      max_allowed_spread = m_config.spread_limits.default_points; // Varsayılan kullan
   }
   
   // Points cinsinden spread kontrolü
   if(current_spread > max_allowed_spread)
   {
      result.result_code = TRADE_ERROR_HIGH_SPREAD;
      result.message = StringFormat("Spread too high: %.1f points (Max: %.1f) - Symbol: %s (%s)", 
                                   current_spread, max_allowed_spread, request.symbol, GetSymbolType(request.symbol));
      result.is_valid = false;
      return result;
   }
   
   // Yüzde cinsinden spread kontrolü
   if(spread_percent > m_config.max_spread_percent)
   {
      result.result_code = TRADE_ERROR_HIGH_SPREAD;
      result.message = StringFormat("Spread too high: %.3f%% (Max: %.3f%%) - Symbol: %s", 
                                   spread_percent, m_config.max_spread_percent, request.symbol);
      result.is_valid = false;
      return result;
   }
   
   result.result_code = TRADE_VALIDATION_OK;
   result.message = StringFormat("Spread OK: %.1f points (%.3f%%) - %s", 
                                current_spread, spread_percent, GetSymbolType(request.symbol));
   result.is_valid = true;
   return result;
}

//+------------------------------------------------------------------+
//| Correct Prices                                                  |
//+------------------------------------------------------------------+
void CTradeController::CorrectPrices(TradeRequest &request, ValidationResult &result)
{
   if(request.action == TRADE_ACTION_DEAL)
   {
      if(request.type == ORDER_TYPE_BUY)
      {
         request.price = m_symbol_info.Ask();
         result.corrected_price = request.price;
      }
      else if(request.type == ORDER_TYPE_SELL)
      {
         request.price = m_symbol_info.Bid();
         result.corrected_price = request.price;
      }
   }
   
   request.price = NormalizePrice(request.symbol, request.price);
}

//+------------------------------------------------------------------+
//| Correct Stop Levels                                             |
//+------------------------------------------------------------------+
void CTradeController::CorrectStopLevels(TradeRequest &request, ValidationResult &result)
{
   // Stop Loss düzeltme
   if(request.sl > 0.0)
   {
      double corrected_sl = GetMinStopLossLevel(request.symbol, request.type, request.price);
      if(corrected_sl > 0.0)
      {
         request.sl = corrected_sl;
         result.corrected_sl = corrected_sl;
      }
   }
   
   // Take Profit düzeltme
   if(request.tp > 0.0)
   {
      double corrected_tp = GetMinTakeProfitLevel(request.symbol, request.type, request.price);
      if(corrected_tp > 0.0)
      {
         request.tp = corrected_tp;
         result.corrected_tp = corrected_tp;
      }
   }
}

//+------------------------------------------------------------------+
//| Correct Volume                                                  |
//+------------------------------------------------------------------+
void CTradeController::CorrectVolume(TradeRequest &request, ValidationResult &result)
{
   double corrected_volume = NormalizeLots(request.symbol, request.volume);
   
   double min_volume = m_symbol_info.LotsMin();
   double max_volume = m_symbol_info.LotsMax();
   
   if(corrected_volume < min_volume)
      corrected_volume = min_volume;
   else if(corrected_volume > max_volume)
      corrected_volume = max_volume;
   
   request.volume = corrected_volume;
   result.corrected_volume = corrected_volume;
}

//+------------------------------------------------------------------+
//| Utility Methods Implementation                                  |
//+------------------------------------------------------------------+

bool CTradeController::SetSymbol(const string symbol)
{
   if(m_current_symbol == symbol)
      return true;
   
   if(m_symbol_info.Name(symbol))
   {
      m_current_symbol = symbol;
      return true;
   }
   
   return false;
}

double CTradeController::NormalizePrice(const string symbol, const double price)
{
   if(!SetSymbol(symbol))
      return price;
   
   return NormalizeDouble(price, (int)m_symbol_info.Digits());
}

double CTradeController::NormalizeLots(const string symbol, const double lots)
{
   if(!SetSymbol(symbol))
      return lots;
   
   double step = m_symbol_info.LotsStep();
   return NormalizeDouble(MathRound(lots / step) * step, 2);
}

bool CTradeController::IsMarketOpen(const string symbol)
{
   if(!SetSymbol(symbol))
      return false;
   
   return (m_symbol_info.Bid() > 0 && m_symbol_info.Ask() > 0);
}

double CTradeController::GetMinStopLevel(const string symbol)
{
   if(!SetSymbol(symbol))
      return 0.0;
   
   return (double)m_symbol_info.StopsLevel();
}

bool CTradeController::CanTrade(const string symbol)
{
   string check_symbol = (symbol == "") ? m_current_symbol : symbol;
   
   if(!SetSymbol(check_symbol))
      return false;
   
   ENUM_SYMBOL_TRADE_MODE trade_mode = (ENUM_SYMBOL_TRADE_MODE)m_symbol_info.TradeMode();
   return (trade_mode != SYMBOL_TRADE_MODE_DISABLED);
}

bool CTradeController::CanOpenLong(const string symbol)
{
   string check_symbol = (symbol == "") ? m_current_symbol : symbol;
   
   if(!SetSymbol(check_symbol))
      return false;
   
   ENUM_SYMBOL_TRADE_MODE trade_mode = (ENUM_SYMBOL_TRADE_MODE)m_symbol_info.TradeMode();
   
   return (trade_mode == SYMBOL_TRADE_MODE_FULL || 
           trade_mode == SYMBOL_TRADE_MODE_LONGONLY);
}

bool CTradeController::CanOpenShort(const string symbol)
{
   string check_symbol = (symbol == "") ? m_current_symbol : symbol;
   
   if(!SetSymbol(check_symbol))
      return false;
   
   ENUM_SYMBOL_TRADE_MODE trade_mode = (ENUM_SYMBOL_TRADE_MODE)m_symbol_info.TradeMode();
   
   return (trade_mode == SYMBOL_TRADE_MODE_FULL || 
           trade_mode == SYMBOL_TRADE_MODE_SHORTONLY);
}

double CTradeController::GetCurrentSpread(const string symbol)
{
   string check_symbol = (symbol == "") ? m_current_symbol : symbol;
   
   if(!SetSymbol(check_symbol))
      return 0.0;
   
   return (m_symbol_info.Ask() - m_symbol_info.Bid()) / m_symbol_info.Point();
}

double CTradeController::GetCurrentSpreadPercent(const string symbol)
{
   string check_symbol = (symbol == "") ? m_current_symbol : symbol;
   
   if(!SetSymbol(check_symbol))
      return 0.0;
   
   double mid_price = (m_symbol_info.Ask() + m_symbol_info.Bid()) / 2.0;
   return ((m_symbol_info.Ask() - m_symbol_info.Bid()) / mid_price) * 100.0;
}

double CTradeController::GetFreeMargin()
{
   return m_account_info.FreeMargin();
}

double CTradeController::GetCurrentMarginLevel()
{
   double margin = m_account_info.Margin();
   if(margin == 0.0)
      return 0.0;
   
   return (m_account_info.Equity() / margin) * 100.0;
}

bool CTradeController::IsStopLossValid(const string symbol, const ENUM_ORDER_TYPE type, const double price, const double sl)
{
   if(sl <= 0.0)
      return true; // SL yoksa geçerli
   
   if(!SetSymbol(symbol))
      return false;
   
   double stop_level = GetMinStopLevel(symbol) * m_symbol_info.Point();
   
   if(type == ORDER_TYPE_BUY || type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP)
   {
      return (sl < price - stop_level);
   }
   else if(type == ORDER_TYPE_SELL || type == ORDER_TYPE_SELL_LIMIT || type == ORDER_TYPE_SELL_STOP)
   {
      return (sl > price + stop_level);
   }
   
   return false;
}

bool CTradeController::IsTakeProfitValid(const string symbol, const ENUM_ORDER_TYPE type, const double price, const double tp)
{
   if(tp <= 0.0)
      return true; // TP yoksa geçerli
   
   if(!SetSymbol(symbol))
      return false;
   
   double stop_level = GetMinStopLevel(symbol) * m_symbol_info.Point();
   
   if(type == ORDER_TYPE_BUY || type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP)
   {
      return (tp > price + stop_level);
   }
   else if(type == ORDER_TYPE_SELL || type == ORDER_TYPE_SELL_LIMIT || type == ORDER_TYPE_SELL_STOP)
   {
      return (tp < price - stop_level);
   }
   
   return false;
}

double CTradeController::CalculateMarginRequired(const string symbol, const double volume, const ENUM_ORDER_TYPE type)
{
   if(!SetSymbol(symbol))
      return 0.0;
   
   ENUM_ORDER_TYPE_FILLING filling = ORDER_FILLING_FOK;
   
   // Margin hesaplaması için OrderCalcMargin kullan
   double margin = 0.0;
   if(!OrderCalcMargin(type, symbol, volume, m_symbol_info.Ask(), margin))
   {
      // Basit hesaplama yap
      double contract_size = m_symbol_info.ContractSize();
      double margin_initial = m_symbol_info.MarginInitial();
      if(margin_initial > 0)
      {
         margin = volume * contract_size * m_symbol_info.Ask() / margin_initial;
      }
      else
      {
         // Varsayılan margin hesaplaması
         margin = volume * contract_size * m_symbol_info.Ask() * 0.01; // %1 margin
      }
   }
   
   return margin;
}

//+------------------------------------------------------------------+
//| Spread Yönetim Metodları Implementation                         |
//+------------------------------------------------------------------+

string CTradeController::GetSymbolType(const string symbol)
{
   if(IsForexMajor(symbol))
      return "Forex Major";
   else if(IsForexMinor(symbol))
      return "Forex Minor";
   else if(IsForexExotic(symbol))
      return "Forex Exotic";
   else if(IsMetal(symbol))
      return "Metal";
   else if(IsOil(symbol))
      return "Oil/Energy";
   else if(IsIndex(symbol))
      return "Index";
   else if(IsCrypto(symbol))
      return "Cryptocurrency";
   else if(IsStock(symbol))
      return "Stock";
   else
      return "Other";
}

double CTradeController::GetMaxSpreadForSymbol(const string symbol)
{
   if(IsForexMajor(symbol))
      return m_config.spread_limits.forex_major_points;
   else if(IsForexMinor(symbol))
      return m_config.spread_limits.forex_minor_points;
   else if(IsForexExotic(symbol))
      return m_config.spread_limits.forex_exotic_points;
   else if(IsMetal(symbol))
      return m_config.spread_limits.metals_points;
   else if(IsOil(symbol))
      return m_config.spread_limits.oil_points;
   else if(IsIndex(symbol))
      return m_config.spread_limits.indices_points;
   else if(IsCrypto(symbol))
      return m_config.spread_limits.crypto_points;
   else if(IsStock(symbol))
      return m_config.spread_limits.stocks_points;
   else
      return m_config.spread_limits.default_points;
}

bool CTradeController::IsForexMajor(const string symbol)
{
   // Major forex çiftleri (USD, EUR, GBP, JPY, CHF, CAD, AUD, NZD)
   string majors[] = {
      "EURUSD", "GBPUSD", "USDJPY", "USDCHF", "USDCAD", "AUDUSD", "NZDUSD",
      "EURJPY", "GBPJPY", "EURGBP", "EURAUD", "EURNZD", "EURCZK", "EURCHF",
      "GBPCHF", "GBPAUD", "GBPNZD", "GBPCAD", "AUDCAD", "AUDCHF", "AUDJPY",
      "AUDNZD", "CADCHF", "CADJPY", "CHFJPY", "NZDCAD", "NZDCHF", "NZDJPY"
   };
   
   for(int i = 0; i < ArraySize(majors); i++)
   {
      if(StringFind(symbol, majors[i]) >= 0)
         return true;
   }
   return false;
}

bool CTradeController::IsForexMinor(const string symbol)
{
   // Minor forex çiftleri (cross currencies)
   if(StringLen(symbol) == 6) // Forex format
   {
      if(!IsForexMajor(symbol) && !IsForexExotic(symbol))
      {
         // EUR, GBP, AUD, NZD, CAD, CHF, JPY içeriyorsa minor olabilir
         string base = StringSubstr(symbol, 0, 3);
         string quote = StringSubstr(symbol, 3, 3);
         
         string major_currencies[] = {"EUR", "GBP", "AUD", "NZD", "CAD", "CHF", "JPY"};
         
         bool base_major = false, quote_major = false;
         for(int i = 0; i < ArraySize(major_currencies); i++)
         {
            if(base == major_currencies[i]) base_major = true;
            if(quote == major_currencies[i]) quote_major = true;
         }
         
         return (base_major && quote_major);
      }
   }
   return false;
}

bool CTradeController::IsForexExotic(const string symbol)
{
   // Exotic forex çiftleri (gelişmekte olan ülke paraları)
   string exotics[] = {
      "TRY", "ZAR", "MXN", "BRL", "RUB", "CNH", "HKD", "SGD", "THB", 
      "PLN", "CZK", "HUF", "NOK", "SEK", "DKK", "ILS", "KRW", "INR"
   };
   
   for(int i = 0; i < ArraySize(exotics); i++)
   {
      if(StringFind(symbol, exotics[i]) >= 0)
         return true;
   }
   return false;
}

bool CTradeController::IsMetal(const string symbol)
{
   string metals[] = {"GOLD", "SILVER", "XAUUSD", "XAGUSD", "XAU", "XAG", "PLATINUM", "PALLADIUM"};
   string upper_symbol = symbol;
   StringToUpper(upper_symbol);
   
   for(int i = 0; i < ArraySize(metals); i++)
   {
      if(StringFind(upper_symbol, metals[i]) >= 0)
         return true;
   }
   return false;
}

bool CTradeController::IsOil(const string symbol)
{
   string oils[] = {"OIL", "WTI", "BRENT", "CRUDE", "NGAS", "NATURALGAS", "ENERGY"};
   string upper_symbol = symbol;
   StringToUpper(upper_symbol);
   
   for(int i = 0; i < ArraySize(oils); i++)
   {
      if(StringFind(upper_symbol, oils[i]) >= 0)
         return true;
   }
   return false;
}

bool CTradeController::IsIndex(const string symbol)
{
   string indices[] = {
      "SPX", "SPY", "SP500", "NASDAQ", "NDX", "DAX", "FTSE", "CAC", "NIKKEI", 
      "ASX", "HSI", "KOSPI", "SENSEX", "IBEX", "AEX", "BEL", "OMX", "WIG",
      "US30", "US100", "US500", "GER30", "UK100", "FRA40", "JPN225", "AUS200"
   };
   string upper_symbol = symbol;
   StringToUpper(upper_symbol);
   
   for(int i = 0; i < ArraySize(indices); i++)
   {
      if(StringFind(upper_symbol, indices[i]) >= 0)
         return true;
   }
   return false;
}

bool CTradeController::IsCrypto(const string symbol)
{
   string cryptos[] = {
      "BTC", "ETH", "XRP", "LTC", "ADA", "DOT", "LINK", "BCH", "XLM", "DOGE",
      "BITCOIN", "ETHEREUM", "RIPPLE", "LITECOIN", "CARDANO", "POLKADOT",
      "CHAINLINK", "STELLAR", "DOGECOIN", "CRYPTO"
   };
   string upper_symbol = symbol;
   StringToUpper(upper_symbol);
   
   for(int i = 0; i < ArraySize(cryptos); i++)
   {
      if(StringFind(upper_symbol, cryptos[i]) >= 0)
         return true;
   }
   return false;
}

bool CTradeController::IsStock(const string symbol)
{
   // Hisse senedi tespiti (genellikle nokta içerir veya belirli uzunlukta)
   if(StringFind(symbol, ".") >= 0) // AAPL.US gibi
      return true;
   
   // Bilinen hisse senedi kodları
   string stocks[] = {
      "AAPL", "MSFT", "GOOGL", "AMZN", "TSLA", "META", "NVDA", "NFLX", "AMD", "INTC",
      "JPM", "BAC", "WMT", "JNJ", "PG", "V", "MA", "DIS", "PFE", "KO"
   };
   string upper_symbol = symbol;
   StringToUpper(upper_symbol);
   
   for(int i = 0; i < ArraySize(stocks); i++)
   {
      if(StringFind(upper_symbol, stocks[i]) >= 0)
         return true;
   }
   return false;
}


//+------------------------------------------------------------------+
//| Safe Trade Execution Methods                                    |
//+------------------------------------------------------------------+

bool CTradeController::ExecuteValidatedTrade(const TradeRequest &request, ValidationResult &result)
{
   TradeRequest mutable_request = request; // Kopyala
   result = ValidateAndCorrectRequest(mutable_request);
   
   if(!result.is_valid)
   {
      LogValidationResult(result);
      return false;
   }
   
   return SafeOrderSend(mutable_request);
}

bool CTradeController::SafeOrderSend(const TradeRequest &request)
{
   MqlTradeRequest mql_request = {};
   MqlTradeResult mql_result = {};
   
   // MqlTradeRequest'i doldur
   mql_request.action = request.action;
   mql_request.magic = request.magic;
   mql_request.order = request.order;
   mql_request.symbol = request.symbol;
   mql_request.volume = request.volume;
   mql_request.price = request.price;
   mql_request.stoplimit = request.stoplimit;
   mql_request.sl = request.sl;
   mql_request.tp = request.tp;
   mql_request.deviation = request.deviation;
   mql_request.type = request.type;
   mql_request.type_filling = request.type_filling;
   mql_request.type_time = request.type_time;
   mql_request.expiration = request.expiration;
   mql_request.comment = request.comment;
   mql_request.position = request.position;
   mql_request.position_by = request.position_by;
   
   // Emri gönder
   bool success = OrderSend(mql_request, mql_result);
   
   if(!success)
   {
      Print("Order send failed: ", mql_result.comment, " (Code: ", mql_result.retcode, ")");
      return false;
   }
   
   Print("Order sent successfully: Ticket #", mql_result.order, ", Deal: ", mql_result.deal);
   return true;
}

//+------------------------------------------------------------------+
//| Logging and Debug Methods                                       |
//+------------------------------------------------------------------+

void CTradeController::LogValidationResult(const ValidationResult &result)
{
   Print("Validation Result: ", result.ToString());
}

void CTradeController::LogTradeRequest(const TradeRequest &request)
{
   Print("Trade Request: ", request.ToString());
}

string CTradeController::GetDetailedStatus()
{
   double current_spread = GetCurrentSpread(m_current_symbol);
   double max_spread = GetMaxSpreadForSymbol(m_current_symbol);
   double spread_percent = GetCurrentSpreadPercent(m_current_symbol);
   
   string status = StringFormat(
      "=== TradeController Status ===\n" +
      "Initialized: %s\n" +
      "Current Symbol: %s (%s)\n" +
      "Market Open: %s\n" +
      "Can Trade: %s\n" +
      "Can Long: %s\n" +
      "Can Short: %s\n" +
      "Current Spread: %.1f points (Max: %.1f)\n" +
      "Spread Percent: %.3f%%\n" +
      "Dynamic Spread: %s\n" +
      "Free Margin: %.2f\n" +
      "Margin Level: %.2f%%\n" +
      "Auto Trading: %s\n" +
      "EA Trading: %s",
      (m_initialized ? "YES" : "NO"),
      m_current_symbol,
      GetSymbolType(m_current_symbol),
      (IsMarketOpen(m_current_symbol) ? "YES" : "NO"),
      (CanTrade() ? "YES" : "NO"),
      (CanOpenLong() ? "YES" : "NO"),
      (CanOpenShort() ? "YES" : "NO"),
      current_spread,
      max_spread,
      spread_percent,
      (m_config.enable_dynamic_spread ? "YES" : "NO"),
      GetFreeMargin(),
      GetCurrentMarginLevel(),
      (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) ? "YES" : "NO"),
      (MQLInfoInteger(MQL_TRADE_ALLOWED) ? "YES" : "NO")
   );
   
   return status;
}

void CTradeController::PrintSystemInfo()
{
   Print(GetDetailedStatus());
}

//+------------------------------------------------------------------+
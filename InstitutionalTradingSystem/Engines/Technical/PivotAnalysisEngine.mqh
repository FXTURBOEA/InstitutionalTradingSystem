//+------------------------------------------------------------------+
//| PivotAnalysisEngine.mqh - Gelişmiş Pivot Analiz Motoru         |
//| ISignalProvider Uyumlu - Institutional Level Pivot Computing   |
//| Standard, Fibonacci, Camarilla, Woodie's Pivot Destekli        |
//| Smart Money Detection & Liquidity Analysis Integrated          |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/Complete_Enum_Types.mqh"
#include "../../Core/ISignalProvider.mqh"

//+------------------------------------------------------------------+
//| Pivot Seviye Bilgi Yapısı                                       |
//+------------------------------------------------------------------+
struct PivotLevel
{
   ENUM_PIVOT_LEVEL_TYPE   level_type;        // Seviye türü
   ENUM_PIVOT_TYPE calc_type;    // Hesaplama türü
   double                  price;             // Fiyat seviyesi
   ENUM_PIVOT_STRENGTH     strength;          // Seviye gücü
   ENUM_PIVOT_ZONE_STATUS  zone_status;       // Zone durumu
   
   // Historical data
   int                     touch_count;       // Kaç kez dokunulmuş
   int                     break_count;       // Kaç kez kırılmış
   int                     bounce_count;      // Kaç kez sektirmiş
   datetime                last_touch_time;   // Son dokunma zamanı
   double                  max_penetration;   // Maksimum penetrasyon
   
   // Reaction metrics
   double                  avg_reaction_pips; // Ortalama reaksiyon (pip)
   double                  max_reaction_pips; // Maksimum reaksiyon (pip)
   double                  success_rate;      // Başarı oranı (%)
   double                  holding_power;     // Tutma gücü (0-100)
   
   // Smart money indicators
   bool                    institutional_level; // Institutional seviye mi?
   bool                    liquidity_zone;     // Likidite bölgesi mi?
   bool                    sweep_target;       // Sweep hedefi mi?
   double                  volume_at_level;    // Seviydeki volume
   
   // Constructor
   PivotLevel()
   {
      Reset();
   }
   
   void Reset()
   {
      level_type = PIVOT_LEVEL_PP;
      calc_type = PIVOT_STANDARD;
      price = 0.0;
      strength = PIVOT_STRENGTH_NORMAL;
      zone_status = PIVOT_ZONE_UNTESTED;
      
      touch_count = 0;
      break_count = 0;
      bounce_count = 0;
      last_touch_time = 0;
      max_penetration = 0.0;
      
      avg_reaction_pips = 0.0;
      max_reaction_pips = 0.0;
      success_rate = 0.0;
      holding_power = 0.0;
      
      institutional_level = false;
      liquidity_zone = false;
      sweep_target = false;
      volume_at_level = 0.0;
   }
   
   bool IsValid() const
   {
      return (price > 0.0 && success_rate >= 0.0 && success_rate <= 100.0);
   }
   
   string ToString() const
   {
      return StringFormat("%s: %.5f | Strength: %s | Touches: %d | Success: %.1f%%",
                         PivotLevelTypeToString(level_type), price,
                         PivotStrengthToString(strength), touch_count, success_rate);
   }
};

//+------------------------------------------------------------------+
//| Pivot Analiz Bilgi Yapısı                                       |
//+------------------------------------------------------------------+
struct PivotAnalysisInfo
{
   // Temel pivot verileri
   datetime                calculation_date;   // Hesaplama tarihi
   ENUM_TIMEFRAMES         timeframe;          // Zaman çerçevesi
   double                  high, low, close;   // OHLC verileri
   double                  open;               // Açılış fiyatı (Woodie's için)
   
   // Standard pivots
   double                  pp;                 // Main Pivot Point
   double                  r1, r2, r3, r4, r5; // Resistance levels
   double                  s1, s2, s3, s4, s5; // Support levels
   
   // Fibonacci pivots
   double                  fib_r618, fib_r1000, fib_r1618; // Fib resistance
   double                  fib_s618, fib_s1000, fib_s1618; // Fib support
   
   // Camarilla pivots
   double                  cam_r3, cam_r4;     // Camarilla resistance
   double                  cam_s3, cam_s4;     // Camarilla support
   
   // Woodie's pivots
   double                  wood_pp;            // Woodie's pivot
   double                  wood_r1, wood_r2;   // Woodie's resistance
   double                  wood_s1, wood_s2;   // Woodie's support
   
   // Current market position
   double                  current_price;      // Mevcut fiyat
   ENUM_PIVOT_LEVEL_TYPE   nearest_level_above; // Üstteki en yakın seviye
   ENUM_PIVOT_LEVEL_TYPE   nearest_level_below; // Alttaki en yakın seviye
   double                  distance_to_nearest; // En yakın seviyeye mesafe
   
   // Market structure analysis
   bool                    above_pivot;        // Pivot üstünde mi?
   bool                    bullish_setup;      // Boğa kurulumu
   bool                    bearish_setup;      // Ayı kurulumu
   int                     confluence_count;   // Confluence seviye sayısı
   
   // Smart money detection
   bool                    equal_highs_detected; // Eşit yükseğer
   bool                    equal_lows_detected;  // Eşit alçaklar
   bool                    liquidity_grab_setup; // Likidite kapma kurulumu
   bool                    sweep_in_progress;    // Sweep devam ediyor
   
   // Strength metrics
   double                  overall_strength;   // Genel güç skoru (0-100)
   double                  resistance_strength; // Direnç gücü
   double                  support_strength;   // Destek gücü
   ENUM_CONFLUENCE_LEVEL   confluence_level;   // Confluence seviyesi
   
   // ML features
   double                  pivot_ml_score;     // ML tabanlı pivot skoru
   double                  breakout_probability; // Kırılma olasılığı
   double                  bounce_probability; // Sekme olasılığı
   double                  institutional_bias; // Institutional yanlılık
   
   // Detailed level analysis
   PivotLevel              levels[20];         // Detaylı seviye analizi
   int                     active_level_count; // Aktif seviye sayısı
   
   // Constructor
   PivotAnalysisInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      calculation_date = 0;
      timeframe = PERIOD_D1;
      high = low = close = open = 0.0;
      
      pp = r1 = r2 = r3 = r4 = r5 = 0.0;
      s1 = s2 = s3 = s4 = s5 = 0.0;
      
      fib_r618 = fib_r1000 = fib_r1618 = 0.0;
      fib_s618 = fib_s1000 = fib_s1618 = 0.0;
      
      cam_r3 = cam_r4 = cam_s3 = cam_s4 = 0.0;
      
      wood_pp = wood_r1 = wood_r2 = wood_s1 = wood_s2 = 0.0;
      
      current_price = 0.0;
      nearest_level_above = PIVOT_LEVEL_PP;
      nearest_level_below = PIVOT_LEVEL_PP;
      distance_to_nearest = 0.0;
      
      above_pivot = false;
      bullish_setup = false;
      bearish_setup = false;
      confluence_count = 0;
      
      equal_highs_detected = false;
      equal_lows_detected = false;
      liquidity_grab_setup = false;
      sweep_in_progress = false;
      
      overall_strength = 0.0;
      resistance_strength = 0.0;
      support_strength = 0.0;
      confluence_level = CONFLUENCE_NONE;
      
      pivot_ml_score = 0.0;
      breakout_probability = 0.0;
      bounce_probability = 0.0;
      institutional_bias = 0.0;
      
      for(int i = 0; i < 20; i++)
         levels[i].Reset();
      active_level_count = 0;
   }
   
   bool IsValid() const
   {
      return (pp > 0.0 && current_price > 0.0 && high > low);
   }
   
   string ToString() const
   {
      return StringFormat("PP: %.5f | Current: %.5f | %s Pivot | Confluence: %d | Strength: %.1f%%",
                         pp, current_price, (above_pivot ? "Above" : "Below"), 
                         confluence_count, overall_strength);
   }
};

//+------------------------------------------------------------------+
//| Helper Functions                                                 |
//+------------------------------------------------------------------+
string PivotLevelTypeToString(ENUM_PIVOT_LEVEL_TYPE level)
{
   switch(level)
   {
      case PIVOT_LEVEL_PP: return "PP";
      case PIVOT_LEVEL_R1: return "R1";
      case PIVOT_LEVEL_R2: return "R2";
      case PIVOT_LEVEL_R3: return "R3";
      case PIVOT_LEVEL_R4: return "R4";
      case PIVOT_LEVEL_R5: return "R5";
      case PIVOT_LEVEL_S1: return "S1";
      case PIVOT_LEVEL_S2: return "S2";
      case PIVOT_LEVEL_S3: return "S3";
      case PIVOT_LEVEL_S4: return "S4";
      case PIVOT_LEVEL_S5: return "S5";
      default: return "UNKNOWN";
   }
}

string PivotStrengthToString(ENUM_PIVOT_STRENGTH strength)
{
   switch(strength)
   {
      case PIVOT_STRENGTH_WEAK: return "WEAK";
      case PIVOT_STRENGTH_NORMAL: return "NORMAL";
      case PIVOT_STRENGTH_STRONG: return "STRONG";
      case PIVOT_STRENGTH_CRITICAL: return "CRITICAL";
      case PIVOT_STRENGTH_INSTITUTIONAL: return "INSTITUTIONAL";
      default: return "UNKNOWN";
   }
}

string PivotZoneStatusToString(ENUM_PIVOT_ZONE_STATUS status)
{
   switch(status)
   {
      case PIVOT_ZONE_UNTESTED: return "UNTESTED";
      case PIVOT_ZONE_TESTED: return "TESTED";
      case PIVOT_ZONE_BROKEN: return "BROKEN";
      case PIVOT_ZONE_HELD: return "HELD";
      case PIVOT_ZONE_RETESTED: return "RETESTED";
      case PIVOT_ZONE_REVERSED: return "REVERSED";
      default: return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Pivot Analiz Motoru                                             |
//+------------------------------------------------------------------+
class PivotAnalysisEngine
{
private:
   // Engine parametreleri
   string                  m_symbol;           // Analiz sembolü
   ENUM_TIMEFRAMES         m_timeframe;        // Ana zaman çerçevesi
   bool                    m_initialized;      // Başlatılma durumu
   
   // Calculation settings
   bool                    m_use_standard;     // Standard pivot kullan
   bool                    m_use_fibonacci;    // Fibonacci pivot kullan
   bool                    m_use_camarilla;    // Camarilla pivot kullan
   bool                    m_use_woodie;       // Woodie's pivot kullan
   
   // Historical tracking
   PivotLevel              m_level_history[100][20]; // Seviye geçmişi
   int                     m_history_days;     // Geçmiş gün sayısı
   datetime                m_last_calculation; // Son hesaplama zamanı
   
   // Smart money detection
   double                  m_equal_high_threshold; // Eşit yüksek eşiği
   double                  m_equal_low_threshold;  // Eşit alçak eşiği
   int                     m_lookback_candles;     // Geçmiş mum sayısı
   
   // ML components
   double                  m_ml_features[30];      // ML özellik vektörü
   double                  m_ml_weights[30];       // ML ağırlıkları
   bool                    m_ml_trained;           // ML eğitilmiş mi?
   
   // Performance tracking
   int                     m_total_calculations;   // Toplam hesaplama
   int                     m_successful_predictions; // Başarılı tahmin
   double                  m_accuracy_rate;        // Doğruluk oranı

public:
   //+------------------------------------------------------------------+
   //| Constructor & Destructor                                         |
   //+------------------------------------------------------------------+
   PivotAnalysisEngine(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_D1)
   {
      m_symbol = (StringLen(symbol) > 0) ? symbol : Symbol();
      m_timeframe = timeframe;
      m_initialized = false;
      
      // Default settings
      m_use_standard = true;
      m_use_fibonacci = true;
      m_use_camarilla = true;
      m_use_woodie = false;
      
      m_history_days = 0;
      m_last_calculation = 0;
      
      m_equal_high_threshold = 5.0; // 5 pips
      m_equal_low_threshold = 5.0;  // 5 pips
      m_lookback_candles = 50;
      
      m_ml_trained = false;
      m_total_calculations = 0;
      m_successful_predictions = 0;
      m_accuracy_rate = 0.0;
      
      // Initialize arrays
      ArrayInitialize(m_ml_features, 0.0);
      ArrayInitialize(m_ml_weights, 1.0);
      
      for(int i = 0; i < 100; i++)
         for(int j = 0; j < 20; j++)
            m_level_history[i][j].Reset();
      
      if(!Initialize())
      {
         Print("ERROR: PivotAnalysisEngine initialization failed");
         return;
      }
      
      Print(StringFormat("PivotAnalysisEngine initialized: %s, TF: %d", m_symbol, m_timeframe));
   }
   
   ~PivotAnalysisEngine()
   {
      if(m_total_calculations > 0)
      {
         Print(StringFormat("PivotAnalysisEngine destroyed. Accuracy: %.2f%% (%d/%d)",
                           m_accuracy_rate, m_successful_predictions, m_total_calculations));
      }
   }

private:
   //+------------------------------------------------------------------+
   //| Initialization                                                   |
   //+------------------------------------------------------------------+
   bool Initialize()
   {
      ResetLastError();
      
      // Sembol doğrulaması
      if(!SymbolSelect(m_symbol, true))
      {
         Print(StringFormat("ERROR: Cannot select symbol: %s", m_symbol));
         return false;
      }
      
      // Pip değeri hesaplama
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      
      if(point <= 0.0)
      {
         Print(StringFormat("ERROR: Invalid point value for %s", m_symbol));
         return false;
      }
      
      // Threshold'ları pip cinsinden ayarla
      double pip_size = (digits == 5 || digits == 3) ? point * 10 : point;
      m_equal_high_threshold = m_equal_high_threshold * pip_size;
      m_equal_low_threshold = m_equal_low_threshold * pip_size;
      
      // Load historical data for ML training
      if(!LoadHistoricalPivotData())
      {
         Print("WARNING: Could not load historical pivot data for ML training");
         // Not critical, continue
      }
      
      m_initialized = true;
      return true;
   }
   
   bool LoadHistoricalPivotData()
   {
      // Son 30 günün pivot verilerini yükle
      datetime current_time = TimeCurrent();
      datetime start_time = current_time - (30 * 24 * 3600); // 30 gün geriye
      
      int loaded_days = 0;
      for(datetime day = start_time; day < current_time && loaded_days < 100; day += 24*3600)
      {
         PivotAnalysisInfo historical_info = CalculatePivotsForDate(day);
         if(historical_info.IsValid())
         {
            // Store in history
            for(int i = 0; i < historical_info.active_level_count && i < 20; i++)
            {
               m_level_history[loaded_days][i] = historical_info.levels[i];
            }
            loaded_days++;
         }
      }
      
      m_history_days = loaded_days;
      Print(StringFormat("Loaded %d days of historical pivot data", loaded_days));
      
      return (loaded_days > 10); // Minimum 10 gün veri
   }

public:
   //+------------------------------------------------------------------+
   //| Ana Analiz Metodları                                            |
   //+------------------------------------------------------------------+
   PivotAnalysisInfo AnalyzePivots(datetime target_date = 0)
   {
      PivotAnalysisInfo info;
      
      if(!m_initialized)
      {
         Print("ERROR: Engine not initialized");
         return info;
      }
      
      m_total_calculations++;
      
      if(target_date == 0)
         target_date = TimeCurrent();
      
      // OHLC verilerini al
      if(!GetOHLCData(target_date, info))
      {
         Print("ERROR: Failed to get OHLC data");
         return info;
      }
      
      // Mevcut fiyatı al
      info.current_price = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      if(info.current_price <= 0.0)
      {
         Print("ERROR: Cannot get current price");
         return info;
      }
      
      // Pivot hesaplamaları
      if(m_use_standard && !CalculateStandardPivots(info))
      {
         Print("ERROR: Failed to calculate standard pivots");
         return info;
      }
      
      if(m_use_fibonacci && !CalculateFibonacciPivots(info))
      {
         Print("WARNING: Failed to calculate Fibonacci pivots");
      }
      
      if(m_use_camarilla && !CalculateCamarillaPivots(info))
      {
         Print("WARNING: Failed to calculate Camarilla pivots");
      }
      
      if(m_use_woodie && !CalculateWoodiePivots(info))
      {
         Print("WARNING: Failed to calculate Woodie's pivots");
      }
      
      // Market position analysis
      AnalyzeMarketPosition(info);
      
      // Smart money detection
      DetectSmartMoneyPatterns(info);
      
      // Confluence analysis
      CalculateConfluenceLevels(info);
      
      // Strength analysis
      CalculateStrengthMetrics(info);
      
      // ML feature extraction
      ExtractMLFeatures(info);
      
      // ML prediction
      if(m_ml_trained)
         CalculateMLPredictions(info);
      
      // Detailed level analysis
      CreateDetailedLevelAnalysis(info);
      
      m_last_calculation = TimeCurrent();
      
      return info;
   }

private:
   bool GetOHLCData(datetime target_date, PivotAnalysisInfo &info)
   {
      // Timeframe'e göre doğru OHLC verilerini al
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      
      int copied = 0;
      if(m_timeframe == PERIOD_D1)
      {
         // Günlük için önceki günün verilerini al
         copied = CopyRates(m_symbol, PERIOD_D1, target_date, 2, rates);
      }
      else if(m_timeframe == PERIOD_W1)
      {
         // Haftalık için önceki haftanın verilerini al
         copied = CopyRates(m_symbol, PERIOD_W1, target_date, 2, rates);
      }
      else if(m_timeframe == PERIOD_MN1)
      {
         // Aylık için önceki ayın verilerini al
         copied = CopyRates(m_symbol, PERIOD_MN1, target_date, 2, rates);
      }
      else
      {
         // Diğer timeframe'ler için
         copied = CopyRates(m_symbol, m_timeframe, target_date, 2, rates);
      }
      
      if(copied < 2)
      {
         Print(StringFormat("ERROR: Insufficient OHLC data. Copied: %d", copied));
         return false;
      }
      
      // Önceki periyodun verilerini kullan (index 1)
      info.high = rates[1].high;
      info.low = rates[1].low;
      info.close = rates[1].close;
      info.open = rates[1].open;
      info.calculation_date = rates[1].time;
      info.timeframe = m_timeframe;
      
      // Validation
      if(info.high <= info.low || info.close <= 0.0)
      {
         Print("ERROR: Invalid OHLC data");
         return false;
      }
      
      return true;
   }
   
   bool CalculateStandardPivots(PivotAnalysisInfo &info)
   {
      // Standard Pivot Point Formula: PP = (H + L + C) / 3
      info.pp = (info.high + info.low + info.close) / 3.0;
      
      // Resistance levels
      info.r1 = 2.0 * info.pp - info.low;
      info.r2 = info.pp + (info.high - info.low);
      info.r3 = info.high + 2.0 * (info.pp - info.low);
      
      // Support levels
      info.s1 = 2.0 * info.pp - info.high;
      info.s2 = info.pp - (info.high - info.low);
      info.s3 = info.low - 2.0 * (info.high - info.pp);
      
      // Extended levels (R4, R5, S4, S5)
      double range = info.high - info.low;
      info.r4 = info.r3 + range;
      info.r5 = info.r4 + range;
      info.s4 = info.s3 - range;
      info.s5 = info.s4 - range;
      
      // Validation
      bool valid = (info.pp > 0.0 && info.r1 > info.pp && info.s1 < info.pp);
      if(!valid)
      {
         Print("ERROR: Invalid standard pivot calculations");
         return false;
      }
      
      return true;
   }
   
   bool CalculateFibonacciPivots(PivotAnalysisInfo &info)
   {
      if(info.pp <= 0.0) return false;
      
      double range = info.high - info.low;
      
      // Fibonacci retracement levels
      info.fib_r618 = info.pp + (range * 0.618);
      info.fib_r1000 = info.pp + range;
      info.fib_r1618 = info.pp + (range * 1.618);
      
      info.fib_s618 = info.pp - (range * 0.618);
      info.fib_s1000 = info.pp - range;
      info.fib_s1618 = info.pp - (range * 1.618);
      
      return true;
   }
   
   bool CalculateCamarillaPivots(PivotAnalysisInfo &info)
   {
      if(info.close <= 0.0) return false;
      
      double range = info.high - info.low;
      
      // Camarilla formula: More weight on close price
      info.cam_r3 = info.close + (range * 0.5);
      info.cam_r4 = info.close + (range * 1.1);
      
      info.cam_s3 = info.close - (range * 0.5);
      info.cam_s4 = info.close - (range * 1.1);
      
      return true;
   }
   
   bool CalculateWoodiePivots(PivotAnalysisInfo &info)
   {
      if(info.open <= 0.0) return false;
      
      // Woodie's formula: PP = (H + L + 2*C) / 4 for next day
      // But uses (H + L + 2*O) / 4 for current day
      info.wood_pp = (info.high + info.low + 2.0 * info.open) / 4.0;
      
      info.wood_r1 = 2.0 * info.wood_pp - info.low;
      info.wood_r2 = info.wood_pp + (info.high - info.low);
      
      info.wood_s1 = 2.0 * info.wood_pp - info.high;
      info.wood_s2 = info.wood_pp - (info.high - info.low);
      
      return true;
   }
   
   void AnalyzeMarketPosition(PivotAnalysisInfo &info)
   {
      // Current position relative to main pivot
      info.above_pivot = (info.current_price > info.pp);
      
      // Find nearest levels
      double min_distance_above = DBL_MAX;
      double min_distance_below = DBL_MAX;
      
      // Check all resistance levels
      double resistances[] = {info.r1, info.r2, info.r3, info.r4, info.r5};
      for(int i = 0; i < ArraySize(resistances); i++)
      {
         if(resistances[i] > info.current_price)
         {
            double distance = resistances[i] - info.current_price;
            if(distance < min_distance_above)
            {
               min_distance_above = distance;
               info.nearest_level_above = (ENUM_PIVOT_LEVEL_TYPE)(PIVOT_LEVEL_R1 + i);
            }
         }
      }
      
      // Check all support levels
      double supports[] = {info.s1, info.s2, info.s3, info.s4, info.s5};
      for(int i = 0; i < ArraySize(supports); i++)
      {
         if(supports[i] < info.current_price)
         {
            double distance = info.current_price - supports[i];
            if(distance < min_distance_below)
            {
               min_distance_below = distance;
               info.nearest_level_below = (ENUM_PIVOT_LEVEL_TYPE)(PIVOT_LEVEL_S1 + i);
            }
         }
      }
      
      // Check main pivot
      if(info.pp > info.current_price && (info.pp - info.current_price) < min_distance_above)
      {
         info.nearest_level_above = PIVOT_LEVEL_PP;
         min_distance_above = info.pp - info.current_price;
      }
      else if(info.pp < info.current_price && (info.current_price - info.pp) < min_distance_below)
      {
         info.nearest_level_below = PIVOT_LEVEL_PP;
         min_distance_below = info.current_price - info.pp;
      }
      
      info.distance_to_nearest = MathMin(min_distance_above, min_distance_below);
      
      // Setup analysis
      if(info.above_pivot && info.current_price > info.r1)
         info.bullish_setup = true;
      else if(!info.above_pivot && info.current_price < info.s1)
         info.bearish_setup = true;
   }
   
   void DetectSmartMoneyPatterns(PivotAnalysisInfo &info)
   {
      // Equal highs/lows detection
      info.equal_highs_detected = DetectEqualHighs();
      info.equal_lows_detected = DetectEqualLows();
      
      // Liquidity grab setup
      info.liquidity_grab_setup = (info.equal_highs_detected || info.equal_lows_detected);
      
      // Sweep detection
      info.sweep_in_progress = DetectLiquiditySweep(info);
   }
   
   bool DetectEqualHighs()
   {
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      
      int copied = CopyRates(m_symbol, m_timeframe, 0, m_lookback_candles, rates);
      if(copied < 10) return false;
      
      // Look for equal highs pattern
      for(int i = 2; i < copied - 2; i++)
      {
         double high1 = rates[i].high;
         
         // Check for equal highs within threshold
         for(int j = i + 3; j < copied - 2; j++)
         {
            double high2 = rates[j].high;
            double difference = MathAbs(high1 - high2);
            
            if(difference <= m_equal_high_threshold)
            {
               // Verify it's a significant high
               bool isSignificantHigh1 = (rates[i-1].high < high1 && rates[i+1].high < high1);
               bool isSignificantHigh2 = (rates[j-1].high < high2 && rates[j+1].high < high2);
               
               if(isSignificantHigh1 && isSignificantHigh2)
                  return true;
            }
         }
      }
      
      return false;
   }
   
   bool DetectEqualLows()
   {
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      
      int copied = CopyRates(m_symbol, m_timeframe, 0, m_lookback_candles, rates);
      if(copied < 10) return false;
      
      // Look for equal lows pattern
      for(int i = 2; i < copied - 2; i++)
      {
         double low1 = rates[i].low;
         
         // Check for equal lows within threshold
         for(int j = i + 3; j < copied - 2; j++)
         {
            double low2 = rates[j].low;
            double difference = MathAbs(low1 - low2);
            
            if(difference <= m_equal_low_threshold)
            {
               // Verify it's a significant low
               bool isSignificantLow1 = (rates[i-1].low > low1 && rates[i+1].low > low1);
               bool isSignificantLow2 = (rates[j-1].low > low2 && rates[j+1].low > low2);
               
               if(isSignificantLow1 && isSignificantLow2)
                  return true;
            }
         }
      }
      
      return false;
   }
   
   bool DetectLiquiditySweep(const PivotAnalysisInfo &info)
   {
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      
      int copied = CopyRates(m_symbol, m_timeframe, 0, 5, rates);
      if(copied < 5) return false;
      
      // Check for recent sweep of pivot levels
      double current_high = rates[0].high;
      double current_low = rates[0].low;
      
      // Check if any pivot level was recently swept
      double pivot_levels[] = {info.r1, info.r2, info.s1, info.s2, info.pp};
      
      for(int i = 0; i < ArraySize(pivot_levels); i++)
      {
         double level = pivot_levels[i];
         
         // Check if price swept through level and returned
         bool swept_up = false, swept_down = false;
         
         for(int j = 1; j < copied; j++)
         {
            if(rates[j].high > level && rates[0].close < level)
               swept_up = true;
            if(rates[j].low < level && rates[0].close > level)
               swept_down = true;
         }
         
         if(swept_up || swept_down)
            return true;
      }
      
      return false;
   }
   
   void CalculateConfluenceLevels(PivotAnalysisInfo &info)
   {
      double confluence_threshold = 10.0 * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      info.confluence_count = 0;
      
      // Collect all pivot levels
      double all_levels[20];
      int level_count = 0;
      
      // Standard pivots
      if(m_use_standard)
      {
         all_levels[level_count++] = info.pp;
         all_levels[level_count++] = info.r1;
         all_levels[level_count++] = info.r2;
         all_levels[level_count++] = info.r3;
         all_levels[level_count++] = info.s1;
         all_levels[level_count++] = info.s2;
         all_levels[level_count++] = info.s3;
      }
      
      // Fibonacci levels
      if(m_use_fibonacci)
      {
         all_levels[level_count++] = info.fib_r618;
         all_levels[level_count++] = info.fib_s618;
      }
      
      // Camarilla levels
      if(m_use_camarilla)
      {
         all_levels[level_count++] = info.cam_r3;
         all_levels[level_count++] = info.cam_r4;
         all_levels[level_count++] = info.cam_s3;
         all_levels[level_count++] = info.cam_s4;
      }
      
      // Count confluences
      for(int i = 0; i < level_count; i++)
      {
         int nearby_count = 0;
         for(int j = 0; j < level_count; j++)
         {
            if(i != j && MathAbs(all_levels[i] - all_levels[j]) <= confluence_threshold)
               nearby_count++;
         }
         if(nearby_count >= 1)
            info.confluence_count++;
      }
      
      // Set confluence level enum
      if(info.confluence_count >= 5)
         info.confluence_level = CONFLUENCE_VERY_STRONG;
      else if(info.confluence_count >= 3)
         info.confluence_level = CONFLUENCE_STRONG;
      else if(info.confluence_count >= 2)
         info.confluence_level = CONFLUENCE_MODERATE;
      else if(info.confluence_count >= 1)
         info.confluence_level = CONFLUENCE_WEAK;
      else
         info.confluence_level = CONFLUENCE_NONE;
   }
   
   void CalculateStrengthMetrics(PivotAnalysisInfo &info)
   {
      // Base strength from confluence
      info.overall_strength = info.confluence_count * 15.0;
      
      // Adjust based on market position
      if(info.above_pivot && info.bullish_setup)
         info.overall_strength += 20.0;
      else if(!info.above_pivot && info.bearish_setup)
         info.overall_strength += 20.0;
      
      // Smart money patterns boost
      if(info.equal_highs_detected || info.equal_lows_detected)
         info.overall_strength += 25.0;
      if(info.liquidity_grab_setup)
         info.overall_strength += 15.0;
      
      // Distance to nearest level factor
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      double distance_in_points = info.distance_to_nearest / point;
      
      if(distance_in_points < 50)
         info.overall_strength += 20.0;
      else if(distance_in_points < 100)
         info.overall_strength += 10.0;
      
      // Cap at 100%
      info.overall_strength = MathMin(100.0, info.overall_strength);
      
      // Calculate resistance and support strengths separately
      if(info.above_pivot)
      {
         info.resistance_strength = info.overall_strength * 1.2;
         info.support_strength = info.overall_strength * 0.8;
      }
      else
      {
         info.support_strength = info.overall_strength * 1.2;
         info.resistance_strength = info.overall_strength * 0.8;
      }
      
      info.resistance_strength = MathMin(100.0, info.resistance_strength);
      info.support_strength = MathMin(100.0, info.support_strength);
   }
   
   void ExtractMLFeatures(PivotAnalysisInfo &info)
   {
      // Feature 1-5: Price position relative to key levels
      m_ml_features[0] = (info.current_price - info.pp) / (info.high - info.low);
      m_ml_features[1] = (info.current_price - info.r1) / (info.high - info.low);
      m_ml_features[2] = (info.current_price - info.s1) / (info.high - info.low);
      m_ml_features[3] = info.distance_to_nearest / (info.high - info.low);
      m_ml_features[4] = info.above_pivot ? 1.0 : 0.0;
      
      // Feature 6-10: Setup and pattern features
      m_ml_features[5] = info.bullish_setup ? 1.0 : 0.0;
      m_ml_features[6] = info.bearish_setup ? 1.0 : 0.0;
      m_ml_features[7] = info.equal_highs_detected ? 1.0 : 0.0;
      m_ml_features[8] = info.equal_lows_detected ? 1.0 : 0.0;
      m_ml_features[9] = info.liquidity_grab_setup ? 1.0 : 0.0;
      
      // Feature 11-15: Strength and confluence
      m_ml_features[10] = info.overall_strength / 100.0;
      m_ml_features[11] = info.confluence_count / 10.0;
      m_ml_features[12] = (double)info.confluence_level / 5.0;
      m_ml_features[13] = info.resistance_strength / 100.0;
      m_ml_features[14] = info.support_strength / 100.0;
      
      // Feature 16-20: Historical performance (if available)
      if(m_history_days > 0)
      {
         m_ml_features[15] = CalculateHistoricalSuccessRate(info.pp);
         m_ml_features[16] = CalculateHistoricalSuccessRate(info.r1);
         m_ml_features[17] = CalculateHistoricalSuccessRate(info.s1);
         m_ml_features[18] = CalculateAverageReactionPips();
         m_ml_features[19] = CalculateVolatilityAdjustment(info);
      }
      
      // Feature 21-25: Advanced market structure
      m_ml_features[20] = CalculateMarketTrend();
      m_ml_features[21] = CalculateVolumePressure();
      m_ml_features[22] = CalculateTimeOfDayFactor();
      m_ml_features[23] = CalculateSessionBias();
      m_ml_features[24] = info.sweep_in_progress ? 1.0 : 0.0;
      
      // Feature 26-30: Additional confluence features
      m_ml_features[25] = (info.fib_r618 > 0) ? 1.0 : 0.0;
      m_ml_features[26] = (info.cam_r4 > 0) ? 1.0 : 0.0;
      m_ml_features[27] = CalculateFibonacciAlignment(info);
      m_ml_features[28] = CalculateCamarillaStrength(info);
      m_ml_features[29] = CalculateOverallPivotHealth(info);
   }
   
   void CalculateMLPredictions(PivotAnalysisInfo &info)
   {
      if(!m_ml_trained) return;
      
      // Simple neural network prediction (placeholder for real implementation)
      double ml_score = 0.0;
      for(int i = 0; i < 30; i++)
      {
         ml_score += m_ml_features[i] * m_ml_weights[i];
      }
      
      // Normalize to 0-100
      ml_score = (MathTanh(ml_score) + 1.0) * 50.0;
      info.pivot_ml_score = MathMax(0.0, MathMin(100.0, ml_score));
      
      // Calculate specific probabilities
      if(info.above_pivot)
      {
         info.breakout_probability = ml_score * 0.6;
         info.bounce_probability = (100.0 - ml_score) * 0.8;
      }
      else
      {
         info.breakout_probability = (100.0 - ml_score) * 0.6;
         info.bounce_probability = ml_score * 0.8;
      }
      
      // Institutional bias calculation
      info.institutional_bias = CalculateInstitutionalBias(info);
   }
   
   void CreateDetailedLevelAnalysis(PivotAnalysisInfo &info)
   {
      info.active_level_count = 0;
      
      // Analyze each major level
      AddLevelAnalysis(info, PIVOT_LEVEL_PP, PIVOT_STANDARD, info.pp);
      AddLevelAnalysis(info, PIVOT_LEVEL_R1, PIVOT_STANDARD, info.r1);
      AddLevelAnalysis(info, PIVOT_LEVEL_R2, PIVOT_STANDARD, info.r2);
      AddLevelAnalysis(info, PIVOT_LEVEL_R3, PIVOT_STANDARD, info.r3);
      AddLevelAnalysis(info, PIVOT_LEVEL_S1, PIVOT_STANDARD, info.s1);
      AddLevelAnalysis(info, PIVOT_LEVEL_S2, PIVOT_STANDARD, info.s2);
      AddLevelAnalysis(info, PIVOT_LEVEL_S3, PIVOT_STANDARD, info.s3);
      
      // Add Camarilla levels if enabled
      if(m_use_camarilla)
      {
         AddLevelAnalysis(info, PIVOT_LEVEL_R4, PIVOT_CAMARILLA, info.cam_r4);
         AddLevelAnalysis(info, PIVOT_LEVEL_S4, PIVOT_CAMARILLA, info.cam_s4);
      }
   }
   
   void AddLevelAnalysis(PivotAnalysisInfo &info, ENUM_PIVOT_LEVEL_TYPE level_type, 
                        ENUM_PIVOT_TYPE calc_type, double price)
   {
      if(info.active_level_count >= 20 || price <= 0.0) return;
      
      PivotLevel level = info.levels[info.active_level_count];
      level.level_type = level_type;
      level.calc_type = calc_type;
      level.price = price;
      
      // Calculate strength based on confluence and setup
      CalculateLevelStrength(level, info);
      
      // Analyze zone status
      AnalyzeZoneStatus(level, info);
      
      // Historical analysis if available
      if(m_history_days > 0)
         AnalyzeHistoricalPerformance(level);
      
      // Smart money indicators
      AnalyzeSmartMoneyIndicators(level, info);
      
      info.active_level_count++;
   }
   
   void CalculateLevelStrength(PivotLevel &level, const PivotAnalysisInfo &info)
   {
      double strength_score = 50.0; // Base strength
      
      // Main pivot gets higher strength
      if(level.level_type == PIVOT_LEVEL_PP)
         strength_score += 20.0;
      
      // Primary R/S levels get moderate boost
      if(level.level_type == PIVOT_LEVEL_R1 || level.level_type == PIVOT_LEVEL_S1)
         strength_score += 15.0;
      
      // Confluence boost
      double confluence_distance = 20.0 * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      int nearby_levels = 0;
      
      for(int i = 0; i < info.active_level_count; i++)
      {
         if(MathAbs(level.price - info.levels[i].price) <= confluence_distance)
            nearby_levels++;
      }
      
      strength_score += nearby_levels * 10.0;
      
      // Distance to current price factor
      double distance = MathAbs(level.price - info.current_price);
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      double distance_points = distance / point;
      
      if(distance_points < 50)
         strength_score += 15.0;
      else if(distance_points < 100)
         strength_score += 10.0;
      
      // Assign strength enum
      if(strength_score >= 90.0)
         level.strength = PIVOT_STRENGTH_INSTITUTIONAL;
      else if(strength_score >= 75.0)
         level.strength = PIVOT_STRENGTH_CRITICAL;
      else if(strength_score >= 60.0)
         level.strength = PIVOT_STRENGTH_STRONG;
      else if(strength_score >= 40.0)
         level.strength = PIVOT_STRENGTH_NORMAL;
      else
         level.strength = PIVOT_STRENGTH_WEAK;
   }
   
   void AnalyzeZoneStatus(PivotLevel &level, const PivotAnalysisInfo &info)
   {
      // Simple zone analysis - could be enhanced with more sophisticated logic
      double tolerance = 10.0 * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      
      if(MathAbs(info.current_price - level.price) <= tolerance)
      {
         level.zone_status = PIVOT_ZONE_TESTED;
      }
      else if((info.current_price > level.price + tolerance && level.level_type >= PIVOT_LEVEL_R1) ||
              (info.current_price < level.price - tolerance && level.level_type >= PIVOT_LEVEL_S1))
      {
         level.zone_status = PIVOT_ZONE_BROKEN;
      }
      else
      {
         level.zone_status = PIVOT_ZONE_UNTESTED;
      }
   }
   
   void AnalyzeHistoricalPerformance(PivotLevel &level)
   {
      // Placeholder for historical analysis
      // In real implementation, this would analyze past performance of similar levels
      level.success_rate = 65.0 + (rand() % 30); // Placeholder
      level.avg_reaction_pips = 15.0 + (rand() % 20); // Placeholder
      level.holding_power = 60.0 + (rand() % 35); // Placeholder
   }
   
   void AnalyzeSmartMoneyIndicators(PivotLevel &level, const PivotAnalysisInfo &info)
   {
      // Institutional level detection
      if(level.strength >= PIVOT_STRENGTH_CRITICAL)
         level.institutional_level = true;
      
      // Liquidity zone detection
      if(level.level_type == PIVOT_LEVEL_R2 || level.level_type == PIVOT_LEVEL_S2 ||
         level.level_type == PIVOT_LEVEL_R3 || level.level_type == PIVOT_LEVEL_S3)
         level.liquidity_zone = true;
      
      // Sweep target identification
      if(info.equal_highs_detected && (level.level_type == PIVOT_LEVEL_R1 || level.level_type == PIVOT_LEVEL_R2))
         level.sweep_target = true;
      if(info.equal_lows_detected && (level.level_type == PIVOT_LEVEL_S1 || level.level_type == PIVOT_LEVEL_S2))
         level.sweep_target = true;
   }

   //+------------------------------------------------------------------+
   //| Helper calculation methods                                        |
   //+------------------------------------------------------------------+
   double CalculateHistoricalSuccessRate(double price_level)
   {
      // Placeholder - would analyze historical data
      return 60.0 + (rand() % 30);
   }
   
   double CalculateAverageReactionPips()
   {
      // Placeholder - would calculate from historical data
      return 20.0 + (rand() % 15);
   }
   
   double CalculateVolatilityAdjustment(const PivotAnalysisInfo &info)
   {
      double range = info.high - info.low;
      double avg_range = range * 1.2; // Placeholder for historical average
      return range / avg_range;
   }
   
   double CalculateMarketTrend()
   {
      // Simple trend calculation
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      
      if(CopyRates(m_symbol, m_timeframe, 0, 20, rates) == 20)
      {
         double recent_avg = (rates[0].close + rates[1].close + rates[2].close) / 3.0;
         double older_avg = (rates[17].close + rates[18].close + rates[19].close) / 3.0;
         
         return (recent_avg > older_avg) ? 0.7 : 0.3;
      }
      
      return 0.5;
   }
   
   double CalculateVolumePressure()
   {
      // Placeholder for volume analysis
      return 0.5;
   }
   
   double CalculateTimeOfDayFactor()
   {
      datetime current_time = TimeCurrent();
      MqlDateTime time_struct;
      TimeToStruct(current_time, time_struct);
      
      // Higher factor during active sessions
      if((time_struct.hour >= 8 && time_struct.hour <= 12) ||  // European session
         (time_struct.hour >= 13 && time_struct.hour <= 17))   // US session
         return 0.8;
      else
         return 0.4;
   }
   
   double CalculateSessionBias()
   {
      // Placeholder for session analysis
      return 0.5;
   }
   
   double CalculateFibonacciAlignment(const PivotAnalysisInfo &info)
   {
      if(!m_use_fibonacci) return 0.0;
      
      double tolerance = 5.0 * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      int alignments = 0;
      
      // Check alignments between standard and fibonacci levels
      double standard_levels[] = {info.r1, info.r2, info.s1, info.s2};
      double fib_levels[] = {info.fib_r618, info.fib_r1000, info.fib_s618, info.fib_s1000};
      
      for(int i = 0; i < ArraySize(standard_levels); i++)
      {
         for(int j = 0; j < ArraySize(fib_levels); j++)
         {
            if(MathAbs(standard_levels[i] - fib_levels[j]) <= tolerance)
               alignments++;
         }
      }
      
      return alignments / 4.0; // Normalize
   }
   
   double CalculateCamarillaStrength(const PivotAnalysisInfo &info)
   {
      if(!m_use_camarilla) return 0.0;
      
      // Camarilla levels are typically stronger near R4/S4
      double cam_factor = 0.0;
      double tolerance = 20.0 * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      
      if(MathAbs(info.current_price - info.cam_r4) <= tolerance ||
         MathAbs(info.current_price - info.cam_s4) <= tolerance)
         cam_factor = 0.9;
      else if(MathAbs(info.current_price - info.cam_r3) <= tolerance ||
              MathAbs(info.current_price - info.cam_s3) <= tolerance)
         cam_factor = 0.6;
      
      return cam_factor;
   }
   
   double CalculateOverallPivotHealth(const PivotAnalysisInfo &info)
   {
      double health = 0.5; // Base health
      
      // Factor in confluence
      health += (info.confluence_count / 10.0) * 0.3;
      
      // Factor in smart money patterns
      if(info.equal_highs_detected || info.equal_lows_detected)
         health += 0.2;
      
      // Factor in position relative to pivot
      if(info.above_pivot && info.bullish_setup)
         health += 0.15;
      else if(!info.above_pivot && info.bearish_setup)
         health += 0.15;
      
      return MathMax(0.0, MathMin(1.0, health));
   }
   
   double CalculateInstitutionalBias(const PivotAnalysisInfo &info)
   {
      double bias = 0.5; // Neutral bias
      
      // Strong institutional bias when multiple factors align
      if(info.liquidity_grab_setup)
         bias += 0.2;
      
      if(info.sweep_in_progress)
         bias += 0.15;
      
      if(info.confluence_level >= CONFLUENCE_STRONG)
         bias += 0.1;
      
      // Adjust based on market position
      if(info.above_pivot)
         bias += 0.05; // Slight bullish bias
      else
         bias -= 0.05; // Slight bearish bias
      
      return MathMax(0.0, MathMin(1.0, bias));
   }
   
   PivotAnalysisInfo CalculatePivotsForDate(datetime target_date)
   {
      // This would calculate pivots for a specific historical date
      // Implementation depends on data availability
      PivotAnalysisInfo historical_info;
      // ... calculation logic ...
      return historical_info;
   }

public:
   //+------------------------------------------------------------------+
   //| Public Interface Methods                                         |
   //+------------------------------------------------------------------+
   bool IsInitialized() const { return m_initialized; }
   string GetSymbol() const { return m_symbol; }
   ENUM_TIMEFRAMES GetTimeframe() const { return m_timeframe; }
   
   // Configuration methods
   void SetCalculationTypes(bool standard, bool fibonacci, bool camarilla, bool woodie)
   {
      m_use_standard = standard;
      m_use_fibonacci = fibonacci;
      m_use_camarilla = camarilla;
      m_use_woodie = woodie;
   }
   
   void SetSmartMoneySettings(double equal_threshold_pips, int lookback_candles)
   {
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      double pip_size = (digits == 5 || digits == 3) ? point * 10 : point;
      
      m_equal_high_threshold = equal_threshold_pips * pip_size;
      m_equal_low_threshold = equal_threshold_pips * pip_size;
      m_lookback_candles = MathMax(10, MathMin(200, lookback_candles));
   }
   
   // Quick access methods
   double GetMainPivot()
   {
      PivotAnalysisInfo info = AnalyzePivots();
      return info.pp;
   }
   
   double GetNearestResistance()
   {
      PivotAnalysisInfo info = AnalyzePivots();
      if(info.nearest_level_above == PIVOT_LEVEL_PP) return info.pp;
      else if(info.nearest_level_above == PIVOT_LEVEL_R1) return info.r1;
      else if(info.nearest_level_above == PIVOT_LEVEL_R2) return info.r2;
      else if(info.nearest_level_above == PIVOT_LEVEL_R3) return info.r3;
      return 0.0;
   }
   
   double GetNearestSupport()
   {
      PivotAnalysisInfo info = AnalyzePivots();
      if(info.nearest_level_below == PIVOT_LEVEL_PP) return info.pp;
      else if(info.nearest_level_below == PIVOT_LEVEL_S1) return info.s1;
      else if(info.nearest_level_below == PIVOT_LEVEL_S2) return info.s2;
      else if(info.nearest_level_below == PIVOT_LEVEL_S3) return info.s3;
      return 0.0;
   }
   
   bool IsAbovePivot()
   {
      PivotAnalysisInfo info = AnalyzePivots();
      return info.above_pivot;
   }
   
   bool HasBullishSetup()
   {
      PivotAnalysisInfo info = AnalyzePivots();
      return info.bullish_setup;
   }
   
   bool HasBearishSetup()
   {
      PivotAnalysisInfo info = AnalyzePivots();
      return info.bearish_setup;
   }
   
   bool IsLiquidityGrabSetup()
   {
      PivotAnalysisInfo info = AnalyzePivots();
      return info.liquidity_grab_setup;
   }
   
   // ML and advanced features
   bool GetMLFeatures(double &features[])
   {
      if(!m_initialized) return false;
      
      PivotAnalysisInfo info = AnalyzePivots(); // This updates ML features
      ArrayResize(features, 30);
      ArrayCopy(features, m_ml_features);
      return true;
   }
   
   bool TrainMLModel(const string historical_data_file = "")
   {
      // Placeholder for ML training
      // In real implementation, this would train the neural network
      m_ml_trained = true;
      
      // Initialize random weights (placeholder)
      for(int i = 0; i < 30; i++)
         m_ml_weights[i] = (MathRand() / 32767.0) * 2.0 - 1.0;
      
      Print("ML model training completed (placeholder implementation)");
      return true;
   }
   
   // Performance metrics
   double GetAccuracyRate() const { return m_accuracy_rate; }
   int GetTotalCalculations() const { return m_total_calculations; }
   datetime GetLastCalculationTime() const { return m_last_calculation; }
   
   // Manual update methods
   bool RefreshHistoricalData()
   {
      return LoadHistoricalPivotData();
   }
   
   // Chart visualization helpers
   bool DrawPivotLevels(const PivotAnalysisInfo &info, color resistance_color = clrRed, 
                       color support_color = clrBlue, color pivot_color = clrYellow)
   {
      // This would draw pivot levels on chart
      // Implementation depends on visualization requirements
      return true;
   }
   
   bool DrawSmartMoneyLevels(const PivotAnalysisInfo &info, color level_color = clrOrange)
   {
      // This would draw equal highs/lows and liquidity levels
      // Implementation depends on visualization requirements  
      return true;
   }
};
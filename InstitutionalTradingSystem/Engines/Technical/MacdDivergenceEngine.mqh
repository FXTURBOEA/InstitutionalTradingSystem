//+------------------------------------------------------------------+
//| MacdDivergenceEngine.mqh - Gelişmiş MACD Divergence Analiz Motoru |
//| ISignalProvider Uyumlu - Multi-timeframe MACD & Advanced Signals |
//| Institutional Grade MACD Analysis + ML Enhanced Divergence       |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/Complete_Enum_Types.mqh"
#include "../../Core/ISignalProvider.mqh"

//+------------------------------------------------------------------+
//| Peak Bilgi Yapısı - Divergence Detection için                   |
//+------------------------------------------------------------------+
struct PeakInfo
{
   int index;
   double price;
   double macd;
   double histogram;
   bool is_high;
   
   PeakInfo()
   {
      index = 0;
      price = 0.0;
      macd = 0.0;
      histogram = 0.0;
      is_high = true;
   }
};

//+------------------------------------------------------------------+
//| MACD Crossover Bilgi Yapısı                                     |
//+------------------------------------------------------------------+
struct MACDCrossoverInfo
{
   ENUM_MACD_SIGNAL_TYPE  crossover_type;    // Crossover türü
   ENUM_TIMEFRAMES        timeframe;         // Zaman çerçevesi
   bool                   active;            // Aktif crossover var mı?
   
   // Crossover detayları
   datetime               cross_time;        // Kesişim zamanı
   double                 cross_price;       // Kesişim fiyatı
   double                 macd_value;        // MACD değeri
   double                 signal_value;      // Signal line değeri
   double                 histogram_value;   // Histogram değeri
   
   // Güç metrikleri
   double                 strength;          // Crossover gücü (0-100)
   double                 momentum;          // Momentum gücü
   double                 velocity;          // Hız (-100 to +100)
   int                    confirmation_bars; // Onay bar sayısı
   bool                   confirmed;         // Onaylanmış mı?
   
   // Tahmin metrikleri
   double                 success_probability; // Başarı olasılığı
   double                 target_projection;   // Hedef projeksiyon
   int                    expected_duration;   // Beklenen süre (bar)
   double                 risk_reward_ratio;   // Risk/Ödül oranı
   
   // Constructor
   MACDCrossoverInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      crossover_type = MACD_SIGNAL_NONE;
      timeframe = PERIOD_CURRENT;
      active = false;
      
      cross_time = 0;
      cross_price = 0.0;
      macd_value = 0.0;
      signal_value = 0.0;
      histogram_value = 0.0;
      
      strength = 0.0;
      momentum = 0.0;
      velocity = 0.0;
      confirmation_bars = 0;
      confirmed = false;
      
      success_probability = 0.0;
      target_projection = 0.0;
      expected_duration = 0;
      risk_reward_ratio = 0.0;
   }
   
   bool IsValid() const
   {
      return (active && crossover_type != MACD_SIGNAL_NONE && cross_time > 0);
   }
   
   string ToString() const
   {
      return StringFormat("%s | TF: %d | Strength: %.1f%% | Probability: %.1f%%",
                         MACDSignalTypeToString(crossover_type), timeframe, 
                         strength, success_probability);
   }
};

//+------------------------------------------------------------------+
//| MACD Divergence Bilgi Yapısı                                    |
//+------------------------------------------------------------------+
struct MACDDivergenceInfo
{
   ENUM_DIVERGENCE_TYPE   divergence_type;   // Divergence türü
   ENUM_TIMEFRAMES        timeframe;         // Zaman çerçevesi
   bool                   active;            // Aktif divergence var mı?
   
   // Divergence detayları
   datetime               start_time;        // Başlangıç zamanı
   datetime               end_time;          // Bitiş zamanı
   double                 start_price;       // Başlangıç fiyatı
   double                 end_price;         // Bitiş fiyatı
   double                 start_macd;        // Başlangıç MACD
   double                 end_macd;          // Bitiş MACD
   double                 start_histogram;   // Başlangıç histogram
   double                 end_histogram;     // Bitiş histogram
   
   // Güç metrikleri
   double                 strength;          // Divergence gücü (0-100)
   double                 reliability;       // Güvenilirlik (0-100)
   double                 macd_divergence_angle; // MACD divergence açısı
   double                 price_divergence_angle; // Fiyat divergence açısı
   int                    confirmation_bars; // Onay bar sayısı
   bool                   confirmed;         // Onaylanmış mı?
   
   // Histogram analizi
   bool                   histogram_supports; // Histogram destekliyor mu?
   double                 histogram_strength; // Histogram gücü
   ENUM_MACD_MOMENTUM_PHASE momentum_phase;  // Momentum fazı
   
   // Tahmin metrikleri
   double                 reversal_probability; // Dönüş olasılığı
   double                 target_projection;    // Hedef projeksiyon
   int                    expected_duration;    // Beklenen süre (bar)
   double                 fibonacci_target;     // Fibonacci hedefi
   
   // Constructor
   MACDDivergenceInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      divergence_type = DIVERGENCE_NONE;
      timeframe = PERIOD_CURRENT;
      active = false;
      
      start_time = 0;
      end_time = 0;
      start_price = 0.0;
      end_price = 0.0;
      start_macd = 0.0;
      end_macd = 0.0;
      start_histogram = 0.0;
      end_histogram = 0.0;
      
      strength = 0.0;
      reliability = 0.0;
      macd_divergence_angle = 0.0;
      price_divergence_angle = 0.0;
      confirmation_bars = 0;
      confirmed = false;
      
      histogram_supports = false;
      histogram_strength = 0.0;
      momentum_phase = MACD_MOMENTUM_UNKNOWN;
      
      reversal_probability = 0.0;
      target_projection = 0.0;
      expected_duration = 0;
      fibonacci_target = 0.0;
   }
   
   bool IsValid() const
   {
      return (active && divergence_type != DIVERGENCE_NONE && 
             start_time > 0 && end_time > start_time);
   }
   
   string ToString() const
   {
      return StringFormat("%s Divergence | TF: %d | Strength: %.1f%% | Histogram: %s | Probability: %.1f%%",
                         DivergenceTypeToString(divergence_type), timeframe, 
                         strength, (histogram_supports ? "YES" : "NO"), reversal_probability);
   }
};

//+------------------------------------------------------------------+
//| MACD Momentum Analiz Bilgi Yapısı                              |
//+------------------------------------------------------------------+
struct MACDMomentumInfo
{
   // Temel MACD verileri
   datetime               calculation_time;  // Hesaplama zamanı
   string                 symbol;            // Sembol
   
   // Multi-timeframe MACD değerleri
   double                 macd_m15;          // M15 MACD
   double                 macd_h1;           // H1 MACD
   double                 macd_h4;           // H4 MACD
   double                 macd_d1;           // D1 MACD
   double                 macd_w1;           // W1 MACD
   
   // Signal line değerleri
   double                 signal_m15;        // M15 Signal
   double                 signal_h1;         // H1 Signal
   double                 signal_h4;         // H4 Signal
   double                 signal_d1;         // D1 Signal
   double                 signal_w1;         // W1 Signal
   
   // Histogram değerleri
   double                 histogram_m15;     // M15 Histogram
   double                 histogram_h1;      // H1 Histogram
   double                 histogram_h4;      // H4 Histogram
   double                 histogram_d1;      // D1 Histogram
   double                 histogram_w1;      // W1 Histogram
   
   // MACD koşulları
   ENUM_MACD_CONDITION    condition_m15;    // M15 MACD durumu
   ENUM_MACD_CONDITION    condition_h1;     // H1 MACD durumu
   ENUM_MACD_CONDITION    condition_h4;     // H4 MACD durumu
   ENUM_MACD_CONDITION    condition_d1;     // D1 MACD durumu
   
   // Momentum fazları
   ENUM_MACD_MOMENTUM_PHASE phase_short;    // Kısa vadeli faz
   ENUM_MACD_MOMENTUM_PHASE phase_medium;   // Orta vadeli faz
   ENUM_MACD_MOMENTUM_PHASE phase_long;     // Uzun vadeli faz
   ENUM_MACD_MOMENTUM_PHASE overall_phase;  // Genel faz
   
   // Crossover bilgileri
   MACDCrossoverInfo      crossovers[10];   // Maksimum 10 aktif crossover
   int                    active_crossover_count; // Aktif crossover sayısı
   bool                   has_signal_line_cross; // Signal line kesişimi var mı?
   bool                   has_zero_line_cross;   // Zero line kesişimi var mı?
   bool                   has_histogram_reversal; // Histogram dönüşü var mı?
   
   // Divergence bilgileri
   MACDDivergenceInfo     divergences[5];   // Maksimum 5 aktif divergence
   int                    active_divergence_count; // Aktif divergence sayısı
   bool                   has_bullish_divergence;  // Boğa divergence var mı?
   bool                   has_bearish_divergence;  // Ayı divergence var mı?
   bool                   has_hidden_divergence;   // Gizli divergence var mı?
   bool                   has_macd_histogram_div;  // MACD-Histogram divergence
   
   // Advanced momentum metrics
   double                 momentum_strength;    // Momentum gücü (0-100)
   double                 momentum_velocity;    // Momentum hızı (-100 to +100)
   double                 momentum_acceleration; // Momentum ivmesi
   double                 momentum_persistence; // Momentum kalıcılığı
   double                 histogram_momentum;   // Histogram momentum
   double                 signal_strength;     // Sinyal gücü
   
   // Confluence analizi
   int                    timeframe_alignment; // Zaman çerçevesi uyumu (0-5)
   double                 confluence_score;    // Confluence skoru (0-100)
   ENUM_CONFLUENCE_LEVEL  confluence_level;    // Confluence seviyesi
   double                 cross_confluence;    // Crossover confluence
   double                 divergence_confluence; // Divergence confluence
   
   // Zero line analysis
   bool                   above_zero_line;     // Zero line üstünde mi?
   int                    zero_line_duration;  // Zero line durumu süresi
   double                 zero_line_distance;  // Zero line'dan uzaklık
   bool                   approaching_zero;    // Zero line'a yaklaşıyor mu?
   
   // Signal generation
   ENUM_SIGNAL_TYPE       primary_signal;     // Ana sinyal
   ENUM_SIGNAL_STRENGTH   signal_strength_enum; // Sinyal gücü enum
   double                 signal_confidence;  // Sinyal güveni (0-100)
   double                 entry_probability;  // Giriş olasılığı
   ENUM_MACD_SIGNAL_TYPE  macd_signal_type;   // MACD sinyal türü
   
   // ML features
   double                 ml_momentum_score;   // ML momentum skoru
   double                 ml_reversal_prob;    // ML dönüş olasılığı
   double                 ml_continuation_prob; // ML devam olasılığı
   double                 pattern_recognition_score; // Pattern tanıma skoru
   double                 histogram_pattern_score;   // Histogram pattern skoru
   
   // Risk assessment
   ENUM_RISK_LEVEL        risk_level;         // Risk seviyesi
   double                 volatility_factor;  // Volatilite faktörü
   bool                   counter_trend_risk; // Karşı trend riski
   bool                   divergence_risk;    // Divergence riski
   double                 false_signal_prob;  // Yanlış sinyal olasılığı
   
   // Advanced analytics
   double                 trend_strength;      // Trend gücü
   double                 trend_sustainability; // Trend sürdürülebilirliği
   double                 reversal_potential;  // Dönüş potansiyeli
   int                    signal_maturity;     // Sinyal olgunluğu (bar)
   
   // Constructor
   MACDMomentumInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      calculation_time = 0;
      symbol = "";
      
      macd_m15 = macd_h1 = macd_h4 = macd_d1 = macd_w1 = 0.0;
      signal_m15 = signal_h1 = signal_h4 = signal_d1 = signal_w1 = 0.0;
      histogram_m15 = histogram_h1 = histogram_h4 = histogram_d1 = histogram_w1 = 0.0;
      
      condition_m15 = condition_h1 = condition_h4 = condition_d1 = MACD_NEUTRAL;
      
      phase_short = phase_medium = phase_long = overall_phase = MACD_MOMENTUM_UNKNOWN;
      
      for(int i = 0; i < 10; i++)
         crossovers[i].Reset();
      active_crossover_count = 0;
      has_signal_line_cross = false;
      has_zero_line_cross = false;
      has_histogram_reversal = false;
      
      for(int i = 0; i < 5; i++)
         divergences[i].Reset();
      active_divergence_count = 0;
      has_bullish_divergence = false;
      has_bearish_divergence = false;
      has_hidden_divergence = false;
      has_macd_histogram_div = false;
      
      momentum_strength = 50.0;
      momentum_velocity = 0.0;
      momentum_acceleration = 0.0;
      momentum_persistence = 50.0;
      histogram_momentum = 0.0;
      signal_strength = 0.0;
      
      timeframe_alignment = 0;
      confluence_score = 0.0;
      confluence_level = CONFLUENCE_NONE;
      cross_confluence = 0.0;
      divergence_confluence = 0.0;
      
      above_zero_line = true;
      zero_line_duration = 0;
      zero_line_distance = 0.0;
      approaching_zero = false;
      
      primary_signal = SIGNAL_NONE;
      signal_strength_enum = SIGNAL_STRENGTH_NONE;
      signal_confidence = 0.0;
      entry_probability = 0.0;
      macd_signal_type = MACD_SIGNAL_NONE;
      
      ml_momentum_score = 50.0;
      ml_reversal_prob = 0.0;
      ml_continuation_prob = 0.0;
      pattern_recognition_score = 0.0;
      histogram_pattern_score = 0.0;
      
      risk_level = RISK_MEDIUM;
      volatility_factor = 1.0;
      counter_trend_risk = false;
      divergence_risk = false;
      false_signal_prob = 0.0;
      
      trend_strength = 0.0;
      trend_sustainability = 50.0;
      reversal_potential = 0.0;
      signal_maturity = 0;
   }
   
   bool IsValid() const
   {
      return (calculation_time > 0 && StringLen(symbol) > 0);
   }
   
   string ToString() const
   {
      return StringFormat("MACD H1: %.4f | Signal: %.4f | Histogram: %.4f | Phase: %s | Confluence: %.1f%% | Signal: %s",
                         macd_h1, signal_h1, histogram_h1, 
                         MACDMomentumPhaseToString(overall_phase),
                         confluence_score, SignalTypeToString(primary_signal));
   }
};

// Helper Functions artık Complete_Enum_Types.mqh'de tanımlı
// Bu fonksiyonlar Complete_Enum_Types.mqh'den kullanılacak

//+------------------------------------------------------------------+
//| MACD Divergence Analiz Motoru                                   |
//+------------------------------------------------------------------+
class MACDDivergenceEngine
{
private:
   // Engine parametreleri
   string                  m_symbol;          // Analiz sembolü
   int                     m_fast_ema;        // Hızlı EMA periyodu
   int                     m_slow_ema;        // Yavaş EMA periyodu
   int                     m_signal_sma;      // Signal SMA periyodu
   ENUM_APPLIED_PRICE      m_applied_price;   // Uygulanan fiyat
   bool                    m_initialized;     // Başlatılma durumu
   
   // Divergence detection settings
   int                     m_divergence_lookback; // Divergence arama periyodu
   double                  m_min_divergence_strength; // Minimum divergence gücü
   int                     m_min_bars_between_peaks; // Peak'lar arası min bar
   double                  m_histogram_threshold; // Histogram eşiği
   
   // Crossover detection settings
   int                     m_crossover_confirmation; // Crossover onay bar sayısı
   double                  m_min_crossover_strength; // Minimum crossover gücü
   bool                    m_require_histogram_support; // Histogram desteği gerekli mi?
   
   // Historical data caching
   double                  m_macd_history[5][200];    // 5 timeframe, 200 bar MACD
   double                  m_signal_history[5][200];  // Signal line history
   double                  m_histogram_history[5][200]; // Histogram history
   double                  m_price_history[5][200];   // Price history for divergence
   datetime                m_time_history[5][200];    // Time history
   int                     m_history_size[5];         // Her TF için history boyutu
   
   // ML components
   double                  m_ml_features[30];         // ML feature vector
   double                  m_ml_weights[30];          // ML weights
   bool                    m_ml_trained;              // ML model trained?
   
   // Performance tracking
   int                     m_total_calculations;      // Toplam hesaplama
   int                     m_successful_signals;      // Başarılı sinyal
   double                  m_accuracy_rate;           // Doğruluk oranı
   datetime                m_last_calculation;        // Son hesaplama zamanı
   
   // Timeframe mapping
   ENUM_TIMEFRAMES         m_timeframes[5];           // Analiz edilen timeframe'ler
   int                     m_timeframe_count;         // Timeframe sayısı

public:
   //+------------------------------------------------------------------+
   //| Constructor & Destructor                                         |
   //+------------------------------------------------------------------+
   MACDDivergenceEngine(string symbol = "", int fast_ema = 12, int slow_ema = 26, 
                        int signal_sma = 9, ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE)
   {
      m_symbol = (StringLen(symbol) > 0) ? symbol : Symbol();
      m_fast_ema = MathMax(5, MathMin(50, fast_ema));
      m_slow_ema = MathMax(10, MathMin(100, slow_ema));
      m_signal_sma = MathMax(3, MathMin(30, signal_sma));
      m_applied_price = applied_price;
      m_initialized = false;
      
      // Divergence settings
      m_divergence_lookback = 50;
      m_min_divergence_strength = 60.0;
      m_min_bars_between_peaks = 5;
      m_histogram_threshold = 0.0001;
      
      // Crossover settings
      m_crossover_confirmation = 2;
      m_min_crossover_strength = 50.0;
      m_require_histogram_support = true;
      
      // Initialize timeframes
      m_timeframes[0] = PERIOD_M15;
      m_timeframes[1] = PERIOD_H1;
      m_timeframes[2] = PERIOD_H4;
      m_timeframes[3] = PERIOD_D1;
      m_timeframes[4] = PERIOD_W1;
      m_timeframe_count = 5;
      
      // Initialize arrays - MQL5 uyumlu
      for(int tf = 0; tf < 5; tf++)
      {
         for(int i = 0; i < 200; i++)
         {
            m_macd_history[tf][i] = 0.0;
            m_signal_history[tf][i] = 0.0;
            m_histogram_history[tf][i] = 0.0;
            m_price_history[tf][i] = 0.0;
            m_time_history[tf][i] = 0;
         }
         m_history_size[tf] = 0;
      }
      
      for(int i = 0; i < 30; i++)
      {
         m_ml_features[i] = 0.0;
         m_ml_weights[i] = 1.0;
      }
      m_ml_trained = false;
      
      m_total_calculations = 0;
      m_successful_signals = 0;
      m_accuracy_rate = 0.0;
      m_last_calculation = 0;
      
      if(!Initialize())
      {
         Print("ERROR: MACDDivergenceEngine initialization failed");
         return;
      }
      
      Print(StringFormat("MACDDivergenceEngine initialized: %s, MACD(%d,%d,%d)", 
                        m_symbol, m_fast_ema, m_slow_ema, m_signal_sma));
   }
   
   ~MACDDivergenceEngine()
   {
      if(m_total_calculations > 0)
      {
         Print(StringFormat("MACDDivergenceEngine destroyed. Accuracy: %.2f%% (%d/%d)",
                           m_accuracy_rate, m_successful_signals, m_total_calculations));
      }
   }

private:
   //+------------------------------------------------------------------+
   //| Initialization                                                   |
   //+------------------------------------------------------------------+
   bool Initialize()
   {
      ResetLastError();
      
      // Symbol validation
      if(!SymbolSelect(m_symbol, true))
      {
         Print(StringFormat("ERROR: Cannot select symbol: %s", m_symbol));
         return false;
      }
      
      // MACD parameters validation
      if(m_fast_ema >= m_slow_ema)
      {
         Print("ERROR: Fast EMA must be less than Slow EMA");
         return false;
      }
      
      // Load historical MACD data
      if(!LoadHistoricalMACDData())
      {
         Print("WARNING: Could not load complete historical MACD data");
         // Not critical, continue with available data
      }
      
      // Initialize ML model
      InitializeMLModel();
      
      m_initialized = true;
      return true;
   }
   
   bool LoadHistoricalMACDData()
   {
      bool all_success = true;
      
      for(int tf = 0; tf < m_timeframe_count; tf++)
      {
         ENUM_TIMEFRAMES timeframe = m_timeframes[tf];
         
         // Load MACD data
         double macd_buffer[], signal_buffer[], histogram_buffer[];
         ArraySetAsSeries(macd_buffer, true);
         ArraySetAsSeries(signal_buffer, true);
         ArraySetAsSeries(histogram_buffer, true);
         
         int macd_handle = iMACD(m_symbol, timeframe, m_fast_ema, m_slow_ema, m_signal_sma, m_applied_price);
         if(macd_handle == INVALID_HANDLE)
         {
            Print(StringFormat("ERROR: Cannot create MACD handle for TF: %d", timeframe));
            all_success = false;
            continue;
         }
         
         int copied_main = CopyBuffer(macd_handle, 0, 0, 200, macd_buffer);
         int copied_signal = CopyBuffer(macd_handle, 1, 0, 200, signal_buffer);
         
         if(copied_main <= 0 || copied_signal <= 0)
         {
            Print(StringFormat("WARNING: No MACD data copied for TF: %d", timeframe));
            all_success = false;
            continue;
         }
         
         // Calculate histogram
         int copied = MathMin(copied_main, copied_signal);
         ArrayResize(histogram_buffer, copied);
         for(int i = 0; i < copied; i++)
         {
            histogram_buffer[i] = macd_buffer[i] - signal_buffer[i];
         }
         
         // Load price data for divergence analysis
         MqlRates rates[];
         ArraySetAsSeries(rates, true);
         
         int price_copied = CopyRates(m_symbol, timeframe, 0, copied, rates);
         if(price_copied != copied)
         {
            Print(StringFormat("WARNING: Price data mismatch for TF: %d", timeframe));
            all_success = false;
            continue;
         }
         
         // Store in internal arrays
         int store_count = MathMin(copied, 200);
         for(int i = 0; i < store_count; i++)
         {
            m_macd_history[tf][i] = macd_buffer[i];
            m_signal_history[tf][i] = signal_buffer[i];
            m_histogram_history[tf][i] = histogram_buffer[i];
            m_price_history[tf][i] = rates[i].close;
            m_time_history[tf][i] = rates[i].time;
         }
         m_history_size[tf] = store_count;
         
         IndicatorRelease(macd_handle);
      }
      
      Print(StringFormat("MACD historical data loaded for %d timeframes", m_timeframe_count));
      return all_success;
   }
   
   void InitializeMLModel()
   {
      // Initialize basic ML weights (placeholder for real ML implementation)
      for(int i = 0; i < 30; i++)
      {
         m_ml_weights[i] = (MathRand() / 32767.0) * 2.0 - 1.0; // Random weights -1 to +1
      }
      
      // In real implementation, load pre-trained weights or train the model
      m_ml_trained = false; // Set to true when real model is loaded
   }

public:
   //+------------------------------------------------------------------+
   //| Ana Analiz Metodları                                            |
   //+------------------------------------------------------------------+
   MACDMomentumInfo AnalyzeMomentum()
   {
      MACDMomentumInfo info;
      
      if(!m_initialized)
      {
         Print("ERROR: Engine not initialized");
         return info;
      }
      
      m_total_calculations++;
      info.calculation_time = TimeCurrent();
      info.symbol = m_symbol;
      
      // Get current MACD values for all timeframes
      if(!GetCurrentMACDValues(info))
      {
         Print("ERROR: Failed to get current MACD values");
         return info;
      }
      
      // Analyze MACD conditions
      AnalyzeMACDConditions(info);
      
      // Analyze momentum phases
      AnalyzeMomentumPhases(info);
      
      // Detect crossovers
      DetectCrossovers(info);
      
      // Detect divergences
      DetectDivergences(info);
      
      // Analyze zero line
      AnalyzeZeroLine(info);
      
      // Calculate confluence
      CalculateConfluence(info);
      
      // Analyze advanced momentum
      AnalyzeAdvancedMomentum(info);
      
      // Generate signals
      GenerateSignals(info);
      
      // Extract ML features
      ExtractMLFeatures(info);
      
      // Calculate ML predictions
      if(m_ml_trained)
         CalculateMLPredictions(info);
      
      // Assess risk
      AssessRisk(info);
      
      m_last_calculation = TimeCurrent();
      
      return info;
   }

private:
   bool GetCurrentMACDValues(MACDMomentumInfo &info)
   {
      bool all_success = true;
      
      // M15 values
      double macd_buffer[1], signal_buffer[1];
      int macd_handle = iMACD(m_symbol, PERIOD_M15, m_fast_ema, m_slow_ema, m_signal_sma, m_applied_price);
      
      if(macd_handle != INVALID_HANDLE)
      {
         int copied_main = CopyBuffer(macd_handle, 0, 0, 1, macd_buffer);
         int copied_signal = CopyBuffer(macd_handle, 1, 0, 1, signal_buffer);
         
         if(copied_main == 1 && copied_signal == 1)
         {
            info.macd_m15 = macd_buffer[0];
            info.signal_m15 = signal_buffer[0];
            info.histogram_m15 = macd_buffer[0] - signal_buffer[0];
         }
         else
         {
            info.macd_m15 = 0.0;
            info.signal_m15 = 0.0;
            info.histogram_m15 = 0.0;
            all_success = false;
         }
         IndicatorRelease(macd_handle);
      }
      else
      {
         all_success = false;
      }
      
      // H1 values
      macd_handle = iMACD(m_symbol, PERIOD_H1, m_fast_ema, m_slow_ema, m_signal_sma, m_applied_price);
      
      if(macd_handle != INVALID_HANDLE)
      {
         int copied_main = CopyBuffer(macd_handle, 0, 0, 1, macd_buffer);
         int copied_signal = CopyBuffer(macd_handle, 1, 0, 1, signal_buffer);
         
         if(copied_main == 1 && copied_signal == 1)
         {
            info.macd_h1 = macd_buffer[0];
            info.signal_h1 = signal_buffer[0];
            info.histogram_h1 = macd_buffer[0] - signal_buffer[0];
         }
         else
         {
            info.macd_h1 = 0.0;
            info.signal_h1 = 0.0;
            info.histogram_h1 = 0.0;
            all_success = false;
         }
         IndicatorRelease(macd_handle);
      }
      else
      {
         all_success = false;
      }
      
      // H4 values
      macd_handle = iMACD(m_symbol, PERIOD_H4, m_fast_ema, m_slow_ema, m_signal_sma, m_applied_price);
      
      if(macd_handle != INVALID_HANDLE)
      {
         int copied_main = CopyBuffer(macd_handle, 0, 0, 1, macd_buffer);
         int copied_signal = CopyBuffer(macd_handle, 1, 0, 1, signal_buffer);
         
         if(copied_main == 1 && copied_signal == 1)
         {
            info.macd_h4 = macd_buffer[0];
            info.signal_h4 = signal_buffer[0];
            info.histogram_h4 = macd_buffer[0] - signal_buffer[0];
         }
         else
         {
            info.macd_h4 = 0.0;
            info.signal_h4 = 0.0;
            info.histogram_h4 = 0.0;
            all_success = false;
         }
         IndicatorRelease(macd_handle);
      }
      else
      {
         all_success = false;
      }
      
      // D1 values
      macd_handle = iMACD(m_symbol, PERIOD_D1, m_fast_ema, m_slow_ema, m_signal_sma, m_applied_price);
      
      if(macd_handle != INVALID_HANDLE)
      {
         int copied_main = CopyBuffer(macd_handle, 0, 0, 1, macd_buffer);
         int copied_signal = CopyBuffer(macd_handle, 1, 0, 1, signal_buffer);
         
         if(copied_main == 1 && copied_signal == 1)
         {
            info.macd_d1 = macd_buffer[0];
            info.signal_d1 = signal_buffer[0];
            info.histogram_d1 = macd_buffer[0] - signal_buffer[0];
         }
         else
         {
            info.macd_d1 = 0.0;
            info.signal_d1 = 0.0;
            info.histogram_d1 = 0.0;
            all_success = false;
         }
         IndicatorRelease(macd_handle);
      }
      else
      {
         all_success = false;
      }
      
      // W1 values
      macd_handle = iMACD(m_symbol, PERIOD_W1, m_fast_ema, m_slow_ema, m_signal_sma, m_applied_price);
      
      if(macd_handle != INVALID_HANDLE)
      {
         int copied_main = CopyBuffer(macd_handle, 0, 0, 1, macd_buffer);
         int copied_signal = CopyBuffer(macd_handle, 1, 0, 1, signal_buffer);
         
         if(copied_main == 1 && copied_signal == 1)
         {
            info.macd_w1 = macd_buffer[0];
            info.signal_w1 = signal_buffer[0];
            info.histogram_w1 = macd_buffer[0] - signal_buffer[0];
         }
         else
         {
            info.macd_w1 = 0.0;
            info.signal_w1 = 0.0;
            info.histogram_w1 = 0.0;
            all_success = false;
         }
         IndicatorRelease(macd_handle);
      }
      else
      {
         all_success = false;
      }
      
      return all_success;
   }
   
   void AnalyzeMACDConditions(MACDMomentumInfo &info)
   {
      // Analyze each timeframe condition
      info.condition_m15 = ClassifyMACDCondition(info.macd_m15, info.signal_m15, info.histogram_m15);
      info.condition_h1 = ClassifyMACDCondition(info.macd_h1, info.signal_h1, info.histogram_h1);
      info.condition_h4 = ClassifyMACDCondition(info.macd_h4, info.signal_h4, info.histogram_h4);
      info.condition_d1 = ClassifyMACDCondition(info.macd_d1, info.signal_d1, info.histogram_d1);
   }
   
   ENUM_MACD_CONDITION ClassifyMACDCondition(double macd_value, double signal_value, double histogram_value)
   {
      bool macd_above_signal = (macd_value > signal_value);
      bool macd_above_zero = (macd_value > 0);
      bool histogram_positive = (histogram_value > 0);
      bool histogram_increasing = true; // Would need historical data to determine
      
      // Strong bullish: MACD > Signal, MACD > 0, Histogram increasing
      if(macd_above_signal && macd_above_zero && histogram_positive)
      {
         if(MathAbs(histogram_value) > m_histogram_threshold * 2)
            return MACD_BULLISH_STRONG;
         else
            return MACD_BULLISH_MODERATE;
      }
      
      // Weak bullish: MACD > Signal but conditions not all met
      if(macd_above_signal)
         return MACD_BULLISH_WEAK;
      
      // Strong bearish: MACD < Signal, MACD < 0, Histogram decreasing
      if(!macd_above_signal && !macd_above_zero && !histogram_positive)
      {
         if(MathAbs(histogram_value) > m_histogram_threshold * 2)
            return MACD_BEARISH_STRONG;
         else
            return MACD_BEARISH_MODERATE;
      }
      
      // Weak bearish: MACD < Signal but conditions not all met
      if(!macd_above_signal)
         return MACD_BEARISH_WEAK;
      
      return MACD_NEUTRAL;
   }
   
   void AnalyzeMomentumPhases(MACDMomentumInfo &info)
   {
      // Analyze momentum phases based on MACD and histogram trends
      info.phase_short = CalculateMomentumPhase(info.macd_m15, info.histogram_m15, 0); // M15
      info.phase_medium = CalculateMomentumPhase(info.macd_h1, info.histogram_h1, 1);  // H1
      info.phase_long = CalculateMomentumPhase(info.macd_h4, info.histogram_h4, 2);    // H4
      
      // Overall phase (weighted combination)
      info.overall_phase = CalculateOverallPhase(info);
   }
   
   ENUM_MACD_MOMENTUM_PHASE CalculateMomentumPhase(double current_macd, double current_histogram, int tf_index)
   {
      if(tf_index < 0 || tf_index >= m_timeframe_count || m_history_size[tf_index] < 5)
         return MACD_MOMENTUM_UNKNOWN;
      
      // Get historical values
      double prev_macd = m_macd_history[tf_index][1];
      double prev_histogram = m_histogram_history[tf_index][1];
      double prev2_histogram = m_histogram_history[tf_index][2];
      
      // Calculate trends
      bool macd_rising = (current_macd > prev_macd);
      bool histogram_rising = (current_histogram > prev_histogram);
      bool histogram_acceleration = (current_histogram - prev_histogram) > (prev_histogram - prev2_histogram);
      
      // Determine phase
      if(current_histogram > 0) // Positive momentum
      {
         if(histogram_rising && histogram_acceleration)
            return MACD_ACCELERATION_UP;
         else if(histogram_rising && !histogram_acceleration)
            return MACD_DECELERATION_UP;
         else if(!histogram_rising)
            return MACD_MOMENTUM_REVERSAL;
      }
      else // Negative momentum
      {
         if(!histogram_rising && !histogram_acceleration)
            return MACD_ACCELERATION_DOWN;
         else if(!histogram_rising && histogram_acceleration)
            return MACD_DECELERATION_DOWN;
         else if(histogram_rising)
            return MACD_MOMENTUM_REVERSAL;
      }
      
      // Check for exhaustion
      if(MathAbs(current_histogram) > m_histogram_threshold * 5)
         return MACD_MOMENTUM_EXHAUSTION;
      
      return MACD_MOMENTUM_UNKNOWN;
   }
   
   ENUM_MACD_MOMENTUM_PHASE CalculateOverallPhase(const MACDMomentumInfo &info)
   {
      // Weight different timeframe phases
      double phase_score = 0.0;
      
      phase_score += MomentumPhaseToScore(info.phase_short) * 0.2;   // 20% weight for short term
      phase_score += MomentumPhaseToScore(info.phase_medium) * 0.5;  // 50% weight for medium term
      phase_score += MomentumPhaseToScore(info.phase_long) * 0.3;    // 30% weight for long term
      
      return ScoreToMomentumPhase(phase_score);
   }
   
   double MomentumPhaseToScore(ENUM_MACD_MOMENTUM_PHASE phase)
   {
      switch(phase)
      {
         case MACD_ACCELERATION_UP: return 2.0;
         case MACD_DECELERATION_UP: return 1.0;
         case MACD_MOMENTUM_REVERSAL: return 0.0;
         case MACD_DECELERATION_DOWN: return -1.0;
         case MACD_ACCELERATION_DOWN: return -2.0;
         case MACD_MOMENTUM_EXHAUSTION: return 0.0;
         default: return 0.0;
      }
   }
   
   ENUM_MACD_MOMENTUM_PHASE ScoreToMomentumPhase(double score)
   {
      if(score >= 1.5) return MACD_ACCELERATION_UP;
      else if(score >= 0.5) return MACD_DECELERATION_UP;
      else if(score <= -1.5) return MACD_ACCELERATION_DOWN;
      else if(score <= -0.5) return MACD_DECELERATION_DOWN;
      else if(MathAbs(score) < 0.1) return MACD_MOMENTUM_REVERSAL;
      else return MACD_MOMENTUM_UNKNOWN;
   }
   
   void DetectCrossovers(MACDMomentumInfo &info)
   {
      info.active_crossover_count = 0;
      info.has_signal_line_cross = false;
      info.has_zero_line_cross = false;
      info.has_histogram_reversal = false;
      
      // Detect crossovers for each major timeframe
      for(int tf = 1; tf < 4; tf++) // H1, H4, D1
      {
         MACDCrossoverInfo cross_info = DetectCrossoverForTimeframe(tf);
         
         if(cross_info.IsValid() && info.active_crossover_count < 10)
         {
            info.crossovers[info.active_crossover_count] = cross_info;
            info.active_crossover_count++;
            
            // Update flags
            if(cross_info.crossover_type == MACD_SIGNAL_LINE_CROSS_UP || 
               cross_info.crossover_type == MACD_SIGNAL_LINE_CROSS_DOWN)
               info.has_signal_line_cross = true;
            
            if(cross_info.crossover_type == MACD_ZERO_LINE_CROSS_UP || 
               cross_info.crossover_type == MACD_ZERO_LINE_CROSS_DOWN)
               info.has_zero_line_cross = true;
            
            if(cross_info.crossover_type == MACD_HISTOGRAM_REVERSAL_UP || 
               cross_info.crossover_type == MACD_HISTOGRAM_REVERSAL_DOWN)
               info.has_histogram_reversal = true;
         }
      }
   }
   
   MACDCrossoverInfo DetectCrossoverForTimeframe(int tf_index)
   {
      MACDCrossoverInfo cross_info;
      
      if(tf_index < 0 || tf_index >= m_timeframe_count || m_history_size[tf_index] < 5)
         return cross_info;
      
      ENUM_TIMEFRAMES timeframe = m_timeframes[tf_index];
      
      // Current and previous values
      double current_macd = m_macd_history[tf_index][0];
      double current_signal = m_signal_history[tf_index][0];
      double current_histogram = m_histogram_history[tf_index][0];
      double current_price = m_price_history[tf_index][0];
      
      double prev_macd = m_macd_history[tf_index][1];
      double prev_signal = m_signal_history[tf_index][1];
      double prev_histogram = m_histogram_history[tf_index][1];
      
      // Detect signal line crossovers
      if((current_macd > current_signal) && (prev_macd <= prev_signal))
      {
         cross_info.crossover_type = MACD_SIGNAL_LINE_CROSS_UP;
         cross_info.active = true;
      }
      else if((current_macd < current_signal) && (prev_macd >= prev_signal))
      {
         cross_info.crossover_type = MACD_SIGNAL_LINE_CROSS_DOWN;
         cross_info.active = true;
      }
      // Detect zero line crossovers
      else if((current_macd > 0) && (prev_macd <= 0))
      {
         cross_info.crossover_type = MACD_ZERO_LINE_CROSS_UP;
         cross_info.active = true;
      }
      else if((current_macd < 0) && (prev_macd >= 0))
      {
         cross_info.crossover_type = MACD_ZERO_LINE_CROSS_DOWN;
         cross_info.active = true;
      }
      // Detect histogram reversals
      else if((current_histogram > 0) && (prev_histogram <= 0))
      {
         cross_info.crossover_type = MACD_HISTOGRAM_REVERSAL_UP;
         cross_info.active = true;
      }
      else if((current_histogram < 0) && (prev_histogram >= 0))
      {
         cross_info.crossover_type = MACD_HISTOGRAM_REVERSAL_DOWN;
         cross_info.active = true;
      }
      
      if(cross_info.active)
      {
         cross_info.timeframe = timeframe;
         cross_info.cross_time = m_time_history[tf_index][0];
         cross_info.cross_price = current_price;
         cross_info.macd_value = current_macd;
         cross_info.signal_value = current_signal;
         cross_info.histogram_value = current_histogram;
         
         // Calculate crossover metrics
         cross_info.strength = CalculateCrossoverStrength(cross_info, tf_index);
         cross_info.momentum = CalculateCrossoverMomentum(cross_info, tf_index);
         cross_info.velocity = CalculateCrossoverVelocity(cross_info, tf_index);
         
         // Calculate probabilities
         cross_info.success_probability = CalculateCrossoverProbability(cross_info);
         cross_info.target_projection = CalculateCrossoverTarget(cross_info);
         cross_info.risk_reward_ratio = CalculateCrossoverRiskReward(cross_info);
         
         // Confirmation analysis
         cross_info.confirmation_bars = 0; // Would need real-time tracking
         cross_info.confirmed = (cross_info.strength >= m_min_crossover_strength);
      }
      
      return cross_info;
   }
   
   double CalculateCrossoverStrength(const MACDCrossoverInfo &cross_info, int tf_index)
   {
      double strength = 50.0; // Base strength
      
      // Distance between MACD and Signal
      double macd_signal_distance = MathAbs(cross_info.macd_value - cross_info.signal_value);
      strength += macd_signal_distance * 1000.0; // Scale appropriately
      
      // Histogram magnitude
      double histogram_magnitude = MathAbs(cross_info.histogram_value);
      if(histogram_magnitude > m_histogram_threshold)
         strength += 20.0;
      
      // Volume support (if available) - placeholder
      // Would check if volume confirms the crossover
      
      // Trend alignment
      if(tf_index >= 1 && m_history_size[tf_index] >= 10)
      {
         double trend_strength = CalculateTrendAlignment(tf_index);
         strength += trend_strength * 0.3;
      }
      
      return MathMax(0.0, MathMin(100.0, strength));
   }
   
   double CalculateCrossoverMomentum(const MACDCrossoverInfo &cross_info, int tf_index)
   {
      if(tf_index < 0 || m_history_size[tf_index] < 5)
         return 50.0;
      
      // Calculate rate of change in MACD
      double current_macd = cross_info.macd_value;
      double prev_macd = m_macd_history[tf_index][2]; // 2 bars ago
      
      double momentum = (current_macd - prev_macd) * 1000.0; // Scale appropriately
      
      return MathMax(0.0, MathMin(100.0, 50.0 + momentum));
   }
   
   double CalculateCrossoverVelocity(const MACDCrossoverInfo &cross_info, int tf_index)
   {
      if(tf_index < 0 || m_history_size[tf_index] < 3)
         return 0.0;
      
      // Calculate velocity as rate of change
      double current_diff = cross_info.macd_value - cross_info.signal_value;
      double prev_diff = m_macd_history[tf_index][1] - m_signal_history[tf_index][1];
      
      double velocity = (current_diff - prev_diff) * 1000.0; // Scale appropriately
      
      return MathMax(-100.0, MathMin(100.0, velocity));
   }
   
   double CalculateCrossoverProbability(const MACDCrossoverInfo &cross_info)
   {
      double probability = cross_info.strength * 0.6; // Base from strength
      
      // Adjust based on crossover type
      switch(cross_info.crossover_type)
      {
         case MACD_SIGNAL_LINE_CROSS_UP:
         case MACD_SIGNAL_LINE_CROSS_DOWN:
            probability *= 1.1; // Signal line crossovers slightly more reliable
            break;
         case MACD_ZERO_LINE_CROSS_UP:
         case MACD_ZERO_LINE_CROSS_DOWN:
            probability *= 1.2; // Zero line crossovers more significant
            break;
         case MACD_HISTOGRAM_REVERSAL_UP:
         case MACD_HISTOGRAM_REVERSAL_DOWN:
            probability *= 0.9; // Histogram reversals less reliable alone
            break;
      }
      
      // Momentum factor
      if(cross_info.momentum > 70.0)
         probability *= 1.15;
      
      return MathMax(0.0, MathMin(100.0, probability));
   }
   
   double CalculateCrossoverTarget(const MACDCrossoverInfo &cross_info)
   {
      // Simple target calculation based on recent price movements
      double price_range = CalculateRecentPriceRange();
      
      if(cross_info.crossover_type == MACD_SIGNAL_LINE_CROSS_UP ||
         cross_info.crossover_type == MACD_ZERO_LINE_CROSS_UP ||
         cross_info.crossover_type == MACD_HISTOGRAM_REVERSAL_UP)
      {
         return cross_info.cross_price + (price_range * 0.618); // Fibonacci ratio
      }
      else
      {
         return cross_info.cross_price - (price_range * 0.618);
      }
   }
   
   double CalculateCrossoverRiskReward(const MACDCrossoverInfo &cross_info)
   {
      double price_range = CalculateRecentPriceRange();
      double stop_distance = price_range * 0.382; // Fibonacci ratio for stop
      double target_distance = MathAbs(cross_info.target_projection - cross_info.cross_price);
      
      return (stop_distance > 0) ? (target_distance / stop_distance) : 1.0;
   }
   
   double CalculateRecentPriceRange()
   {
      if(m_history_size[1] < 20) return 0.01; // Default small range
      
      double max_price = m_price_history[1][0];
      double min_price = m_price_history[1][0];
      
      for(int i = 1; i < MathMin(20, m_history_size[1]); i++)
      {
         max_price = MathMax(max_price, m_price_history[1][i]);
         min_price = MathMin(min_price, m_price_history[1][i]);
      }
      
      return (max_price - min_price);
   }
   
   double CalculateTrendAlignment(int tf_index)
   {
      if(tf_index < 0 || m_history_size[tf_index] < 10)
         return 0.0;
      
      // Simple trend calculation based on MACD position relative to zero
      int bullish_count = 0, bearish_count = 0;
      
      for(int i = 0; i < MathMin(10, m_history_size[tf_index]); i++)
      {
         if(m_macd_history[tf_index][i] > 0)
            bullish_count++;
         else
            bearish_count++;
      }
      
      double trend_strength = MathAbs(bullish_count - bearish_count) * 10.0; // 0-100 range
      return (bullish_count > bearish_count) ? trend_strength : -trend_strength;
   }
   
   void DetectDivergences(MACDMomentumInfo &info)
   {
      info.active_divergence_count = 0;
      info.has_bullish_divergence = false;
      info.has_bearish_divergence = false;
      info.has_hidden_divergence = false;
      info.has_macd_histogram_div = false;
      
      // Detect divergences for each major timeframe
      for(int tf = 1; tf < 4; tf++) // H1, H4, D1
      {
         MACDDivergenceInfo div_info = DetectDivergenceForTimeframe(tf);
         
         if(div_info.IsValid() && info.active_divergence_count < 5)
         {
            info.divergences[info.active_divergence_count] = div_info;
            info.active_divergence_count++;
            
            // Update flags
            if(div_info.divergence_type == DIVERGENCE_REGULAR_BULLISH || 
               div_info.divergence_type == DIVERGENCE_HIDDEN_BULLISH)
               info.has_bullish_divergence = true;
            
            if(div_info.divergence_type == DIVERGENCE_REGULAR_BEARISH || 
               div_info.divergence_type == DIVERGENCE_HIDDEN_BEARISH)
               info.has_bearish_divergence = true;
            
            if(div_info.divergence_type == DIVERGENCE_HIDDEN_BULLISH || 
               div_info.divergence_type == DIVERGENCE_HIDDEN_BEARISH)
               info.has_hidden_divergence = true;
            
            if(div_info.histogram_supports)
               info.has_macd_histogram_div = true;
         }
      }
   }
   
   MACDDivergenceInfo DetectDivergenceForTimeframe(int tf_index)
   {
      MACDDivergenceInfo div_info;
      
      if(tf_index < 0 || tf_index >= m_timeframe_count || m_history_size[tf_index] < 20)
         return div_info;
      
      ENUM_TIMEFRAMES timeframe = m_timeframes[tf_index];
      int lookback = MathMin(m_divergence_lookback, m_history_size[tf_index] - 5);
      
      // Find significant peaks and troughs
      PeakInfo peaks[20];
      int peak_count = 0;
      
      // Identify peaks (both highs and lows)
      for(int i = 2; i < lookback - 2 && peak_count < 20; i++)
      {
         double price = m_price_history[tf_index][i];
         double macd = m_macd_history[tf_index][i];
         double histogram = m_histogram_history[tf_index][i];
         
         // Check for price high
         if(price > m_price_history[tf_index][i-1] && price > m_price_history[tf_index][i+1] &&
            price > m_price_history[tf_index][i-2] && price > m_price_history[tf_index][i+2])
         {
            peaks[peak_count].index = i;
            peaks[peak_count].price = price;
            peaks[peak_count].macd = macd;
            peaks[peak_count].histogram = histogram;
            peaks[peak_count].is_high = true;
            peak_count++;
         }
         // Check for price low
         else if(price < m_price_history[tf_index][i-1] && price < m_price_history[tf_index][i+1] &&
                 price < m_price_history[tf_index][i-2] && price < m_price_history[tf_index][i+2])
         {
            peaks[peak_count].index = i;
            peaks[peak_count].price = price;
            peaks[peak_count].macd = macd;
            peaks[peak_count].histogram = histogram;
            peaks[peak_count].is_high = false;
            peak_count++;
         }
      }
      
      // Analyze peaks for divergences
      for(int i = 0; i < peak_count - 1; i++)
      {
         for(int j = i + 1; j < peak_count; j++)
         {
            if(peaks[i].is_high != peaks[j].is_high) continue;
            if(MathAbs(peaks[i].index - peaks[j].index) < m_min_bars_between_peaks) continue;
            
            MACDDivergenceInfo potential_div = AnalyzePotentialDivergence(peaks[i], peaks[j], tf_index);
            
            if(potential_div.IsValid() && potential_div.strength >= m_min_divergence_strength)
            {
               potential_div.timeframe = timeframe;
               return potential_div;
            }
         }
      }
      
      return div_info;
   }
   
   MACDDivergenceInfo AnalyzePotentialDivergence(const PeakInfo &peak1, const PeakInfo &peak2, int tf_index)
   {
      MACDDivergenceInfo div_info;
      
      // Determine which peak is more recent
      bool peak1_recent = (peak1.index < peak2.index);
      const PeakInfo recent = peak1_recent ? peak1 : peak2;
      const PeakInfo older = peak1_recent ? peak2 : peak1;
      
      // Price and MACD differences
      double price_diff = recent.price - older.price;
      double macd_diff = recent.macd - older.macd;
      double histogram_diff = recent.histogram - older.histogram;
      
      // Divergence type classification
      if(recent.is_high) // Looking at highs
      {
         if(price_diff > 0 && macd_diff < 0) // Higher highs, lower MACD highs
         {
            div_info.divergence_type = DIVERGENCE_REGULAR_BEARISH;
         }
         else if(price_diff < 0 && macd_diff > 0) // Lower highs, higher MACD highs
         {
            div_info.divergence_type = DIVERGENCE_HIDDEN_BULLISH;
         }
      }
      else // Looking at lows
      {
         if(price_diff < 0 && macd_diff > 0) // Lower lows, higher MACD lows
         {
            div_info.divergence_type = DIVERGENCE_REGULAR_BULLISH;
         }
         else if(price_diff > 0 && macd_diff < 0) // Higher lows, lower MACD lows
         {
            div_info.divergence_type = DIVERGENCE_HIDDEN_BEARISH;
         }
      }
      
      if(div_info.divergence_type != DIVERGENCE_NONE)
      {
         div_info.active = true;
         div_info.start_time = m_time_history[tf_index][older.index];
         div_info.end_time = m_time_history[tf_index][recent.index];
         div_info.start_price = older.price;
         div_info.end_price = recent.price;
         div_info.start_macd = older.macd;
         div_info.end_macd = recent.macd;
         div_info.start_histogram = older.histogram;
         div_info.end_histogram = recent.histogram;
         
         // Calculate angles
         div_info.price_divergence_angle = CalculateDivergenceAngle(price_diff, recent.index - older.index);
         div_info.macd_divergence_angle = CalculateDivergenceAngle(macd_diff, recent.index - older.index);
         
         // Calculate strength
         div_info.strength = CalculateDivergenceStrength(price_diff, macd_diff, histogram_diff, recent.is_high);
         div_info.reliability = CalculateDivergenceReliability(div_info);
         
         // Histogram analysis
         div_info.histogram_supports = AnalyzeHistogramSupport(div_info, histogram_diff);
         div_info.histogram_strength = CalculateHistogramStrength(histogram_diff);
         div_info.momentum_phase = AnalyzeMomentumPhase(div_info);
         
         // Calculate probabilities
         div_info.reversal_probability = CalculateReversalProbability(div_info);
         div_info.target_projection = CalculateTargetProjection(div_info);
         div_info.fibonacci_target = CalculateFibonacciTarget(div_info);
         
         // Confirmation analysis
         div_info.confirmation_bars = recent.index; // Bars since divergence
         div_info.confirmed = (div_info.confirmation_bars >= 3 && div_info.strength >= 70.0);
      }
      
      return div_info;
   }
   
   double CalculateDivergenceAngle(double value_diff, int time_diff)
   {
      if(time_diff <= 0) return 0.0;
      
      double slope = value_diff / time_diff;
      double angle = MathArctan(slope) * 180.0 / M_PI; // Convert to degrees
      
      return angle;
   }
   
   double CalculateDivergenceStrength(double price_diff, double macd_diff, double histogram_diff, bool is_high)
   {
      double strength = 0.0;
      
      // Base strength from difference magnitude
      double price_magnitude = MathAbs(price_diff);
      double macd_magnitude = MathAbs(macd_diff);
      double histogram_magnitude = MathAbs(histogram_diff);
      
      // Normalize and combine
      strength = (macd_magnitude / 0.001) * 30.0; // MACD diff component (scale appropriately)
      strength += (price_magnitude > 0) ? 25.0 : 0.0; // Price diff component
      strength += (histogram_magnitude / m_histogram_threshold) * 20.0; // Histogram component
      
      // Bonus for strong divergence angles
      double angle_threshold = 30.0; // degrees
      if(MathAbs(CalculateDivergenceAngle(macd_diff, 10)) > angle_threshold)
         strength += 15.0;
      
      // Bonus for extreme MACD levels
      if(is_high && (macd_diff < -0.001)) strength += 10.0;
      if(!is_high && (macd_diff > 0.001)) strength += 10.0;
      
      return MathMax(0.0, MathMin(100.0, strength));
   }
   
   double CalculateDivergenceReliability(const MACDDivergenceInfo &div_info)
   {
      double reliability = 60.0; // Base reliability
      
      // Time span factor
      double time_span_hours = (div_info.end_time - div_info.start_time) / 3600.0;
      if(time_span_hours > 24.0) reliability += 15.0;
      if(time_span_hours > 72.0) reliability += 10.0;
      
      // Strength factor
      if(div_info.strength > 80.0) reliability += 15.0;
      else if(div_info.strength > 60.0) reliability += 10.0;
      
      // Regular divergences are generally more reliable
      if(div_info.divergence_type == DIVERGENCE_REGULAR_BULLISH || 
         div_info.divergence_type == DIVERGENCE_REGULAR_BEARISH)
         reliability += 15.0;
      
      // Histogram support increases reliability
      if(div_info.histogram_supports)
         reliability += 10.0;
      
      return MathMax(0.0, MathMin(100.0, reliability));
   }
   
   bool AnalyzeHistogramSupport(const MACDDivergenceInfo &div_info, double histogram_diff)
   {
      // Check if histogram movement supports the divergence
      bool supports = false;
      
      switch(div_info.divergence_type)
      {
         case DIVERGENCE_REGULAR_BULLISH:
            supports = (histogram_diff > 0); // Histogram should be improving
            break;
         case DIVERGENCE_REGULAR_BEARISH:
            supports = (histogram_diff < 0); // Histogram should be deteriorating
            break;
         case DIVERGENCE_HIDDEN_BULLISH:
            supports = (histogram_diff > 0); // Histogram should support continuation
            break;
         case DIVERGENCE_HIDDEN_BEARISH:
            supports = (histogram_diff < 0); // Histogram should support continuation
            break;
      }
      
      return supports;
   }
   
   double CalculateHistogramStrength(double histogram_diff)
   {
      double strength = MathAbs(histogram_diff) / m_histogram_threshold * 50.0;
      return MathMax(0.0, MathMin(100.0, strength));
   }
   
   ENUM_MACD_MOMENTUM_PHASE AnalyzeMomentumPhase(const MACDDivergenceInfo &div_info)
   {
      // Analyze the momentum phase based on divergence characteristics
      double histogram_change = div_info.end_histogram - div_info.start_histogram;
      
      if(div_info.divergence_type == DIVERGENCE_REGULAR_BULLISH)
      {
         return (histogram_change > 0) ? MACD_ACCELERATION_UP : MACD_MOMENTUM_REVERSAL;
      }
      else if(div_info.divergence_type == DIVERGENCE_REGULAR_BEARISH)
      {
         return (histogram_change < 0) ? MACD_ACCELERATION_DOWN : MACD_MOMENTUM_REVERSAL;
      }
      else if(div_info.divergence_type == DIVERGENCE_HIDDEN_BULLISH)
      {
         return MACD_DECELERATION_UP; // Temporary pullback in uptrend
      }
      else if(div_info.divergence_type == DIVERGENCE_HIDDEN_BEARISH)
      {
         return MACD_DECELERATION_DOWN; // Temporary pullback in downtrend
      }
      
      return MACD_MOMENTUM_UNKNOWN;
   }
   
   double CalculateReversalProbability(const MACDDivergenceInfo &div_info)
   {
      double probability = div_info.reliability * 0.7; // Base from reliability
      
      // Adjust based on divergence type
      if(div_info.divergence_type == DIVERGENCE_REGULAR_BULLISH || 
         div_info.divergence_type == DIVERGENCE_REGULAR_BEARISH)
         probability *= 1.3; // Regular divergences more likely to reverse
      else
         probability *= 0.8; // Hidden divergences less likely to reverse
      
      // Histogram support increases probability
      if(div_info.histogram_supports)
         probability *= 1.2;
      
      // Strong divergence angles increase probability
      if(MathAbs(div_info.macd_divergence_angle) > 30.0)
         probability *= 1.1;
      
      return MathMax(0.0, MathMin(100.0, probability));
   }
   
   double CalculateTargetProjection(const MACDDivergenceInfo &div_info)
   {
      // Simple target calculation based on price difference
      double price_range = MathAbs(div_info.end_price - div_info.start_price);
      
      // Project similar move in reversal direction
      if(div_info.divergence_type == DIVERGENCE_REGULAR_BULLISH)
         return div_info.end_price + (price_range * 0.618); // Fibonacci ratio
      else if(div_info.divergence_type == DIVERGENCE_REGULAR_BEARISH)
         return div_info.end_price - (price_range * 0.618);
      else // Hidden divergences - continuation targets
         return div_info.end_price + (price_range * 0.382 * (div_info.divergence_type == DIVERGENCE_HIDDEN_BULLISH ? 1 : -1));
   }
   
   double CalculateFibonacciTarget(const MACDDivergenceInfo &div_info)
   {
      double price_range = MathAbs(div_info.end_price - div_info.start_price);
      double fib_extension = price_range * 1.618; // Fibonacci extension
      
      if(div_info.divergence_type == DIVERGENCE_REGULAR_BULLISH)
         return div_info.end_price + fib_extension;
      else if(div_info.divergence_type == DIVERGENCE_REGULAR_BEARISH)
         return div_info.end_price - fib_extension;
      else
         return div_info.target_projection; // Use regular target for hidden divergences
   }
   
   void AnalyzeZeroLine(MACDMomentumInfo &info)
   {
      // Analyze MACD position relative to zero line
      info.above_zero_line = (info.macd_h1 > 0);
      info.zero_line_distance = MathAbs(info.macd_h1);
      info.approaching_zero = false;
      
      // Calculate zero line duration
      info.zero_line_duration = CalculateZeroLineDuration(info);
      
      // Check if approaching zero line
      if(m_history_size[1] >= 5)
      {
         double prev_distance = MathAbs(m_macd_history[1][1]);
         info.approaching_zero = (info.zero_line_distance < prev_distance);
      }
   }
   
   int CalculateZeroLineDuration(const MACDMomentumInfo &info)
   {
      if(m_history_size[1] < 10) return 0;
      
      bool current_above = info.above_zero_line;
      int duration = 0;
      
      for(int i = 1; i < m_history_size[1] && i < 100; i++)
      {
         bool historical_above = (m_macd_history[1][i] > 0);
         if(historical_above == current_above)
            duration++;
         else
            break;
      }
      
      return duration;
   }
   
   void CalculateConfluence(MACDMomentumInfo &info)
   {
      // Timeframe alignment calculation
      info.timeframe_alignment = 0;
      
      // Count aligned conditions
      ENUM_MACD_CONDITION conditions[] = {info.condition_m15, info.condition_h1, info.condition_h4, info.condition_d1};
      
      // Bullish alignment
      int bullish_count = 0, bearish_count = 0;
      for(int i = 0; i < ArraySize(conditions); i++)
      {
         if(conditions[i] == MACD_BULLISH_WEAK || conditions[i] == MACD_BULLISH_MODERATE || conditions[i] == MACD_BULLISH_STRONG)
            bullish_count++;
         else if(conditions[i] == MACD_BEARISH_WEAK || conditions[i] == MACD_BEARISH_MODERATE || conditions[i] == MACD_BEARISH_STRONG)
            bearish_count++;
      }
      
      info.timeframe_alignment = MathMax(bullish_count, bearish_count);
      
      // Confluence score calculation
      info.confluence_score = 0.0;
      
      // Base score from alignment
      info.confluence_score += info.timeframe_alignment * 15.0;
      
      // Phase alignment bonus
      if(info.phase_short == info.phase_medium && info.phase_medium == info.phase_long)
         info.confluence_score += 25.0;
      else if(info.phase_short == info.phase_medium || info.phase_medium == info.phase_long)
         info.confluence_score += 15.0;
      
      // Crossover confluence
      info.cross_confluence = 0.0;
      if(info.has_signal_line_cross) info.cross_confluence += 20.0;
      if(info.has_zero_line_cross) info.cross_confluence += 25.0;
      if(info.has_histogram_reversal) info.cross_confluence += 15.0;
      info.confluence_score += info.cross_confluence;
      
      // Divergence confluence
      info.divergence_confluence = 0.0;
      if(info.has_bullish_divergence || info.has_bearish_divergence) info.divergence_confluence += 25.0;
      if(info.has_hidden_divergence) info.divergence_confluence += 15.0;
      if(info.has_macd_histogram_div) info.divergence_confluence += 10.0;
      info.confluence_score += info.divergence_confluence;
      
      // Zero line analysis bonus
      if(info.above_zero_line && bullish_count > bearish_count)
         info.confluence_score += 10.0;
      else if(!info.above_zero_line && bearish_count > bullish_count)
         info.confluence_score += 10.0;
      
      // Set confluence level
      if(info.confluence_score >= 80.0)
         info.confluence_level = CONFLUENCE_VERY_STRONG;
      else if(info.confluence_score >= 60.0)
         info.confluence_level = CONFLUENCE_STRONG;
      else if(info.confluence_score >= 40.0)
         info.confluence_level = CONFLUENCE_MODERATE;
      else if(info.confluence_score >= 20.0)
         info.confluence_level = CONFLUENCE_WEAK;
      else
         info.confluence_level = CONFLUENCE_NONE;
   }
   
   void AnalyzeAdvancedMomentum(MACDMomentumInfo &info)
   {
      // Calculate advanced momentum metrics
      info.momentum_strength = CalculateMomentumStrength(info);
      info.momentum_velocity = CalculateMomentumVelocity(info);
      info.momentum_acceleration = CalculateMomentumAcceleration(info);
      info.momentum_persistence = CalculateMomentumPersistence(info);
      info.histogram_momentum = CalculateHistogramMomentum(info);
      info.signal_strength = CalculateSignalStrength(info);
      
      // Trend analysis
      info.trend_strength = CalculateTrendStrength(info);
      info.trend_sustainability = CalculateTrendSustainability(info);
      info.reversal_potential = CalculateReversalPotential(info);
   }
   
   double CalculateMomentumStrength(const MACDMomentumInfo &info)
   {
      double strength = 50.0; // Base strength
      
      // MACD distance from zero
      strength += MathAbs(info.macd_h1) * 1000.0; // Scale appropriately
      
      // Histogram strength
      strength += MathAbs(info.histogram_h1) * 2000.0; // Scale appropriately
      
      // Crossover strength
      if(info.active_crossover_count > 0)
      {
         double avg_crossover_strength = 0.0;
         for(int i = 0; i < info.active_crossover_count; i++)
         {
            avg_crossover_strength += info.crossovers[i].strength;
         }
         strength += (avg_crossover_strength / info.active_crossover_count) * 0.3;
      }
      
      return MathMax(0.0, MathMin(100.0, strength));
   }
   
   double CalculateMomentumVelocity(const MACDMomentumInfo &info)
   {
      if(m_history_size[1] < 3) return 0.0;
      
      // Calculate rate of change in MACD
      double current_macd = info.macd_h1;
      double prev_macd = m_macd_history[1][1];
      double velocity = (current_macd - prev_macd) * 1000.0; // Scale appropriately
      
      return MathMax(-100.0, MathMin(100.0, velocity));
   }
   
   double CalculateMomentumAcceleration(const MACDMomentumInfo &info)
   {
      if(m_history_size[1] < 4) return 0.0;
      
      // Calculate acceleration (change in velocity)
      double current_velocity = info.momentum_velocity;
      
      // Calculate previous velocity
      double prev_current = m_macd_history[1][1];
      double prev_prev = m_macd_history[1][2];
      double prev_velocity = (prev_current - prev_prev) * 1000.0;
      
      double acceleration = current_velocity - prev_velocity;
      
      return MathMax(-100.0, MathMin(100.0, acceleration));
   }
   
   double CalculateMomentumPersistence(const MACDMomentumInfo &info)
   {
      if(m_history_size[1] < 10) return 50.0;
      
      // Calculate how consistently momentum has been in same direction
      double current_direction = (info.macd_h1 > 0) ? 1.0 : -1.0;
      int consistent_count = 0;
      
      for(int i = 1; i < MathMin(10, m_history_size[1]); i++)
      {
         double historical_direction = (m_macd_history[1][i] > 0) ? 1.0 : -1.0;
         if(historical_direction == current_direction)
            consistent_count++;
      }
      
      return (consistent_count * 10.0); // 0-100 scale
   }
   
   double CalculateHistogramMomentum(const MACDMomentumInfo &info)
   {
      if(m_history_size[1] < 3) return 0.0;
      
      // Calculate histogram momentum
      double current_histogram = info.histogram_h1;
      double prev_histogram = m_histogram_history[1][1];
      
      double histogram_change = current_histogram - prev_histogram;
      double momentum = histogram_change * 5000.0; // Scale appropriately
      
      return MathMax(-100.0, MathMin(100.0, momentum));
   }
   
   double CalculateSignalStrength(const MACDMomentumInfo &info)
   {
      double strength = 0.0;
      
      // Base strength from confluence
      strength += info.confluence_score * 0.4;
      
      // Crossover strength
      if(info.active_crossover_count > 0)
      {
         double max_crossover_strength = 0.0;
         for(int i = 0; i < info.active_crossover_count; i++)
         {
            max_crossover_strength = MathMax(max_crossover_strength, info.crossovers[i].strength);
         }
         strength += max_crossover_strength * 0.3;
      }
      
      // Divergence strength
      if(info.active_divergence_count > 0)
      {
         double max_divergence_strength = 0.0;
         for(int i = 0; i < info.active_divergence_count; i++)
         {
            max_divergence_strength = MathMax(max_divergence_strength, info.divergences[i].strength);
         }
         strength += max_divergence_strength * 0.3;
      }
      
      return MathMax(0.0, MathMin(100.0, strength));
   }
   
   double CalculateTrendStrength(const MACDMomentumInfo &info)
   {
      double strength = 0.0;
      
      // Zero line position
      if(info.above_zero_line)
         strength += 30.0;
      
      // Zero line duration
      strength += MathMin(info.zero_line_duration * 2.0, 30.0);
      
      // MACD vs Signal position
      if(info.macd_h1 > info.signal_h1)
         strength += 20.0;
      
      // Histogram direction
      if(info.histogram_h1 > 0)
         strength += 20.0;
      
      return MathMax(0.0, MathMin(100.0, strength));
   }
   
   double CalculateTrendSustainability(const MACDMomentumInfo &info)
   {
      double sustainability = 50.0; // Base
      
      // Momentum persistence factor
      sustainability += (info.momentum_persistence - 50.0) * 0.5;
      
      // Divergence risk (reduces sustainability)
      if(info.has_bullish_divergence || info.has_bearish_divergence)
         sustainability -= 20.0;
      
      // Crossover support (increases sustainability)
      if(info.has_signal_line_cross)
         sustainability += 10.0;
      
      return MathMax(0.0, MathMin(100.0, sustainability));
   }
   
   double CalculateReversalPotential(const MACDMomentumInfo &info)
   {
      double potential = 0.0;
      
      // Divergence increases reversal potential
      if(info.has_bullish_divergence || info.has_bearish_divergence)
         potential += 40.0;
      
      // Extreme MACD levels
      if(MathAbs(info.macd_h1) > 0.005) // Threshold for "extreme"
         potential += 20.0;
      
      // Momentum exhaustion
      if(info.overall_phase == MACD_MOMENTUM_EXHAUSTION)
         potential += 30.0;
      
      // Approaching zero line
      if(info.approaching_zero)
         potential += 10.0;
      
      return MathMax(0.0, MathMin(100.0, potential));
   }
   
   void GenerateSignals(MACDMomentumInfo &info)
   {
      info.primary_signal = SIGNAL_NONE;
      info.signal_strength_enum = SIGNAL_STRENGTH_NONE;
      info.signal_confidence = 0.0;
      info.entry_probability = 0.0;
      info.macd_signal_type = MACD_SIGNAL_NONE;
      
      // Signal generation based on multiple factors
      double bullish_score = 0.0, bearish_score = 0.0;
      
      // MACD condition scoring
      switch(info.condition_h1)
      {
         case MACD_BULLISH_STRONG: bullish_score += 40.0; break;
         case MACD_BULLISH_MODERATE: bullish_score += 30.0; break;
         case MACD_BULLISH_WEAK: bullish_score += 20.0; break;
         case MACD_BEARISH_STRONG: bearish_score += 40.0; break;
         case MACD_BEARISH_MODERATE: bearish_score += 30.0; break;
         case MACD_BEARISH_WEAK: bearish_score += 20.0; break;
      }
      
      // Crossover scoring
      if(info.has_signal_line_cross)
      {
         for(int i = 0; i < info.active_crossover_count; i++)
         {
            MACDCrossoverInfo cross = info.crossovers[i];
            if(cross.crossover_type == MACD_SIGNAL_LINE_CROSS_UP)
               bullish_score += cross.strength * 0.5;
            else if(cross.crossover_type == MACD_SIGNAL_LINE_CROSS_DOWN)
               bearish_score += cross.strength * 0.5;
         }
      }
      
      if(info.has_zero_line_cross)
      {
         for(int i = 0; i < info.active_crossover_count; i++)
         {
            MACDCrossoverInfo cross = info.crossovers[i];
            if(cross.crossover_type == MACD_ZERO_LINE_CROSS_UP)
               bullish_score += cross.strength * 0.6;
            else if(cross.crossover_type == MACD_ZERO_LINE_CROSS_DOWN)
               bearish_score += cross.strength * 0.6;
         }
      }
      
      // Divergence scoring
      if(info.has_bullish_divergence)
      {
         for(int i = 0; i < info.active_divergence_count; i++)
         {
            if(info.divergences[i].divergence_type == DIVERGENCE_REGULAR_BULLISH)
               bullish_score += info.divergences[i].strength * 0.7;
         }
      }
      
      if(info.has_bearish_divergence)
      {
         for(int i = 0; i < info.active_divergence_count; i++)
         {
            if(info.divergences[i].divergence_type == DIVERGENCE_REGULAR_BEARISH)
               bearish_score += info.divergences[i].strength * 0.7;
         }
      }
      
      // Phase scoring
      switch(info.overall_phase)
      {
         case MACD_ACCELERATION_UP: bullish_score += 25.0; break;
         case MACD_DECELERATION_UP: bullish_score += 15.0; break;
         case MACD_ACCELERATION_DOWN: bearish_score += 25.0; break;
         case MACD_DECELERATION_DOWN: bearish_score += 15.0; break;
         case MACD_MOMENTUM_REVERSAL:
            if(info.macd_h1 < 0) bullish_score += 20.0;
            else bearish_score += 20.0;
            break;
      }
      
      // Zero line position bonus
      if(info.above_zero_line) bullish_score += 10.0;
      else bearish_score += 10.0;
      
      // Determine primary signal
      if(bullish_score > bearish_score && bullish_score >= 50.0)
      {
         info.primary_signal = SIGNAL_BUY;
         info.signal_confidence = MathMin(100.0, bullish_score);
         
         // Determine MACD signal type
         if(info.has_signal_line_cross) info.macd_signal_type = MACD_SIGNAL_LINE_CROSS_UP;
         else if(info.has_zero_line_cross) info.macd_signal_type = MACD_ZERO_LINE_CROSS_UP;
         else if(info.has_bullish_divergence) info.macd_signal_type = MACD_DIVERGENCE_BULLISH;
         else info.macd_signal_type = MACD_HISTOGRAM_REVERSAL_UP;
      }
      else if(bearish_score > bullish_score && bearish_score >= 50.0)
      {
         info.primary_signal = SIGNAL_SELL;
         info.signal_confidence = MathMin(100.0, bearish_score);
         
         // Determine MACD signal type
         if(info.has_signal_line_cross) info.macd_signal_type = MACD_SIGNAL_LINE_CROSS_DOWN;
         else if(info.has_zero_line_cross) info.macd_signal_type = MACD_ZERO_LINE_CROSS_DOWN;
         else if(info.has_bearish_divergence) info.macd_signal_type = MACD_DIVERGENCE_BEARISH;
         else info.macd_signal_type = MACD_HISTOGRAM_REVERSAL_DOWN;
      }
      
      // Signal strength classification
      if(info.signal_confidence >= 90.0)
         info.signal_strength_enum = SIGNAL_EXTREME;
      else if(info.signal_confidence >= 75.0)
         info.signal_strength_enum = SIGNAL_VERY_STRONG;
      else if(info.signal_confidence >= 60.0)
         info.signal_strength_enum = SIGNAL_STRONG;
      else if(info.signal_confidence >= 45.0)
         info.signal_strength_enum = SIGNAL_MODERATE;
      else if(info.signal_confidence >= 30.0)
         info.signal_strength_enum = SIGNAL_WEAK;
      else
         info.signal_strength_enum = SIGNAL_VERY_WEAK;
      
      // Entry probability calculation
      info.entry_probability = info.signal_confidence * (info.confluence_score / 100.0);
      
      // Signal maturity
      info.signal_maturity = CalculateSignalMaturity(info);
   }
   
   int CalculateSignalMaturity(const MACDMomentumInfo &info)
   {
      int maturity = 0;
      
      // Count bars since most recent crossover
      if(info.active_crossover_count > 0)
      {
         maturity = info.crossovers[0].confirmation_bars;
      }
      
      // Minimum maturity for confirmed signals
      if(maturity < 2 && info.signal_confidence > 70.0)
         maturity = 2;
      
      return maturity;
   }
   
   void ExtractMLFeatures(MACDMomentumInfo &info)
   {
      // Feature 1-5: MACD values
      m_ml_features[0] = info.macd_m15 * 1000.0; // Scale for ML
      m_ml_features[1] = info.macd_h1 * 1000.0;
      m_ml_features[2] = info.macd_h4 * 1000.0;
      m_ml_features[3] = info.macd_d1 * 1000.0;
      m_ml_features[4] = info.macd_w1 * 1000.0;
      
      // Feature 6-10: Signal values
      m_ml_features[5] = info.signal_m15 * 1000.0;
      m_ml_features[6] = info.signal_h1 * 1000.0;
      m_ml_features[7] = info.signal_h4 * 1000.0;
      m_ml_features[8] = info.signal_d1 * 1000.0;
      m_ml_features[9] = info.signal_w1 * 1000.0;
      
      // Feature 11-15: Histogram values
      m_ml_features[10] = info.histogram_m15 * 1000.0;
      m_ml_features[11] = info.histogram_h1 * 1000.0;
      m_ml_features[12] = info.histogram_h4 * 1000.0;
      m_ml_features[13] = info.histogram_d1 * 1000.0;
      m_ml_features[14] = info.histogram_w1 * 1000.0;
      
      // Feature 16-20: Conditions and phases
      m_ml_features[15] = (double)info.condition_h1 / 7.0;
      m_ml_features[16] = (double)info.overall_phase / 6.0;
      m_ml_features[17] = info.timeframe_alignment / 5.0;
      m_ml_features[18] = info.confluence_score / 100.0;
      m_ml_features[19] = info.above_zero_line ? 1.0 : 0.0;
      
      // Feature 21-25: Advanced metrics
      m_ml_features[20] = info.momentum_strength / 100.0;
      m_ml_features[21] = (info.momentum_velocity + 100.0) / 200.0; // Normalize -100,+100 to 0,1
      m_ml_features[22] = (info.momentum_acceleration + 100.0) / 200.0;
      m_ml_features[23] = info.momentum_persistence / 100.0;
      m_ml_features[24] = (info.histogram_momentum + 100.0) / 200.0;
      
      // Feature 26-30: Crossovers and divergences
      m_ml_features[25] = info.has_signal_line_cross ? 1.0 : 0.0;
      m_ml_features[26] = info.has_zero_line_cross ? 1.0 : 0.0;
      m_ml_features[27] = info.has_bullish_divergence ? 1.0 : 0.0;
      m_ml_features[28] = info.has_bearish_divergence ? 1.0 : 0.0;
      m_ml_features[29] = info.zero_line_duration / 50.0; // Normalize to reasonable range
   }
   
   void CalculateMLPredictions(MACDMomentumInfo &info)
   {
      if(!m_ml_trained) return;
      
      // Simple neural network prediction (placeholder)
      double ml_score = 0.0;
      for(int i = 0; i < 30; i++)
      {
         ml_score += m_ml_features[i] * m_ml_weights[i];
      }
      
      // Apply activation function and normalize
      ml_score = (MathTanh(ml_score) + 1.0) * 50.0; // 0-100 range
      info.ml_momentum_score = MathMax(0.0, MathMin(100.0, ml_score));
      
      // Calculate specific probabilities
      if(info.primary_signal == SIGNAL_BUY)
      {
         info.ml_reversal_prob = (100.0 - info.ml_momentum_score) * 0.8;
         info.ml_continuation_prob = info.ml_momentum_score * 0.9;
      }
      else if(info.primary_signal == SIGNAL_SELL)
      {
         info.ml_reversal_prob = info.ml_momentum_score * 0.8;
         info.ml_continuation_prob = (100.0 - info.ml_momentum_score) * 0.9;
      }
      else
      {
         info.ml_reversal_prob = 50.0;
         info.ml_continuation_prob = 50.0;
      }
      
      // Pattern recognition scores
      info.pattern_recognition_score = CalculatePatternRecognitionScore(info);
      info.histogram_pattern_score = CalculateHistogramPatternScore(info);
   }
   
   double CalculatePatternRecognitionScore(const MACDMomentumInfo &info)
   {
      double pattern_score = 50.0; // Base score
      
      // Classic MACD patterns
      if(info.has_bullish_divergence && info.macd_h1 < 0)
         pattern_score += 30.0; // Classic bullish divergence pattern
      
      if(info.has_bearish_divergence && info.macd_h1 > 0)
         pattern_score += 30.0; // Classic bearish divergence pattern
      
      // Zero line patterns
      if(info.has_zero_line_cross)
         pattern_score += 25.0;
      
      // Multi-timeframe confirmation
      if(info.timeframe_alignment >= 3)
         pattern_score += 20.0;
      
      // Signal line crossover patterns
      if(info.has_signal_line_cross && info.above_zero_line)
         pattern_score += 15.0; // Strong bullish pattern
      
      return MathMax(0.0, MathMin(100.0, pattern_score));
   }
   
   double CalculateHistogramPatternScore(const MACDMomentumInfo &info)
   {
      double pattern_score = 50.0; // Base score
      
      // Histogram reversal patterns
      if(info.has_histogram_reversal)
         pattern_score += 25.0;
      
      // Histogram momentum patterns
      if(MathAbs(info.histogram_momentum) > 50.0)
         pattern_score += 20.0;
      
      // Histogram divergence patterns
      if(info.has_macd_histogram_div)
         pattern_score += 15.0;
      
      return MathMax(0.0, MathMin(100.0, pattern_score));
   }
   
   void AssessRisk(MACDMomentumInfo &info)
   {
      // Base risk assessment
      info.risk_level = RISK_MEDIUM;
      info.volatility_factor = 1.0;
      info.counter_trend_risk = false;
      info.divergence_risk = false;
      info.false_signal_prob = 30.0; // Base false signal probability
      
      // Adjust risk based on conditions
      if(info.signal_confidence < 40.0)
      {
         info.risk_level = RISK_HIGH;
         info.false_signal_prob += 20.0;
      }
      
      if(info.confluence_score < 30.0)
      {
         info.risk_level = RISK_HIGH;
         info.volatility_factor = 1.5;
      }
      
      // Divergence risk assessment
      if(info.has_bullish_divergence || info.has_bearish_divergence)
      {
         info.divergence_risk = true;
         if(info.active_divergence_count > 1)
         {
            info.risk_level = RISK_VERY_HIGH;
            info.volatility_factor = 2.0;
         }
      }
      
      // Counter-trend risk assessment
      if((info.primary_signal == SIGNAL_BUY && !info.above_zero_line) ||
         (info.primary_signal == SIGNAL_SELL && info.above_zero_line))
      {
         info.counter_trend_risk = true;
         if(info.risk_level < RISK_HIGH)
            info.risk_level = RISK_HIGH;
      }
      
      // Signal maturity reduces risk
      if(info.signal_maturity >= 3)
      {
         info.false_signal_prob -= 10.0;
         if(info.risk_level == RISK_VERY_HIGH) info.risk_level = RISK_HIGH;
      }
      
      // Strong confluence reduces risk
      if(info.confluence_level >= CONFLUENCE_STRONG)
      {
         info.false_signal_prob -= 15.0;
         if(info.risk_level == RISK_VERY_HIGH) info.risk_level = RISK_HIGH;
         else if(info.risk_level == RISK_HIGH) info.risk_level = RISK_MEDIUM;
         else if(info.risk_level == RISK_MEDIUM) info.risk_level = RISK_LOW;
      }
      
      // Normalize false signal probability
      info.false_signal_prob = MathMax(5.0, MathMin(70.0, info.false_signal_prob));
   }

public:
   //+------------------------------------------------------------------+
   //| Public Interface Methods                                         |
   //+------------------------------------------------------------------+
   bool IsInitialized() const { return m_initialized; }
   string GetSymbol() const { return m_symbol; }
   
   // Configuration methods
   void SetMACDParameters(int fast_ema, int slow_ema, int signal_sma)
   {
      m_fast_ema = MathMax(5, MathMin(50, fast_ema));
      m_slow_ema = MathMax(10, MathMin(100, slow_ema));
      m_signal_sma = MathMax(3, MathMin(30, signal_sma));
      
      if(m_fast_ema >= m_slow_ema)
      {
         Print("WARNING: Fast EMA must be less than Slow EMA");
         m_fast_ema = m_slow_ema - 1;
      }
   }
   
   void SetDivergenceSettings(int lookback, double min_strength, int min_bars)
   {
      m_divergence_lookback = MathMax(20, MathMin(100, lookback));
      m_min_divergence_strength = MathMax(30.0, MathMin(90.0, min_strength));
      m_min_bars_between_peaks = MathMax(3, MathMin(20, min_bars));
   }
   
   void SetCrossoverSettings(int confirmation_bars, double min_strength, bool require_histogram)
   {
      m_crossover_confirmation = MathMax(1, MathMin(10, confirmation_bars));
      m_min_crossover_strength = MathMax(20.0, MathMin(90.0, min_strength));
      m_require_histogram_support = require_histogram;
   }
   
   // Quick access methods
   double GetCurrentMACD(ENUM_TIMEFRAMES timeframe = PERIOD_H1)
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      
      switch(timeframe)
      {
         case PERIOD_M15: return info.macd_m15;
         case PERIOD_H1: return info.macd_h1;
         case PERIOD_H4: return info.macd_h4;
         case PERIOD_D1: return info.macd_d1;
         case PERIOD_W1: return info.macd_w1;
         default: return info.macd_h1;
      }
   }
   
   double GetCurrentSignal(ENUM_TIMEFRAMES timeframe = PERIOD_H1)
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      
      switch(timeframe)
      {
         case PERIOD_M15: return info.signal_m15;
         case PERIOD_H1: return info.signal_h1;
         case PERIOD_H4: return info.signal_h4;
         case PERIOD_D1: return info.signal_d1;
         case PERIOD_W1: return info.signal_w1;
         default: return info.signal_h1;
      }
   }
   
   double GetCurrentHistogram(ENUM_TIMEFRAMES timeframe = PERIOD_H1)
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      
      switch(timeframe)
      {
         case PERIOD_M15: return info.histogram_m15;
         case PERIOD_H1: return info.histogram_h1;
         case PERIOD_H4: return info.histogram_h4;
         case PERIOD_D1: return info.histogram_d1;
         case PERIOD_W1: return info.histogram_w1;
         default: return info.histogram_h1;
      }
   }
   
   ENUM_MACD_CONDITION GetMACDCondition(ENUM_TIMEFRAMES timeframe = PERIOD_H1)
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      
      switch(timeframe)
      {
         case PERIOD_M15: return info.condition_m15;
         case PERIOD_H1: return info.condition_h1;
         case PERIOD_H4: return info.condition_h4;
         case PERIOD_D1: return info.condition_d1;
         default: return info.condition_h1;
      }
   }
   
   bool HasSignalLineCrossover()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      return info.has_signal_line_cross;
   }
   
   bool HasZeroLineCrossover()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      return info.has_zero_line_cross;
   }
   
   bool HasBullishDivergence()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      return info.has_bullish_divergence;
   }
   
   bool HasBearishDivergence()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      return info.has_bearish_divergence;
   }
   
   bool IsAboveZeroLine()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      return info.above_zero_line;
   }
   
   ENUM_MACD_MOMENTUM_PHASE GetOverallPhase()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      return info.overall_phase;
   }
   
   double GetConfluenceScore()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      return info.confluence_score;
   }
   
   // ML and advanced features
   bool GetMLFeatures(double &features[])
   {
      if(!m_initialized) return false;
      
      MACDMomentumInfo info = AnalyzeMomentum(); // This updates ML features
      ArrayResize(features, 30);
      ArrayCopy(features, m_ml_features);
      return true;
   }
   
   bool TrainMLModel(const string historical_data_file = "")
   {
      // Placeholder for ML training
      m_ml_trained = true;
      
      // Initialize random weights (placeholder)
      for(int i = 0; i < 30; i++)
         m_ml_weights[i] = (MathRand() / 32767.0) * 2.0 - 1.0;
      
      Print("MACD ML model training completed (placeholder implementation)");
      return true;
   }
   
   // Performance metrics
   double GetAccuracyRate() const { return m_accuracy_rate; }
   int GetTotalCalculations() const { return m_total_calculations; }
   datetime GetLastCalculationTime() const { return m_last_calculation; }
   
   // Update methods
   bool RefreshHistoricalData()
   {
      return LoadHistoricalMACDData();
   }
   
   void UpdatePerformance(bool signal_success)
   {
      if(signal_success)
         m_successful_signals++;
      
      if(m_total_calculations > 0)
         m_accuracy_rate = (m_successful_signals * 100.0) / m_total_calculations;
   }
   
   // MACD specific analysis methods
   MACDCrossoverInfo GetLatestCrossover()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      if(info.active_crossover_count > 0)
         return info.crossovers[0];
      
      MACDCrossoverInfo empty;
      return empty;
   }
   
   MACDDivergenceInfo GetLatestDivergence()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      if(info.active_divergence_count > 0)
         return info.divergences[0];
      
      MACDDivergenceInfo empty;
      return empty;
   }
   
   double GetZeroLineDistance()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      return info.zero_line_distance;
   }
   
   int GetZeroLineDuration()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      return info.zero_line_duration;
   }
   
   // Signal quality assessment
   bool IsHighQualitySignal()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      return (info.signal_confidence >= 70.0 && 
             info.confluence_score >= 60.0 &&
             info.signal_maturity >= 2);
   }
   
   ENUM_SIGNAL_QUALITY GetSignalQuality()
   {
      MACDMomentumInfo info = AnalyzeMomentum();
      
      if(info.signal_confidence >= 90.0 && info.confluence_score >= 80.0)
         return SIGNAL_QUALITY_EXCELLENT;
      else if(info.signal_confidence >= 75.0 && info.confluence_score >= 65.0)
         return SIGNAL_QUALITY_VERY_GOOD;
      else if(info.signal_confidence >= 60.0 && info.confluence_score >= 50.0)
         return SIGNAL_QUALITY_GOOD;
      else if(info.signal_confidence >= 45.0 && info.confluence_score >= 35.0)
         return SIGNAL_QUALITY_FAIR;
      else if(info.signal_confidence >= 30.0)
         return SIGNAL_QUALITY_POOR;
      else
         return SIGNAL_QUALITY_VERY_POOR;
   }
};
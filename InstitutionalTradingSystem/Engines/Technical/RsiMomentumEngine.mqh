//+------------------------------------------------------------------+
//| RsiMomentumEngine.mqh - Gelişmiş RSI Momentum Analiz Motoru    |
//| ISignalProvider Uyumlu - Multi-timeframe RSI & Divergence      |
//| Hidden/Regular Divergence Detection + ML Enhanced Momentum     |
//| MQL5 UYUMLU - HATALAR DÜZELTİLDİ                               |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/Complete_Enum_Types.mqh"
#include "../../Core/ISignalProvider.mqh"

//+------------------------------------------------------------------+
//| Peak Bilgi Yapısı - MQL5 UYUMLU                                |
//+------------------------------------------------------------------+
struct PeakInfo
{
   int    index;
   double price;
   double rsi;
   bool   is_high;
   
   PeakInfo()
   {
      index = 0;
      price = 0.0;
      rsi = 50.0;
      is_high = false;
   }
};

//+------------------------------------------------------------------+
//| RSI Timeframe Bilgi Yapısı - MQL5 UYUMLU                        |
//+------------------------------------------------------------------+
struct RSITimeframeInfo
{
   ENUM_TIMEFRAMES timeframe;
   double         rsi_value;
   
   // MQL5 uyumlu constructor
   void Initialize()
   {
      timeframe = PERIOD_H1;
      rsi_value = 50.0;
   }
   
   void Initialize(ENUM_TIMEFRAMES tf, double rsi)
   {
      timeframe = tf;
      rsi_value = rsi;
   }
};

//+------------------------------------------------------------------+
//| RSI Divergence Bilgi Yapısı                                     |
//+------------------------------------------------------------------+
struct RSIDivergenceInfo
{
   ENUM_DIVERGENCE_TYPE   divergence_type;    // Divergence türü
   ENUM_TIMEFRAMES        timeframe;          // Zaman çerçevesi
   bool                   active;             // Aktif divergence var mı?
   
   // Divergence detayları
   datetime               start_time;         // Başlangıç zamanı
   datetime               end_time;           // Bitiş zamanı
   double                 start_price;        // Başlangıç fiyatı
   double                 end_price;          // Bitiş fiyatı
   double                 start_rsi;          // Başlangıç RSI
   double                 end_rsi;            // Bitiş RSI
   
   // Güç metrikleri
   double                 strength;           // Divergence gücü (0-100)
   double                 reliability;        // Güvenilirlik (0-100)
   int                    confirmation_bars;  // Onay bar sayısı
   bool                   confirmed;          // Onaylanmış mı?
   
   // Tahmin metrikleri
   double                 reversal_probability; // Dönüş olasılığı
   double                 target_projection;    // Hedef projeksiyon
   int                    expected_duration;    // Beklenen süre (bar)
   
   // Constructor
   RSIDivergenceInfo()
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
      start_rsi = 0.0;
      end_rsi = 0.0;
      
      strength = 0.0;
      reliability = 0.0;
      confirmation_bars = 0;
      confirmed = false;
      
      reversal_probability = 0.0;
      target_projection = 0.0;
      expected_duration = 0;
   }
   
   bool IsValid() const
   {
      return (active && divergence_type != DIVERGENCE_NONE && 
             start_time > 0 && end_time > start_time);
   }
   
   string ToString() const
   {
      return StringFormat("%s Divergence | TF: %d | Strength: %.1f%% | Probability: %.1f%%",
                         DivergenceTypeToString(divergence_type), timeframe, 
                         strength, reversal_probability);
   }
};

//+------------------------------------------------------------------+
//| RSI Momentum Analiz Bilgi Yapısı                               |
//+------------------------------------------------------------------+
struct RSIMomentumInfo
{
   // Temel RSI verileri
   datetime               calculation_time;   // Hesaplama zamanı
   string                 symbol;             // Sembol
   
   // Multi-timeframe RSI değerleri
   double                 rsi_m15;            // M15 RSI
   double                 rsi_h1;             // H1 RSI
   double                 rsi_h4;             // H4 RSI
   double                 rsi_d1;             // D1 RSI
   double                 rsi_w1;             // W1 RSI
   
   // RSI koşulları
   ENUM_RSI_CONDITION     condition_m15;     // M15 RSI durumu
   ENUM_RSI_CONDITION     condition_h1;      // H1 RSI durumu
   ENUM_RSI_CONDITION     condition_h4;      // H4 RSI durumu
   ENUM_RSI_CONDITION     condition_d1;      // D1 RSI durumu
   
   // Trend analizi
   ENUM_RSI_TREND         trend_short;       // Kısa vadeli trend
   ENUM_RSI_TREND         trend_medium;      // Orta vadeli trend
   ENUM_RSI_TREND         trend_long;        // Uzun vadeli trend
   ENUM_RSI_TREND         overall_trend;     // Genel trend
   
   // Momentum durumu
   ENUM_MOMENTUM_STATE    momentum_state;    // Momentum durumu
   double                 momentum_strength; // Momentum gücü (0-100)
   double                 momentum_velocity; // Momentum hızı (-100 to +100)
   double                 momentum_acceleration; // Momentum ivmesi
   
   // Divergence bilgileri
   RSIDivergenceInfo      divergences[5];    // Maksimum 5 aktif divergence
   int                    active_divergence_count; // Aktif divergence sayısı
   bool                   has_bullish_divergence;  // Boğa divergence var mı?
   bool                   has_bearish_divergence;  // Ayı divergence var mı?
   bool                   has_hidden_divergence;   // Gizli divergence var mı?
   
   // Confluence analizi
   int                    timeframe_alignment; // Zaman çerçevesi uyumu (0-5)
   double                 confluence_score;   // Confluence skoru (0-100)
   ENUM_CONFLUENCE_LEVEL  confluence_level;   // Confluence seviyesi
   
   // Extreme level analysis
   bool                   extreme_oversold;   // Aşırı aşırı satım
   bool                   extreme_overbought; // Aşırı aşırı alım
   bool                   multi_tf_extreme;   // Çoklu TF extreme
   int                    extreme_duration;   // Extreme süre (bar)
   
   // Signal generation
   ENUM_SIGNAL_TYPE       primary_signal;    // Ana sinyal
   ENUM_SIGNAL_STRENGTH   signal_strength;   // Sinyal gücü
   double                 signal_confidence; // Sinyal güveni (0-100)
   double                 entry_probability; // Giriş olasılığı
   
   // ML features
   double                 ml_momentum_score;  // ML momentum skoru
   double                 ml_reversal_prob;   // ML dönüş olasılığı
   double                 ml_continuation_prob; // ML devam olasılığı
   double                 pattern_recognition_score; // Pattern tanıma skoru
   
   // Risk assessment
   ENUM_RISK_LEVEL        risk_level;        // Risk seviyesi
   double                 volatility_factor; // Volatilite faktörü
   bool                   counter_trend_risk; // Karşı trend riski
   
   // Constructor
   RSIMomentumInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      calculation_time = 0;
      symbol = "";
      
      rsi_m15 = rsi_h1 = rsi_h4 = rsi_d1 = rsi_w1 = 50.0;
      
      condition_m15 = condition_h1 = condition_h4 = condition_d1 = RSI_NEUTRAL;
      
      trend_short = trend_medium = trend_long = overall_trend = RSI_TREND_NEUTRAL;
      
      momentum_state = MOMENTUM_STABLE;
      momentum_strength = 50.0;
      momentum_velocity = 0.0;
      momentum_acceleration = 0.0;
      
      for(int i = 0; i < 5; i++)
         divergences[i].Reset();
      active_divergence_count = 0;
      has_bullish_divergence = false;
      has_bearish_divergence = false;
      has_hidden_divergence = false;
      
      timeframe_alignment = 0;
      confluence_score = 0.0;
      confluence_level = CONFLUENCE_NONE;
      
      extreme_oversold = false;
      extreme_overbought = false;
      multi_tf_extreme = false;
      extreme_duration = 0;
      
      primary_signal = SIGNAL_NONE;
      signal_strength = SIGNAL_STRENGTH_NONE;
      signal_confidence = 0.0;
      entry_probability = 0.0;
      
      ml_momentum_score = 50.0;
      ml_reversal_prob = 0.0;
      ml_continuation_prob = 0.0;
      pattern_recognition_score = 0.0;
      
      risk_level = RISK_MEDIUM;
      volatility_factor = 1.0;
      counter_trend_risk = false;
   }
   
   bool IsValid() const
   {
      return (calculation_time > 0 && StringLen(symbol) > 0 && 
             rsi_h1 >= 0.0 && rsi_h1 <= 100.0);
   }
   
   string ToString() const
   {
      return StringFormat("RSI H1: %.1f | Trend: %s | Momentum: %s | Confluence: %.1f%% | Signal: %s",
                         rsi_h1, RSITrendToString(overall_trend), 
                         MomentumStateToString(momentum_state),
                         confluence_score, SignalTypeToString(primary_signal));
   }
};

//+------------------------------------------------------------------+
//| Helper Functions                                                 |
//+------------------------------------------------------------------+
string RSIConditionToString(ENUM_RSI_CONDITION condition)
{
   switch(condition)
   {
      case RSI_OVERSOLD_EXTREME: return "OVERSOLD_EXTREME";
      case RSI_OVERSOLD: return "OVERSOLD";
      case RSI_NEUTRAL_BEARISH: return "NEUTRAL_BEARISH";
      case RSI_NEUTRAL: return "NEUTRAL";
      case RSI_NEUTRAL_BULLISH: return "NEUTRAL_BULLISH";
      case RSI_OVERBOUGHT: return "OVERBOUGHT";
      case RSI_OVERBOUGHT_EXTREME: return "OVERBOUGHT_EXTREME";
      case RSI_CONDITION_UNKNOWN: return "UNKNOWN";
      default: return "INVALID";
   }
}

string RSITrendToString(ENUM_RSI_TREND trend)
{
   switch(trend)
   {
      case RSI_TREND_STRONG_BEARISH: return "STRONG_BEARISH";
      case RSI_TREND_BEARISH: return "BEARISH";
      case RSI_TREND_NEUTRAL: return "NEUTRAL";
      case RSI_TREND_BULLISH: return "BULLISH";
      case RSI_TREND_STRONG_BULLISH: return "STRONG_BULLISH";
      case RSI_TREND_UNKNOWN: return "UNKNOWN";
      default: return "INVALID";
   }
}

string MomentumStateToString(ENUM_MOMENTUM_STATE state)
{
   switch(state)
   {
      case MOMENTUM_WEAKENING: return "WEAKENING";
      case MOMENTUM_STABLE: return "STABLE";
      case MOMENTUM_BUILDING: return "BUILDING";
      case MOMENTUM_ACCELERATING: return "ACCELERATING";
      case MOMENTUM_EXHAUSTION: return "EXHAUSTION";
      case MOMENTUM_UNKNOWN: return "UNKNOWN";
      default: return "INVALID";
   }
}

//+------------------------------------------------------------------+
//| RSI Momentum Analiz Motoru - MQL5 UYUMLU                       |
//+------------------------------------------------------------------+
class RSIMomentumEngine
{
private:
   // Engine parametreleri
   string                  m_symbol;          // Analiz sembolü
   int                     m_rsi_period;      // RSI periyodu
   double                  m_oversold_level;  // Aşırı satım seviyesi
   double                  m_overbought_level; // Aşırı alım seviyesi
   double                  m_extreme_oversold; // Aşırı aşırı satım
   double                  m_extreme_overbought; // Aşırı aşırı alım
   bool                    m_initialized;     // Başlatılma durumu
   
   // Divergence detection settings
   int                     m_divergence_lookback; // Divergence arama periyodu
   double                  m_min_divergence_strength; // Minimum divergence gücü
   int                     m_min_bars_between_peaks; // Peak'lar arası min bar
   
   // Historical data caching - MQL5 UYUMLU 2D ARRAY
   double                  m_rsi_history_m15[200];    // M15 RSI history
   double                  m_rsi_history_h1[200];     // H1 RSI history
   double                  m_rsi_history_h4[200];     // H4 RSI history
   double                  m_rsi_history_d1[200];     // D1 RSI history
   double                  m_rsi_history_w1[200];     // W1 RSI history
   
   double                  m_price_history_m15[200];  // M15 Price history
   double                  m_price_history_h1[200];   // H1 Price history
   double                  m_price_history_h4[200];   // H4 Price history
   double                  m_price_history_d1[200];   // D1 Price history
   double                  m_price_history_w1[200];   // W1 Price history
   
   datetime                m_time_history_m15[200];   // M15 Time history
   datetime                m_time_history_h1[200];    // H1 Time history
   datetime                m_time_history_h4[200];    // H4 Time history
   datetime                m_time_history_d1[200];    // D1 Time history
   datetime                m_time_history_w1[200];    // W1 Time history
   
   int                     m_history_size[5];         // Her TF için history boyutu
   
   // ML components
   double                  m_ml_features[25];         // ML feature vector
   double                  m_ml_weights[25];          // ML weights
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
   RSIMomentumEngine(string symbol = "", int rsi_period = 14, 
                     double oversold = 30.0, double overbought = 70.0)
   {
      m_symbol = (StringLen(symbol) > 0) ? symbol : Symbol();
      m_rsi_period = MathMax(5, MathMin(50, rsi_period));
      m_oversold_level = MathMax(10.0, MathMin(40.0, oversold));
      m_overbought_level = MathMax(60.0, MathMin(90.0, overbought));
      m_extreme_oversold = 20.0;
      m_extreme_overbought = 80.0;
      m_initialized = false;
      
      // Divergence settings
      m_divergence_lookback = 50;
      m_min_divergence_strength = 60.0;
      m_min_bars_between_peaks = 5;
      
      // Initialize timeframes
      m_timeframes[0] = PERIOD_M15;
      m_timeframes[1] = PERIOD_H1;
      m_timeframes[2] = PERIOD_H4;
      m_timeframes[3] = PERIOD_D1;
      m_timeframes[4] = PERIOD_W1;
      m_timeframe_count = 5;
      
      // Initialize arrays - MQL5 UYUMLU
      ArrayInitialize(m_rsi_history_m15, 50.0);
      ArrayInitialize(m_rsi_history_h1, 50.0);
      ArrayInitialize(m_rsi_history_h4, 50.0);
      ArrayInitialize(m_rsi_history_d1, 50.0);
      ArrayInitialize(m_rsi_history_w1, 50.0);
      
      ArrayInitialize(m_price_history_m15, 0.0);
      ArrayInitialize(m_price_history_h1, 0.0);
      ArrayInitialize(m_price_history_h4, 0.0);
      ArrayInitialize(m_price_history_d1, 0.0);
      ArrayInitialize(m_price_history_w1, 0.0);
      
      ArrayInitialize(m_time_history_m15, 0);
      ArrayInitialize(m_time_history_h1, 0);
      ArrayInitialize(m_time_history_h4, 0);
      ArrayInitialize(m_time_history_d1, 0);
      ArrayInitialize(m_time_history_w1, 0);
      
      for(int i = 0; i < 5; i++)
         m_history_size[i] = 0;
      
      ArrayInitialize(m_ml_features, 0.0);
      ArrayInitialize(m_ml_weights, 1.0);
      m_ml_trained = false;
      
      m_total_calculations = 0;
      m_successful_signals = 0;
      m_accuracy_rate = 0.0;
      m_last_calculation = 0;
      
      if(!Initialize())
      {
         Print("ERROR: RSIMomentumEngine initialization failed");
         return;
      }
      
      Print(StringFormat("RSIMomentumEngine initialized: %s, Period: %d, OS: %.1f, OB: %.1f", 
                        m_symbol, m_rsi_period, m_oversold_level, m_overbought_level));
   }
   
   ~RSIMomentumEngine()
   {
      if(m_total_calculations > 0)
      {
         Print(StringFormat("RSIMomentumEngine destroyed. Accuracy: %.2f%% (%d/%d)",
                           m_accuracy_rate, m_successful_signals, m_total_calculations));
      }
   }

private:
   //+------------------------------------------------------------------+
   //| Helper methods for array access - MQL5 UYUMLU                  |
   //+------------------------------------------------------------------+
   double GetRSIHistory(int tf_index, int bar_index)
   {
      if(bar_index < 0 || bar_index >= 200) return 50.0;
      
      switch(tf_index)
      {
         case 0: return m_rsi_history_m15[bar_index];
         case 1: return m_rsi_history_h1[bar_index];
         case 2: return m_rsi_history_h4[bar_index];
         case 3: return m_rsi_history_d1[bar_index];
         case 4: return m_rsi_history_w1[bar_index];
         default: return 50.0;
      }
   }
   
   void SetRSIHistory(int tf_index, int bar_index, double value)
   {
      if(bar_index < 0 || bar_index >= 200) return;
      
      switch(tf_index)
      {
         case 0: m_rsi_history_m15[bar_index] = value; break;
         case 1: m_rsi_history_h1[bar_index] = value; break;
         case 2: m_rsi_history_h4[bar_index] = value; break;
         case 3: m_rsi_history_d1[bar_index] = value; break;
         case 4: m_rsi_history_w1[bar_index] = value; break;
      }
   }
   
   double GetPriceHistory(int tf_index, int bar_index)
   {
      if(bar_index < 0 || bar_index >= 200) return 0.0;
      
      switch(tf_index)
      {
         case 0: return m_price_history_m15[bar_index];
         case 1: return m_price_history_h1[bar_index];
         case 2: return m_price_history_h4[bar_index];
         case 3: return m_price_history_d1[bar_index];
         case 4: return m_price_history_w1[bar_index];
         default: return 0.0;
      }
   }
   
   void SetPriceHistory(int tf_index, int bar_index, double value)
   {
      if(bar_index < 0 || bar_index >= 200) return;
      
      switch(tf_index)
      {
         case 0: m_price_history_m15[bar_index] = value; break;
         case 1: m_price_history_h1[bar_index] = value; break;
         case 2: m_price_history_h4[bar_index] = value; break;
         case 3: m_price_history_d1[bar_index] = value; break;
         case 4: m_price_history_w1[bar_index] = value; break;
      }
   }
   
   datetime GetTimeHistory(int tf_index, int bar_index)
   {
      if(bar_index < 0 || bar_index >= 200) return 0;
      
      switch(tf_index)
      {
         case 0: return m_time_history_m15[bar_index];
         case 1: return m_time_history_h1[bar_index];
         case 2: return m_time_history_h4[bar_index];
         case 3: return m_time_history_d1[bar_index];
         case 4: return m_time_history_w1[bar_index];
         default: return 0;
      }
   }
   
   void SetTimeHistory(int tf_index, int bar_index, datetime value)
   {
      if(bar_index < 0 || bar_index >= 200) return;
      
      switch(tf_index)
      {
         case 0: m_time_history_m15[bar_index] = value; break;
         case 1: m_time_history_h1[bar_index] = value; break;
         case 2: m_time_history_h4[bar_index] = value; break;
         case 3: m_time_history_d1[bar_index] = value; break;
         case 4: m_time_history_w1[bar_index] = value; break;
      }
   }

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
      
      // Load historical RSI data
      if(!LoadHistoricalRSIData())
      {
         Print("WARNING: Could not load complete historical RSI data");
         // Not critical, continue with available data
      }
      
      // Initialize ML model (basic setup)
      InitializeMLModel();
      
      m_initialized = true;
      return true;
   }
   
   bool LoadHistoricalRSIData()
   {
      bool all_success = true;
      
      for(int tf = 0; tf < m_timeframe_count; tf++)
      {
         ENUM_TIMEFRAMES timeframe = m_timeframes[tf];
         
         // Load RSI data
         double rsi_buffer[];
         ArraySetAsSeries(rsi_buffer, true);
         
         int rsi_handle = iRSI(m_symbol, timeframe, m_rsi_period, PRICE_CLOSE);
         if(rsi_handle == INVALID_HANDLE)
         {
            Print(StringFormat("ERROR: Cannot create RSI handle for TF: %d", timeframe));
            all_success = false;
            continue;
         }
         
         int copied = CopyBuffer(rsi_handle, 0, 0, 200, rsi_buffer);
         if(copied <= 0)
         {
            Print(StringFormat("WARNING: No RSI data copied for TF: %d", timeframe));
            all_success = false;
            continue;
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
         
         // Store in internal arrays - MQL5 UYUMLU
         int store_count = MathMin(copied, 200);
         for(int i = 0; i < store_count; i++)
         {
            SetRSIHistory(tf, i, rsi_buffer[i]);
            SetPriceHistory(tf, i, rates[i].close);
            SetTimeHistory(tf, i, rates[i].time);
         }
         m_history_size[tf] = store_count;
         
         IndicatorRelease(rsi_handle);
      }
      
      Print(StringFormat("RSI historical data loaded for %d timeframes", m_timeframe_count));
      return all_success;
   }
   
   void InitializeMLModel()
   {
      // Initialize basic ML weights (placeholder for real ML implementation)
      for(int i = 0; i < 25; i++)
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
   RSIMomentumInfo AnalyzeMomentum()
   {
      RSIMomentumInfo info;
      
      if(!m_initialized)
      {
         Print("ERROR: Engine not initialized");
         return info;
      }
      
      m_total_calculations++;
      info.calculation_time = TimeCurrent();
      info.symbol = m_symbol;
      
      // Get current RSI values for all timeframes
      if(!GetCurrentRSIValues(info))
      {
         Print("ERROR: Failed to get current RSI values");
         return info;
      }
      
      // Analyze RSI conditions
      AnalyzeRSIConditions(info);
      
      // Analyze RSI trends
      AnalyzeRSITrends(info);
      
      // Analyze momentum
      AnalyzeMomentumState(info);
      
      // Detect divergences
      DetectDivergences(info);
      
      // Calculate confluence
      CalculateConfluence(info);
      
      // Analyze extreme levels
      AnalyzeExtremeLevels(info);
      
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
   bool GetCurrentRSIValues(RSIMomentumInfo &info)
   {
      // MQL5 UYUMLU - Manual struct array initialization
      RSITimeframeInfo timeframes[5];
      timeframes[0].Initialize(PERIOD_M15, 50.0);
      timeframes[1].Initialize(PERIOD_H1, 50.0);
      timeframes[2].Initialize(PERIOD_H4, 50.0);
      timeframes[3].Initialize(PERIOD_D1, 50.0);
      timeframes[4].Initialize(PERIOD_W1, 50.0);
      
      bool all_success = true;
      
      for(int i = 0; i < 5; i++)
      {
         double rsi_buffer[1];
         int rsi_handle = iRSI(m_symbol, timeframes[i].timeframe, m_rsi_period, PRICE_CLOSE);
         
         if(rsi_handle == INVALID_HANDLE)
         {
            Print(StringFormat("ERROR: Cannot create RSI handle for TF: %d", timeframes[i].timeframe));
            all_success = false;
            continue;
         }
         
         int copied = CopyBuffer(rsi_handle, 0, 0, 1, rsi_buffer);
         if(copied == 1)
         {
            timeframes[i].rsi_value = rsi_buffer[0];
            
            // Set values to info struct
            switch(i)
            {
               case 0: info.rsi_m15 = rsi_buffer[0]; break;
               case 1: info.rsi_h1 = rsi_buffer[0]; break;
               case 2: info.rsi_h4 = rsi_buffer[0]; break;
               case 3: info.rsi_d1 = rsi_buffer[0]; break;
               case 4: info.rsi_w1 = rsi_buffer[0]; break;
            }
         }
         else
         {
            Print(StringFormat("WARNING: Cannot get RSI value for TF: %d", timeframes[i].timeframe));
            // Set default values
            switch(i)
            {
               case 0: info.rsi_m15 = 50.0; break;
               case 1: info.rsi_h1 = 50.0; break;
               case 2: info.rsi_h4 = 50.0; break;
               case 3: info.rsi_d1 = 50.0; break;
               case 4: info.rsi_w1 = 50.0; break;
            }
            all_success = false;
         }
         
         IndicatorRelease(rsi_handle);
      }
      
      return all_success;
   }
   
   void AnalyzeRSIConditions(RSIMomentumInfo &info)
   {
      // Analyze each timeframe condition
      info.condition_m15 = ClassifyRSICondition(info.rsi_m15);
      info.condition_h1 = ClassifyRSICondition(info.rsi_h1);
      info.condition_h4 = ClassifyRSICondition(info.rsi_h4);
      info.condition_d1 = ClassifyRSICondition(info.rsi_d1);
   }
   
   ENUM_RSI_CONDITION ClassifyRSICondition(double rsi_value)
   {
      if(rsi_value < m_extreme_oversold)
         return RSI_OVERSOLD_EXTREME;
      else if(rsi_value < m_oversold_level)
         return RSI_OVERSOLD;
      else if(rsi_value < 50.0)
         return RSI_NEUTRAL_BEARISH;
      else if(rsi_value < 55.0)
         return RSI_NEUTRAL;
      else if(rsi_value < m_overbought_level)
         return RSI_NEUTRAL_BULLISH;
      else if(rsi_value < m_extreme_overbought)
         return RSI_OVERBOUGHT;
      else
         return RSI_OVERBOUGHT_EXTREME;
   }
   
   void AnalyzeRSITrends(RSIMomentumInfo &info)
   {
      // Short term trend (M15, H1)
      info.trend_short = CalculateRSITrend(info.rsi_m15, info.rsi_h1);
      
      // Medium term trend (H1, H4)
      info.trend_medium = CalculateRSITrend(info.rsi_h1, info.rsi_h4);
      
      // Long term trend (H4, D1, W1)
      info.trend_long = CalculateRSITrend(info.rsi_h4, info.rsi_d1, info.rsi_w1);
      
      // Overall trend (weighted combination)
      info.overall_trend = CalculateOverallTrend(info);
   }
   
   ENUM_RSI_TREND CalculateRSITrend(double rsi_fast, double rsi_slow, double rsi_slower = 50.0)
   {
      double fast_weight = 0.5;
      double slow_weight = 0.3;
      double slower_weight = 0.2;
      
      if(rsi_slower == 50.0) // Only 2 values
      {
         fast_weight = 0.7;
         slow_weight = 0.3;
         slower_weight = 0.0;
      }
      
      double weighted_rsi = (rsi_fast * fast_weight) + (rsi_slow * slow_weight) + (rsi_slower * slower_weight);
      
      // Historical trend analysis
      double trend_strength = CalculateRSITrendStrength(rsi_fast, rsi_slow);
      
      if(weighted_rsi > 65.0 && trend_strength > 0.7)
         return RSI_TREND_STRONG_BULLISH;
      else if(weighted_rsi > 55.0 && trend_strength > 0.3)
         return RSI_TREND_BULLISH;
      else if(weighted_rsi < 35.0 && trend_strength < -0.7)
         return RSI_TREND_STRONG_BEARISH;
      else if(weighted_rsi < 45.0 && trend_strength < -0.3)
         return RSI_TREND_BEARISH;
      else
         return RSI_TREND_NEUTRAL;
   }
   
   double CalculateRSITrendStrength(double current_rsi, double reference_rsi)
   {
      // Simple trend strength calculation
      double diff = current_rsi - reference_rsi;
      return MathMax(-1.0, MathMin(1.0, diff / 30.0)); // Normalize to -1 to +1
   }
   
   ENUM_RSI_TREND CalculateOverallTrend(const RSIMomentumInfo &info)
   {
      // Weight different timeframe trends
      double trend_score = 0.0;
      
      trend_score += RSITrendToScore(info.trend_short) * 0.3;   // 30% weight for short term
      trend_score += RSITrendToScore(info.trend_medium) * 0.4;  // 40% weight for medium term
      trend_score += RSITrendToScore(info.trend_long) * 0.3;    // 30% weight for long term
      
      return ScoreToRSITrend(trend_score);
   }
   
   double RSITrendToScore(ENUM_RSI_TREND trend)
   {
      switch(trend)
      {
         case RSI_TREND_STRONG_BEARISH: return -2.0;
         case RSI_TREND_BEARISH: return -1.0;
         case RSI_TREND_NEUTRAL: return 0.0;
         case RSI_TREND_BULLISH: return 1.0;
         case RSI_TREND_STRONG_BULLISH: return 2.0;
         default: return 0.0;
      }
   }
   
   ENUM_RSI_TREND ScoreToRSITrend(double score)
   {
      if(score >= 1.5) return RSI_TREND_STRONG_BULLISH;
      else if(score >= 0.5) return RSI_TREND_BULLISH;
      else if(score <= -1.5) return RSI_TREND_STRONG_BEARISH;
      else if(score <= -0.5) return RSI_TREND_BEARISH;
      else return RSI_TREND_NEUTRAL;
   }
   
   void AnalyzeMomentumState(RSIMomentumInfo &info)
   {
      // Calculate momentum metrics
      info.momentum_strength = CalculateMomentumStrength(info);
      info.momentum_velocity = CalculateMomentumVelocity(info);
      info.momentum_acceleration = CalculateMomentumAcceleration(info);
      
      // Determine momentum state
      info.momentum_state = DetermineMomentumState(info);
   }
   
   double CalculateMomentumStrength(const RSIMomentumInfo &info)
   {
      // Combine multiple timeframe RSI values
      double strength = 0.0;
      
      // Distance from neutral (50)
      strength += MathAbs(info.rsi_h1 - 50.0) * 0.4;    // 40% H1
      strength += MathAbs(info.rsi_h4 - 50.0) * 0.3;    // 30% H4
      strength += MathAbs(info.rsi_d1 - 50.0) * 0.2;    // 20% D1
      strength += MathAbs(info.rsi_m15 - 50.0) * 0.1;   // 10% M15
      
      // Normalize to 0-100
      strength = MathMin(100.0, strength * 2.0);
      
      return strength;
   }
   
   double CalculateMomentumVelocity(const RSIMomentumInfo &info)
   {
      // Calculate rate of change in RSI
      double velocity = 0.0;
      
      // Get recent RSI changes (if historical data available)
      if(m_history_size[1] >= 5) // H1 data
      {
         double current_rsi = info.rsi_h1;
         double prev_rsi = GetRSIHistory(1, 1); // Previous H1 RSI
         velocity = (current_rsi - prev_rsi) * 2.0; // Scale for visibility
      }
      
      // Clamp to -100 to +100
      return MathMax(-100.0, MathMin(100.0, velocity));
   }
   
   double CalculateMomentumAcceleration(const RSIMomentumInfo &info)
   {
      // Calculate acceleration (change in velocity)
      double acceleration = 0.0;
      
      if(m_history_size[1] >= 10) // H1 data
      {
         double current_velocity = info.momentum_velocity;
         
         // Calculate previous velocity
         double prev_current = GetRSIHistory(1, 1);
         double prev_prev = GetRSIHistory(1, 2);
         double prev_velocity = (prev_current - prev_prev) * 2.0;
         
         acceleration = current_velocity - prev_velocity;
      }
      
      return acceleration;
   }
   
   ENUM_MOMENTUM_STATE DetermineMomentumState(const RSIMomentumInfo &info)
   {
      double strength = info.momentum_strength;
      double velocity = info.momentum_velocity;
      double acceleration = info.momentum_acceleration;
      
      // Extreme conditions
      if(strength > 80.0 && MathAbs(velocity) < 5.0)
         return MOMENTUM_EXHAUSTION;
      
      // Accelerating momentum
      if(MathAbs(acceleration) > 3.0 && MathAbs(velocity) > 10.0)
         return MOMENTUM_ACCELERATING;
      
      // Building momentum
      if(strength > 60.0 && MathAbs(velocity) > 5.0)
         return MOMENTUM_BUILDING;
      
      // Weakening momentum
      if(strength < 30.0 || (MathAbs(velocity) < 2.0 && strength < 50.0))
         return MOMENTUM_WEAKENING;
      
      // Default stable
      return MOMENTUM_STABLE;
   }
   
   void DetectDivergences(RSIMomentumInfo &info)
   {
      info.active_divergence_count = 0;
      info.has_bullish_divergence = false;
      info.has_bearish_divergence = false;
      info.has_hidden_divergence = false;
      
      // Detect divergences for each major timeframe
      for(int tf = 1; tf < 4; tf++) // H1, H4, D1
      {
         RSIDivergenceInfo div_info = DetectDivergenceForTimeframe(tf);
         
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
         }
      }
   }
   
   RSIDivergenceInfo DetectDivergenceForTimeframe(int tf_index)
   {
      RSIDivergenceInfo div_info;
      
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
         double price = GetPriceHistory(tf_index, i);
         double rsi = GetRSIHistory(tf_index, i);
         
         // Check for price high
         if(price > GetPriceHistory(tf_index, i-1) && price > GetPriceHistory(tf_index, i+1) &&
            price > GetPriceHistory(tf_index, i-2) && price > GetPriceHistory(tf_index, i+2))
         {
            peaks[peak_count].index = i;
            peaks[peak_count].price = price;
            peaks[peak_count].rsi = rsi;
            peaks[peak_count].is_high = true;
            peak_count++;
         }
         // Check for price low
         else if(price < GetPriceHistory(tf_index, i-1) && price < GetPriceHistory(tf_index, i+1) &&
                 price < GetPriceHistory(tf_index, i-2) && price < GetPriceHistory(tf_index, i+2))
         {
            peaks[peak_count].index = i;
            peaks[peak_count].price = price;
            peaks[peak_count].rsi = rsi;
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
            
            RSIDivergenceInfo potential_div = AnalyzePotentialDivergence(peaks[i], peaks[j], tf_index);
            
            if(potential_div.IsValid() && potential_div.strength >= m_min_divergence_strength)
            {
               potential_div.timeframe = timeframe;
               return potential_div;
            }
         }
      }
      
      return div_info;
   }
   
   RSIDivergenceInfo AnalyzePotentialDivergence(const PeakInfo &peak1, const PeakInfo &peak2, int tf_index)
   {
      RSIDivergenceInfo div_info;
      
      // Determine which peak is more recent
      bool peak1_recent = (peak1.index < peak2.index);
      PeakInfo recent = peak1_recent ? peak1 : peak2;
      PeakInfo older = peak1_recent ? peak2 : peak1;
      
      // Price and RSI differences
      double price_diff = recent.price - older.price;
      double rsi_diff = recent.rsi - older.rsi;
      
      // Divergence type classification
      if(recent.is_high) // Looking at highs
      {
         if(price_diff > 0 && rsi_diff < 0) // Higher highs, lower RSI highs
         {
            div_info.divergence_type = DIVERGENCE_REGULAR_BEARISH;
         }
         else if(price_diff < 0 && rsi_diff > 0) // Lower highs, higher RSI highs
         {
            div_info.divergence_type = DIVERGENCE_HIDDEN_BULLISH;
         }
      }
      else // Looking at lows
      {
         if(price_diff < 0 && rsi_diff > 0) // Lower lows, higher RSI lows
         {
            div_info.divergence_type = DIVERGENCE_REGULAR_BULLISH;
         }
         else if(price_diff > 0 && rsi_diff < 0) // Higher lows, lower RSI lows
         {
            div_info.divergence_type = DIVERGENCE_HIDDEN_BEARISH;
         }
      }
      
      if(div_info.divergence_type != DIVERGENCE_NONE)
      {
         div_info.active = true;
         div_info.start_time = GetTimeHistory(tf_index, older.index);
         div_info.end_time = GetTimeHistory(tf_index, recent.index);
         div_info.start_price = older.price;
         div_info.end_price = recent.price;
         div_info.start_rsi = older.rsi;
         div_info.end_rsi = recent.rsi;
         
         // Calculate strength
         div_info.strength = CalculateDivergenceStrength(price_diff, rsi_diff, recent.is_high);
         div_info.reliability = CalculateDivergenceReliability(div_info);
         
         // Calculate probabilities
         div_info.reversal_probability = CalculateReversalProbability(div_info);
         div_info.target_projection = CalculateTargetProjection(div_info);
         
         // Confirmation analysis
         div_info.confirmation_bars = recent.index; // Bars since divergence
         div_info.confirmed = (div_info.confirmation_bars >= 3 && div_info.strength >= 70.0);
      }
      
      return div_info;
   }
   
   double CalculateDivergenceStrength(double price_diff, double rsi_diff, bool is_high)
   {
      double strength = 0.0;
      
      // Base strength from difference magnitude
      double price_magnitude = MathAbs(price_diff);
      double rsi_magnitude = MathAbs(rsi_diff);
      
      // Normalize and combine
      strength = (rsi_magnitude / 30.0) * 50.0; // RSI diff component
      strength += (price_magnitude > 0) ? 30.0 : 0.0; // Price diff component
      
      // Bonus for extreme RSI levels
      if(is_high && (rsi_diff < -10.0)) strength += 20.0;
      if(!is_high && (rsi_diff > 10.0)) strength += 20.0;
      
      return MathMax(0.0, MathMin(100.0, strength));
   }
   
   double CalculateDivergenceReliability(const RSIDivergenceInfo &div_info)
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
         reliability += 10.0;
      
      return MathMax(0.0, MathMin(100.0, reliability));
   }
   
   double CalculateReversalProbability(const RSIDivergenceInfo &div_info)
   {
      double probability = div_info.reliability * 0.7; // Base from reliability
      
      // Adjust based on divergence type
      if(div_info.divergence_type == DIVERGENCE_REGULAR_BULLISH || 
         div_info.divergence_type == DIVERGENCE_REGULAR_BEARISH)
         probability *= 1.2;
      else
         probability *= 0.9; // Hidden divergences less likely to reverse
      
      // Extreme RSI levels increase reversal probability
      if(div_info.end_rsi > 75.0 || div_info.end_rsi < 25.0)
         probability *= 1.15;
      
      return MathMax(0.0, MathMin(100.0, probability));
   }
   
   double CalculateTargetProjection(const RSIDivergenceInfo &div_info)
   {
      // Simple target calculation based on price difference
      double price_range = MathAbs(div_info.end_price - div_info.start_price);
      
      // Project similar move in opposite direction
      if(div_info.divergence_type == DIVERGENCE_REGULAR_BULLISH)
         return div_info.end_price + (price_range * 0.618); // Fibonacci ratio
      else if(div_info.divergence_type == DIVERGENCE_REGULAR_BEARISH)
         return div_info.end_price - (price_range * 0.618);
      else
         return div_info.end_price; // No projection for hidden divergences
   }
   
   void CalculateConfluence(RSIMomentumInfo &info)
   {
      // Timeframe alignment calculation
      info.timeframe_alignment = 0;
      
      // Count aligned conditions - MQL5 UYUMLU
      ENUM_RSI_CONDITION conditions[4];
      conditions[0] = info.condition_m15;
      conditions[1] = info.condition_h1;
      conditions[2] = info.condition_h4;
      conditions[3] = info.condition_d1;
      
      // Bullish alignment
      int bullish_count = 0, bearish_count = 0;
      for(int i = 0; i < 4; i++)
      {
         if(conditions[i] == RSI_NEUTRAL_BULLISH || conditions[i] == RSI_OVERBOUGHT || conditions[i] == RSI_OVERBOUGHT_EXTREME)
            bullish_count++;
         else if(conditions[i] == RSI_NEUTRAL_BEARISH || conditions[i] == RSI_OVERSOLD || conditions[i] == RSI_OVERSOLD_EXTREME)
            bearish_count++;
      }
      
      info.timeframe_alignment = MathMax(bullish_count, bearish_count);
      
      // Confluence score calculation
      info.confluence_score = 0.0;
      
      // Base score from alignment
      info.confluence_score += info.timeframe_alignment * 15.0;
      
      // Trend alignment bonus
      if(info.trend_short == info.trend_medium && info.trend_medium == info.trend_long)
         info.confluence_score += 25.0;
      else if(info.trend_short == info.trend_medium || info.trend_medium == info.trend_long)
         info.confluence_score += 15.0;
      
      // Divergence bonus
      if(info.has_bullish_divergence || info.has_bearish_divergence)
         info.confluence_score += 20.0;
      if(info.has_hidden_divergence)
         info.confluence_score += 10.0;
      
      // Extreme level bonus
      if(info.extreme_oversold || info.extreme_overbought)
         info.confluence_score += 15.0;
      
      // Momentum state bonus
      if(info.momentum_state == MOMENTUM_ACCELERATING || info.momentum_state == MOMENTUM_BUILDING)
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
   
   void AnalyzeExtremeLevels(RSIMomentumInfo &info)
   {
      // Single timeframe extreme detection
      info.extreme_oversold = (info.rsi_h1 < m_extreme_oversold || info.rsi_h4 < m_extreme_oversold);
      info.extreme_overbought = (info.rsi_h1 > m_extreme_overbought || info.rsi_h4 > m_extreme_overbought);
      
      // Multi-timeframe extreme detection
      int extreme_count = 0;
      if(info.rsi_m15 < m_extreme_oversold || info.rsi_m15 > m_extreme_overbought) extreme_count++;
      if(info.rsi_h1 < m_extreme_oversold || info.rsi_h1 > m_extreme_overbought) extreme_count++;
      if(info.rsi_h4 < m_extreme_oversold || info.rsi_h4 > m_extreme_overbought) extreme_count++;
      if(info.rsi_d1 < m_extreme_oversold || info.rsi_d1 > m_extreme_overbought) extreme_count++;
      
      info.multi_tf_extreme = (extreme_count >= 2);
      
      // Calculate extreme duration (if historical data available)
      info.extreme_duration = CalculateExtremeDuration(info);
   }
   
   int CalculateExtremeDuration(const RSIMomentumInfo &info)
   {
      if(m_history_size[1] < 10) return 0; // Need H1 history
      
      int duration = 0;
      bool current_extreme = (info.rsi_h1 < m_extreme_oversold || info.rsi_h1 > m_extreme_overbought);
      
      if(current_extreme)
      {
         for(int i = 1; i < m_history_size[1] && i < 50; i++)
         {
            double historical_rsi = GetRSIHistory(1, i);
            if(historical_rsi < m_extreme_oversold || historical_rsi > m_extreme_overbought)
               duration++;
            else
               break;
         }
      }
      
      return duration;
   }
   
   void GenerateSignals(RSIMomentumInfo &info)
   {
      info.primary_signal = SIGNAL_NONE;
      info.signal_strength = SIGNAL_STRENGTH_NONE;
      info.signal_confidence = 0.0;
      info.entry_probability = 0.0;
      
      // Signal generation based on multiple factors
      double bullish_score = 0.0, bearish_score = 0.0;
      
      // RSI condition scoring
      if(info.condition_h1 == RSI_OVERSOLD || info.condition_h1 == RSI_OVERSOLD_EXTREME)
         bullish_score += 30.0;
      if(info.condition_h1 == RSI_OVERBOUGHT || info.condition_h1 == RSI_OVERBOUGHT_EXTREME)
         bearish_score += 30.0;
      
      // Divergence scoring
      if(info.has_bullish_divergence) bullish_score += 40.0;
      if(info.has_bearish_divergence) bearish_score += 40.0;
      
      // Trend scoring
      if(info.overall_trend == RSI_TREND_BULLISH || info.overall_trend == RSI_TREND_STRONG_BULLISH)
         bullish_score += 25.0;
      if(info.overall_trend == RSI_TREND_BEARISH || info.overall_trend == RSI_TREND_STRONG_BEARISH)
         bearish_score += 25.0;
      
      // Momentum scoring
      if(info.momentum_state == MOMENTUM_BUILDING || info.momentum_state == MOMENTUM_ACCELERATING)
      {
         if(info.momentum_velocity > 0) bullish_score += 20.0;
         else if(info.momentum_velocity < 0) bearish_score += 20.0;
      }
      
      // Extreme level scoring
      if(info.extreme_oversold) bullish_score += 25.0;
      if(info.extreme_overbought) bearish_score += 25.0;
      
      // Multi-timeframe extreme bonus
      if(info.multi_tf_extreme)
      {
         if(info.extreme_oversold) bullish_score += 15.0;
         if(info.extreme_overbought) bearish_score += 15.0;
      }
      
      // Determine primary signal
      if(bullish_score > bearish_score && bullish_score >= 50.0)
      {
         info.primary_signal = SIGNAL_BUY;
         info.signal_confidence = MathMin(100.0, bullish_score);
      }
      else if(bearish_score > bullish_score && bearish_score >= 50.0)
      {
         info.primary_signal = SIGNAL_SELL;
         info.signal_confidence = MathMin(100.0, bearish_score);
      }
      
      // Signal strength classification
      if(info.signal_confidence >= 90.0)
         info.signal_strength = SIGNAL_EXTREME;
      else if(info.signal_confidence >= 75.0)
         info.signal_strength = SIGNAL_VERY_STRONG;
      else if(info.signal_confidence >= 60.0)
         info.signal_strength = SIGNAL_STRONG;
      else if(info.signal_confidence >= 45.0)
         info.signal_strength = SIGNAL_MODERATE;
      else if(info.signal_confidence >= 30.0)
         info.signal_strength = SIGNAL_WEAK;
      else
         info.signal_strength = SIGNAL_VERY_WEAK;
      
      // Entry probability calculation
      info.entry_probability = info.signal_confidence * (info.confluence_score / 100.0);
   }
   
   void ExtractMLFeatures(RSIMomentumInfo &info)
   {
      // Feature 1-5: RSI values
      m_ml_features[0] = info.rsi_m15 / 100.0;
      m_ml_features[1] = info.rsi_h1 / 100.0;
      m_ml_features[2] = info.rsi_h4 / 100.0;
      m_ml_features[3] = info.rsi_d1 / 100.0;
      m_ml_features[4] = info.rsi_w1 / 100.0;
      
      // Feature 6-10: RSI conditions (normalized)
      m_ml_features[5] = (double)info.condition_h1 / 7.0;
      m_ml_features[6] = (double)info.condition_h4 / 7.0;
      m_ml_features[7] = (double)info.condition_d1 / 7.0;
      m_ml_features[8] = info.extreme_oversold ? 1.0 : 0.0;
      m_ml_features[9] = info.extreme_overbought ? 1.0 : 0.0;
      
      // Feature 11-15: Trend information
      m_ml_features[10] = (double)info.overall_trend / 5.0;
      m_ml_features[11] = (double)info.trend_short / 5.0;
      m_ml_features[12] = (double)info.trend_medium / 5.0;
      m_ml_features[13] = (double)info.trend_long / 5.0;
      m_ml_features[14] = info.timeframe_alignment / 5.0;
      
      // Feature 16-20: Momentum information
      m_ml_features[15] = info.momentum_strength / 100.0;
      m_ml_features[16] = (info.momentum_velocity + 100.0) / 200.0; // Normalize -100,+100 to 0,1
      m_ml_features[17] = (info.momentum_acceleration + 50.0) / 100.0; // Rough normalization
      m_ml_features[18] = (double)info.momentum_state / 5.0;
      m_ml_features[19] = info.confluence_score / 100.0;
      
      // Feature 21-25: Divergence and advanced features
      m_ml_features[20] = info.has_bullish_divergence ? 1.0 : 0.0;
      m_ml_features[21] = info.has_bearish_divergence ? 1.0 : 0.0;
      m_ml_features[22] = info.has_hidden_divergence ? 1.0 : 0.0;
      m_ml_features[23] = info.multi_tf_extreme ? 1.0 : 0.0;
      m_ml_features[24] = info.extreme_duration / 20.0; // Normalize to reasonable range
   }
   
   void CalculateMLPredictions(RSIMomentumInfo &info)
   {
      if(!m_ml_trained) return;
      
      // Simple neural network prediction (placeholder)
      double ml_score = 0.0;
      for(int i = 0; i < 25; i++)
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
      
      // Pattern recognition score
      info.pattern_recognition_score = CalculatePatternRecognitionScore(info);
   }
   
   double CalculatePatternRecognitionScore(const RSIMomentumInfo &info)
   {
      double pattern_score = 50.0; // Base score
      
      // Classic RSI patterns
      if(info.has_bullish_divergence && info.extreme_oversold)
         pattern_score += 30.0; // Classic bullish divergence pattern
      
      if(info.has_bearish_divergence && info.extreme_overbought)
         pattern_score += 30.0; // Classic bearish divergence pattern
      
      // Multi-timeframe confirmation
      if(info.timeframe_alignment >= 3)
         pattern_score += 20.0;
      
      // Momentum exhaustion patterns
      if(info.momentum_state == MOMENTUM_EXHAUSTION && info.multi_tf_extreme)
         pattern_score += 25.0;
      
      return MathMax(0.0, MathMin(100.0, pattern_score));
   }
   
   void AssessRisk(RSIMomentumInfo &info)
   {
      // Base risk assessment
      info.risk_level = RISK_MEDIUM;
      info.volatility_factor = 1.0;
      info.counter_trend_risk = false;
      
      // Adjust risk based on conditions
      if(info.multi_tf_extreme)
      {
         info.risk_level = RISK_HIGH;
         info.volatility_factor = 1.5;
      }
      
      if(info.momentum_state == MOMENTUM_EXHAUSTION)
      {
         info.risk_level = RISK_VERY_HIGH;
         info.volatility_factor = 2.0;
      }
      
      // Counter-trend risk assessment
      if((info.primary_signal == SIGNAL_BUY && info.overall_trend == RSI_TREND_BEARISH) ||
         (info.primary_signal == SIGNAL_SELL && info.overall_trend == RSI_TREND_BULLISH))
      {
         info.counter_trend_risk = true;
         if(info.risk_level < RISK_HIGH)
            info.risk_level = RISK_HIGH;
      }
      
      // Confluence reduces risk
      if(info.confluence_level >= CONFLUENCE_STRONG)
      {
         if(info.risk_level == RISK_VERY_HIGH) info.risk_level = RISK_HIGH;
         else if(info.risk_level == RISK_HIGH) info.risk_level = RISK_MEDIUM;
         else if(info.risk_level == RISK_MEDIUM) info.risk_level = RISK_LOW;
      }
   }

public:
   //+------------------------------------------------------------------+
   //| Public Interface Methods                                         |
   //+------------------------------------------------------------------+
   bool IsInitialized() const { return m_initialized; }
   string GetSymbol() const { return m_symbol; }
   int GetRSIPeriod() const { return m_rsi_period; }
   double GetOversoldLevel() const { return m_oversold_level; }
   double GetOverboughtLevel() const { return m_overbought_level; }
   
   // Configuration methods
   void SetRSILevels(double oversold, double overbought, double extreme_os, double extreme_ob)
   {
      m_oversold_level = MathMax(10.0, MathMin(40.0, oversold));
      m_overbought_level = MathMax(60.0, MathMin(90.0, overbought));
      m_extreme_oversold = MathMax(5.0, MathMin(30.0, extreme_os));
      m_extreme_overbought = MathMax(70.0, MathMin(95.0, extreme_ob));
   }
   
   void SetDivergenceSettings(int lookback, double min_strength, int min_bars)
   {
      m_divergence_lookback = MathMax(20, MathMin(100, lookback));
      m_min_divergence_strength = MathMax(30.0, MathMin(90.0, min_strength));
      m_min_bars_between_peaks = MathMax(3, MathMin(20, min_bars));
   }
   
   // Quick access methods
   double GetCurrentRSI(ENUM_TIMEFRAMES timeframe = PERIOD_H1)
   {
      RSIMomentumInfo info = AnalyzeMomentum();
      
      switch(timeframe)
      {
         case PERIOD_M15: return info.rsi_m15;
         case PERIOD_H1: return info.rsi_h1;
         case PERIOD_H4: return info.rsi_h4;
         case PERIOD_D1: return info.rsi_d1;
         case PERIOD_W1: return info.rsi_w1;
         default: return info.rsi_h1;
      }
   }
   
   ENUM_RSI_CONDITION GetRSICondition(ENUM_TIMEFRAMES timeframe = PERIOD_H1)
   {
      RSIMomentumInfo info = AnalyzeMomentum();
      
      switch(timeframe)
      {
         case PERIOD_M15: return info.condition_m15;
         case PERIOD_H1: return info.condition_h1;
         case PERIOD_H4: return info.condition_h4;
         case PERIOD_D1: return info.condition_d1;
         default: return info.condition_h1;
      }
   }
   
   bool IsOversold(ENUM_TIMEFRAMES timeframe = PERIOD_H1)
   {
      ENUM_RSI_CONDITION condition = GetRSICondition(timeframe);
      return (condition == RSI_OVERSOLD || condition == RSI_OVERSOLD_EXTREME);
   }
   
   bool IsOverbought(ENUM_TIMEFRAMES timeframe = PERIOD_H1)
   {
      ENUM_RSI_CONDITION condition = GetRSICondition(timeframe);
      return (condition == RSI_OVERBOUGHT || condition == RSI_OVERBOUGHT_EXTREME);
   }
   
   bool HasBullishDivergence()
   {
      RSIMomentumInfo info = AnalyzeMomentum();
      return info.has_bullish_divergence;
   }
   
   bool HasBearishDivergence()
   {
      RSIMomentumInfo info = AnalyzeMomentum();
      return info.has_bearish_divergence;
   }
   
   bool IsMultiTimeframeExtreme()
   {
      RSIMomentumInfo info = AnalyzeMomentum();
      return info.multi_tf_extreme;
   }
   
   ENUM_RSI_TREND GetOverallTrend()
   {
      RSIMomentumInfo info = AnalyzeMomentum();
      return info.overall_trend;
   }
   
   ENUM_MOMENTUM_STATE GetMomentumState()
   {
      RSIMomentumInfo info = AnalyzeMomentum();
      return info.momentum_state;
   }
   
   double GetConfluenceScore()
   {
      RSIMomentumInfo info = AnalyzeMomentum();
      return info.confluence_score;
   }
   
   // ML and advanced features
   bool GetMLFeatures(double &features[])
   {
      if(!m_initialized) return false;
      
      RSIMomentumInfo info = AnalyzeMomentum(); // This updates ML features
      ArrayResize(features, 25);
      ArrayCopy(features, m_ml_features);
      return true;
   }
   
   bool TrainMLModel(const string historical_data_file = "")
   {
      // Placeholder for ML training
      m_ml_trained = true;
      
      // Initialize random weights (placeholder)
      for(int i = 0; i < 25; i++)
         m_ml_weights[i] = (MathRand() / 32767.0) * 2.0 - 1.0;
      
      Print("RSI ML model training completed (placeholder implementation)");
      return true;
   }
   
   // Performance metrics
   double GetAccuracyRate() const { return m_accuracy_rate; }
   int GetTotalCalculations() const { return m_total_calculations; }
   datetime GetLastCalculationTime() const { return m_last_calculation; }
   
   // Update methods
   bool RefreshHistoricalData()
   {
      return LoadHistoricalRSIData();
   }
   
   void UpdatePerformance(bool signal_success)
   {
      if(signal_success)
         m_successful_signals++;
      
      if(m_total_calculations > 0)
         m_accuracy_rate = (m_successful_signals * 100.0) / m_total_calculations;
   }
   
   // Chart visualization helpers
   bool DrawRSILevels(color oversold_color = clrGreen, color overbought_color = clrRed)
   {
      // This would draw RSI levels on chart
      // Implementation depends on visualization requirements
      return true;
   }
   
   bool DrawDivergenceLines(const RSIMomentumInfo &info, color bullish_color = clrBlue, color bearish_color = clrRed)
   {
      // This would draw divergence lines on chart
      // Implementation depends on visualization requirements
      return true;
   }
};

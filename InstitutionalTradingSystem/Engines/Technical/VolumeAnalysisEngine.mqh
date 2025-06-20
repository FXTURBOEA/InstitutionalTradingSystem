﻿//+------------------------------------------------------------------+
//| VolumeAnalysisEngine.mqh - Gelişmiş Volume Analiz Motoru      |
//| ISignalProvider Uyumlu - Institutional Footprint Detection     |
//| Volume Spike, OBV, Volume Profile, Break Confirmation          |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/Complete_Enum_Types.mqh"
#include "../../Core/ISignalProvider.mqh"

//+------------------------------------------------------------------+
//| Volume Spike Bilgi Yapısı                                      |
//+------------------------------------------------------------------+
struct VolumeSpikeInfo
{
   // Spike detection
   bool                  spike_detected;     // Spike tespit edildi mi?
   double                spike_ratio;        // Spike oranı (ortalamaya göre)
   double                current_volume;     // Mevcut volume
   double                average_volume;     // Ortalama volume
   double                volume_percentile;  // Volume yüzdelik dilimi
   
   // Spike classification
   ENUM_VOLUME_STATE     spike_intensity;    // Spike yoğunluğu
   bool                  institutional_spike; // Institutional spike mi?
   bool                  retail_spike;       // Retail spike mi?
   bool                  news_related;       // Haber ilişkili mi?
   
   // Direction analysis
   bool                  buying_spike;       // Alım spike'ı
   bool                  selling_spike;      // Satım spike'ı
   double                buying_pressure;    // Alım baskısı (0-100)
   double                selling_pressure;   // Satım baskısı (0-100)
   
   // Timing analysis
   datetime              spike_start_time;   // Spike başlangıç zamanı
   datetime              spike_peak_time;    // Spike zirve zamanı
   int                   spike_duration_bars; // Spike süresi (bar)
   bool                  spike_ongoing;      // Spike devam ediyor mu?
   
   // Impact analysis
   double                price_impact;       // Fiyat etkisi (%)
   double                momentum_change;    // Momentum değişimi
   bool                  trend_acceleration; // Trend hızlanması
   bool                  reversal_potential; // Dönüş potansiyeli
   
   VolumeSpikeInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      spike_detected = false;
      spike_ratio = 1.0;
      current_volume = average_volume = 0.0;
      volume_percentile = 50.0;
      
      spike_intensity = VOLUME_NORMAL;
      institutional_spike = retail_spike = news_related = false;
      
      buying_spike = selling_spike = false;
      buying_pressure = selling_pressure = 50.0;
      
      spike_start_time = spike_peak_time = 0;
      spike_duration_bars = 0;
      spike_ongoing = false;
      
      price_impact = momentum_change = 0.0;
      trend_acceleration = reversal_potential = false;
   }
};

//+------------------------------------------------------------------+
//| Volume Profile Bilgi Yapısı                                    |
//+------------------------------------------------------------------+
struct VolumeProfileInfo
{
   // Profile metrics
   double                max_volume_price;    // En yüksek volume fiyatı (POC)
   double                value_area_high;     // Value area yüksek
   double                value_area_low;      // Value area alçak
   double                value_area_percentage; // Value area yüzdesi
   
   // Distribution analysis
   ENUM_VOLUME_PROFILE_TYPE profile_type;    // Profile türü
   double                skewness;           // Çarpıklık
   double                kurtosis;           // Basıklık
   double                balance_point;      // Denge noktası
   
   // Support/Resistance from volume
   double                volume_resistance[5]; // Volume dirençleri
   double                volume_support[5];    // Volume destekleri
   int                   resistance_count;     // Direnç sayısı
   int                   support_count;        // Destek sayısı
   
   // Current position analysis
   bool                  above_poc;          // POC üstünde mi?
   bool                  in_value_area;      // Value area içinde mi?
   double                distance_to_poc;    // POC'a mesafe
   double                poc_strength;       // POC gücü (0-100)
   
   // Institutional levels
   double                institutional_levels[10]; // Institutional seviyeler
   int                   institutional_count;      // Institutional seviye sayısı
   bool                  near_institutional_level; // Institutional seviyeye yakın
   
   VolumeProfileInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      max_volume_price = value_area_high = value_area_low = 0.0;
      value_area_percentage = 70.0;
      
      profile_type = VOLUME_PROFILE_NORMAL;
      skewness = kurtosis = 0.0;
      balance_point = 0.0;
      
      ArrayInitialize(volume_resistance, 0.0);
      ArrayInitialize(volume_support, 0.0);
      resistance_count = support_count = 0;
      
      above_poc = in_value_area = false;
      distance_to_poc = 0.0;
      poc_strength = 0.0;
      
      ArrayInitialize(institutional_levels, 0.0);
      institutional_count = 0;
      near_institutional_level = false;
   }
};

//+------------------------------------------------------------------+
//| OBV Analiz Bilgi Yapısı                                        |
//+------------------------------------------------------------------+
struct OBVAnalysisInfo
{
   // OBV values
   double                obv_current;        // Mevcut OBV
   double                obv_sma;            // OBV SMA
   double                obv_ema;            // OBV EMA
   double                obv_slope;          // OBV eğimi
   
   // OBV trend
   ENUM_TREND_DIRECTION  obv_trend;          // OBV trendi
   ENUM_TREND_STRENGTH   obv_strength;       // OBV trend gücü
   bool                  obv_rising;         // OBV yükseliyor
   bool                  obv_falling;        // OBV düşüyor
   
   // Divergence analysis
   bool                  bullish_divergence; // Boğa divergence
   bool                  bearish_divergence; // Ayı divergence
   bool                  hidden_divergence;  // Gizli divergence
   double                divergence_strength; // Divergence gücü
   
   // Volume-Price relationship
   double                correlation_coefficient; // Korelasyon katsayısı
   bool                  volume_leads_price;      // Volume fiyatı yönlendiriyor
   bool                  price_leads_volume;      // Fiyat volume'u yönlendiriyor
   double                lead_lag_strength;       // Yönlendirme gücü
   
   // Momentum analysis
   double                obv_momentum;       // OBV momentumu
   double                momentum_acceleration; // Momentum ivmesi
   bool                  momentum_exhaustion;   // Momentum tükenmesi
   
   OBVAnalysisInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      obv_current = obv_sma = obv_ema = obv_slope = 0.0;
      
      obv_trend = TREND_UNDEFINED;
      obv_strength = TREND_STRENGTH_NONE;
      obv_rising = obv_falling = false;
      
      bullish_divergence = bearish_divergence = hidden_divergence = false;
      divergence_strength = 0.0;
      
      correlation_coefficient = 0.0;
      volume_leads_price = price_leads_volume = false;
      lead_lag_strength = 0.0;
      
      obv_momentum = momentum_acceleration = 0.0;
      momentum_exhaustion = false;
   }
};

//+------------------------------------------------------------------+
//| Ana Volume Analiz Bilgi Yapısı                                 |
//+------------------------------------------------------------------+
struct VolumeAnalysisInfo
{
   // Temel bilgiler
   datetime              calculation_time;   // Hesaplama zamanı
   string                symbol;             // Sembol
   ENUM_TIMEFRAMES       timeframe;          // Zaman çerçevesi
   double                current_price;      // Mevcut fiyat
   
   // Volume metrics
   double                current_volume;     // Mevcut volume
   double                volume_sma;         // Volume SMA
   double                volume_ema;         // Volume EMA
   double                volume_std;         // Volume standart sapması
   double                relative_volume;    // Göreceli volume
   
   // Volume analysis components
   VolumeSpikeInfo       spike_analysis;     // Spike analizi
   VolumeProfileInfo     profile_analysis;   // Profile analizi
   OBVAnalysisInfo       obv_analysis;       // OBV analizi
   
   // Institutional analysis
   ENUM_INSTITUTIONAL_ACTIVITY institutional_activity; // Institutional aktivite
   double                institutional_strength; // Institutional güç (0-100)
   bool                  dark_pool_activity;     // Dark pool aktivitesi
   bool                  algorithmic_activity;   // Algoritmik aktivite
   double                smart_money_flow;       // Smart money akışı
   
   // Break confirmation
   ENUM_VOLUME_CONFIRMATION breakout_confirmation; // Kırılım onayı
   ENUM_VOLUME_CONFIRMATION breakdown_confirmation; // Çöküş onayı
   bool                  volume_breakout;          // Volume kırılımı
   bool                  volume_exhaustion;        // Volume tükenmesi
   double                breakout_strength;        // Kırılım gücü
   
   // Multi-timeframe volume
   double                volume_h1_ratio;     // H1 volume oranı
   double                volume_h4_ratio;     // H4 volume oranı
   double                volume_d1_ratio;     // D1 volume oranı
   bool                  multi_tf_confirmation; // Çoklu TF onayı
   
   // Volume-based signals
   ENUM_SIGNAL_TYPE      volume_signal;       // Volume sinyali
   ENUM_SIGNAL_STRENGTH  signal_strength;     // Sinyal gücü
   double                signal_confidence;   // Sinyal güveni
   double                entry_probability;   // Giriş olasılığı
   
   // ML predictions
   double                ml_volume_score;     // ML volume skoru
   double                accumulation_prob;   // Birikim olasılığı
   double                distribution_prob;   // Dağıtım olasılığı
   double                manipulation_prob;   // Manipülasyon olasılığı
   
   // Risk assessment
   ENUM_RISK_LEVEL       volume_risk;         // Volume riski
   double                liquidity_factor;    // Likidite faktörü
   bool                  unusual_activity;    // Olağandışı aktivite
   
   // Constructor
   VolumeAnalysisInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      calculation_time = 0;
      symbol = "";
      timeframe = PERIOD_H1;
      current_price = 0.0;
      
      current_volume = volume_sma = volume_ema = volume_std = 0.0;
      relative_volume = 1.0;
      
      spike_analysis.Reset();
      profile_analysis.Reset();
      obv_analysis.Reset();
      
      institutional_activity = INSTITUTIONAL_NONE;
      institutional_strength = 0.0;
      dark_pool_activity = algorithmic_activity = false;
      smart_money_flow = 0.0;
      
      breakout_confirmation = breakdown_confirmation = VOLUME_CONF_NONE;
      volume_breakout = volume_exhaustion = false;
      breakout_strength = 0.0;
      
      volume_h1_ratio = volume_h4_ratio = volume_d1_ratio = 1.0;
      multi_tf_confirmation = false;
      
      volume_signal = SIGNAL_NONE;
      signal_strength = SIGNAL_STRENGTH_NONE;
      signal_confidence = entry_probability = 0.0;
      
      ml_volume_score = 50.0;
      accumulation_prob = distribution_prob = manipulation_prob = 0.0;
      
      volume_risk = RISK_MEDIUM;
      liquidity_factor = 1.0;
      unusual_activity = false;
   }
   
   bool IsValid() const
   {
      return (calculation_time > 0 && StringLen(symbol) > 0 && current_volume >= 0.0);
   }
   
   string ToString() const
   {
      return StringFormat("Volume: %.0f | Relative: %.2f | Spike: %s | Institution: %s | Signal: %s",
                         current_volume, relative_volume,
                         (spike_analysis.spike_detected ? "YES" : "NO"),
                         (institutional_activity != INSTITUTIONAL_NONE ? "ACTIVE" : "NONE"),
                         SignalTypeToString(volume_signal));
   }
};

//+------------------------------------------------------------------+
//| Helper Functions                                                 |
//+------------------------------------------------------------------+
string InstitutionalActivityToString(ENUM_INSTITUTIONAL_ACTIVITY activity)
{
   switch(activity)
   {
      case INSTITUTIONAL_ACCUMULATION: return "ACCUMULATION";
      case INSTITUTIONAL_DISTRIBUTION: return "DISTRIBUTION";
      case INSTITUTIONAL_ABSORPTION: return "ABSORPTION";
      case INSTITUTIONAL_MANIPULATION: return "MANIPULATION";
      case INSTITUTIONAL_TESTING: return "TESTING";
      case INSTITUTIONAL_BREAKOUT: return "BREAKOUT";
      case INSTITUTIONAL_NONE: return "NONE";
      default: return "UNKNOWN";
   }
}

string VolumeConfirmationToString(ENUM_VOLUME_CONFIRMATION confirmation)
{
   switch(confirmation)
   {
      case VOLUME_CONF_WEAK: return "WEAK";
      case VOLUME_CONF_MODERATE: return "MODERATE";
      case VOLUME_CONF_STRONG: return "STRONG";
      case VOLUME_CONF_EXTREME: return "EXTREME";
      case VOLUME_CONF_NONE: return "NONE";
      default: return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Volume Analiz Motoru                                            |
//+------------------------------------------------------------------+
class VolumeAnalysisEngine
{
private:
   // Engine parametreleri
   string                m_symbol;           // Analiz sembolü
   ENUM_TIMEFRAMES       m_timeframe;        // Ana zaman çerçevesi
   bool                  m_initialized;      // Başlatılma durumu
   
   // Volume analysis settings
   int                   m_volume_sma_period; // Volume SMA periyodu
   int                   m_volume_ema_period; // Volume EMA periyodu
   double                m_spike_threshold;   // Spike eşiği (çarpan)
   double                m_institutional_threshold; // Institutional eşiği
   
   // OBV settings
   int                   m_obv_sma_period;   // OBV SMA periyodu
   int                   m_obv_ema_period;   // OBV EMA periyodu
   
   // Historical data
   double                m_volume_history[500]; // Volume geçmişi
   double                m_price_history[500];  // Fiyat geçmişi
   double                m_obv_history[500];    // OBV geçmişi
   datetime              m_time_history[500];   // Zaman geçmişi
   int                   m_history_size;        // Geçmiş boyutu
   
   // Statistical data
   double                m_volume_mean;         // Volume ortalaması
   double                m_volume_std_dev;      // Volume standart sapması
   double                m_volume_percentiles[101]; // Volume yüzdelik dilimleri
   
   // ML components
   double                m_ml_features[25];     // ML özellik vektörü
   double                m_ml_weights[25];      // ML ağırlıkları
   bool                  m_ml_trained;          // ML eğitilmiş mi?
   
   // Performance tracking
   int                   m_total_calculations;  // Toplam hesaplama
   int                   m_successful_signals;  // Başarılı sinyal
   double                m_accuracy_rate;       // Doğruluk oranı
   datetime              m_last_calculation;    // Son hesaplama zamanı

public:
   //+------------------------------------------------------------------+
   //| Constructor & Destructor                                         |
   //+------------------------------------------------------------------+
   VolumeAnalysisEngine(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_H1)
   {
      m_symbol = (StringLen(symbol) > 0) ? symbol : Symbol();
      m_timeframe = timeframe;
      m_initialized = false;
      
      // Default settings
      m_volume_sma_period = 20;
      m_volume_ema_period = 14;
      m_spike_threshold = 2.0; // 2x ortalama
      m_institutional_threshold = 3.0; // 3x ortalama
      
      m_obv_sma_period = 14;
      m_obv_ema_period = 21;
      
      m_history_size = 0;
      m_volume_mean = m_volume_std_dev = 0.0;
      
      ArrayInitialize(m_volume_history, 0.0);
      ArrayInitialize(m_price_history, 0.0);
      ArrayInitialize(m_obv_history, 0.0);
      ArrayInitialize(m_time_history, 0);
      ArrayInitialize(m_volume_percentiles, 0.0);
      
      ArrayInitialize(m_ml_features, 0.0);
      ArrayInitialize(m_ml_weights, 1.0);
      m_ml_trained = false;
      
      m_total_calculations = 0;
      m_successful_signals = 0;
      m_accuracy_rate = 0.0;
      m_last_calculation = 0;
      
      if(!Initialize())
      {
         Print("ERROR: VolumeAnalysisEngine initialization failed");
         return;
      }
      
      Print(StringFormat("VolumeAnalysisEngine initialized: %s, TF: %d", m_symbol, m_timeframe));
   }
   
   ~VolumeAnalysisEngine()
   {
      if(m_total_calculations > 0)
      {
         Print(StringFormat("VolumeAnalysisEngine destroyed. Accuracy: %.2f%% (%d/%d)",
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
      
      // Load historical data
      if(!LoadHistoricalVolumeData())
      {
         Print("ERROR: Failed to load historical volume data");
         return false;
      }
      
      // Calculate statistics
      if(!CalculateVolumeStatistics())
      {
         Print("ERROR: Failed to calculate volume statistics");
         return false;
      }
      
      // Initialize ML model
      InitializeMLModel();
      
      m_initialized = true;
      return true;
   }
   
   bool LoadHistoricalVolumeData()
   {
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      
      int copied = CopyRates(m_symbol, m_timeframe, 0, 500, rates);
      if(copied <= 0)
      {
         Print("ERROR: Cannot load historical data");
         return false;
      }
      
      // Store in internal arrays
      m_history_size = MathMin(copied, 500);
      for(int i = 0; i < m_history_size; i++)
      {
         m_volume_history[i] = (double)rates[i].tick_volume; // Use tick volume
         m_price_history[i] = rates[i].close;
         m_time_history[i] = rates[i].time;
      }
      
      // Calculate OBV history
      CalculateOBVHistory();
      
      Print(StringFormat("Loaded %d volume data points", m_history_size));
      return true;
   }
   
   void CalculateOBVHistory()
   {
      if(m_history_size < 2) return;
      
      m_obv_history[m_history_size-1] = m_volume_history[m_history_size-1]; // First OBV value
      
      for(int i = m_history_size-2; i >= 0; i--)
      {
         if(m_price_history[i] > m_price_history[i+1])
            m_obv_history[i] = m_obv_history[i+1] + m_volume_history[i];
         else if(m_price_history[i] < m_price_history[i+1])
            m_obv_history[i] = m_obv_history[i+1] - m_volume_history[i];
         else
            m_obv_history[i] = m_obv_history[i+1];
      }
   }
   
   bool CalculateVolumeStatistics()
   {
      if(m_history_size < 20)
      {
         Print("ERROR: Insufficient data for statistics");
         return false;
      }
      
      // Calculate mean
      double sum = 0.0;
      for(int i = 0; i < m_history_size; i++)
      {
         sum += m_volume_history[i];
      }
      m_volume_mean = sum / m_history_size;
      
      // Calculate standard deviation
      double variance_sum = 0.0;
      for(int i = 0; i < m_history_size; i++)
      {
         double diff = m_volume_history[i] - m_volume_mean;
         variance_sum += diff * diff;
      }
      m_volume_std_dev = MathSqrt(variance_sum / (m_history_size - 1));
      
      // Calculate percentiles
      CalculateVolumePercentiles();
      
      return true;
   }
   
   void CalculateVolumePercentiles()
   {
      // Sort volume data
      double sorted_volume[];
      ArrayResize(sorted_volume, m_history_size);
      ArrayCopy(sorted_volume, m_volume_history, 0, 0, m_history_size);
      ArraySort(sorted_volume);
      
      // Calculate percentiles
      for(int p = 0; p <= 100; p++)
      {
         double position = p * (m_history_size - 1) / 100.0;
         int lower_index = (int)MathFloor(position);
         int upper_index = (int)MathCeil(position);
         
         if(lower_index == upper_index)
         {
            m_volume_percentiles[p] = sorted_volume[lower_index];
         }
         else
         {
            double weight = position - lower_index;
            m_volume_percentiles[p] = sorted_volume[lower_index] * (1 - weight) + 
                                     sorted_volume[upper_index] * weight;
         }
      }
   }
   
   void InitializeMLModel()
   {
      // Initialize basic ML weights (placeholder)
      for(int i = 0; i < 25; i++)
      {
         m_ml_weights[i] = (MathRand() / 32767.0) * 2.0 - 1.0;
      }
      
      m_ml_trained = false;
   }

public:
   //+------------------------------------------------------------------+
   //| Ana Analiz Metodları                                            |
   //+------------------------------------------------------------------+
   VolumeAnalysisInfo AnalyzeVolume()
   {
      VolumeAnalysisInfo info;
      
      if(!m_initialized)
      {
         Print("ERROR: Engine not initialized");
         return info;
      }
      
      m_total_calculations++;
      info.calculation_time = TimeCurrent();
      info.symbol = m_symbol;
      info.timeframe = m_timeframe;
      
      // Get current data
      if(!GetCurrentVolumeData(info))
      {
         Print("ERROR: Failed to get current volume data");
         return info;
      }
      
      // Volume spike analysis
      AnalyzeVolumeSpikes(info);
      
      // Volume profile analysis
      AnalyzeVolumeProfile(info);
      
      // OBV analysis
      AnalyzeOBV(info);
      
      // Institutional analysis
      AnalyzeInstitutionalActivity(info);
      
      // Break confirmation
      AnalyzeBreakConfirmation(info);
      
      // Multi-timeframe analysis
      AnalyzeMultiTimeframeVolume(info);
      
      // Generate signals
      GenerateVolumeSignals(info);
      
      // Extract ML features
      ExtractMLFeatures(info);
      
      // ML predictions
      if(m_ml_trained)
         CalculateMLPredictions(info);
      
      // Risk assessment
      AssessVolumeRisk(info);
      
      m_last_calculation = TimeCurrent();
      
      return info;
   }

private:
   bool GetCurrentVolumeData(VolumeAnalysisInfo &info)
   {
      // Get current volume
      MqlRates rates[1];
      if(CopyRates(m_symbol, m_timeframe, 0, 1, rates) != 1)
      {
         Print("ERROR: Cannot get current volume");
         return false;
      }
      
      info.current_volume = (double)rates[0].tick_volume;
      info.current_price = rates[0].close;
      
      // Calculate volume averages
      if(m_history_size >= m_volume_sma_period)
      {
         double sum = info.current_volume;
         for(int i = 1; i < m_volume_sma_period && i < m_history_size; i++)
         {
            sum += m_volume_history[i];
         }
         info.volume_sma = sum / m_volume_sma_period;
      }
      
      // Calculate volume EMA
      if(m_history_size >= m_volume_ema_period)
      {
         double alpha = 2.0 / (m_volume_ema_period + 1);
         info.volume_ema = m_volume_history[1]; // Previous EMA
         info.volume_ema = alpha * info.current_volume + (1 - alpha) * info.volume_ema;
      }
      
      // Calculate relative volume
      if(info.volume_sma > 0)
         info.relative_volume = info.current_volume / info.volume_sma;
      
      // Volume statistics
      info.volume_std = m_volume_std_dev;
      
      return true;
   }
   
   void AnalyzeVolumeSpikes(VolumeAnalysisInfo &info)
   {
      VolumeSpikeInfo spike = info.spike_analysis;
      
      spike.current_volume = info.current_volume;
      spike.average_volume = info.volume_sma;
      
      if(spike.average_volume > 0)
      {
         spike.spike_ratio = spike.current_volume / spike.average_volume;
         spike.spike_detected = (spike.spike_ratio >= m_spike_threshold);
      }
      
      // Calculate volume percentile
      spike.volume_percentile = CalculateCurrentVolumePercentile(info.current_volume);
      
      // Classify spike intensity
      if(spike.spike_ratio >= 5.0)
         spike.spike_intensity = VOLUME_SPIKE;
      else if(spike.spike_ratio >= 3.0)
         spike.spike_intensity = VOLUME_HIGH;
      else if(spike.spike_ratio >= 1.5)
         spike.spike_intensity = VOLUME_NORMAL;
      else
         spike.spike_intensity = VOLUME_LOW;
      
      // Institutional vs retail classification
      spike.institutional_spike = (spike.spike_ratio >= m_institutional_threshold);
      spike.retail_spike = (spike.spike_detected && !spike.institutional_spike);
      
      // Direction analysis
      AnalyzeSpikeDirection(spike, info);
      
      // Timing analysis
      AnalyzeSpikeTiming(spike);
      
      // Impact analysis
      AnalyzeSpikeImpact(spike, info);
   }
   
   double CalculateCurrentVolumePercentile(double volume)
   {
      if(volume <= m_volume_percentiles[0]) return 0.0;
      if(volume >= m_volume_percentiles[100]) return 100.0;
      
      for(int i = 0; i < 100; i++)
      {
         if(volume >= m_volume_percentiles[i] && volume <= m_volume_percentiles[i+1])
         {
            double weight = (volume - m_volume_percentiles[i]) / 
                           (m_volume_percentiles[i+1] - m_volume_percentiles[i]);
            return i + weight;
         }
      }
      
      return 50.0; // Fallback
   }
   
   void AnalyzeSpikeDirection(VolumeSpikeInfo &spike, const VolumeAnalysisInfo &info)
   {
      if(!spike.spike_detected) return;
      
      // Simple direction analysis based on price movement
      if(m_history_size >= 2)
      {
         double price_change = info.current_price - m_price_history[1];
         double price_change_pct = (m_price_history[1] > 0) ? (price_change / m_price_history[1] * 100.0) : 0.0;
         
         if(price_change_pct > 0.1) // Positive price movement
         {
            spike.buying_spike = true;
            spike.buying_pressure = 60.0 + MathMin(40.0, price_change_pct * 10.0);
            spike.selling_pressure = 100.0 - spike.buying_pressure;
         }
         else if(price_change_pct < -0.1) // Negative price movement
         {
            spike.selling_spike = true;
            spike.selling_pressure = 60.0 + MathMin(40.0, MathAbs(price_change_pct) * 10.0);
            spike.buying_pressure = 100.0 - spike.selling_pressure;
         }
         else // Neutral movement
         {
            spike.buying_pressure = spike.selling_pressure = 50.0;
         }
      }
   }
   
   void AnalyzeSpikeTiming(VolumeSpikeInfo &spike)
   {
      if(!spike.spike_detected) return;
      
      // Simplified timing analysis
      spike.spike_start_time = TimeCurrent();
      spike.spike_peak_time = TimeCurrent();
      spike.spike_duration_bars = 1;
      spike.spike_ongoing = true;
      
      // In real implementation, this would track spike progression over multiple bars
   }
   
   void AnalyzeSpikeImpact(VolumeSpikeInfo &spike, const VolumeAnalysisInfo &info)
   {
      if(!spike.spike_detected) return;
      
      // Calculate price impact
      if(m_history_size >= 2)
      {
         double price_change = info.current_price - m_price_history[1];
         spike.price_impact = (m_price_history[1] > 0) ? (price_change / m_price_history[1] * 100.0) : 0.0;
      }
      
      // Momentum change analysis
      if(m_history_size >= 5)
      {
         double recent_momentum = (info.current_price - m_price_history[3]) / m_price_history[3];
         double older_momentum = (m_price_history[3] - m_price_history[6]) / m_price_history[6];
         spike.momentum_change = (recent_momentum - older_momentum) * 100.0;
      }
      
      // Trend acceleration and reversal potential
      spike.trend_acceleration = (MathAbs(spike.price_impact) > 0.5 && spike.spike_ratio > 3.0);
      spike.reversal_potential = (spike.institutional_spike && MathAbs(spike.price_impact) > 1.0);
   }
   
   void AnalyzeVolumeProfile(VolumeAnalysisInfo &info)
   {
      VolumeProfileInfo profile = info.profile_analysis;
      
      // Simplified volume profile analysis
      // In real implementation, this would analyze volume distribution across price levels
      
      // Find Point of Control (POC) - price level with highest volume
      profile.max_volume_price = FindPOC();
      
      // Calculate value area (simplified)
      CalculateValueArea(profile);
      
      // Analyze current position
      profile.above_poc = (info.current_price > profile.max_volume_price);
      profile.distance_to_poc = MathAbs(info.current_price - profile.max_volume_price);
      
      // Check if in value area
      profile.in_value_area = (info.current_price >= profile.value_area_low && 
                              info.current_price <= profile.value_area_high);
      
      // Calculate POC strength
      profile.poc_strength = CalculatePOCStrength(profile, info);
      
      // Identify volume-based S/R levels
      IdentifyVolumeLevels(profile);
      
      // Analyze distribution type
      AnalyzeProfileDistribution(profile);
   }
   
   double FindPOC()
   {
      // Simplified POC calculation
      // In real implementation, would analyze volume at each price level
      
      if(m_history_size < 20) return 0.0;
      
      // Find the price level around which most trading occurred
      double max_volume = 0.0;
      double poc_price = 0.0;
      
      for(int i = 0; i < MathMin(50, m_history_size); i++)
      {
         if(m_volume_history[i] > max_volume)
         {
            max_volume = m_volume_history[i];
            poc_price = m_price_history[i];
         }
      }
      
      return poc_price;
   }
   
   void CalculateValueArea(VolumeProfileInfo &profile)
   {
      // Simplified value area calculation
      // Typically 70% of volume
      
      if(m_history_size < 20) return;
      
      // Find price range containing 70% of volume
      double total_volume = 0.0;
      for(int i = 0; i < MathMin(50, m_history_size); i++)
      {
         total_volume += m_volume_history[i];
      }
      
      double target_volume = total_volume * 0.70;
      double accumulated_volume = 0.0;
      
      double min_price = DBL_MAX, max_price = -DBL_MAX;
      
      for(int i = 0; i < MathMin(50, m_history_size) && accumulated_volume < target_volume; i++)
      {
         accumulated_volume += m_volume_history[i];
         min_price = MathMin(min_price, m_price_history[i]);
         max_price = MathMax(max_price, m_price_history[i]);
      }
      
      profile.value_area_high = max_price;
      profile.value_area_low = min_price;
      profile.value_area_percentage = 70.0;
   }
   
   double CalculatePOCStrength(const VolumeProfileInfo &profile, const VolumeAnalysisInfo &info)
   {
      // POC strength based on volume concentration and distance
      double strength = 50.0; // Base strength
      
      // Distance factor
      double distance_factor = profile.distance_to_poc / (info.current_price * 0.01); // 1% of price
      strength += MathMax(-30.0, MathMin(30.0, 30.0 - distance_factor * 5.0));
      
      // Volume concentration factor
      if(info.current_volume > info.volume_sma * 1.5)
         strength += 20.0;
      
      return MathMax(0.0, MathMin(100.0, strength));
   }
   
   void IdentifyVolumeLevels(VolumeProfileInfo &profile)
   {
      // Simplified S/R level identification based on volume
      profile.resistance_count = profile.support_count = 0;
      
      // In real implementation, would identify significant volume nodes
      // as support and resistance levels
      
      if(m_history_size >= 20)
      {
         // Find top volume levels
         for(int i = 0; i < MathMin(20, m_history_size) && profile.resistance_count < 5; i++)
         {
            if(m_volume_history[i] > m_volume_mean * 1.5)
            {
               if(m_price_history[i] > profile.max_volume_price)
               {
                  profile.volume_resistance[profile.resistance_count] = m_price_history[i];
                  profile.resistance_count++;
               }
               else
               {
                  profile.volume_support[profile.support_count] = m_price_history[i];
                  profile.support_count++;
               }
            }
         }
      }
   }
   
   void AnalyzeProfileDistribution(VolumeProfileInfo &profile)
   {
      // Simplified distribution analysis
      profile.profile_type = VOLUME_PROFILE_NORMAL;
      profile.skewness = 0.0;
      profile.kurtosis = 3.0; // Normal kurtosis
      profile.balance_point = profile.max_volume_price;
   }
   
   void AnalyzeOBV(VolumeAnalysisInfo &info)
   {
      OBVAnalysisInfo obv = info.obv_analysis;
      
      if(m_history_size < 10) return;
      
      // Current OBV (already calculated in history)
      obv.obv_current = m_obv_history[0];
      
      // Calculate OBV moving averages
      if(m_history_size >= m_obv_sma_period)
      {
         double sum = 0.0;
         for(int i = 0; i < m_obv_sma_period; i++)
         {
            sum += m_obv_history[i];
         }
         obv.obv_sma = sum / m_obv_sma_period;
      }
      
      // Calculate OBV EMA
      if(m_history_size >= m_obv_ema_period)
      {
         double alpha = 2.0 / (m_obv_ema_period + 1);
         obv.obv_ema = m_obv_history[1]; // Previous EMA
         obv.obv_ema = alpha * obv.obv_current + (1 - alpha) * obv.obv_ema;
      }
      
      // Calculate OBV slope
      if(m_history_size >= 5)
      {
         obv.obv_slope = (m_obv_history[0] - m_obv_history[4]) / 4.0;
      }
      
      // OBV trend analysis
      AnalyzeOBVTrend(obv);
      
      // OBV divergence analysis
      AnalyzeOBVDivergence(obv, info);
      
      // Volume-price relationship
      AnalyzeVolumePriceRelationship(obv, info);
      
      // OBV momentum
      AnalyzeOBVMomentum(obv);
   }
   
   void AnalyzeOBVTrend(OBVAnalysisInfo &obv)
   {
      // Determine OBV trend
      if(obv.obv_slope > 0)
      {
         obv.obv_rising = true;
         obv.obv_trend = TREND_BULLISH;
      }
      else if(obv.obv_slope < 0)
      {
         obv.obv_falling = true;
         obv.obv_trend = TREND_BEARISH;
      }
      else
      {
         obv.obv_trend = TREND_NEUTRAL;
      }
      
      // OBV trend strength
      double slope_magnitude = MathAbs(obv.obv_slope);
      if(slope_magnitude > 1000)
         obv.obv_strength = TREND_VERY_STRONG;
      else if(slope_magnitude > 500)
         obv.obv_strength = TREND_STRONG;
      else if(slope_magnitude > 200)
         obv.obv_strength = TREND_MODERATE;
      else if(slope_magnitude > 50)
         obv.obv_strength = TREND_WEAK;
      else
         obv.obv_strength = TREND_VERY_WEAK;
   }
   
   void AnalyzeOBVDivergence(OBVAnalysisInfo &obv, const VolumeAnalysisInfo &info)
   {
      if(m_history_size < 20) return;
      
      // Simplified divergence analysis
      // Compare recent price trend vs OBV trend
      
      double recent_price_change = info.current_price - m_price_history[10];
      double recent_obv_change = obv.obv_current - m_obv_history[10];
      
      // Bullish divergence: price down, OBV up
      if(recent_price_change < 0 && recent_obv_change > 0)
      {
         obv.bullish_divergence = true;
         obv.divergence_strength = MathMin(100.0, MathAbs(recent_obv_change) / 1000.0);
      }
      // Bearish divergence: price up, OBV down
      else if(recent_price_change > 0 && recent_obv_change < 0)
      {
         obv.bearish_divergence = true;
         obv.divergence_strength = MathMin(100.0, MathAbs(recent_obv_change) / 1000.0);
      }
   }
   
   void AnalyzeVolumePriceRelationship(OBVAnalysisInfo &obv, const VolumeAnalysisInfo &info)
   {
      if(m_history_size < 20) return;
      
      // Calculate correlation between volume and price changes
      double sum_volume = 0.0, sum_price = 0.0;
      double sum_volume_price = 0.0, sum_volume_sq = 0.0, sum_price_sq = 0.0;
      int count = MathMin(20, m_history_size - 1);
      
      for(int i = 1; i < count; i++)
      {
         double volume_change = m_volume_history[i-1] - m_volume_history[i];
         double price_change = m_price_history[i-1] - m_price_history[i];
         
         sum_volume += volume_change;
         sum_price += price_change;
         sum_volume_price += volume_change * price_change;
         sum_volume_sq += volume_change * volume_change;
         sum_price_sq += price_change * price_change;
      }
      
      // Calculate correlation coefficient
      double volume_mean = sum_volume / count;
      double price_mean = sum_price / count;
      
      double numerator = sum_volume_price - count * volume_mean * price_mean;
      double denominator = MathSqrt((sum_volume_sq - count * volume_mean * volume_mean) * 
                                   (sum_price_sq - count * price_mean * price_mean));
      
      if(denominator > 0)
      {
         obv.correlation_coefficient = numerator / denominator;
      }
      
      // Determine lead-lag relationship
      obv.volume_leads_price = (obv.correlation_coefficient > 0.3);
      obv.price_leads_volume = (obv.correlation_coefficient < -0.3);
      obv.lead_lag_strength = MathAbs(obv.correlation_coefficient);
   }
   
   void AnalyzeOBVMomentum(OBVAnalysisInfo &obv)
   {
      if(m_history_size < 10) return;
      
      // Calculate OBV momentum
      double short_term_change = m_obv_history[0] - m_obv_history[5];
      double long_term_change = m_obv_history[0] - m_obv_history[10];
      
      obv.obv_momentum = short_term_change;
      obv.momentum_acceleration = short_term_change - long_term_change;
      
      // Check for momentum exhaustion
      if(m_history_size >= 20)
      {
         double very_recent = m_obv_history[0] - m_obv_history[2];
         double recent = m_obv_history[2] - m_obv_history[4];
         
         obv.momentum_exhaustion = (MathAbs(very_recent) < MathAbs(recent) * 0.5 && 
                                   MathAbs(recent) > 100);
      }
   }
   
   void AnalyzeInstitutionalActivity(VolumeAnalysisInfo &info)
   {
      info.institutional_activity = INSTITUTIONAL_NONE;
      info.institutional_strength = 0.0;
      info.smart_money_flow = 0.0;
      
      // Detect institutional activity patterns
      if(info.spike_analysis.institutional_spike)
      {
         // Determine type of institutional activity
         if(info.spike_analysis.buying_spike && info.current_price > info.profile_analysis.value_area_high)
         {
            info.institutional_activity = INSTITUTIONAL_BREAKOUT;
            info.institutional_strength = 70.0 + info.spike_analysis.spike_ratio * 5.0;
         }
         else if(info.spike_analysis.selling_spike && info.current_price < info.profile_analysis.value_area_low)
         {
            info.institutional_activity = INSTITUTIONAL_DISTRIBUTION;
            info.institutional_strength = 70.0 + info.spike_analysis.spike_ratio * 5.0;
         }
         else if(info.profile_analysis.in_value_area)
         {
            info.institutional_activity = INSTITUTIONAL_ACCUMULATION;
            info.institutional_strength = 60.0 + info.spike_analysis.spike_ratio * 3.0;
         }
         else
         {
            info.institutional_activity = INSTITUTIONAL_TESTING;
            info.institutional_strength = 50.0 + info.spike_analysis.spike_ratio * 2.0;
         }
      }
      
      // Detect absorption patterns
      if(info.current_volume > info.volume_sma * 2.0 && MathAbs(info.spike_analysis.price_impact) < 0.2)
      {
         info.institutional_activity = INSTITUTIONAL_ABSORPTION;
         info.institutional_strength = 65.0;
      }
      
      // Detect manipulation patterns
      if(info.spike_analysis.spike_detected && info.spike_analysis.reversal_potential)
      {
         info.institutional_activity = INSTITUTIONAL_MANIPULATION;
         info.institutional_strength = 75.0;
      }
      
      // Calculate smart money flow
      if(info.obv_analysis.volume_leads_price)
      {
         info.smart_money_flow = info.obv_analysis.obv_momentum / 1000.0; // Normalize
         info.smart_money_flow = MathMax(-100.0, MathMin(100.0, info.smart_money_flow));
      }
      
      // Detect dark pool and algorithmic activity (simplified indicators)
      info.dark_pool_activity = (info.current_volume > info.volume_sma * 1.5 && 
                                 MathAbs(info.spike_analysis.price_impact) < 0.1);
      
      info.algorithmic_activity = (info.current_volume > info.volume_sma && 
                                  info.spike_analysis.spike_duration_bars <= 2);
   }
   
   void AnalyzeBreakConfirmation(VolumeAnalysisInfo &info)
   {
      info.breakout_confirmation = VOLUME_CONF_NONE;
      info.breakdown_confirmation = VOLUME_CONF_NONE;
      info.volume_breakout = false;
      info.volume_exhaustion = false;
      info.breakout_strength = 0.0;
      
      // Analyze volume confirmation for price movements
      if(m_history_size >= 5)
      {
         double price_change = info.current_price - m_price_history[3];
         double price_change_pct = MathAbs(price_change) / m_price_history[3] * 100.0;
         
         if(price_change_pct > 0.5) // Significant price movement
         {
            double volume_strength = info.relative_volume;
            
            // Determine confirmation level
            ENUM_VOLUME_CONFIRMATION confirmation = VOLUME_CONF_NONE;
            if(volume_strength >= 3.0)
               confirmation = VOLUME_CONF_EXTREME;
            else if(volume_strength >= 2.0)
               confirmation = VOLUME_CONF_STRONG;
            else if(volume_strength >= 1.5)
               confirmation = VOLUME_CONF_MODERATE;
            else if(volume_strength >= 1.2)
               confirmation = VOLUME_CONF_WEAK;
            
            if(price_change > 0) // Breakout up
               info.breakout_confirmation = confirmation;
            else // Breakdown
               info.breakdown_confirmation = confirmation;
            
            info.breakout_strength = volume_strength * price_change_pct;
         }
      }
      
      // Volume breakout detection
      info.volume_breakout = (info.relative_volume >= 2.5);
      
      // Volume exhaustion detection
      if(m_history_size >= 10)
      {
         double recent_avg = 0.0, older_avg = 0.0;
         for(int i = 0; i < 3; i++)
            recent_avg += m_volume_history[i];
         for(int i = 7; i < 10; i++)
            older_avg += m_volume_history[i];
         
         recent_avg /= 3.0;
         older_avg /= 3.0;
         
         info.volume_exhaustion = (recent_avg < older_avg * 0.7 && older_avg > info.volume_sma);
      }
   }
   
   void AnalyzeMultiTimeframeVolume(VolumeAnalysisInfo &info)
   {
      // Get volume ratios from different timeframes
      info.volume_h1_ratio = GetVolumeRatioForTimeframe(PERIOD_H1);
      info.volume_h4_ratio = GetVolumeRatioForTimeframe(PERIOD_H4);
      info.volume_d1_ratio = GetVolumeRatioForTimeframe(PERIOD_D1);
      
      // Multi-timeframe confirmation
      int high_volume_tfs = 0;
      if(info.volume_h1_ratio > 1.5) high_volume_tfs++;
      if(info.volume_h4_ratio > 1.5) high_volume_tfs++;
      if(info.volume_d1_ratio > 1.5) high_volume_tfs++;
      
      info.multi_tf_confirmation = (high_volume_tfs >= 2);
   }
   
   double GetVolumeRatioForTimeframe(ENUM_TIMEFRAMES timeframe)
   {
      // Get current volume for specific timeframe
      MqlRates rates[21]; // Current + 20 for average
      if(CopyRates(m_symbol, timeframe, 0, 21, rates) != 21)
         return 1.0;
      
      double current_volume = (double)rates[0].tick_volume;
      double sum = 0.0;
      for(int i = 1; i < 21; i++)
      {
         sum += (double)rates[i].tick_volume;
      }
      
      double average_volume = sum / 20.0;
      return (average_volume > 0) ? (current_volume / average_volume) : 1.0;
   }
   
   void GenerateVolumeSignals(VolumeAnalysisInfo &info)
   {
      info.volume_signal = SIGNAL_NONE;
      info.signal_strength = SIGNAL_STRENGTH_NONE;
      info.signal_confidence = 0.0;
      info.entry_probability = 0.0;
      
      double bullish_score = 0.0, bearish_score = 0.0;
      
      // Volume spike signals
      if(info.spike_analysis.buying_spike)
         bullish_score += 25.0;
      if(info.spike_analysis.selling_spike)
         bearish_score += 25.0;
      
      // Institutional activity signals
      if(info.institutional_activity == INSTITUTIONAL_ACCUMULATION ||
         info.institutional_activity == INSTITUTIONAL_BREAKOUT)
         bullish_score += 30.0;
      if(info.institutional_activity == INSTITUTIONAL_DISTRIBUTION)
         bearish_score += 30.0;
      
      // OBV signals
      if(info.obv_analysis.bullish_divergence)
         bullish_score += 20.0;
      if(info.obv_analysis.bearish_divergence)
         bearish_score += 20.0;
      if(info.obv_analysis.obv_trend == TREND_BULLISH)
         bullish_score += 15.0;
      if(info.obv_analysis.obv_trend == TREND_BEARISH)
         bearish_score += 15.0;
      
      // Break confirmation signals
      if(info.breakout_confirmation >= VOLUME_CONF_STRONG)
         bullish_score += 25.0;
      if(info.breakdown_confirmation >= VOLUME_CONF_STRONG)
         bearish_score += 25.0;
      
      // Multi-timeframe confirmation
      if(info.multi_tf_confirmation)
      {
         if(bullish_score > bearish_score)
            bullish_score += 15.0;
         else if(bearish_score > bullish_score)
            bearish_score += 15.0;
      }
      
      // Volume exhaustion (contrarian signal)
      if(info.volume_exhaustion)
      {
         if(bullish_score > bearish_score)
            bearish_score += 20.0; // Potential reversal
         else if(bearish_score > bullish_score)
            bullish_score += 20.0; // Potential reversal
      }
      
      // Determine signal
      if(bullish_score > bearish_score && bullish_score >= 40.0)
      {
         info.volume_signal = SIGNAL_BUY;
         info.signal_confidence = MathMin(100.0, bullish_score);
      }
      else if(bearish_score > bullish_score && bearish_score >= 40.0)
      {
         info.volume_signal = SIGNAL_SELL;
         info.signal_confidence = MathMin(100.0, bearish_score);
      }
      
      // Signal strength
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
      
      // Entry probability
      info.entry_probability = info.signal_confidence;
      if(info.institutional_activity != INSTITUTIONAL_NONE)
         info.entry_probability += 10.0;
      if(info.multi_tf_confirmation)
         info.entry_probability += 10.0;
      
      info.entry_probability = MathMin(100.0, info.entry_probability);
   }
   
   void ExtractMLFeatures(VolumeAnalysisInfo &info)
   {
      // Feature 1-5: Basic volume metrics
      m_ml_features[0] = info.relative_volume / 5.0; // Normalize to reasonable range
      m_ml_features[1] = info.spike_analysis.volume_percentile / 100.0;
      m_ml_features[2] = info.spike_analysis.spike_detected ? 1.0 : 0.0;
      m_ml_features[3] = info.spike_analysis.spike_ratio / 5.0;
      m_ml_features[4] = (double)info.spike_analysis.spike_intensity / 4.0;
      
      // Feature 6-10: Institutional indicators
      m_ml_features[5] = (double)info.institutional_activity / 6.0;
      m_ml_features[6] = info.institutional_strength / 100.0;
      m_ml_features[7] = info.dark_pool_activity ? 1.0 : 0.0;
      m_ml_features[8] = info.algorithmic_activity ? 1.0 : 0.0;
      m_ml_features[9] = (info.smart_money_flow + 100.0) / 200.0; // Normalize -100,+100 to 0,1
      
      // Feature 11-15: OBV features
      m_ml_features[10] = info.obv_analysis.obv_slope / 1000.0; // Normalize
      m_ml_features[11] = (double)info.obv_analysis.obv_trend / 5.0;
      m_ml_features[12] = info.obv_analysis.bullish_divergence ? 1.0 : 0.0;
      m_ml_features[13] = info.obv_analysis.bearish_divergence ? 1.0 : 0.0;
      m_ml_features[14] = info.obv_analysis.correlation_coefficient; // Already -1 to +1
      
      // Feature 16-20: Volume profile features
      m_ml_features[15] = info.profile_analysis.above_poc ? 1.0 : 0.0;
      m_ml_features[16] = info.profile_analysis.in_value_area ? 1.0 : 0.0;
      m_ml_features[17] = info.profile_analysis.poc_strength / 100.0;
      m_ml_features[18] = (double)info.profile_analysis.profile_type / 5.0;
      m_ml_features[19] = info.profile_analysis.near_institutional_level ? 1.0 : 0.0;
      
      // Feature 21-25: Advanced features
      m_ml_features[20] = (double)info.breakout_confirmation / 4.0;
      m_ml_features[21] = info.volume_breakout ? 1.0 : 0.0;
      m_ml_features[22] = info.volume_exhaustion ? 1.0 : 0.0;
      m_ml_features[23] = info.multi_tf_confirmation ? 1.0 : 0.0;
      m_ml_features[24] = info.unusual_activity ? 1.0 : 0.0;
   }
   
   void CalculateMLPredictions(VolumeAnalysisInfo &info)
   {
      if(!m_ml_trained) return;
      
      // Simple neural network prediction (placeholder)
      double ml_score = 0.0;
      for(int i = 0; i < 25; i++)
      {
         ml_score += m_ml_features[i] * m_ml_weights[i];
      }
      
      // Apply activation and normalize
      ml_score = (MathTanh(ml_score) + 1.0) * 50.0;
      info.ml_volume_score = MathMax(0.0, MathMin(100.0, ml_score));
      
      // Calculate specific probabilities
      if(info.institutional_activity == INSTITUTIONAL_ACCUMULATION)
         info.accumulation_prob = 70.0 + (info.ml_volume_score - 50.0) * 0.6;
      else if(info.institutional_activity == INSTITUTIONAL_DISTRIBUTION)
         info.distribution_prob = 70.0 + (info.ml_volume_score - 50.0) * 0.6;
      else if(info.institutional_activity == INSTITUTIONAL_MANIPULATION)
         info.manipulation_prob = 60.0 + (info.ml_volume_score - 50.0) * 0.8;
      
      // Normalize probabilities
      info.accumulation_prob = MathMax(0.0, MathMin(100.0, info.accumulation_prob));
      info.distribution_prob = MathMax(0.0, MathMin(100.0, info.distribution_prob));
      info.manipulation_prob = MathMax(0.0, MathMin(100.0, info.manipulation_prob));
   }
   
   void AssessVolumeRisk(VolumeAnalysisInfo &info)
   {
      info.volume_risk = RISK_MEDIUM;
      info.liquidity_factor = 1.0;
      info.unusual_activity = false;
      
      // High volume reduces risk (better liquidity)
      if(info.relative_volume > 2.0)
      {
         info.volume_risk = RISK_LOW;
         info.liquidity_factor = 0.7;
      }
      // Very low volume increases risk
      else if(info.relative_volume < 0.5)
      {
         info.volume_risk = RISK_HIGH;
         info.liquidity_factor = 1.5;
      }
      
      // Institutional manipulation increases risk
      if(info.institutional_activity == INSTITUTIONAL_MANIPULATION)
      {
         info.volume_risk = RISK_VERY_HIGH;
         info.liquidity_factor = 2.0;
         info.unusual_activity = true;
      }
      
      // Volume exhaustion increases risk
      if(info.volume_exhaustion)
      {
         info.volume_risk = RISK_HIGH;
         info.unusual_activity = true;
      }
      
      // Extreme volume spikes can be risky
      if(info.spike_analysis.spike_ratio > 5.0)
      {
         info.unusual_activity = true;
         if(info.volume_risk < RISK_HIGH)
            info.volume_risk = RISK_HIGH;
      }
      
      // Multi-timeframe confirmation reduces risk
      if(info.multi_tf_confirmation && info.volume_risk > RISK_LOW)
      {
         info.volume_risk = (ENUM_RISK_LEVEL)(info.volume_risk - 1);
         info.liquidity_factor *= 0.9;
      }
   }

public:
   //+------------------------------------------------------------------+
   //| Public Interface Methods                                         |
   //+------------------------------------------------------------------+
   bool IsInitialized() const { return m_initialized; }
   string GetSymbol() const { return m_symbol; }
   ENUM_TIMEFRAMES GetTimeframe() const { return m_timeframe; }
   
   // Configuration methods
   void SetVolumeSettings(int sma_period, int ema_period, double spike_threshold, double institutional_threshold)
   {
      m_volume_sma_period = MathMax(5, MathMin(100, sma_period));
      m_volume_ema_period = MathMax(5, MathMin(100, ema_period));
      m_spike_threshold = MathMax(1.2, MathMin(10.0, spike_threshold));
      m_institutional_threshold = MathMax(1.5, MathMin(20.0, institutional_threshold));
   }
   
   void SetOBVSettings(int sma_period, int ema_period)
   {
      m_obv_sma_period = MathMax(5, MathMin(50, sma_period));
      m_obv_ema_period = MathMax(5, MathMin(50, ema_period));
   }
   
   // Quick access methods
   double GetRelativeVolume()
   {
      VolumeAnalysisInfo info = AnalyzeVolume();
      return info.relative_volume;
   }
   
   bool HasVolumeSpike()
   {
      VolumeAnalysisInfo info = AnalyzeVolume();
      return info.spike_analysis.spike_detected;
   }
   
   bool IsInstitutionalActivity()
   {
      VolumeAnalysisInfo info = AnalyzeVolume();
      return (info.institutional_activity != INSTITUTIONAL_NONE);
   }
   
   ENUM_INSTITUTIONAL_ACTIVITY GetInstitutionalActivity()
   {
      VolumeAnalysisInfo info = AnalyzeVolume();
      return info.institutional_activity;
   }
   
   bool HasBullishDivergence()
   {
      VolumeAnalysisInfo info = AnalyzeVolume();
      return info.obv_analysis.bullish_divergence;
   }
   
   bool HasBearishDivergence()
   {
      VolumeAnalysisInfo info = AnalyzeVolume();
      return info.obv_analysis.bearish_divergence;
   }
   
   ENUM_VOLUME_CONFIRMATION GetBreakoutConfirmation()
   {
      VolumeAnalysisInfo info = AnalyzeVolume();
      return info.breakout_confirmation;
   }
   
   bool IsVolumeBreakout()
   {
      VolumeAnalysisInfo info = AnalyzeVolume();
      return info.volume_breakout;
   }
   
   bool IsAbovePOC()
   {
      VolumeAnalysisInfo info = AnalyzeVolume();
      return info.profile_analysis.above_poc;
   }
   
   bool IsInValueArea()
   {
      VolumeAnalysisInfo info = AnalyzeVolume();
      return info.profile_analysis.in_value_area;
   }
   
   double GetSmartMoneyFlow()
   {
      VolumeAnalysisInfo info = AnalyzeVolume();
      return info.smart_money_flow;
   }
   
   // ML and advanced features
   bool GetMLFeatures(double &features[])
   {
      if(!m_initialized) return false;
      
      VolumeAnalysisInfo info = AnalyzeVolume(); // This updates ML features
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
      
      Print("Volume ML model training completed (placeholder implementation)");
      return true;
   }
   
   // Performance metrics
   double GetAccuracyRate() const { return m_accuracy_rate; }
   int GetTotalCalculations() const { return m_total_calculations; }
   datetime GetLastCalculationTime() const { return m_last_calculation; }
   
   void UpdatePerformance(bool signal_success)
   {
      if(signal_success)
         m_successful_signals++;
      
      if(m_total_calculations > 0)
         m_accuracy_rate = (m_successful_signals * 100.0) / m_total_calculations;
   }
   
   // Update methods
   bool RefreshHistoricalData()
   {
      return LoadHistoricalVolumeData() && CalculateVolumeStatistics();
   }
};

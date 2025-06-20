//+------------------------------------------------------------------+
//| ISignalProvider.mqh - Gelişmiş Confluence Skorlama Sistemi       |
//| MQL5 Uyumlu - Machine Learning ve Multi-Timeframe Destekli      |
//| Complete_Enum_Types Uyumlu Advanced Confluence & OOP Mimari      |
//| KESINLIKLE SON SÜRÜM - HATALAR DÜZELTİLDİ                       |
//+------------------------------------------------------------------+
#property strict

#include "Complete_Enum_Types.mqh"

// Forward declaration for compatibility
#ifndef PERIOD_CURRENT
#define PERIOD_CURRENT 0
#endif

//+------------------------------------------------------------------+
//| MQL5 ERROR HANDLING MACROS - DÜZELTİLMİŞ                       |
//+------------------------------------------------------------------+
#define SAFE_DELETE(ptr) if(CheckPointer(ptr) != POINTER_INVALID) { delete ptr; ptr = NULL; }
#define CHECK_POINTER(ptr) (CheckPointer(ptr) != POINTER_INVALID)

//+------------------------------------------------------------------+
//| MQL5 UYUMLU HELPER FUNCTIONS                                    |
//+------------------------------------------------------------------+

void ResetLastErrorCode()
{
   ResetLastError();
}

int GetLastErrorCode()
{
   return GetLastError();
}

int GetObjectsTotal()
{
   return ObjectsTotal(0, -1, -1); // MQL5'te chart_id, subwindow, type parametreleri gerekli
}

//+------------------------------------------------------------------+
//| Provider Konfigürasyon Yapısı                                   |
//+------------------------------------------------------------------+
struct ProviderConfig
{
   string               provider_name;        // Provider adı
   string               provider_version;     // Provider versiyonu
   string               symbol;               // İşlem sembolü
   ENUM_TIMEFRAMES      primary_timeframe;   // Ana zaman çerçevesi
   ENUM_TIMEFRAMES      secondary_timeframes[9]; // İkincil zaman çerçeveleri
   int                  timeframe_count;      // Zaman çerçevesi sayısı
   
   // Confluence ayarları
   double               min_confluence_score; // Minimum confluence skoru
   double               min_confidence;       // Minimum güven oranı
   ENUM_SIGNAL_QUALITY  min_signal_quality;  // Minimum sinyal kalitesi
   ENUM_CONFLUENCE_LEVEL min_confluence_level; // Minimum confluence seviyesi
   
   // Risk yönetimi
   double               max_risk_per_trade;   // İşlem başına maksimum risk
   double               max_daily_risk;       // Günlük maksimum risk
   ENUM_RISK_LEVEL      default_risk_level;  // Varsayılan risk seviyesi
   
   // ML ayarları
   ENUM_ML_MODEL_TYPE   ml_model_type;       // ML model türü
   bool                 enable_ml;           // ML etkinleştir
   bool                 enable_adaptation;   // Adaptasyon etkinleştir
   string               ml_data_path;        // ML veri yolu
   
   // Genel ayarlar
   bool                 enable_confluence;   // Confluence etkinleştir
   bool                 enable_multi_timeframe; // Çoklu zaman çerçevesi
   bool                 enable_volume_analysis; // Hacim analizi
   bool                 enable_news_filter;  // Haber filtresi
   int                  signal_expiry_minutes; // Sinyal geçerlilik süresi (dakika)
   
   // Constructor
   ProviderConfig()
   {
      Reset();
   }
   
   void Reset()
   {
      provider_name = "DefaultProvider";
      provider_version = "1.0.0";
      symbol = Symbol();
      primary_timeframe = PERIOD_H1;
      ArrayInitialize(secondary_timeframes, PERIOD_CURRENT);
      timeframe_count = 1;
      
      min_confluence_score = 50.0;
      min_confidence = 0.6;
      min_signal_quality = SIGNAL_QUALITY_FAIR;
      min_confluence_level = CONFLUENCE_MODERATE;
      
      max_risk_per_trade = 0.01; // %1
      max_daily_risk = 0.04;     // %4
      default_risk_level = RISK_MEDIUM;
      
      ml_model_type = ML_NEURAL_NETWORK;
      enable_ml = false;
      enable_adaptation = false;
      ml_data_path = "";
      
      enable_confluence = true;
      enable_multi_timeframe = true;
      enable_volume_analysis = true;
      enable_news_filter = false;
      signal_expiry_minutes = 60;
   }
   
   bool IsValid() const
   {
      bool result = true;
      
      if(StringLen(provider_name) == 0)
      {
         Print("ERROR: Empty provider name");
         result = false;
      }
      
      if(min_confidence <= 0.0 || min_confidence > 1.0)
      {
         Print(StringFormat("ERROR: Invalid min_confidence: %.3f", min_confidence));
         result = false;
      }
      
      if(min_confluence_score < 0.0 || min_confluence_score > 100.0)
      {
         Print(StringFormat("ERROR: Invalid min_confluence_score: %.2f", min_confluence_score));
         result = false;
      }
      
      if(!IsValidSignalQuality(min_signal_quality))
      {
         Print(StringFormat("ERROR: Invalid signal quality: %d", (int)min_signal_quality));
         result = false;
      }
      
      if(!IsValidConfluenceLevel(min_confluence_level))
      {
         Print(StringFormat("ERROR: Invalid confluence level: %d", (int)min_confluence_level));
         result = false;
      }
      
      if(max_risk_per_trade <= 0.0 || max_risk_per_trade > 1.0)
      {
         Print(StringFormat("ERROR: Invalid max_risk_per_trade: %.4f", max_risk_per_trade));
         result = false;
      }
      
      return result;
   }
};

//+------------------------------------------------------------------+
//| Performans İstatistikleri Yapısı                               |
//+------------------------------------------------------------------+
struct PerformanceStats
{
   // Temel istatistikler
   int                  total_signals;       // Toplam sinyal sayısı
   int                  successful_signals;  // Başarılı sinyal sayısı
   int                  failed_signals;      // Başarısız sinyal sayısı
   double               success_rate;        // Başarı oranı (%)
   
   // Getiri istatistikleri
   double               total_return;        // Toplam getiri
   double               average_return;      // Ortalama getiri
   double               best_return;         // En iyi getiri
   double               worst_return;        // En kötü getiri
   double               sharpe_ratio;        // Sharpe oranı
   
   // Risk istatistikleri
   double               max_drawdown;        // Maksimum düşüş
   double               volatility;          // Volatilite
   double               var_95;              // %95 VaR
   double               average_risk_reward; // Ortalama risk/ödül
   
   // Confluence istatistikleri
   double               avg_confluence_score; // Ortalama confluence skoru
   int                  high_quality_signals; // Yüksek kaliteli sinyal sayısı
   int                  low_quality_signals;  // Düşük kaliteli sinyal sayısı
   double               confluence_success_rate; // Confluence başarı oranı
   
   // Zaman bazlı istatistikler
   datetime             first_signal_time;   // İlk sinyal zamanı
   datetime             last_signal_time;    // Son sinyal zamanı
   double               signals_per_day;     // Günlük sinyal sayısı
   double               avg_signal_duration; // Ortalama sinyal süresi (dakika)
   
   // ML performans
   double               ml_accuracy;         // ML doğruluk oranı
   double               ml_precision;        // ML kesinlik
   double               ml_recall;           // ML hatırlama
   double               ml_f1_score;         // ML F1 skoru
   
   // Constructor
   PerformanceStats()
   {
      Reset();
   }
   
   void Reset()
   {
      total_signals = 0;
      successful_signals = 0;
      failed_signals = 0;
      success_rate = 0.0;
      
      total_return = 0.0;
      average_return = 0.0;
      best_return = 0.0;
      worst_return = 0.0;
      sharpe_ratio = 0.0;
      
      max_drawdown = 0.0;
      volatility = 0.0;
      var_95 = 0.0;
      average_risk_reward = 0.0;
      
      avg_confluence_score = 0.0;
      high_quality_signals = 0;
      low_quality_signals = 0;
      confluence_success_rate = 0.0;
      
      first_signal_time = 0;
      last_signal_time = 0;
      signals_per_day = 0.0;
      avg_signal_duration = 0.0;
      
      ml_accuracy = 0.0;
      ml_precision = 0.0;
      ml_recall = 0.0;
      ml_f1_score = 0.0;
   }
   
   bool UpdateStats(bool signal_success, double return_pct, double confluence_score, double signal_duration_minutes)
   {
      // Input validation
      if(return_pct < -100.0 || return_pct > 1000.0)
      {
         Print(StringFormat("ERROR: Invalid return percentage: %.2f", return_pct));
         return false;
      }
      
      if(confluence_score < 0.0 || confluence_score > 100.0)
      {
         Print(StringFormat("ERROR: Invalid confluence score: %.2f", confluence_score));
         return false;
      }
      
      if(signal_duration_minutes < 0.0)
      {
         Print(StringFormat("ERROR: Invalid signal duration: %.2f", signal_duration_minutes));
         return false;
      }
      
      total_signals++;
      
      if(signal_success)
         successful_signals++;
      else
         failed_signals++;
      
      success_rate = (total_signals > 0) ? (successful_signals * 100.0 / total_signals) : 0.0;
      
      // Getiri güncellemesi
      total_return += return_pct;
      average_return = total_return / total_signals;
      
      if(return_pct > best_return) best_return = return_pct;
      if(return_pct < worst_return) worst_return = return_pct;
      
      // Confluence güncellemesi
      avg_confluence_score = ((avg_confluence_score * (total_signals - 1)) + confluence_score) / total_signals;
      
      if(confluence_score >= 75.0)
         high_quality_signals++;
      else if(confluence_score <= 35.0)
         low_quality_signals++;
      
      // Süre güncellemesi
      avg_signal_duration = ((avg_signal_duration * (total_signals - 1)) + signal_duration_minutes) / total_signals;
      
      last_signal_time = TimeCurrent();
      if(first_signal_time == 0) first_signal_time = last_signal_time;
      
      // Günlük sinyal sayısı
      if(first_signal_time > 0 && last_signal_time > first_signal_time)
      {
         double days = (last_signal_time - first_signal_time) / 86400.0; // 86400 saniye = 1 gün
         if(days > 0) signals_per_day = total_signals / days;
      }
      
      return true;
   }
   
   ENUM_PERFORMANCE_CLASS GetPerformanceClass() const
   {
      return CalculatePerformanceClass(success_rate);
   }
   
   string ToString() const
   {
      return StringFormat("Signals: %d | Success Rate: %.2f%% | Avg Return: %.2f%% | Avg Confluence: %.1f%% | Performance: %s",
                         total_signals, success_rate, average_return, avg_confluence_score, 
                         PerformanceClassToString(GetPerformanceClass()));
   }
};

//+------------------------------------------------------------------+
//| ML Model Bilgi Yapısı                                          |
//+------------------------------------------------------------------+
struct MLModelInfo
{
   // Model temel bilgileri
   ENUM_ML_MODEL_TYPE   model_type;          // Model türü
   ENUM_ML_MODEL_STATE  model_state;         // Model durumu
   ENUM_ML_ADAPTATION_TYPE adaptation_type;  // Adaptasyon türü
   string               model_name;          // Model adı
   string               model_version;       // Model versiyonu
   
   // Eğitim bilgileri
   datetime             last_training_time;  // Son eğitim zamanı
   datetime             last_update_time;    // Son güncelleme zamanı
   int                  training_epochs;     // Eğitim epoch sayısı
   int                  total_training_samples; // Toplam eğitim örneği
   double               training_accuracy;   // Eğitim doğruluğu
   double               validation_accuracy; // Doğrulama doğruluğu
   double               test_accuracy;       // Test doğruluğu
   
   // Model performansı
   double               current_confidence;  // Mevcut güven seviyesi
   double               prediction_accuracy; // Tahmin doğruluğu
   double               model_stability;     // Model kararlılığı
   double               adaptation_rate;     // Adaptasyon oranı
   
   // Feature bilgileri
   int                  feature_count;       // Feature sayısı
   string               feature_names[50];   // Feature isimleri
   double               feature_importance[50]; // Feature önemlilikleri
   
   // Model hiperparametreleri
   double               learning_rate;       // Öğrenme oranı
   int                  hidden_layers;       // Gizli katman sayısı
   int                  neurons_per_layer;   // Katman başına nöron
   double               dropout_rate;        // Dropout oranı
   double               regularization;      // Regularizasyon
   
   // Adaptasyon bilgileri
   bool                 enable_online_learning; // Online öğrenme etkin mi
   bool                 enable_drift_detection; // Drift tespiti etkin mi
   double               drift_threshold;      // Drift eşiği
   int                  adaptation_window;    // Adaptasyon penceresi
   int                  samples_since_adaptation; // Son adaptasyondan bu yana örnek sayısı
   
   // Constructor
   MLModelInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      model_type = ML_NEURAL_NETWORK;
      model_state = ML_STATE_NOT_INITIALIZED;
      adaptation_type = ML_ADAPT_NONE;
      model_name = "DefaultModel";
      model_version = "1.0.0";
      
      last_training_time = 0;
      last_update_time = 0;
      training_epochs = 0;
      total_training_samples = 0;
      training_accuracy = 0.0;
      validation_accuracy = 0.0;
      test_accuracy = 0.0;
      
      current_confidence = 0.0;
      prediction_accuracy = 0.0;
      model_stability = 0.0;
      adaptation_rate = 0.0;
      
      feature_count = 0;
      for(int i = 0; i < 50; i++)
         feature_names[i] = "";
      ArrayInitialize(feature_importance, 0.0);
      
      learning_rate = 0.001;
      hidden_layers = 3;
      neurons_per_layer = 64;
      dropout_rate = 0.2;
      regularization = 0.01;
      
      enable_online_learning = false;
      enable_drift_detection = false;
      drift_threshold = 0.1;
      adaptation_window = 100;
      samples_since_adaptation = 0;
   }
   
   bool IsReady() const
   {
      return (model_state == ML_STATE_READY && current_confidence > 0.5);
   }
   
   bool NeedsTraining() const
   {
      return (model_state == ML_STATE_NOT_INITIALIZED || 
              model_state == ML_STATE_UNDERFITTED ||
              current_confidence < 0.3);
   }
   
   bool NeedsAdaptation() const
   {
      return (enable_online_learning && 
              samples_since_adaptation >= adaptation_window);
   }
   
   string ToString() const
   {
      return StringFormat("Model: %s v%s | State: %s | Accuracy: %.2f%% | Confidence: %.2f%% | Features: %d",
                         model_name, model_version, 
                         MLModelStateToString(model_state),
                         prediction_accuracy * 100.0,
                         current_confidence * 100.0,
                         feature_count);
   }
};

//+------------------------------------------------------------------+
//| Utility Functions - ISignalProvider'a özel                     |
//+------------------------------------------------------------------+

string MarketConditionToString(ENUM_MARKET_CONDITION condition)
{
   switch(condition)
   {
      case MARKET_RANGING: return "RANGING";
      case MARKET_TRENDING: return "TRENDING";
      case MARKET_VOLATILE: return "VOLATILE";
      case MARKET_QUIET: return "QUIET";
      default: return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Confluence Bilgi Yapısı - GÜVENLİK İYİLEŞTİRMELİ               |
//+------------------------------------------------------------------+
struct ConfluenceInfo
{
   // Temel confluence verileri
   int                   indicator_count;        // Onaylayan gösterge sayısı
   int                   timeframe_count;        // Onaylayan zaman çerçevesi sayısı
   double                total_score;            // Toplam confluence skoru (0-100)
   double                weighted_score;         // Ağırlıklı confluence skoru
   double                quality_multiplier;     // Kalite çarpanı
   
   // Gösterge kategori skorları
   double                trend_score;            // Trend göstergeleri skoru
   double                momentum_score;         // Momentum göstergeleri skoru
   double                volume_score;           // Hacim göstergeleri skoru
   double                volatility_score;       // Volatilite göstergeleri skoru
   double                support_resistance_score; // S/R seviye skoru
   
   // Zaman çerçevesi skorları
   double                timeframe_scores[10];   // Her TF için ayrı skor
   ENUM_TIMEFRAMES       active_timeframes[10];  // Aktif zaman çerçeveleri
   int                   active_tf_count;        // Aktif TF sayısı
   
   // Skor detayları
   string                scoring_details;        // Skorlama detayları
   string                strong_signals[20];     // Güçlü sinyaller
   string                weak_signals[20];       // Zayıf sinyaller
   int                   strong_count;           // Güçlü sinyal sayısı
   int                   weak_count;             // Zayıf sinyal sayısı
   
   // Constructor
   ConfluenceInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      indicator_count = 0;
      timeframe_count = 0;
      total_score = 0.0;
      weighted_score = 0.0;
      quality_multiplier = 1.0;
      
      trend_score = 0.0;
      momentum_score = 0.0;
      volume_score = 0.0;
      volatility_score = 0.0;
      support_resistance_score = 0.0;
      
      ArrayInitialize(timeframe_scores, 0.0);
      ArrayInitialize(active_timeframes, PERIOD_CURRENT);
      active_tf_count = 0;
      
      scoring_details = "";
      for(int i = 0; i < 20; i++)
      {
         strong_signals[i] = "";
         weak_signals[i] = "";
      }
      strong_count = 0;
      weak_count = 0;
   }
   
   // GÜVENLİ STRONG SIGNAL EKLEME
   bool AddStrongSignal(const string signal_name)
   {
      return SafeAddStringToArray(strong_signals, strong_count, 20, signal_name);
   }
   
   // GÜVENLİ WEAK SIGNAL EKLEME
   bool AddWeakSignal(const string signal_name)
   {
      return SafeAddStringToArray(weak_signals, weak_count, 20, signal_name);
   }
   
   // GÜVENLİ TIMEFRAME SCORE EKLEME
   bool AddTimeframeScore(ENUM_TIMEFRAMES timeframe, double score)
   {
      if(active_tf_count >= 10)
      {
         Print("WARNING: Maximum timeframes reached (10)");
         return false;
      }
      
      if(score < 0.0 || score > 100.0)
      {
         Print(StringFormat("WARNING: Invalid score value: %.2f", score));
         return false;
      }
      
      active_timeframes[active_tf_count] = timeframe;
      timeframe_scores[active_tf_count] = score;
      active_tf_count++;
      return true;
   }
   
   // GÜVENLİ GETTER METODLARI
   string GetStrongSignal(int index) const
   {
      return SafeGetStringFromArray(strong_signals, index, strong_count);
   }
   
   string GetWeakSignal(int index) const
   {
      return SafeGetStringFromArray(weak_signals, index, weak_count);
   }
   
   double GetTimeframeScore(int index) const
   {
      if(index < 0 || index >= active_tf_count || index >= 10)
      {
         Print(StringFormat("WARNING: Invalid timeframe index: %d", index));
         return 0.0;
      }
      return timeframe_scores[index];
   }
   
   bool IsValid() const
   {
      if(total_score < 0.0 || total_score > 100.0)
      {
         Print(StringFormat("ERROR: Invalid total score: %.2f", total_score));
         return false;
      }
      
      if(weighted_score < 0.0 || weighted_score > 100.0)
      {
         Print(StringFormat("ERROR: Invalid weighted score: %.2f", weighted_score));
         return false;
      }
      
      if(indicator_count < 0 || indicator_count > 100)
      {
         Print(StringFormat("ERROR: Invalid indicator count: %d", indicator_count));
         return false;
      }
      
      if(timeframe_count < 0 || timeframe_count > 10)
      {
         Print(StringFormat("ERROR: Invalid timeframe count: %d", timeframe_count));
         return false;
      }
      
      return true;
   }
   
   ENUM_SIGNAL_QUALITY GetQualityLevel() const
   {
      if(weighted_score >= 95.0 && strong_count >= 4)
         return SIGNAL_QUALITY_PRISTINE;
      else if(weighted_score >= 85.0 && strong_count >= 3)
         return SIGNAL_QUALITY_EXCELLENT;
      else if(weighted_score >= 75.0 && strong_count >= 2)
         return SIGNAL_QUALITY_VERY_GOOD;
      else if(weighted_score >= 60.0)
         return SIGNAL_QUALITY_GOOD;
      else if(weighted_score >= 40.0)
         return SIGNAL_QUALITY_FAIR;
      else if(weighted_score >= 20.0)
         return SIGNAL_QUALITY_POOR;
      else
         return SIGNAL_QUALITY_VERY_POOR;
   }
   
   ENUM_CONFLUENCE_LEVEL GetConfluenceLevel() const
   {
      return CalculateConfluenceLevel(indicator_count);
   }
   
   ENUM_TIMEFRAME_ALIGNMENT GetTimeframeAlignment() const
   {
      return CalculateTimeframeAlignment(timeframe_count, active_tf_count);
   }
   
   string ToString() const
   {
      return StringFormat("Confluence: %.1f%% | Indicators: %d | TFs: %d | Level: %s | Quality: %s | TF Alignment: %s",
                         weighted_score, indicator_count, timeframe_count, 
                         ConfluenceLevelToString(GetConfluenceLevel()),
                         SignalQualityToString(GetQualityLevel()),
                         TimeframeAlignmentToString(GetTimeframeAlignment()));
   }
};

//+------------------------------------------------------------------+
//| Gösterge Ağırlık Yapısı                                        |
//+------------------------------------------------------------------+
struct IndicatorWeight
{
   string                indicator_name;         // Gösterge adı
   ENUM_INDICATOR_TYPE   indicator_type;         // Gösterge türü
   double                base_weight;            // Temel ağırlık
   double                market_condition_multiplier; // Market koşulu çarpanı
   double                timeframe_multiplier;   // Zaman çerçevesi çarpanı
   double                reliability_factor;     // Güvenilirlik faktörü
   bool                  is_primary;             // Ana gösterge mi?
   
   IndicatorWeight()
   {
      indicator_name = "";
      indicator_type = INDICATOR_TREND;
      base_weight = 1.0;
      market_condition_multiplier = 1.0;
      timeframe_multiplier = 1.0;
      reliability_factor = 1.0;
      is_primary = false;
   }
   
   double GetEffectiveWeight() const
   {
      return base_weight * market_condition_multiplier * timeframe_multiplier * reliability_factor;
   }
   
   string ToString() const
   {
      return StringFormat("%s (%s) | Weight: %.2f | Primary: %s | Effective: %.2f",
                         indicator_name, IndicatorTypeToString(indicator_type),
                         base_weight, (is_primary ? "Yes" : "No"), GetEffectiveWeight());
   }
};

//+------------------------------------------------------------------+
//| Gelişmiş Sinyal Bilgi Yapısı - GÜVENLİK İYİLEŞTİRMELİ         |
//+------------------------------------------------------------------+
struct SignalInfo
{
   ENUM_SIGNAL_TYPE      signal_type;        // Sinyal türü
   ENUM_SIGNAL_STRENGTH  signal_strength;    // Sinyal gücü
   ENUM_TREND_DIRECTION  trend_direction;    // Trend yönü
   ENUM_TREND_STRENGTH   trend_strength;     // Trend gücü
   ENUM_SIGNAL_QUALITY   signal_quality;     // Sinyal kalitesi
   ENUM_SIGNAL_TIMING    signal_timing;      // Sinyal zamanlama
   ENUM_RISK_LEVEL       risk_level;         // Risk seviyesi
   
   double                confidence;         // Güven oranı (0.0-1.0)
   double                probability;        // Başarı olasılığı (0.0-1.0)
   double                expected_return;    // Beklenen getiri
   double                risk_reward_ratio;  // Risk/Ödül oranı
   double                entry_price;        // Giriş fiyatı
   double                stop_loss;          // Stop loss
   double                take_profit;        // Take profit
   double                position_size;      // Pozisyon boyutu
   
   // Gelişmiş confluence bilgileri
   ConfluenceInfo        confluence;         // Confluence detayları
   double                confluence_score;   // Hızlı erişim için skor
   int                   confluence_count;   // Geriye uyumluluk için
   int                   timeframe_count;    // Geriye uyumluluk için
   
   datetime              signal_time;        // Sinyal zamanı
   datetime              expiry_time;        // Geçerlilik süresi
   string                description;        // Sinyal açıklaması
   string                source_indicators;  // Kaynak göstergeler
   
   // Constructor
   SignalInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      signal_type = SIGNAL_NONE;
      signal_strength = SIGNAL_STRENGTH_NONE;
      trend_direction = TREND_UNDEFINED;
      trend_strength = TREND_STRENGTH_NONE;
      signal_quality = SIGNAL_QUALITY_VERY_POOR;
      signal_timing = SIGNAL_TIMING_LATE;
      risk_level = RISK_MEDIUM;
      
      confidence = 0.0;
      probability = 0.0;
      expected_return = 0.0;
      risk_reward_ratio = 0.0;
      entry_price = 0.0;
      stop_loss = 0.0;
      take_profit = 0.0;
      position_size = 0.0;
      
      confluence.Reset();
      confluence_score = 0.0;
      confluence_count = 0;
      timeframe_count = 0;
      signal_time = 0;
      expiry_time = 0;
      description = "";
      source_indicators = "";
   }
   
   // KAPSAMLI VALIDATION - MQL5 UYUMLU
   bool IsValid() const
   {
      ResetLastErrorCode();
      
      // Temel validations
      if(signal_type == SIGNAL_NONE)
      {
         Print("ERROR: Signal type is NONE");
         return false;
      }
      
      if(confidence <= 0.0 || confidence > 1.0)
      {
         Print(StringFormat("ERROR: Invalid confidence: %.3f", confidence));
         return false;
      }
      
      if(signal_time <= 0)
      {
         Print("ERROR: Invalid signal time");
         return false;
      }
      
      if(confluence_score < 0.0 || confluence_score > 100.0)
      {
         Print(StringFormat("ERROR: Invalid confluence score: %.2f", confluence_score));
         return false;
      }
      
      // Price validations
      if(entry_price <= 0.0)
      {
         Print(StringFormat("ERROR: Invalid entry price: %.5f", entry_price));
         return false;
      }
      
      if(stop_loss < 0.0)
      {
         Print(StringFormat("ERROR: Invalid stop loss: %.5f", stop_loss));
         return false;
      }
      
      if(take_profit < 0.0)
      {
         Print(StringFormat("ERROR: Invalid take profit: %.5f", take_profit));
         return false;
      }
      
      // Risk/Reward validation
      if(risk_reward_ratio < 0.0)
      {
         Print(StringFormat("ERROR: Invalid risk/reward ratio: %.2f", risk_reward_ratio));
         return false;
      }
      
      // Position size validation
      if(position_size < 0.0 || position_size > 1.0)
      {
         Print(StringFormat("ERROR: Invalid position size: %.4f", position_size));
         return false;
      }
      
      // Confluence validation
      if(!confluence.IsValid())
      {
         Print("ERROR: Invalid confluence info");
         return false;
      }
      
      int last_error = GetLastErrorCode();
      if(last_error != 0)
      {
         Print(StringFormat("WARNING: MQL5 error during validation: %d", last_error));
      }
      
      return true;
   }
   
   // GÜVENLİ EXPIRY CHECK
   bool IsExpired() const
   {
      if(expiry_time <= 0)
         return false; // Expiry time set edilmemişse expired değil
      
      datetime current_time = TimeCurrent();
      if(current_time <= 0)
      {
         Print("ERROR: Cannot get current time");
         return true; // Sistem zamanı alınamazsa güvenli tarafta kal
      }
      
      return (current_time > expiry_time);
   }
   
   // GÜVENLİ CONFIDENCE UPDATE
   bool UpdateConfidenceFromConfluence()
   {
      if(confluence_score <= 0.0)
      {
         Print("WARNING: Zero confluence score, cannot update confidence");
         return false;
      }
      
      double old_confidence = confidence;
      
      double confluence_factor = MathMax(0.1, MathMin(1.0, confluence_score / 100.0));
      confidence = MathMax(0.1, MathMin(1.0, confidence * (0.5 + confluence_factor)));
      
      signal_quality = confluence.GetQualityLevel();
      
      ENUM_CONFLUENCE_LEVEL conf_level = confluence.GetConfluenceLevel();
      double multiplier = 1.0;
      
      switch(conf_level)
      {
         case CONFLUENCE_VERY_STRONG:
         case CONFLUENCE_UNANIMOUS:
            multiplier = 1.15;
            break;
         case CONFLUENCE_STRONG:
            multiplier = 1.10;
            break;
         case CONFLUENCE_MODERATE:
            multiplier = 1.05;
            break;
         case CONFLUENCE_WEAK:
            multiplier = 0.95;
            break;
         case CONFLUENCE_NONE:
            multiplier = 0.8;
            break;
      }
      
      confidence = MathMax(0.1, MathMin(1.0, confidence * multiplier));
      
      Print(StringFormat("Confidence updated: %.3f -> %.3f (confluence: %.1f%%)", 
                        old_confidence, confidence, confluence_score));
      
      return true;
   }
   
   string ToString() const
   {
      return StringFormat("%s | %s | Conf:%.2f | Confluence:%.1f%% | R/R:%.2f | %s",
                         SignalTypeToString(signal_type),
                         SignalStrengthToString(signal_strength),
                         confidence,
                         confluence_score,
                         risk_reward_ratio,
                         TimeToString(signal_time));
   }
   
   string GetDetailedReport() const
   {
      string report = "=== SIGNAL DETAILED REPORT ===\n";
      report += StringFormat("Signal Type: %s\n", SignalTypeToString(signal_type));
      report += StringFormat("Signal Strength: %s\n", SignalStrengthToString(signal_strength));
      report += StringFormat("Trend: %s (%s)\n", TrendDirectionToString(trend_direction), TrendStrengthToString(trend_strength));
      report += StringFormat("Quality: %s\n", SignalQualityToString(signal_quality));
      report += StringFormat("Risk Level: %s\n", RiskLevelToString(risk_level));
      report += StringFormat("Confidence: %.2f%% | Probability: %.2f%%\n", confidence * 100.0, probability * 100.0);
      report += StringFormat("Entry: %.5f | SL: %.5f | TP: %.5f\n", entry_price, stop_loss, take_profit);
      report += StringFormat("Risk/Reward: %.2f | Position Size: %.4f\n", risk_reward_ratio, position_size);
      report += StringFormat("Time: %s | Expiry: %s\n", TimeToString(signal_time), TimeToString(expiry_time));
      report += "Confluence Details:\n" + confluence.ToString() + "\n";
      report += StringFormat("Source Indicators: %s\n", source_indicators);
      report += StringFormat("Description: %s\n", description);
      
      return report;
   }
};

//+------------------------------------------------------------------+
//| Confluence Hesaplama Motoru - GÜVENLİK İYİLEŞTİRMELİ          |
//+------------------------------------------------------------------+
class ConfluenceEngine
{
private:
   IndicatorWeight       m_weights[50];         // Gösterge ağırlıkları
   int                   m_weight_count;        // Ağırlık sayısı
   ENUM_MARKET_CONDITION m_market_condition;   // Mevcut market durumu
   bool                  m_initialized;         // Başlatılma durumu
   
public:
   ConfluenceEngine()
   {
      m_weight_count = 0;
      m_market_condition = MARKET_RANGING;
      m_initialized = false;
      
      ResetLastErrorCode();
      
      if(!InitializeDefaultWeights())
      {
         Print("ERROR: Failed to initialize default weights");
         return;
      }
      
      m_initialized = true;
      Print("ConfluenceEngine initialized successfully");
   }
   
   ~ConfluenceEngine() 
   {
      m_initialized = false;
      Print("ConfluenceEngine destroyed");
   }
   
   bool IsInitialized() const
   {
      return m_initialized;
   }
   
   bool InitializeDefaultWeights()
   {
      ResetLastErrorCode();
      
      // Trend göstergeleri
      if(!AddIndicatorWeight("MA_Cross", INDICATOR_TREND, 2.5, true)) return false;
      if(!AddIndicatorWeight("ADX", INDICATOR_TREND, 2.2, false)) return false;
      if(!AddIndicatorWeight("Ichimoku", INDICATOR_TREND, 2.8, true)) return false;
      if(!AddIndicatorWeight("Parabolic_SAR", INDICATOR_TREND, 1.8, false)) return false;
      
      // Momentum göstergeleri
      if(!AddIndicatorWeight("MACD", INDICATOR_MOMENTUM, 2.0, true)) return false;
      if(!AddIndicatorWeight("RSI", INDICATOR_MOMENTUM, 1.5, false)) return false;
      if(!AddIndicatorWeight("Stochastic", INDICATOR_MOMENTUM, 1.5, false)) return false;
      if(!AddIndicatorWeight("Williams_R", INDICATOR_MOMENTUM, 1.3, false)) return false;
      if(!AddIndicatorWeight("ROC", INDICATOR_MOMENTUM, 1.2, false)) return false;
      
      // Volatilite göstergeleri
      if(!AddIndicatorWeight("Bollinger_Bands", INDICATOR_VOLATILITY, 1.8, false)) return false;
      if(!AddIndicatorWeight("ATR", INDICATOR_VOLATILITY, 1.4, false)) return false;
      if(!AddIndicatorWeight("Keltner_Channel", INDICATOR_VOLATILITY, 1.6, false)) return false;
      
      // Destek/Direnç göstergeleri
      if(!AddIndicatorWeight("Support_Resistance", INDICATOR_SUPPORT_RESISTANCE, 3.0, true)) return false;
      if(!AddIndicatorWeight("Fibonacci", INDICATOR_SUPPORT_RESISTANCE, 2.0, false)) return false;
      if(!AddIndicatorWeight("Pivot_Points", INDICATOR_SUPPORT_RESISTANCE, 1.8, false)) return false;
      
      // Hacim göstergeleri
      if(!AddIndicatorWeight("Volume", INDICATOR_VOLUME, 1.2, false)) return false;
      if(!AddIndicatorWeight("OBV", INDICATOR_VOLUME, 1.1, false)) return false;
      if(!AddIndicatorWeight("Volume_Profile", INDICATOR_VOLUME, 1.4, false)) return false;
      
      // Osilatör göstergeleri
      if(!AddIndicatorWeight("CCI", INDICATOR_OSCILLATOR, 1.3, false)) return false;
      if(!AddIndicatorWeight("Awesome_Oscillator", INDICATOR_OSCILLATOR, 1.2, false)) return false;
      
      // AI/ML göstergeleri
      if(!AddIndicatorWeight("Neural_Network", INDICATOR_AI_ML, 2.2, true)) return false;
      if(!AddIndicatorWeight("ML_Prediction", INDICATOR_AI_ML, 2.0, false)) return false;
      
      // Pattern göstergeleri
      if(!AddIndicatorWeight("Chart_Patterns", INDICATOR_PATTERN, 1.9, false)) return false;
      if(!AddIndicatorWeight("Candlestick_Patterns", INDICATOR_PATTERN, 1.7, false)) return false;
      
      int last_error = GetLastErrorCode();
      if(last_error != 0)
      {
         Print(StringFormat("WARNING: MQL5 error during weight initialization: %d", last_error));
         return false;
      }
      
      Print(StringFormat("Initialized %d default indicator weights", m_weight_count));
      return true;
   }
   
   bool AddIndicatorWeight(string name, ENUM_INDICATOR_TYPE type, double weight, bool is_primary)
   {
      // Input validation
      if(StringLen(name) == 0)
      {
         Print("ERROR: Empty indicator name");
         return false;
      }
      
      if(weight <= 0.0 || weight > 10.0)
      {
         Print(StringFormat("ERROR: Invalid weight value: %.2f", weight));
         return false;
      }
      
      if(m_weight_count >= 50)
      {
         Print("ERROR: Maximum indicator weights reached (50)");
         return false;
      }
      
      if(!IsValidIndicatorType(type))
      {
         Print(StringFormat("ERROR: Invalid indicator type: %d", (int)type));
         return false;
      }
      
      // Duplicate check
      for(int i = 0; i < m_weight_count; i++)
      {
         if(m_weights[i].indicator_name == name)
         {
            Print(StringFormat("WARNING: Indicator '%s' already exists. Updating...", name));
            m_weights[i].base_weight = weight;
            m_weights[i].indicator_type = type;
            m_weights[i].is_primary = is_primary;
            m_weights[i].reliability_factor = CalculateReliabilityFactor(type);
            return true;
         }
      }
      
      // Add new weight
      m_weights[m_weight_count].indicator_name = name;
      m_weights[m_weight_count].indicator_type = type;
      m_weights[m_weight_count].base_weight = weight;
      m_weights[m_weight_count].is_primary = is_primary;
      m_weights[m_weight_count].reliability_factor = CalculateReliabilityFactor(type);
      m_weights[m_weight_count].market_condition_multiplier = 1.0;
      m_weights[m_weight_count].timeframe_multiplier = 1.0;
      
      m_weight_count++;
      
      return true;
   }
   
   void UpdateMarketCondition(ENUM_MARKET_CONDITION condition)
   {
      if(!m_initialized)
      {
         Print("ERROR: ConfluenceEngine not initialized");
         return;
      }
      
      m_market_condition = condition;
      AdjustWeightsForMarketCondition();
      
      Print(StringFormat("Market condition updated to: %s", MarketConditionToString(condition)));
   }
   
   void AdjustWeightsForMarketCondition()
   {
      for(int i = 0; i < m_weight_count; i++)
      {
         switch(m_market_condition)
         {
            case MARKET_TRENDING:
               switch(m_weights[i].indicator_type)
               {
                  case INDICATOR_TREND:
                     m_weights[i].market_condition_multiplier = 1.3;
                     break;
                  case INDICATOR_MOMENTUM:
                     m_weights[i].market_condition_multiplier = 1.1;
                     break;
                  case INDICATOR_SUPPORT_RESISTANCE:
                     m_weights[i].market_condition_multiplier = 0.9;
                     break;
                  case INDICATOR_OSCILLATOR:
                     m_weights[i].market_condition_multiplier = 0.8;
                     break;
                  default:
                     m_weights[i].market_condition_multiplier = 0.9;
               }
               break;
               
            case MARKET_RANGING:
               switch(m_weights[i].indicator_type)
               {
                  case INDICATOR_SUPPORT_RESISTANCE:
                     m_weights[i].market_condition_multiplier = 1.4;
                     break;
                  case INDICATOR_OSCILLATOR:
                     m_weights[i].market_condition_multiplier = 1.3;
                     break;
                  case INDICATOR_MOMENTUM:
                     m_weights[i].market_condition_multiplier = 1.2;
                     break;
                  case INDICATOR_TREND:
                     m_weights[i].market_condition_multiplier = 0.7;
                     break;
                  default:
                     m_weights[i].market_condition_multiplier = 0.9;
               }
               break;
               
            case MARKET_VOLATILE:
               switch(m_weights[i].indicator_type)
               {
                  case INDICATOR_VOLATILITY:
                     m_weights[i].market_condition_multiplier = 1.5;
                     break;
                  case INDICATOR_VOLUME:
                     m_weights[i].market_condition_multiplier = 1.3;
                     break;
                  case INDICATOR_AI_ML:
                     m_weights[i].market_condition_multiplier = 1.2;
                     break;
                  case INDICATOR_STATISTICAL:
                     m_weights[i].market_condition_multiplier = 1.1;
                     break;
                  case INDICATOR_OSCILLATOR:
                     m_weights[i].market_condition_multiplier = 0.8;
                     break;
                  default:
                     m_weights[i].market_condition_multiplier = 0.9;
               }
               break;
               
            case MARKET_QUIET:
               switch(m_weights[i].indicator_type)
               {
                  case INDICATOR_PATTERN:
                     m_weights[i].market_condition_multiplier = 1.2;
                     break;
                  case INDICATOR_STATISTICAL:
                     m_weights[i].market_condition_multiplier = 1.1;
                     break;
                  case INDICATOR_VOLUME:
                     m_weights[i].market_condition_multiplier = 0.7;
                     break;
                  case INDICATOR_VOLATILITY:
                     m_weights[i].market_condition_multiplier = 0.6;
                     break;
                  default:
                     m_weights[i].market_condition_multiplier = 1.0;
               }
               break;
               
            default:
               m_weights[i].market_condition_multiplier = 1.0;
         }
      }
   }
   
   double CalculateReliabilityFactor(ENUM_INDICATOR_TYPE type)
   {
      switch(type)
      {
         case INDICATOR_TREND: 
            return 1.2;
         case INDICATOR_SUPPORT_RESISTANCE: 
            return 1.3;
         case INDICATOR_MOMENTUM: 
            return 1.0;
         case INDICATOR_AI_ML: 
            return 1.1;
         case INDICATOR_STATISTICAL: 
            return 1.1;
         case INDICATOR_PATTERN: 
            return 1.0;
         case INDICATOR_VOLATILITY: 
            return 0.9;
         case INDICATOR_OSCILLATOR: 
            return 0.9;
         case INDICATOR_VOLUME: 
            return 0.8;
         case INDICATOR_CYCLE: 
            return 0.8;
         case INDICATOR_BREADTH: 
            return 0.7;
         case INDICATOR_SENTIMENT: 
            return 0.7;
         case INDICATOR_FUNDAMENTAL: 
            return 0.9;
         case INDICATOR_CUSTOM: 
            return 0.8;
         default: 
            return 1.0;
      }
   }
   
   ConfluenceInfo CalculateConfluence(const string &indicators[], const double &scores[], 
                                     const ENUM_TIMEFRAMES &timeframes[], const double &tf_scores[],
                                     const int indicator_count, const int tf_count)
   {
      ConfluenceInfo confluence;
      confluence.Reset();
      
      if(!m_initialized)
      {
         Print("ERROR: ConfluenceEngine not initialized");
         return confluence;
      }
      
      ResetLastErrorCode();
      
      // Input validation
      if(indicator_count <= 0 || tf_count <= 0)
      {
         Print("ERROR: Invalid input counts for confluence calculation");
         return confluence;
      }
      
      if(indicator_count > 100)
      {
         Print(StringFormat("ERROR: Too many indicators: %d (max 100)", indicator_count));
         return confluence;
      }
      
      if(tf_count > 10)
      {
         Print(StringFormat("ERROR: Too many timeframes: %d (max 10)", tf_count));
         return confluence;
      }
      
      // Validate arrays
      for(int i = 0; i < indicator_count; i++)
      {
         if(StringLen(indicators[i]) == 0)
         {
            Print(StringFormat("ERROR: Empty indicator name at index %d", i));
            return confluence;
         }
         
         if(scores[i] < 0.0 || scores[i] > 100.0)
         {
            Print(StringFormat("ERROR: Invalid score %.2f for indicator %s", scores[i], indicators[i]));
            return confluence;
         }
      }
      
      for(int i = 0; i < tf_count; i++)
      {
         if(tf_scores[i] < 0.0 || tf_scores[i] > 100.0)
         {
            Print(StringFormat("ERROR: Invalid TF score %.2f at index %d", tf_scores[i], i));
            return confluence;
         }
      }
      
      // Gösterge skorlarını hesapla
      double total_weighted_score = 0.0;
      double total_weight = 0.0;
      
      for(int i = 0; i < indicator_count; i++)
      {
         double weight = GetIndicatorWeight(indicators[i]);
         double adjusted_score = scores[i] * weight;
         
         total_weighted_score += adjusted_score;
         total_weight += weight;
         
         ENUM_INDICATOR_TYPE ind_type = GetIndicatorType(indicators[i]);
         UpdateCategoryScore(confluence, ind_type, adjusted_score / weight);
         
         if(scores[i] >= 70.0)
         {
            confluence.AddStrongSignal(indicators[i]);
         }
         else if(scores[i] <= 30.0)
         {
            confluence.AddWeakSignal(indicators[i]);
         }
      }
      
      // Zaman çerçevesi skorlarını hesapla
      double tf_weighted_score = 0.0;
      double tf_total_weight = 0.0;
      
      for(int i = 0; i < tf_count; i++)
      {
         double tf_weight = GetTimeframeWeight(timeframes[i]);
         tf_weighted_score += tf_scores[i] * tf_weight;
         tf_total_weight += tf_weight;
         
         confluence.AddTimeframeScore(timeframes[i], tf_scores[i]);
      }
      
      // Final skor hesaplama
      double indicator_score = (total_weight > 0) ? (total_weighted_score / total_weight) : 0.0;
      double timeframe_score = (tf_total_weight > 0) ? (tf_weighted_score / tf_total_weight) : 0.0;
      
      confluence.total_score = (indicator_score * 0.7) + (timeframe_score * 0.3);
      
      // Kalite çarpanı hesaplama
      confluence.quality_multiplier = CalculateQualityMultiplier(confluence);
      confluence.weighted_score = confluence.total_score * confluence.quality_multiplier;
      
      // Diğer alanları doldur
      confluence.indicator_count = indicator_count;
      confluence.timeframe_count = tf_count;
      confluence.active_tf_count = tf_count;
      confluence.scoring_details = GenerateScoringDetails(confluence);
      
      // Final validation
      if(!confluence.IsValid())
      {
         Print("ERROR: Generated invalid confluence info");
         confluence.Reset();
         return confluence;
      }
      
      int last_error = GetLastErrorCode();
      if(last_error != 0)
      {
         Print(StringFormat("WARNING: MQL5 error during confluence calculation: %d", last_error));
      }
      
      Print(StringFormat("Confluence calculated: %.2f%% (%d indicators, %d TFs)", 
                        confluence.weighted_score, indicator_count, tf_count));
      
      return confluence;
   }
   
   double GetIndicatorWeight(const string indicator_name)
   {
      for(int i = 0; i < m_weight_count; i++)
      {
         if(m_weights[i].indicator_name == indicator_name)
         {
            return m_weights[i].GetEffectiveWeight();
         }
      }
      return 1.0;
   }
   
   ENUM_INDICATOR_TYPE GetIndicatorType(const string indicator_name)
   {
      for(int i = 0; i < m_weight_count; i++)
      {
         if(m_weights[i].indicator_name == indicator_name)
            return m_weights[i].indicator_type;
      }
      return INDICATOR_CUSTOM;
   }
   
   double GetTimeframeWeight(ENUM_TIMEFRAMES timeframe)
   {
      switch(timeframe)
      {
         case PERIOD_M1:  return 0.3;
         case PERIOD_M5:  return 0.5;
         case PERIOD_M15: return 0.8;
         case PERIOD_M30: return 1.0;
         case PERIOD_H1:  return 1.2;
         case PERIOD_H4:  return 1.5;
         case PERIOD_D1:  return 1.8;
         case PERIOD_W1:  return 2.0;
         case PERIOD_MN1: return 1.5;
         default: return 1.0;
      }
   }
   
   void UpdateCategoryScore(ConfluenceInfo &confluence, ENUM_INDICATOR_TYPE type, double score)
   {
      switch(type)
      {
         case INDICATOR_TREND:
            confluence.trend_score = MathMax(confluence.trend_score, score);
            break;
         case INDICATOR_MOMENTUM:
         case INDICATOR_OSCILLATOR:
            confluence.momentum_score = MathMax(confluence.momentum_score, score);
            break;
         case INDICATOR_VOLUME:
            confluence.volume_score = MathMax(confluence.volume_score, score);
            break;
         case INDICATOR_VOLATILITY:
            confluence.volatility_score = MathMax(confluence.volatility_score, score);
            break;
         case INDICATOR_SUPPORT_RESISTANCE:
            confluence.support_resistance_score = MathMax(confluence.support_resistance_score, score);
            break;
         case INDICATOR_AI_ML:
         case INDICATOR_STATISTICAL:
         case INDICATOR_PATTERN:
         case INDICATOR_CUSTOM:
            confluence.trend_score = MathMax(confluence.trend_score, score * 0.8);
            break;
         case INDICATOR_SENTIMENT:
         case INDICATOR_FUNDAMENTAL:
            confluence.momentum_score = MathMax(confluence.momentum_score, score * 0.9);
            break;
         case INDICATOR_CYCLE:
         case INDICATOR_BREADTH:
            confluence.volatility_score = MathMax(confluence.volatility_score, score * 0.7);
            break;
      }
   }
   
   double CalculateQualityMultiplier(const ConfluenceInfo &confluence)
   {
      double multiplier = 1.0;
      
      if(confluence.strong_count >= 3)
         multiplier += 0.15;
      else if(confluence.strong_count >= 2)
         multiplier += 0.10;
      else if(confluence.strong_count >= 1)
         multiplier += 0.05;
      
      int active_categories = 0;
      if(confluence.trend_score > 0) active_categories++;
      if(confluence.momentum_score > 0) active_categories++;
      if(confluence.volume_score > 0) active_categories++;
      if(confluence.volatility_score > 0) active_categories++;
      if(confluence.support_resistance_score > 0) active_categories++;
      
      if(active_categories >= 4)
         multiplier += 0.12;
      else if(active_categories >= 3)
         multiplier += 0.08;
      else if(active_categories >= 2)
         multiplier += 0.04;
      
      if(confluence.weak_count >= 2)
         multiplier -= 0.10;
      else if(confluence.weak_count >= 1)
         multiplier -= 0.05;
      
      return MathMax(multiplier, 0.5);
   }
   
   string GenerateScoringDetails(const ConfluenceInfo &confluence)
   {
      string details = StringFormat("Total Score: %.1f%% | Quality: %.2fx\n",
                                   confluence.total_score, confluence.quality_multiplier);
      
      details += StringFormat("Categories - Trend:%.1f Momentum:%.1f Volume:%.1f Volatility:%.1f S/R:%.1f\n",
                             confluence.trend_score, confluence.momentum_score, 
                             confluence.volume_score, confluence.volatility_score,
                             confluence.support_resistance_score);
      
      details += StringFormat("Strong Signals: %d | Weak Signals: %d",
                             confluence.strong_count, confluence.weak_count);
      
      return details;
   }
   
   ENUM_MARKET_CONDITION GetMarketCondition() const
   {
      return m_market_condition;
   }
   
   int GetWeightCount() const
   {
      return m_weight_count;
   }
   
   IndicatorWeight GetWeight(int index) const
   {
      IndicatorWeight empty;
      if(index < 0 || index >= m_weight_count)
         return empty;
      return m_weights[index];
   }
};

//+------------------------------------------------------------------+
//| Global Confluence Helper Functions                              |
//+------------------------------------------------------------------+

// Tip bilgisi ile ağırlıklı confluence hesaplama
double CalculateQuickConfluence(const double &scores[], const int count, const ENUM_INDICATOR_TYPE &types[])
{
   if(count <= 0) return 0.0;
   
   double weighted_sum = 0.0;
   double weight_sum = 0.0;
   
   for(int i = 0; i < count; i++)
   {
      double weight = 1.0;
      
      if(IsValidIndicatorType(types[i]))
      {
         switch(types[i])
         {
            case INDICATOR_TREND:
            case INDICATOR_SUPPORT_RESISTANCE:
               weight = 1.3;
               break;
            case INDICATOR_AI_ML:
            case INDICATOR_STATISTICAL:
               weight = 1.2;
               break;
            case INDICATOR_MOMENTUM:
            case INDICATOR_PATTERN:
               weight = 1.0;
               break;
            case INDICATOR_VOLATILITY:
            case INDICATOR_OSCILLATOR:
               weight = 0.9;
               break;
            case INDICATOR_VOLUME:
            case INDICATOR_CYCLE:
               weight = 0.8;
               break;
            default:
               weight = 0.7;
         }
      }
      
      weighted_sum += scores[i] * weight;
      weight_sum += weight;
   }
   
   return (weight_sum > 0) ? (weighted_sum / weight_sum) : 0.0;
}

// Basit confluence hesaplama (tip bilgisi olmadan)
double CalculateQuickConfluence(const double &scores[], const int count)
{
   if(count <= 0) return 0.0;
   
   double sum = 0.0;
   for(int i = 0; i < count; i++)
   {
      sum += scores[i];
   }
   
   return sum / count;
}

//+------------------------------------------------------------------+
//| Gelişmiş Sinyal Sağlayıcı Interface - MQL5 UYUMLU             |
//+------------------------------------------------------------------+
class ISignalProvider
{
protected:
   ProviderConfig        m_config;         // Konfigürasyon
   PerformanceStats      m_stats;          // Performans istatistikleri
   MLModelInfo           m_ml_info;        // ML model bilgisi
   ConfluenceEngine*     m_confluence_engine; // Confluence motoru
   string                m_symbol;         // İşlem sembolü
   bool                  m_initialized;    // Başlatılma durumu
   bool                  m_enabled;        // Etkinlik durumu
   
   // Performance monitoring
   datetime              m_last_performance_check;
   int                   m_last_objects_total;

public:
   //+------------------------------------------------------------------+
   //| Constructor & Destructor - MQL5 UYUMLU                          |
   //+------------------------------------------------------------------+
   ISignalProvider() : m_symbol(_Symbol), m_initialized(false), m_enabled(false)
   {
      ResetLastErrorCode();
      
      // Struct'ları güvenli şekilde sıfırla
      m_config.Reset();
      m_stats.Reset();
      m_ml_info.Reset();
      
      // Performance monitoring initialize
      m_last_performance_check = 0;
      m_last_objects_total = 0;
      
      // Confluence engine oluştur ve kontrol et
      m_confluence_engine = new ConfluenceEngine();
      
      if(!CHECK_POINTER(m_confluence_engine))
      {
         Print("CRITICAL ERROR: Failed to create ConfluenceEngine!");
         m_initialized = false;
         m_enabled = false;
         return;
      }
      
      // Başlangıç doğrulaması
      if(!ValidateInitialState())
      {
         Print("ERROR: Initial state validation failed!");
         m_initialized = false;
         return;
      }
      
      int last_error = GetLastErrorCode();
      if(last_error != 0)
      {
         Print(StringFormat("WARNING: MQL5 error during initialization: %d", last_error));
      }
      
      m_initialized = true;
      Print(StringFormat("SignalProvider initialized successfully. Symbol: %s", m_symbol));
   }
   
   virtual ~ISignalProvider() 
   { 
      SafeCleanup();
   }

private:
   void SafeCleanup()
   {
      ResetLastErrorCode();
      
      // Confluence engine'i güvenli şekilde temizle
      if(CHECK_POINTER(m_confluence_engine))
      {
         Print("Cleaning up ConfluenceEngine...");
         SAFE_DELETE(m_confluence_engine);
      }
      
      // Performance stats'ı kaydet
      if(m_stats.total_signals > 0)
      {
         Print(StringFormat("Final Performance: %s", m_stats.ToString()));
      }
      
      // State'i güvenli hale getir
      m_initialized = false;
      m_enabled = false;
      
      int last_error = GetLastErrorCode();
      if(last_error != 0)
      {
         Print(StringFormat("WARNING: MQL5 error during cleanup: %d", last_error));
      }
      
      Print("SignalProvider cleanup completed successfully.");
   }
   
   bool ValidateInitialState()
   {
      if(StringLen(m_symbol) == 0)
      {
         Print("ERROR: Empty symbol");
         return false;
      }
      
      if(!m_config.IsValid())
      {
         Print("ERROR: Invalid configuration");
         return false;
      }
      
      // Symbol market info kontrolü
      ResetLastErrorCode();
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      
      int last_error = GetLastErrorCode();
      if(last_error != 0)
      {
         Print(StringFormat("ERROR: Cannot get symbol info for %s, error: %d", m_symbol, last_error));
         return false;
      }
      
      if(point <= 0.0)
      {
         Print(StringFormat("ERROR: Invalid symbol or market closed: %s", m_symbol));
         return false;
      }
      
      return true;
   }

public:
   //+------------------------------------------------------------------+
   //| Memory & Performance Monitoring - MQL5 UYUMLU                   |
   //+------------------------------------------------------------------+
   void CheckMemoryLeaks()
   {
      int current_objects = GetObjectsTotal();
      
      if(current_objects > m_last_objects_total + 10)
      {
         Print(StringFormat("WARNING: Possible memory leak detected. Objects: %d (was %d)", 
                           current_objects, m_last_objects_total));
      }
      
      m_last_objects_total = current_objects;
   }
   
   void MonitorPerformance()
   {
      datetime current_time = TimeCurrent();
      
      if(current_time - m_last_performance_check > 3600) // Her saat
      {
         CheckMemoryLeaks();
         
         if(m_stats.total_signals > 0)
         {
            Print(StringFormat("Performance Check: %s", m_stats.ToString()));
         }
         
         if(CHECK_POINTER(m_confluence_engine))
         {
            Print(StringFormat("ConfluenceEngine status: Initialized=%s, Weights=%d", 
                              (m_confluence_engine.IsInitialized() ? "Yes" : "No"),
                              m_confluence_engine.GetWeightCount()));
         }
         
         m_last_performance_check = current_time;
      }
   }

   //+------------------------------------------------------------------+
   //| Confluence Interface Metodları - MQL5 UYUMLU                   |
   //+------------------------------------------------------------------+
   
   virtual ConfluenceInfo CalculateSignalConfluence(const string &indicators[], const double &scores[],
                                                    const ENUM_TIMEFRAMES &timeframes[], const double &tf_scores[],
                                                    const int indicator_count, const int tf_count)
   {
      ConfluenceInfo empty;
      
      if(!CHECK_POINTER(m_confluence_engine))
      {
         Print("ERROR: ConfluenceEngine not available");
         return empty;
      }
      
      if(!m_confluence_engine.IsInitialized())
      {
         Print("ERROR: ConfluenceEngine not initialized");
         return empty;
      }
      
      return m_confluence_engine.CalculateConfluence(indicators, scores, timeframes, tf_scores,
                                                    indicator_count, tf_count);
   }
   
   virtual void UpdateMarketCondition(ENUM_MARKET_CONDITION condition)
   {
      if(CHECK_POINTER(m_confluence_engine))
         m_confluence_engine.UpdateMarketCondition(condition);
   }
   
   virtual bool AddCustomIndicatorWeight(string name, ENUM_INDICATOR_TYPE type, double weight, bool is_primary = false)
   {
      if(CHECK_POINTER(m_confluence_engine))
         return m_confluence_engine.AddIndicatorWeight(name, type, weight, is_primary);
      return false;
   }
   
   virtual double GetQuickConfluenceScore(const string &indicators[], const double &scores[], const int count)
   {
      if(count <= 0) return 0.0;
      
      if(CHECK_POINTER(m_confluence_engine))
      {
         ENUM_INDICATOR_TYPE types[];
         ArrayResize(types, count);
         
         for(int i = 0; i < count; i++)
         {
            types[i] = m_confluence_engine.GetIndicatorType(indicators[i]);
         }
         
         return CalculateQuickConfluence(scores, count, types);
      }
      
      return CalculateQuickConfluence(scores, count);
   }
   
   virtual bool ValidateSignalWithConfluence(SignalInfo &signal)
   {
      if(!ValidateSignal(signal))
         return false;
      
      signal.confluence_score = signal.confluence.weighted_score;
      signal.confluence_count = signal.confluence.indicator_count;
      signal.timeframe_count = signal.confluence.timeframe_count;
      
      if(!signal.UpdateConfidenceFromConfluence())
      {
         Print("ERROR: Failed to update confidence from confluence");
         return false;
      }
      
      if(signal.confluence_score < m_config.min_confluence_score)
      {
         Print(StringFormat("Signal rejected: confluence score %.2f < minimum %.2f", 
                           signal.confluence_score, m_config.min_confluence_score));
         return false;
      }
      
      if(signal.confluence.GetQualityLevel() < m_config.min_signal_quality)
      {
         Print(StringFormat("Signal rejected: quality %s < minimum %s", 
                           SignalQualityToString(signal.confluence.GetQualityLevel()),
                           SignalQualityToString(m_config.min_signal_quality)));
         return false;
      }
      
      if(signal.confluence.GetConfluenceLevel() < m_config.min_confluence_level)
      {
         Print(StringFormat("Signal rejected: confluence level %s < minimum %s", 
                           ConfluenceLevelToString(signal.confluence.GetConfluenceLevel()),
                           ConfluenceLevelToString(m_config.min_confluence_level)));
         return false;
      }
      
      return true;
   }

   //+------------------------------------------------------------------+
   //| Temel Interface Metodları (Pure Virtual)                        |
   //+------------------------------------------------------------------+
   
   virtual bool Initialize(const ProviderConfig &config) = 0;
   virtual void Deinitialize() = 0;
   virtual bool IsInitialized() const { return m_initialized; }
   
   virtual SignalInfo GenerateSignal() = 0;
   virtual SignalInfo GenerateSignal(ENUM_TIMEFRAMES timeframe) = 0;
   virtual bool ValidateSignal(const SignalInfo &signal) = 0;
   
   virtual SignalInfo GenerateConfluenceSignal() 
   {
      SignalInfo signal = GenerateSignal();
      if(signal.IsValid())
      {
         ValidateSignalWithConfluence(signal);
      }
      return signal;
   }
   
   virtual ENUM_TREND_DIRECTION AnalyzeTrend() = 0;
   virtual ENUM_TREND_DIRECTION AnalyzeTrend(ENUM_TIMEFRAMES timeframe) = 0;
   virtual ENUM_TREND_STRENGTH CalculateTrendStrength() = 0;
   virtual ENUM_TREND_STRENGTH CalculateTrendStrength(ENUM_TIMEFRAMES timeframe) = 0;
   
   virtual SignalInfo GenerateMultiTimeframeSignal() = 0;
   virtual bool GetTimeframeConsensus(ENUM_SIGNAL_TYPE &consensus_signal, double &consensus_strength) = 0;
   virtual int GetTimeframeAlignment() = 0;
   
   virtual double CalculatePositionSize(const SignalInfo &signal) = 0;
   virtual double CalculateStopLoss(const SignalInfo &signal) = 0;
   virtual double CalculateTakeProfit(const SignalInfo &signal) = 0;
   virtual ENUM_RISK_LEVEL AssessRisk(const SignalInfo &signal) = 0;
   
   virtual ENUM_RISK_LEVEL AssessRiskWithConfluence(const SignalInfo &signal)
   {
      ENUM_RISK_LEVEL base_risk = AssessRisk(signal);
      
      if(signal.confluence_score >= 80.0 && signal.confluence.strong_count >= 3)
      {
         if(base_risk == RISK_HIGH) return RISK_MEDIUM;
         if(base_risk == RISK_MEDIUM) return RISK_LOW;
         if(base_risk == RISK_LOW) return RISK_VERY_LOW;
      }
      else if(signal.confluence_score <= 40.0 || signal.confluence.weak_count >= 2)
      {
         if(base_risk == RISK_VERY_LOW) return RISK_LOW;
         if(base_risk == RISK_LOW) return RISK_MEDIUM;
         if(base_risk == RISK_MEDIUM) return RISK_HIGH;
         if(base_risk == RISK_HIGH) return RISK_VERY_HIGH;
      }
      
      return base_risk;
   }
   
   virtual bool TrainModel(const string data_file = "") = 0;
   virtual bool UpdateModel() = 0;
   virtual double GetModelConfidence() = 0;
   virtual ENUM_ML_MODEL_STATE GetModelState() = 0;
   virtual bool AdaptToMarketConditions() = 0;

   //+------------------------------------------------------------------+
   //| Gelişmiş Confluence Filtreleme                                  |
   //+------------------------------------------------------------------+
   
   virtual bool FilterSignalByConfluence(const SignalInfo &signal)
   {
      if(signal.confluence_score < m_config.min_confluence_score)
         return false;
      
      if(signal.confluence.GetQualityLevel() < m_config.min_signal_quality)
         return false;
      
      if(signal.confluence.GetConfluenceLevel() < m_config.min_confluence_level)
         return false;
      
      if(signal.confluence.indicator_count < 2)
         return false;
      
      int active_categories = 0;
      if(signal.confluence.trend_score > 0) active_categories++;
      if(signal.confluence.momentum_score > 0) active_categories++;
      if(signal.confluence.support_resistance_score > 0) active_categories++;
      if(signal.confluence.volume_score > 0) active_categories++;
      if(signal.confluence.volatility_score > 0) active_categories++;
      
      if(active_categories < 2)
         return false;
      
      ENUM_TIMEFRAME_ALIGNMENT tf_alignment = signal.confluence.GetTimeframeAlignment();
      if(tf_alignment == TF_ALIGNMENT_CONFLICTING)
         return false;
      
      if(signal.confluence.weak_count > signal.confluence.strong_count)
         return false;
      
      return true;
   }
   
   virtual SignalInfo CombineSignalsWithConfluence(const SignalInfo &signal1, const SignalInfo &signal2)
   {
      SignalInfo combined;
      
      if(signal1.confluence_score >= signal2.confluence_score)
         combined = signal1;
      else
         combined = signal2;
      
      combined.confluence.indicator_count = signal1.confluence.indicator_count + signal2.confluence.indicator_count;
      combined.confluence.total_score = (signal1.confluence_score + signal2.confluence_score) / 2.0;
      combined.confluence.strong_count = signal1.confluence.strong_count + signal2.confluence.strong_count;
      
      double weight1 = signal1.confluence_score / 100.0;
      double weight2 = signal2.confluence_score / 100.0;
      double total_weight = weight1 + weight2;
      
      if(total_weight > 0)
      {
         combined.confidence = (signal1.confidence * weight1 + signal2.confidence * weight2) / total_weight;
         combined.confluence.weighted_score = (signal1.confluence.weighted_score * weight1 + 
                                             signal2.confluence.weighted_score * weight2) / total_weight;
      }
      
      combined.confluence_score = combined.confluence.weighted_score;
      combined.UpdateConfidenceFromConfluence();
      
      combined.source_indicators = signal1.source_indicators + "," + signal2.source_indicators;
      combined.description = "Combined: " + signal1.description + " + " + signal2.description;
      
      return combined;
   }
   
   //+------------------------------------------------------------------+
   //| Performans İzleme - MQL5 UYUMLU                                |
   //+------------------------------------------------------------------+
   
   virtual void UpdatePerformanceWithConfluence(const SignalInfo &signal, const bool success, const double return_pct)
   {
      UpdatePerformanceStats(signal, success, return_pct);
      
      if(success)
      {
         Print(StringFormat("[%s] Successful Signal - Confluence: %.1f%%, Quality: %s, Strong Signals: %d",
                           GetProviderName(), signal.confluence_score, 
                           SignalQualityToString(signal.confluence.GetQualityLevel()),
                           signal.confluence.strong_count));
      }
      else
      {
         Print(StringFormat("[%s] Failed Signal - Confluence: %.1f%%, Weak Signals: %d",
                           GetProviderName(), signal.confluence_score, signal.confluence.weak_count));
      }
   }
   
   virtual void UpdatePerformanceStats(const SignalInfo &signal, const bool success, const double return_pct)
   {
      double signal_duration = (signal.expiry_time > signal.signal_time) ? 
                               ((signal.expiry_time - signal.signal_time) / 60.0) : 60.0;
      
      if(!m_stats.UpdateStats(success, return_pct, signal.confluence_score, signal_duration))
      {
         Print("ERROR: Failed to update performance stats");
      }
   }
   
   //+------------------------------------------------------------------+
   //| Debug ve Log                                                     |
   //+------------------------------------------------------------------+
   
   virtual void LogSignalWithConfluence(const SignalInfo &signal)
   {
      Print(StringFormat("[%s] Signal Details:", GetProviderName()));
      Print("  " + signal.ToString());
      Print("  " + signal.confluence.ToString());
      Print("  " + signal.confluence.scoring_details);
      
      if(signal.confluence.strong_count > 0)
      {
         string strong_list = "Strong Indicators: ";
         for(int i = 0; i < signal.confluence.strong_count && i < 20; i++)
         {
            strong_list += signal.confluence.GetStrongSignal(i);
            if(i < signal.confluence.strong_count - 1) strong_list += ", ";
         }
         Print("  " + strong_list);
      }
   }

   //+------------------------------------------------------------------+
   //| Temel Interface Metodları                                       |
   //+------------------------------------------------------------------+
   
   virtual ProviderConfig GetConfig() const { return m_config; }
   virtual string GetProviderName() const { return m_config.provider_name; }
   virtual string GetProviderVersion() const { return m_config.provider_version; }
   virtual bool IsEnabled() const { return m_enabled; }
   virtual PerformanceStats GetPerformanceStats() const { return m_stats; }
   virtual MLModelInfo GetMLModelInfo() const { return m_ml_info; }
   
   virtual void SetEnabled(bool enabled) { m_enabled = enabled; }
   virtual void Enable() { m_enabled = true; }
   virtual void Disable() { m_enabled = false; }
   
   virtual string GetSymbol() const { return m_symbol; }
   virtual void SetSymbol(const string symbol) { m_symbol = symbol; }
   
   virtual bool UpdateConfig(const ProviderConfig &config)
   {
      if(!config.IsValid())
      {
         Print("ERROR: Invalid configuration provided");
         return false;
      }
      
      m_config = config;
      Print("Configuration updated successfully");
      return true;
   }
};

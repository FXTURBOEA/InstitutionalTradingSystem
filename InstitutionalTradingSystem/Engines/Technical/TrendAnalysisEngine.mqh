﻿//+------------------------------------------------------------------+
//| TrendAnalysisEngine.mqh - Gelişmiş Trend Analiz Motoru        |
//| ISignalProvider Uyumlu - Multi-MA, Ichimoku, ADX Kombine       |
//| Market Structure Analysis + ML Enhanced Trend Detection        |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/Complete_Enum_Types.mqh"
#include "../../Core/ISignalProvider.mqh"

//+------------------------------------------------------------------+
//| Moving Average Bilgi Yapısı                                     |
//+------------------------------------------------------------------+
struct MovingAverageInfo
{
   // EMA değerleri
   double                ema_fast;           // Hızlı EMA (20)
   double                ema_slow;           // Yavaş EMA (50)
   double                ema_trend;          // Trend EMA (200)
   
   // MA ilişkileri
   bool                  golden_cross;       // Altın kesişim
   bool                  death_cross;        // Ölüm kesişimi
   bool                  above_trend_ma;     // Trend MA üstünde
   bool                  ma_alignment_bull;  // Boğa sıralaması
   bool                  ma_alignment_bear;  // Ayı sıralaması
   
   // Slope analizi
   double                fast_slope;         // Hızlı MA eğimi
   double                slow_slope;         // Yavaş MA eğimi
   double                trend_slope;        // Trend MA eğimi
   
   // Distance metrics
   double                price_to_fast_pct;  // Fiyat-hızlı MA mesafesi %
   double                price_to_slow_pct;  // Fiyat-yavaş MA mesafesi %
   double                price_to_trend_pct; // Fiyat-trend MA mesafesi %
   
   MovingAverageInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      ema_fast = ema_slow = ema_trend = 0.0;
      golden_cross = death_cross = false;
      above_trend_ma = false;
      ma_alignment_bull = ma_alignment_bear = false;
      fast_slope = slow_slope = trend_slope = 0.0;
      price_to_fast_pct = price_to_slow_pct = price_to_trend_pct = 0.0;
   }
};

//+------------------------------------------------------------------+
//| Ichimoku Bilgi Yapısı                                          |
//+------------------------------------------------------------------+
struct IchimokuInfo
{
   // Ichimoku çizgileri
   double                tenkan_sen;         // Tenkan-sen (9)
   double                kijun_sen;          // Kijun-sen (26)
   double                senkou_span_a;      // Senkou Span A
   double                senkou_span_b;      // Senkou Span B
   double                chikou_span;        // Chikou Span
   
   // Kumo (bulut) analizi
   bool                  above_kumo;         // Kumo üstünde
   bool                  below_kumo;         // Kumo altında
   bool                  in_kumo;            // Kumo içinde
   double                kumo_thickness;     // Kumo kalınlığı
   bool                  kumo_bullish;       // Boğa kumosu
   
   // Sinyaller
   bool                  tenkan_kijun_cross_bull; // TK boğa kesişimi
   bool                  tenkan_kijun_cross_bear; // TK ayı kesişimi
   bool                  price_above_tenkan;      // Fiyat Tenkan üstünde
   bool                  price_above_kijun;       // Fiyat Kijun üstünde
   bool                  chikou_clear;            // Chikou temiz
   
   // Güç skoru
   double                ichimoku_strength;       // Ichimoku güç skoru (0-100)
   
   IchimokuInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      tenkan_sen = kijun_sen = senkou_span_a = senkou_span_b = chikou_span = 0.0;
      above_kumo = below_kumo = in_kumo = kumo_bullish = false;
      kumo_thickness = 0.0;
      tenkan_kijun_cross_bull = tenkan_kijun_cross_bear = false;
      price_above_tenkan = price_above_kijun = chikou_clear = false;
      ichimoku_strength = 0.0;
   }
};

//+------------------------------------------------------------------+
//| ADX Trend Bilgi Yapısı                                         |
//+------------------------------------------------------------------+
struct ADXTrendInfo
{
   // ADX değerleri
   double                adx_value;          // ADX değeri
   double                di_plus;            // DI+
   double                di_minus;           // DI-
   
   // Trend gücü
   ENUM_TREND_STRENGTH   trend_strength;     // Trend gücü
   bool                  strong_trend;       // Güçlü trend (ADX > 25)
   bool                  very_strong_trend;  // Çok güçlü trend (ADX > 40)
   bool                  weak_trend;         // Zayıf trend (ADX < 20)
   
   // Yön
   bool                  bullish_momentum;   // Boğa momentumu
   bool                  bearish_momentum;   // Ayı momentumu
   bool                  momentum_change;    // Momentum değişimi
   
   // ADX trendi
   bool                  adx_rising;         // ADX yükseliyor
   bool                  adx_falling;        // ADX düşüyor
   double                adx_slope;          // ADX eğimi
   
   ADXTrendInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      adx_value = di_plus = di_minus = 0.0;
      trend_strength = TREND_STRENGTH_NONE;
      strong_trend = very_strong_trend = weak_trend = false;
      bullish_momentum = bearish_momentum = momentum_change = false;
      adx_rising = adx_falling = false;
      adx_slope = 0.0;
   }
};

//+------------------------------------------------------------------+
//| Market Structure Bilgi Yapısı                                  |
//+------------------------------------------------------------------+
struct MarketStructureInfo
{
   // Swing noktaları
   double                last_swing_high;    // Son swing yüksek
   double                last_swing_low;     // Son swing düşük
   datetime              swing_high_time;    // Swing yüksek zamanı
   datetime              swing_low_time;     // Swing düşük zamanı
   
   // Structure patterns
   bool                  higher_highs;       // Yükselen zirveler
   bool                  higher_lows;        // Yükselen dipler
   bool                  lower_highs;        // Düşen zirveler
   bool                  lower_lows;         // Düşen dipler
   
   // Breakout analizi
   bool                  structure_break_up; // Yapı yukarı kırılımı
   bool                  structure_break_down; // Yapı aşağı kırılımı
   double                break_level;        // Kırılım seviyesi
   datetime              break_time;         // Kırılım zamanı
   
   // Support/Resistance
   double                key_resistance;     // Ana direnç
   double                key_support;        // Ana destek
   int                   resistance_touches; // Direnç dokunma sayısı
   int                   support_touches;    // Destek dokunma sayısı
   
   MarketStructureInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      last_swing_high = last_swing_low = 0.0;
      swing_high_time = swing_low_time = 0;
      higher_highs = higher_lows = lower_highs = lower_lows = false;
      structure_break_up = structure_break_down = false;
      break_level = 0.0;
      break_time = 0;
      key_resistance = key_support = 0.0;
      resistance_touches = support_touches = 0;
   }
};

//+------------------------------------------------------------------+
//| Ana Trend Analiz Bilgi Yapısı                                  |
//+------------------------------------------------------------------+
struct TrendAnalysisInfo
{
   // Temel bilgiler
   datetime              calculation_time;   // Hesaplama zamanı
   string                symbol;             // Sembol
   ENUM_TIMEFRAMES       timeframe;          // Zaman çerçevesi
   double                current_price;      // Mevcut fiyat
   
   // Trend sonuçları
   ENUM_TREND_DIRECTION  primary_trend;      // Ana trend yönü
   ENUM_TREND_STRENGTH   primary_strength;   // Ana trend gücü
   ENUM_TREND_PHASE      trend_phase;        // Trend fazı
   ENUM_MARKET_STRUCTURE market_structure;   // Market yapısı
   
   // Multi-timeframe trend
   ENUM_TREND_DIRECTION  trend_m15;          // M15 trend
   ENUM_TREND_DIRECTION  trend_h1;           // H1 trend
   ENUM_TREND_DIRECTION  trend_h4;           // H4 trend
   ENUM_TREND_DIRECTION  trend_d1;           // D1 trend
   int                   trend_alignment;    // Trend uyumu (0-4)
   
   // Analiz bileşenleri
   MovingAverageInfo     ma_analysis;        // Moving Average analizi
   IchimokuInfo          ichimoku_analysis;  // Ichimoku analizi
   ADXTrendInfo          adx_analysis;       // ADX analizi
   MarketStructureInfo   structure_analysis; // Market yapı analizi
   
   // Confluence ve güç
   double                trend_confluence;   // Trend confluence skoru (0-100)
   double                trend_certainty;    // Trend kesinlik oranı (0-100)
   double                trend_momentum;     // Trend momentumu (-100 to +100)
   double                trend_velocity;     // Trend hızı
   
   // ML predictions
   double                ml_trend_score;     // ML trend skoru
   double                trend_continuation_prob; // Trend devam olasılığı
   double                trend_reversal_prob;     // Trend dönüş olasılığı
   double                breakout_probability;    // Kırılım olasılığı
   
   // Signal generation
   ENUM_SIGNAL_TYPE      trend_signal;       // Trend sinyali
   ENUM_SIGNAL_STRENGTH  signal_strength;    // Sinyal gücü
   double                entry_confidence;   // Giriş güveni
   
   // Risk assessment
   ENUM_RISK_LEVEL       trend_risk;         // Trend riski
   bool                  trend_exhaustion;   // Trend tükenmesi
   bool                  reversal_warning;   // Dönüş uyarısı
   double                volatility_factor;  // Volatilite faktörü
   
   // Constructor
   TrendAnalysisInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      calculation_time = 0;
      symbol = "";
      timeframe = PERIOD_H1;
      current_price = 0.0;
      
      primary_trend = TREND_UNDEFINED;
      primary_strength = TREND_STRENGTH_NONE;
      trend_phase = PHASE_UNKNOWN;
      market_structure = STRUCTURE_UNKNOWN;
      
      trend_m15 = trend_h1 = trend_h4 = trend_d1 = TREND_UNDEFINED;
      trend_alignment = 0;
      
      ma_analysis.Reset();
      ichimoku_analysis.Reset();
      adx_analysis.Reset();
      structure_analysis.Reset();
      
      trend_confluence = 0.0;
      trend_certainty = 0.0;
      trend_momentum = 0.0;
      trend_velocity = 0.0;
      
      ml_trend_score = 50.0;
      trend_continuation_prob = 0.0;
      trend_reversal_prob = 0.0;
      breakout_probability = 0.0;
      
      trend_signal = SIGNAL_NONE;
      signal_strength = SIGNAL_STRENGTH_NONE;
      entry_confidence = 0.0;
      
      trend_risk = RISK_MEDIUM;
      trend_exhaustion = false;
      reversal_warning = false;
      volatility_factor = 1.0;
   }
   
   bool IsValid() const
   {
      return (calculation_time > 0 && StringLen(symbol) > 0 && current_price > 0.0);
   }
   
   string ToString() const
   {
      return StringFormat("Trend: %s | Güç: %s | Faz: %s | Confluence: %.1f%% | Sinyal: %s",
                         TrendDirectionToString(primary_trend),
                         TrendStrengthToString(primary_strength),
                         TrendPhaseToString(trend_phase),
                         trend_confluence,
                         SignalTypeToString(trend_signal));
   }
};

//+------------------------------------------------------------------+
//| Helper Functions                                                 |
//+------------------------------------------------------------------+
string TrendPhaseToString(ENUM_TREND_PHASE phase)
{
   switch(phase)
   {
      case PHASE_EARLY_TREND: return "EARLY_TREND";
      case PHASE_DEVELOPING_TREND: return "DEVELOPING_TREND";
      case PHASE_MATURE_TREND: return "MATURE_TREND";
      case PHASE_EXHAUSTION: return "EXHAUSTION";
      case PHASE_CORRECTION: return "CORRECTION";
      case PHASE_REVERSAL: return "REVERSAL";
      case PHASE_UNKNOWN: return "UNKNOWN";
      default: return "INVALID";
   }
}

string MarketStructureToString(ENUM_MARKET_STRUCTURE structure)
{
   switch(structure)
   {
      case STRUCTURE_UPTREND: return "UPTREND";
      case STRUCTURE_DOWNTREND: return "DOWNTREND";
      case STRUCTURE_RANGE_BOUND: return "RANGE_BOUND";
      case STRUCTURE_ACCUMULATION: return "ACCUMULATION";
      case STRUCTURE_DISTRIBUTION: return "DISTRIBUTION";
      case STRUCTURE_BREAKOUT_UP: return "BREAKOUT_UP";
      case STRUCTURE_BREAKOUT_DOWN: return "BREAKOUT_DOWN";
      case STRUCTURE_REVERSAL_PENDING: return "REVERSAL_PENDING";
      case STRUCTURE_CONSOLIDATION: return "CONSOLIDATION";
      case STRUCTURE_UNKNOWN: return "UNKNOWN";
      default: return "INVALID";
   }
}

//+------------------------------------------------------------------+
//| Trend Analiz Motoru                                             |
//+------------------------------------------------------------------+
class TrendAnalysisEngine
{
private:
   // Engine parametreleri
   string                m_symbol;           // Analiz sembolü
   ENUM_TIMEFRAMES       m_timeframe;        // Ana zaman çerçevesi
   bool                  m_initialized;      // Başlatılma durumu
   
   // Moving Average ayarları
   int                   m_ma_fast_period;   // Hızlı MA periyodu
   int                   m_ma_slow_period;   // Yavaş MA periyodu
   int                   m_ma_trend_period;  // Trend MA periyodu
   ENUM_MA_METHOD        m_ma_method;        // MA metodu
   
   // Ichimoku ayarları
   int                   m_tenkan_period;    // Tenkan-sen periyodu
   int                   m_kijun_period;     // Kijun-sen periyodu
   int                   m_senkou_period;    // Senkou periyodu
   
   // ADX ayarları
   int                   m_adx_period;       // ADX periyodu
   double                m_adx_strong_level; // Güçlü trend seviyesi
   double                m_adx_weak_level;   // Zayıf trend seviyesi
   
   // Market structure ayarları
   int                   m_swing_lookback;   // Swing analiz periyodu
   double                m_structure_threshold; // Yapı kırılım eşiği
   
   // Historical data
   double                m_price_history[200]; // Fiyat geçmişi
   datetime              m_time_history[200];  // Zaman geçmişi
   int                   m_history_size;       // Geçmiş boyutu
   
   // ML components
   double                m_ml_features[30];    // ML özellik vektörü
   double                m_ml_weights[30];     // ML ağırlıkları
   bool                  m_ml_trained;         // ML eğitilmiş mi?
   
   // Performance tracking
   int                   m_total_calculations; // Toplam hesaplama
   int                   m_successful_predictions; // Başarılı tahmin
   double                m_accuracy_rate;      // Doğruluk oranı
   datetime              m_last_calculation;   // Son hesaplama zamanı

public:
   //+------------------------------------------------------------------+
   //| Constructor & Destructor                                         |
   //+------------------------------------------------------------------+
   TrendAnalysisEngine(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_H1)
   {
      m_symbol = (StringLen(symbol) > 0) ? symbol : Symbol();
      m_timeframe = timeframe;
      m_initialized = false;
      
      // Default settings
      m_ma_fast_period = 20;
      m_ma_slow_period = 50;
      m_ma_trend_period = 200;
      m_ma_method = MODE_EMA;
      
      m_tenkan_period = 9;
      m_kijun_period = 26;
      m_senkou_period = 52;
      
      m_adx_period = 14;
      m_adx_strong_level = 25.0;
      m_adx_weak_level = 20.0;
      
      m_swing_lookback = 50;
      m_structure_threshold = 20.0; // pips
      
      m_history_size = 0;
      ArrayInitialize(m_price_history, 0.0);
      ArrayInitialize(m_time_history, 0);
      
      ArrayInitialize(m_ml_features, 0.0);
      ArrayInitialize(m_ml_weights, 1.0);
      m_ml_trained = false;
      
      m_total_calculations = 0;
      m_successful_predictions = 0;
      m_accuracy_rate = 0.0;
      m_last_calculation = 0;
      
      if(!Initialize())
      {
         Print("ERROR: TrendAnalysisEngine initialization failed");
         return;
      }
      
      Print(StringFormat("TrendAnalysisEngine initialized: %s, TF: %d", m_symbol, m_timeframe));
   }
   
   ~TrendAnalysisEngine()
   {
      if(m_total_calculations > 0)
      {
         Print(StringFormat("TrendAnalysisEngine destroyed. Accuracy: %.2f%% (%d/%d)",
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
      
      // Symbol validation
      if(!SymbolSelect(m_symbol, true))
      {
         Print(StringFormat("ERROR: Cannot select symbol: %s", m_symbol));
         return false;
      }
      
      // Load historical data
      if(!LoadHistoricalData())
      {
         Print("WARNING: Could not load complete historical data");
         // Not critical, continue
      }
      
      // Convert threshold to symbol points
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      double pip_size = (digits == 5 || digits == 3) ? point * 10 : point;
      m_structure_threshold = m_structure_threshold * pip_size;
      
      // Initialize ML model
      InitializeMLModel();
      
      m_initialized = true;
      return true;
   }
   
   bool LoadHistoricalData()
   {
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      
      int copied = CopyRates(m_symbol, m_timeframe, 0, 200, rates);
      if(copied <= 0)
      {
         Print("ERROR: Cannot load historical data");
         return false;
      }
      
      // Store in internal arrays
      m_history_size = MathMin(copied, 200);
      for(int i = 0; i < m_history_size; i++)
      {
         m_price_history[i] = rates[i].close;
         m_time_history[i] = rates[i].time;
      }
      
      Print(StringFormat("Loaded %d historical data points", m_history_size));
      return true;
   }
   
   void InitializeMLModel()
   {
      // Initialize basic ML weights (placeholder)
      for(int i = 0; i < 30; i++)
      {
         m_ml_weights[i] = (MathRand() / 32767.0) * 2.0 - 1.0;
      }
      
      m_ml_trained = false; // Set to true when real model is loaded
   }

public:
   //+------------------------------------------------------------------+
   //| Ana Analiz Metodları                                            |
   //+------------------------------------------------------------------+
   TrendAnalysisInfo AnalyzeTrend()
   {
      TrendAnalysisInfo info;
      
      if(!m_initialized)
      {
         Print("ERROR: Engine not initialized");
         return info;
      }
      
      m_total_calculations++;
      info.calculation_time = TimeCurrent();
      info.symbol = m_symbol;
      info.timeframe = m_timeframe;
      
      // Get current price
      info.current_price = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      if(info.current_price <= 0.0)
      {
         Print("ERROR: Cannot get current price");
         return info;
      }
      
      // Moving Average analizi
      if(!AnalyzeMovingAverages(info))
      {
         Print("ERROR: Failed to analyze moving averages");
         return info;
      }
      
      // Ichimoku analizi
      if(!AnalyzeIchimoku(info))
      {
         Print("WARNING: Failed to analyze Ichimoku");
      }
      
      // ADX analizi
      if(!AnalyzeADX(info))
      {
         Print("WARNING: Failed to analyze ADX");
      }
      
      // Market structure analizi
      AnalyzeMarketStructure(info);
      
      // Multi-timeframe analizi
      AnalyzeMultiTimeframe(info);
      
      // Confluence hesaplama
      CalculateTrendConfluence(info);
      
      // Trend fazı belirleme
      DetermineTrendPhase(info);
      
      // ML feature extraction
      ExtractMLFeatures(info);
      
      // ML predictions
      if(m_ml_trained)
         CalculateMLPredictions(info);
      
      // Signal generation
      GenerateTrendSignals(info);
      
      // Risk assessment
      AssessTrendRisk(info);
      
      m_last_calculation = TimeCurrent();
      
      return info;
   }

private:
   bool AnalyzeMovingAverages(TrendAnalysisInfo &info)
   {
      MovingAverageInfo ma = info.ma_analysis;
      
      // Get MA values
      double ma_fast_buffer[3], ma_slow_buffer[3], ma_trend_buffer[3];
      
      // Fast MA
      int ma_fast_handle = iMA(m_symbol, m_timeframe, m_ma_fast_period, 0, m_ma_method, PRICE_CLOSE);
      if(ma_fast_handle == INVALID_HANDLE || CopyBuffer(ma_fast_handle, 0, 0, 3, ma_fast_buffer) != 3)
      {
         Print("ERROR: Cannot get fast MA data");
         return false;
      }
      ma.ema_fast = ma_fast_buffer[0];
      
      // Slow MA
      int ma_slow_handle = iMA(m_symbol, m_timeframe, m_ma_slow_period, 0, m_ma_method, PRICE_CLOSE);
      if(ma_slow_handle == INVALID_HANDLE || CopyBuffer(ma_slow_handle, 0, 0, 3, ma_slow_buffer) != 3)
      {
         Print("ERROR: Cannot get slow MA data");
         return false;
      }
      ma.ema_slow = ma_slow_buffer[0];
      
      // Trend MA
      int ma_trend_handle = iMA(m_symbol, m_timeframe, m_ma_trend_period, 0, m_ma_method, PRICE_CLOSE);
      if(ma_trend_handle == INVALID_HANDLE || CopyBuffer(ma_trend_handle, 0, 0, 3, ma_trend_buffer) != 3)
      {
         Print("ERROR: Cannot get trend MA data");
         return false;
      }
      ma.ema_trend = ma_trend_buffer[0];
      
      // Analyze crossovers
      ma.golden_cross = (ma_fast_buffer[0] > ma_slow_buffer[0] && ma_fast_buffer[1] <= ma_slow_buffer[1]);
      ma.death_cross = (ma_fast_buffer[0] < ma_slow_buffer[0] && ma_fast_buffer[1] >= ma_slow_buffer[1]);
      
      // Position relative to trend MA
      ma.above_trend_ma = (info.current_price > ma.ema_trend);
      
      // MA alignment
      ma.ma_alignment_bull = (ma.ema_fast > ma.ema_slow && ma.ema_slow > ma.ema_trend);
      ma.ma_alignment_bear = (ma.ema_fast < ma.ema_slow && ma.ema_slow < ma.ema_trend);
      
      // Calculate slopes
      if(ma_fast_buffer[2] > 0)
         ma.fast_slope = (ma_fast_buffer[0] - ma_fast_buffer[2]) / ma_fast_buffer[2] * 10000; // Basis points
      if(ma_slow_buffer[2] > 0)
         ma.slow_slope = (ma_slow_buffer[0] - ma_slow_buffer[2]) / ma_slow_buffer[2] * 10000;
      if(ma_trend_buffer[2] > 0)
         ma.trend_slope = (ma_trend_buffer[0] - ma_trend_buffer[2]) / ma_trend_buffer[2] * 10000;
      
      // Distance percentages
      if(ma.ema_fast > 0)
         ma.price_to_fast_pct = (info.current_price - ma.ema_fast) / ma.ema_fast * 100.0;
      if(ma.ema_slow > 0)
         ma.price_to_slow_pct = (info.current_price - ma.ema_slow) / ma.ema_slow * 100.0;
      if(ma.ema_trend > 0)
         ma.price_to_trend_pct = (info.current_price - ma.ema_trend) / ma.ema_trend * 100.0;
      
      // Release handles
      IndicatorRelease(ma_fast_handle);
      IndicatorRelease(ma_slow_handle);
      IndicatorRelease(ma_trend_handle);
      
      return true;
   }
   
   bool AnalyzeIchimoku(TrendAnalysisInfo &info)
   {
      IchimokuInfo ich = info.ichimoku_analysis;
      
      // Get Ichimoku values
      int ichimoku_handle = iIchimoku(m_symbol, m_timeframe, m_tenkan_period, m_kijun_period, m_senkou_period);
      if(ichimoku_handle == INVALID_HANDLE)
      {
         Print("ERROR: Cannot create Ichimoku handle");
         return false;
      }
      
      double tenkan_buffer[3], kijun_buffer[3];
      double senkou_a_buffer[3], senkou_b_buffer[3], chikou_buffer[3];
      
      // Copy buffers
      bool success = true;
      success &= (CopyBuffer(ichimoku_handle, 0, 0, 3, tenkan_buffer) == 3); // Tenkan-sen
      success &= (CopyBuffer(ichimoku_handle, 1, 0, 3, kijun_buffer) == 3);  // Kijun-sen
      success &= (CopyBuffer(ichimoku_handle, 2, 0, 3, senkou_a_buffer) == 3); // Senkou Span A
      success &= (CopyBuffer(ichimoku_handle, 3, 0, 3, senkou_b_buffer) == 3); // Senkou Span B
      success &= (CopyBuffer(ichimoku_handle, 4, 0, 3, chikou_buffer) == 3);   // Chikou Span
      
      if(!success)
      {
         Print("ERROR: Cannot copy Ichimoku buffers");
         IndicatorRelease(ichimoku_handle);
         return false;
      }
      
      // Store values
      ich.tenkan_sen = tenkan_buffer[0];
      ich.kijun_sen = kijun_buffer[0];
      ich.senkou_span_a = senkou_a_buffer[0];
      ich.senkou_span_b = senkou_b_buffer[0];
      ich.chikou_span = chikou_buffer[0];
      
      // Kumo analysis
      double kumo_top = MathMax(ich.senkou_span_a, ich.senkou_span_b);
      double kumo_bottom = MathMin(ich.senkou_span_a, ich.senkou_span_b);
      
      ich.above_kumo = (info.current_price > kumo_top);
      ich.below_kumo = (info.current_price < kumo_bottom);
      ich.in_kumo = (!ich.above_kumo && !ich.below_kumo);
      ich.kumo_thickness = MathAbs(ich.senkou_span_a - ich.senkou_span_b);
      ich.kumo_bullish = (ich.senkou_span_a > ich.senkou_span_b);
      
      // Signal analysis
      ich.tenkan_kijun_cross_bull = (tenkan_buffer[0] > kijun_buffer[0] && tenkan_buffer[1] <= kijun_buffer[1]);
      ich.tenkan_kijun_cross_bear = (tenkan_buffer[0] < kijun_buffer[0] && tenkan_buffer[1] >= kijun_buffer[1]);
      ich.price_above_tenkan = (info.current_price > ich.tenkan_sen);
      ich.price_above_kijun = (info.current_price > ich.kijun_sen);
      
      // Chikou analysis (simplified - check if clear of price action)
      ich.chikou_clear = true; // Placeholder - would need proper historical analysis
      
      // Calculate Ichimoku strength
      ich.ichimoku_strength = CalculateIchimokuStrength(ich, info.current_price);
      
      IndicatorRelease(ichimoku_handle);
      return true;
   }
   
   double CalculateIchimokuStrength(const IchimokuInfo &ich, double current_price)
   {
      double strength = 0.0;
      
      // Kumo position (40% weight)
      if(ich.above_kumo) strength += 40.0;
      else if(ich.below_kumo) strength -= 40.0;
      
      // TK line relationship (20% weight)
      if(ich.tenkan_sen > ich.kijun_sen) strength += 20.0;
      else strength -= 20.0;
      
      // Price vs TK lines (20% weight)
      if(ich.price_above_tenkan && ich.price_above_kijun) strength += 20.0;
      else if(!ich.price_above_tenkan && !ich.price_above_kijun) strength -= 20.0;
      
      // Kumo color (10% weight)
      if(ich.kumo_bullish) strength += 10.0;
      else strength -= 10.0;
      
      // Chikou clear (10% weight)
      if(ich.chikou_clear) strength += 10.0;
      
      // Normalize to 0-100
      return 50.0 + (strength / 2.0);
   }
   
   bool AnalyzeADX(TrendAnalysisInfo &info)
   {
      ADXTrendInfo adx = info.adx_analysis;
      
      // Get ADX values
      int adx_handle = iADX(m_symbol, m_timeframe, m_adx_period);
      if(adx_handle == INVALID_HANDLE)
      {
         Print("ERROR: Cannot create ADX handle");
         return false;
      }
      
      double adx_buffer[3], di_plus_buffer[3], di_minus_buffer[3];
      
      bool success = true;
      success &= (CopyBuffer(adx_handle, 0, 0, 3, adx_buffer) == 3);       // ADX
      success &= (CopyBuffer(adx_handle, 1, 0, 3, di_plus_buffer) == 3);   // DI+
      success &= (CopyBuffer(adx_handle, 2, 0, 3, di_minus_buffer) == 3);  // DI-
      
      if(!success)
      {
         Print("ERROR: Cannot copy ADX buffers");
         IndicatorRelease(adx_handle);
         return false;
      }
      
      // Store values
      adx.adx_value = adx_buffer[0];
      adx.di_plus = di_plus_buffer[0];
      adx.di_minus = di_minus_buffer[0];
      
      // Trend strength classification
      if(adx.adx_value >= 40.0)
         adx.trend_strength = TREND_VERY_STRONG;
      else if(adx.adx_value >= m_adx_strong_level)
         adx.trend_strength = TREND_STRONG;
      else if(adx.adx_value >= m_adx_weak_level)
         adx.trend_strength = TREND_MODERATE;
      else
         adx.trend_strength = TREND_WEAK;
      
      adx.strong_trend = (adx.adx_value >= m_adx_strong_level);
      adx.very_strong_trend = (adx.adx_value >= 40.0);
      adx.weak_trend = (adx.adx_value < m_adx_weak_level);
      
      // Direction analysis
      adx.bullish_momentum = (adx.di_plus > adx.di_minus);
      adx.bearish_momentum = (adx.di_plus < adx.di_minus);
      
      // Check for momentum change
      bool prev_bullish = (di_plus_buffer[1] > di_minus_buffer[1]);
      adx.momentum_change = (adx.bullish_momentum != prev_bullish);
      
      // ADX trend
      adx.adx_rising = (adx_buffer[0] > adx_buffer[1]);
      adx.adx_falling = (adx_buffer[0] < adx_buffer[1]);
      adx.adx_slope = adx_buffer[0] - adx_buffer[2]; // Simple slope over 2 periods
      
      IndicatorRelease(adx_handle);
      return true;
   }
   
   void AnalyzeMarketStructure(TrendAnalysisInfo &info)
   {
      MarketStructureInfo structure = info.structure_analysis;
      
      if(m_history_size < 20) return; // Need sufficient data
      
      // Find swing highs and lows
      FindSwingPoints(structure);
      
      // Analyze structure patterns
      AnalyzeStructurePatterns(structure, info.current_price);
      
      // Check for structure breaks
      CheckStructureBreaks(structure, info.current_price);
      
      // Identify key S/R levels
      IdentifyKeyLevels(structure);
   }
   
   void FindSwingPoints(MarketStructureInfo &structure)
   {
      int swing_period = 5; // Look for swings over 5 periods
      
      // Find recent swing high
      for(int i = swing_period; i < m_history_size - swing_period; i++)
      {
         bool is_swing_high = true;
         for(int j = 1; j <= swing_period; j++)
         {
            if(m_price_history[i] <= m_price_history[i-j] || 
               m_price_history[i] <= m_price_history[i+j])
            {
               is_swing_high = false;
               break;
            }
         }
         
         if(is_swing_high)
         {
            structure.last_swing_high = m_price_history[i];
            structure.swing_high_time = m_time_history[i];
            break;
         }
      }
      
      // Find recent swing low
      for(int i = swing_period; i < m_history_size - swing_period; i++)
      {
         bool is_swing_low = true;
         for(int j = 1; j <= swing_period; j++)
         {
            if(m_price_history[i] >= m_price_history[i-j] || 
               m_price_history[i] >= m_price_history[i+j])
            {
               is_swing_low = false;
               break;
            }
         }
         
         if(is_swing_low)
         {
            structure.last_swing_low = m_price_history[i];
            structure.swing_low_time = m_time_history[i];
            break;
         }
      }
   }
   
   void AnalyzeStructurePatterns(MarketStructureInfo &structure, double current_price)
   {
      if(m_history_size < 50) return;
      
      // Simplified pattern analysis
      // In real implementation, this would be much more sophisticated
      
      // Check for higher highs and higher lows (uptrend structure)
      int recent_highs = 0, recent_lows = 0;
      for(int i = 10; i < 30 && i < m_history_size; i++)
      {
         if(m_price_history[i] > m_price_history[i+10])
            recent_highs++;
         if(m_price_history[i] > m_price_history[i+10])
            recent_lows++;
      }
      
      structure.higher_highs = (recent_highs > 15);
      structure.higher_lows = (recent_lows > 15);
      structure.lower_highs = (recent_highs < 5);
      structure.lower_lows = (recent_lows < 5);
   }
   
   void CheckStructureBreaks(MarketStructureInfo &structure, double current_price)
   {
      // Check if current price has broken recent structure
      if(structure.last_swing_high > 0 && 
         current_price > structure.last_swing_high + m_structure_threshold)
      {
         structure.structure_break_up = true;
         structure.break_level = structure.last_swing_high;
         structure.break_time = TimeCurrent();
      }
      
      if(structure.last_swing_low > 0 && 
         current_price < structure.last_swing_low - m_structure_threshold)
      {
         structure.structure_break_down = true;
         structure.break_level = structure.last_swing_low;
         structure.break_time = TimeCurrent();
      }
   }
   
   void IdentifyKeyLevels(MarketStructureInfo &structure)
   {
      // Simplified S/R identification
      // In real implementation, this would analyze multiple swing points
      
      structure.key_resistance = structure.last_swing_high;
      structure.key_support = structure.last_swing_low;
      
      // Count touches (simplified)
      structure.resistance_touches = 1; // Placeholder
      structure.support_touches = 1;    // Placeholder
   }
   
   void AnalyzeMultiTimeframe(TrendAnalysisInfo &info)
   {
      // Analyze trend on different timeframes
      info.trend_m15 = GetTrendForTimeframe(PERIOD_M15);
      info.trend_h1 = GetTrendForTimeframe(PERIOD_H1);
      info.trend_h4 = GetTrendForTimeframe(PERIOD_H4);
      info.trend_d1 = GetTrendForTimeframe(PERIOD_D1);
      
      // Calculate alignment
      info.trend_alignment = 0;
      ENUM_TREND_DIRECTION trends[] = {info.trend_m15, info.trend_h1, info.trend_h4, info.trend_d1};
      
      // Count bullish trends
      int bullish_count = 0, bearish_count = 0;
      for(int i = 0; i < ArraySize(trends); i++)
      {
         if(IsBullishTrend(trends[i])) bullish_count++;
         else if(IsBearishTrend(trends[i])) bearish_count++;
      }
      
      info.trend_alignment = MathMax(bullish_count, bearish_count);
   }
   
   ENUM_TREND_DIRECTION GetTrendForTimeframe(ENUM_TIMEFRAMES timeframe)
   {
      // Get MA values for this timeframe
      double ma_fast_buffer[1], ma_slow_buffer[1];
      
      int ma_fast_handle = iMA(m_symbol, timeframe, m_ma_fast_period, 0, m_ma_method, PRICE_CLOSE);
      int ma_slow_handle = iMA(m_symbol, timeframe, m_ma_slow_period, 0, m_ma_method, PRICE_CLOSE);
      
      if(ma_fast_handle == INVALID_HANDLE || ma_slow_handle == INVALID_HANDLE)
         return TREND_UNDEFINED;
      
      if(CopyBuffer(ma_fast_handle, 0, 0, 1, ma_fast_buffer) != 1 ||
         CopyBuffer(ma_slow_handle, 0, 0, 1, ma_slow_buffer) != 1)
      {
         IndicatorRelease(ma_fast_handle);
         IndicatorRelease(ma_slow_handle);
         return TREND_UNDEFINED;
      }
      
      ENUM_TREND_DIRECTION trend;
      if(ma_fast_buffer[0] > ma_slow_buffer[0])
         trend = TREND_BULLISH;
      else if(ma_fast_buffer[0] < ma_slow_buffer[0])
         trend = TREND_BEARISH;
      else
         trend = TREND_NEUTRAL;
      
      IndicatorRelease(ma_fast_handle);
      IndicatorRelease(ma_slow_handle);
      
      return trend;
   }
   
   void CalculateTrendConfluence(TrendAnalysisInfo &info)
   {
      double confluence = 0.0;
      
      // Moving Average confluence (30% weight)
      double ma_score = 0.0;
      if(info.ma_analysis.ma_alignment_bull || info.ma_analysis.ma_alignment_bear)
         ma_score += 20.0;
      if(info.ma_analysis.golden_cross)
         ma_score += 15.0;
      if(info.ma_analysis.death_cross)
         ma_score += 15.0;
      if(MathAbs(info.ma_analysis.fast_slope) > 10.0)
         ma_score += 10.0;
      
      confluence += ma_score * 0.3;
      
      // Ichimoku confluence (25% weight)
      confluence += (info.ichimoku_analysis.ichimoku_strength - 50.0) * 0.5; // Convert to -25,+25 range
      
      // ADX confluence (20% weight)
      double adx_score = 0.0;
      if(info.adx_analysis.strong_trend)
         adx_score += 15.0;
      if(info.adx_analysis.very_strong_trend)
         adx_score += 10.0;
      if(info.adx_analysis.adx_rising)
         adx_score += 5.0;
      
      confluence += adx_score * 0.8; // Scale to 20% weight
      
      // Multi-timeframe confluence (15% weight)
      confluence += (info.trend_alignment / 4.0) * 15.0;
      
      // Structure confluence (10% weight)
      double structure_score = 0.0;
      if(info.structure_analysis.structure_break_up || info.structure_analysis.structure_break_down)
         structure_score += 10.0;
      if(info.structure_analysis.higher_highs && info.structure_analysis.higher_lows)
         structure_score += 5.0;
      if(info.structure_analysis.lower_highs && info.structure_analysis.lower_lows)
         structure_score += 5.0;
      
      confluence += structure_score;
      
      info.trend_confluence = MathMax(0.0, MathMin(100.0, confluence));
      
      // Calculate certainty
      info.trend_certainty = info.trend_confluence;
      if(info.trend_alignment >= 3)
         info.trend_certainty += 10.0;
      if(info.adx_analysis.very_strong_trend)
         info.trend_certainty += 10.0;
      
      info.trend_certainty = MathMax(0.0, MathMin(100.0, info.trend_certainty));
   }
   
   void DetermineTrendPhase(TrendAnalysisInfo &info)
   {
      // Determine primary trend first
      if(info.ma_analysis.ma_alignment_bull && info.trend_alignment >= 2)
         info.primary_trend = TREND_BULLISH;
      else if(info.ma_analysis.ma_alignment_bear && info.trend_alignment >= 2)
         info.primary_trend = TREND_BEARISH;
      else if(info.trend_alignment >= 3)
      {
         if(IsBullishTrend(info.trend_h1) && IsBullishTrend(info.trend_h4))
            info.primary_trend = TREND_BULLISH;
         else if(IsBearishTrend(info.trend_h1) && IsBearishTrend(info.trend_h4))
            info.primary_trend = TREND_BEARISH;
         else
            info.primary_trend = TREND_NEUTRAL;
      }
      else
         info.primary_trend = TREND_NEUTRAL;
      
      // Determine strength
      if(info.trend_confluence >= 80.0)
         info.primary_strength = TREND_VERY_STRONG;
      else if(info.trend_confluence >= 60.0)
         info.primary_strength = TREND_STRONG;
      else if(info.trend_confluence >= 40.0)
         info.primary_strength = TREND_MODERATE;
      else if(info.trend_confluence >= 20.0)
         info.primary_strength = TREND_WEAK;
      else
         info.primary_strength = TREND_VERY_WEAK;
      
      // Determine phase
      if(info.ma_analysis.golden_cross || info.ma_analysis.death_cross)
         info.trend_phase = PHASE_EARLY_TREND;
      else if(info.primary_strength >= TREND_STRONG && info.adx_analysis.adx_rising)
         info.trend_phase = PHASE_DEVELOPING_TREND;
      else if(info.primary_strength >= TREND_STRONG && info.adx_analysis.very_strong_trend)
         info.trend_phase = PHASE_MATURE_TREND;
      else if(info.adx_analysis.adx_falling && info.adx_analysis.very_strong_trend)
         info.trend_phase = PHASE_EXHAUSTION;
      else if(info.primary_trend != TREND_NEUTRAL && info.primary_strength <= TREND_WEAK)
         info.trend_phase = PHASE_CORRECTION;
      else
         info.trend_phase = PHASE_UNKNOWN;
      
      // Determine market structure
      if(info.structure_analysis.higher_highs && info.structure_analysis.higher_lows)
         info.market_structure = STRUCTURE_UPTREND;
      else if(info.structure_analysis.lower_highs && info.structure_analysis.lower_lows)
         info.market_structure = STRUCTURE_DOWNTREND;
      else if(info.structure_analysis.structure_break_up)
         info.market_structure = STRUCTURE_BREAKOUT_UP;
      else if(info.structure_analysis.structure_break_down)
         info.market_structure = STRUCTURE_BREAKOUT_DOWN;
      else if(info.primary_trend == TREND_NEUTRAL)
         info.market_structure = STRUCTURE_RANGE_BOUND;
      else
         info.market_structure = STRUCTURE_CONSOLIDATION;
   }
   
   void ExtractMLFeatures(TrendAnalysisInfo &info)
   {
      // Feature 1-5: Moving Average features
      m_ml_features[0] = info.ma_analysis.price_to_fast_pct / 10.0; // Normalize
      m_ml_features[1] = info.ma_analysis.price_to_slow_pct / 10.0;
      m_ml_features[2] = info.ma_analysis.price_to_trend_pct / 10.0;
      m_ml_features[3] = info.ma_analysis.fast_slope / 100.0;
      m_ml_features[4] = info.ma_analysis.slow_slope / 100.0;
      
      // Feature 6-10: Ichimoku features
      m_ml_features[5] = info.ichimoku_analysis.ichimoku_strength / 100.0;
      m_ml_features[6] = info.ichimoku_analysis.above_kumo ? 1.0 : 0.0;
      m_ml_features[7] = info.ichimoku_analysis.below_kumo ? 1.0 : 0.0;
      m_ml_features[8] = info.ichimoku_analysis.kumo_bullish ? 1.0 : 0.0;
      m_ml_features[9] = info.ichimoku_analysis.tenkan_kijun_cross_bull ? 1.0 : 0.0;
      
      // Feature 11-15: ADX features
      m_ml_features[10] = info.adx_analysis.adx_value / 100.0;
      m_ml_features[11] = (info.adx_analysis.di_plus - info.adx_analysis.di_minus) / 50.0;
      m_ml_features[12] = info.adx_analysis.strong_trend ? 1.0 : 0.0;
      m_ml_features[13] = info.adx_analysis.adx_rising ? 1.0 : 0.0;
      m_ml_features[14] = info.adx_analysis.momentum_change ? 1.0 : 0.0;
      
      // Feature 16-20: Structure features
      m_ml_features[15] = info.structure_analysis.higher_highs ? 1.0 : 0.0;
      m_ml_features[16] = info.structure_analysis.higher_lows ? 1.0 : 0.0;
      m_ml_features[17] = info.structure_analysis.structure_break_up ? 1.0 : 0.0;
      m_ml_features[18] = info.structure_analysis.structure_break_down ? 1.0 : 0.0;
      m_ml_features[19] = (double)info.market_structure / 9.0;
      
      // Feature 21-25: Multi-timeframe features
      m_ml_features[20] = info.trend_alignment / 4.0;
      m_ml_features[21] = (double)info.trend_h1 / 8.0; // Normalize enum
      m_ml_features[22] = (double)info.trend_h4 / 8.0;
      m_ml_features[23] = (double)info.trend_d1 / 8.0;
      m_ml_features[24] = info.trend_confluence / 100.0;
      
      // Feature 26-30: Advanced features
      m_ml_features[25] = (double)info.primary_trend / 8.0;
      m_ml_features[26] = (double)info.primary_strength / 8.0;
      m_ml_features[27] = (double)info.trend_phase / 6.0;
      m_ml_features[28] = info.trend_certainty / 100.0;
      m_ml_features[29] = CalculateMomentumFeature(info);
   }
   
   double CalculateMomentumFeature(const TrendAnalysisInfo &info)
   {
      // Combine multiple momentum indicators
      double momentum = 0.0;
      
      momentum += info.ma_analysis.fast_slope / 100.0 * 0.3;
      momentum += info.adx_analysis.adx_slope / 10.0 * 0.3;
      momentum += (info.adx_analysis.di_plus - info.adx_analysis.di_minus) / 50.0 * 0.4;
      
      return MathMax(-1.0, MathMin(1.0, momentum));
   }
   
   void CalculateMLPredictions(TrendAnalysisInfo &info)
   {
      if(!m_ml_trained) return;
      
      // Simple neural network prediction (placeholder)
      double ml_score = 0.0;
      for(int i = 0; i < 30; i++)
      {
         ml_score += m_ml_features[i] * m_ml_weights[i];
      }
      
      // Apply activation and normalize
      ml_score = (MathTanh(ml_score) + 1.0) * 50.0;
      info.ml_trend_score = MathMax(0.0, MathMin(100.0, ml_score));
      
      // Calculate specific probabilities
      if(info.primary_trend == TREND_BULLISH || info.primary_trend == TREND_BEARISH)
      {
         info.trend_continuation_prob = info.ml_trend_score * (info.trend_certainty / 100.0);
         info.trend_reversal_prob = 100.0 - info.trend_continuation_prob;
      }
      else
      {
         info.trend_continuation_prob = 50.0;
         info.trend_reversal_prob = 50.0;
      }
      
      // Breakout probability
      if(info.market_structure == STRUCTURE_RANGE_BOUND || info.market_structure == STRUCTURE_CONSOLIDATION)
      {
         info.breakout_probability = 70.0 + (info.adx_analysis.adx_value - 20.0);
         info.breakout_probability = MathMax(20.0, MathMin(90.0, info.breakout_probability));
      }
      else
      {
         info.breakout_probability = 30.0;
      }
      
      // Calculate momentum metrics
      info.trend_momentum = CalculateTrendMomentum(info);
      info.trend_velocity = CalculateTrendVelocity(info);
   }
   
   double CalculateTrendMomentum(const TrendAnalysisInfo &info)
   {
      double momentum = 0.0;
      
      // Base from trend direction
      if(info.primary_trend == TREND_BULLISH)
         momentum = 50.0;
      else if(info.primary_trend == TREND_BEARISH)
         momentum = -50.0;
      
      // Adjust for strength
      momentum *= (info.primary_strength / 4.0); // Scale by strength
      
      // Adjust for ADX
      if(info.adx_analysis.strong_trend)
         momentum *= 1.2;
      
      return MathMax(-100.0, MathMin(100.0, momentum));
   }
   
   double CalculateTrendVelocity(const TrendAnalysisInfo &info)
   {
      // Velocity based on slope and ADX
      double velocity = info.ma_analysis.fast_slope;
      
      // Adjust for ADX strength
      velocity *= (info.adx_analysis.adx_value / 25.0);
      
      return velocity;
   }
   
   void GenerateTrendSignals(TrendAnalysisInfo &info)
   {
      info.trend_signal = SIGNAL_NONE;
      info.signal_strength = SIGNAL_STRENGTH_NONE;
      info.entry_confidence = 0.0;
      
      double bullish_score = 0.0, bearish_score = 0.0;
      
      // Trend alignment scoring
      if(info.trend_alignment >= 3)
      {
         if(info.primary_trend == TREND_BULLISH) bullish_score += 30.0;
         else if(info.primary_trend == TREND_BEARISH) bearish_score += 30.0;
      }
      
      // MA signal scoring
      if(info.ma_analysis.golden_cross) bullish_score += 25.0;
      if(info.ma_analysis.death_cross) bearish_score += 25.0;
      if(info.ma_analysis.ma_alignment_bull) bullish_score += 20.0;
      if(info.ma_analysis.ma_alignment_bear) bearish_score += 20.0;
      
      // Ichimoku scoring
      if(info.ichimoku_analysis.ichimoku_strength > 70.0) bullish_score += 20.0;
      else if(info.ichimoku_analysis.ichimoku_strength < 30.0) bearish_score += 20.0;
      
      // Structure break scoring
      if(info.structure_analysis.structure_break_up) bullish_score += 25.0;
      if(info.structure_analysis.structure_break_down) bearish_score += 25.0;
      
      // ADX confirmation
      if(info.adx_analysis.strong_trend)
      {
         if(info.adx_analysis.bullish_momentum) bullish_score += 15.0;
         if(info.adx_analysis.bearish_momentum) bearish_score += 15.0;
      }
      
      // Determine signal
      if(bullish_score > bearish_score && bullish_score >= 40.0)
      {
         info.trend_signal = SIGNAL_BUY;
         info.entry_confidence = MathMin(100.0, bullish_score);
      }
      else if(bearish_score > bullish_score && bearish_score >= 40.0)
      {
         info.trend_signal = SIGNAL_SELL;
         info.entry_confidence = MathMin(100.0, bearish_score);
      }
      
      // Signal strength
      if(info.entry_confidence >= 90.0)
         info.signal_strength = SIGNAL_EXTREME;
      else if(info.entry_confidence >= 75.0)
         info.signal_strength = SIGNAL_VERY_STRONG;
      else if(info.entry_confidence >= 60.0)
         info.signal_strength = SIGNAL_STRONG;
      else if(info.entry_confidence >= 45.0)
         info.signal_strength = SIGNAL_MODERATE;
      else if(info.entry_confidence >= 30.0)
         info.signal_strength = SIGNAL_WEAK;
      else
         info.signal_strength = SIGNAL_VERY_WEAK;
   }
   
   void AssessTrendRisk(TrendAnalysisInfo &info)
   {
      info.trend_risk = RISK_MEDIUM;
      info.trend_exhaustion = false;
      info.reversal_warning = false;
      info.volatility_factor = 1.0;
      
      // Exhaustion analysis
      if(info.trend_phase == PHASE_EXHAUSTION || 
         (info.adx_analysis.very_strong_trend && info.adx_analysis.adx_falling))
      {
         info.trend_exhaustion = true;
         info.trend_risk = RISK_HIGH;
      }
      
      // Reversal warning
      if(info.trend_phase == PHASE_CORRECTION || 
         (info.ma_analysis.golden_cross && info.primary_trend == TREND_BEARISH) ||
         (info.ma_analysis.death_cross && info.primary_trend == TREND_BULLISH))
      {
         info.reversal_warning = true;
         info.trend_risk = RISK_HIGH;
      }
      
      // Low confluence increases risk
      if(info.trend_confluence < 40.0)
      {
         info.trend_risk = RISK_HIGH;
         info.volatility_factor = 1.3;
      }
      
      // Strong trends reduce risk
      if(info.primary_strength >= TREND_STRONG && info.trend_confluence >= 70.0)
      {
         info.trend_risk = RISK_LOW;
         info.volatility_factor = 0.8;
      }
      
      // Multi-timeframe conflicts increase risk
      if(info.trend_alignment <= 1)
      {
         info.trend_risk = RISK_VERY_HIGH;
         info.volatility_factor = 1.5;
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
   void SetMovingAverageSettings(int fast_period, int slow_period, int trend_period, ENUM_MA_METHOD method)
   {
      m_ma_fast_period = MathMax(5, MathMin(50, fast_period));
      m_ma_slow_period = MathMax(10, MathMin(100, slow_period));
      m_ma_trend_period = MathMax(50, MathMin(500, trend_period));
      m_ma_method = method;
   }
   
   void SetIchimokuSettings(int tenkan, int kijun, int senkou)
   {
      m_tenkan_period = MathMax(5, MathMin(20, tenkan));
      m_kijun_period = MathMax(10, MathMin(50, kijun));
      m_senkou_period = MathMax(20, MathMin(100, senkou));
   }
   
   void SetADXSettings(int period, double strong_level, double weak_level)
   {
      m_adx_period = MathMax(5, MathMin(50, period));
      m_adx_strong_level = MathMax(15.0, MathMin(40.0, strong_level));
      m_adx_weak_level = MathMax(10.0, MathMin(25.0, weak_level));
   }
   
   // Quick access methods
   ENUM_TREND_DIRECTION GetPrimaryTrend()
   {
      TrendAnalysisInfo info = AnalyzeTrend();
      return info.primary_trend;
   }
   
   ENUM_TREND_STRENGTH GetTrendStrength()
   {
      TrendAnalysisInfo info = AnalyzeTrend();
      return info.primary_strength;
   }
   
   double GetTrendConfidence()
   {
      TrendAnalysisInfo info = AnalyzeTrend();
      return info.trend_certainty;
   }
   
   bool IsStrongTrend()
   {
      TrendAnalysisInfo info = AnalyzeTrend();
      return (info.primary_strength >= TREND_STRONG);
   }
   
   bool HasGoldenCross()
   {
      TrendAnalysisInfo info = AnalyzeTrend();
      return info.ma_analysis.golden_cross;
   }
   
   bool HasDeathCross()
   {
      TrendAnalysisInfo info = AnalyzeTrend();
      return info.ma_analysis.death_cross;
   }
   
   int GetTrendAlignment()
   {
      TrendAnalysisInfo info = AnalyzeTrend();
      return info.trend_alignment;
   }
   
   ENUM_MARKET_STRUCTURE GetMarketStructure()
   {
      TrendAnalysisInfo info = AnalyzeTrend();
      return info.market_structure;
   }
   
   bool IsAboveTrendMA()
   {
      TrendAnalysisInfo info = AnalyzeTrend();
      return info.ma_analysis.above_trend_ma;
   }
   
   double GetADXValue()
   {
      TrendAnalysisInfo info = AnalyzeTrend();
      return info.adx_analysis.adx_value;
   }
   
   // ML and advanced features
   bool GetMLFeatures(double &features[])
   {
      if(!m_initialized) return false;
      
      TrendAnalysisInfo info = AnalyzeTrend(); // This updates ML features
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
      
      Print("Trend ML model training completed (placeholder implementation)");
      return true;
   }
   
   // Performance metrics
   double GetAccuracyRate() const { return m_accuracy_rate; }
   int GetTotalCalculations() const { return m_total_calculations; }
   datetime GetLastCalculationTime() const { return m_last_calculation; }
   
   void UpdatePerformance(bool prediction_success)
   {
      if(prediction_success)
         m_successful_predictions++;
      
      if(m_total_calculations > 0)
         m_accuracy_rate = (m_successful_predictions * 100.0) / m_total_calculations;
   }
   
   // Update methods
   bool RefreshHistoricalData()
   {
      return LoadHistoricalData();
   }
};

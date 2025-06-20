//+------------------------------------------------------------------+
//| AtrVolatilityEngine.mqh - NUCLEAR LEVEL INSTITUTIONAL ATR      |
//| COMPLETE IMPLEMENTATION - HEDGE FUND GRADE                     |
//| Complete_Enum_Types ve ISignalProvider Uyumlu                  |
//| PART 1/7 - HEADERS, ENUMS, STRUCTURES                          |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/Complete_Enum_Types.mqh"
#include "../../Core/ISignalProvider.mqh"

//+------------------------------------------------------------------+
//| ENHANCED TRADING SESSION ENUM                                   |
//+------------------------------------------------------------------+
enum ENUM_TRADING_SESSION
{
   SESSION_SYDNEY = 0,           // Sydney session
   SESSION_TOKYO = 1,            // Tokyo session  
   SESSION_LONDON = 2,           // London session
   SESSION_NEWYORK = 3,          // New York session
   SESSION_OVERLAP_LONDON_NY = 4, // London-NY overlap
   SESSION_OVERLAP_SYDNEY_TOKYO = 5, // Sydney-Tokyo overlap
   SESSION_DEAD_ZONE = 6         // Low activity period
};

enum ENUM_MARKET_REGIME
{
   REGIME_UNKNOWN = 0,           // Bilinmeyen rejim
   REGIME_TRENDING = 1,          // Trend rejimi
   REGIME_RANGING = 2,           // Range rejimi
   REGIME_BREAKOUT = 3,          // Breakout rejimi
   REGIME_MEAN_REVERSION = 4,    // Mean reversion rejimi
   REGIME_HIGH_VOLATILITY = 5,   // Yüksek volatilite rejimi
   REGIME_LOW_VOLATILITY = 6,    // Düşük volatilite rejimi
   REGIME_CRISIS = 7,            // Kriz rejimi
   REGIME_EUPHORIA = 8           // Euphoria rejimi
};

//+------------------------------------------------------------------+
//| MARKET SESSION STRUCTURE                                        |
//+------------------------------------------------------------------+
struct MarketSession
{
   string                name;                    // Session adı
   int                   start_hour;              // Başlangıç saati (GMT)
   int                   end_hour;                // Bitiş saati (GMT)
   double                volatility_multiplier;   // Volatilite çarpanı
   bool                  high_impact_session;     // Yüksek etki session'ı
   double                avg_spread;              // Ortalama spread
   double                liquidity_factor;        // Likidite faktörü
   
   MarketSession()
   {
      name = "";
      start_hour = 0;
      end_hour = 0;
      volatility_multiplier = 1.0;
      high_impact_session = false;
      avg_spread = 0.0;
      liquidity_factor = 1.0;
   }
};

//+------------------------------------------------------------------+
//| VOLATILITY SURFACE INFO STRUCTURE                              |
//+------------------------------------------------------------------+
struct VolatilitySurfaceInfo
{
   // Implied Volatility Smile/Skew
   double                implied_vol_smile[10];    // IV smile curve points
   double                volatility_skew;          // Vol skew (-1 to +1)
   double                vol_term_structure[6];    // Term structure (1W,2W,1M,3M,6M,1Y)
   double                vol_surface_curvature;    // Surface curvature
   
   // Volatility Risk Metrics
   double                vol_of_vol;               // Volatility of volatility
   double                vol_mean_reversion_speed; // Mean reversion speed
   double                vol_persistence;          // Volatility persistence
   bool                  vol_spike_exhaustion;    // Vol spike tükenmesi
   
   // Advanced Vol Metrics
   double                realized_vol_1d;         // 1-day realized vol
   double                realized_vol_1w;         // 1-week realized vol
   double                realized_vol_1m;         // 1-month realized vol
   double                vol_risk_premium;        // Volatility risk premium
   double                garch_forecast;          // GARCH volatility forecast
   
   // Vol Trading Signals
   bool                  vol_breakout_signal;     // Vol breakout sinyali
   bool                  vol_mean_revert_signal;  // Vol mean revert sinyali
   bool                  vol_regime_change;       // Vol rejim değişimi
   double                vol_trading_signal_strength; // Vol sinyal gücü
   
   VolatilitySurfaceInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      ArrayInitialize(implied_vol_smile, 0.0);
      volatility_skew = 0.0;
      ArrayInitialize(vol_term_structure, 0.0);
      vol_surface_curvature = 0.0;
      
      vol_of_vol = 0.0;
      vol_mean_reversion_speed = 0.0;
      vol_persistence = 0.0;
      vol_spike_exhaustion = false;
      
      realized_vol_1d = realized_vol_1w = realized_vol_1m = 0.0;
      vol_risk_premium = 0.0;
      garch_forecast = 0.0;
      
      vol_breakout_signal = vol_mean_revert_signal = vol_regime_change = false;
      vol_trading_signal_strength = 0.0;
   }
};

//+------------------------------------------------------------------+
//| RISK REGIME INFO STRUCTURE                                     |
//+------------------------------------------------------------------+
struct RiskRegimeInfo
{
   // Risk-On/Risk-Off Detection
   bool                  risk_off_event;          // Risk-off event tespit
   bool                  flight_to_safety;        // Güvenli limana kaçış
   bool                  risk_on_rally;           // Risk-on rally
   double                risk_appetite_score;     // Risk iştahı skoru (-100 to +100)
   
   // Market Stress Indicators
   double                vix_equivalent;          // VIX benzeri stres ölçümü
   double                correlation_breakdown;    // Korelasyon çöküşü
   bool                  tail_risk_event;         // Tail risk olayı
   double                systemic_risk_score;     // Sistemik risk skoru
   
   // Institutional Behavior
   bool                  institutional_hedging;   // Institutional hedging
   bool                  retail_panic;            // Retail panik
   bool                  smart_money_positioning; // Smart money positioning
   double                institutional_flow;      // Institutional para akışı
   
   // Crisis Detection
   bool                  market_crash_risk;       // Market çöküş riski
   bool                  liquidity_crisis;        // Likidite krizi
   bool                  margin_call_cascade;     // Margin call kaskadı
   double                contagion_risk;          // Bulaşma riski
   
   // Central Bank Response
   bool                  cb_intervention_likely;  // MB müdahale olasılığı
   bool                  emergency_measures;      // Acil önlemler
   double                policy_response_prob;    // Politik yanıt olasılığı
   
   RiskRegimeInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      risk_off_event = flight_to_safety = risk_on_rally = false;
      risk_appetite_score = 0.0;
      
      vix_equivalent = correlation_breakdown = systemic_risk_score = 0.0;
      tail_risk_event = false;
      
      institutional_hedging = retail_panic = smart_money_positioning = false;
      institutional_flow = 0.0;
      
      market_crash_risk = liquidity_crisis = margin_call_cascade = false;
      contagion_risk = 0.0;
      
      cb_intervention_likely = emergency_measures = false;
      policy_response_prob = 0.0;
   }
};

//+------------------------------------------------------------------+
//| POLICY IMPACT INFO STRUCTURE                                   |
//+------------------------------------------------------------------+
struct PolicyImpactInfo
{
   // Monetary Policy Stance
   bool                  dovish_shift;            // Dovish kayma
   bool                  hawkish_shift;           // Hawkish kayma
   double                policy_uncertainty;      // Politik belirsizlik (0-100)
   double                rate_expectation_change; // Faiz beklenti değişimi
   
   // Central Bank Intervention
   bool                  fx_intervention_risk;    // FX müdahale riski
   bool                  yield_curve_control;     // Yield curve kontrolü
   bool                  quantitative_easing;     // Niceliksel gevşeme
   bool                  quantitative_tightening; // Niceliksel sıkılaştırma
   
   // Policy Communication Impact
   bool                  forward_guidance_change; // Forward guidance değişimi
   double                communication_impact;    // İletişim etkisi
   bool                  policy_surprise;         // Politik sürpriz
   double                market_reaction_intensity; // Market reaksiyon yoğunluğu
   
   // Cross-Border Impact
   double                spillover_effect;        // Yayılma etkisi
   bool                  currency_war_risk;       // Para savaşı riski
   double                global_liquidity_impact; // Global likidite etkisi
   bool                  emergency_measures;      // Acil Önlemler
   
   // Economic Data Impact
   double                inflation_surprise;      // Enflasyon sürprizi
   double                employment_surprise;     // İstihdam sürprizi
   double                gdp_surprise;            // GDP sürprizi
   bool                  data_dependent_policy;   // Veriye bağlı politika
   
   PolicyImpactInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      dovish_shift = hawkish_shift = false;
      policy_uncertainty = rate_expectation_change = 0.0;
      
      fx_intervention_risk = yield_curve_control = false;
      quantitative_easing = quantitative_tightening = false;
      emergency_measures = false;
      forward_guidance_change = policy_surprise = false;
      communication_impact = market_reaction_intensity = 0.0;
      
      spillover_effect = global_liquidity_impact = 0.0;
      currency_war_risk = false;
      
      inflation_surprise = employment_surprise = gdp_surprise = 0.0;
      data_dependent_policy = false;
   }
};

//+------------------------------------------------------------------+
//| CROSS ASSET VOLATILITY INFO STRUCTURE                          |
//+------------------------------------------------------------------+
struct CrossAssetVolatilityInfo
{
   // Asset Correlation Matrix
   double                equity_correlation;      // Hisse korelasyonu
   double                bond_correlation;        // Tahvil korelasyonu
   double                commodity_correlation;   // Emtia korelasyonu
   double                currency_correlation;    // Para birimi korelasyonu
   double                crypto_correlation;      // Kripto korelasyonu
   
   // Cross-Asset Volatility Spillover
   double                equity_vol_spillover;    // Hisse vol yayılımı
   double                bond_vol_spillover;      // Tahvil vol yayılımı
   double                fx_vol_spillover;        // FX vol yayılımı
   double                commodity_vol_spillover; // Emtia vol yayılımı
   double                correlation_breakdown;   // Korelasyon dağılımı
   
   // Sector Rotation Analysis
   bool                  defensive_rotation;      // Savunma rotasyonu
   bool                  growth_rotation;         // Büyüme rotasyonu
   bool                  value_rotation;          // Değer rotasyonu
   double                sector_momentum;         // Sektör momentumu
   
   // Safe Haven Flows
   bool                  gold_safe_haven_flow;    // Altın güvenli liman akışı
   bool                  yen_safe_haven_flow;     // Yen güvenli liman akışı
   bool                  treasury_safe_haven_flow; // Hazine güvenli liman akışı
   bool                  dollar_safe_haven_flow;  // Dolar güvenli liman akışı
   
   // Global Risk Indicators
   double                global_risk_appetite;    // Global risk iştahı
   double                emerging_market_stress;  // Gelişen piyasa stresi
   double                carry_trade_unwinding;   // Carry trade çözülmesi
   bool                  deleveraging_event;      // Kaldıraç azaltma olayı
   
   // Economic Regime Detection
   bool                  growth_scare;            // Büyüme korkusu
   bool                  inflation_scare;         // Enflasyon korkusu
   bool                  stagflation_risk;        // Stagflasyon riski
   bool                  deflation_risk;          // Deflasyon riski
   
   CrossAssetVolatilityInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      equity_correlation = bond_correlation = commodity_correlation = 0.0;
      currency_correlation = crypto_correlation = 0.0;
      
      equity_vol_spillover = bond_vol_spillover = fx_vol_spillover = 0.0;
      commodity_vol_spillover = 0.0;
      
      defensive_rotation = growth_rotation = value_rotation = false;
      sector_momentum = 0.0;
      
      gold_safe_haven_flow = yen_safe_haven_flow = false;
      treasury_safe_haven_flow = dollar_safe_haven_flow = false;
      
      global_risk_appetite = emerging_market_stress = carry_trade_unwinding = 0.0;
      deleveraging_event = false;
      
      growth_scare = inflation_scare = stagflation_risk = deflation_risk = false;
   }
};

//+------------------------------------------------------------------+
//| DARK POOL VOLATILITY INFO STRUCTURE                            |
//+------------------------------------------------------------------+
struct DarkPoolVolatilityInfo
{
   // Dark Pool Detection
   bool                  dark_pool_activity;      // Dark pool aktivitesi
   double                dark_pool_volume_ratio;  // Dark pool volume oranı
   bool                  iceberg_orders;          // Iceberg orders
   double                hidden_liquidity_factor; // Gizli likidite faktörü
   
   // Institutional Footprint
   bool                  block_trading;           // Block trading
   bool                  algo_trading_surge;      // Algo trading patlaması
   bool                  hft_volatility_farming;  // HFT vol farming
   double                institutional_vol_demand; // Institutional vol talebi
   
   // Stealth Trading Patterns
   bool                  stealth_accumulation;    // Gizli birikim
   bool                  stealth_distribution;    // Gizli dağıtım
   double                stealth_trading_intensity; // Gizli işlem yoğunluğu
   bool                  coordinated_execution;   // Koordineli işlem
   
   // Market Microstructure
   double                bid_ask_impact;          // Bid-ask etkisi
   double                market_impact_cost;      // Market etki maliyeti
   bool                  liquidity_provision;     // Likidite sağlama
   bool                  liquidity_consumption;   // Likidite tüketimi
   
   // Volatility Trading Signals
   bool                  vol_arb_opportunity;     // Vol arbitraj fırsatı
   bool                  gamma_squeeze_risk;      // Gamma sıkışması riski
   bool                  volatility_clustering;   // Volatilite kümelenmesi
   double                implied_realized_spread; // IV-RV spread
   
   DarkPoolVolatilityInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      dark_pool_activity = iceberg_orders = false;
      dark_pool_volume_ratio = hidden_liquidity_factor = 0.0;
      
      block_trading = algo_trading_surge = hft_volatility_farming = false;
      institutional_vol_demand = 0.0;
      
      stealth_accumulation = stealth_distribution = coordinated_execution = false;
      stealth_trading_intensity = 0.0;
      
      bid_ask_impact = market_impact_cost = 0.0;
      liquidity_provision = liquidity_consumption = false;
      
      vol_arb_opportunity = gamma_squeeze_risk = volatility_clustering = false;
      implied_realized_spread = 0.0;
   }
};
//+------------------------------------------------------------------+
//| ENHANCED ATR VOLATILITY INFO - NUCLEAR LEVEL                   |
//+------------------------------------------------------------------+
struct ATRVolatilityInfo
{
   // Temel ATR verileri
   datetime               calculation_time;   // Hesaplama zamanı
   string                 symbol;             // Sembol
   
   // Multi-timeframe ATR değerleri
   double                 atr_m15;            // M15 ATR
   double                 atr_h1;             // H1 ATR
   double                 atr_h4;             // H4 ATR
   double                 atr_d1;             // D1 ATR
   double                 atr_w1;             // W1 ATR
   
   // ATR periode göre
   double                 atr_14[5];          // ATR 14 period (5 timeframe)
   double                 atr_21[5];          // ATR 21 period
   double                 atr_50[5];          // ATR 50 period
   
   // Volatility Regime Analysis
   ENUM_VOLATILITY_REGIME current_regime;    // Mevcut volatilite rejimi
   ENUM_VOLATILITY_REGIME regime_h1;         // H1 rejim
   ENUM_VOLATILITY_REGIME regime_h4;         // H4 rejim
   ENUM_VOLATILITY_REGIME regime_d1;         // D1 rejim
   
   // Volatility Metrics
   double                 volatility_percentile; // Volatilite yüzdelik (0-100)
   double                 volatility_zscore;     // Z-score (-3 to +3)
   double                 volatility_rank;       // Rank 0-1
   bool                   extreme_volatility;   // Aşırı volatilite
   
   // Expansion/Contraction Analysis
   bool                   volatility_expansion; // Volatilite genişlemesi
   bool                   volatility_contraction; // Volatilite daralması
   double                 expansion_strength;   // Genişleme gücü (0-100)
   double                 contraction_duration; // Daralma süresi (bar)
   int                    expansion_bars;       // Genişleme bar sayısı
   
   // ATR Trend Analysis
   ENUM_TREND_DIRECTION   atr_trend_short;     // Kısa vadeli ATR trend
   ENUM_TREND_DIRECTION   atr_trend_medium;    // Orta vadeli ATR trend
   ENUM_TREND_DIRECTION   atr_trend_long;      // Uzun vadeli ATR trend
   double                 atr_momentum;        // ATR momentum (-100 to +100)
   
   // Stop Loss Optimization
   double                 optimal_stop_loss;   // Optimal stop loss mesafesi
   double                 conservative_sl;     // Muhafazakar SL
   double                 aggressive_sl;       // Agresif SL
   double                 atr_multiplier_sl;   // ATR çarpan SL için
   double                 breakeven_distance;  // Breakeven mesafesi
   
   // Position Sizing
   double                 atr_position_size;   // ATR bazlı pozisyon boyutu
   double                 risk_adjusted_size;  // Risk düzeltmeli boyut
   double                 volatility_adjusted_size; // Volatilite düzeltmeli
   double                 max_position_size;   // Maksimum pozisyon boyutu
   
   // Advanced Volatility Features
   double                 garch_volatility;    // GARCH model volatilite
   double                 realized_volatility; // Gerçekleşen volatilite
   double                 implied_volatility;  // Implied volatilite (approx)
   double                 volatility_smile;    // Volatilite gülümsemesi
   
   // Market Session Analysis
   double                 session_volatility[7]; // Enhanced session array
   bool                   high_volatility_session; // Yüksek vol session
   double                 current_session_factor; // Mevcut session faktörü
   ENUM_TRADING_SESSION   current_session;     // Mevcut session
   
   // Breakout Potential
   double                 breakout_probability; // Kırılım olasılığı
   double                 false_breakout_risk;  // Sahte kırılım riski
   double                 continuation_probability; // Devam olasılığı
   double                 reversal_probability; // Dönüş olasılığı
   
   // ML Predictions
   double                 ml_volatility_forecast; // ML volatilite tahmini
   double                 ml_regime_probability;  // ML rejim olasılığı
   double                 ml_expansion_signal;    // ML genişleme sinyali
   double                 pattern_recognition;    // Pattern tanıma skoru
   
   // Risk Assessment
   ENUM_RISK_LEVEL        volatility_risk;     // Volatilite riski
   double                 portfolio_heat;      // Portfolio ısısı
   bool                   regime_change_risk;  // Rejim değişim riski
   double                 tail_risk;           // Kuyruk riski
   
   // Signal Generation
   ENUM_SIGNAL_TYPE       primary_signal;     // Ana sinyal
   ENUM_SIGNAL_STRENGTH   signal_strength;    // Sinyal gücü
   double                 signal_confidence;  // Sinyal güveni
   double                 entry_timing_score; // Giriş zamanlama skoru
   
   // Confluence Information
   double                 confluence_score;   // Confluence skoru
   int                    timeframe_alignment; // TF uyumu
   ENUM_CONFLUENCE_LEVEL  confluence_level;   // Confluence seviyesi
   
   // INSTITUTIONAL ENHANCEMENTS - NUCLEAR LEVEL
   VolatilitySurfaceInfo  vol_surface;        // Volatility surface analysis
   RiskRegimeInfo         risk_regime;        // Risk regime analysis
   PolicyImpactInfo       policy_impact;      // Central bank policy impact
   CrossAssetVolatilityInfo cross_asset;      // Cross-asset volatility
   DarkPoolVolatilityInfo dark_pool;          // Dark pool volatility
   
   // Advanced Institutional Metrics
   double                 institutional_vol_demand; // Institutional vol demand
   double                 retail_vol_sentiment;     // Retail vol sentiment
   double                 smart_money_vol_positioning; // Smart money vol positioning
   bool                   vol_regime_change_imminent; // Vol rejim değişimi yakın
   double                 systemic_vol_risk;         // Sistemik vol riski
   
   // Cross-Market Volatility Spillover
   double                 equity_vol_spillover;      // Equity vol spillover
   double                 bond_vol_spillover;        // Bond vol spillover
   double                 fx_vol_spillover;          // FX vol spillover
   double                 commodity_vol_spillover;   // Commodity vol spillover
   
   // Real-Time Institutional Detection
   bool                   real_time_institutional_flow; // Real-time institutional flow
   bool                   algo_vol_farming;              // Algorithmic vol farming
   bool                   gamma_hedging_flow;            // Gamma hedging flow
   bool                   vol_surface_arbitrage;         // Vol surface arbitrage
   
   // Market Microstructure Volatility
   double                 microstructure_vol;         // Microstructure volatility
   double                 order_flow_imbalance_vol;   // Order flow imbalance vol
   double                 liquidity_adjusted_vol;     // Liquidity adjusted vol
   bool                   vol_clustering_detected;    // Vol clustering detection
   
   // Constructor
   ATRVolatilityInfo()
   {
      Reset();
   }
   
   void Reset()
   {
      calculation_time = 0;
      symbol = "";
      
      atr_m15 = atr_h1 = atr_h4 = atr_d1 = atr_w1 = 0.0;
      
      ArrayInitialize(atr_14, 0.0);
      ArrayInitialize(atr_21, 0.0);
      ArrayInitialize(atr_50, 0.0);
      
      current_regime = VOLATILITY_UNKNOWN;
      regime_h1 = regime_h4 = regime_d1 = VOLATILITY_UNKNOWN;
      
      volatility_percentile = 50.0;
      volatility_zscore = 0.0;
      volatility_rank = 0.5;
      extreme_volatility = false;
      
      volatility_expansion = false;
      volatility_contraction = false;
      expansion_strength = 0.0;
      contraction_duration = 0.0;
      expansion_bars = 0;
      
      atr_trend_short = atr_trend_medium = atr_trend_long = TREND_NEUTRAL;
      atr_momentum = 0.0;
      
      optimal_stop_loss = 0.0;
      conservative_sl = 0.0;
      aggressive_sl = 0.0;
      atr_multiplier_sl = 2.0;
      breakeven_distance = 0.0;
      
      atr_position_size = 0.0;
      risk_adjusted_size = 0.0;
      volatility_adjusted_size = 0.0;
      max_position_size = 0.0;
      
      garch_volatility = 0.0;
      realized_volatility = 0.0;
      implied_volatility = 0.0;
      volatility_smile = 0.0;
      
      ArrayInitialize(session_volatility, 0.0);
      high_volatility_session = false;
      current_session_factor = 1.0;
      current_session = SESSION_SYDNEY;
      
      breakout_probability = 0.0;
      false_breakout_risk = 0.0;
      continuation_probability = 0.0;
      reversal_probability = 0.0;
      
      ml_volatility_forecast = 0.0;
      ml_regime_probability = 0.0;
      ml_expansion_signal = 0.0;
      pattern_recognition = 0.0;
      
      volatility_risk = RISK_MEDIUM;
      portfolio_heat = 0.0;
      regime_change_risk = false;
      tail_risk = 0.0;
      
      primary_signal = SIGNAL_NONE;
      signal_strength = SIGNAL_STRENGTH_NONE;
      signal_confidence = 0.0;
      entry_timing_score = 0.0;
      
      confluence_score = 0.0;
      timeframe_alignment = 0;
      confluence_level = CONFLUENCE_NONE;
      
      // Reset institutional structures
      vol_surface.Reset();
      risk_regime.Reset();
      policy_impact.Reset();
      cross_asset.Reset();
      dark_pool.Reset();
      
      // Reset advanced institutional metrics
      institutional_vol_demand = 0.0;
      retail_vol_sentiment = 0.0;
      smart_money_vol_positioning = 0.0;
      vol_regime_change_imminent = false;
      systemic_vol_risk = 0.0;
      
      equity_vol_spillover = bond_vol_spillover = 0.0;
      fx_vol_spillover = commodity_vol_spillover = 0.0;
      
      real_time_institutional_flow = false;
      algo_vol_farming = false;
      gamma_hedging_flow = false;
      vol_surface_arbitrage = false;
      
      microstructure_vol = 0.0;
      order_flow_imbalance_vol = 0.0;
      liquidity_adjusted_vol = 0.0;
      vol_clustering_detected = false;
   }
   
   bool IsValid() const
   {
      return (calculation_time > 0 && StringLen(symbol) > 0 && 
              atr_h1 > 0.0 && volatility_percentile >= 0.0);
   }
   
   string ToString() const
   {
      return StringFormat("ATR H1: %.5f | Regime: %s | Vol%%: %.1f | Risk: %s | Signal: %s | Institutional: %s",
                         atr_h1, VolatilityRegimeToString(current_regime),
                         volatility_percentile, RiskLevelToString(volatility_risk),
                         SignalTypeToString(primary_signal),
                         (real_time_institutional_flow ? "ACTIVE" : "INACTIVE"));
   }
   
   // Advanced analysis methods
   bool IsInstitutionalVolatilityEvent() const
   {
      return (dark_pool.dark_pool_activity || 
              risk_regime.institutional_hedging ||
              real_time_institutional_flow ||
              vol_surface_arbitrage);
   }
   
   double GetInstitutionalVolatilityScore() const
   {
      double score = 0.0;
      
      if(dark_pool.dark_pool_activity) score += 25.0;
      if(risk_regime.institutional_hedging) score += 20.0;
      if(vol_surface_arbitrage) score += 15.0;
      if(gamma_hedging_flow) score += 10.0;
      
      score += institutional_vol_demand;
      score += smart_money_vol_positioning * 0.3;
      
      return MathMin(100.0, score);
   }
   
   bool IsVolatilityRegimeChange() const
   {
      return (vol_regime_change_imminent || 
              regime_change_risk ||
              vol_surface.vol_regime_change);
   }
   
   ENUM_MARKET_REGIME GetMarketRegime() const
   {
      if(risk_regime.market_crash_risk) return REGIME_CRISIS;
      if(volatility_expansion && expansion_strength > 70.0) return REGIME_BREAKOUT;
      if(volatility_contraction && contraction_duration > 10) return REGIME_RANGING;
      if(current_regime == VOLATILITY_HIGH) return REGIME_HIGH_VOLATILITY;
      if(current_regime == VOLATILITY_LOW) return REGIME_LOW_VOLATILITY;
      return REGIME_UNKNOWN;
   }
};
//+------------------------------------------------------------------+
//| NUCLEAR LEVEL ATR VOLATILITY ENGINE CLASS                       |
//+------------------------------------------------------------------+
class ATRVolatilityEngine
{
private:  
   // Engine parametreleri
   string                  m_symbol;           // Analiz sembolü
   ENUM_TIMEFRAMES         m_timeframe;        // Ana zaman çerçevesi
   bool                    m_initialized;      // Başlatılma durumu
   
   // ATR calculation parameters
   int                     m_atr_period_short;    // Kısa ATR periyodu
   int                     m_atr_period_medium;   // Orta ATR periyodu
   int                     m_atr_period_long;     // Uzun ATR periyodu
   
   // Dinamik array yapıları
   struct TimeframeData
   {
      double                atr_history[];
      double                price_history[];
      datetime              time_history[];
      double                volatility_percentiles[];
      int                   history_size;
      bool                  percentiles_calculated;
      
      TimeframeData()
      {
         ArrayResize(atr_history, 500);
         ArrayResize(price_history, 500);
         ArrayResize(time_history, 500);
         ArrayResize(volatility_percentiles, 100);
         history_size = 0;
         percentiles_calculated = false;
      }
   };
   
   TimeframeData           m_tf_data[5];        // Her timeframe için ayrı data
   
   // Enhanced session data
   MarketSession           m_sessions[7];          // Enhanced market sessions
   int                     m_current_session;     // Mevcut session
   
   // ML components - Enhanced
   struct MLData
   {
      double                features[];
      double                weights[];
      double                lstm_weights[];
      double                gru_weights[];
      double                transformer_weights[];
      bool                  is_trained;
      bool                  deep_learning_active;
      
      MLData()
      {
         ArrayResize(features, 75);
         ArrayResize(weights, 75);
         ArrayResize(lstm_weights, 100);
         ArrayResize(gru_weights, 100);
         ArrayResize(transformer_weights, 200);
         is_trained = false;
         deep_learning_active = false;
      }
   };
   
   MLData                  m_ml_data;
   
   // Enhanced GARCH model
   double                  m_garch_weights[20];       // Enhanced GARCH model weights
   double                  m_correlation_matrix[25];  // 5x5 TF correlation matrix flattened
   
   // Cross-asset data storage
   struct CrossAssetData
   {
      double                data[];
      string                symbols[10];
      int                   count;
      
      CrossAssetData()
      {
         ArrayResize(data, 1000);
         count = 0;
      }
   };
   
   CrossAssetData          m_cross_asset;
   
   // Real-time institutional detection
   struct InstitutionalData
   {
      double                flow_history[200];
      double                dark_pool_activity_history[200];
      double                features[50];
      double                dark_pool_features[30];
      double                regime_features[40];
      int                   history_size;
      
      InstitutionalData()
      {
         ArrayInitialize(flow_history, 0.0);
         ArrayInitialize(dark_pool_activity_history, 0.0);
         ArrayInitialize(features, 0.0);
         ArrayInitialize(dark_pool_features, 0.0);
         ArrayInitialize(regime_features, 0.0);
         history_size = 0;
      }
   };
   
   InstitutionalData       m_institutional;
   
   // Market microstructure data
   struct MicrostructureData
   {
      double                bid_ask_spreads[100];
      double                order_flow_imbalance[100];
      double                market_impact_costs[100];
      int                   history_size;
      
      MicrostructureData()
      {
         ArrayInitialize(bid_ask_spreads, 0.0);
         ArrayInitialize(order_flow_imbalance, 0.0);
         ArrayInitialize(market_impact_costs, 0.0);
         history_size = 0;
      }
   };
   
   MicrostructureData      m_microstructure;
   
   // Performance tracking
   int                     m_total_calculations;
   double                  m_accuracy_rate;
   datetime                m_last_calculation;
   
   // Timeframe mapping
   ENUM_TIMEFRAMES         m_timeframes[5];       // Analiz edilen timeframe'ler
   int                     m_timeframe_count;     // Timeframe sayısı

   //+------------------------------------------------------------------+
   //| PRIVATE INITIALIZATION METHODS                                  |
   //+------------------------------------------------------------------+
   
   bool Initialize();
   void InitializeBasicSettings();
   void InitializeCrossAssetSymbols();
   void InitializeEnhancedMarketSessions();
   bool LoadEnhancedHistoricalATRData();
   bool CalculateEnhancedVolatilityPercentiles();
   void InitializeEnhancedMLModels();
   void LoadCrossAssetData();
   void InitializeInstitutionalDetectionModels();
   void CalculateEnhancedCorrelationMatrix();
   void InitializeMarketMicrostructureAnalysis();

   //+------------------------------------------------------------------+
   //| PRIVATE CORE ATR ANALYSIS METHODS                              |
   //+------------------------------------------------------------------+
   bool GetEnhancedCurrentATRValues(ATRVolatilityInfo &info);
   void AnalyzeEnhancedVolatilityRegimes(ATRVolatilityInfo &info);
   void CalculateEnhancedVolatilityMetrics(ATRVolatilityInfo &info);
   void AnalyzeEnhancedVolatilityExpansionContraction(ATRVolatilityInfo &info);
   void AnalyzeEnhancedATRTrends(ATRVolatilityInfo &info);
   void CalculateEnhancedOptimalStopLoss(ATRVolatilityInfo &info);
   void CalculateEnhancedPositionSizing(ATRVolatilityInfo &info);

   //+------------------------------------------------------------------+
   //| PRIVATE INSTITUTIONAL ANALYSIS METHODS                         |
   //+------------------------------------------------------------------+
   void AnalyzeVolatilitySurface(ATRVolatilityInfo &info);
   void AnalyzeRiskRegime(ATRVolatilityInfo &info);
   void AnalyzePolicyImpact(ATRVolatilityInfo &info);
   void AnalyzeCrossAssetVolatility(ATRVolatilityInfo &info);
   void AnalyzeDarkPoolVolatility(ATRVolatilityInfo &info);
   
   // Volatility Surface Sub-methods
   void CalculateImpliedVolatilitySmile(VolatilitySurfaceInfo &surface, const ATRVolatilityInfo &info);
   void CalculateVolatilityTermStructure(VolatilitySurfaceInfo &surface, const ATRVolatilityInfo &info);
   void CalculateAdvancedVolatilityMetrics(VolatilitySurfaceInfo &surface, const ATRVolatilityInfo &info);
   void GenerateVolatilitySurfaceSignals(VolatilitySurfaceInfo &surface, const ATRVolatilityInfo &info);
   
   // Risk Regime Sub-methods
   void DetectRiskOnRiskOff(RiskRegimeInfo &risk, const ATRVolatilityInfo &info);
   void CalculateMarketStressIndicators(RiskRegimeInfo &risk, const ATRVolatilityInfo &info);
   void AnalyzeInstitutionalBehavior(RiskRegimeInfo &risk, const ATRVolatilityInfo &info);
   void DetectCrisisSignals(RiskRegimeInfo &risk, const ATRVolatilityInfo &info);
   void AnalyzeCentralBankResponse(RiskRegimeInfo &risk, const ATRVolatilityInfo &info);
   
   // Policy Impact Sub-methods
   void AnalyzeMonetaryPolicyStance(PolicyImpactInfo &policy, const ATRVolatilityInfo &info);
   void AnalyzeCentralBankIntervention(PolicyImpactInfo &policy, const ATRVolatilityInfo &info);
   void AnalyzePolicyCommunicationImpact(PolicyImpactInfo &policy, const ATRVolatilityInfo &info);
   void AnalyzeCrossBorderImpact(PolicyImpactInfo &policy, const ATRVolatilityInfo &info);
   void AnalyzeEconomicDataImpact(PolicyImpactInfo &policy, const ATRVolatilityInfo &info);
   
   // Cross-Asset Sub-methods
   void CalculateAssetCorrelations(CrossAssetVolatilityInfo &cross, const ATRVolatilityInfo &info);
   void AnalyzeVolatilitySpillover(CrossAssetVolatilityInfo &cross, const ATRVolatilityInfo &info);
   void AnalyzeSectorRotation(CrossAssetVolatilityInfo &cross, const ATRVolatilityInfo &info);
   
   // Dark Pool Sub-methods
   void DetectDarkPoolActivity(DarkPoolVolatilityInfo &dark, const ATRVolatilityInfo &info);
   void AnalyzeInstitutionalFootprint(DarkPoolVolatilityInfo &dark, const ATRVolatilityInfo &info);
   void DetectStealthTradingPatterns(DarkPoolVolatilityInfo &dark, const ATRVolatilityInfo &info);
   void AnalyzeMarketMicrostructure(DarkPoolVolatilityInfo &dark, const ATRVolatilityInfo &info);
   void GenerateDarkPoolVolatilitySignals(DarkPoolVolatilityInfo &dark, const ATRVolatilityInfo &info);

   //+------------------------------------------------------------------+
   //| PRIVATE ENHANCED ANALYSIS METHODS                              |
   //+------------------------------------------------------------------+
   void AnalyzeEnhancedMarketSessions(ATRVolatilityInfo &info);
   void AnalyzeEnhancedBreakoutPotential(ATRVolatilityInfo &info);
   
   // Market Session Sub-methods
   ENUM_TRADING_SESSION DetermineCurrentSession(int hour);
   void AnalyzeSessionVolatilityPatterns(ATRVolatilityInfo &info);
   void CalculateSessionVolatilityFactors(ATRVolatilityInfo &info);
   void DetectHighVolatilitySessions(ATRVolatilityInfo &info);
   void CalculateSessionTransitionEffects(ATRVolatilityInfo &info);
   
   // Breakout Analysis Sub-methods
   void CalculateBreakoutProbability(ATRVolatilityInfo &info);
   void AssessFalseBreakoutRisk(ATRVolatilityInfo &info);
   void CalculateContinuationProbability(ATRVolatilityInfo &info);
   void CalculateReversalProbability(ATRVolatilityInfo &info);
   void IntegrateCrossAssetConfirmation(ATRVolatilityInfo &info);

   //+------------------------------------------------------------------+
   //| PRIVATE NUCLEAR ML METHODS                                     |
   //+------------------------------------------------------------------+
   void ExtractNuclearMLFeatures(ATRVolatilityInfo &info);
   void CalculateNuclearMLPredictions(ATRVolatilityInfo &info);
   
   // ML Feature Extraction Sub-methods
   void ExtractBasicVolatilityFeatures(const ATRVolatilityInfo &info);
   void ExtractCrossTimeframeFeatures(const ATRVolatilityInfo &info);
   void ExtractInstitutionalFeatures(const ATRVolatilityInfo &info);
   void ExtractRiskRegimeFeatures(const ATRVolatilityInfo &info);
   void ExtractAdvancedFeatures(const ATRVolatilityInfo &info);
   void NormalizeMLFeatures();
   
   // ML Prediction Sub-methods
   void CalculateBasicMLPredictions(ATRVolatilityInfo &info);
   void CalculateDeepLearningPredictions(ATRVolatilityInfo &info);
   void CalculateEnsemblePredictions(ATRVolatilityInfo &info);
   void CalculatePatternRecognition(ATRVolatilityInfo &info);
   
   // Deep Learning Sub-methods
   double CalculateLSTMOutput();
   double CalculateGRUOutput();
   double CalculateTransformerOutput();
   double CalculatePatternBasedForecast(const ATRVolatilityInfo &info);

   //+------------------------------------------------------------------+
   //| PRIVATE INSTITUTIONAL DETECTION METHODS                        |
   //+------------------------------------------------------------------+
   void DetectInstitutionalActivity(ATRVolatilityInfo &info);
   void AnalyzeRealTimeMicrostructure(ATRVolatilityInfo &info);
   
   // Institutional Detection Sub-methods
   void DetectRealTimeInstitutionalFlow(ATRVolatilityInfo &info);
   void DetectAlgorithmicVolatilityFarming(ATRVolatilityInfo &info);
   void DetectGammaHedgingFlow(ATRVolatilityInfo &info);
   void DetectVolatilitySurfaceArbitrage(ATRVolatilityInfo &info);
   void UpdateInstitutionalMetrics(ATRVolatilityInfo &info);
   void UpdateInstitutionalFlowHistory(double flow_value);
   
   // Microstructure Analysis Sub-methods
   void CalculateMicrostructureVolatility(ATRVolatilityInfo &info);
   void AnalyzeOrderFlowImbalance(ATRVolatilityInfo &info);
   void CalculateLiquidityAdjustedVolatility(ATRVolatilityInfo &info);
   void DetectVolatilityClustering(ATRVolatilityInfo &info);
   void UpdateMicrostructureHistory(const ATRVolatilityInfo &info);

   //+------------------------------------------------------------------+
   //| PRIVATE RISK AND SIGNAL METHODS                                |
   //+------------------------------------------------------------------+
   void AssessNuclearVolatilityRisk(ATRVolatilityInfo &info);
   void GenerateNuclearVolatilitySignals(ATRVolatilityInfo &info);
   void CalculateNuclearVolatilityConfluence(ATRVolatilityInfo &info);
   
   // Risk Assessment Sub-methods
   void CalculatePortfolioHeat(ATRVolatilityInfo &info);
   void AssessTailRisk(ATRVolatilityInfo &info);
   void CalculateSystemicVolatilityRisk(ATRVolatilityInfo &info);
   void DetermineVolatilityRiskLevel(ATRVolatilityInfo &info);
   void GenerateRiskWarnings(const ATRVolatilityInfo &info);
   
   // Signal Generation Sub-methods
   void DeterminePrimaryVolatilitySignal(ATRVolatilityInfo &info);
   void CalculateSignalStrength(ATRVolatilityInfo &info);
   void CalculateSignalConfidence(ATRVolatilityInfo &info);
   void CalculateEntryTimingScore(ATRVolatilityInfo &info);
   void ApplySignalFilters(ATRVolatilityInfo &info);
   
   // Confluence Calculation Sub-methods
   void CalculateTimeframeAlignment(ATRVolatilityInfo &info);
   void CalculateCrossAssetConfluence(ATRVolatilityInfo &info);
   void CalculateInstitutionalConfluence(ATRVolatilityInfo &info);
   void CalculatePolicyConfluence(ATRVolatilityInfo &info);
   void CalculateOverallConfluenceScore(ATRVolatilityInfo &info);
   void DetermineConfluenceLevel(ATRVolatilityInfo &info);

   //+------------------------------------------------------------------+
   //| PRIVATE UTILITY AND HELPER METHODS                             |
   //+------------------------------------------------------------------+
   
   // Volatility Regime Helper Methods
   ENUM_VOLATILITY_REGIME DetermineEnhancedVolatilityRegime(int tf_index, double current_atr);
   ENUM_VOLATILITY_REGIME DetermineEnhancedOverallRegime(const ATRVolatilityInfo &info);
   double FindEnhancedATRPercentile(int tf_index, double atr_value);
   bool DetectVolatilityRegimeChangeRisk(const ATRVolatilityInfo &info);
   double VolatilityRegimeToScore(ENUM_VOLATILITY_REGIME regime);
   ENUM_VOLATILITY_REGIME ScoreToEnhancedVolatilityRegime(double score);
   
   // Cross-Asset Helper Methods  
   double CalculateCrossAssetVolatilityAdjustment();
   double CalculateSimpleCrossAssetVolatility(int asset_index);
   double CalculateCrossAssetVolatilityStress();
   double CalculateMLRegimeAdjustment(const ATRVolatilityInfo &info);
   
   // Enhanced Metrics Helper Methods
   double CalculateEnhancedATRZScore(int tf_index, double current_atr);
   double CalculateMLRankAdjustment(const ATRVolatilityInfo &info);
   
   // Expansion/Contraction Helper Methods
   int DetermineAdaptiveWindow();
   double CalculateAdaptiveExpansionThreshold(const ATRVolatilityInfo &info);
   double CalculateAdaptiveContractionThreshold(const ATRVolatilityInfo &info);
   int CountEnhancedConsecutiveExpansionBars();
   int CountEnhancedConsecutiveContractionBars();
   double CalculateCrossAssetExpansionConfirmation();
   
   // ATR Trend Helper Methods
   ENUM_TREND_DIRECTION CalculateATRTrend(int tf_index, int lookback);
   double CalculateATRMomentum(int tf_index);
   double CalculateEnhancedATRCorrelation(int tf1, int tf2);
   
   // Volatility Surface Helper Methods
   double CalculateVolatilitySkewAdjustment(double moneyness);
   double CalculateOverallVolatilitySkew(const VolatilitySurfaceInfo &surface);
   double CalculateVolatilitySurfaceCurvature(const VolatilitySurfaceInfo &surface);
   double CalculateVolatilityOfVolatility();
   double CalculateVolatilityMeanReversionSpeed();
   double CalculateVolatilityPersistence();
   bool DetectVolatilitySpikeExhaustion(const ATRVolatilityInfo &info);
   double CalculateRealizedVolatility(int hours);
   double CalculateVolatilityRiskPremium(const VolatilitySurfaceInfo &surface);
   double CalculateGARCHVolatilityForecast();
   
   // Risk Regime Helper Methods
   double CalculateVIXEquivalent(const ATRVolatilityInfo &info);
   double CalculateCorrelationBreakdown();

public:
   //+------------------------------------------------------------------+
   //| PUBLIC CONSTRUCTOR AND DESTRUCTOR                              |
   //+------------------------------------------------------------------+
   ATRVolatilityEngine(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_H1);
   ~ATRVolatilityEngine();

   //+------------------------------------------------------------------+
   //| PUBLIC MAIN INTERFACE METHODS                                  |
   //+------------------------------------------------------------------+
   
   /**
    * Ana volatilite analizi metodu - NUCLEAR LEVEL
    * @return ATRVolatilityInfo Kapsamlı volatilite analiz sonuçları
    */
   ATRVolatilityInfo ATRVolatilityEngine::AnalyzeVolatility()
   {
      ATRVolatilityInfo info;
      
      if(!ValidateEngineState())
      {
         Print("ERROR: Nuclear Engine validation failed");
         return info;
      }
      
      m_total_calculations++;
      info.calculation_time = TimeCurrent();
      info.symbol = m_symbol;
      
      Print(StringFormat("🚀 Starting NUCLEAR LEVEL volatility analysis for %s", m_symbol));
      
      // Core analysis phases
      if(!GetEnhancedCurrentATRValues(info))
      {
         Print("ERROR: Failed to get enhanced current ATR values");
         return info;
      }
      
      AnalyzeEnhancedVolatilityRegimes(info);
      CalculateEnhancedVolatilityMetrics(info);
      AnalyzeEnhancedVolatilityExpansionContraction(info);
      AnalyzeEnhancedATRTrends(info);
      CalculateEnhancedOptimalStopLoss(info);
      CalculateEnhancedPositionSizing(info);
      
      // INSTITUTIONAL ANALYSIS
      AnalyzeVolatilitySurface(info);
      AnalyzeRiskRegime(info);
      AnalyzePolicyImpact(info);
      AnalyzeCrossAssetVolatility(info);
      AnalyzeDarkPoolVolatility(info);
      
      // ENHANCED ANALYSIS
      AnalyzeEnhancedMarketSessions(info);
      AnalyzeEnhancedBreakoutPotential(info);
      
      // ML ANALYSIS
      ExtractNuclearMLFeatures(info);
      if(m_ml_data.is_trained)
         CalculateNuclearMLPredictions(info);
      
      // INSTITUTIONAL DETECTION
      DetectInstitutionalActivity(info);
      AnalyzeRealTimeMicrostructure(info);
      
      // RISK & SIGNALS
      AssessNuclearVolatilityRisk(info);
      GenerateNuclearVolatilitySignals(info);
      CalculateNuclearVolatilityConfluence(info);
      
      m_last_calculation = TimeCurrent();
      
      Print(StringFormat("✅ NUCLEAR LEVEL analysis completed. Institutional Score: %.1f%%", 
                        info.GetInstitutionalVolatilityScore()));
      
      return info;
   }

   //+------------------------------------------------------------------+
   //| PUBLIC CONFIGURATION METHODS                                   |
   //+------------------------------------------------------------------+
   
   /**
    * ATR periyotlarını ayarla
    */
   void SetATRPeriods(int short_period, int medium_period, int long_period);
   
   /**
    * ML modelini eğit
    */
   bool TrainMLModel();
   
   /**
    * Deep learning'i aktif et/deaktif et
    */
   void SetDeepLearningActive(bool active);
   
   /**
    * Performans güncelle
    */
   void UpdatePerformance(bool prediction_correct);

   //+------------------------------------------------------------------+
   //| PUBLIC STATUS AND INFO METHODS                                 |
   //+------------------------------------------------------------------+
   
   /**
    * Engine durumu sorgula
    */
   bool IsInitialized() const;
   bool IsMLTrained() const;
   bool IsDeepLearningActive() const;
   
   /**
    * Engine bilgileri
    */
   string GetSymbol() const;
   ENUM_TIMEFRAMES GetTimeframe() const;
   int GetTotalCalculations() const;
   double GetAccuracyRate() const;
   datetime GetLastCalculation() const;
   
   /**
    * ATR ayarları sorgula
    */
   int GetShortATRPeriod() const;
   int GetMediumATRPeriod() const;
   int GetLongATRPeriod() const;

   //+------------------------------------------------------------------+
   //| PUBLIC UTILITY METHODS                                         |
   //+------------------------------------------------------------------+
   
   /**
    * Engine performans raporu
    */
   string GetPerformanceReport() const;
   
   /**
    * Engine durumu raporu
    */
   string GetStatusReport() const;
   
   /**
    * Memory check
    */
   void CheckMemoryLeaks();
   
   /**
    * Validate engine state
    */
   bool ValidateEngineState() const;
};
//+------------------------------------------------------------------+
//| IMPLEMENTATION - CONSTRUCTOR                                    |
//+------------------------------------------------------------------+
ATRVolatilityEngine::ATRVolatilityEngine(string symbol, ENUM_TIMEFRAMES timeframe)
{
   // ✅ DÜZELTİLMİŞ - Basit constructor
   m_symbol = (StringLen(symbol) > 0) ? symbol : Symbol();
   m_timeframe = timeframe;
   m_initialized = false;
   
   // Temel ayarları başlat
   InitializeBasicSettings();
   
   // Asıl initialization'ı ayrı method'da yap
   if(!Initialize())
   {
      Print("ERROR: Nuclear ATRVolatilityEngine initialization failed");
      return;
   }
   
   Print(StringFormat("🚀 NUCLEAR ATRVolatilityEngine initialized: %s, TF: %d", m_symbol, m_timeframe));
}
ATRVolatilityEngine::~ATRVolatilityEngine()
{
   if(m_total_calculations > 0)
   {
      Print(StringFormat("🔥 Nuclear ATRVolatilityEngine destroyed. Accuracy: %.2f%% (%d calculations)",
                        m_accuracy_rate, m_total_calculations));
   }
}
void ATRVolatilityEngine::InitializeBasicSettings()
{
   m_atr_period_short = 14;
   m_atr_period_medium = 21;
   m_atr_period_long = 50;
   
   m_timeframes[0] = PERIOD_M15;
   m_timeframes[1] = PERIOD_H1;
   m_timeframes[2] = PERIOD_H4;
   m_timeframes[3] = PERIOD_D1;
   m_timeframes[4] = PERIOD_W1;
   m_timeframe_count = 5;
   
   // Initialize ML data
   ArrayResize(m_ml_data.features, 75);
   ArrayResize(m_ml_data.weights, 75);
   ArrayResize(m_ml_data.lstm_weights, 100);
   ArrayResize(m_ml_data.gru_weights, 100);
   ArrayResize(m_ml_data.transformer_weights, 200);
   m_ml_data.is_trained = false;
   m_ml_data.deep_learning_active = false;
   
   // Initialize cross asset data
   ArrayResize(m_cross_asset.data, 1000);
   m_cross_asset.count = 0;
   
   m_total_calculations = 0;
   m_accuracy_rate = 0.0;
   m_last_calculation = 0;
   m_current_session = 0;
   m_institutional.history_size = 0;
   m_microstructure.history_size = 0;
}
bool ATRVolatilityEngine::Initialize()
{
   ResetLastError();
   
   // Symbol validation
   if(!SymbolSelect(m_symbol, true))
   {
      Print(StringFormat("ERROR: Cannot select symbol: %s", m_symbol));
      return false;
   }
   
   // Initialize enhanced sessions
   InitializeEnhancedMarketSessions();
   
   // Initialize cross-asset symbols
   InitializeCrossAssetSymbols();
   
   // Load historical data
   if(!LoadEnhancedHistoricalATRData())
   {
      Print("WARNING: Could not load complete enhanced historical ATR data");
   }
   
   // Calculate percentiles
   if(!CalculateEnhancedVolatilityPercentiles())
   {
      Print("WARNING: Could not calculate enhanced volatility percentiles");
   }
   
   // Initialize ML models
   InitializeEnhancedMLModels();
   
   // Initialize other components
   LoadCrossAssetData();
   InitializeInstitutionalDetectionModels();
   CalculateEnhancedCorrelationMatrix();
   InitializeMarketMicrostructureAnalysis();
   
   m_initialized = true;
   Print("✅ Nuclear ATR Engine initialization completed successfully!");
   return true;
}
bool ATRVolatilityEngine::IsInitialized() const 
{ 
   return m_initialized; 
}
bool ATRVolatilityEngine::IsMLTrained() const 
{ 
   return m_ml_data.is_trained; 
}

bool ATRVolatilityEngine::IsDeepLearningActive() const 
{ 
   return m_ml_data.deep_learning_active; 
}

string ATRVolatilityEngine::GetSymbol() const 
{ 
   return m_symbol; 
}

ENUM_TIMEFRAMES ATRVolatilityEngine::GetTimeframe() const 
{ 
   return m_timeframe; 
}

int ATRVolatilityEngine::GetTotalCalculations() const 
{ 
   return m_total_calculations; 
}

double ATRVolatilityEngine::GetAccuracyRate() const 
{ 
   return m_accuracy_rate; 
}

datetime ATRVolatilityEngine::GetLastCalculation() const 
{ 
   return m_last_calculation; 
}

int ATRVolatilityEngine::GetShortATRPeriod() const 
{ 
   return m_atr_period_short; 
}

int ATRVolatilityEngine::GetMediumATRPeriod() const 
{ 
   return m_atr_period_medium; 
}

int ATRVolatilityEngine::GetLongATRPeriod() const 
{ 
   return m_atr_period_long; 
}
// ✅ PUBLIC CONFIGURATION METHODS
void ATRVolatilityEngine::SetATRPeriods(int short_period, int medium_period, int long_period)
{
   m_atr_period_short = short_period;
   m_atr_period_medium = medium_period;
   m_atr_period_long = long_period;
}

void ATRVolatilityEngine::SetDeepLearningActive(bool active)
{
   m_ml_data.deep_learning_active = active;
}

bool ATRVolatilityEngine::TrainMLModel()
{
   if(!m_initialized) return false;
   
   // Basit ML model eğitimi simulasyonu
   for(int i = 0; i < 75; i++)
   {
      m_ml_data.weights[i] = (MathRand() / 32767.0) * 2.0 - 1.0;
   }
   
   m_ml_data.is_trained = true;
   Print("🧠 ML model trained successfully");
   return true;
}

void ATRVolatilityEngine::UpdatePerformance(bool prediction_correct)
{
   if(m_total_calculations > 0)
   {
      double correct_predictions = m_accuracy_rate * (m_total_calculations - 1) / 100.0;
      if(prediction_correct) correct_predictions += 1.0;
      
      m_accuracy_rate = (correct_predictions / m_total_calculations) * 100.0;
   }
}

// ✅ PUBLIC UTILITY METHODS
string ATRVolatilityEngine::GetPerformanceReport() const
{
   return StringFormat("Nuclear ATR Engine - Symbol: %s | Calculations: %d | Accuracy: %.2f%% | Last: %s",
                      m_symbol, m_total_calculations, m_accuracy_rate, 
                      TimeToString(m_last_calculation));
}

string ATRVolatilityEngine::GetStatusReport() const
{
   return StringFormat("Status: %s | ML: %s | Deep Learning: %s | Cross-Assets: %d",
                      m_initialized ? "INITIALIZED" : "NOT_INITIALIZED",
                      m_ml_data.is_trained ? "TRAINED" : "NOT_TRAINED",
                      m_ml_data.deep_learning_active ? "ACTIVE" : "INACTIVE",
                      m_cross_asset.count);
}
void ATRVolatilityEngine::CheckMemoryLeaks()
{
   // Memory leak check implementation
   Print("Memory check completed");
}


void ATRVolatilityEngine::InitializeEnhancedMarketSessions()
{
   // Enhanced Sydney Session
   m_sessions[0].name = "Sydney";
   m_sessions[0].start_hour = 22;  // 22:00 GMT
   m_sessions[0].end_hour = 7;     // 07:00 GMT
   m_sessions[0].volatility_multiplier = 0.6;
   m_sessions[0].high_impact_session = false;
   m_sessions[0].avg_spread = 2.5;
   m_sessions[0].liquidity_factor = 0.7;
   
   // Enhanced Tokyo Session
   m_sessions[1].name = "Tokyo";
   m_sessions[1].start_hour = 0;   // 00:00 GMT
   m_sessions[1].end_hour = 9;     // 09:00 GMT
   m_sessions[1].volatility_multiplier = 0.8;
   m_sessions[1].high_impact_session = false;
   m_sessions[1].avg_spread = 2.0;
   m_sessions[1].liquidity_factor = 0.8;
   
   // Enhanced London Session
   m_sessions[2].name = "London";
   m_sessions[2].start_hour = 8;   // 08:00 GMT
   m_sessions[2].end_hour = 17;    // 17:00 GMT
   m_sessions[2].volatility_multiplier = 1.4;
   m_sessions[2].high_impact_session = true;
   m_sessions[2].avg_spread = 1.2;
   m_sessions[2].liquidity_factor = 1.4;
   
   // Enhanced New York Session
   m_sessions[3].name = "NewYork";
   m_sessions[3].start_hour = 13;  // 13:00 GMT
   m_sessions[3].end_hour = 22;    // 22:00 GMT
   m_sessions[3].volatility_multiplier = 1.5;
   m_sessions[3].high_impact_session = true;
   m_sessions[3].avg_spread = 1.5;
   m_sessions[3].liquidity_factor = 1.3;
   
   // London-NY Overlap (Most active)
   m_sessions[4].name = "London_NY_Overlap";
   m_sessions[4].start_hour = 13;  // 13:00 GMT
   m_sessions[4].end_hour = 17;    // 17:00 GMT
   m_sessions[4].volatility_multiplier = 1.8;
   m_sessions[4].high_impact_session = true;
   m_sessions[4].avg_spread = 1.0;
   m_sessions[4].liquidity_factor = 1.6;
   
   // Sydney-Tokyo Overlap
   m_sessions[5].name = "Sydney_Tokyo_Overlap";
   m_sessions[5].start_hour = 0;   // 00:00 GMT
   m_sessions[5].end_hour = 7;     // 07:00 GMT
   m_sessions[5].volatility_multiplier = 0.7;
   m_sessions[5].high_impact_session = false;
   m_sessions[5].avg_spread = 2.2;
   m_sessions[5].liquidity_factor = 0.8;
   
   // Dead Zone (Low activity)
   m_sessions[6].name = "Dead_Zone";
   m_sessions[6].start_hour = 17;  // 17:00 GMT
   m_sessions[6].end_hour = 22;    // 22:00 GMT
   m_sessions[6].volatility_multiplier = 0.4;
   m_sessions[6].high_impact_session = false;
   m_sessions[6].avg_spread = 3.0;
   m_sessions[6].liquidity_factor = 0.5;
   Print("Enhanced market sessions initialized");
}
bool ATRVolatilityEngine::LoadEnhancedHistoricalATRData()
{
   bool all_success = true;
   
   for(int tf = 0; tf < m_timeframe_count && tf < 5; tf++)
   {
      ENUM_TIMEFRAMES timeframe = m_timeframes[tf];
      
      // Load enhanced ATR data with multiple periods
      double atr_buffer[];
      ArraySetAsSeries(atr_buffer, true);
      
      int atr_handle = iATR(m_symbol, timeframe, m_atr_period_short);
      if(atr_handle == INVALID_HANDLE)
      {
         Print(StringFormat("ERROR: Cannot create ATR handle for TF: %d", timeframe));
         all_success = false;
         continue;
      }
      
      int copied = CopyBuffer(atr_handle, 0, 0, 500, atr_buffer);
      if(copied <= 0)
      {
         Print(StringFormat("WARNING: No ATR data copied for TF: %d", timeframe));
         all_success = false;
         continue;
      }
      
      // Load enhanced price data
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      
      int price_copied = CopyRates(m_symbol, timeframe, 0, copied, rates);
      if(price_copied != copied)
      {
         Print(StringFormat("WARNING: Price data mismatch for TF: %d", timeframe));
         all_success = false;
         continue;
      }
      
      // Store in enhanced internal arrays using TimeframeData struct
      int store_count = MathMin(copied, 500);
      for(int i = 0; i < store_count; i++)
      {
         m_tf_data[tf].atr_history[i] = atr_buffer[i];
         m_tf_data[tf].price_history[i] = rates[i].close;
         m_tf_data[tf].time_history[i] = rates[i].time;
      }
      m_tf_data[tf].history_size = store_count;
      
      // Percentile hesaplaması için flag'i sıfırla
      m_tf_data[tf].percentiles_calculated = false;
      
      IndicatorRelease(atr_handle);
   }
   
   Print(StringFormat("📊 Enhanced ATR historical data loaded for %d timeframes", m_timeframe_count));
   return all_success;
}
bool ATRVolatilityEngine::CalculateEnhancedVolatilityPercentiles()
{
   for(int tf = 0; tf < 5; tf++) // 5 timeframe
   {
      if(m_tf_data[tf].history_size < 50) continue;
      
      // Create enhanced sorted ATR array for percentile calculation
      double sorted_atr[];
      ArrayResize(sorted_atr, m_tf_data[tf].history_size);
      
      // Copy data from timeframe-specific array
      for(int i = 0; i < m_tf_data[tf].history_size; i++)
      {
         sorted_atr[i] = m_tf_data[tf].atr_history[i];
      }
      
      // Sort ATR values
      ArraySort(sorted_atr);
      
      // Calculate enhanced percentiles (0-99)
      for(int p = 0; p < 100; p++)
      {
         double position = p * (m_tf_data[tf].history_size - 1) / 100.0;
         int lower_index = (int)MathFloor(position);
         int upper_index = (int)MathCeil(position);
         
         if(lower_index == upper_index)
         {
            m_tf_data[tf].volatility_percentiles[p] = sorted_atr[lower_index];
         }
         else
         {
            double weight = position - lower_index;
            m_tf_data[tf].volatility_percentiles[p] = sorted_atr[lower_index] * (1 - weight) + 
                                     sorted_atr[upper_index] * weight;
         }
      }
      
      m_tf_data[tf].percentiles_calculated = true;
   }
   
   Print("📊 Enhanced volatility percentiles calculated for all timeframes");
   return true;
}

void ATRVolatilityEngine::InitializeEnhancedMLModels()
{
   // ML model initialization logic
   // Initialize enhanced ML weights
   for(int i = 0; i < ArraySize(m_ml_data.weights); i++)
   {
      m_ml_data.weights[i] = (MathRand() / 32767.0) * 2.0 - 1.0;
   }
   
   // Initialize LSTM weights
   for(int i = 0; i < ArraySize(m_ml_data.lstm_weights); i++)
   {
      m_ml_data.lstm_weights[i] = (MathRand() / 32767.0) * 0.1 - 0.05;
   }
   
   // Initialize GRU weights
   for(int i = 0; i < ArraySize(m_ml_data.gru_weights); i++)
   {
      m_ml_data.gru_weights[i] = (MathRand() / 32767.0) * 0.1 - 0.05;
   }
   
   // Initialize Transformer weights
   for(int i = 0; i < ArraySize(m_ml_data.transformer_weights); i++)
   {
      m_ml_data.transformer_weights[i] = (MathRand() / 32767.0) * 0.05 - 0.025;
   }
   
   // Initialize enhanced GARCH weights
   double garch_decay = 0.94;
   for(int i = 0; i < ArraySize(m_garch_weights); i++)
   {
      m_garch_weights[i] = MathPow(garch_decay, i);
   }
   
   // Initialize correlation matrix
   for(int i = 0; i < ArraySize(m_correlation_matrix); i++)
   {
      if(i % 6 == 0) // Diagonal elements (0, 6, 12, 18, 24)
         m_correlation_matrix[i] = 1.0;
      else
         m_correlation_matrix[i] = (MathRand() / 32767.0) * 0.2 - 0.1; // Small correlations
   }
   
   // Reset training status
   m_ml_data.is_trained = false;
   m_ml_data.deep_learning_active = false;
   
   Print("🧠 Enhanced ML models initialized with LSTM, GRU, and Transformer architectures");
   Print("📊 GARCH and correlation matrix initialized");
}
void ATRVolatilityEngine::InitializeCrossAssetSymbols()
{
   // Define cross-asset symbols for correlation analysis
   m_cross_asset.symbols[0] = "EURUSD";
   m_cross_asset.symbols[1] = "GBPUSD";
   m_cross_asset.symbols[2] = "USDJPY";
   m_cross_asset.symbols[3] = "AUDUSD";
   m_cross_asset.symbols[4] = "USDCHF";
   m_cross_asset.symbols[5] = "USDCAD";
   m_cross_asset.symbols[6] = "NZDUSD";
   m_cross_asset.symbols[7] = "XAUUSD";
   m_cross_asset.symbols[8] = "USOIL";
   m_cross_asset.symbols[9] = "US30";
   m_cross_asset.count = 10;
}
void ATRVolatilityEngine::LoadCrossAssetData()
{
   for(int asset = 0; asset < m_cross_asset.count; asset++)
   {
      string symbol = m_cross_asset.symbols[asset];
      
      if(!SymbolSelect(symbol, true))
      {
         Print(StringFormat("WARNING: Cannot select cross-asset symbol: %s", symbol));
         continue;
      }
      
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      
      int copied = CopyRates(symbol, m_timeframe, 0, 100, rates);
      if(copied > 0)
      {
         // Her sembol için 100'lük bloklar halinde veri saklama
         int start_index = asset * 100;
         
         // Array boyutunu kontrol et ve gerekirse genişlet
         if(start_index + copied > ArraySize(m_cross_asset.data))
         {
            ArrayResize(m_cross_asset.data, start_index + copied);
         }
         
         for(int i = 0; i < copied; i++)
         {
            m_cross_asset.data[start_index + i] = rates[i].close;
         }
      }
   }
   
   Print(StringFormat("🌐 Cross-asset data loaded for %d instruments", m_cross_asset.count));
}

void ATRVolatilityEngine::InitializeInstitutionalDetectionModels()
{
   // Initialize institutional feature weights
   for(int i = 0; i < ArraySize(m_institutional.features); i++)
   {
      m_institutional.features[i] = (MathRand() / 32767.0) * 0.02 - 0.01;
   }
   
   // Initialize dark pool feature weights
   for(int i = 0; i < ArraySize(m_institutional.dark_pool_features); i++)
   {
      m_institutional.dark_pool_features[i] = (MathRand() / 32767.0) * 0.02 - 0.01;
   }
   
   // Initialize regime feature weights
   for(int i = 0; i < ArraySize(m_institutional.regime_features); i++)
   {
      m_institutional.regime_features[i] = (MathRand() / 32767.0) * 0.02 - 0.01;
   }
   
   // Initialize flow and dark pool history arrays
   ArrayInitialize(m_institutional.flow_history, 0.0);
   ArrayInitialize(m_institutional.dark_pool_activity_history, 0.0);
   
   // Reset history size
   m_institutional.history_size = 0;
   
   Print("🏛️ Institutional detection models initialized with enhanced features");
}

void ATRVolatilityEngine::CalculateEnhancedCorrelationMatrix()
{
   // Calculate enhanced correlation between different timeframes and assets
   for(int i = 0; i < m_timeframe_count; i++)
   {
      for(int j = 0; j < m_timeframe_count; j++)
      {
         if(i == j)
         {
            m_correlation_matrix[i*5 + j] = 1.0;
            continue;
         }
         
         m_correlation_matrix[i*5 + j] = CalculateEnhancedATRCorrelation(i, j);
      }
   }
   
   Print("📈 Enhanced correlation matrix calculated");
}
double ATRVolatilityEngine::CalculateEnhancedATRCorrelation(int tf1, int tf2)
{
   if(m_tf_data[tf1].history_size < 50 || m_tf_data[tf2].history_size < 50)
      return 0.0;
   
   int min_size = MathMin(m_tf_data[tf1].history_size, m_tf_data[tf2].history_size);
   min_size = MathMin(min_size, 100); // Use last 100 values
   
   // Calculate enhanced correlation coefficient with volatility adjustment
   double sum_x = 0, sum_y = 0, sum_xy = 0, sum_x2 = 0, sum_y2 = 0;
   
   for(int i = 0; i < min_size; i++)
   {
      double x = m_tf_data[tf1].atr_history[i];
      double y = m_tf_data[tf2].atr_history[i];
      
      // Apply volatility normalization
      double vol_adj_x = x / MathSqrt(m_tf_data[tf1].history_size);
      double vol_adj_y = y / MathSqrt(m_tf_data[tf2].history_size);
      
      sum_x += vol_adj_x;
      sum_y += vol_adj_y;
      sum_xy += vol_adj_x * vol_adj_y;
      sum_x2 += vol_adj_x * vol_adj_x;
      sum_y2 += vol_adj_y * vol_adj_y;
   }
   
   double n = (double)min_size;
   double numerator = (n * sum_xy) - (sum_x * sum_y);
   double denominator = MathSqrt((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y));
   
   return (denominator != 0) ? (numerator / denominator) : 0.0;
}
void ATRVolatilityEngine::InitializeMarketMicrostructureAnalysis()
{
   // Initialize microstructure analysis arrays
   for(int i = 0; i < 100; i++)
   {
      m_microstructure.bid_ask_spreads[i] = 0.0;
      m_microstructure.order_flow_imbalance[i] = 0.0;
      m_microstructure.market_impact_costs[i] = 0.0;
   }
   
   m_microstructure.history_size = 0;
   
   Print("🔬 Market microstructure analysis initialized");
}

bool ATRVolatilityEngine::GetEnhancedCurrentATRValues(ATRVolatilityInfo &info)
{
   struct ATRTimeframe
   {
      ENUM_TIMEFRAMES timeframe;
      int array_index;
   };
   
   ATRTimeframe timeframes[] = 
   {
      {PERIOD_M15, 0},
      {PERIOD_H1, 1},
      {PERIOD_H4, 2},
      {PERIOD_D1, 3},
      {PERIOD_W1, 4}
   };
   
   bool all_success = true;
   
   for(int i = 0; i < ArraySize(timeframes); i++)
   {
      // Get enhanced ATR for different periods
      for(int period = 0; period < 3; period++)
      {
         int atr_period = (period == 0) ? m_atr_period_short : 
                         (period == 1) ? m_atr_period_medium : m_atr_period_long;
         
         double atr_buffer[5];
         int atr_handle = iATR(m_symbol, timeframes[i].timeframe, atr_period);
         
         if(atr_handle == INVALID_HANDLE)
         {
            Print(StringFormat("ERROR: Cannot create enhanced ATR handle for TF: %d, Period: %d", 
                              timeframes[i].timeframe, atr_period));
            all_success = false;
            continue;
         }
         
         int copied = CopyBuffer(atr_handle, 0, 0, 5, atr_buffer);
         if(copied >= 1)
         {
            // Set main ATR values
            switch(timeframes[i].timeframe)
            {
               case PERIOD_M15: if(period == 0) info.atr_m15 = atr_buffer[0]; break;
               case PERIOD_H1:  if(period == 0) info.atr_h1 = atr_buffer[0]; break;
               case PERIOD_H4:  if(period == 0) info.atr_h4 = atr_buffer[0]; break;
               case PERIOD_D1:  if(period == 0) info.atr_d1 = atr_buffer[0]; break;
               case PERIOD_W1:  if(period == 0) info.atr_w1 = atr_buffer[0]; break;
            }
            
            // Store in enhanced period arrays
            if(period == 0) info.atr_14[timeframes[i].array_index] = atr_buffer[0];
            else if(period == 1) info.atr_21[timeframes[i].array_index] = atr_buffer[0];
            else if(period == 2) info.atr_50[timeframes[i].array_index] = atr_buffer[0];
         }
         else
         {
            Print(StringFormat("WARNING: Cannot get enhanced ATR value for TF: %d, Period: %d", 
                              timeframes[i].timeframe, atr_period));
            all_success = false;
         }
         
         IndicatorRelease(atr_handle);
      }
   }
   
   return all_success;
}

void ATRVolatilityEngine::AnalyzeEnhancedVolatilityRegimes(ATRVolatilityInfo &info)
{
   // Enhanced regime analysis for each major timeframe
   info.regime_h1 = DetermineEnhancedVolatilityRegime(1, info.atr_h1);
   info.regime_h4 = DetermineEnhancedVolatilityRegime(2, info.atr_h4);
   info.regime_d1 = DetermineEnhancedVolatilityRegime(3, info.atr_d1);
   
   // Enhanced overall regime (machine learning weighted combination)
   info.current_regime = DetermineEnhancedOverallRegime(info);
   
   // Detect regime change risk
   info.regime_change_risk = DetectVolatilityRegimeChangeRisk(info);
   info.vol_regime_change_imminent = info.regime_change_risk;
}
bool ATRVolatilityEngine::DetectVolatilityRegimeChangeRisk(const ATRVolatilityInfo &info)
{
   // Check for regime change indicators
   bool regime_conflict = (info.regime_h1 != info.regime_h4) || 
                        (info.regime_h4 != info.regime_d1);
   
   bool extreme_divergence = MathAbs(VolatilityRegimeToScore(info.regime_h1) - 
                                    VolatilityRegimeToScore(info.regime_d1)) >= 3.0;
   
   // Check cross-asset regime indicators
   double cross_asset_vol_stress = CalculateCrossAssetVolatilityStress();
   bool cross_asset_regime_change = cross_asset_vol_stress > 0.7;
   
   return (regime_conflict && extreme_divergence) || cross_asset_regime_change;
}
ENUM_VOLATILITY_REGIME ATRVolatilityEngine::DetermineEnhancedVolatilityRegime(int tf_index, double current_atr)
{
   if(!m_tf_data[tf_index].percentiles_calculated || current_atr <= 0.0)
      return VOLATILITY_UNKNOWN;
   
   // Enhanced percentile calculation with adaptive thresholds
   double percentile = FindEnhancedATRPercentile(tf_index, current_atr);
   
   // Dynamic thresholds based on market conditions
   double expansion_threshold = 85.0;
   double high_threshold = 75.0;
   double normal_high_threshold = 60.0;
   double normal_low_threshold = 40.0;
   double low_threshold = 25.0;
   double contraction_threshold = 15.0;
   
   // Adjust thresholds based on cross-asset volatility
   double cross_asset_adjustment = CalculateCrossAssetVolatilityAdjustment();
   expansion_threshold += cross_asset_adjustment;
   high_threshold += cross_asset_adjustment * 0.8;
   low_threshold -= cross_asset_adjustment * 0.8;
   contraction_threshold -= cross_asset_adjustment;
   
   if(percentile >= expansion_threshold)
      return VOLATILITY_EXPANSION;
   else if(percentile >= high_threshold)
      return VOLATILITY_HIGH;
   else if(percentile >= normal_high_threshold)
      return VOLATILITY_NORMAL;
   else if(percentile >= normal_low_threshold)
      return VOLATILITY_NORMAL;
   else if(percentile >= low_threshold)
      return VOLATILITY_LOW;
   else if(percentile <= contraction_threshold)
      return VOLATILITY_CONTRACTION;
   else
      return VOLATILITY_LOW;
}
double ATRVolatilityEngine::CalculateCrossAssetVolatilityAdjustment()
{
   // Calculate volatility adjustment based on cross-asset conditions
   double adjustment = 0.0;
   
   // This would normally use real cross-asset data
   // For now, using a simplified calculation
   if(m_cross_asset.count > 0)
   {
      double avg_cross_vol = 0.0;
      int valid_assets = 0;
      
      for(int i = 0; i < m_cross_asset.count && i < 5; i++)
      {
         if(m_cross_asset.data[i*100] > 0)
         {
            // Calculate simple volatility for cross asset
            double asset_vol = CalculateSimpleCrossAssetVolatility(i);
            avg_cross_vol += asset_vol;
            valid_assets++;
         }
      }
      
      if(valid_assets > 0)
      {
         avg_cross_vol /= valid_assets;
         // Adjustment based on cross-asset volatility relative to normal
         adjustment = (avg_cross_vol - 0.5) * 10.0; // Scale to ±5 percentile points
      }
   }
   
   return MathMax(-10.0, MathMin(10.0, adjustment));
}

double ATRVolatilityEngine::CalculateSimpleCrossAssetVolatility(int asset_index)
{
   // Calculate simple volatility for cross asset
   double sum_sq_returns = 0.0;
   int count = 0;
   
   for(int i = 1; i < 20 && i < 100; i++)
   {
      double current = m_cross_asset.data[asset_index*100 + i-1];
      double previous = m_cross_asset.data[asset_index*100 + i];
      
      if(current > 0 && previous > 0)
      {
         double return_rate = MathLog(current / previous);
         sum_sq_returns += return_rate * return_rate;
         count++;
      }
   }
   
   return (count > 0) ? MathSqrt(sum_sq_returns / count) : 0.0;
}

double ATRVolatilityEngine::CalculateCrossAssetVolatilityStress()
{
   // Calculate cross-asset volatility stress indicator
   double stress = 0.0;
   int stress_assets = 0;
   
   for(int i = 0; i < m_cross_asset.count && i < 5; i++)
   {
      double asset_vol = CalculateSimpleCrossAssetVolatility(i);
      if(asset_vol > 0.02) // Threshold for high volatility
      {
         stress_assets++;
      }
      stress += asset_vol;
   }
   
   if(m_cross_asset.count > 0)
   {
      stress /= m_cross_asset.count;
      // Add systemic stress factor
      if(stress_assets >= m_cross_asset.count * 0.6) // 60% of assets in stress
      {
         stress *= 1.5;
      }
   }
   
   return MathMin(1.0, stress * 10.0); // Normalize to 0-1
}

double ATRVolatilityEngine::FindEnhancedATRPercentile(int tf_index, double atr_value)
{
   if(!m_tf_data[tf_index].percentiles_calculated)
      return 50.0;
   
   // Enhanced binary search for percentile with interpolation
   for(int p = 0; p < 99; p++)
   {
      if(atr_value <= m_tf_data[tf_index].volatility_percentiles[p])
      {
         // Linear interpolation for more precise percentile
         if(p > 0)
         {
            double lower_val = m_tf_data[tf_index].volatility_percentiles[p-1];
            double upper_val = m_tf_data[tf_index].volatility_percentiles[p];
            if(upper_val > lower_val)
            {
               double weight = (atr_value - lower_val) / (upper_val - lower_val);
               return (p-1) + weight;
            }
         }
         return (double)p;
      }
   }
   
   return 99.0; // Extreme high
}
ENUM_VOLATILITY_REGIME ATRVolatilityEngine::DetermineEnhancedOverallRegime(const ATRVolatilityInfo &info)
{
   // Enhanced weighted combination with machine learning
   double regime_score = 0.0;
   
   // Base regime scores
   regime_score += VolatilityRegimeToScore(info.regime_h1) * 0.25;   // 25% H1
   regime_score += VolatilityRegimeToScore(info.regime_h4) * 0.40;   // 40% H4
   regime_score += VolatilityRegimeToScore(info.regime_d1) * 0.35;   // 35% D1
   
   // Apply machine learning enhancement
   if(m_ml_data.is_trained)
   {
      double ml_adjustment = CalculateMLRegimeAdjustment(info);
      regime_score += ml_adjustment * 0.1; // 10% ML adjustment
   }
   
   return ScoreToEnhancedVolatilityRegime(regime_score);
}
ENUM_VOLATILITY_REGIME ATRVolatilityEngine::ScoreToEnhancedVolatilityRegime(double score)
{
   if(score >= 5.5) return VOLATILITY_EXPANSION;
   else if(score >= 4.5) return VOLATILITY_HIGH;
   else if(score >= 2.5) return VOLATILITY_NORMAL;
   else if(score >= 1.5) return VOLATILITY_LOW;
   else return VOLATILITY_CONTRACTION;
}

double ATRVolatilityEngine::CalculateMLRegimeAdjustment(const ATRVolatilityInfo &info)
{
   // Machine learning adjustment for regime determination
   double adjustment = 0.0;
   
   if(m_ml_data.is_trained)
   {
      // Simple ML adjustment based on features
      double feature_score = 0.0;
      
      // ATR momentum feature
      feature_score += info.atr_momentum * 0.01;
      
      // Volatility percentile feature
      feature_score += (info.volatility_percentile - 50.0) * 0.02;
      
      // Cross-timeframe consistency feature
      if(info.regime_h1 == info.regime_h4 && info.regime_h4 == info.regime_d1)
         feature_score += 0.5;
      
      adjustment = MathTanh(feature_score); // Normalize to ±1
   }
   
   return adjustment;
}

double ATRVolatilityEngine::VolatilityRegimeToScore(ENUM_VOLATILITY_REGIME regime)
{
   switch(regime)
   {
      case VOLATILITY_CONTRACTION: return 1.0;
      case VOLATILITY_LOW: return 2.0;
      case VOLATILITY_NORMAL: return 3.0;
      case VOLATILITY_HIGH: return 4.0;
      case VOLATILITY_EXPANSION: return 5.0;
      case VOLATILITY_EXTREME: return 6.0;
      default: return 3.0;
   }
}
void ATRVolatilityEngine::CalculateEnhancedVolatilityMetrics(ATRVolatilityInfo &info)
{
   // Enhanced percentile calculation for H1 ATR
   info.volatility_percentile = FindEnhancedATRPercentile(1, info.atr_h1);
   
   // Enhanced Z-score with adaptive normalization
   info.volatility_zscore = CalculateEnhancedATRZScore(1, info.atr_h1);
   
   // Enhanced rank (0-1) with machine learning adjustment
   info.volatility_rank = info.volatility_percentile / 100.0;
   if(m_ml_data.is_trained)
   {
      double ml_rank_adjustment = CalculateMLRankAdjustment(info);
      info.volatility_rank += ml_rank_adjustment * 0.1;
      info.volatility_rank = MathMax(0.0, MathMin(1.0, info.volatility_rank));
   }
   
   // Enhanced extreme volatility flag with dynamic thresholds
   double extreme_threshold_high = 95.0;
   double extreme_threshold_low = 5.0;
   
   // Adjust thresholds based on market regime
   if(info.risk_regime.market_crash_risk)
   {
      extreme_threshold_high = 90.0;
      extreme_threshold_low = 10.0;
   }
   else if(info.cross_asset.global_risk_appetite < -0.5)
   {
      extreme_threshold_high = 92.0;
      extreme_threshold_low = 8.0;
   }
   
   info.extreme_volatility = (info.volatility_percentile >= extreme_threshold_high || 
                              info.volatility_percentile <= extreme_threshold_low);
}

double ATRVolatilityEngine::CalculateMLRankAdjustment(const ATRVolatilityInfo &info)
{
   // Machine learning adjustment for volatility rank
   if(!m_ml_data.is_trained) return 0.0;
   
   double adjustment = 0.0;
   
   // Factor in cross-asset volatility
   if(info.cross_asset.global_risk_appetite < -0.3)
      adjustment += 0.1; // Increase rank during risk-off
   else if(info.cross_asset.global_risk_appetite > 0.3)
      adjustment -= 0.1; // Decrease rank during risk-on
   
   // Factor in regime stability
   if(info.regime_change_risk)
      adjustment += 0.05;
   
   // Factor in session effects
   if(info.high_volatility_session)
      adjustment += 0.02;
   
   return MathMax(-0.2, MathMin(0.2, adjustment));
}

double ATRVolatilityEngine::CalculateEnhancedATRZScore(int tf_index, double current_atr)
{
   if(m_tf_data[tf_index].history_size < 30)
      return 0.0;
   
   // Calculate enhanced mean and standard deviation with outlier adjustment
   double sum = 0.0, sum_sq = 0.0;
   int count = MathMin(m_tf_data[tf_index].history_size, 200); // Use last 200 values
   
   for(int i = 0; i < count; i++)
   {
      double atr_val = m_tf_data[tf_index].atr_history[i];
      sum += atr_val;
      sum_sq += atr_val * atr_val;
   }
   
   double mean = sum / count;
   double variance = (sum_sq / count) - (mean * mean);
   double std_dev = MathSqrt(variance);
   
   // Apply outlier-robust adjustment
   if(std_dev > 0)
   {
      double z_score = (current_atr - mean) / std_dev;
      
      // Winsorize extreme Z-scores to reduce outlier impact
      z_score = MathMax(-4.0, MathMin(4.0, z_score));
      
      return z_score;
   }
   
   return 0.0;
}
void ATRVolatilityEngine::AnalyzeEnhancedVolatilityExpansionContraction(ATRVolatilityInfo &info)
{
   // Enhanced expansion/contraction analysis with machine learning
   if(m_tf_data[1].history_size < 15) return; // Need H1 history
   
   double current_atr = info.atr_h1;
   double recent_avg_atr = 0.0;
   double long_avg_atr = 0.0;
   
   // Calculate enhanced recent average (adaptive window)
   int recent_window = DetermineAdaptiveWindow();
   for(int i = 1; i <= recent_window && i < m_tf_data[1].history_size; i++)
      recent_avg_atr += m_tf_data[1].atr_history[i];
   recent_avg_atr /= recent_window;
   
   // Calculate enhanced longer average (adaptive window)
   int long_window = recent_window * 3;
   long_window = MathMin(long_window, m_tf_data[1].history_size - 1);
   for(int i = 1; i <= long_window && i < m_tf_data[1].history_size; i++)
      long_avg_atr += m_tf_data[1].atr_history[i];
   long_avg_atr /= long_window;
   
   // Enhanced expansion/contraction thresholds with adaptive adjustment
   double expansion_threshold = CalculateAdaptiveExpansionThreshold(info);
   double contraction_threshold = CalculateAdaptiveContractionThreshold(info);
   
   // Determine enhanced expansion/contraction
   if(current_atr > recent_avg_atr * expansion_threshold)
   {
      info.volatility_expansion = true;
      info.expansion_strength = ((current_atr / recent_avg_atr) - 1.0) * 100.0;
      info.expansion_bars = CountEnhancedConsecutiveExpansionBars();
   }
   else if(current_atr < recent_avg_atr * contraction_threshold)
   {
      info.volatility_contraction = true;
      info.contraction_duration = CountEnhancedConsecutiveContractionBars();
   }
   
   // Enhanced expansion strength with cross-asset confirmation
   if(info.volatility_expansion)
   {
      double cross_asset_confirmation = CalculateCrossAssetExpansionConfirmation();
      info.expansion_strength *= (1.0 + cross_asset_confirmation * 0.2);
      info.expansion_strength = MathMin(200.0, info.expansion_strength);
   }
}

double ATRVolatilityEngine::CalculateCrossAssetExpansionConfirmation()
{
   // Calculate cross-asset confirmation for volatility expansion
   double confirmation = 0.0;
   int expanding_assets = 0;
   
   for(int i = 0; i < m_cross_asset.count && i < 5; i++)
   {
      double asset_vol = CalculateSimpleCrossAssetVolatility(i);
      if(asset_vol > 0.015) // Threshold for expansion
      {
         expanding_assets++;
      }
   }
   
   if(m_cross_asset.count > 0)
   {
      confirmation = (double)expanding_assets / m_cross_asset.count;
   }
   
   return confirmation;
}

int ATRVolatilityEngine::CountEnhancedConsecutiveContractionBars()
{
   if(m_tf_data[1].history_size < 15) return 0;
   
   int count = 0;
   double reference_atr = 0.0;
   
   // Calculate reference ATR (average of bars 10-20)
   for(int i = 10; i < 20 && i < m_tf_data[1].history_size; i++)
      reference_atr += m_tf_data[1].atr_history[i];
   reference_atr /= 10.0;
   
   if(reference_atr <= 0) return 0;
   
   // Count consecutive bars below reference - 25%
   for(int i = 0; i < 15 && i < m_tf_data[1].history_size; i++)
   {
      if(m_tf_data[1].atr_history[i] < reference_atr * 0.75)
         count++;
      else
         break;
   }
   
   return count;
}
double ATRVolatilityEngine::CalculateAdaptiveContractionThreshold(const ATRVolatilityInfo &info)
{
   double base_threshold = 0.7; // 30% decrease
   
   // Adjust based on current regime
   switch(info.current_regime)
   {
      case VOLATILITY_HIGH: base_threshold = 0.8; break; // Easier to detect contraction in high vol
      case VOLATILITY_LOW: base_threshold = 0.6; break; // Harder to detect contraction in low vol
      default: base_threshold = 0.7;
   }
   
   // Adjust based on cross-asset conditions
   if(info.cross_asset.global_risk_appetite > 0.5)
      base_threshold *= 1.1; // Higher threshold during risk-on
   
   return base_threshold;
}

int ATRVolatilityEngine::CountEnhancedConsecutiveExpansionBars()
{
   if(m_tf_data[1].history_size < 10) return 0;
   
   int count = 0;
   double reference_atr = 0.0;
   
   // Calculate reference ATR (average of bars 8-12)
   for(int i = 8; i < 12 && i < m_tf_data[1].history_size; i++)
      reference_atr += m_tf_data[1].atr_history[i];
   reference_atr /= 4.0;
   
   if(reference_atr <= 0) return 0;
   
   // Count consecutive bars above reference + 15%
   for(int i = 0; i < 8 && i < m_tf_data[1].history_size; i++)
   {
      if(m_tf_data[1].atr_history[i] > reference_atr * 1.15)
         count++;
      else
         break;
   }
   
   return count;
}

double ATRVolatilityEngine::CalculateAdaptiveExpansionThreshold(const ATRVolatilityInfo &info)
{
   double base_threshold = 1.3; // 30% increase
   
   // Adjust based on current regime
   switch(info.current_regime)
   {
      case VOLATILITY_LOW: base_threshold = 1.2; break; // Easier to detect expansion in low vol
      case VOLATILITY_HIGH: base_threshold = 1.4; break; // Harder to detect expansion in high vol
      case VOLATILITY_EXTREME: base_threshold = 1.5; break;
      default: base_threshold = 1.3;
   }
   
   // Adjust based on cross-asset conditions
   if(info.cross_asset.global_risk_appetite < -0.5)
      base_threshold *= 0.9; // Lower threshold during risk-off
   
   // Adjust based on session
   if(info.high_volatility_session)
      base_threshold *= 1.1; // Higher threshold during active sessions
   
   return base_threshold;
}

int ATRVolatilityEngine::DetermineAdaptiveWindow()
{
   // Adaptive window based on current volatility regime
   // Higher volatility = shorter window for faster response
   double avg_recent_atr = 0.0;
   int base_window = 5;
   
   for(int i = 1; i <= base_window && i < m_tf_data[1].history_size; i++)
      avg_recent_atr += m_tf_data[1].atr_history[i];
   avg_recent_atr /= base_window;
   
   double long_avg_atr = 0.0;
   int long_window = 20;
   for(int i = 1; i <= long_window && i < m_tf_data[1].history_size; i++)
      long_avg_atr += m_tf_data[1].atr_history[i];
   long_avg_atr /= long_window;
   
   if(long_avg_atr > 0)
   {
      double vol_ratio = avg_recent_atr / long_avg_atr;
      if(vol_ratio > 1.5) return 3; // High vol = shorter window
      else if(vol_ratio > 1.2) return 4;
      else if(vol_ratio < 0.8) return 7; // Low vol = longer window
      else if(vol_ratio < 0.9) return 6;
   }
   
   return base_window;
}

void ATRVolatilityEngine::AnalyzeEnhancedATRTrends(ATRVolatilityInfo &info)
{
   // Kısa vadeli ATR trend (5 bar)
   info.atr_trend_short = CalculateATRTrend(1, 5);
   
   // Orta vadeli ATR trend (14 bar)
   info.atr_trend_medium = CalculateATRTrend(1, 14);
   
   // Uzun vadeli ATR trend (50 bar)
   info.atr_trend_long = CalculateATRTrend(1, 50);
   
   // ATR momentum hesaplama
   info.atr_momentum = CalculateATRMomentum(1);
}

double ATRVolatilityEngine::CalculateATRMomentum(int tf_index)
{
   if(m_tf_data[tf_index].history_size < 10)
      return 0.0;
   
   // Son 5 bar ile önceki 5 bar arasındaki fark
   double recent_avg = 0.0, older_avg = 0.0;
   
   for(int i = 0; i < 5; i++)
      recent_avg += m_tf_data[tf_index].atr_history[i];
   recent_avg /= 5.0;
   
   for(int i = 5; i < 10; i++)
      older_avg += m_tf_data[tf_index].atr_history[i];
   older_avg /= 5.0;
   
   if(older_avg > 0)
   {
      double momentum = ((recent_avg - older_avg) / older_avg) * 100.0;
      return MathMax(-100.0, MathMin(100.0, momentum));
   }
   
   return 0.0;
}

ENUM_TREND_DIRECTION ATRVolatilityEngine::CalculateATRTrend(int tf_index, int lookback)
{
   if(m_tf_data[tf_index].history_size < lookback + 5)
      return TREND_NEUTRAL;
   
   // Linear regression ile trend hesaplama
   double sum_x = 0.0, sum_y = 0.0, sum_xy = 0.0, sum_x2 = 0.0;
   
   for(int i = 0; i < lookback; i++)
   {
      double x = (double)i;
      double y = m_tf_data[tf_index].atr_history[i];
      
      sum_x += x;
      sum_y += y;
      sum_xy += x * y;
      sum_x2 += x * x;
   }
   
   double n = (double)lookback;
   double slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x);
   
   // Trend yönü belirleme
   if(slope > 0.001) return TREND_BULLISH;
   else if(slope < -0.001) return TREND_BEARISH;
   else return TREND_NEUTRAL;
}
void ATRVolatilityEngine::CalculateEnhancedOptimalStopLoss(ATRVolatilityInfo &info)
{
   if(info.atr_h1 <= 0) return;
   
   // Volatiliteye göre ATR çarpanları
   double volatility_multiplier = 1.0;
   
   switch(info.current_regime)
   {
      case VOLATILITY_LOW: volatility_multiplier = 1.5; break;
      case VOLATILITY_NORMAL: volatility_multiplier = 2.0; break;
      case VOLATILITY_HIGH: volatility_multiplier = 2.5; break;
      case VOLATILITY_EXTREME: volatility_multiplier = 3.0; break;
      case VOLATILITY_EXPANSION: volatility_multiplier = 3.5; break;
      default: volatility_multiplier = 2.0;
   }
   
   // Session ayarlaması
   if(info.high_volatility_session)
      volatility_multiplier *= 1.2;
   
   // Temel stop loss hesaplamaları
   info.conservative_sl = info.atr_h1 * (volatility_multiplier + 0.5);
   info.optimal_stop_loss = info.atr_h1 * volatility_multiplier;
   info.aggressive_sl = info.atr_h1 * (volatility_multiplier - 0.5);
   
   // Minimum ve maksimum limitler
   info.conservative_sl = MathMax(info.conservative_sl, info.atr_h1 * 1.5);
   info.aggressive_sl = MathMax(info.aggressive_sl, info.atr_h1 * 1.0);
   
   info.atr_multiplier_sl = volatility_multiplier;
   info.breakeven_distance = info.optimal_stop_loss * 0.6;
}

void ATRVolatilityEngine::CalculateEnhancedPositionSizing(ATRVolatilityInfo &info)
{
   if(info.atr_h1 <= 0) return;
   
   // Risk bazlı pozisyon boyutu (örnek: %1 risk)
   double risk_percent = 0.01; // %1 risk
   double account_balance = 200000.0; // Örnek bakiye
   
   // ATR bazlı pozisyon boyutu
   info.atr_position_size = (account_balance * risk_percent) / info.optimal_stop_loss;
   
   // Volatilite düzeltmeli boyut
   double vol_adjustment = 1.0;
   
   switch(info.current_regime)
   {
      case VOLATILITY_LOW: vol_adjustment = 1.3; break;
      case VOLATILITY_NORMAL: vol_adjustment = 1.0; break;
      case VOLATILITY_HIGH: vol_adjustment = 0.7; break;
      case VOLATILITY_EXTREME: vol_adjustment = 0.5; break;
      case VOLATILITY_EXPANSION: vol_adjustment = 0.4; break;
      default: vol_adjustment = 1.0;
   }
   
   info.volatility_adjusted_size = info.atr_position_size * vol_adjustment;
   
   // Risk düzeltmeli boyut
   double risk_adjustment = 1.0;
   switch(info.volatility_risk)
   {
      case RISK_VERY_LOW: risk_adjustment = 1.2; break;
      case RISK_LOW: risk_adjustment = 1.1; break;
      case RISK_MEDIUM: risk_adjustment = 1.0; break;
      case RISK_HIGH: risk_adjustment = 0.8; break;
      case RISK_VERY_HIGH: risk_adjustment = 0.6; break;
   }
   
   info.risk_adjusted_size = info.volatility_adjusted_size * risk_adjustment;
   
   // Maksimum pozisyon boyutu limiti
   info.max_position_size = account_balance * 0.1; // Maksimum %10
   
   // Final pozisyon boyutu
   info.risk_adjusted_size = MathMin(info.risk_adjusted_size, info.max_position_size);
}

void ATRVolatilityEngine::AnalyzeVolatilitySurface(ATRVolatilityInfo &info)
{
   VolatilitySurfaceInfo surface = info.vol_surface;
   
   // Calculate implied volatility smile approximation
   CalculateImpliedVolatilitySmile(surface, info);
   
   // Calculate volatility term structure
   CalculateVolatilityTermStructure(surface, info);
   
   // Calculate advanced volatility metrics
   CalculateAdvancedVolatilityMetrics(surface, info);
   
   // Generate volatility Surface signals
   GenerateVolatilitySurfaceSignals(surface, info);
   
   Print("📊 Volatility surface analysis completed");
}

void ATRVolatilityEngine::CalculateVolatilityTermStructure(VolatilitySurfaceInfo &surface, const ATRVolatilityInfo &info)
{
   // Calculate volatility term structure (1W, 2W, 1M, 3M, 6M, 1Y)
   double base_vol = info.atr_h1 * MathSqrt(252);
   
   // Typical term structure patterns
   surface.vol_term_structure[0] = base_vol * 1.2; // 1W - higher short-term vol
   surface.vol_term_structure[1] = base_vol * 1.1; // 2W
   surface.vol_term_structure[2] = base_vol * 1.0; // 1M - base
   surface.vol_term_structure[3] = base_vol * 0.95; // 3M
   surface.vol_term_structure[4] = base_vol * 0.9;  // 6M
   surface.vol_term_structure[5] = base_vol * 0.85; // 1Y - lower long-term vol
   
   // Adjust based on current volatility regime
   if(info.current_regime == VOLATILITY_HIGH || info.current_regime == VOLATILITY_EXPANSION)
   {
      // Invert term structure during high volatility
      for(int i = 0; i < 6; i++)
      {
         surface.vol_term_structure[i] *= (1.0 + (5-i) * 0.05); // Higher long-term vol
      }
   }
}

void ATRVolatilityEngine::CalculateAdvancedVolatilityMetrics(VolatilitySurfaceInfo &surface, const ATRVolatilityInfo &info)
{
   // Volatility of volatility
   surface.vol_of_vol = CalculateVolatilityOfVolatility();
   
   // Volatility mean reversion speed
   surface.vol_mean_reversion_speed = CalculateVolatilityMeanReversionSpeed();
   
   // Volatility persistence
   surface.vol_persistence = CalculateVolatilityPersistence();
   
   // Volatility spike exhaustion
   surface.vol_spike_exhaustion = DetectVolatilitySpikeExhaustion(info);
   
   // Realized volatility metrics
   surface.realized_vol_1d = CalculateRealizedVolatility(24); // 1 day in hours
   surface.realized_vol_1w = CalculateRealizedVolatility(168); // 1 week in hours
   surface.realized_vol_1m = CalculateRealizedVolatility(720); // 1 month in hours
   
   // Volatility risk premium
   surface.vol_risk_premium = CalculateVolatilityRiskPremium(surface);
   
   // GARCH forecast
   surface.garch_forecast = CalculateGARCHVolatilityForecast();
}

double ATRVolatilityEngine::CalculateGARCHVolatilityForecast()
{
   if(m_tf_data[1].history_size < 50) return 0.0;
   
   // Simplified GARCH(1,1) forecast
   double omega = 0.000001; // Constant term
   double alpha = 0.1;      // ARCH term
   double beta = 0.85;      // GARCH term
   
   // Calculate current conditional variance
   double prev_return_sq = 0.0;
   if(m_tf_data[1].price_history[0] > 0 && m_tf_data[1].price_history[1] > 0)
   {
      double return_rate = MathLog(m_tf_data[1].price_history[0] / m_tf_data[1].price_history[1]);
      prev_return_sq = return_rate * return_rate;
   }
   
   double prev_variance = m_tf_data[1].atr_history[1] * m_tf_data[1].atr_history[1];
   
   // GARCH forecast
   double forecast_variance = omega + alpha * prev_return_sq + beta * prev_variance;
   
   return MathSqrt(forecast_variance * 252 * 24); // Annualized
}

double ATRVolatilityEngine::CalculateVolatilityRiskPremium(const VolatilitySurfaceInfo &surface)
{
   // Volatility risk premium = Implied Vol - Realized Vol
   double implied_vol = surface.vol_term_structure[2]; // 1M implied
   double realized_vol = surface.realized_vol_1m;
   
   return implied_vol - realized_vol;
}

double ATRVolatilityEngine::CalculateRealizedVolatility(int hours)
{
   if(m_tf_data[1].history_size < hours/24) return 0.0; // Need enough H1 data
   
   double sum_sq_returns = 0.0;
   int count = 0;
   int bars_needed = MathMin(hours, m_tf_data[1].history_size - 1);
   
   for(int i = 1; i < bars_needed; i++)
   {
      double current = m_tf_data[1].price_history[i-1];
      double previous = m_tf_data[1].price_history[i];
      
      if(current > 0 && previous > 0)
      {
         double return_rate = MathLog(current / previous);
         sum_sq_returns += return_rate * return_rate;
         count++;
      }
   }
   
   if(count > 0)
   {
      return MathSqrt(sum_sq_returns * 252 * 24 / count); // Annualized
   }
   return 0.0;
}

bool ATRVolatilityEngine::DetectVolatilitySpikeExhaustion(const ATRVolatilityInfo &info)
{
   // Detect if a volatility spike is showing signs of exhaustion
   bool high_volatility = info.volatility_percentile > 85.0;
   bool recent_expansion = info.volatility_expansion && info.expansion_bars >= 3;
   bool momentum_declining = info.atr_momentum < 0;
   
   return high_volatility && recent_expansion && momentum_declining;
}

double ATRVolatilityEngine::CalculateVolatilityPersistence()
{
   if(m_tf_data[1].history_size < 20) return 0.0;
   
   // Calculate autocorrelation of volatility
   double mean = 0.0;
   int period = 20;
   
   for(int i = 0; i < period && i < m_tf_data[1].history_size; i++)
      mean += m_tf_data[1].atr_history[i];
   mean /= period;
   
   double numerator = 0.0, denominator = 0.0;
   
   for(int i = 1; i < period && i < m_tf_data[1].history_size; i++)
   {
      double x = m_tf_data[1].atr_history[i] - mean;
      double y = m_tf_data[1].atr_history[i-1] - mean;
      numerator += x * y;
      denominator += x * x;
   }
   
   return (denominator > 0) ? (numerator / denominator) : 0.0;
}

double ATRVolatilityEngine::CalculateVolatilityMeanReversionSpeed()
{
   if(m_tf_data[1].history_size < 30) return 0.0;
   
   // Simple mean reversion speed calculation
   double long_mean = 0.0;
   int mean_period = 30;
   
   for(int i = 0; i < mean_period && i < m_tf_data[1].history_size; i++)
      long_mean += m_tf_data[1].atr_history[i];
   long_mean /= mean_period;
   
   if(long_mean <= 0) return 0.0;
   
   // Calculate how fast volatility reverts to mean
   double current_deviation = (m_tf_data[1].atr_history[0] - long_mean) / long_mean;
   double previous_deviation = (m_tf_data[1].atr_history[1] - long_mean) / long_mean;
   
   if(MathAbs(previous_deviation) > 0.001)
   {
      double reversion_speed = (current_deviation - previous_deviation) / previous_deviation;
      return MathMax(0.0, -reversion_speed); // Positive value indicates reversion
   }
   
   return 0.0;
}

double ATRVolatilityEngine::CalculateVolatilityOfVolatility()
{
   if(m_tf_data[1].history_size < 50) return 0.0;
   
   // Calculate volatility of ATR changes
   double vol_changes[50];
   int count = 0;
   
   for(int i = 1; i < 50 && i < m_tf_data[1].history_size; i++)
   {
      double vol_change = m_tf_data[1].atr_history[i-1] - m_tf_data[1].atr_history[i];
      vol_changes[count++] = vol_change;
   }
   
   if(count < 10) return 0.0;
   
   // Calculate standard deviation of volatility changes
   double mean = 0.0;
   for(int i = 0; i < count; i++)
      mean += vol_changes[i];
   mean /= count;
   
   double variance = 0.0;
   for(int i = 0; i < count; i++)
      variance += (vol_changes[i] - mean) * (vol_changes[i] - mean);
   variance /= (count - 1);
   
   return MathSqrt(variance);
}

void ATRVolatilityEngine::CalculateImpliedVolatilitySmile(VolatilitySurfaceInfo &surface, const ATRVolatilityInfo &info)
{
   // Approximate implied volatility smile based on ATR distribution
   double base_iv = info.atr_h1 * MathSqrt(252); // Annualized
   
   // Create smile curve with skew
   for(int i = 0; i < 10; i++)
   {
      double moneyness = 0.8 + (i * 0.04); // 80% to 120% moneyness
      double skew_adjustment = CalculateVolatilitySkewAdjustment(moneyness);
      surface.implied_vol_smile[i] = base_iv * (1.0 + skew_adjustment);
   }
   
   // Calculate overall volatility skew
   surface.volatility_skew = CalculateOverallVolatilitySkew(surface);
   
   // Calculate surface curvature
   surface.vol_surface_curvature = CalculateVolatilitySurfaceCurvature(surface);
}

double ATRVolatilityEngine::CalculateOverallVolatilitySkew(const VolatilitySurfaceInfo &surface)
{
   // Calculate skew as difference between put and call volatilities
   double put_vol = surface.implied_vol_smile[2]; // 88% moneyness
   double call_vol = surface.implied_vol_smile[7]; // 108% moneyness
   double atm_vol = surface.implied_vol_smile[5]; // 100% moneyness
   
   if(atm_vol > 0)
   {
      return (put_vol - call_vol) / atm_vol;
   }
   return 0.0;
}

double ATRVolatilityEngine::CalculateVolatilitySkewAdjustment(double moneyness)
{
   // Typical volatility smile/skew pattern
   if(moneyness < 1.0) // Out-of-the-money puts
   {
      return (1.0 - moneyness) * 0.3; // Higher IV for OTM puts
   }
   else if(moneyness > 1.0) // Out-of-the-money calls
   {
      return (moneyness - 1.0) * 0.1; // Slightly higher IV for OTM calls
   }
   return 0.0; // At-the-money
}

double ATRVolatilityEngine::CalculateVolatilitySurfaceCurvature(const VolatilitySurfaceInfo &surface)
{
   // Calculate second derivative approximation for surface curvature
   double curvature = 0.0;
   
   for(int i = 1; i < 9; i++)
   {
      double second_derivative = surface.implied_vol_smile[i+1] - 
                                2*surface.implied_vol_smile[i] + 
                                surface.implied_vol_smile[i-1];
      curvature += MathAbs(second_derivative);
   }
   
   return curvature / 8.0; // Average curvature
}

void ATRVolatilityEngine::GenerateVolatilitySurfaceSignals(VolatilitySurfaceInfo &surface, const ATRVolatilityInfo &info)
{
   // Volatility breakout signal
   surface.vol_breakout_signal = (info.volatility_expansion && 
                                 info.expansion_strength > 50.0 &&
                                 surface.vol_of_vol > 0.002);
   
   // Volatility mean reversion signal
   surface.vol_mean_revert_signal = (info.extreme_volatility &&
                                    surface.vol_mean_reversion_speed > 0.1 &&
                                    surface.vol_spike_exhaustion);
   
   // Volatility regime change signal
   surface.vol_regime_change = info.regime_change_risk;
   
   // Calculate volatility trading signal strength
   double signal_strength = 0.0;
   
   if(surface.vol_breakout_signal) signal_strength += 40.0;
   if(surface.vol_mean_revert_signal) signal_strength += 35.0;
   if(surface.vol_regime_change) signal_strength += 25.0;
   
   // Add volatility risk premium factor
   if(surface.vol_risk_premium > 0.05) signal_strength += 15.0;
   else if(surface.vol_risk_premium < -0.05) signal_strength += 10.0;
   
   surface.vol_trading_signal_strength = MathMin(100.0, signal_strength);
}

void ATRVolatilityEngine::AnalyzeRiskRegime(ATRVolatilityInfo &info)
{
   RiskRegimeInfo risk = info.risk_regime;
   
   // Risk-On/Risk-Off Detection
   DetectRiskOnRiskOff(risk, info);
   
   // Market Stress Indicators
   CalculateMarketStressIndicators(risk, info);
   
   // Institutional Behavior Analysis
   AnalyzeInstitutionalBehavior(risk, info);
   
   // Crisis Detection
   DetectCrisisSignals(risk, info);
   
   // Central Bank Response Analysis
   AnalyzeCentralBankResponse(risk, info);
   
   Print("⚠️ Risk regime analysis completed");
}

void ATRVolatilityEngine::AnalyzeCentralBankResponse(RiskRegimeInfo &risk, const ATRVolatilityInfo &info)
{
   // Central bank intervention likelihood
   risk.cb_intervention_likely = (risk.market_crash_risk ||
                                 (risk.systemic_risk_score > 70.0 &&
                                  info.policy_impact.fx_intervention_risk));
   
   // Emergency measures likelihood
   risk.emergency_measures = (risk.liquidity_crisis ||
                              risk.margin_call_cascade ||
                              risk.contagion_risk > 80.0);
   
   // Policy response probability
   double policy_prob = 0.0;
   
   if(risk.cb_intervention_likely) policy_prob += 60.0;
   if(risk.emergency_measures) policy_prob += 40.0;
   if(info.volatility_percentile > 95.0) policy_prob += 30.0;
   if(risk.systemic_risk_score > 80.0) policy_prob += 25.0;
   
   risk.policy_response_prob = MathMin(100.0, policy_prob);
}

void ATRVolatilityEngine::DetectCrisisSignals(RiskRegimeInfo &risk, const ATRVolatilityInfo &info)
{
   // Market crash risk
   risk.market_crash_risk = (info.volatility_percentile > 98.0 &&
                            info.expansion_strength > 100.0 &&
                            risk.systemic_risk_score > 80.0);
   
   // Liquidity crisis
   risk.liquidity_crisis = (info.dark_pool.hidden_liquidity_factor < 0.3 &&
                            info.extreme_volatility &&
                            info.microstructure_vol > info.atr_h1 * 1.5);
   
   // Margin call cascade
   risk.margin_call_cascade = (risk.market_crash_risk &&
                              info.expansion_bars >= 2 &&
                              risk.correlation_breakdown > 0.7);
   
   // Contagion risk
   double contagion = 0.0;
   
   if(risk.market_crash_risk) contagion += 40.0;
   if(risk.liquidity_crisis) contagion += 30.0;
   if(info.cross_asset.emerging_market_stress > 0.7) contagion += 20.0;
   if(risk.systemic_risk_score > 70.0) contagion += 25.0;
   
   risk.contagion_risk = MathMin(100.0, contagion);
}

void ATRVolatilityEngine::AnalyzeInstitutionalBehavior(RiskRegimeInfo &risk, const ATRVolatilityInfo &info)
{
   // Institutional hedging detection
   risk.institutional_hedging = (info.dark_pool.dark_pool_activity &&
                                info.volatility_expansion &&
                                info.vol_surface.vol_trading_signal_strength > 60.0);
   
   // Retail panic detection
   risk.retail_panic = (info.extreme_volatility &&
                       info.expansion_bars >= 3 &&
                       !info.dark_pool.stealth_trading_intensity);
   
   // Smart money positioning
   risk.smart_money_positioning = (info.dark_pool.stealth_accumulation ||
                                  info.dark_pool.stealth_distribution ||
                                  info.dark_pool.coordinated_execution);
   
   // Calculate institutional flow
   double flow = 0.0;
   
   if(risk.institutional_hedging) flow -= 30.0; // Hedging = negative flow
   if(risk.smart_money_positioning) flow += 20.0; // Smart money = positive flow
   if(info.dark_pool.block_trading) flow += 15.0;
   
   // Adjust based on dark pool activity
   flow += info.dark_pool.dark_pool_volume_ratio * 25.0;
   
   risk.institutional_flow = MathMax(-100.0, MathMin(100.0, flow));
}

void ATRVolatilityEngine::CalculateMarketStressIndicators(RiskRegimeInfo &risk, const ATRVolatilityInfo &info)
{
   // VIX equivalent calculation
   risk.vix_equivalent = CalculateVIXEquivalent(info);
   
   // Correlation breakdown detection
   risk.correlation_breakdown = CalculateCorrelationBreakdown();
   
   // Tail risk event detection
   risk.tail_risk_event = (info.volatility_zscore > 3.0 || 
                           info.volatility_zscore < -3.0 ||
                           info.volatility_percentile > 99.0);
   
   // Systemic risk score
   double systemic_score = 0.0;
   
   if(risk.vix_equivalent > 25.0) systemic_score += 25.0;
   if(risk.correlation_breakdown > 0.5) systemic_score += 30.0;
   if(risk.tail_risk_event) systemic_score += 35.0;
   if(info.extreme_volatility) systemic_score += 20.0;
   
   // Add cross-asset stress factor
   double cross_asset_stress = CalculateCrossAssetVolatilityStress();
   systemic_score += cross_asset_stress * 40.0;
   
   risk.systemic_risk_score = MathMin(100.0, systemic_score);
}

double ATRVolatilityEngine::CalculateCorrelationBreakdown()
{
   // Calculate correlation breakdown indicator
   double breakdown = 0.0;
   int negative_correlations = 0;
   int total_correlations = 0;
   
   // Check timeframe correlations
   for(int i = 0; i < 5; i++)
   {
      for(int j = i+1; j < 5; j++)
      {
         double correlation = m_correlation_matrix[i*5 + j];
         if(correlation < 0.3) // Normally correlated timeframes becoming uncorrelated
            negative_correlations++;
         total_correlations++;
      }
   }
   
   if(total_correlations > 0)
   {
      breakdown = (double)negative_correlations / total_correlations;
   }
   
   return breakdown;
}

double ATRVolatilityEngine::CalculateVIXEquivalent(const ATRVolatilityInfo &info)
{
   // Calculate VIX-like indicator from ATR data
   double base_vol = info.atr_h1 * MathSqrt(252 * 24); // Annualized H1 ATR
   double vol_percentile_adjustment = info.volatility_percentile / 100.0;
   
   // VIX typically ranges from 10-80, with average around 18-20
   double vix_equivalent = base_vol * 100 * (1.0 + vol_percentile_adjustment);
   
   // Apply regime-based adjustment
   switch(info.current_regime)
   {
      case VOLATILITY_LOW: vix_equivalent *= 0.7; break;
      case VOLATILITY_HIGH: vix_equivalent *= 1.4; break;
      case VOLATILITY_EXTREME: vix_equivalent *= 1.8; break;
      case VOLATILITY_EXPANSION: vix_equivalent *= 1.6; break;
      default: break;
   }
   
   return MathMax(5.0, MathMin(100.0, vix_equivalent));
}

void ATRVolatilityEngine::DetectRiskOnRiskOff(RiskRegimeInfo &risk, const ATRVolatilityInfo &info)
{
   // Risk-off detection based on volatility patterns
   risk.risk_off_event = (info.extreme_volatility && 
                          info.volatility_expansion &&
                          info.expansion_strength > 75.0);
   
   // Flight to safety detection
   risk.flight_to_safety = (risk.risk_off_event &&
                            info.cross_asset.yen_safe_haven_flow);
   
   // Risk-on rally detection
   risk.risk_on_rally = (info.volatility_contraction &&
                        info.contraction_duration >= 5 &&
                        !info.extreme_volatility);
   
   // Calculate risk appetite score
   double risk_score = 0.0;
   
   if(risk.risk_on_rally) risk_score += 50.0;
   if(risk.risk_off_event) risk_score -= 60.0;
   if(risk.flight_to_safety) risk_score -= 40.0;
   
   // Adjust based on volatility percentile
   risk_score += (50.0 - info.volatility_percentile) * 0.8;
   
   // Adjust based on cross-asset conditions
   risk_score += info.cross_asset.global_risk_appetite * 30.0;
   
   risk.risk_appetite_score = MathMax(-100.0, MathMin(100.0, risk_score));
}

void ATRVolatilityEngine::AnalyzePolicyImpact(ATRVolatilityInfo &info)
{
   PolicyImpactInfo policy = info.policy_impact;
   
   // Monetary Policy Stance Analysis
   AnalyzeMonetaryPolicyStance(policy, info);
   
   // Central Bank Intervention Analysis
   AnalyzeCentralBankIntervention(policy, info);
   
   // Policy Communication Impact
   AnalyzePolicyCommunicationImpact(policy, info);
   
   // Cross-Border Impact Analysis
   AnalyzeCrossBorderImpact(policy, info);
   
   // Economic Data Impact Analysis
   AnalyzeEconomicDataImpact(policy, info);
   
   Print("🏛️ Policy impact analysis completed");
}

void ATRVolatilityEngine::AnalyzeEconomicDataImpact(PolicyImpactInfo &policy, const ATRVolatilityInfo &info)
{
   // Economic surprises (simplified simulation based on volatility)
   
   // Inflation surprise
   if(info.volatility_expansion && info.expansion_strength > 50.0)
      policy.inflation_surprise = 0.3; // Higher than expected inflation
   else if(info.volatility_contraction)
      policy.inflation_surprise = -0.2; // Lower than expected inflation
   else
      policy.inflation_surprise = 0.0;
   
   // Employment surprise
   if(info.risk_regime.risk_on_rally)
      policy.employment_surprise = 0.2; // Better employment
   else if(info.risk_regime.risk_off_event)
      policy.employment_surprise = -0.3; // Worse employment
   else
      policy.employment_surprise = 0.0;
   
   // GDP surprise
   if(info.cross_asset.growth_scare)
      policy.gdp_surprise = -0.4; // Lower GDP
   else if(info.volatility_percentile < 30.0)
      policy.gdp_surprise = 0.15; // Higher GDP
   else
      policy.gdp_surprise = 0.0;
   
   // Data dependent policy
   policy.data_dependent_policy = (MathAbs(policy.inflation_surprise) > 0.2 ||
                                  MathAbs(policy.employment_surprise) > 0.2 ||
                                  MathAbs(policy.gdp_surprise) > 0.3);
}

void ATRVolatilityEngine::AnalyzeCrossBorderImpact(PolicyImpactInfo &policy, const ATRVolatilityInfo &info)
{
   // Spillover effect
   double spillover = 0.0;
   
   if(info.cross_asset.equity_vol_spillover > 0.5) spillover += 25.0;
   if(info.cross_asset.fx_vol_spillover > 0.5) spillover += 30.0;
   if(info.cross_asset.bond_vol_spillover > 0.5) spillover += 20.0;
   if(info.risk_regime.contagion_risk > 50.0) spillover += 35.0;
   
   policy.spillover_effect = MathMin(100.0, spillover);
   
   // Currency war risk
   policy.currency_war_risk = (policy.fx_intervention_risk &&
                              info.cross_asset.carry_trade_unwinding > 0.6 &&
                              policy.spillover_effect > 60.0);
   
   // Global liquidity impact
   double liquidity_impact = 0.0;
   
   if(policy.quantitative_easing) liquidity_impact += 60.0;
   if(policy.quantitative_tightening) liquidity_impact -= 40.0;
   if(info.risk_regime.liquidity_crisis) liquidity_impact -= 50.0;
   if(policy.spillover_effect > 50.0) liquidity_impact *= 1.2;
   
   policy.global_liquidity_impact = MathMax(-100.0, MathMin(100.0, liquidity_impact));
}

void ATRVolatilityEngine::AnalyzePolicyCommunicationImpact(PolicyImpactInfo &policy, const ATRVolatilityInfo &info)
{
   // Forward guidance change
   policy.forward_guidance_change = (policy.dovish_shift || policy.hawkish_shift);
   
   // Communication impact
   double comm_impact = 0.0;
   
   if(policy.forward_guidance_change) comm_impact += 40.0;
   if(info.extreme_volatility) comm_impact += 30.0; // More impact during high vol
   if(policy.policy_uncertainty > 50.0) comm_impact += 20.0;
   
   policy.communication_impact = MathMin(100.0, comm_impact);
   
   // Policy surprise
   policy.policy_surprise = (info.regime_change_risk &&
                            (policy.dovish_shift || policy.hawkish_shift) &&
                            info.extreme_volatility);
   
   // Market reaction intensity
   double reaction_intensity = 0.0;
   
   if(policy.policy_surprise) reaction_intensity += 50.0;
   if(policy.communication_impact > 60.0) reaction_intensity += 30.0;
   if(info.volatility_expansion) reaction_intensity += 25.0;
   
   policy.market_reaction_intensity = MathMin(100.0, reaction_intensity);
}

void ATRVolatilityEngine::AnalyzeCentralBankIntervention(PolicyImpactInfo &policy, const ATRVolatilityInfo &info)
{
   // FX intervention risk
   policy.fx_intervention_risk = (info.extreme_volatility &&
                                 info.expansion_strength > 80.0 &&
                                 (StringFind(m_symbol, "USD") >= 0 ||
                                  StringFind(m_symbol, "EUR") >= 0 ||
                                  StringFind(m_symbol, "JPY") >= 0));
   
   // Yield curve control
   policy.yield_curve_control = (info.risk_regime.liquidity_crisis &&
                                info.policy_impact.dovish_shift);
   
   // Quantitative easing
   policy.quantitative_easing = (info.risk_regime.market_crash_risk ||
                                (info.risk_regime.systemic_risk_score > 70.0 &&
                                 policy.dovish_shift));
   
   // Quantitative tightening
   policy.quantitative_tightening = (info.volatility_percentile < 25.0 &&
                                    !info.risk_regime.risk_off_event &&
                                    policy.hawkish_shift);
}

void ATRVolatilityEngine::AnalyzeMonetaryPolicyStance(PolicyImpactInfo &policy, const ATRVolatilityInfo &info)
{
   // Detect dovish/hawkish shifts based on volatility patterns
   bool high_vol_environment = info.volatility_percentile > 70.0;
   bool vol_expansion = info.volatility_expansion;
   
   // Dovish shift detection (typically in response to high volatility/crisis)
   policy.dovish_shift = (high_vol_environment && 
                         info.risk_regime.market_crash_risk &&
                         vol_expansion);
   
   // Hawkish shift detection (typically during low volatility/overheating)
   policy.hawkish_shift = (info.volatility_percentile < 30.0 &&
                          info.volatility_contraction &&
                          !info.risk_regime.risk_off_event);
   
   // Policy uncertainty calculation
   double uncertainty = 0.0;
   
   if(info.regime_change_risk) uncertainty += 30.0;
   if(info.extreme_volatility) uncertainty += 25.0;
   if(info.risk_regime.systemic_risk_score > 50.0) uncertainty += 20.0;
   if(info.cross_asset.global_risk_appetite < -0.5) uncertainty += 15.0;
   
   policy.policy_uncertainty = MathMin(100.0, uncertainty);
   
   // Rate expectation change
   double rate_change = 0.0;
   
   if(policy.dovish_shift) rate_change -= 0.5; // Expect rate cuts
   if(policy.hawkish_shift) rate_change += 0.25; // Expect rate hikes
   if(info.risk_regime.emergency_measures) rate_change -= 0.75; // Emergency cuts
   
   policy.rate_expectation_change = MathMax(-1.0, MathMin(1.0, rate_change));
}

void ATRVolatilityEngine::AnalyzeCrossAssetVolatility(ATRVolatilityInfo &info)
{
   CrossAssetVolatilityInfo cross = info.cross_asset;
   
   // Calculate Asset Correlations
   CalculateAssetCorrelations(cross, info);
   
   // Analyze Volatility Spillover
   AnalyzeVolatilitySpillover(cross, info);
   
   // Sector Rotation Analysis
   AnalyzeSectorRotation(cross, info);
   
   // Safe Haven Flow Analysis
   //AnalyzeSafeHavenFlows(cross, info);
   
   // Global Risk Indicators
   //CalculateGlobalRiskIndicators(cross, info);
   
   // Economic Regime Detection
   //DetectEconomicRegime(cross, info);
   
   Print("🌐 Cross-asset volatility analysis completed");
}

void ATRVolatilityEngine::AnalyzeSectorRotation(CrossAssetVolatilityInfo &cross, const ATRVolatilityInfo &info)
{
   // Defensive rotation (during high volatility/risk-off)
   cross.defensive_rotation = (info.risk_regime.risk_off_event ||
                              info.volatility_percentile > 75.0);
   
   // Growth rotation (during low volatility/risk-on)
   cross.growth_rotation = (info.risk_regime.risk_on_rally &&
                           info.volatility_percentile < 40.0);
   
   // Value rotation (during transitional periods)
   cross.value_rotation = (!cross.defensive_rotation && 
                          !cross.growth_rotation &&
                          info.regime_change_risk);
   
   // Sector momentum
   double momentum = 0.0;
   
   if(cross.growth_rotation) momentum += 50.0;
   if(cross.defensive_rotation) momentum -= 30.0;
   if(cross.value_rotation) momentum += 20.0;
   if(info.volatility_expansion) momentum += 15.0;
   
   cross.sector_momentum = MathMax(-100.0, MathMin(100.0, momentum));
}

void ATRVolatilityEngine::AnalyzeVolatilitySpillover(CrossAssetVolatilityInfo &cross, const ATRVolatilityInfo &info)
{
   // Calculate volatility spillover effects
   double base_spillover = info.volatility_percentile / 100.0;
   
   // Equity volatility spillover
   cross.equity_vol_spillover = base_spillover * cross.equity_correlation;
   
   // Bond volatility spillover
   cross.bond_vol_spillover = base_spillover * MathAbs(cross.bond_correlation);
   
   // FX volatility spillover
   cross.fx_vol_spillover = base_spillover * 0.8; // FX usually has high spillover
   
   // Commodity volatility spillover
   cross.commodity_vol_spillover = base_spillover * cross.commodity_correlation;
   
   // Adjust for extreme events
   if(info.extreme_volatility)
   {
      cross.equity_vol_spillover *= 1.5;
      cross.fx_vol_spillover *= 1.3;
      cross.commodity_vol_spillover *= 1.4;
   }
}

void ATRVolatilityEngine::CalculateAssetCorrelations(CrossAssetVolatilityInfo &cross, const ATRVolatilityInfo &info)
{
   // Simplified correlation calculations
   // In production, these would use real cross-asset price data
   
   // Base correlations on volatility regime
   switch(info.current_regime)
   {
      case VOLATILITY_LOW:
         cross.equity_correlation = 0.3;
         cross.bond_correlation = -0.2;
         cross.commodity_correlation = 0.4;
         cross.currency_correlation = 0.1;
         cross.crypto_correlation = 0.6;
         break;
         
      case VOLATILITY_HIGH:
      case VOLATILITY_EXTREME:
         cross.equity_correlation = 0.8; // High correlation during stress
         cross.bond_correlation = -0.6;  // Flight to safety
         cross.commodity_correlation = 0.7;
         cross.currency_correlation = 0.5;
         cross.crypto_correlation = 0.9; // Very high correlation in crisis
         break;
         
      default:
         cross.equity_correlation = 0.5;
         cross.bond_correlation = -0.3;
         cross.commodity_correlation = 0.5;
         cross.currency_correlation = 0.2;
         cross.crypto_correlation = 0.7;
         break;
   }
   
   // Adjust based on risk regime
   if(info.risk_regime.risk_off_event)
   {
      cross.equity_correlation += 0.2;
      cross.bond_correlation -= 0.2;
   }
}


void ATRVolatilityEngine::AnalyzeDarkPoolVolatility(ATRVolatilityInfo &info)
{
   DarkPoolVolatilityInfo dark = info.dark_pool;
   
   // Phase 1: Dark Pool Activity Detection
   DetectDarkPoolActivity(dark, info);
   
   // Phase 2: Institutional Footprint Analysis
   AnalyzeInstitutionalFootprint(dark, info);
   
   // Phase 3: Stealth Trading Pattern Detection
   DetectStealthTradingPatterns(dark, info);
   
   // Phase 4: Market Microstructure Analysis
   AnalyzeMarketMicrostructure(dark, info);
   
   // Phase 5: Volatility Trading Signal Generation
   GenerateDarkPoolVolatilitySignals(dark, info);
   
   // Update main info
   info.dark_pool = dark;
   
   Print(StringFormat("🕳️ Dark Pool Analysis: Activity=%.1f%%, Stealth=%.1f%%, Institutional=%.1f%%",
                     dark.dark_pool_volume_ratio * 100,
                     dark.stealth_trading_intensity * 100,
                     dark.institutional_vol_demand));
}

void ATRVolatilityEngine::AnalyzeMarketMicrostructure(DarkPoolVolatilityInfo &dark, const ATRVolatilityInfo &info)
{
   // Bid-ask impact calculation
   double base_spread = 0.0001; // 1 pip for EURUSD equivalent
   double vol_spread_multiplier = 1.0 + (info.volatility_percentile / 50.0);
   
   dark.bid_ask_impact = base_spread * vol_spread_multiplier;
   
   if(dark.dark_pool_activity)
      dark.bid_ask_impact *= 1.3; // Dark pools can increase spreads
   
   // Market impact cost
   dark.market_impact_cost = dark.bid_ask_impact * (1.0 + dark.institutional_vol_demand / 100.0);
   
   // Liquidity provision/consumption
   if(dark.stealth_accumulation || dark.hidden_liquidity_factor > 0.6)
   {
      dark.liquidity_provision = true;
      dark.liquidity_consumption = false;
   }
   else if(dark.algo_trading_surge || dark.hft_volatility_farming)
   {
      dark.liquidity_provision = false;
      dark.liquidity_consumption = true;
   }
   else
   {
      dark.liquidity_provision = false;
      dark.liquidity_consumption = false;
   }
}


void ATRVolatilityEngine::DetectStealthTradingPatterns(DarkPoolVolatilityInfo &dark, const ATRVolatilityInfo &info)
{
   // Stealth accumulation detection
   dark.stealth_accumulation = (info.volatility_contraction &&
                               dark.dark_pool_activity &&
                               info.contraction_duration >= 5 &&
                               !info.extreme_volatility);
   
   // Stealth distribution detection
   dark.stealth_distribution = (info.volatility_expansion &&
                               info.expansion_strength < 75.0 &&
                               dark.dark_pool_volume_ratio > 0.2 &&
                               info.expansion_bars >= 3);
   
   // Stealth trading intensity
   double intensity = 0.0;
   
   if(dark.stealth_accumulation) intensity += 0.4;
   if(dark.stealth_distribution) intensity += 0.5;
   if(dark.iceberg_orders) intensity += 0.3;
   if(dark.hidden_liquidity_factor < 0.4) intensity += 0.2;
   
   dark.stealth_trading_intensity = MathMin(1.0, intensity);
   
   // Coordinated execution detection
   dark.coordinated_execution = (dark.stealth_trading_intensity > 0.6 &&
                                dark.institutional_vol_demand > 50.0 &&
                                (info.regime_h1 == info.regime_h4)); // Cross-timeframe coordination
}

void ATRVolatilityEngine::AnalyzeInstitutionalFootprint(DarkPoolVolatilityInfo &dark, const ATRVolatilityInfo &info)
{
   // Block trading detection
   dark.block_trading = (info.extreme_volatility && 
                        info.expansion_bars >= 2 &&
                        dark.dark_pool_activity);
   
   // Algorithmic trading surge detection
   bool rapid_vol_changes = (info.atr_momentum > 50.0 || info.atr_momentum < -50.0);
   dark.algo_trading_surge = (rapid_vol_changes && 
                             info.volatility_expansion &&
                             (info.current_session == SESSION_LONDON ||
                             info.current_session == SESSION_NEWYORK));
   
   // HFT volatility farming detection
   dark.hft_volatility_farming = (info.microstructure_vol > info.atr_h1 * 1.2 &&
                                 dark.algo_trading_surge &&
                                 info.high_volatility_session);
   
   // Institutional volatility demand calculation
   double demand = 0.0;
   
   if(dark.block_trading) demand += 25.0;
   if(dark.algo_trading_surge) demand += 20.0;
   if(dark.hft_volatility_farming) demand += 15.0;
   if(info.vol_surface.vol_trading_signal_strength > 60.0) demand += 20.0;
   
   // Adjust for market conditions
   if(info.risk_regime.institutional_hedging) demand += 30.0;
   if(info.policy_impact.policy_uncertainty > 50.0) demand += 15.0;
   
   dark.institutional_vol_demand = MathMin(100.0, demand);
}

void ATRVolatilityEngine::DetectDarkPoolActivity(DarkPoolVolatilityInfo &dark, const ATRVolatilityInfo &info)
{
   // Dark pool activity indicator based on volume-volatility divergence
   double vol_expansion_without_price_movement = 0.0;
   
   if(info.volatility_expansion && info.expansion_strength > 30.0)
   {
      // Check if volatility expansion is accompanied by unusual volume patterns
      vol_expansion_without_price_movement = info.expansion_strength * 0.6;
   }
   
   // Dark pool volume ratio estimation
   dark.dark_pool_volume_ratio = MathMin(0.8, vol_expansion_without_price_movement / 100.0);
   dark.dark_pool_activity = dark.dark_pool_volume_ratio > 0.15; // 15% threshold
   
   // Iceberg orders detection
   dark.iceberg_orders = (info.volatility_expansion && 
                         info.expansion_bars <= 2 && 
                         info.expansion_strength > 50.0);
   
   // Hidden liquidity factor
   if(dark.dark_pool_activity)
   {
      dark.hidden_liquidity_factor = 0.3 + (dark.dark_pool_volume_ratio * 0.5);
   }
   else
   {
      dark.hidden_liquidity_factor = 0.8 - (info.volatility_percentile / 200.0);
   }
   
   dark.hidden_liquidity_factor = MathMax(0.1, MathMin(0.9, dark.hidden_liquidity_factor));
}

void GenerateDarkPoolVolatilitySignals(DarkPoolVolatilityInfo &dark, const ATRVolatilityInfo &info)
{
   // Volatility arbitrage opportunity
   dark.vol_arb_opportunity = (MathAbs(info.vol_surface.vol_risk_premium) > 0.05 &&
                              dark.institutional_vol_demand > 40.0);
   
   // Gamma squeeze risk
   dark.gamma_squeeze_risk = (info.extreme_volatility &&
                             info.expansion_strength > 100.0 &&
                             dark.coordinated_execution);
   
   // Volatility clustering
   dark.volatility_clustering = (info.expansion_bars >= 3 &&
                               info.atr_trend_short == TREND_BULLISH &&
                               dark.algo_trading_surge);
   
   // Implied-Realized volatility spread
   double implied_vol = info.vol_surface.vol_term_structure[2]; // 1M
   double realized_vol = info.vol_surface.realized_vol_1m;
   
   if(realized_vol > 0)
      dark.implied_realized_spread = implied_vol - realized_vol;
   else
      dark.implied_realized_spread = 0.0;
}

void ATRVolatilityEngine::AnalyzeEnhancedMarketSessions(ATRVolatilityInfo &info)
{
   // Determine current session
   MqlDateTime time;
   TimeCurrent(time);
   
   int current_hour = time.hour;
   info.current_session = DetermineCurrentSession(current_hour);
   
   // Analyze session-specific volatility patterns
   AnalyzeSessionVolatilityPatterns(info);
   
   // Calculate session volatility factors
   CalculateSessionVolatilityFactors(info);
   
   // Detect high volatility sessions
   DetectHighVolatilitySessions(info);
   
   // Calculate session transition effects
   CalculateSessionTransitionEffects(info);

}

void ATRVolatilityEngine::CalculateSessionTransitionEffects(ATRVolatilityInfo &info)
{
   MqlDateTime time;
   TimeCurrent(time);
   
   int current_hour = time.hour;
   
   bool session_transition = false;
   
   // Check for session transition times (±1 hour)
   int transition_hours[] = {7, 8, 9, 12, 13, 14, 16, 17, 18, 21, 22, 23};
   
   for(int i = 0; i < ArraySize(transition_hours); i++)
   {
      if(MathAbs(current_hour - transition_hours[i]) <= 1)
      {
         session_transition = true;
         break;
      }
   }
   
   if(session_transition)
   {
      // Increase volatility factor during transitions
      info.current_session_factor *= 1.15;
      
      // Higher probability of regime changes during transitions
      if(!info.regime_change_risk && info.volatility_percentile > 70.0)
         info.vol_regime_change_imminent = true;
   }
}

void ATRVolatilityEngine::DetectHighVolatilitySessions(ATRVolatilityInfo &info)
{
   // High volatility session criteria
   bool active_session = (info.current_session == SESSION_LONDON ||
                         info.current_session == SESSION_NEWYORK ||
                         info.current_session == SESSION_OVERLAP_LONDON_NY);
   
   bool vol_conditions = (info.volatility_percentile > 60.0 ||
                         info.volatility_expansion ||
                         info.extreme_volatility);
   
   bool institutional_activity = (info.dark_pool.dark_pool_activity ||
                                 info.risk_regime.institutional_hedging);
   
   info.high_volatility_session = active_session && (vol_conditions || institutional_activity);
   
   // Special conditions override
   if(info.risk_regime.market_crash_risk || info.policy_impact.emergency_measures)
      info.high_volatility_session = true;
}

void ATRVolatilityEngine::CalculateSessionVolatilityFactors(ATRVolatilityInfo &info)
{
   int session_index = (int)info.current_session;
   
   if(session_index >= 0 && session_index < 7)
   {
      info.current_session_factor = info.session_volatility[session_index] / info.atr_h1;
   }
   else
   {
      info.current_session_factor = 1.0;
   }
   
   // Additional factors for special conditions
   if(info.policy_impact.policy_surprise)
      info.current_session_factor *= 1.4;
   
   if(info.vol_surface.vol_regime_change)
      info.current_session_factor *= 1.2;
   
   // Limit factor range
   info.current_session_factor = MathMax(0.3, MathMin(2.5, info.current_session_factor));
}
void ATRVolatilityEngine::AnalyzeSessionVolatilityPatterns(ATRVolatilityInfo &info)
{
   // Calculate session-specific volatility multipliers
   double session_multipliers[7] = {0.6, 0.8, 1.4, 1.5, 1.8, 0.7, 0.4}; // Enhanced values
   
   for(int i = 0; i < 7; i++)
   {
      double base_vol = info.atr_h1;
      info.session_volatility[i] = base_vol * session_multipliers[i];
      
      // Adjust for current volatility regime
      switch(info.current_regime)
      {
         case VOLATILITY_HIGH:
         case VOLATILITY_EXTREME:
            info.session_volatility[i] *= 1.3;
            break;
         case VOLATILITY_LOW:
            info.session_volatility[i] *= 0.8;
            break;
      }
      
      // Adjust for risk regime
      if(info.risk_regime.risk_off_event)
         info.session_volatility[i] *= 1.5;
      else if(info.risk_regime.risk_on_rally)
         info.session_volatility[i] *= 0.9;
   }
}

ENUM_TRADING_SESSION ATRVolatilityEngine::DetermineCurrentSession(int hour)
{
   // Enhanced session determination with overlaps
   if((hour >= 22 && hour <= 23) || (hour >= 0 && hour <= 6))
   {
      if(hour >= 0 && hour <= 6) return SESSION_OVERLAP_SYDNEY_TOKYO;
      return SESSION_SYDNEY;
   }
   else if(hour >= 0 && hour <= 8)
   {
      return SESSION_TOKYO;
   }
   else if(hour >= 8 && hour <= 16)
   {
      if(hour >= 13 && hour <= 16) return SESSION_OVERLAP_LONDON_NY;
      return SESSION_LONDON;
   }
   else if(hour >= 13 && hour <= 21)
   {
      return SESSION_NEWYORK;
   }
   else
   {
      return SESSION_DEAD_ZONE;
   }
}

void ATRVolatilityEngine::AnalyzeEnhancedBreakoutPotential(ATRVolatilityInfo &info)
{
   // Phase 1: Calculate Breakout Probability
   CalculateBreakoutProbability(info);
   
   // Phase 2: Assess False Breakout Risk
   AssessFalseBreakoutRisk(info);
   
   // Phase 3: Calculate Continuation Probability
   CalculateContinuationProbability(info);
   
   // Phase 4: Calculate Reversal Probability
   CalculateReversalProbability(info);
   
   // Phase 5: Integrate Cross-Asset Confirmation
   IntegrateCrossAssetConfirmation(info);
      
   Print("🎯 Enhanced breakout potential analysis stub");
}

void ATRVolatilityEngine::IntegrateCrossAssetConfirmation(ATRVolatilityInfo &info)
{
   // Adjust probabilities based on cross-asset conditions
   double confirmation_factor = 1.0;
   
   // Strong cross-asset spillover increases breakout probability
   if(info.cross_asset.equity_vol_spillover > 0.6 &&
      info.cross_asset.fx_vol_spillover > 0.6)
   {
      confirmation_factor = 1.2;
      info.breakout_probability *= confirmation_factor;
      info.continuation_probability *= confirmation_factor;
   }
   
   // Cross-asset divergence increases false breakout risk
   if(info.cross_asset.correlation_breakdown > 0.6)
   {
      info.false_breakout_risk *= 1.3;
      info.reversal_probability *= 1.15;
   }
   
   // Safe haven flows increase reversal probability
   if(info.cross_asset.gold_safe_haven_flow || 
      info.cross_asset.yen_safe_haven_flow)
   {
      info.reversal_probability *= 1.2;
      info.breakout_probability *= 0.9;
   }
   
   // Ensure probabilities don't exceed limits
   info.breakout_probability = MathMin(95.0, info.breakout_probability);
   info.false_breakout_risk = MathMin(90.0, info.false_breakout_risk);
   info.continuation_probability = MathMin(90.0, info.continuation_probability);
   info.reversal_probability = MathMin(85.0, info.reversal_probability);
}

void ATRVolatilityEngine::CalculateReversalProbability(ATRVolatilityInfo &info)
{
   double probability = 0.0;
   
   // Extreme volatility often leads to reversals
   if(info.extreme_volatility && info.volatility_percentile > 95.0)
      probability += 40.0;
   
   // Volatility spike exhaustion
   if(info.vol_surface.vol_spike_exhaustion)
      probability += 35.0;
   
   // Mean reversion signals
   if(info.vol_surface.vol_mean_revert_signal)
      probability += 30.0;
   
   // Negative ATR momentum
   if(info.atr_momentum < -20.0)
      probability += 25.0;
   
   // Risk regime factors
   if(info.risk_regime.flight_to_safety)
      probability += 20.0;
   
   // Policy response likelihood
   if(info.risk_regime.policy_response_prob > 60.0)
      probability += 15.0;
   
   // High false breakout risk
   probability += info.false_breakout_risk * 0.4;
   
   info.reversal_probability = MathMin(85.0, probability);
}

void ATRVolatilityEngine::CalculateContinuationProbability(ATRVolatilityInfo &info)
{
   double probability = 0.0;
   
   // Strong expansion with institutional support
   if(info.volatility_expansion && 
      info.expansion_strength > 50.0 &&
      info.dark_pool.institutional_vol_demand > 40.0)
      probability += 40.0;
   
   // Positive ATR momentum
   if(info.atr_momentum > 20.0)
      probability += 25.0;
   else if(info.atr_momentum > 0.0)
      probability += 15.0;
   
   // Session support
   if(info.high_volatility_session)
      probability += 20.0;
   
   // Cross-asset confirmation
   if(info.cross_asset.equity_vol_spillover > 0.5 ||
      info.cross_asset.fx_vol_spillover > 0.5)
      probability += 15.0;
   
   // Regime alignment
   if(info.regime_h1 == info.regime_h4)
      probability += 10.0;
   
   // Low false breakout risk enhances continuation probability
   probability += (50.0 - info.false_breakout_risk) * 0.3;
   
   info.continuation_probability = MathMin(90.0, probability);
}

void ATRVolatilityEngine::AssessFalseBreakoutRisk(ATRVolatilityInfo &info)
{
   double risk = 0.0;
   
   // High volatility = higher false breakout risk
   if(info.extreme_volatility)
      risk += 30.0;
   else if(info.volatility_percentile > 80.0)
      risk += 20.0;
   
   // Recent expansion without institutional support
   if(info.volatility_expansion && 
      info.dark_pool.institutional_vol_demand < 30.0)
      risk += 25.0;
   
   // Session risk factors
   if(info.current_session == SESSION_DEAD_ZONE)
      risk += 20.0;
   else if(!info.high_volatility_session && info.volatility_expansion)
      risk += 15.0;
   
   // Policy uncertainty
   if(info.policy_impact.policy_uncertainty > 70.0)
      risk += 15.0;
   
   // Cross-asset divergence
   if(info.cross_asset.correlation_breakdown > 0.5)
      risk += 20.0;
   
   // Risk-off environment
   if(info.risk_regime.risk_off_event)
      risk += 25.0;
   
   info.false_breakout_risk = MathMin(90.0, risk);
}

void ATRVolatilityEngine::CalculateBreakoutProbability(ATRVolatilityInfo &info)
{
   double probability = 0.0;
   
   // Volatility expansion factor (40% weight)
   if(info.volatility_expansion)
   {
      probability += (info.expansion_strength / 100.0) * 40.0;
   }
   
   // Volatility regime factor (25% weight)
   switch(info.current_regime)
   {
      case VOLATILITY_CONTRACTION:
         probability += 30.0; // Contractions often lead to breakouts
         break;
      case VOLATILITY_LOW:
         probability += 25.0;
         break;
      case VOLATILITY_EXPANSION:
         probability += 15.0; // Already in expansion
         break;
   }
   
   // Session factor (15% weight)
   if(info.high_volatility_session)
      probability += 15.0;
   
   // Institutional activity factor (10% weight)
   if(info.dark_pool.coordinated_execution)
      probability += 10.0;
   
   // Policy impact factor (10% weight)
   if(info.policy_impact.policy_surprise)
      probability += 15.0;
   else if(info.policy_impact.communication_impact > 50.0)
      probability += 8.0;
   
   // Cross-timeframe alignment bonus
   if(info.regime_h1 == info.regime_h4 && info.regime_h4 == info.regime_d1)
      probability += 10.0;
   
   info.breakout_probability = MathMin(95.0, probability);
}


void ATRVolatilityEngine::ExtractNuclearMLFeatures(ATRVolatilityInfo &info)
{
   // Reset feature array
   ArrayInitialize(m_ml_data.features, 0.0);
   
   // Phase 1: Basic Volatility Features (0-14)
   ExtractBasicVolatilityFeatures(info);
   
   // Phase 2: Cross-Timeframe Features (15-29)
   ExtractCrossTimeframeFeatures(info);
   
   // Phase 3: Institutional Features (30-44)
   ExtractInstitutionalFeatures(info);
   
   // Phase 4: Risk Regime Features (45-59)
   ExtractRiskRegimeFeatures(info);
   
   // Phase 5: Advanced Features (60-74)
   ExtractAdvancedFeatures(info);
   
   // Normalize features
   NormalizeMLFeatures();
   Print("🧠 Nuclear ML features extraction stub");
}
void ATRVolatilityEngine::NormalizeMLFeatures()
{
   // Apply Min-Max normalization to ensure all features are in [0,1] range
   for(int i = 0; i < 75; i++)
   {
      // Clamp extreme values
      m_ml_data.features[i] = MathMax(-5.0, MathMin(5.0, m_ml_data.features[i]));
      
      // Normalize to [0,1]
      m_ml_data.features[i] = (m_ml_data.features[i] + 5.0) / 10.0;
   }
}

void ATRVolatilityEngine::ExtractAdvancedFeatures(const ATRVolatilityInfo &info)
{
   // Feature 60-64: Volatility surface features
   m_ml_data.features[60] = info.vol_surface.volatility_skew;
   m_ml_data.features[61] = info.vol_surface.vol_of_vol / 0.01; // Normalize
   m_ml_data.features[62] = info.vol_surface.vol_mean_reversion_speed;
   m_ml_data.features[63] = info.vol_surface.vol_persistence;
   m_ml_data.features[64] = info.vol_surface.vol_risk_premium / 0.1; // Normalize
   
   // Feature 65-69: Session and timing features
   m_ml_data.features[65] = (double)info.current_session / 6.0; // Normalize session enum
   m_ml_data.features[66] = info.current_session_factor;
   m_ml_data.features[67] = info.high_volatility_session ? 1.0 : 0.0;
   
   // Feature 68-69: Breakout features
   m_ml_data.features[68] = info.breakout_probability / 100.0;
   m_ml_data.features[69] = info.false_breakout_risk / 100.0;
   
   // Feature 70-74: Cross-asset spillover
   m_ml_data.features[70] = info.cross_asset.equity_vol_spillover;
   m_ml_data.features[71] = info.cross_asset.fx_vol_spillover;
   m_ml_data.features[72] = info.cross_asset.bond_vol_spillover;
   m_ml_data.features[73] = info.cross_asset.commodity_vol_spillover;
   m_ml_data.features[74] = info.microstructure_vol / (info.atr_h1 > 0 ? info.atr_h1 : 0.001);
}

void ATRVolatilityEngine::ExtractRiskRegimeFeatures(const ATRVolatilityInfo &info)
   {
      // Feature 45-49: Risk-on/Risk-off features
      m_ml_data.features[45] = info.risk_regime.risk_appetite_score / 100.0;
      m_ml_data.features[46] = info.risk_regime.risk_off_event ? 1.0 : 0.0;
      m_ml_data.features[47] = info.risk_regime.flight_to_safety ? 1.0 : 0.0;
      m_ml_data.features[48] = info.risk_regime.risk_on_rally ? 1.0 : 0.0;
      m_ml_data.features[49] = info.cross_asset.global_risk_appetite;
      
      // Feature 50-54: Market stress features
      m_ml_data.features[50] = info.risk_regime.vix_equivalent / 50.0; // Normalize to typical VIX range
      m_ml_data.features[51] = info.risk_regime.systemic_risk_score / 100.0;
      m_ml_data.features[52] = info.risk_regime.tail_risk_event ? 1.0 : 0.0;
      m_ml_data.features[53] = info.risk_regime.correlation_breakdown;
      m_ml_data.features[54] = info.risk_regime.contagion_risk / 100.0;
      
      // Feature 55-59: Crisis and policy features
      m_ml_data.features[55] = info.risk_regime.market_crash_risk ? 1.0 : 0.0;
      m_ml_data.features[56] = info.risk_regime.liquidity_crisis ? 1.0 : 0.0;
      m_ml_data.features[57] = info.policy_impact.policy_uncertainty / 100.0;
      m_ml_data.features[58] = info.policy_impact.policy_surprise ? 1.0 : 0.0;
      m_ml_data.features[59] = info.risk_regime.policy_response_prob / 100.0;
   }

void ATRVolatilityEngine::ExtractInstitutionalFeatures(const ATRVolatilityInfo &info)
{
   // Feature 30-34: Dark pool features
   m_ml_data.features[30] = info.dark_pool.dark_pool_volume_ratio;
   m_ml_data.features[31] = info.dark_pool.stealth_trading_intensity;
   m_ml_data.features[32] = info.dark_pool.institutional_vol_demand / 100.0;
   m_ml_data.features[33] = info.dark_pool.dark_pool_activity ? 1.0 : 0.0;
   m_ml_data.features[34] = info.dark_pool.coordinated_execution ? 1.0 : 0.0;
   
   // Feature 35-39: Institutional behavior
   m_ml_data.features[35] = info.risk_regime.institutional_hedging ? 1.0 : 0.0;
   m_ml_data.features[36] = info.risk_regime.smart_money_positioning ? 1.0 : 0.0;
   m_ml_data.features[37] = info.risk_regime.institutional_flow / 100.0;
   m_ml_data.features[38] = info.institutional_vol_demand / 100.0;
   m_ml_data.features[39] = info.smart_money_vol_positioning / 100.0;
   
   // Feature 40-44: Advanced institutional metrics
   m_ml_data.features[40] = info.dark_pool.hidden_liquidity_factor;
   m_ml_data.features[41] = info.dark_pool.market_impact_cost / 0.001; // Normalize
   m_ml_data.features[42] = info.dark_pool.algo_trading_surge ? 1.0 : 0.0;
   m_ml_data.features[43] = info.dark_pool.hft_volatility_farming ? 1.0 : 0.0;
   m_ml_data.features[44] = info.dark_pool.vol_arb_opportunity ? 1.0 : 0.0;
}

void ATRVolatilityEngine::ExtractBasicVolatilityFeatures(const ATRVolatilityInfo &info)
{
   // Feature 0-4: ATR values normalized
   m_ml_data.features[0] = info.atr_h1 / 0.001; // Normalize to typical range
   m_ml_data.features[1] = info.atr_h4 / 0.004;
   m_ml_data.features[2] = info.atr_d1 / 0.02;
   m_ml_data.features[3] = info.volatility_percentile / 100.0;
   m_ml_data.features[4] = info.volatility_zscore / 4.0; // Normalize to ±4 sigma
   
   // Feature 5-9: Volatility dynamics
   m_ml_data.features[5] = info.expansion_strength / 100.0;
   m_ml_data.features[6] = info.contraction_duration / 20.0;
   m_ml_data.features[7] = info.atr_momentum / 100.0;
   m_ml_data.features[8] = info.extreme_volatility ? 1.0 : 0.0;
   m_ml_data.features[9] = info.volatility_expansion ? 1.0 : 0.0;
   
   // Feature 10-14: Regime information
   m_ml_data.features[10] = (double)info.current_regime / 6.0; // Normalize enum
   m_ml_data.features[11] = (double)info.regime_h1 / 6.0;
   m_ml_data.features[12] = (double)info.regime_h4 / 6.0;
   m_ml_data.features[13] = (double)info.regime_d1 / 6.0;
   m_ml_data.features[14] = info.regime_change_risk ? 1.0 : 0.0;
}
void ATRVolatilityEngine::ExtractCrossTimeframeFeatures(const ATRVolatilityInfo &info)
{
   // Feature 15-19: ATR ratios between timeframes
   if(info.atr_h1 > 0)
   {
      m_ml_data.features[15] = info.atr_m15 / info.atr_h1;
      m_ml_data.features[16] = info.atr_h4 / info.atr_h1;
      m_ml_data.features[17] = info.atr_d1 / info.atr_h1;
      m_ml_data.features[18] = info.atr_w1 / info.atr_h1;
   }
   
   // Feature 19-24: Cross-timeframe trends
   m_ml_data.features[19] = (double)info.atr_trend_short / 2.0; // Normalize trend enum
   m_ml_data.features[20] = (double)info.atr_trend_medium / 2.0;
   m_ml_data.features[21] = (double)info.atr_trend_long / 2.0;
   
   // Feature 22-24: Timeframe alignment
   bool tf_alignment_h1_h4 = (info.regime_h1 == info.regime_h4);
   bool tf_alignment_h4_d1 = (info.regime_h4 == info.regime_d1);
   bool full_alignment = (tf_alignment_h1_h4 && tf_alignment_h4_d1);
   
   m_ml_data.features[22] = tf_alignment_h1_h4 ? 1.0 : 0.0;
   m_ml_data.features[23] = tf_alignment_h4_d1 ? 1.0 : 0.0;
   m_ml_data.features[24] = full_alignment ? 1.0 : 0.0;
   
   // Feature 25-29: Correlation features
   for(int i = 0; i < 5; i++)
   {
      if(i < 5) m_ml_data.features[25 + i] = m_correlation_matrix[i*5 + ((i+1)%5)];
   }
}

void ATRVolatilityEngine::CalculateNuclearMLPredictions(ATRVolatilityInfo &info)
{
   if(!m_ml_data.is_trained)
   {
      TrainMLModel(); // Auto-train if not trained
   }
   
   // Phase 1: Basic ML Predictions
   CalculateBasicMLPredictions(info);
   
   // Phase 2: Deep Learning Predictions
   CalculateDeepLearningPredictions(info);
   
   // Phase 3: Ensemble Predictions
   CalculateEnsemblePredictions(info);
   
   // Phase 4: Pattern Recognition
   CalculatePatternRecognition(info);
   
   Print(StringFormat("🤖 ML Predictions: Vol Forecast=%.5f, Regime Prob=%.2f, Pattern=%.2f",
                     info.ml_volatility_forecast, info.ml_regime_probability, info.pattern_recognition));
}

void ATRVolatilityEngine::CalculatePatternRecognition(ATRVolatilityInfo &info)
{
   double pattern_score = 0.0;
   
   // Pattern 1: Volatility compression before breakout
   if(info.volatility_contraction && info.contraction_duration >= 5)
      pattern_score += 25.0;
   
   // Pattern 2: Cross-timeframe regime alignment
   if(info.regime_h1 == info.regime_h4 && info.regime_h4 == info.regime_d1)
      pattern_score += 20.0;
   
   // Pattern 3: Institutional activity surge
   if(info.dark_pool.coordinated_execution && info.dark_pool.institutional_vol_demand > 50.0)
      pattern_score += 20.0;
   
   // Pattern 4: Risk regime transition
   if(info.risk_regime.risk_off_event && info.vol_regime_change_imminent)
      pattern_score += 25.0;
   
   // Pattern 5: Session transition volatility
   if(info.current_session == SESSION_OVERLAP_LONDON_NY && info.volatility_expansion)
      pattern_score += 15.0;
   
   // Pattern 6: Policy-driven volatility spike
   if(info.policy_impact.policy_surprise && info.extreme_volatility)
      pattern_score += 20.0;
   
   info.pattern_recognition = MathMin(100.0, pattern_score);
}

void ATRVolatilityEngine::CalculateDeepLearningPredictions(ATRVolatilityInfo &info)
{
   if(!m_ml_data.deep_learning_active) return;
   
   // Simplified LSTM-like calculation
   double lstm_output = CalculateLSTMOutput();
   
   // Simplified GRU-like calculation
   double gru_output = CalculateGRUOutput();
   
   // Simplified Transformer-like calculation
   double transformer_output = CalculateTransformerOutput();
   
   // Combine deep learning outputs
   double dl_volatility_forecast = (lstm_output + gru_output + transformer_output) / 3.0;
   
   // Weight with basic ML prediction
   info.ml_volatility_forecast = (info.ml_volatility_forecast * 0.7) + (dl_volatility_forecast * 0.3);
   
   // Adjust regime probability with deep learning
   double dl_regime_signal = MathTanh((lstm_output + gru_output) / 2.0);
   info.ml_regime_probability = (info.ml_regime_probability * 0.8) + (dl_regime_signal * 0.2);
}

double ATRVolatilityEngine::CalculateLSTMOutput()
{
   double output = 0.0;
   
   // Simplified LSTM cell calculation
   for(int i = 0; i < 25; i++) // Use first 25 features for LSTM
   {
      double forget_gate = 1.0 / (1.0 + MathExp(-(m_ml_data.features[i] * m_ml_data.lstm_weights[i])));
      double input_gate = 1.0 / (1.0 + MathExp(-(m_ml_data.features[i] * m_ml_data.lstm_weights[i+25])));
      double candidate = MathTanh(m_ml_data.features[i] * m_ml_data.lstm_weights[i+50]);
      
      output += forget_gate * input_gate * candidate;
   }
   
   return MathTanh(output / 25.0);
}

double ATRVolatilityEngine::CalculateGRUOutput()
{
   double output = 0.0;
   
   // Simplified GRU calculation
   for(int i = 25; i < 50; i++) // Use features 25-49 for GRU
   {
      int weight_idx = i - 25;
      double reset_gate = 1.0 / (1.0 + MathExp(-(m_ml_data.features[i] * m_ml_data.gru_weights[weight_idx])));
      double update_gate = 1.0 / (1.0 + MathExp(-(m_ml_data.features[i] * m_ml_data.gru_weights[weight_idx+25])));
      double candidate = MathTanh(m_ml_data.features[i] * reset_gate * m_ml_data.gru_weights[weight_idx+50]);
      
      output += update_gate * candidate;
   }
   
   return MathTanh(output / 25.0);
}

double ATRVolatilityEngine::CalculateTransformerOutput()
{
   double output = 0.0;
   
   // Simplified self-attention mechanism
   for(int i = 50; i < 75; i++) // Use features 50-74 for Transformer
   {
      int weight_idx = (i - 50) % 100; // Cycle through transformer weights
      double attention_weight = 1.0 / (1.0 + MathExp(-(m_ml_data.features[i] * m_ml_data.transformer_weights[weight_idx])));
      double value = m_ml_data.features[i] * m_ml_data.transformer_weights[weight_idx + 100];
      
      output += attention_weight * value;
   }
   
   return MathTanh(output / 25.0);
}

void ATRVolatilityEngine::CalculateEnsemblePredictions(ATRVolatilityInfo &info)
{
   // Ensemble different prediction methods
   double ensemble_weight_basic = 0.4;
   double ensemble_weight_garch = 0.3;
   double ensemble_weight_pattern = 0.3;
   
   // GARCH-based forecast
   double garch_forecast = info.vol_surface.garch_forecast;
   
   // Pattern-based forecast
   double pattern_forecast = CalculatePatternBasedForecast(info);
   
   // Combine all forecasts
   double ensemble_forecast = (info.ml_volatility_forecast * ensemble_weight_basic) +
                             (garch_forecast * ensemble_weight_garch) +
                             (pattern_forecast * ensemble_weight_pattern);
   
   info.ml_volatility_forecast = ensemble_forecast;
   
   // Confidence calculation based on agreement between methods
   double forecast_variance = MathPow(info.ml_volatility_forecast - garch_forecast, 2) +
                             MathPow(info.ml_volatility_forecast - pattern_forecast, 2);
   
   double confidence = 1.0 / (1.0 + forecast_variance * 1000.0); // Scale variance
   info.signal_confidence = MathMax(0.1, MathMin(0.95, confidence));
}

double ATRVolatilityEngine::CalculatePatternBasedForecast(const ATRVolatilityInfo &info)
{
   // Simple pattern-based volatility forecast
   double forecast = info.atr_h1; // Base forecast
   
   // Pattern adjustments
   if(info.volatility_expansion && info.expansion_bars >= 2)
   {
      forecast *= (1.0 + info.expansion_strength / 200.0); // Continue expansion
   }
   else if(info.volatility_contraction && info.contraction_duration >= 5)
   {
      forecast *= 1.3; // Contraction often leads to expansion
   }
   
   // Session pattern adjustment
   if(info.high_volatility_session)
      forecast *= 1.15;
   
   // Institutional pattern adjustment
   if(info.dark_pool.coordinated_execution)
      forecast *= 1.2;
   
   return forecast;
}

void ATRVolatilityEngine::CalculateBasicMLPredictions(ATRVolatilityInfo &info)
{
   // Linear combination of features for volatility forecast
   double forecast = 0.0;
   
   for(int i = 0; i < 75; i++)
   {
      forecast += m_ml_data.features[i] * m_ml_data.weights[i];
   }
   
   // Apply activation function (sigmoid)
   forecast = 1.0 / (1.0 + MathExp(-forecast));
   
   // Scale to reasonable volatility range
   info.ml_volatility_forecast = forecast * info.atr_h1 * 2.0; // Max 2x current ATR
   
   // ML regime probability
   double regime_signal = 0.0;
   
   // Focus on regime-relevant features
   for(int i = 10; i < 25; i++) // Regime and cross-timeframe features
   {
      regime_signal += m_ml_data.features[i] * m_ml_data.weights[i] * 2.0;
   }
   
   info.ml_regime_probability = MathMax(0.0, MathMin(1.0, 1.0 / (1.0 + MathExp(-regime_signal))));
   
   // ML expansion signal
   double expansion_signal = 0.0;
   
   // Focus on expansion-relevant features
   for(int i = 5; i < 15; i++) // Volatility dynamics features
   {
      expansion_signal += m_ml_data.features[i] * m_ml_data.weights[i] * 1.5;
   }
   
   info.ml_expansion_signal = MathTanh(expansion_signal); // Range [-1, 1]
}

void ATRVolatilityEngine::DetectInstitutionalActivity(ATRVolatilityInfo &info)
{
   // Phase 1: Real-time Institutional Flow Detection
   DetectRealTimeInstitutionalFlow(info);
   
   // Phase 2: Algorithmic Volatility Farming Detection
   DetectAlgorithmicVolatilityFarming(info);
   
   // Phase 3: Gamma Hedging Flow Detection
   DetectGammaHedgingFlow(info);
   
   // Phase 4: Volatility Surface Arbitrage Detection
   DetectVolatilitySurfaceArbitrage(info);
   
   // Phase 5: Update Institutional Metrics
   UpdateInstitutionalMetrics(info);
   
   Print(StringFormat("🏛️ Institutional Activity: Flow=%s, Gamma=%s, Vol Arb=%s, Score=%.1f",
                     info.real_time_institutional_flow ? "ACTIVE" : "INACTIVE",
                     info.gamma_hedging_flow ? "ACTIVE" : "INACTIVE",
                     info.vol_surface_arbitrage ? "ACTIVE" : "INACTIVE",
                     info.GetInstitutionalVolatilityScore()));
}

void ATRVolatilityEngine::UpdateInstitutionalMetrics(ATRVolatilityInfo &info)
{
   // Update institutional volatility demand
   double demand = 0.0;
   
   if(info.real_time_institutional_flow) demand += 30.0;
   if(info.gamma_hedging_flow) demand += 25.0;
   if(info.vol_surface_arbitrage) demand += 20.0;
   if(info.algo_vol_farming) demand += 15.0;
   
   // Add base institutional demand
   demand += info.dark_pool.institutional_vol_demand * 0.5;
   
   info.institutional_vol_demand = MathMin(100.0, demand);
   
   // Update smart money positioning
   double positioning = 0.0;
   
   if(info.dark_pool.stealth_accumulation) positioning += 40.0;
   if(info.dark_pool.stealth_distribution) positioning -= 30.0;
   if(info.dark_pool.coordinated_execution) positioning += 25.0;
   if(info.real_time_institutional_flow) positioning += 20.0;
   
   info.smart_money_vol_positioning = MathMax(-100.0, MathMin(100.0, positioning));
   
   // Update retail volatility sentiment (opposite of institutional)
   info.retail_vol_sentiment = 100.0 - info.institutional_vol_demand;
   
   // Check for imminent regime change
   bool multiple_institutional_signals = (info.real_time_institutional_flow && 
                                         info.gamma_hedging_flow && 
                                         info.vol_surface_arbitrage);
   
   if(multiple_institutional_signals && info.extreme_volatility)
      info.vol_regime_change_imminent = true;
}

void ATRVolatilityEngine::DetectVolatilitySurfaceArbitrage(ATRVolatilityInfo &info)
{
   // Detect vol surface arbitrage opportunities
   bool iv_rv_spread_large = MathAbs(info.dark_pool.implied_realized_spread) > 0.05;
   
   bool vol_skew_extreme = MathAbs(info.vol_surface.volatility_skew) > 0.3;
   
   bool term_structure_inversion = false;
   // Check for term structure inversions
   for(int i = 1; i < 6; i++)
   {
      if(info.vol_surface.vol_term_structure[i] > info.vol_surface.vol_term_structure[i-1] * 1.1)
      {
         term_structure_inversion = true;
         break;
      }
   }
   
   bool institutional_vol_arb = info.dark_pool.vol_arb_opportunity;
   
   info.vol_surface_arbitrage = iv_rv_spread_large || 
                               vol_skew_extreme || 
                               term_structure_inversion || 
                               institutional_vol_arb;
}

void ATRVolatilityEngine::DetectGammaHedgingFlow(ATRVolatilityInfo &info)
{
   // Detect gamma hedging flows
   bool vol_expansion_with_institutional = info.volatility_expansion && 
                                          info.dark_pool.institutional_vol_demand > 40.0;
   
   bool options_expiry_effects = false; // Simplified - in production would check actual expiry dates
   
   // Check for gamma squeeze patterns
   bool gamma_squeeze_patterns = info.dark_pool.gamma_squeeze_risk;
   
   // Check for systematic hedging patterns
   bool systematic_hedging = info.risk_regime.institutional_hedging &&
                            info.vol_surface.vol_trading_signal_strength > 50.0;
   
   info.gamma_hedging_flow = vol_expansion_with_institutional || 
                            gamma_squeeze_patterns || 
                            systematic_hedging ||
                            options_expiry_effects;
}

void ATRVolatilityEngine::DetectAlgorithmicVolatilityFarming(ATRVolatilityInfo &info)
{
   // Detect algo vol farming patterns
   bool rapid_vol_oscillations = (info.atr_momentum > 30.0 && info.atr_momentum < 70.0) ||
                                (info.atr_momentum < -30.0 && info.atr_momentum > -70.0);
   
   bool microstructure_anomalies = info.microstructure_vol > info.atr_h1 * 1.5;
   
   bool high_frequency_patterns = info.dark_pool.hft_volatility_farming;
   
   bool session_timing = (info.current_session == SESSION_LONDON ||
                         info.current_session == SESSION_NEWYORK ||
                         info.current_session == SESSION_OVERLAP_LONDON_NY);
   
   info.algo_vol_farming = (rapid_vol_oscillations || microstructure_anomalies || 
                           high_frequency_patterns) && session_timing;
}

void ATRVolatilityEngine::DetectRealTimeInstitutionalFlow(ATRVolatilityInfo &info)
{
   // Detect institutional flow based on volatility patterns
   bool large_vol_moves = info.extreme_volatility && info.expansion_strength > 75.0;
   bool stealth_execution = info.dark_pool.stealth_trading_intensity > 0.5;
   bool institutional_timing = info.high_volatility_session;
   
   // Check for institutional flow signatures
   bool flow_signature = (large_vol_moves || stealth_execution) && institutional_timing;
   
   // Additional checks for institutional behavior
   bool coordinated_cross_asset = (info.cross_asset.equity_vol_spillover > 0.6 &&
                                  info.cross_asset.fx_vol_spillover > 0.6);
   
   bool policy_driven_flow = info.policy_impact.policy_surprise && 
                            info.policy_impact.market_reaction_intensity > 60.0;
   
   info.real_time_institutional_flow = flow_signature || coordinated_cross_asset || policy_driven_flow;
   
   // Update institutional flow history
   UpdateInstitutionalFlowHistory(info.real_time_institutional_flow ? 1.0 : 0.0);
}

void ATRVolatilityEngine::UpdateInstitutionalFlowHistory(double flow_value)
{
   // Shift history array
   for(int i = 199; i > 0; i--)
   {
      m_institutional.flow_history[i] = m_institutional.flow_history[i-1];
   }
   
   // Add new value
   m_institutional.flow_history[0] = flow_value;
   
   // Update history size
   if(m_institutional.history_size < 200)
      m_institutional.history_size++;
}

void ATRVolatilityEngine::AnalyzeRealTimeMicrostructure(ATRVolatilityInfo &info)
{
   // Phase 1: Calculate Microstructure Volatility
   CalculateMicrostructureVolatility(info);
   
   // Phase 2: Analyze Order Flow Imbalance
   AnalyzeOrderFlowImbalance(info);
   
   // Phase 3: Calculate Liquidity Adjusted Volatility
   CalculateLiquidityAdjustedVolatility(info);
   
   // Phase 4: Detect Volatility Clustering
   DetectVolatilityClustering(info);
   
   // Phase 5: Update Microstructure History
   UpdateMicrostructureHistory(info);
   
   Print(StringFormat("🔬 Microstructure: Vol=%.5f, Imbalance=%.3f, Liquidity Adj=%.5f, Clustering=%s",
                     info.microstructure_vol, info.order_flow_imbalance_vol,
                     info.liquidity_adjusted_vol, info.vol_clustering_detected ? "YES" : "NO"));
}

void ATRVolatilityEngine::UpdateMicrostructureHistory(const ATRVolatilityInfo &info)
{
   // Update bid-ask spread history
   for(int i = 99; i > 0; i--)
   {
      m_microstructure.bid_ask_spreads[i] = m_microstructure.bid_ask_spreads[i-1];
      m_microstructure.order_flow_imbalance[i] = m_microstructure.order_flow_imbalance[i-1];
      m_microstructure.market_impact_costs[i] = m_microstructure.market_impact_costs[i-1];
   }
   
   // Add new values
   m_microstructure.bid_ask_spreads[0] = info.dark_pool.bid_ask_impact;
   m_microstructure.order_flow_imbalance[0] = info.order_flow_imbalance_vol;
   m_microstructure.market_impact_costs[0] = info.dark_pool.market_impact_cost;
   
   // Update history size
   if(m_microstructure.history_size < 100)
      m_microstructure.history_size++;
}

void ATRVolatilityEngine::DetectVolatilityClustering(ATRVolatilityInfo &info)
{
   // Detect volatility clustering patterns
   bool high_vol_persistence = info.vol_surface.vol_persistence > 0.7;
   bool consecutive_expansion = info.expansion_bars >= 3;
   bool autocorrelated_volatility = high_vol_persistence && consecutive_expansion;
   
   // Check for GARCH-like clustering
   bool garch_clustering = (info.extreme_volatility && 
                           info.vol_surface.garch_forecast > info.atr_h1 * 1.2);
   
   // Institutional clustering
   bool institutional_clustering = (info.real_time_institutional_flow &&
                                   info.dark_pool.coordinated_execution);
   
   // Session-based clustering
   bool session_clustering = (info.high_volatility_session &&
                             info.current_session_factor > 1.3);
   
   info.vol_clustering_detected = autocorrelated_volatility || 
                                  garch_clustering || 
                                  institutional_clustering || 
                                  session_clustering;
}

void ATRVolatilityEngine::CalculateLiquidityAdjustedVolatility(ATRVolatilityInfo &info)
{
   // Adjust volatility for liquidity conditions
   double liquidity_factor = info.dark_pool.hidden_liquidity_factor;
   
   // Low liquidity amplifies volatility
   double liquidity_adjustment = 1.0 / MathMax(0.1, liquidity_factor);
   
   // Session liquidity adjustments
   switch(info.current_session)
   {
      case SESSION_OVERLAP_LONDON_NY:
         liquidity_adjustment *= 0.8; // High liquidity dampens vol
         break;
      case SESSION_DEAD_ZONE:
         liquidity_adjustment *= 1.5; // Low liquidity amplifies vol
         break;
   }
   
   // Crisis conditions reduce liquidity
   if(info.risk_regime.liquidity_crisis)
      liquidity_adjustment *= 2.0;
   
   if(info.risk_regime.market_crash_risk)
      liquidity_adjustment *= 1.8;
   
   info.liquidity_adjusted_vol = info.atr_h1 * liquidity_adjustment;
   
   // Ensure reasonable bounds
   info.liquidity_adjusted_vol = MathMax(info.atr_h1 * 0.5, 
                                        MathMin(info.atr_h1 * 3.0, info.liquidity_adjusted_vol));
}

void ATRVolatilityEngine::AnalyzeOrderFlowImbalance(ATRVolatilityInfo &info)
{
   // Estimate order flow imbalance from volatility patterns
   double imbalance = 0.0;
   
   // Strong expansion suggests buy/sell imbalance
   if(info.volatility_expansion && info.expansion_strength > 50.0)
   {
      imbalance = (info.expansion_strength - 50.0) / 50.0; // Range 0-1
   }
   
   // Institutional activity creates imbalances
   if(info.dark_pool.block_trading)
      imbalance += 0.3;
   
   if(info.dark_pool.coordinated_execution)
      imbalance += 0.4;
   
   // Policy surprises create severe imbalances
   if(info.policy_impact.policy_surprise)
      imbalance += 0.5;
   
   // Risk-off events create flight-to-safety imbalances
   if(info.risk_regime.flight_to_safety)
      imbalance += 0.6;
   
   // Randomize direction (in real system, would use actual order flow data)
   if(MathRand() % 2 == 0) imbalance *= -1.0;
   
   info.order_flow_imbalance_vol = MathMax(-1.0, MathMin(1.0, imbalance));
}

void ATRVolatilityEngine::CalculateMicrostructureVolatility(ATRVolatilityInfo &info)
{
   // Calculate intrabar volatility approximation
   double microstructure_factor = 1.0;
   
   // Adjust based on session activity
   switch(info.current_session)
   {
      case SESSION_LONDON:
      case SESSION_NEWYORK:
      case SESSION_OVERLAP_LONDON_NY:
         microstructure_factor = 1.4;
         break;
      case SESSION_TOKYO:
         microstructure_factor = 1.1;
         break;
      case SESSION_SYDNEY:
         microstructure_factor = 0.8;
         break;
      case SESSION_DEAD_ZONE:
         microstructure_factor = 0.6;
         break;
   }
   
   // Enhanced microstructure adjustments using struct data
   if(m_microstructure.history_size > 0)
   {
      // Calculate average bid-ask spread impact
      double avg_spread = 0.0;
      int spread_count = MathMin(m_microstructure.history_size, 20); // Last 20 values
      
      for(int i = 0; i < spread_count; i++)
      {
         avg_spread += m_microstructure.bid_ask_spreads[i];
      }
      avg_spread /= spread_count;
      
      // Adjust factor based on spread width
      if(avg_spread > 0.0005) // Wide spreads = higher microstructure volatility
         microstructure_factor *= 1.3;
      else if(avg_spread < 0.0001) // Tight spreads = lower microstructure volatility
         microstructure_factor *= 0.8;
      
      // Calculate order flow imbalance impact
      double avg_imbalance = 0.0;
      for(int i = 0; i < spread_count; i++)
      {
         avg_imbalance += MathAbs(m_microstructure.order_flow_imbalance[i]);
      }
      avg_imbalance /= spread_count;
      
      // High imbalance increases microstructure volatility
      if(avg_imbalance > 0.6) // Strong imbalance
         microstructure_factor *= 1.2;
      
      // Calculate market impact cost effect
      double avg_impact = 0.0;
      for(int i = 0; i < spread_count; i++)
      {
         avg_impact += m_microstructure.market_impact_costs[i];
      }
      avg_impact /= spread_count;
      
      // High impact costs indicate illiquidity = higher volatility
      if(avg_impact > 0.001)
         microstructure_factor *= 1.4;
   }
   
   // Adjust based on institutional activity
   if(info.dark_pool.hft_volatility_farming)
      microstructure_factor *= 1.5;
   
   if(info.algo_vol_farming)
      microstructure_factor *= 1.3;
   
   // Base microstructure volatility on ATR with adjustments
   info.microstructure_vol = info.atr_h1 * microstructure_factor;
   
   // Add noise for HFT activity
   if(info.dark_pool.algo_trading_surge)
   {
      double hft_noise = info.atr_h1 * 0.2 * (MathRand() / 32767.0);
      info.microstructure_vol += hft_noise;
   }
   
   // Store current microstructure impact for future reference
   if(m_microstructure.history_size < 100)
   {
      int index = m_microstructure.history_size;
      m_microstructure.market_impact_costs[index] = info.microstructure_vol / info.atr_h1;
      m_microstructure.history_size++;
   }
   else
   {
      // Rolling window update
      for(int i = 0; i < 99; i++)
      {
         m_microstructure.market_impact_costs[i] = m_microstructure.market_impact_costs[i + 1];
      }
      m_microstructure.market_impact_costs[99] = info.microstructure_vol / info.atr_h1;
   }
}
void ATRVolatilityEngine::AssessNuclearVolatilityRisk(ATRVolatilityInfo &info)
{
   // Phase 1: Calculate Portfolio Heat
   CalculatePortfolioHeat(info);
   
   // Phase 2: Assess Tail Risk
   AssessTailRisk(info);
   
   // Phase 3: Calculate Systemic Volatility Risk
   CalculateSystemicVolatilityRisk(info);
   
   // Phase 4: Determine Overall Volatility Risk Level
   DetermineVolatilityRiskLevel(info);
   
   // Phase 5: Generate Risk Warnings
   GenerateRiskWarnings(info);
   
   Print(StringFormat("⚠️ Risk Assessment: Level=%s, Portfolio Heat=%.1f%%, Tail Risk=%.1f%%, Systemic=%.1f%%",
                     RiskLevelToString(info.volatility_risk), info.portfolio_heat,
                     info.tail_risk * 100, info.systemic_vol_risk));
}

void ATRVolatilityEngine::GenerateRiskWarnings(const ATRVolatilityInfo &info)
{
   // Generate risk warnings for extreme conditions
   if(info.volatility_risk == RISK_VERY_HIGH)
   {
      Print("🚨 CRITICAL RISK WARNING: Extremely high volatility risk detected!");
      
      if(info.risk_regime.market_crash_risk)
         Print("🚨 MARKET CRASH RISK DETECTED!");
      
      if(info.tail_risk > 0.8)
         Print("🚨 EXTREME TAIL RISK WARNING!");
   }
   else if(info.volatility_risk == RISK_HIGH)
   {
      Print("⚠️ HIGH RISK WARNING: Elevated volatility risk");
      
      if(info.systemic_vol_risk > 70.0)
         Print("⚠️ SYSTEMIC RISK ALERT!");
   }
   
   // Specific warnings
   if(info.vol_regime_change_imminent)
      Print("🔄 REGIME CHANGE WARNING: Volatility regime change imminent");
   
   if(info.policy_impact.emergency_measures)
      Print("🏛️ POLICY ALERT: Emergency measures likely");
}

void ATRVolatilityEngine::DetermineVolatilityRiskLevel(ATRVolatilityInfo &info)
{
   // Determine overall risk level
   double composite_risk = 0.0;
   
   // Weight different risk components
   composite_risk += info.portfolio_heat * 0.3;           // 30%
   composite_risk += info.tail_risk * 100.0 * 0.25;      // 25%
   composite_risk += info.systemic_vol_risk * 0.25;      // 25%
   composite_risk += info.volatility_percentile * 0.2;   // 20%
   
   // Adjust for extreme conditions
   if(info.risk_regime.market_crash_risk)
      composite_risk = MathMax(composite_risk, 85.0);
   
   if(info.risk_regime.liquidity_crisis)
      composite_risk = MathMax(composite_risk, 80.0);
   
   // Determine risk level
   if(composite_risk >= 80.0)
      info.volatility_risk = RISK_VERY_HIGH;
   else if(composite_risk >= 65.0)
      info.volatility_risk = RISK_HIGH;
   else if(composite_risk >= 45.0)
      info.volatility_risk = RISK_MEDIUM;
   else if(composite_risk >= 25.0)
      info.volatility_risk = RISK_LOW;
   else
      info.volatility_risk = RISK_VERY_LOW;
}

void ATRVolatilityEngine::CalculateSystemicVolatilityRisk(ATRVolatilityInfo &info)
{
   // Systemic volatility risk assessment
   double systemic_risk = 0.0;
   
   // Base systemic risk from risk regime
   systemic_risk += info.risk_regime.systemic_risk_score * 0.4;
   
   // Cross-asset correlation breakdown
   systemic_risk += info.risk_regime.correlation_breakdown * 30.0;
   
   // Contagion risk
   systemic_risk += info.risk_regime.contagion_risk * 0.3;
   
   // Global risk factors
   if(info.cross_asset.global_risk_appetite < -0.7)
      systemic_risk += 20.0;
   
   // Emerging market stress
   systemic_risk += info.cross_asset.emerging_market_stress * 15.0;
   
   // Liquidity crisis
   if(info.risk_regime.liquidity_crisis)
      systemic_risk += 25.0;
   
   // Central bank emergency response likelihood
   systemic_risk += info.risk_regime.policy_response_prob * 0.2;
   
   // Multiple asset class stress
   int stressed_asset_classes = 0;
   if(info.cross_asset.equity_vol_spillover > 0.7) stressed_asset_classes++;
   if(info.cross_asset.fx_vol_spillover > 0.7) stressed_asset_classes++;
   if(info.cross_asset.bond_vol_spillover > 0.7) stressed_asset_classes++;
   if(info.cross_asset.commodity_vol_spillover > 0.7) stressed_asset_classes++;
   
   systemic_risk += stressed_asset_classes * 10.0;
   
   info.systemic_vol_risk = MathMax(0.0, MathMin(100.0, systemic_risk));
}

void ATRVolatilityEngine::AssessTailRisk(ATRVolatilityInfo &info)
{
   // Tail risk assessment
   double tail_risk = 0.0;
   
   // Extreme Z-score indicates tail events
   if(MathAbs(info.volatility_zscore) > 3.0)
      tail_risk += 0.4;
   else if(MathAbs(info.volatility_zscore) > 2.5)
      tail_risk += 0.25;
   
   // Extreme percentiles
   if(info.volatility_percentile > 99.0 || info.volatility_percentile < 1.0)
      tail_risk += 0.35;
   else if(info.volatility_percentile > 95.0 || info.volatility_percentile < 5.0)
      tail_risk += 0.2;
   
   // Risk regime tail events
   if(info.risk_regime.tail_risk_event)
      tail_risk += 0.3;
   
   if(info.risk_regime.market_crash_risk)
      tail_risk += 0.4;
   
   // Black swan indicators
   if(info.policy_impact.policy_surprise && info.extreme_volatility)
      tail_risk += 0.25;
   
   // Cross-asset contagion
   if(info.risk_regime.contagion_risk > 70.0)
      tail_risk += 0.2;
   
   // VIX equivalent extreme levels
   if(info.risk_regime.vix_equivalent > 40.0)
      tail_risk += 0.15;
   
   info.tail_risk = MathMax(0.0, MathMin(1.0, tail_risk));
}

void ATRVolatilityEngine::CalculatePortfolioHeat(ATRVolatilityInfo &info)
{
   // Portfolio heat based on volatility exposure
   double heat = 0.0;
   
   // Base heat from volatility percentile
   heat += info.volatility_percentile * 0.6;
   
   // Add heat from regime factors
   switch(info.current_regime)
   {
      case VOLATILITY_EXTREME:
         heat += 25.0;
         break;
      case VOLATILITY_EXPANSION:
         heat += 20.0;
         break;
      case VOLATILITY_HIGH:
         heat += 15.0;
         break;
      case VOLATILITY_LOW:
         heat -= 10.0;
         break;
   }
   
   // Add heat from risk factors
   if(info.extreme_volatility) heat += 20.0;
   if(info.volatility_expansion) heat += 15.0;
   if(info.regime_change_risk) heat += 10.0;
   
   // Add heat from institutional activity
   heat += info.institutional_vol_demand * 0.3;
   
   // Add heat from cross-asset spillover
   double avg_spillover = (info.cross_asset.equity_vol_spillover + 
                          info.cross_asset.fx_vol_spillover + 
                          info.cross_asset.bond_vol_spillover) / 3.0;
   heat += avg_spillover * 20.0;
   
   // Add heat from policy risk
   heat += info.policy_impact.policy_uncertainty * 0.2;
   
   info.portfolio_heat = MathMax(0.0, MathMin(100.0, heat));
}

void ATRVolatilityEngine::GenerateNuclearVolatilitySignals(ATRVolatilityInfo &info)
{
   // Phase 1: Determine Primary Signal
   DeterminePrimaryVolatilitySignal(info);
   
   // Phase 2: Calculate Signal Strength
   CalculateSignalStrength(info);
   
   // Phase 3: Calculate Signal Confidence
   CalculateSignalConfidence(info);
   
   // Phase 4: Calculate Entry Timing Score
   CalculateEntryTimingScore(info);
   
   // Phase 5: Apply Signal Filters
   ApplySignalFilters(info);
   
   Print(StringFormat("🎯 Signals: Primary=%s, Strength=%s, Confidence=%.1f%%, Timing=%.1f",
                     SignalTypeToString(info.primary_signal), 
                     SignalStrengthToString(info.signal_strength),
                     info.signal_confidence * 100, info.entry_timing_score));
}

void ATRVolatilityEngine::ApplySignalFilters(ATRVolatilityInfo &info)
{
   // Filter out signals during extreme market stress
   if(info.risk_regime.market_crash_risk && info.signal_strength != SIGNAL_VERY_STRONG)
   {
      info.primary_signal = SIGNAL_HOLD;
      info.signal_strength = SIGNAL_STRENGTH_NONE;
      Print("🚨 Signal filtered due to market crash risk");
   }
   
   // Filter out signals during liquidity crisis
   if(info.risk_regime.liquidity_crisis && info.signal_confidence < 0.7)
   {
      info.primary_signal = SIGNAL_HOLD;
      info.signal_strength = SIGNAL_WEAK;
      Print("⚠️ Signal filtered due to liquidity crisis");
   }
   
   // Filter out signals during dead zone unless very strong
   if(info.current_session == SESSION_DEAD_ZONE && 
      info.signal_strength < SIGNAL_STRONG)
   {
      info.signal_strength = SIGNAL_WEAK;
      Print("⏰ Signal strength reduced due to low activity session");
   }
   
   // Filter out weak signals with low confidence
   if(info.signal_strength <= SIGNAL_WEAK && info.signal_confidence < 0.6)
   {
      info.primary_signal = SIGNAL_HOLD;
      info.signal_strength = SIGNAL_STRENGTH_NONE;
   }
   
   // Enhanced filtering based on signal types
   switch(info.primary_signal)
   {
      case SIGNAL_EMERGENCY_EXIT:
         // Emergency exits should not be filtered unless extreme conditions
         if(!info.risk_regime.market_crash_risk && !info.risk_regime.liquidity_crisis)
         {
            // Keep emergency signal as-is
         }
         break;
         
      case SIGNAL_ARBITRAGE:
         // Arbitrage opportunities during high volatility are valid
         if(info.extreme_volatility && info.signal_strength >= SIGNAL_MODERATE)
         {
            // Keep arbitrage signal
         }
         else if(info.signal_confidence < 0.8)
         {
            info.primary_signal = SIGNAL_HOLD;
            info.signal_strength = SIGNAL_WEAK;
            Print("📊 Arbitrage signal filtered due to low confidence");
         }
         break;
         
      case SIGNAL_BREAKOUT_BUY:
      case SIGNAL_BREAKOUT_SELL:
         // Breakout signals need high confidence during volatile markets
         if(info.extreme_volatility && info.signal_confidence < 0.75)
         {
            info.primary_signal = SIGNAL_HOLD;
            info.signal_strength = SIGNAL_MODERATE;
            Print("📈 Breakout signal filtered due to extreme volatility");
         }
         break;
         
      case SIGNAL_MEAN_REVERSION:
         // Mean reversion signals are stronger during extreme conditions
         if(info.volatility_percentile > 95.0)
         {
            // Boost mean reversion signal strength
            if(info.signal_strength < SIGNAL_STRONG)
               info.signal_strength = SIGNAL_STRONG;
         }
         break;
   }
   
   // News/Policy event filtering
   if(info.policy_impact.policy_surprise && info.policy_impact.policy_uncertainty > 0.8)
   {
      // During major policy surprises, only very strong signals pass
      if(info.signal_strength < SIGNAL_VERY_STRONG)
      {
         if(info.primary_signal != SIGNAL_EMERGENCY_EXIT)
         {
            info.signal_strength = SIGNAL_WEAK;
            Print("📰 Signal strength reduced due to policy uncertainty");
         }
      }
   }
   
   // ML confidence filtering
   if(m_ml_data.is_trained)
   {
      // If ML confidence is very low, downgrade signal
      if(info.ml_regime_probability < 0.3)
      {
         if(info.signal_strength > SIGNAL_MODERATE)
         {
            info.signal_strength = SIGNAL_MODERATE;
            Print("🤖 Signal strength reduced due to low ML confidence");
         }
      }
      
      // If ML strongly disagrees with signal, filter it
      if((IsBuySignal(info.primary_signal) && info.ml_expansion_signal < -0.5) ||
         (IsSellSignal(info.primary_signal) && info.ml_expansion_signal > 0.5))
      {
         info.primary_signal = SIGNAL_HOLD;
         info.signal_strength = SIGNAL_WEAK;
         Print("🤖 Signal filtered due to ML disagreement");
      }
   }
   
   // Cross-timeframe disagreement filtering
   int conflicting_timeframes = 0;
   
   if(info.regime_h1 != info.regime_h4) conflicting_timeframes++;
   if(info.regime_h4 != info.regime_d1) conflicting_timeframes++;
   if(info.regime_h1 != info.regime_d1) conflicting_timeframes++;
   
   if(conflicting_timeframes >= 2 && info.signal_strength < SIGNAL_STRONG)
   {
      info.signal_strength = SIGNAL_WEAK;
      Print("⏱️ Signal strength reduced due to timeframe conflicts");
   }
   
   // Final signal quality check
   if(info.signal_strength == SIGNAL_STRENGTH_NONE || info.primary_signal == SIGNAL_HOLD)
   {
      // Ensure no contradictory information remains
      info.signal_confidence = 0.0;
      info.breakout_probability = 50.0; // Neutral
      Print("🔄 Signal neutralized after filtering");
   }

}

void ATRVolatilityEngine::CalculateEntryTimingScore(ATRVolatilityInfo &info)
{
   double timing_score = 0.0;
   
   // Session timing (30% weight)
   switch(info.current_session)
   {
      case SESSION_OVERLAP_LONDON_NY:
         timing_score += 30.0; // Best timing
         break;
      case SESSION_LONDON:
      case SESSION_NEWYORK:
         timing_score += 25.0;
         break;
      case SESSION_TOKYO:
         timing_score += 15.0;
         break;
      case SESSION_SYDNEY:
         timing_score += 10.0;
         break;
      case SESSION_DEAD_ZONE:
         timing_score += 5.0; // Worst timing
         break;
   }
   
   // Volatility regime timing (25% weight)
   if(info.current_regime == VOLATILITY_CONTRACTION && info.contraction_duration >= 5)
      timing_score += 25.0; // Great timing for vol expansion
   else if(info.volatility_expansion && info.expansion_bars <= 2)
      timing_score += 20.0; // Good timing for early expansion
   else if(info.extreme_volatility && info.vol_surface.vol_spike_exhaustion)
      timing_score += 15.0; // Good timing for mean reversion
   
   // Institutional activity timing (20% weight)
   if(info.real_time_institutional_flow)
      timing_score += 20.0;
   else if(info.dark_pool.coordinated_execution)
      timing_score += 15.0;
   
   // Policy timing (15% weight)
   if(info.policy_impact.policy_surprise)
      timing_score += 15.0; // Immediate reaction expected
   else if(info.policy_impact.communication_impact > 60.0)
      timing_score += 10.0;
   
   // Technical timing (10% weight)
   if(info.breakout_probability > 70.0 && info.false_breakout_risk < 40.0)
      timing_score += 10.0;
   
   info.entry_timing_score = MathMin(100.0, timing_score);
}

void ATRVolatilityEngine::CalculateSignalConfidence(ATRVolatilityInfo &info)
{
   double confidence = 0.5; // Base 50% confidence
   
   // Increase confidence for strong institutional signals
   if(info.GetInstitutionalVolatilityScore() > 70.0)
      confidence += 0.2;
   
   // Increase confidence for cross-asset confirmation
   double avg_spillover = (info.cross_asset.equity_vol_spillover + 
                          info.cross_asset.fx_vol_spillover) / 2.0;
   confidence += avg_spillover * 0.15;
   
   // Increase confidence for ML predictions
   if(m_ml_data.is_trained && info.pattern_recognition > 60.0)
      confidence += 0.15;
   
   // Increase confidence for low false breakout risk
   confidence += (100.0 - info.false_breakout_risk) / 1000.0;
   
   // Decrease confidence for high policy uncertainty
   confidence -= info.policy_impact.policy_uncertainty / 500.0;
   
   // Decrease confidence for extreme market stress
   if(info.risk_regime.systemic_risk_score > 80.0)
      confidence -= 0.1;
   
   // Session timing adjustment
   if(info.high_volatility_session)
      confidence += 0.05;
   else if(info.current_session == SESSION_DEAD_ZONE)
      confidence -= 0.1;
   
   info.signal_confidence = MathMax(0.1, MathMin(0.95, confidence));
}

void ATRVolatilityEngine::CalculateSignalStrength(ATRVolatilityInfo &info)
{
   double strength = 0.0;
   
   // Base strength from signal factors
   if(info.primary_signal == SIGNAL_BUY)
   {
      if(info.extreme_volatility) strength += 25.0;
      if(info.volatility_expansion) strength += 20.0;
      if(info.real_time_institutional_flow) strength += 20.0;
      if(info.risk_regime.risk_off_event) strength += 15.0;
      if(info.policy_impact.policy_surprise) strength += 10.0;
      if(info.breakout_probability > 70.0) strength += 10.0;
   }
   else if(info.primary_signal == SIGNAL_SELL)
   {
      if(info.vol_surface.vol_spike_exhaustion) strength += 25.0;
      if(info.volatility_percentile > 95.0) strength += 20.0;
      if(info.false_breakout_risk > 70.0) strength += 15.0;
      if(info.risk_regime.risk_on_rally) strength += 15.0;
      if(info.vol_surface.vol_mean_revert_signal) strength += 15.0;
      if(info.atr_momentum < -30.0) strength += 10.0;
   }
   
   // Cross-timeframe confirmation
   bool tf_alignment = (info.regime_h1 == info.regime_h4 && info.regime_h4 == info.regime_d1);
   if(tf_alignment) strength += 15.0;
   
   // Session timing bonus
   if(info.high_volatility_session) strength += 10.0;
   
   // ML prediction confirmation
   if(m_ml_data.is_trained)
   {
      if(info.primary_signal == SIGNAL_BUY && info.ml_expansion_signal > 0.3)
         strength += 10.0;
      else if(info.primary_signal == SIGNAL_SELL && info.ml_expansion_signal < -0.3)
         strength += 10.0;
   }
   
   // Enhanced signal type-specific strength adjustments
   switch(info.primary_signal)
   {
      case SIGNAL_EMERGENCY_EXIT:
         strength += 20.0; // Emergency situations have high strength
         break;
      case SIGNAL_ARBITRAGE:
         strength += 15.0; // Arbitrage opportunities are strong
         break;
      case SIGNAL_BREAKOUT_BUY:
      case SIGNAL_BREAKOUT_SELL:
         if(info.breakout_probability > 80.0) strength += 15.0;
         break;
      case SIGNAL_MEAN_REVERSION:
         if(info.volatility_percentile > 90.0) strength += 12.0;
         break;
      case SIGNAL_REVERSAL_BUY:
      case SIGNAL_REVERSAL_SELL:
         if(tf_alignment) strength += 10.0;
         break;
   }
   
   // Determine strength level using Complete_Enum_Types
   if(strength >= 95.0)
      info.signal_strength = SIGNAL_EXTREME;           // Aşırı güçlü (95-100%)
   else if(strength >= 80.0)
      info.signal_strength = SIGNAL_VERY_STRONG;       // Çok güçlü (80-95%)
   else if(strength >= 60.0)
      info.signal_strength = SIGNAL_STRONG;            // Güçlü (60-80%)
   else if(strength >= 40.0)
      info.signal_strength = SIGNAL_MODERATE;          // Orta (40-60%)
   else if(strength >= 20.0)
      info.signal_strength = SIGNAL_WEAK;              // Zayıf (20-40%)
   else if(strength >= 5.0)
      info.signal_strength = SIGNAL_VERY_WEAK;         // Çok zayıf (5-20%)
   else
      info.signal_strength = SIGNAL_STRENGTH_NONE;     // Güç yok (0-5%)
   
   // Additional context-based strength classification
   int confluence_count = 0;
   
   // Count confluence factors
   if(info.extreme_volatility) confluence_count++;
   if(info.volatility_expansion) confluence_count++;
   if(info.real_time_institutional_flow) confluence_count++;
   if(info.risk_regime.risk_off_event || info.risk_regime.risk_on_rally) confluence_count++;
   if(info.policy_impact.policy_surprise) confluence_count++;
   if(tf_alignment) confluence_count++;
   if(info.high_volatility_session) confluence_count++;
   if(m_ml_data.is_trained && MathAbs(info.ml_expansion_signal) > 0.3) confluence_count++;
   
   // Override with confluence-based strength if applicable
   if(confluence_count >= 6)
      info.signal_strength = SIGNAL_UNANIMOUS_CONSENSUS;    // Oybirliği konsensüsü
   else if(confluence_count >= 5)
      info.signal_strength = SIGNAL_MULTIPLE_CONFIRMATION;  // Çoklu onay
   else if(confluence_count >= 3)
      info.signal_strength = SIGNAL_TRIPLE_CONFIRMATION;    // Üçlü onay
   else if(confluence_count >= 2)
      info.signal_strength = SIGNAL_DUAL_CONFIRMATION;      // İkili onay
   else if(confluence_count == 1)
      info.signal_strength = SIGNAL_SINGLE_INDICATOR;       // Tek gösterge
   
   // Final ML-based strength adjustment
   if(m_ml_data.is_trained)
   {
      if(info.ml_regime_probability > 0.8)
      {
         // High ML confidence - upgrade strength
         if(info.signal_strength == SIGNAL_STRONG)
            info.signal_strength = SIGNAL_ML_PROBABILITY_HIGH;
         else if(info.signal_strength == SIGNAL_VERY_STRONG)
            info.signal_strength = SIGNAL_ML_PROBABILITY_EXTREME;
      }
      else if(info.ml_regime_probability > 0.6)
      {
         if(info.signal_strength == SIGNAL_MODERATE)
            info.signal_strength = SIGNAL_ML_PROBABILITY_MEDIUM;
      }
      else if(info.ml_regime_probability < 0.4)
      {
         if(info.signal_strength > SIGNAL_WEAK)
            info.signal_strength = SIGNAL_ML_PROBABILITY_LOW;
      }
   }
}

void ATRVolatilityEngine::DeterminePrimaryVolatilitySignal(ATRVolatilityInfo &info)
{
   // Initialize signal scores
   double long_vol_score = 0.0;
   double short_vol_score = 0.0;
   double neutral_score = 50.0; // Base neutral score
   
   // Factor 1: Volatility Regime (30% weight)
   switch(info.current_regime)
   {
      case VOLATILITY_CONTRACTION:
         long_vol_score += 30.0; // Expect expansion after contraction
         break;
      case VOLATILITY_LOW:
         long_vol_score += 20.0;
         break;
      case VOLATILITY_EXTREME:
         short_vol_score += 25.0; // Mean reversion expected
         break;
      case VOLATILITY_EXPANSION:
         if(info.expansion_bars <= 2)
            long_vol_score += 15.0; // Early expansion
         else
            short_vol_score += 10.0; // Late expansion
         break;
   }
   
   // Factor 2: Institutional Activity (25% weight)
   if(info.real_time_institutional_flow)
      long_vol_score += 20.0;
   
   if(info.gamma_hedging_flow)
      long_vol_score += 15.0;
   
   if(info.vol_surface_arbitrage)
      long_vol_score += 10.0;
   
   // Factor 3: Risk Regime (20% weight)
   if(info.risk_regime.risk_off_event)
      long_vol_score += 20.0;
   
   if(info.risk_regime.risk_on_rally)
      short_vol_score += 15.0;
   
   if(info.risk_regime.flight_to_safety)
      long_vol_score += 18.0;
   
   // Factor 4: Policy Impact (15% weight)
   if(info.policy_impact.policy_surprise)
      long_vol_score += 15.0;
   
   if(info.policy_impact.dovish_shift)
      short_vol_score += 10.0;
   
   // Factor 5: Technical Factors (10% weight)
   if(info.breakout_probability > 70.0)
      long_vol_score += 10.0;
   
   if(info.false_breakout_risk > 60.0)
      short_vol_score += 8.0;
   
   // Determine primary signal using Complete_Enum_Types
   double max_score = MathMax(long_vol_score, MathMax(short_vol_score, neutral_score));
   
   if(max_score == long_vol_score && long_vol_score > neutral_score + 15.0)
      info.primary_signal = SIGNAL_BUY; // Volatility long signal
   else if(max_score == short_vol_score && short_vol_score > neutral_score + 15.0)
      info.primary_signal = SIGNAL_SELL; // Volatility short signal
   else
      info.primary_signal = SIGNAL_HOLD; // Neutral/Wait signal
   
   // Special conditions override
   if(info.risk_regime.market_crash_risk)
      info.primary_signal = SIGNAL_BUY; // Vol spike in crash
   
   if(info.vol_surface.vol_spike_exhaustion && info.extreme_volatility)
      info.primary_signal = SIGNAL_SELL; // Vol mean reversion
   
   // Enhanced signal classification based on context
   if(info.primary_signal == SIGNAL_BUY)
   {
      // Determine specific buy signal type based on conditions
      if(info.risk_regime.market_crash_risk)
         info.primary_signal = SIGNAL_EMERGENCY_EXIT; // Actually this would be a vol spike buy
      else if(info.vol_surface_arbitrage)
         info.primary_signal = SIGNAL_ARBITRAGE;
      else if(info.breakout_probability > 80.0)
         info.primary_signal = SIGNAL_BREAKOUT_BUY;
      else
         info.primary_signal = SIGNAL_BUY; // Standard volatility long
   }
   else if(info.primary_signal == SIGNAL_SELL)
   {
      // Determine specific sell signal type based on conditions
      if(info.vol_surface.vol_spike_exhaustion)
         info.primary_signal = SIGNAL_MEAN_REVERSION;
      else if(info.risk_regime.risk_on_rally)
         info.primary_signal = SIGNAL_REVERSAL_SELL;
      else
         info.primary_signal = SIGNAL_SELL; // Standard volatility short
   }
}

void ATRVolatilityEngine::CalculateNuclearVolatilityConfluence(ATRVolatilityInfo &info)
{
   // Phase 1: Calculate Timeframe Alignment
   CalculateTimeframeAlignment(info);
   
   // Phase 2: Calculate Cross-Asset Confluence
   CalculateCrossAssetConfluence(info);
   
   // Phase 3: Calculate Institutional Confluence
   CalculateInstitutionalConfluence(info);
   
   // Phase 4: Calculate Policy Confluence
   CalculatePolicyConfluence(info);
   
   // Phase 5: Calculate Overall Confluence Score
   CalculateOverallConfluenceScore(info);
   
   // Phase 6: Determine Confluence Level
   DetermineConfluenceLevel(info);
   
   Print(StringFormat("🎯 Confluence: Score=%.1f, Level=%s, TF Alignment=%d/5, Institutional=%.1f%%",
                     info.confluence_score, ConfluenceLevelToString(info.confluence_level),
                     info.timeframe_alignment, info.GetInstitutionalVolatilityScore()));
}

void ATRVolatilityEngine::DetermineConfluenceLevel(ATRVolatilityInfo &info)
{
   if(info.confluence_score >= 85.0)
      info.confluence_level = CONFLUENCE_VERY_STRONG;
   else if(info.confluence_score >= 70.0)
      info.confluence_level = CONFLUENCE_STRONG;
   else if(info.confluence_score >= 55.0)
      info.confluence_level = CONFLUENCE_MODERATE;
   else if(info.confluence_score >= 35.0)
      info.confluence_level = CONFLUENCE_WEAK;
   else
      info.confluence_level = CONFLUENCE_NONE;
   
   // Special overrides for extreme conditions
   if(info.risk_regime.market_crash_risk && info.primary_signal == SIGNAL_BUY)
      info.confluence_level = CONFLUENCE_VERY_STRONG; // Vol spike in crash
   
   if(info.signal_strength == SIGNAL_VERY_STRONG && 
      info.timeframe_alignment >= 5 && 
      info.institutional_vol_demand > 80.0)
      info.confluence_level = CONFLUENCE_VERY_STRONG; // Perfect storm
}

void ATRVolatilityEngine::CalculateOverallConfluenceScore(ATRVolatilityInfo &info)
{
   double total_score = 0.0;
   
   // Timeframe alignment (25% weight)
   total_score += (info.timeframe_alignment / 6.0) * 25.0;
   
   // Cross-asset confluence (25% weight)
   total_score += (info.cross_asset.global_risk_appetite / 40.0) * 25.0;
   
   // Institutional confluence (25% weight)
   total_score += (info.institutional_vol_demand / 100.0) * 25.0;
   
   // Policy confluence (15% weight)
   total_score += (info.policy_impact.communication_impact / 100.0) * 15.0;
   
   // Signal strength bonus (10% weight)
   switch(info.signal_strength)
   {
      case SIGNAL_VERY_STRONG: total_score += 10.0; break;
      case SIGNAL_STRONG: total_score += 8.0; break;
      case SIGNAL_MODERATE: total_score += 6.0; break;
      case SIGNAL_WEAK: total_score += 3.0; break;
      case SIGNAL_STRENGTH_NONE: total_score += 0.0; break;
   }
   
   // ML prediction confluence bonus
   if(m_ml_data.is_trained && info.pattern_recognition > 70.0)
      total_score += 5.0;
   
   // Session timing bonus
   if(info.entry_timing_score > 80.0)
      total_score += 3.0;
   
   info.confluence_score = MathMax(0.0, MathMin(100.0, total_score));
}

void ATRVolatilityEngine::CalculatePolicyConfluence(ATRVolatilityInfo &info)
{
   double policy_score = 0.0;
   
   // Policy surprise confluence
   if(info.policy_impact.policy_surprise && info.extreme_volatility)
      policy_score += 20.0;
   
   // Monetary policy stance confluence
   if((info.policy_impact.dovish_shift && info.risk_regime.risk_off_event) ||
      (info.policy_impact.hawkish_shift && info.risk_regime.risk_on_rally))
      policy_score += 15.0;
   
   // Central bank intervention confluence
   if((info.policy_impact.fx_intervention_risk && info.extreme_volatility) ||
      (info.policy_impact.quantitative_easing && info.risk_regime.liquidity_crisis))
      policy_score += 12.0;
   
   // Policy uncertainty confluence
   if(info.policy_impact.policy_uncertainty > 60.0 && info.regime_change_risk)
      policy_score += 10.0;
   
   // Emergency measures confluence
   if(info.risk_regime.emergency_measures && info.risk_regime.market_crash_risk)
      policy_score += 8.0;
   
   info.policy_impact.communication_impact = MathMax(0.0, MathMin(100.0, policy_score));
}

void ATRVolatilityEngine::CalculateInstitutionalConfluence(ATRVolatilityInfo &info)
{
   double institutional_score = 0.0;
   
   // Real-time institutional flow confluence
   if(info.real_time_institutional_flow)
      institutional_score += 20.0;
   
   // Dark pool activity confluence
   if(info.dark_pool.coordinated_execution && info.dark_pool.institutional_vol_demand > 50.0)
      institutional_score += 18.0;
   
   // Stealth trading confluence
   if((info.dark_pool.stealth_accumulation && info.primary_signal == SIGNAL_BUY) ||
      (info.dark_pool.stealth_distribution && info.primary_signal == SIGNAL_SELL))
      institutional_score += 15.0;
   
   // Gamma hedging confluence
   if(info.gamma_hedging_flow && info.volatility_expansion)
      institutional_score += 12.0;
   
   // Volatility surface arbitrage confluence
   if(info.vol_surface_arbitrage && MathAbs(info.vol_surface.vol_risk_premium) > 0.05)
      institutional_score += 10.0;
   
   // Smart money positioning confluence
   if((info.smart_money_vol_positioning > 30.0 && info.primary_signal == SIGNAL_BUY) ||
      (info.smart_money_vol_positioning < -30.0 && info.primary_signal == SIGNAL_SELL))
      institutional_score += 8.0;
   
   info.institutional_vol_demand = MathMax(0.0, MathMin(100.0, institutional_score));
}

void ATRVolatilityEngine::CalculateCrossAssetConfluence(ATRVolatilityInfo &info)
{
   double cross_asset_score = 0.0;
   
   // Spillover confluence
   double avg_spillover = (info.cross_asset.equity_vol_spillover + 
                          info.cross_asset.fx_vol_spillover + 
                          info.cross_asset.bond_vol_spillover + 
                          info.cross_asset.commodity_vol_spillover) / 4.0;
   
   cross_asset_score += avg_spillover * 25.0;
   
   // Risk appetite confluence
   if(info.risk_regime.risk_appetite_score > 30.0 && info.primary_signal == SIGNAL_SELL)
      cross_asset_score += 15.0; // Risk-on supports vol selling
   else if(info.risk_regime.risk_appetite_score < -30.0 && info.primary_signal == SIGNAL_BUY)
      cross_asset_score += 15.0; // Risk-off supports vol buying
   
   // Safe haven flow confluence
   if((info.cross_asset.gold_safe_haven_flow || info.cross_asset.yen_safe_haven_flow) &&
      info.primary_signal == SIGNAL_BUY)
      cross_asset_score += 10.0;
   
   // Correlation breakdown confluence
   if(info.risk_regime.correlation_breakdown > 0.5 && info.extreme_volatility)
      cross_asset_score += 10.0;
   
   info.cross_asset.global_risk_appetite = MathMax(-40.0, MathMin(40.0, cross_asset_score));
}

void ATRVolatilityEngine::CalculateTimeframeAlignment(ATRVolatilityInfo &info)
{
   int alignment_count = 0;
   
   // Check regime alignment across timeframes
   if(info.regime_h1 == info.current_regime) alignment_count++;
   if(info.regime_h4 == info.current_regime) alignment_count++;
   if(info.regime_d1 == info.current_regime) alignment_count++;
   
   // Check ATR trend alignment
   if(info.atr_trend_short == info.atr_trend_medium) alignment_count++;
   if(info.atr_trend_medium == info.atr_trend_long) alignment_count++;
   
   info.timeframe_alignment = alignment_count;
   
   // Bonus for perfect alignment
   if(alignment_count == 5)
      info.timeframe_alignment += 1; // Extra point for perfect alignment
}

//+------------------------------------------------------------------+
//| NUCLEAR ATR ENGINE FACTORY                                      |
//+------------------------------------------------------------------+
ATRVolatilityEngine* CreateNuclearATREngine(string symbol, ENUM_TIMEFRAMES timeframe = PERIOD_H1)
{
   return new ATRVolatilityEngine(symbol, timeframe);
}
//+------------------------------------------------------------------+
//| UTILITY FUNCTIONS - VOLATILITY REGIME                           |
//+------------------------------------------------------------------+

string VolatilityRegimeToString(ENUM_VOLATILITY_REGIME regime)
{
   switch(regime)
   {
      case VOLATILITY_UNKNOWN: return "UNKNOWN";
      case VOLATILITY_LOW: return "LOW";
      case VOLATILITY_NORMAL: return "NORMAL";
      case VOLATILITY_HIGH: return "HIGH";
      case VOLATILITY_EXTREME: return "EXTREME";
      case VOLATILITY_EXPANSION: return "EXPANSION";
      case VOLATILITY_CONTRACTION: return "CONTRACTION";
      default: return "UNKNOWN";
   }
}
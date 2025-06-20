//+------------------------------------------------------------------+
//| Complete_Enum_Types.mqh - Genişletilmiş Sinyal ve Trend Enumları |
//| Machine Learning ve Adaptasyon Destekli                          |
//| ISignalProvider Uyumlu - Confluence Destekli Tam Sürüm           |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| Sinyal Türleri                                                   |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_TYPE
{
   SIGNAL_NONE = 0,              // Sinyal yok
   
   // Temel sinyal türleri
   SIGNAL_BUY = 1,               // Alış sinyali
   SIGNAL_SELL = 2,              // Satış sinyali
   SIGNAL_HOLD = 3,              // Bekle sinyali
   SIGNAL_CLOSE = 4,             // Kapat sinyali
   
   // Sinyal kaynağına göre türler
   SIGNAL_TECHNICAL = 10,        // Teknik analiz sinyali
   SIGNAL_FUNDAMENTAL = 11,      // Fundamental analiz sinyali
   SIGNAL_SENTIMENT = 12,        // Sentiment analiz sinyali
   SIGNAL_ML_BASED = 13,         // ML bazlı sinyal
   SIGNAL_HYBRID = 14,           // Hibrit sinyal
   SIGNAL_QUANTITATIVE = 15,     // Kantitatif sinyal
   SIGNAL_NEWS_BASED = 16,       // Haber bazlı sinyal
   SIGNAL_CORRELATION = 17,      // Korelasyon sinyali
   SIGNAL_ARBITRAGE = 18,        // Arbitraj sinyali
   SIGNAL_MEAN_REVERSION = 19,   // Ortalamaya dönüş sinyali
   
   // Spesifik teknik sinyal türleri
   SIGNAL_BREAKOUT_BUY = 20,     // Kırılım alış
   SIGNAL_BREAKOUT_SELL = 21,    // Kırılım satış
   SIGNAL_PULLBACK_BUY = 22,     // Geri çekilme alış
   SIGNAL_PULLBACK_SELL = 23,    // Geri çekilme satış
   SIGNAL_REVERSAL_BUY = 24,     // Dönüş alış
   SIGNAL_REVERSAL_SELL = 25,    // Dönüş satış
   SIGNAL_CONTINUATION_BUY = 26, // Devam alış
   SIGNAL_CONTINUATION_SELL = 27, // Devam satış
   SIGNAL_DIVERGENCE_BUY = 28,   // Divergence alış
   SIGNAL_DIVERGENCE_SELL = 29,  // Divergence satış
   
   // Risk seviyesine göre sinyaller
   SIGNAL_CONSERVATIVE_BUY = 30, // Muhafazakar alış
   SIGNAL_CONSERVATIVE_SELL = 31, // Muhafazakar satış
   SIGNAL_MODERATE_BUY = 32,     // Orta risk alış
   SIGNAL_MODERATE_SELL = 33,    // Orta risk satış
   SIGNAL_AGGRESSIVE_BUY = 34,   // Agresif alış
   SIGNAL_AGGRESSIVE_SELL = 35,  // Agresif satış
   
   // Zaman çerçevesine göre sinyaller
   SIGNAL_SCALP_BUY = 40,        // Scalp alış
   SIGNAL_SCALP_SELL = 41,       // Scalp satış
   SIGNAL_INTRADAY_BUY = 42,     // İntraday alış
   SIGNAL_INTRADAY_SELL = 43,    // İntraday satış
   SIGNAL_SWING_BUY = 44,        // Swing alış
   SIGNAL_SWING_SELL = 45,       // Swing satış
   SIGNAL_POSITION_BUY = 46,     // Pozisyon alış
   SIGNAL_POSITION_SELL = 47,    // Pozisyon satış
   
   // ML bazlı özel sinyaller
   SIGNAL_AI_HIGH_CONFIDENCE = 50, // AI yüksek güven
   SIGNAL_AI_MEDIUM_CONFIDENCE = 51, // AI orta güven
   SIGNAL_AI_LOW_CONFIDENCE = 52,  // AI düşük güven
   SIGNAL_ENSEMBLE_CONSENSUS = 53, // Ensemble fikir birliği
   SIGNAL_DEEP_LEARNING = 54,      // Deep learning sinyali
   SIGNAL_REINFORCEMENT = 55,      // Reinforcement learning
   
   // Özel durum sinyalleri
   SIGNAL_EMERGENCY_EXIT = 60,     // Acil çıkış
   SIGNAL_STOP_LOSS = 61,          // Stop loss
   SIGNAL_TAKE_PROFIT = 62,        // Take profit
   SIGNAL_TRAILING_STOP = 63,      // Trailing stop
   SIGNAL_HEDGE = 64,              // Hedge sinyali
   SIGNAL_REBALANCE = 65,          // Rebalans sinyali
   SIGNAL_RISK_REDUCTION = 66,     // Risk azaltma
   SIGNAL_POSITION_SIZING = 67     // Pozisyon boyutlandırma
};

//+------------------------------------------------------------------+
//| Sinyal Güçleri (Genişletilmiş)                                   |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_STRENGTH
{
   SIGNAL_STRENGTH_NONE = 0,     // Güç yok
   
   // Temel güç seviyeleri
   SIGNAL_VERY_WEAK = 1,         // Çok zayıf (0-20%)
   SIGNAL_WEAK = 2,              // Zayıf (20-40%)
   SIGNAL_MODERATE = 3,          // Orta (40-60%)
   SIGNAL_STRONG = 4,            // Güçlü (60-80%)
   SIGNAL_VERY_STRONG = 5,       // Çok güçlü (80-90%)
   SIGNAL_EXTREME = 6,           // Aşırı güçlü (90-100%)
   
   // Güvenilirlik bazlı güç
   SIGNAL_LOW_CONFIDENCE = 10,   // Düşük güven
   SIGNAL_MEDIUM_CONFIDENCE = 11, // Orta güven
   SIGNAL_HIGH_CONFIDENCE = 12,  // Yüksek güven
   SIGNAL_VERY_HIGH_CONFIDENCE = 13, // Çok yüksek güven
   
   // Volatilite düzeltmeli güç
   SIGNAL_VOLATILITY_ADJUSTED_WEAK = 20,   // Volatilite düzeltmeli zayıf
   SIGNAL_VOLATILITY_ADJUSTED_MEDIUM = 21, // Volatilite düzeltmeli orta
   SIGNAL_VOLATILITY_ADJUSTED_STRONG = 22, // Volatilite düzeltmeli güçlü
   
   // Confluence bazlı güç
   SIGNAL_SINGLE_INDICATOR = 30,  // Tek gösterge
   SIGNAL_DUAL_CONFIRMATION = 31, // İkili onay
   SIGNAL_TRIPLE_CONFIRMATION = 32, // Üçlü onay
   SIGNAL_MULTIPLE_CONFIRMATION = 33, // Çoklu onay
   SIGNAL_UNANIMOUS_CONSENSUS = 34,   // Oybirliği konsensüsü
   
   // Zaman çerçevesi bazlı güç
   SIGNAL_SINGLE_TIMEFRAME = 40,  // Tek zaman çerçevesi
   SIGNAL_DUAL_TIMEFRAME = 41,    // İkili zaman çerçevesi
   SIGNAL_MULTI_TIMEFRAME = 42,   // Çoklu zaman çerçevesi
   SIGNAL_ALL_TIMEFRAMES = 43,    // Tüm zaman çerçeveleri
   
   // Momentum bazlı güç
   SIGNAL_MOMENTUM_WEAK = 50,     // Zayıf momentum
   SIGNAL_MOMENTUM_BUILDING = 51, // Artan momentum
   SIGNAL_MOMENTUM_STRONG = 52,   // Güçlü momentum
   SIGNAL_MOMENTUM_EXPLOSIVE = 53, // Patlayıcı momentum
   
   // ML bazlı güç değerlendirmesi
   SIGNAL_ML_PROBABILITY_LOW = 60,    // ML düşük olasılık
   SIGNAL_ML_PROBABILITY_MEDIUM = 61, // ML orta olasılık
   SIGNAL_ML_PROBABILITY_HIGH = 62,   // ML yüksek olasılık
   SIGNAL_ML_PROBABILITY_EXTREME = 63 // ML aşırı yüksek olasılık
};

//+------------------------------------------------------------------+
//| Trend Yönleri (Genişletilmiş)                                    |
//+------------------------------------------------------------------+
enum ENUM_TREND_DIRECTION
{
   TREND_UNDEFINED = 0,          // Tanımsız trend
   
   // Temel trend yönleri
   TREND_NEUTRAL = 1,            // Nötr/Yatay trend
   TREND_BULLISH = 2,            // Yükseliş trendi
   TREND_BEARISH = 3,            // Düşüş trendi
   
   // Detaylı trend yönleri
   TREND_SIDEWAYS = 10,          // Yatay hareket
   TREND_RANGING = 11,           // Sınırlı hareket
   TREND_CONSOLIDATING = 12,     // Konsolidasyon
   TREND_ACCUMULATION = 13,      // Birikim fazı
   TREND_DISTRIBUTION = 14,      // Dağıtım fazı
   
   // Güçlü trend yönleri
   TREND_STRONG_BULLISH = 20,    // Güçlü yükseliş
   TREND_STRONG_BEARISH = 21,    // Güçlü düşüş
   TREND_PARABOLIC_UP = 22,      // Parabolik yükseliş
   TREND_PARABOLIC_DOWN = 23,    // Parabolik düşüş
   TREND_EXPLOSIVE_UP = 24,      // Patlayıcı yükseliş
   TREND_EXPLOSIVE_DOWN = 25,    // Patlayıcı düşüş
   
   // Trend fazları
   TREND_EARLY_BULLISH = 30,     // Erken yükseliş
   TREND_EARLY_BEARISH = 31,     // Erken düşüş
   TREND_MATURE_BULLISH = 32,    // Olgun yükseliş
   TREND_MATURE_BEARISH = 33,    // Olgun düşüş
   TREND_LATE_BULLISH = 34,      // Geç yükseliş
   TREND_LATE_BEARISH = 35,      // Geç düşüş
   TREND_EXHAUSTION_UP = 36,     // Yükseliş tükenmesi
   TREND_EXHAUSTION_DOWN = 37,   // Düşüş tükenmesi
   
   // Trend değişim durumları
   TREND_REVERSAL_TO_BULLISH = 40, // Yükselişe dönüş
   TREND_REVERSAL_TO_BEARISH = 41, // Düşüşe dönüş
   TREND_REVERSAL_PENDING = 42,    // Dönüş beklemede
   TREND_WEAKENING_BULLISH = 43,   // Zayıflayan yükseliş
   TREND_WEAKENING_BEARISH = 44,   // Zayıflayan düşüş
   TREND_STRENGTHENING_BULLISH = 45, // Güçlenen yükseliş
   TREND_STRENGTHENING_BEARISH = 46, // Güçlenen düşüş
   
   // Zaman çerçevesi bazlı trendler
   TREND_SHORT_TERM_BULLISH = 50,  // Kısa vadeli yükseliş
   TREND_SHORT_TERM_BEARISH = 51,  // Kısa vadeli düşüş
   TREND_MEDIUM_TERM_BULLISH = 52, // Orta vadeli yükseliş
   TREND_MEDIUM_TERM_BEARISH = 53, // Orta vadeli düşüş
   TREND_LONG_TERM_BULLISH = 54,   // Uzun vadeli yükseliş
   TREND_LONG_TERM_BEARISH = 55,   // Uzun vadeli düşüş
   
   // Karmaşık trend durumları
   TREND_DIVERGENT = 60,           // Farklılaşan trend
   TREND_CONVERGENT = 61,          // Yakınsayan trend
   TREND_CONFLICTING = 62,         // Çelişkili trend
   TREND_MULTI_DIRECTIONAL = 63,   // Çok yönlü trend
   TREND_SEASONAL_BULLISH = 64,    // Mevsimsel yükseliş
   TREND_SEASONAL_BEARISH = 65,    // Mevsimsel düşüş
   TREND_CYCLICAL_UP = 66,         // Döngüsel yükseliş
   TREND_CYCLICAL_DOWN = 67        // Döngüsel düşüş
};

//+------------------------------------------------------------------+
//| Trend Güçleri (Genişletilmiş)                                    |
//+------------------------------------------------------------------+
enum ENUM_TREND_STRENGTH
{
   TREND_STRENGTH_NONE = 0,      // Trend gücü yok
   
   // Temel güç seviyeleri
   TREND_VERY_WEAK = 1,          // Çok zayıf trend (0-15%)
   TREND_WEAK = 2,               // Zayıf trend (15-30%)
   TREND_MODERATE_WEAK = 3,      // Orta-zayıf trend (30-45%)
   TREND_MODERATE = 4,           // Orta trend (45-60%)
   TREND_MODERATE_STRONG = 5,    // Orta-güçlü trend (60-75%)
   TREND_STRONG = 6,             // Güçlü trend (75-85%)
   TREND_VERY_STRONG = 7,        // Çok güçlü trend (85-95%)
   TREND_EXTREME = 8,            // Aşırı güçlü trend (95-100%)
   
   // Momentum bazlı güç
   TREND_MOMENTUM_DECLINING = 10, // Azalan momentum
   TREND_MOMENTUM_STABLE = 11,    // Stabil momentum
   TREND_MOMENTUM_INCREASING = 12, // Artan momentum
   TREND_MOMENTUM_ACCELERATING = 13, // Hızlanan momentum
   TREND_MOMENTUM_EXPLOSIVE = 14,  // Patlayıcı momentum
   
   // Volatilite düzeltmeli güç
   TREND_LOW_VOLATILITY_WEAK = 20,    // Düşük volatilite zayıf
   TREND_LOW_VOLATILITY_STRONG = 21,  // Düşük volatilite güçlü
   TREND_HIGH_VOLATILITY_WEAK = 22,   // Yüksek volatilite zayıf
   TREND_HIGH_VOLATILITY_STRONG = 23, // Yüksek volatilite güçlü
   TREND_VOLATILITY_NORMALIZED = 24,  // Volatilite normalleştirilmiş
   
   // Süre bazlı güç
   TREND_SHORT_DURATION = 30,     // Kısa süreli
   TREND_MEDIUM_DURATION = 31,    // Orta süreli
   TREND_LONG_DURATION = 32,      // Uzun süreli
   TREND_PERSISTENT = 33,         // Kalıcı
   TREND_SUSTAINABLE = 34,        // Sürdürülebilir
   
   // Hacim onaylı güç
   TREND_VOLUME_WEAK = 40,        // Hacim zayıf onaylı
   TREND_VOLUME_MODERATE = 41,    // Hacim orta onaylı
   TREND_VOLUME_STRONG = 42,      // Hacim güçlü onaylı
   TREND_VOLUME_EXPLOSIVE = 43,   // Hacim patlayıcı onaylı
   TREND_VOLUME_DIVERGENT = 44,   // Hacim farklılaşan
   
   // Multi-timeframe güç
   TREND_MTF_WEAK = 50,           // Çoklu zaman zayıf
   TREND_MTF_MODERATE = 51,       // Çoklu zaman orta
   TREND_MTF_STRONG = 52,         // Çoklu zaman güçlü
   TREND_MTF_UNANIMOUS = 53,      // Çoklu zaman oybirliği
   TREND_MTF_CONFLICTING = 54,    // Çoklu zaman çelişkili
   
   // İstatistiksel güç
   TREND_STATISTICAL_WEAK = 60,       // İstatistiksel zayıf
   TREND_STATISTICAL_SIGNIFICANT = 61, // İstatistiksel anlamlı
   TREND_STATISTICAL_STRONG = 62,     // İstatistiksel güçlü
   TREND_STATISTICAL_ROBUST = 63,     // İstatistiksel sağlam
   
   // ML bazlı güç değerlendirmesi
   TREND_ML_CONFIDENCE_LOW = 70,      // ML düşük güven
   TREND_ML_CONFIDENCE_MEDIUM = 71,   // ML orta güven
   TREND_ML_CONFIDENCE_HIGH = 72,     // ML yüksek güven
   TREND_ML_CONFIDENCE_EXTREME = 73,  // ML aşırı yüksek güven
   TREND_ML_ENSEMBLE_WEAK = 74,       // ML ensemble zayıf
   TREND_ML_ENSEMBLE_STRONG = 75      // ML ensemble güçlü
};

//+------------------------------------------------------------------+
//| Gösterge Türleri (ISignalProvider için gerekli)                |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_TYPE
{
   INDICATOR_TREND = 0,              // Trend göstergeleri
   INDICATOR_MOMENTUM = 1,           // Momentum göstergeleri
   INDICATOR_VOLUME = 2,             // Hacim göstergeleri
   INDICATOR_VOLATILITY = 3,         // Volatilite göstergeleri
   INDICATOR_SUPPORT_RESISTANCE = 4, // Destek/Direnç göstergeleri
   INDICATOR_OSCILLATOR = 5,         // Osilatör göstergeleri
   INDICATOR_CYCLE = 6,              // Döngü göstergeleri
   INDICATOR_BREADTH = 7,            // Genişlik göstergeleri
   INDICATOR_SENTIMENT = 8,          // Sentiment göstergeleri
   INDICATOR_FUNDAMENTAL = 9,        // Fundamental göstergeler
   INDICATOR_STATISTICAL = 10,       // İstatistiksel göstergeler
   INDICATOR_PATTERN = 11,           // Pattern göstergeleri
   INDICATOR_AI_ML = 12,             // AI/ML göstergeleri
   INDICATOR_CUSTOM = 13             // Özel göstergeler
};

//+------------------------------------------------------------------+
//| Geliştirilmiş Sinyal Kalitesi (ISignalProvider uyumlu)         |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_QUALITY
{
   SIGNAL_QUALITY_VERY_POOR = 0,    // Çok zayıf kalite (0-20%)
   SIGNAL_QUALITY_POOR = 1,         // Zayıf kalite (20-40%)
   SIGNAL_QUALITY_FAIR = 2,         // Makul kalite (40-60%)
   SIGNAL_QUALITY_GOOD = 3,         // İyi kalite (60-75%)
   SIGNAL_QUALITY_VERY_GOOD = 4,    // Çok iyi kalite (75-85%)
   SIGNAL_QUALITY_EXCELLENT = 5,    // Mükemmel kalite (85-95%)
   SIGNAL_QUALITY_PRISTINE = 6      // Kusursuz kalite (95-100%)
};

//+------------------------------------------------------------------+
//| Confluence Seviyesi                                             |
//+------------------------------------------------------------------+
enum ENUM_CONFLUENCE_LEVEL
{
   CONFLUENCE_NONE = 0,              // Confluence yok
   CONFLUENCE_WEAK = 1,              // Zayıf confluence (1-2 gösterge)
   CONFLUENCE_MODERATE = 2,          // Orta confluence (3-4 gösterge)
   CONFLUENCE_STRONG = 3,            // Güçlü confluence (5-6 gösterge)
   CONFLUENCE_VERY_STRONG = 4,       // Çok güçlü confluence (7+ gösterge)
   CONFLUENCE_UNANIMOUS = 5          // Oybirliği confluence (tüm göstergeler)
};

//+------------------------------------------------------------------+
//| Market Fazları                                                  |
//+------------------------------------------------------------------+
enum ENUM_MARKET_PHASE
{
   MARKET_PHASE_UNDEFINED = 0,       // Tanımsız faz
   MARKET_PHASE_ACCUMULATION = 1,    // Birikim fazı
   MARKET_PHASE_MARKUP = 2,          // İşaretleme fazı
   MARKET_PHASE_DISTRIBUTION = 3,    // Dağıtım fazı
   MARKET_PHASE_MARKDOWN = 4,        // İşaretleme azaltma fazı
   MARKET_PHASE_RECOVERY = 5,        // Toparlanma fazı
   MARKET_PHASE_DECLINE = 6,         // Düşüş fazı
   MARKET_PHASE_CONSOLIDATION = 7,   // Konsolidasyon fazı
   MARKET_PHASE_BREAKOUT = 8,        // Kırılım fazı
   MARKET_PHASE_REVERSAL = 9,        // Dönüş fazı
   MARKET_PHASE_CONTINUATION = 10    // Devam fazı
};
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
//| Volume Analizi Enum'ları                                        |
//+------------------------------------------------------------------+
enum ENUM_VOLUME_PROFILE_TYPE
{
   VOLUME_PROFILE_NORMAL = 0,        // Normal dağılım
   VOLUME_PROFILE_BIMODAL = 1,       // İki modlu dağılım
   VOLUME_PROFILE_MULTIMODAL = 2,    // Çok modlu dağılım
   VOLUME_PROFILE_SKEWED_HIGH = 3,   // Yukarı çarpık
   VOLUME_PROFILE_SKEWED_LOW = 4,    // Aşağı çarpık
   VOLUME_PROFILE_FLAT = 5           // Düz dağılım
};

enum ENUM_INSTITUTIONAL_ACTIVITY
{
   INSTITUTIONAL_NONE = 0,           // Institutional aktivite yok
   INSTITUTIONAL_ACCUMULATION = 1,   // Institutional birikim
   INSTITUTIONAL_DISTRIBUTION = 2,   // Institutional dağıtım
   INSTITUTIONAL_ABSORPTION = 3,     // Institutional emilim
   INSTITUTIONAL_MANIPULATION = 4,   // Institutional manipülasyon
   INSTITUTIONAL_TESTING = 5,        // Institutional test
   INSTITUTIONAL_BREAKOUT = 6        // Institutional kırılım
};

enum ENUM_VOLUME_CONFIRMATION
{
   VOLUME_CONF_NONE = 0,            // Onay yok
   VOLUME_CONF_WEAK = 1,            // Zayıf onay
   VOLUME_CONF_MODERATE = 2,        // Orta onay
   VOLUME_CONF_STRONG = 3,          // Güçlü onay
   VOLUME_CONF_EXTREME = 4          // Aşırı güçlü onay
};
//+------------------------------------------------------------------+
//| Zaman Çerçevesi Uyumu                                          |
//+------------------------------------------------------------------+
enum ENUM_TIMEFRAME_ALIGNMENT
{
   TF_ALIGNMENT_NONE = 0,            // Uyum yok
   TF_ALIGNMENT_WEAK = 1,            // Zayıf uyum (1-2 TF)
   TF_ALIGNMENT_MODERATE = 2,        // Orta uyum (3-4 TF)
   TF_ALIGNMENT_STRONG = 3,          // Güçlü uyum (5-6 TF)
   TF_ALIGNMENT_PERFECT = 4,         // Mükemmel uyum (7+ TF)
   TF_ALIGNMENT_CONFLICTING = 5      // Çelişkili (karışık sinyaller)
};

//+------------------------------------------------------------------+
//| Adaptasyon Durumu                                               |
//+------------------------------------------------------------------+
enum ENUM_ADAPTATION_STATUS
{
   ADAPTATION_NONE = 0,              // Adaptasyon yok
   ADAPTATION_LEARNING = 1,          // Öğrenme fazı
   ADAPTATION_ADAPTING = 2,          // Adaptasyon fazı
   ADAPTATION_STABLE = 3,            // Stabil durum
   ADAPTATION_OPTIMIZING = 4,        // Optimizasyon fazı
   ADAPTATION_ERROR = 5,             // Adaptasyon hatası
   ADAPTATION_COMPLETE = 6           // Adaptasyon tamamlandı
};

//+------------------------------------------------------------------+
//| Performans Sınıflandırması                                     |
//+------------------------------------------------------------------+
enum ENUM_PERFORMANCE_CLASS
{
   PERFORMANCE_POOR = 0,             // Zayıf performans (< 40%)
   PERFORMANCE_BELOW_AVERAGE = 1,    // Ortalama altı (40-50%)
   PERFORMANCE_AVERAGE = 2,          // Ortalama (50-65%)
   PERFORMANCE_ABOVE_AVERAGE = 3,    // Ortalama üstü (65-75%)
   PERFORMANCE_GOOD = 4,             // İyi (75-85%)
   PERFORMANCE_EXCELLENT = 5,        // Mükemmel (85-95%)
   PERFORMANCE_OUTSTANDING = 6       // Olağanüstü (> 95%)
};

//+------------------------------------------------------------------+
//| Provider Durumu                                                 |
//+------------------------------------------------------------------+
enum ENUM_PROVIDER_STATE
{
   PROVIDER_INACTIVE = 0,            // Pasif
   PROVIDER_INITIALIZING = 1,        // Başlatılıyor
   PROVIDER_ACTIVE = 2,              // Aktif
   PROVIDER_PAUSED = 3,              // Duraklatıldı
   PROVIDER_ERROR = 4,               // Hata durumu
   PROVIDER_MAINTENANCE = 5,         // Bakım modu
   PROVIDER_UPDATING = 6,            // Güncelleniyor
   PROVIDER_SHUTDOWN = 7             // Kapatılıyor
};

//+------------------------------------------------------------------+
//| Sinyal Timing                                                   |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_TIMING
{
   SIGNAL_TIMING_EARLY = 0,       // Erken sinyal
   SIGNAL_TIMING_OPTIMAL = 1,     // Optimal sinyal
   SIGNAL_TIMING_LATE = 2,        // Geç sinyal
   SIGNAL_TIMING_MISSED = 3       // Kaçırılan sinyal
};

//+------------------------------------------------------------------+
//| Trend Sürekliliği                                               |
//+------------------------------------------------------------------+
enum ENUM_TREND_CONTINUITY
{
   TREND_CONT_BROKEN = 0,         // Kırılan trend
   TREND_CONT_WEAK = 1,           // Zayıf süreklilik
   TREND_CONT_MODERATE = 2,       // Orta süreklilik
   TREND_CONT_STRONG = 3,         // Güçlü süreklilik
   TREND_CONT_PERSISTENT = 4      // Kalıcı süreklilik
};
//+------------------------------------------------------------------+
//| RSI Momentum Enum'ları                                          |
//+------------------------------------------------------------------+
enum ENUM_RSI_CONDITION
{
   RSI_CONDITION_UNKNOWN = 0,        // Bilinmeyen
   RSI_OVERSOLD = 1,                 // Aşırı satım (< 30)
   RSI_OVERSOLD_EXTREME = 2,         // Aşırı aşırı satım (< 20)
   RSI_NEUTRAL_BEARISH = 3,          // Nötr düşüş eğilimli (30-50)
   RSI_NEUTRAL = 4,                  // Nötr (45-55)
   RSI_NEUTRAL_BULLISH = 5,          // Nötr yükseliş eğilimli (50-70)
   RSI_OVERBOUGHT = 6,               // Aşırı alım (> 70)
   RSI_OVERBOUGHT_EXTREME = 7        // Aşırı aşırı alım (> 80)
};

enum ENUM_RSI_TREND
{
   RSI_TREND_UNKNOWN = 0,            // Bilinmeyen trend
   RSI_TREND_STRONG_BEARISH = 1,     // Güçlü düşüş
   RSI_TREND_BEARISH = 2,            // Düşüş
   RSI_TREND_NEUTRAL = 3,            // Nötr
   RSI_TREND_BULLISH = 4,            // Yükseliş
   RSI_TREND_STRONG_BULLISH = 5      // Güçlü yükseliş
};

enum ENUM_MOMENTUM_STATE
{
   MOMENTUM_UNKNOWN = 0,             // Bilinmeyen
   MOMENTUM_WEAKENING = 1,           // Zayıflıyor
   MOMENTUM_STABLE = 2,              // Stabil
   MOMENTUM_BUILDING = 3,            // Güçleniyor
   MOMENTUM_ACCELERATING = 4,        // Hızlanıyor
   MOMENTUM_EXHAUSTION = 5           // Tükenme
};

//+------------------------------------------------------------------+
//| MACD Sinyal Türleri                                             |
//+------------------------------------------------------------------+
enum ENUM_MACD_SIGNAL_TYPE
{
   MACD_SIGNAL_NONE = 0,             // Sinyal yok
   MACD_SIGNAL_LINE_CROSS_UP = 1,    // Signal line yukarı kesişim
   MACD_SIGNAL_LINE_CROSS_DOWN = 2,  // Signal line aşağı kesişim
   MACD_ZERO_LINE_CROSS_UP = 3,      // Zero line yukarı kesişim
   MACD_ZERO_LINE_CROSS_DOWN = 4,    // Zero line aşağı kesişim
   MACD_HISTOGRAM_REVERSAL_UP = 5,   // Histogram yukarı dönüş
   MACD_HISTOGRAM_REVERSAL_DOWN = 6, // Histogram aşağı dönüş
   MACD_DIVERGENCE_BULLISH = 7,      // Boğa divergence
   MACD_DIVERGENCE_BEARISH = 8,      // Ayı divergence
   MACD_HIDDEN_DIV_BULLISH = 9,      // Gizli boğa divergence
   MACD_HIDDEN_DIV_BEARISH = 10      // Gizli ayı divergence
};

//+------------------------------------------------------------------+
//| MACD Koşul Durumları                                            |
//+------------------------------------------------------------------+
enum ENUM_MACD_CONDITION
{
   MACD_CONDITION_UNKNOWN = 0,       // Bilinmeyen
   MACD_BULLISH_STRONG = 1,          // Güçlü boğa
   MACD_BULLISH_MODERATE = 2,        // Orta boğa
   MACD_BULLISH_WEAK = 3,            // Zayıf boğa
   MACD_NEUTRAL = 4,                 // Nötr
   MACD_BEARISH_WEAK = 5,            // Zayıf ayı
   MACD_BEARISH_MODERATE = 6,        // Orta ayı
   MACD_BEARISH_STRONG = 7           // Güçlü ayı
};

//+------------------------------------------------------------------+
//| MACD Momentum Fazları                                           |
//+------------------------------------------------------------------+
enum ENUM_MACD_MOMENTUM_PHASE
{
   MACD_MOMENTUM_UNKNOWN = 0,        // Bilinmeyen
   MACD_ACCELERATION_UP = 1,         // Yukarı ivme
   MACD_DECELERATION_UP = 2,         // Yukarı yavaşlama
   MACD_ACCELERATION_DOWN = 3,       // Aşağı ivme  
   MACD_DECELERATION_DOWN = 4,       // Aşağı yavaşlama
   MACD_MOMENTUM_REVERSAL = 5,       // Momentum dönüşü
   MACD_MOMENTUM_EXHAUSTION = 6      // Momentum tükenmesi
};
//+------------------------------------------------------------------+
//| MACHINE LEARNING ENUMLERİ                                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ML Model Türleri                                                |
//+------------------------------------------------------------------+
enum ENUM_ML_MODEL_TYPE
{
   ML_NONE = 0,              // ML kullanılmıyor
   ML_LINEAR_REGRESSION,     // Doğrusal regresyon
   ML_LOGISTIC_REGRESSION,   // Lojistik regresyon
   ML_DECISION_TREE,         // Karar ağacı
   ML_RANDOM_FOREST,         // Rastgele orman
   ML_SVM,                   // Destek vektör makinesi
   ML_NEURAL_NETWORK,        // Sinir ağı
   ML_LSTM,                  // LSTM ağı
   ML_GRU,                   // GRU ağı
   ML_CNN,                   // Konvolüsyonel ağ
   ML_ENSEMBLE,              // Topluluk modeli
   ML_REINFORCEMENT,         // Pekiştirmeli öğrenme
   ML_GENETIC_ALGORITHM,     // Genetik algoritma
   ML_FUZZY_LOGIC,          // Bulanık mantık
   ML_BAYESIAN_NETWORK      // Bayesian ağ
};

//+------------------------------------------------------------------+
//| ML Model Durumları                                              |
//+------------------------------------------------------------------+
enum ENUM_ML_MODEL_STATE
{
   ML_STATE_NOT_INITIALIZED = 0, // Başlatılmamış
   ML_STATE_TRAINING,            // Eğitim aşamasında
   ML_STATE_VALIDATING,          // Doğrulama aşamasında
   ML_STATE_TESTING,             // Test aşamasında
   ML_STATE_READY,               // Kullanıma hazır
   ML_STATE_PREDICTING,          // Tahmin yapıyor
   ML_STATE_UPDATING,            // Güncelleniyor
   ML_STATE_ERROR,               // Hata durumu
   ML_STATE_OVERFITTED,          // Aşırı öğrenme
   ML_STATE_UNDERFITTED,         // Yetersiz öğrenme
   ML_STATE_CONVERGED           // Yakınsadı
};

//+------------------------------------------------------------------+
//| ML Adaptasyon Türleri                                           |
//+------------------------------------------------------------------+
enum ENUM_ML_ADAPTATION_TYPE
{
   ML_ADAPT_NONE = 0,         // Adaptasyon yok
   ML_ADAPT_ONLINE_LEARNING,  // Çevrimiçi öğrenme
   ML_ADAPT_INCREMENTAL,      // Artımlı öğrenme
   ML_ADAPT_TRANSFER_LEARNING, // Transfer öğrenme
   ML_ADAPT_META_LEARNING,    // Meta öğrenme
   ML_ADAPT_ENSEMBLE_UPDATE,  // Topluluk güncellemesi
   ML_ADAPT_DRIFT_DETECTION,  // Kayma tespiti
   ML_ADAPT_CONCEPT_DRIFT,    // Kavram kayması
   ML_ADAPT_REGIME_CHANGE,    // Rejim değişikliği
   ML_ADAPT_VOLATILITY_REGIME, // Volatilite rejimi
   ML_ADAPT_MARKET_PHASE,     // Market fazı adaptasyonu
   ML_ADAPT_FEEDBACK_LOOP,    // Geri besleme döngüsü
   ML_ADAPT_REINFORCEMENT,    // Pekiştirmeli adaptasyon
   ML_ADAPT_EVOLUTIONARY     // Evrimsel adaptasyon
};

//+------------------------------------------------------------------+
//| TEKNİK ANALİZ ENUMLERİ                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Divergence Türleri                                              |
//+------------------------------------------------------------------+
enum ENUM_DIVERGENCE_TYPE
{
   DIVERGENCE_NONE = 0,           // Divergence yok
   DIVERGENCE_REGULAR_BULLISH = 1, // Normal boğa divergence
   DIVERGENCE_REGULAR_BEARISH = 2, // Normal ayı divergence
   DIVERGENCE_HIDDEN_BULLISH = 3,  // Gizli boğa divergence
   DIVERGENCE_HIDDEN_BEARISH = 4   // Gizli ayı divergence
};

//+------------------------------------------------------------------+
//| DİĞER DESTEKLEYICI ENUMLERİ                                     |
//+------------------------------------------------------------------+

enum ENUM_PIVOT_TYPE
{
   PIVOT_STANDARD = 0,           // Standard Pivot Points
   PIVOT_FIBONACCI = 1,          // Fibonacci Pivot Points
   PIVOT_CAMARILLA = 2,          // Camarilla Pivot Points
   PIVOT_WOODIE = 3,             // Woodie's Pivot Points
   PIVOT_DEMARK = 4,             // Tom DeMark's Pivot Points
   PIVOT_CLASSICAL = 5           // Classical Floor Trader Pivots
};

enum ENUM_PIVOT_LEVEL_TYPE
{
   PIVOT_LEVEL_PP = 0,           // Main Pivot Point
   PIVOT_LEVEL_R1 = 1,           // Resistance 1
   PIVOT_LEVEL_R2 = 2,           // Resistance 2
   PIVOT_LEVEL_R3 = 3,           // Resistance 3
   PIVOT_LEVEL_R4 = 4,           // Resistance 4 (Camarilla)
   PIVOT_LEVEL_R5 = 5,           // Resistance 5 (Extended)
   PIVOT_LEVEL_S1 = 6,           // Support 1
   PIVOT_LEVEL_S2 = 7,           // Support 2
   PIVOT_LEVEL_S3 = 8,           // Support 3
   PIVOT_LEVEL_S4 = 9,           // Support 4 (Camarilla)
   PIVOT_LEVEL_S5 = 10           // Support 5 (Extended)
};

enum ENUM_PIVOT_STRENGTH
{
   PIVOT_STRENGTH_WEAK = 0,      // Zayıf pivot seviyesi
   PIVOT_STRENGTH_NORMAL = 1,    // Normal pivot seviyesi
   PIVOT_STRENGTH_STRONG = 2,    // Güçlü pivot seviyesi
   PIVOT_STRENGTH_CRITICAL = 3,  // Kritik pivot seviyesi
   PIVOT_STRENGTH_INSTITUTIONAL = 4 // Institutional seviye
};

enum ENUM_PIVOT_ZONE_STATUS
{
   PIVOT_ZONE_UNTESTED = 0,      // Test edilmemiş
   PIVOT_ZONE_TESTED = 1,        // Test edilmiş
   PIVOT_ZONE_BROKEN = 2,        // Kırılmış
   PIVOT_ZONE_HELD = 3,          // Tutmuş
   PIVOT_ZONE_RETESTED = 4,      // Yeniden test edilmiş
   PIVOT_ZONE_REVERSED = 5       // Ters yönde kırılmış
};
enum ENUM_MARKET_SENTIMENT
{
   SENTIMENT_VERY_BEARISH = 0,  // Çok düşüş eğilimli
   SENTIMENT_BEARISH = 1,       // Düşüş eğilimli
   SENTIMENT_NEUTRAL = 2,       // Nötr
   SENTIMENT_BULLISH = 3,       // Yükseliş eğilimli
   SENTIMENT_VERY_BULLISH = 4   // Çok yükseliş eğilimli
};

enum ENUM_VOLUME_STATE
{
   VOLUME_LOW = 0,        // Düşük volume
   VOLUME_NORMAL = 1,     // Normal volume
   VOLUME_HIGH = 2,       // Yüksek volume
   VOLUME_SPIKE = 3       // Volume patlaması
};

enum ENUM_MARKET_CONDITION
{
   MARKET_RANGING = 0,    // Yatay market
   MARKET_TRENDING = 1,   // Trendli market
   MARKET_VOLATILE = 2,   // Volatil market
   MARKET_QUIET = 3       // Sakin market
};

enum ENUM_RISK_LEVEL
{
   RISK_VERY_LOW = 0,     // Çok düşük risk
   RISK_LOW = 1,          // Düşük risk
   RISK_MEDIUM = 2,       // Orta risk
   RISK_HIGH = 3,         // Yüksek risk
   RISK_VERY_HIGH = 4     // Çok yüksek risk
};
//+------------------------------------------------------------------+
//| Volatilite Rejim Enum'ı                                         |
//+------------------------------------------------------------------+
enum ENUM_VOLATILITY_REGIME
{
   VOLATILITY_UNKNOWN = 0,       // Bilinmeyen rejim
   VOLATILITY_LOW = 1,           // Düşük volatilite (< 25th percentile)
   VOLATILITY_NORMAL = 2,        // Normal volatilite (25-75th percentile)  
   VOLATILITY_HIGH = 3,          // Yüksek volatilite (75-95th percentile)
   VOLATILITY_EXTREME = 4,       // Aşırı volatilite (> 95th percentile)
   VOLATILITY_EXPANSION = 5,     // Volatilite genişlemesi
   VOLATILITY_CONTRACTION = 6    // Volatilite daralması
};
//+------------------------------------------------------------------+
//| STRING CONVERSION FUNCTIONS (GENİŞLETİLMİŞ)                    |
//+------------------------------------------------------------------+

string SignalTypeToString(ENUM_SIGNAL_TYPE signal_type)
{
   switch(signal_type)
   {
      // Temel sinyaller
      case SIGNAL_BUY:  return "BUY";
      case SIGNAL_SELL: return "SELL";
      case SIGNAL_HOLD: return "HOLD";
      case SIGNAL_CLOSE: return "CLOSE";
      case SIGNAL_NONE: return "NONE";
      
      // Kaynak bazlı sinyaller
      case SIGNAL_TECHNICAL: return "TECHNICAL";
      case SIGNAL_FUNDAMENTAL: return "FUNDAMENTAL";
      case SIGNAL_SENTIMENT: return "SENTIMENT";
      case SIGNAL_ML_BASED: return "ML_BASED";
      case SIGNAL_HYBRID: return "HYBRID";
      case SIGNAL_QUANTITATIVE: return "QUANTITATIVE";
      case SIGNAL_NEWS_BASED: return "NEWS_BASED";
      case SIGNAL_CORRELATION: return "CORRELATION";
      case SIGNAL_ARBITRAGE: return "ARBITRAGE";
      case SIGNAL_MEAN_REVERSION: return "MEAN_REVERSION";
      
      // Spesifik teknik sinyaller
      case SIGNAL_BREAKOUT_BUY: return "BREAKOUT_BUY";
      case SIGNAL_BREAKOUT_SELL: return "BREAKOUT_SELL";
      case SIGNAL_PULLBACK_BUY: return "PULLBACK_BUY";
      case SIGNAL_PULLBACK_SELL: return "PULLBACK_SELL";
      case SIGNAL_REVERSAL_BUY: return "REVERSAL_BUY";
      case SIGNAL_REVERSAL_SELL: return "REVERSAL_SELL";
      case SIGNAL_CONTINUATION_BUY: return "CONTINUATION_BUY";
      case SIGNAL_CONTINUATION_SELL: return "CONTINUATION_SELL";
      case SIGNAL_DIVERGENCE_BUY: return "DIVERGENCE_BUY";
      case SIGNAL_DIVERGENCE_SELL: return "DIVERGENCE_SELL";
      
      // Risk seviyesi sinyalleri
      case SIGNAL_CONSERVATIVE_BUY: return "CONSERVATIVE_BUY";
      case SIGNAL_CONSERVATIVE_SELL: return "CONSERVATIVE_SELL";
      case SIGNAL_MODERATE_BUY: return "MODERATE_BUY";
      case SIGNAL_MODERATE_SELL: return "MODERATE_SELL";
      case SIGNAL_AGGRESSIVE_BUY: return "AGGRESSIVE_BUY";
      case SIGNAL_AGGRESSIVE_SELL: return "AGGRESSIVE_SELL";
      
      // Zaman çerçevesi sinyalleri
      case SIGNAL_SCALP_BUY: return "SCALP_BUY";
      case SIGNAL_SCALP_SELL: return "SCALP_SELL";
      case SIGNAL_INTRADAY_BUY: return "INTRADAY_BUY";
      case SIGNAL_INTRADAY_SELL: return "INTRADAY_SELL";
      case SIGNAL_SWING_BUY: return "SWING_BUY";
      case SIGNAL_SWING_SELL: return "SWING_SELL";
      case SIGNAL_POSITION_BUY: return "POSITION_BUY";
      case SIGNAL_POSITION_SELL: return "POSITION_SELL";
      
      // ML sinyalleri
      case SIGNAL_AI_HIGH_CONFIDENCE: return "AI_HIGH_CONFIDENCE";
      case SIGNAL_AI_MEDIUM_CONFIDENCE: return "AI_MEDIUM_CONFIDENCE";
      case SIGNAL_AI_LOW_CONFIDENCE: return "AI_LOW_CONFIDENCE";
      case SIGNAL_ENSEMBLE_CONSENSUS: return "ENSEMBLE_CONSENSUS";
      case SIGNAL_DEEP_LEARNING: return "DEEP_LEARNING";
      case SIGNAL_REINFORCEMENT: return "REINFORCEMENT";
      
      // Özel durum sinyalleri
      case SIGNAL_EMERGENCY_EXIT: return "EMERGENCY_EXIT";
      case SIGNAL_STOP_LOSS: return "STOP_LOSS";
      case SIGNAL_TAKE_PROFIT: return "TAKE_PROFIT";
      case SIGNAL_TRAILING_STOP: return "TRAILING_STOP";
      case SIGNAL_HEDGE: return "HEDGE";
      case SIGNAL_REBALANCE: return "REBALANCE";
      case SIGNAL_RISK_REDUCTION: return "RISK_REDUCTION";
      case SIGNAL_POSITION_SIZING: return "POSITION_SIZING";
      
      default: return "UNKNOWN";
   }
}

string SignalStrengthToString(ENUM_SIGNAL_STRENGTH signal_strength)
{
   switch(signal_strength)
   {
      // Temel güç seviyeleri
      case SIGNAL_STRENGTH_NONE: return "NONE";
      case SIGNAL_VERY_WEAK: return "VERY_WEAK";
      case SIGNAL_WEAK: return "WEAK";
      case SIGNAL_MODERATE: return "MODERATE";
      case SIGNAL_STRONG: return "STRONG";
      case SIGNAL_VERY_STRONG: return "VERY_STRONG";
      case SIGNAL_EXTREME: return "EXTREME";
      
      // Güvenilirlik bazlı
      case SIGNAL_LOW_CONFIDENCE: return "LOW_CONFIDENCE";
      case SIGNAL_MEDIUM_CONFIDENCE: return "MEDIUM_CONFIDENCE";
      case SIGNAL_HIGH_CONFIDENCE: return "HIGH_CONFIDENCE";
      case SIGNAL_VERY_HIGH_CONFIDENCE: return "VERY_HIGH_CONFIDENCE";
      
      // Volatilite düzeltmeli
      case SIGNAL_VOLATILITY_ADJUSTED_WEAK: return "VOLATILITY_ADJUSTED_WEAK";
      case SIGNAL_VOLATILITY_ADJUSTED_MEDIUM: return "VOLATILITY_ADJUSTED_MEDIUM";
      case SIGNAL_VOLATILITY_ADJUSTED_STRONG: return "VOLATILITY_ADJUSTED_STRONG";
      
      // Confluence bazlı
      case SIGNAL_SINGLE_INDICATOR: return "SINGLE_INDICATOR";
      case SIGNAL_DUAL_CONFIRMATION: return "DUAL_CONFIRMATION";
      case SIGNAL_TRIPLE_CONFIRMATION: return "TRIPLE_CONFIRMATION";
      case SIGNAL_MULTIPLE_CONFIRMATION: return "MULTIPLE_CONFIRMATION";
      case SIGNAL_UNANIMOUS_CONSENSUS: return "UNANIMOUS_CONSENSUS";
      
      // Zaman çerçevesi bazlı
      case SIGNAL_SINGLE_TIMEFRAME: return "SINGLE_TIMEFRAME";
      case SIGNAL_DUAL_TIMEFRAME: return "DUAL_TIMEFRAME";
      case SIGNAL_MULTI_TIMEFRAME: return "MULTI_TIMEFRAME";
      case SIGNAL_ALL_TIMEFRAMES: return "ALL_TIMEFRAMES";
      
      // Momentum bazlı
      case SIGNAL_MOMENTUM_WEAK: return "MOMENTUM_WEAK";
      case SIGNAL_MOMENTUM_BUILDING: return "MOMENTUM_BUILDING";
      case SIGNAL_MOMENTUM_STRONG: return "MOMENTUM_STRONG";
      case SIGNAL_MOMENTUM_EXPLOSIVE: return "MOMENTUM_EXPLOSIVE";
      
      // ML bazlı
      case SIGNAL_ML_PROBABILITY_LOW: return "ML_PROBABILITY_LOW";
      case SIGNAL_ML_PROBABILITY_MEDIUM: return "ML_PROBABILITY_MEDIUM";
      case SIGNAL_ML_PROBABILITY_HIGH: return "ML_PROBABILITY_HIGH";
      case SIGNAL_ML_PROBABILITY_EXTREME: return "ML_PROBABILITY_EXTREME";
      
      default: return "UNKNOWN";
   }
}

string TrendDirectionToString(ENUM_TREND_DIRECTION trend_direction)
{
   switch(trend_direction)
   {
      // Temel yönler
      case TREND_UNDEFINED: return "UNDEFINED";
      case TREND_NEUTRAL: return "NEUTRAL";
      case TREND_BULLISH: return "BULLISH";
      case TREND_BEARISH: return "BEARISH";
      
      // Detaylı yönler
      case TREND_SIDEWAYS: return "SIDEWAYS";
      case TREND_RANGING: return "RANGING";
      case TREND_CONSOLIDATING: return "CONSOLIDATING";
      case TREND_ACCUMULATION: return "ACCUMULATION";
      case TREND_DISTRIBUTION: return "DISTRIBUTION";
      
      // Güçlü yönler
      case TREND_STRONG_BULLISH: return "STRONG_BULLISH";
      case TREND_STRONG_BEARISH: return "STRONG_BEARISH";
      case TREND_PARABOLIC_UP: return "PARABOLIC_UP";
      case TREND_PARABOLIC_DOWN: return "PARABOLIC_DOWN";
      case TREND_EXPLOSIVE_UP: return "EXPLOSIVE_UP";
      case TREND_EXPLOSIVE_DOWN: return "EXPLOSIVE_DOWN";
      
      // Trend fazları
      case TREND_EARLY_BULLISH: return "EARLY_BULLISH";
      case TREND_EARLY_BEARISH: return "EARLY_BEARISH";
      case TREND_MATURE_BULLISH: return "MATURE_BULLISH";
      case TREND_MATURE_BEARISH: return "MATURE_BEARISH";
      case TREND_LATE_BULLISH: return "LATE_BULLISH";
      case TREND_LATE_BEARISH: return "LATE_BEARISH";
      case TREND_EXHAUSTION_UP: return "EXHAUSTION_UP";
      case TREND_EXHAUSTION_DOWN: return "EXHAUSTION_DOWN";
      
      // Değişim durumları
      case TREND_REVERSAL_TO_BULLISH: return "REVERSAL_TO_BULLISH";
      case TREND_REVERSAL_TO_BEARISH: return "REVERSAL_TO_BEARISH";
      case TREND_REVERSAL_PENDING: return "REVERSAL_PENDING";
      case TREND_WEAKENING_BULLISH: return "WEAKENING_BULLISH";
      case TREND_WEAKENING_BEARISH: return "WEAKENING_BEARISH";
      case TREND_STRENGTHENING_BULLISH: return "STRENGTHENING_BULLISH";
      case TREND_STRENGTHENING_BEARISH: return "STRENGTHENING_BEARISH";
      
      // Zaman çerçevesi bazlı
      case TREND_SHORT_TERM_BULLISH: return "SHORT_TERM_BULLISH";
      case TREND_SHORT_TERM_BEARISH: return "SHORT_TERM_BEARISH";
      case TREND_MEDIUM_TERM_BULLISH: return "MEDIUM_TERM_BULLISH";
      case TREND_MEDIUM_TERM_BEARISH: return "MEDIUM_TERM_BEARISH";
      case TREND_LONG_TERM_BULLISH: return "LONG_TERM_BULLISH";
      case TREND_LONG_TERM_BEARISH: return "LONG_TERM_BEARISH";
      
      // Karmaşık durumlar
      case TREND_DIVERGENT: return "DIVERGENT";
      case TREND_CONVERGENT: return "CONVERGENT";
      case TREND_CONFLICTING: return "CONFLICTING";
      case TREND_MULTI_DIRECTIONAL: return "MULTI_DIRECTIONAL";
      case TREND_SEASONAL_BULLISH: return "SEASONAL_BULLISH";
      case TREND_SEASONAL_BEARISH: return "SEASONAL_BEARISH";
      case TREND_CYCLICAL_UP: return "CYCLICAL_UP";
      case TREND_CYCLICAL_DOWN: return "CYCLICAL_DOWN";
      
      default: return "UNKNOWN";
   }
}

string TrendStrengthToString(ENUM_TREND_STRENGTH trend_strength)
{
   switch(trend_strength)
   {
      // Temel güç seviyeleri
      case TREND_STRENGTH_NONE: return "NONE";
      case TREND_VERY_WEAK: return "VERY_WEAK";
      case TREND_WEAK: return "WEAK";
      case TREND_MODERATE_WEAK: return "MODERATE_WEAK";
      case TREND_MODERATE: return "MODERATE";
      case TREND_MODERATE_STRONG: return "MODERATE_STRONG";
      case TREND_STRONG: return "STRONG";
      case TREND_VERY_STRONG: return "VERY_STRONG";
      case TREND_EXTREME: return "EXTREME";
      
      // Momentum bazlı
      case TREND_MOMENTUM_DECLINING: return "MOMENTUM_DECLINING";
      case TREND_MOMENTUM_STABLE: return "MOMENTUM_STABLE";
      case TREND_MOMENTUM_INCREASING: return "MOMENTUM_INCREASING";
      case TREND_MOMENTUM_ACCELERATING: return "MOMENTUM_ACCELERATING";
      case TREND_MOMENTUM_EXPLOSIVE: return "MOMENTUM_EXPLOSIVE";
      
      // Volatilite düzeltmeli
      case TREND_LOW_VOLATILITY_WEAK: return "LOW_VOLATILITY_WEAK";
      case TREND_LOW_VOLATILITY_STRONG: return "LOW_VOLATILITY_STRONG";
      case TREND_HIGH_VOLATILITY_WEAK: return "HIGH_VOLATILITY_WEAK";
      case TREND_HIGH_VOLATILITY_STRONG: return "HIGH_VOLATILITY_STRONG";
      case TREND_VOLATILITY_NORMALIZED: return "VOLATILITY_NORMALIZED";
      
      // Süre bazlı
      case TREND_SHORT_DURATION: return "SHORT_DURATION";
      case TREND_MEDIUM_DURATION: return "MEDIUM_DURATION";
      case TREND_LONG_DURATION: return "LONG_DURATION";
      case TREND_PERSISTENT: return "PERSISTENT";
      case TREND_SUSTAINABLE: return "SUSTAINABLE";
      
      // Hacim onaylı
      case TREND_VOLUME_WEAK: return "VOLUME_WEAK";
      case TREND_VOLUME_MODERATE: return "VOLUME_MODERATE";
      case TREND_VOLUME_STRONG: return "VOLUME_STRONG";
      case TREND_VOLUME_EXPLOSIVE: return "VOLUME_EXPLOSIVE";
      case TREND_VOLUME_DIVERGENT: return "VOLUME_DIVERGENT";
      
      // Multi-timeframe
      case TREND_MTF_WEAK: return "MTF_WEAK";
      case TREND_MTF_MODERATE: return "MTF_MODERATE";
      case TREND_MTF_STRONG: return "MTF_STRONG";
      case TREND_MTF_UNANIMOUS: return "MTF_UNANIMOUS";
      case TREND_MTF_CONFLICTING: return "MTF_CONFLICTING";
      
      // İstatistiksel
      case TREND_STATISTICAL_WEAK: return "STATISTICAL_WEAK";
      case TREND_STATISTICAL_SIGNIFICANT: return "STATISTICAL_SIGNIFICANT";
      case TREND_STATISTICAL_STRONG: return "STATISTICAL_STRONG";
      case TREND_STATISTICAL_ROBUST: return "STATISTICAL_ROBUST";
      
      // ML bazlı
      case TREND_ML_CONFIDENCE_LOW: return "ML_CONFIDENCE_LOW";
      case TREND_ML_CONFIDENCE_MEDIUM: return "ML_CONFIDENCE_MEDIUM";
      case TREND_ML_CONFIDENCE_HIGH: return "ML_CONFIDENCE_HIGH";
      case TREND_ML_CONFIDENCE_EXTREME: return "ML_CONFIDENCE_EXTREME";
      case TREND_ML_ENSEMBLE_WEAK: return "ML_ENSEMBLE_WEAK";
      case TREND_ML_ENSEMBLE_STRONG: return "ML_ENSEMBLE_STRONG";
      
      default: return "UNKNOWN";
   }
}
//+------------------------------------------------------------------+
//| MACD String Conversion Functions                                 |
//+------------------------------------------------------------------+
string MACDSignalTypeToString(ENUM_MACD_SIGNAL_TYPE signal_type)
{
   switch(signal_type)
   {
      case MACD_SIGNAL_LINE_CROSS_UP: return "SIGNAL_LINE_CROSS_UP";
      case MACD_SIGNAL_LINE_CROSS_DOWN: return "SIGNAL_LINE_CROSS_DOWN";
      case MACD_ZERO_LINE_CROSS_UP: return "ZERO_LINE_CROSS_UP";
      case MACD_ZERO_LINE_CROSS_DOWN: return "ZERO_LINE_CROSS_DOWN";
      case MACD_HISTOGRAM_REVERSAL_UP: return "HISTOGRAM_REVERSAL_UP";
      case MACD_HISTOGRAM_REVERSAL_DOWN: return "HISTOGRAM_REVERSAL_DOWN";
      case MACD_DIVERGENCE_BULLISH: return "DIVERGENCE_BULLISH";
      case MACD_DIVERGENCE_BEARISH: return "DIVERGENCE_BEARISH";
      case MACD_HIDDEN_DIV_BULLISH: return "HIDDEN_DIV_BULLISH";
      case MACD_HIDDEN_DIV_BEARISH: return "HIDDEN_DIV_BEARISH";
      case MACD_SIGNAL_NONE: return "NONE";
      default: return "UNKNOWN";
   }
}

string MACDConditionToString(ENUM_MACD_CONDITION condition)
{
   switch(condition)
   {
      case MACD_BULLISH_STRONG: return "BULLISH_STRONG";
      case MACD_BULLISH_MODERATE: return "BULLISH_MODERATE";
      case MACD_BULLISH_WEAK: return "BULLISH_WEAK";
      case MACD_NEUTRAL: return "NEUTRAL";
      case MACD_BEARISH_WEAK: return "BEARISH_WEAK";
      case MACD_BEARISH_MODERATE: return "BEARISH_MODERATE";
      case MACD_BEARISH_STRONG: return "BEARISH_STRONG";
      case MACD_CONDITION_UNKNOWN: return "UNKNOWN";
      default: return "INVALID";
   }
}

string MACDMomentumPhaseToString(ENUM_MACD_MOMENTUM_PHASE phase)
{
   switch(phase)
   {
      case MACD_ACCELERATION_UP: return "ACCELERATION_UP";
      case MACD_DECELERATION_UP: return "DECELERATION_UP";
      case MACD_ACCELERATION_DOWN: return "ACCELERATION_DOWN";
      case MACD_DECELERATION_DOWN: return "DECELERATION_DOWN";
      case MACD_MOMENTUM_REVERSAL: return "MOMENTUM_REVERSAL";
      case MACD_MOMENTUM_EXHAUSTION: return "MOMENTUM_EXHAUSTION";
      case MACD_MOMENTUM_UNKNOWN: return "UNKNOWN";
      default: return "INVALID";
   }
}
//+------------------------------------------------------------------+
//| STRING CONVERSION FUNCTIONS - Yeni Enumlar İçin                 |
//+------------------------------------------------------------------+

string IndicatorTypeToString(ENUM_INDICATOR_TYPE indicator_type)
{
   switch(indicator_type)
   {
      case INDICATOR_TREND: return "TREND";
      case INDICATOR_MOMENTUM: return "MOMENTUM";
      case INDICATOR_VOLUME: return "VOLUME";
      case INDICATOR_VOLATILITY: return "VOLATILITY";
      case INDICATOR_SUPPORT_RESISTANCE: return "SUPPORT_RESISTANCE";
      case INDICATOR_OSCILLATOR: return "OSCILLATOR";
      case INDICATOR_CYCLE: return "CYCLE";
      case INDICATOR_BREADTH: return "BREADTH";
      case INDICATOR_SENTIMENT: return "SENTIMENT";
      case INDICATOR_FUNDAMENTAL: return "FUNDAMENTAL";
      case INDICATOR_STATISTICAL: return "STATISTICAL";
      case INDICATOR_PATTERN: return "PATTERN";
      case INDICATOR_AI_ML: return "AI_ML";
      case INDICATOR_CUSTOM: return "CUSTOM";
      default: return "UNKNOWN";
   }
}

string ConfluenceLevelToString(ENUM_CONFLUENCE_LEVEL confluence_level)
{
   switch(confluence_level)
   {
      case CONFLUENCE_NONE: return "NONE";
      case CONFLUENCE_WEAK: return "WEAK";
      case CONFLUENCE_MODERATE: return "MODERATE";
      case CONFLUENCE_STRONG: return "STRONG";
      case CONFLUENCE_VERY_STRONG: return "VERY_STRONG";
      case CONFLUENCE_UNANIMOUS: return "UNANIMOUS";
      default: return "UNKNOWN";
   }
}

string MarketPhaseToString(ENUM_MARKET_PHASE market_phase)
{
   switch(market_phase)
   {
      case MARKET_PHASE_UNDEFINED: return "UNDEFINED";
      case MARKET_PHASE_ACCUMULATION: return "ACCUMULATION";
      case MARKET_PHASE_MARKUP: return "MARKUP";
      case MARKET_PHASE_DISTRIBUTION: return "DISTRIBUTION";
      case MARKET_PHASE_MARKDOWN: return "MARKDOWN";
      case MARKET_PHASE_RECOVERY: return "RECOVERY";
      case MARKET_PHASE_DECLINE: return "DECLINE";
      case MARKET_PHASE_CONSOLIDATION: return "CONSOLIDATION";
      case MARKET_PHASE_BREAKOUT: return "BREAKOUT";
      case MARKET_PHASE_REVERSAL: return "REVERSAL";
      case MARKET_PHASE_CONTINUATION: return "CONTINUATION";
      default: return "UNKNOWN";
   }
}

string TimeframeAlignmentToString(ENUM_TIMEFRAME_ALIGNMENT tf_alignment)
{
   switch(tf_alignment)
   {
      case TF_ALIGNMENT_NONE: return "NONE";
      case TF_ALIGNMENT_WEAK: return "WEAK";
      case TF_ALIGNMENT_MODERATE: return "MODERATE";
      case TF_ALIGNMENT_STRONG: return "STRONG";
      case TF_ALIGNMENT_PERFECT: return "PERFECT";
      case TF_ALIGNMENT_CONFLICTING: return "CONFLICTING";
      default: return "UNKNOWN";
   }
}

string AdaptationStatusToString(ENUM_ADAPTATION_STATUS adaptation_status)
{
   switch(adaptation_status)
   {
      case ADAPTATION_NONE: return "NONE";
      case ADAPTATION_LEARNING: return "LEARNING";
      case ADAPTATION_ADAPTING: return "ADAPTING";
      case ADAPTATION_STABLE: return "STABLE";
      case ADAPTATION_OPTIMIZING: return "OPTIMIZING";
      case ADAPTATION_ERROR: return "ERROR";
      case ADAPTATION_COMPLETE: return "COMPLETE";
      default: return "UNKNOWN";
   }
}

string PerformanceClassToString(ENUM_PERFORMANCE_CLASS performance_class)
{
   switch(performance_class)
   {
      case PERFORMANCE_POOR: return "POOR";
      case PERFORMANCE_BELOW_AVERAGE: return "BELOW_AVERAGE";
      case PERFORMANCE_AVERAGE: return "AVERAGE";
      case PERFORMANCE_ABOVE_AVERAGE: return "ABOVE_AVERAGE";
      case PERFORMANCE_GOOD: return "GOOD";
      case PERFORMANCE_EXCELLENT: return "EXCELLENT";
      case PERFORMANCE_OUTSTANDING: return "OUTSTANDING";
      default: return "UNKNOWN";
   }
}

string ProviderStateToString(ENUM_PROVIDER_STATE provider_state)
{
   switch(provider_state)
   {
      case PROVIDER_INACTIVE: return "INACTIVE";
      case PROVIDER_INITIALIZING: return "INITIALIZING";
      case PROVIDER_ACTIVE: return "ACTIVE";
      case PROVIDER_PAUSED: return "PAUSED";
      case PROVIDER_ERROR: return "ERROR";
      case PROVIDER_MAINTENANCE: return "MAINTENANCE";
      case PROVIDER_UPDATING: return "UPDATING";
      case PROVIDER_SHUTDOWN: return "SHUTDOWN";
      default: return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| GENİŞLETİLMİŞ UTILITY FUNCTIONS                                 |
//+------------------------------------------------------------------+

bool IsValidSignalType(ENUM_SIGNAL_TYPE signal_type)
{
   return (signal_type >= SIGNAL_NONE && signal_type <= SIGNAL_POSITION_SIZING);
}

bool IsValidSignalStrength(ENUM_SIGNAL_STRENGTH signal_strength)
{
   return (signal_strength >= SIGNAL_STRENGTH_NONE && signal_strength <= SIGNAL_ML_PROBABILITY_EXTREME);
}

bool IsValidTrendDirection(ENUM_TREND_DIRECTION trend_direction)
{
   return (trend_direction >= TREND_UNDEFINED && trend_direction <= TREND_CYCLICAL_DOWN);
}

bool IsValidTrendStrength(ENUM_TREND_STRENGTH trend_strength)
{
   return (trend_strength >= TREND_STRENGTH_NONE && trend_strength <= TREND_ML_ENSEMBLE_STRONG);
}

bool IsValidIndicatorType(ENUM_INDICATOR_TYPE indicator_type)
{
   return (indicator_type >= INDICATOR_TREND && indicator_type <= INDICATOR_CUSTOM);
}

bool IsValidConfluenceLevel(ENUM_CONFLUENCE_LEVEL confluence_level)
{
   return (confluence_level >= CONFLUENCE_NONE && confluence_level <= CONFLUENCE_UNANIMOUS);
}

bool IsValidMarketPhase(ENUM_MARKET_PHASE market_phase)
{
   return (market_phase >= MARKET_PHASE_UNDEFINED && market_phase <= MARKET_PHASE_CONTINUATION);
}

// Temel sinyal kontrolleri
bool IsBuySignal(ENUM_SIGNAL_TYPE signal_type)
{
   return (signal_type == SIGNAL_BUY || 
           signal_type == SIGNAL_BREAKOUT_BUY ||
           signal_type == SIGNAL_PULLBACK_BUY ||
           signal_type == SIGNAL_REVERSAL_BUY ||
           signal_type == SIGNAL_CONTINUATION_BUY ||
           signal_type == SIGNAL_DIVERGENCE_BUY ||
           signal_type == SIGNAL_CONSERVATIVE_BUY ||
           signal_type == SIGNAL_MODERATE_BUY ||
           signal_type == SIGNAL_AGGRESSIVE_BUY ||
           signal_type == SIGNAL_SCALP_BUY ||
           signal_type == SIGNAL_INTRADAY_BUY ||
           signal_type == SIGNAL_SWING_BUY ||
           signal_type == SIGNAL_POSITION_BUY);
}

bool IsSellSignal(ENUM_SIGNAL_TYPE signal_type)
{
   return (signal_type == SIGNAL_SELL ||
           signal_type == SIGNAL_BREAKOUT_SELL ||
           signal_type == SIGNAL_PULLBACK_SELL ||
           signal_type == SIGNAL_REVERSAL_SELL ||
           signal_type == SIGNAL_CONTINUATION_SELL ||
           signal_type == SIGNAL_DIVERGENCE_SELL ||
           signal_type == SIGNAL_CONSERVATIVE_SELL ||
           signal_type == SIGNAL_MODERATE_SELL ||
           signal_type == SIGNAL_AGGRESSIVE_SELL ||
           signal_type == SIGNAL_SCALP_SELL ||
           signal_type == SIGNAL_INTRADAY_SELL ||
           signal_type == SIGNAL_SWING_SELL ||
           signal_type == SIGNAL_POSITION_SELL);
}

bool IsExitSignal(ENUM_SIGNAL_TYPE signal_type)
{
   return (signal_type == SIGNAL_CLOSE ||
           signal_type == SIGNAL_EMERGENCY_EXIT ||
           signal_type == SIGNAL_STOP_LOSS ||
           signal_type == SIGNAL_TAKE_PROFIT ||
           signal_type == SIGNAL_TRAILING_STOP);
}

bool IsMLBasedSignal(ENUM_SIGNAL_TYPE signal_type)
{
   return (signal_type == SIGNAL_ML_BASED ||
           signal_type == SIGNAL_AI_HIGH_CONFIDENCE ||
           signal_type == SIGNAL_AI_MEDIUM_CONFIDENCE ||
           signal_type == SIGNAL_AI_LOW_CONFIDENCE ||
           signal_type == SIGNAL_ENSEMBLE_CONSENSUS ||
           signal_type == SIGNAL_DEEP_LEARNING ||
           signal_type == SIGNAL_REINFORCEMENT);
}

// Güç seviyesi kontrolleri
bool IsStrongSignal(ENUM_SIGNAL_STRENGTH signal_strength)
{
   return (signal_strength == SIGNAL_STRONG ||
           signal_strength == SIGNAL_VERY_STRONG ||
           signal_strength == SIGNAL_EXTREME ||
           signal_strength == SIGNAL_HIGH_CONFIDENCE ||
           signal_strength == SIGNAL_VERY_HIGH_CONFIDENCE ||
           signal_strength == SIGNAL_MULTIPLE_CONFIRMATION ||
           signal_strength == SIGNAL_UNANIMOUS_CONSENSUS ||
           signal_strength == SIGNAL_MOMENTUM_STRONG ||
           signal_strength == SIGNAL_MOMENTUM_EXPLOSIVE ||
           signal_strength == SIGNAL_ML_PROBABILITY_HIGH ||
           signal_strength == SIGNAL_ML_PROBABILITY_EXTREME);
}

bool IsWeakSignal(ENUM_SIGNAL_STRENGTH signal_strength)
{
   return (signal_strength == SIGNAL_VERY_WEAK ||
           signal_strength == SIGNAL_WEAK ||
           signal_strength == SIGNAL_LOW_CONFIDENCE ||
           signal_strength == SIGNAL_SINGLE_INDICATOR ||
           signal_strength == SIGNAL_MOMENTUM_WEAK ||
           signal_strength == SIGNAL_ML_PROBABILITY_LOW);
}

// Trend kontrolleri
bool IsBullishTrend(ENUM_TREND_DIRECTION trend_direction)
{
   return (trend_direction == TREND_BULLISH ||
           trend_direction == TREND_STRONG_BULLISH ||
           trend_direction == TREND_PARABOLIC_UP ||
           trend_direction == TREND_EXPLOSIVE_UP ||
           trend_direction == TREND_EARLY_BULLISH ||
           trend_direction == TREND_MATURE_BULLISH ||
           trend_direction == TREND_LATE_BULLISH ||
           trend_direction == TREND_REVERSAL_TO_BULLISH ||
           trend_direction == TREND_STRENGTHENING_BULLISH ||
           trend_direction == TREND_SHORT_TERM_BULLISH ||
           trend_direction == TREND_MEDIUM_TERM_BULLISH ||
           trend_direction == TREND_LONG_TERM_BULLISH ||
           trend_direction == TREND_SEASONAL_BULLISH ||
           trend_direction == TREND_CYCLICAL_UP);
}

bool IsBearishTrend(ENUM_TREND_DIRECTION trend_direction)
{
   return (trend_direction == TREND_BEARISH ||
           trend_direction == TREND_STRONG_BEARISH ||
           trend_direction == TREND_PARABOLIC_DOWN ||
           trend_direction == TREND_EXPLOSIVE_DOWN ||
           trend_direction == TREND_EARLY_BEARISH ||
           trend_direction == TREND_MATURE_BEARISH ||
           trend_direction == TREND_LATE_BEARISH ||
           trend_direction == TREND_REVERSAL_TO_BEARISH ||
           trend_direction == TREND_STRENGTHENING_BEARISH ||
           trend_direction == TREND_SHORT_TERM_BEARISH ||
           trend_direction == TREND_MEDIUM_TERM_BEARISH ||
           trend_direction == TREND_LONG_TERM_BEARISH ||
           trend_direction == TREND_SEASONAL_BEARISH ||
           trend_direction == TREND_CYCLICAL_DOWN);
}

bool IsNeutralTrend(ENUM_TREND_DIRECTION trend_direction)
{
   return (trend_direction == TREND_NEUTRAL ||
           trend_direction == TREND_SIDEWAYS ||
           trend_direction == TREND_RANGING ||
           trend_direction == TREND_CONSOLIDATING ||
           trend_direction == TREND_UNDEFINED);
}

bool IsStrongTrend(ENUM_TREND_STRENGTH trend_strength)
{
   return (trend_strength == TREND_STRONG ||
           trend_strength == TREND_VERY_STRONG ||
           trend_strength == TREND_EXTREME ||
           trend_strength == TREND_MOMENTUM_ACCELERATING ||
           trend_strength == TREND_MOMENTUM_EXPLOSIVE ||
           trend_strength == TREND_VOLUME_STRONG ||
           trend_strength == TREND_VOLUME_EXPLOSIVE ||
           trend_strength == TREND_MTF_STRONG ||
           trend_strength == TREND_MTF_UNANIMOUS ||
           trend_strength == TREND_STATISTICAL_STRONG ||
           trend_strength == TREND_STATISTICAL_ROBUST ||
           trend_strength == TREND_ML_CONFIDENCE_HIGH ||
           trend_strength == TREND_ML_CONFIDENCE_EXTREME ||
           trend_strength == TREND_ML_ENSEMBLE_STRONG);
}

bool IsWeakTrend(ENUM_TREND_STRENGTH trend_strength)
{
   return (trend_strength == TREND_VERY_WEAK ||
           trend_strength == TREND_WEAK ||
           trend_strength == TREND_MODERATE_WEAK ||
           trend_strength == TREND_MOMENTUM_DECLINING ||
           trend_strength == TREND_VOLUME_WEAK ||
           trend_strength == TREND_MTF_WEAK ||
           trend_strength == TREND_STATISTICAL_WEAK ||
           trend_strength == TREND_ML_CONFIDENCE_LOW ||
           trend_strength == TREND_ML_ENSEMBLE_WEAK);
}

// Uyumluluk fonksiyonları
bool IsSignalCompatible(ENUM_SIGNAL_TYPE signal1, ENUM_SIGNAL_TYPE signal2)
{
   if(signal1 == SIGNAL_NONE || signal2 == SIGNAL_NONE)
      return false;
   
   bool both_buy = IsBuySignal(signal1) && IsBuySignal(signal2);
   bool both_sell = IsSellSignal(signal1) && IsSellSignal(signal2);
   
   return (both_buy || both_sell);
}

bool IsSignalTrendCompatible(ENUM_SIGNAL_TYPE signal_type, ENUM_TREND_DIRECTION trend_direction)
{
   if(signal_type == SIGNAL_NONE || trend_direction == TREND_UNDEFINED)
      return false;
      
   bool buy_signal_bullish_trend = IsBuySignal(signal_type) && IsBullishTrend(trend_direction);
   bool sell_signal_bearish_trend = IsSellSignal(signal_type) && IsBearishTrend(trend_direction);
   
   return (buy_signal_bullish_trend || sell_signal_bearish_trend);
}
//+------------------------------------------------------------------+
//| MACD Validation Functions                                        |
//+------------------------------------------------------------------+
bool IsValidMACDSignalType(ENUM_MACD_SIGNAL_TYPE signal_type)
{
   return (signal_type >= MACD_SIGNAL_NONE && signal_type <= MACD_HIDDEN_DIV_BEARISH);
}

bool IsValidMACDCondition(ENUM_MACD_CONDITION condition)
{
   return (condition >= MACD_CONDITION_UNKNOWN && condition <= MACD_BEARISH_STRONG);
}

bool IsValidMACDMomentumPhase(ENUM_MACD_MOMENTUM_PHASE phase)
{
   return (phase >= MACD_MOMENTUM_UNKNOWN && phase <= MACD_MOMENTUM_EXHAUSTION);
}
//+------------------------------------------------------------------+
//| MACD Utility Functions                                           |
//+------------------------------------------------------------------+
bool IsBullishMACDSignal(ENUM_MACD_SIGNAL_TYPE signal_type)
{
   return (signal_type == MACD_SIGNAL_LINE_CROSS_UP ||
           signal_type == MACD_ZERO_LINE_CROSS_UP ||
           signal_type == MACD_HISTOGRAM_REVERSAL_UP ||
           signal_type == MACD_DIVERGENCE_BULLISH ||
           signal_type == MACD_HIDDEN_DIV_BULLISH);
}

bool IsBearishMACDSignal(ENUM_MACD_SIGNAL_TYPE signal_type)
{
   return (signal_type == MACD_SIGNAL_LINE_CROSS_DOWN ||
           signal_type == MACD_ZERO_LINE_CROSS_DOWN ||
           signal_type == MACD_HISTOGRAM_REVERSAL_DOWN ||
           signal_type == MACD_DIVERGENCE_BEARISH ||
           signal_type == MACD_HIDDEN_DIV_BEARISH);
}

bool IsBullishMACDCondition(ENUM_MACD_CONDITION condition)
{
   return (condition == MACD_BULLISH_WEAK ||
           condition == MACD_BULLISH_MODERATE ||
           condition == MACD_BULLISH_STRONG);
}

bool IsBearishMACDCondition(ENUM_MACD_CONDITION condition)
{
   return (condition == MACD_BEARISH_WEAK ||
           condition == MACD_BEARISH_MODERATE ||
           condition == MACD_BEARISH_STRONG);
}

bool IsAcceleratingPhase(ENUM_MACD_MOMENTUM_PHASE phase)
{
   return (phase == MACD_ACCELERATION_UP || phase == MACD_ACCELERATION_DOWN);
}

bool IsDeceleratingPhase(ENUM_MACD_MOMENTUM_PHASE phase)
{
   return (phase == MACD_DECELERATION_UP || phase == MACD_DECELERATION_DOWN);
}

bool IsReversalPhase(ENUM_MACD_MOMENTUM_PHASE phase)
{
   return (phase == MACD_MOMENTUM_REVERSAL || phase == MACD_MOMENTUM_EXHAUSTION);
}


//+------------------------------------------------------------------+
//| UTILITY FUNCTIONS - Yeni Enumlar İçin                          |
//+------------------------------------------------------------------+

ENUM_CONFLUENCE_LEVEL CalculateConfluenceLevel(int indicator_count)
{
   if(indicator_count <= 0)
      return CONFLUENCE_NONE;
   else if(indicator_count <= 2)
      return CONFLUENCE_WEAK;
   else if(indicator_count <= 4)
      return CONFLUENCE_MODERATE;
   else if(indicator_count <= 6)
      return CONFLUENCE_STRONG;
   else if(indicator_count <= 8)
      return CONFLUENCE_VERY_STRONG;
   else
      return CONFLUENCE_UNANIMOUS;
}

ENUM_TIMEFRAME_ALIGNMENT CalculateTimeframeAlignment(int aligned_tf_count, int total_tf_count)
{
   if(total_tf_count <= 0)
      return TF_ALIGNMENT_NONE;
      
   double alignment_ratio = (double)aligned_tf_count / total_tf_count;
   
   if(alignment_ratio >= 0.90)
      return TF_ALIGNMENT_PERFECT;
   else if(alignment_ratio >= 0.70)
      return TF_ALIGNMENT_STRONG;
   else if(alignment_ratio >= 0.50)
      return TF_ALIGNMENT_MODERATE;
   else if(alignment_ratio >= 0.30)
      return TF_ALIGNMENT_WEAK;
   else
      return TF_ALIGNMENT_CONFLICTING;
}

ENUM_PERFORMANCE_CLASS CalculatePerformanceClass(double success_rate)
{
   if(success_rate >= 95.0)
      return PERFORMANCE_OUTSTANDING;
   else if(success_rate >= 85.0)
      return PERFORMANCE_EXCELLENT;
   else if(success_rate >= 75.0)
      return PERFORMANCE_GOOD;
   else if(success_rate >= 65.0)
      return PERFORMANCE_ABOVE_AVERAGE;
   else if(success_rate >= 50.0)
      return PERFORMANCE_AVERAGE;
   else if(success_rate >= 40.0)
      return PERFORMANCE_BELOW_AVERAGE;
   else
      return PERFORMANCE_POOR;
}

// Dönüşüm fonksiyonları
ENUM_SIGNAL_TYPE InverseSignal(ENUM_SIGNAL_TYPE signal_type)
{
   if(IsBuySignal(signal_type))
   {
      switch(signal_type)
      {
         case SIGNAL_BUY: return SIGNAL_SELL;
         case SIGNAL_BREAKOUT_BUY: return SIGNAL_BREAKOUT_SELL;
         case SIGNAL_PULLBACK_BUY: return SIGNAL_PULLBACK_SELL;
         case SIGNAL_REVERSAL_BUY: return SIGNAL_REVERSAL_SELL;
         case SIGNAL_CONTINUATION_BUY: return SIGNAL_CONTINUATION_SELL;
         case SIGNAL_DIVERGENCE_BUY: return SIGNAL_DIVERGENCE_SELL;
         case SIGNAL_CONSERVATIVE_BUY: return SIGNAL_CONSERVATIVE_SELL;
         case SIGNAL_MODERATE_BUY: return SIGNAL_MODERATE_SELL;
         case SIGNAL_AGGRESSIVE_BUY: return SIGNAL_AGGRESSIVE_SELL;
         case SIGNAL_SCALP_BUY: return SIGNAL_SCALP_SELL;
         case SIGNAL_INTRADAY_BUY: return SIGNAL_INTRADAY_SELL;
         case SIGNAL_SWING_BUY: return SIGNAL_SWING_SELL;
         case SIGNAL_POSITION_BUY: return SIGNAL_POSITION_SELL;
         default: return SIGNAL_SELL;
      }
   }
   else if(IsSellSignal(signal_type))
   {
      switch(signal_type)
      {
         case SIGNAL_SELL: return SIGNAL_BUY;
         case SIGNAL_BREAKOUT_SELL: return SIGNAL_BREAKOUT_BUY;
         case SIGNAL_PULLBACK_SELL: return SIGNAL_PULLBACK_BUY;
         case SIGNAL_REVERSAL_SELL: return SIGNAL_REVERSAL_BUY;
         case SIGNAL_CONTINUATION_SELL: return SIGNAL_CONTINUATION_BUY;
         case SIGNAL_DIVERGENCE_SELL: return SIGNAL_DIVERGENCE_BUY;
         case SIGNAL_CONSERVATIVE_SELL: return SIGNAL_CONSERVATIVE_BUY;
         case SIGNAL_MODERATE_SELL: return SIGNAL_MODERATE_BUY;
         case SIGNAL_AGGRESSIVE_SELL: return SIGNAL_AGGRESSIVE_BUY;
         case SIGNAL_SCALP_SELL: return SIGNAL_SCALP_BUY;
         case SIGNAL_INTRADAY_SELL: return SIGNAL_INTRADAY_BUY;
         case SIGNAL_SWING_SELL: return SIGNAL_SWING_BUY;
         case SIGNAL_POSITION_SELL: return SIGNAL_POSITION_BUY;
         default: return SIGNAL_BUY;
      }
   }
   
   return SIGNAL_NONE;
}

ENUM_SIGNAL_TYPE TrendToSignal(ENUM_TREND_DIRECTION trend)
{
   if(IsBullishTrend(trend))
      return SIGNAL_BUY;
   else if(IsBearishTrend(trend))
      return SIGNAL_SELL;
   else
      return SIGNAL_NONE;
}

ENUM_TREND_DIRECTION SignalToTrend(ENUM_SIGNAL_TYPE signal)
{
   if(IsBuySignal(signal))
      return TREND_BULLISH;
   else if(IsSellSignal(signal))
      return TREND_BEARISH;
   else
      return TREND_NEUTRAL;
}

// Gelişmiş hesaplama fonksiyonları
ENUM_SIGNAL_STRENGTH CalculateSignalStrength(double confidence, int confluence_count, bool volume_confirmation, bool multi_timeframe)
{
   double strength_score = confidence;
   
   // Confluence bonus
   if(confluence_count >= 5)
      strength_score += 0.2;
   else if(confluence_count >= 3)
      strength_score += 0.1;
   else if(confluence_count >= 2)
      strength_score += 0.05;
   
   // Volume confirmation bonus
   if(volume_confirmation)
      strength_score += 0.1;
   
   // Multi-timeframe bonus
   if(multi_timeframe)
      strength_score += 0.15;
   
   // Normalize
   if(strength_score > 1.0) strength_score = 1.0;
   
   if(strength_score >= 0.95)
      return SIGNAL_EXTREME;
   else if(strength_score >= 0.85)
      return SIGNAL_VERY_STRONG;
   else if(strength_score >= 0.70)
      return SIGNAL_STRONG;
   else if(strength_score >= 0.55)
      return SIGNAL_MODERATE;
   else if(strength_score >= 0.35)
      return SIGNAL_WEAK;
   else
      return SIGNAL_VERY_WEAK;
}

ENUM_TREND_STRENGTH CalculateTrendStrength(double momentum, double duration_hours, double volume_ratio, double atr_ratio)
{
   double strength_score = 0.0;
   
   // Momentum component (40%)
   strength_score += momentum * 0.4;
   
   // Duration component (25%)
   double duration_score = MathMin(duration_hours / 168.0, 1.0); // Normalize to weekly
   strength_score += duration_score * 0.25;
   
   // Volume component (20%)
   double vol_score = MathMin(volume_ratio / 2.0, 1.0); // Normalize to 2x average
   strength_score += vol_score * 0.20;
   
   // ATR component (15%)
   double atr_score = MathMin(atr_ratio / 1.5, 1.0); // Normalize to 1.5x average
   strength_score += atr_score * 0.15;
   
   if(strength_score >= 0.90)
      return TREND_EXTREME;
   else if(strength_score >= 0.80)
      return TREND_VERY_STRONG;
   else if(strength_score >= 0.65)
      return TREND_STRONG;
   else if(strength_score >= 0.50)
      return TREND_MODERATE;
   else if(strength_score >= 0.35)
      return TREND_WEAK;
   else
      return TREND_VERY_WEAK;
}

//+------------------------------------------------------------------+
//| Complete_Enum_Types.mqh'ye EKLEYİN - Eksik Fonksiyonlar        |
//| Bu kodu Complete_Enum_Types.mqh dosyanızın sonuna ekleyin       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| EKSİK STRING CONVERSION FUNCTIONS - Complete_Enum_Types için    |
//+------------------------------------------------------------------+

string MLModelStateToString(ENUM_ML_MODEL_STATE state)
{
   switch(state)
   {
      case ML_STATE_NOT_INITIALIZED: return "NOT_INITIALIZED";
      case ML_STATE_TRAINING: return "TRAINING";
      case ML_STATE_VALIDATING: return "VALIDATING";
      case ML_STATE_TESTING: return "TESTING";
      case ML_STATE_READY: return "READY";
      case ML_STATE_PREDICTING: return "PREDICTING";
      case ML_STATE_UPDATING: return "UPDATING";
      case ML_STATE_ERROR: return "ERROR";
      case ML_STATE_OVERFITTED: return "OVERFITTED";
      case ML_STATE_UNDERFITTED: return "UNDERFITTED";
      case ML_STATE_CONVERGED: return "CONVERGED";
      default: return "UNKNOWN";
   }
}

string SignalQualityToString(ENUM_SIGNAL_QUALITY quality)
{
   switch(quality)
   {
      case SIGNAL_QUALITY_VERY_POOR: return "VERY_POOR";
      case SIGNAL_QUALITY_POOR: return "POOR";
      case SIGNAL_QUALITY_FAIR: return "FAIR";
      case SIGNAL_QUALITY_GOOD: return "GOOD";
      case SIGNAL_QUALITY_VERY_GOOD: return "VERY_GOOD";
      case SIGNAL_QUALITY_EXCELLENT: return "EXCELLENT";
      case SIGNAL_QUALITY_PRISTINE: return "PRISTINE";
      default: return "UNKNOWN";
   }
}

string RiskLevelToString(ENUM_RISK_LEVEL risk_level)
{
   switch(risk_level)
   {
      case RISK_VERY_LOW: return "VERY_LOW";
      case RISK_LOW: return "LOW";
      case RISK_MEDIUM: return "MEDIUM";
      case RISK_HIGH: return "HIGH";
      case RISK_VERY_HIGH: return "VERY_HIGH";
      default: return "UNKNOWN";
   }
}

string MLModelTypeToString(ENUM_ML_MODEL_TYPE model_type)
{
   switch(model_type)
   {
      case ML_NONE: return "NONE";
      case ML_LINEAR_REGRESSION: return "LINEAR_REGRESSION";
      case ML_LOGISTIC_REGRESSION: return "LOGISTIC_REGRESSION";
      case ML_DECISION_TREE: return "DECISION_TREE";
      case ML_RANDOM_FOREST: return "RANDOM_FOREST";
      case ML_SVM: return "SVM";
      case ML_NEURAL_NETWORK: return "NEURAL_NETWORK";
      case ML_LSTM: return "LSTM";
      case ML_GRU: return "GRU";
      case ML_CNN: return "CNN";
      case ML_ENSEMBLE: return "ENSEMBLE";
      case ML_REINFORCEMENT: return "REINFORCEMENT";
      case ML_GENETIC_ALGORITHM: return "GENETIC_ALGORITHM";
      case ML_FUZZY_LOGIC: return "FUZZY_LOGIC";
      case ML_BAYESIAN_NETWORK: return "BAYESIAN_NETWORK";
      default: return "UNKNOWN";
   }
}

string MLAdaptationTypeToString(ENUM_ML_ADAPTATION_TYPE adaptation_type)
{
   switch(adaptation_type)
   {
      case ML_ADAPT_NONE: return "NONE";
      case ML_ADAPT_ONLINE_LEARNING: return "ONLINE_LEARNING";
      case ML_ADAPT_INCREMENTAL: return "INCREMENTAL";
      case ML_ADAPT_TRANSFER_LEARNING: return "TRANSFER_LEARNING";
      case ML_ADAPT_META_LEARNING: return "META_LEARNING";
      case ML_ADAPT_ENSEMBLE_UPDATE: return "ENSEMBLE_UPDATE";
      case ML_ADAPT_DRIFT_DETECTION: return "DRIFT_DETECTION";
      case ML_ADAPT_CONCEPT_DRIFT: return "CONCEPT_DRIFT";
      case ML_ADAPT_REGIME_CHANGE: return "REGIME_CHANGE";
      case ML_ADAPT_VOLATILITY_REGIME: return "VOLATILITY_REGIME";
      case ML_ADAPT_MARKET_PHASE: return "MARKET_PHASE";
      case ML_ADAPT_FEEDBACK_LOOP: return "FEEDBACK_LOOP";
      case ML_ADAPT_REINFORCEMENT: return "REINFORCEMENT";
      case ML_ADAPT_EVOLUTIONARY: return "EVOLUTIONARY";
      default: return "UNKNOWN";
   }
}

string DivergenceTypeToString(ENUM_DIVERGENCE_TYPE divergence_type)
{
   switch(divergence_type)
   {
      case DIVERGENCE_NONE: return "NONE";
      case DIVERGENCE_REGULAR_BULLISH: return "REGULAR_BULLISH";
      case DIVERGENCE_REGULAR_BEARISH: return "REGULAR_BEARISH";
      case DIVERGENCE_HIDDEN_BULLISH: return "HIDDEN_BULLISH";
      case DIVERGENCE_HIDDEN_BEARISH: return "HIDDEN_BEARISH";
      default: return "UNKNOWN";
   }
}

string SignalTimingToString(ENUM_SIGNAL_TIMING timing)
{
   switch(timing)
   {
      case SIGNAL_TIMING_EARLY: return "EARLY";
      case SIGNAL_TIMING_OPTIMAL: return "OPTIMAL";
      case SIGNAL_TIMING_LATE: return "LATE";
      case SIGNAL_TIMING_MISSED: return "MISSED";
      default: return "UNKNOWN";
   }
}

string PivotTypeToString(ENUM_PIVOT_TYPE pivot_type)
{
   switch(pivot_type)
   {
      case PIVOT_STANDARD: return "STANDARD";
      case PIVOT_FIBONACCI: return "FIBONACCI";
      case PIVOT_CAMARILLA: return "CAMARILLA";
      case PIVOT_WOODIE:  return "WOODIE";
      case PIVOT_DEMARK: return "DEMARK";
      case PIVOT_CLASSICAL: return "CLASSICAL";
      default: return "UNKNOWN";
   }
}

string MarketSentimentToString(ENUM_MARKET_SENTIMENT sentiment)
{
   switch(sentiment)
   {
      case SENTIMENT_VERY_BEARISH: return "VERY_BEARISH";
      case SENTIMENT_BEARISH: return "BEARISH";
      case SENTIMENT_NEUTRAL: return "NEUTRAL";
      case SENTIMENT_BULLISH: return "BULLISH";
      case SENTIMENT_VERY_BULLISH: return "VERY_BULLISH";
      default: return "UNKNOWN";
   }
}

string VolumeStateToString(ENUM_VOLUME_STATE volume_state)
{
   switch(volume_state)
   {
      case VOLUME_LOW: return "LOW";
      case VOLUME_NORMAL: return "NORMAL";
      case VOLUME_HIGH: return "HIGH";
      case VOLUME_SPIKE: return "SPIKE";
      default: return "UNKNOWN";
   }
}

string TrendContinuityToString(ENUM_TREND_CONTINUITY continuity)
{
   switch(continuity)
   {
      case TREND_CONT_BROKEN: return "BROKEN";
      case TREND_CONT_WEAK: return "WEAK";
      case TREND_CONT_MODERATE: return "MODERATE";
      case TREND_CONT_STRONG: return "STRONG";
      case TREND_CONT_PERSISTENT: return "PERSISTENT";
      default: return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| EKSİK VALIDATION FUNCTIONS - Complete_Enum_Types için           |
//+------------------------------------------------------------------+

bool IsValidSignalQuality(ENUM_SIGNAL_QUALITY quality)
{
   return (quality >= SIGNAL_QUALITY_VERY_POOR && quality <= SIGNAL_QUALITY_PRISTINE);
}

bool IsValidMLModelState(ENUM_ML_MODEL_STATE state)
{
   return (state >= ML_STATE_NOT_INITIALIZED && state <= ML_STATE_CONVERGED);
}

bool IsValidMLModelType(ENUM_ML_MODEL_TYPE model_type)
{
   return (model_type >= ML_NONE && model_type <= ML_BAYESIAN_NETWORK);
}

bool IsValidMLAdaptationType(ENUM_ML_ADAPTATION_TYPE adaptation_type)
{
   return (adaptation_type >= ML_ADAPT_NONE && adaptation_type <= ML_ADAPT_EVOLUTIONARY);
}

bool IsValidDivergenceType(ENUM_DIVERGENCE_TYPE divergence_type)
{
   return (divergence_type >= DIVERGENCE_NONE && divergence_type <= DIVERGENCE_HIDDEN_BEARISH);
}

bool IsValidSignalTiming(ENUM_SIGNAL_TIMING timing)
{
   return (timing >= SIGNAL_TIMING_EARLY && timing <= SIGNAL_TIMING_MISSED);
}

bool IsValidPivotType(ENUM_PIVOT_TYPE pivot_type)
{
   return (pivot_type >= PIVOT_STANDARD && pivot_type <= PIVOT_CLASSICAL);
}

bool IsValidMarketSentiment(ENUM_MARKET_SENTIMENT sentiment)
{
   return (sentiment >= SENTIMENT_VERY_BEARISH && sentiment <= SENTIMENT_VERY_BULLISH);
}

bool IsValidVolumeState(ENUM_VOLUME_STATE volume_state)
{
   return (volume_state >= VOLUME_LOW && volume_state <= VOLUME_SPIKE);
}

bool IsValidTrendContinuity(ENUM_TREND_CONTINUITY continuity)
{
   return (continuity >= TREND_CONT_BROKEN && continuity <= TREND_CONT_PERSISTENT);
}

bool IsValidRiskLevel(ENUM_RISK_LEVEL risk_level)
{
   return (risk_level >= RISK_VERY_LOW && risk_level <= RISK_VERY_HIGH);
}

//+------------------------------------------------------------------+
//| GÜVENLİK UTILITY FUNCTIONS - Complete_Enum_Types için           |
//+------------------------------------------------------------------+

bool SafeAddStringToArray(string &array[], int &count, const int max_size, const string value)
{
   if(count >= max_size || count < 0)
   {
      Print(StringFormat("ERROR: Array bounds exceeded. Count: %d, Max: %d", count, max_size));
      return false;
   }
   
   if(StringLen(value) == 0)
   {
      Print("WARNING: Empty string value provided");
      return false;
   }
   
   array[count] = value;
   count++;
   return true;
}

string SafeGetStringFromArray(const string &array[], const int index, const int array_size, const string default_value = "")
{
   if(index < 0 || index >= array_size)
   {
      Print(StringFormat("WARNING: Array index out of bounds. Index: %d, Size: %d", index, array_size));
      return default_value;
   }
   
   return array[index];
}

//+------------------------------------------------------------------+
//| EXTENDED VALIDATION FUNCTION                                     |
//+------------------------------------------------------------------+

bool ValidateAllEnumsExtended()
{
   bool result = true;
   int error_count = 0;
   
   Print("Starting extended enum validation...");
   
   // Test signal quality validation
   if(!IsValidSignalQuality(SIGNAL_QUALITY_GOOD))
   {
      Print("ERROR: Signal quality validation failed");
      result = false;
      error_count++;
   }
   
   // Test ML model state validation
   if(!IsValidMLModelState(ML_STATE_READY))
   {
      Print("ERROR: ML model state validation failed");
      result = false;
      error_count++;
   }
   
   // Test risk level validation
   if(!IsValidRiskLevel(RISK_MEDIUM))
   {
      Print("ERROR: Risk level validation failed");
      result = false;
      error_count++;
   }
   
   // Test string conversions
   if(StringLen(SignalQualityToString(SIGNAL_QUALITY_EXCELLENT)) == 0)
   {
      Print("ERROR: SignalQualityToString failed");
      result = false;
      error_count++;
   }
   
   if(StringLen(MLModelStateToString(ML_STATE_READY)) == 0)
   {
      Print("ERROR: MLModelStateToString failed");
      result = false;
      error_count++;
   }
   
   if(StringLen(RiskLevelToString(RISK_MEDIUM)) == 0)
   {
      Print("ERROR: RiskLevelToString failed");
      result = false;
      error_count++;
   }
   
   // Test ML types
   if(StringLen(MLModelTypeToString(ML_NEURAL_NETWORK)) == 0)
   {
      Print("ERROR: MLModelTypeToString failed");
      result = false;
      error_count++;
   }
   
   if(StringLen(MLAdaptationTypeToString(ML_ADAPT_ONLINE_LEARNING)) == 0)
   {
      Print("ERROR: MLAdaptationTypeToString failed");
      result = false;
      error_count++;
   }
   
   // Test other types
   if(StringLen(DivergenceTypeToString(DIVERGENCE_REGULAR_BULLISH)) == 0)
   {
      Print("ERROR: DivergenceTypeToString failed");
      result = false;
      error_count++;
   }
   
   if(StringLen(SignalTimingToString(SIGNAL_TIMING_OPTIMAL)) == 0)
   {
      Print("ERROR: SignalTimingToString failed");
      result = false;
      error_count++;
   }
   
   // Test safety functions
   string test_array[5];
   int test_count = 0;
   
   if(!SafeAddStringToArray(test_array, test_count, 5, "Test"))
   {
      Print("ERROR: SafeAddStringToArray failed");
      result = false;
      error_count++;
   }
   
   string retrieved = SafeGetStringFromArray(test_array, 0, test_count);
   if(retrieved != "Test")
   {
      Print("ERROR: SafeGetStringFromArray failed");
      result = false;
      error_count++;
   }
   // Test MACD signal type validation
   if(!IsValidMACDSignalType(MACD_SIGNAL_LINE_CROSS_UP))
   {
      Print("ERROR: MACD signal type validation failed");
      result = false;
      error_count++;
   }
   
   // Test MACD condition validation
   if(!IsValidMACDCondition(MACD_BULLISH_STRONG))
   {
      Print("ERROR: MACD condition validation failed");
      result = false;
      error_count++;
   }
   
   // Test MACD momentum phase validation
   if(!IsValidMACDMomentumPhase(MACD_ACCELERATION_UP))
   {
      Print("ERROR: MACD momentum phase validation failed");
      result = false;
      error_count++;
   }
   
   // Test string conversions
   if(StringLen(MACDSignalTypeToString(MACD_DIVERGENCE_BULLISH)) == 0)
   {
      Print("ERROR: MACDSignalTypeToString failed");
      result = false;
      error_count++;
   }
   
   if(StringLen(MACDConditionToString(MACD_BULLISH_STRONG)) == 0)
   {
      Print("ERROR: MACDConditionToString failed");
      result = false;
      error_count++;
   }
   
   if(StringLen(MACDMomentumPhaseToString(MACD_ACCELERATION_UP)) == 0)
   {
      Print("ERROR: MACDMomentumPhaseToString failed");
      result = false;
      error_count++;
   }
   
   // Test utility functions
   if(!IsBullishMACDSignal(MACD_SIGNAL_LINE_CROSS_UP))
   {
      Print("ERROR: IsBullishMACDSignal failed");
      result = false;
      error_count++;
   }
   
   if(!IsBearishMACDCondition(MACD_BEARISH_STRONG))
   {
      Print("ERROR: IsBearishMACDCondition failed");
      result = false;
      error_count++;
   }
   
   if(result)
   {
      Print("✅ All extended enum validations PASSED!");
   }
   else
   {
      Print(StringFormat("❌ Extended enum validation FAILED! %d errors found.", error_count));
   }
   
   return result;
}

//+------------------------------------------------------------------+

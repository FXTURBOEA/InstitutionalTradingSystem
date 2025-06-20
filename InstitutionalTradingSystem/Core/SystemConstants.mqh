//+------------------------------------------------------------------+
//|                         SystemConstants.mqh                      |
//|        OOP Mimaride Sabit Değerler ve Global Ayarlar            |
//+------------------------------------------------------------------+
#ifndef __SYSTEM_CONSTANTS_MQH__
#define __SYSTEM_CONSTANTS_MQH__

// Yüklenen Kütüphaneler
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>

//+------------------------------------------------------------------+
//| Sabitler                                                         |
//+------------------------------------------------------------------+

// Risk Yönetimi
#define DEFAULT_RISK_PERCENT        1.0
#define MAX_DAILY_DRAWDOWN_PERCENT  5.0
#define DEFAULT_SL_ATR_MULTIPLIER   1.5
#define DEFAULT_TP_MULTIPLIER       2.0

// ATR parametreleri
#define DEFAULT_ATR_PERIOD          14

// RSI parametreleri
#define DEFAULT_RSI_PERIOD          3
#define DEFAULT_RSI_OVERBOUGHT      95
#define DEFAULT_RSI_OVERSOLD        5

// Saat dilimi kontrolü
#define DEFAULT_TRADING_SESSION_START_HOUR   8     // London açılışı
#define DEFAULT_TRADING_SESSION_END_HOUR     17    // New York ortası

// Günlük sıfırlama saati
#define DEFAULT_DAILY_RESET_HOUR             0     // Günlük limitler bu saatte sıfırlanır

//+------------------------------------------------------------------+
//| Sistem Genel Ayar Nesnesi                                        |
//+------------------------------------------------------------------+
class CSystemSettings
  {
public:
   double   RiskPercent;
   double   MaxDailyDrawdown;
   double   SlAtrMultiplier;
   double   TpMultiplier;
   int      AtrPeriod;
   int      RsiPeriod;
   double   RsiOverbought;
   double   RsiOversold;
   int      SessionStartHour;
   int      SessionEndHour;
   int      DailyResetHour;

   CSystemSettings()
     {
      RiskPercent       = DEFAULT_RISK_PERCENT;
      MaxDailyDrawdown  = MAX_DAILY_DRAWDOWN_PERCENT;
      SlAtrMultiplier   = DEFAULT_SL_ATR_MULTIPLIER;
      TpMultiplier      = DEFAULT_TP_MULTIPLIER;
      AtrPeriod         = DEFAULT_ATR_PERIOD;
      RsiPeriod         = DEFAULT_RSI_PERIOD;
      RsiOverbought     = DEFAULT_RSI_OVERBOUGHT;
      RsiOversold       = DEFAULT_RSI_OVERSOLD;
      SessionStartHour  = DEFAULT_TRADING_SESSION_START_HOUR;
      SessionEndHour    = DEFAULT_TRADING_SESSION_END_HOUR;
      DailyResetHour    = DEFAULT_DAILY_RESET_HOUR;
     }
  };

//+------------------------------------------------------------------+
//| Terminal Nesneleri (Globalde kullanılabilir)                     |
//+------------------------------------------------------------------+
CPositionInfo  g_position;  
CTrade         g_trade;     
CSymbolInfo    g_symbol;    
CAccountInfo   g_account;   
CDealInfo      g_deal;      
COrderInfo     g_order;

//+------------------------------------------------------------------+
#endif // __SYSTEM_CONSTANTS_MQH__

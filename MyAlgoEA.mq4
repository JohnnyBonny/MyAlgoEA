//+------------------------------------------------------------------+
//|                                              baselineEntryEA.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//confirmation 1
double sslBullCur;
double sslBullPrev;
string SSLname = "Downloads\\NEW INDICATORS\\SSL_fast_sBar_alert_mtf_1";
input int lb = 10;
input int sslMaMethod = 0;
int SSLBarLevel = 50;
bool alertsON = false;
bool alertsMessageBox = false;
bool alertsSound = false;
string alertsSoundfile = "TP1M.wav";
bool alertsEmail = false;
bool alertsAfterBarClose = false;
int TimeFrame = 0;
string TimeFrames = "";
string MAMethod = "";

//volume 1
double WAEBullCur;
double WAEBearCur;
double WAEBullPrev;
double WAEBearPrev;
double WAESignalLineCur;
double WAESignalLinePrev;
double WAEDeadPip;
string WAEName = "Downloads\\WAE_Ext";
input int sensetive = 95;
input double deadZonePip = 3.35;
input int explosionPower = 30;
input int trendPower = 30;
input int BBandPeriod = 15;
input double BBandSD = 2.0;
input int FEMA = 15;
input int SEMA = 30;
input int signalMa = 4;
input int atrPeriod = 130;
input int WAEPrice = 0;
bool AlertWindow = false;
int AlertCount = 500;
bool AlertLong = false;
bool AlertShort = false;
bool AlertExitLong = false;
bool AlertExitShort = false;

//volume 2
double damianiVolume;
double damianiNoVolume;
string damianiName = "Downloads\\Volume\\damiani_volatmeter";
input int damianiViscosity = 5;
input int damianiSedimentation = 30;
input int damianiThreshold = 1.25;
input bool damianiLagSupressor = true;

//confimation 2
double DpoValue;
string dpoName = "Downloads\\NEW INDICATORS\\dpo-histogram-indicator";
input int DpoPeriod = 14;
input int DpoSmoothness = 2;

//baseline 1
enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2, // Heiken ashi trend biased (extreme) price
   pr_habclose,   // Heiken ashi (better formula) close
   pr_habopen ,   // Heiken ashi (better formula) open
   pr_habhigh,    // Heiken ashi (better formula) high
   pr_hablow,     // Heiken ashi (better formula) low
   pr_habmedian,  // Heiken ashi (better formula) median
   pr_habtypical, // Heiken ashi (better formula) typical
   pr_habweighted,// Heiken ashi (better formula) weighted
   pr_habaverage, // Heiken ashi (better formula) average
   pr_habmedianb, // Heiken ashi (better formula) median body
   pr_habtbiased, // Heiken ashi (better formula) trend biased price
   pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price
};

double JurikValue;
double JurikTrendCur;
double JurikTrendPrev;
string JurikName = "Downloads\\NEW INDICATORS\\Jurik filter 1.02";
extern ENUM_TIMEFRAMES    JurikTimeFrame       = PERIOD_CURRENT;   // Time frame
extern int                JurikLength          = 30;               // Jurik and filter period to use
extern double             JurikPhase           = 0;              // Jurik phase 
extern bool               JurikDouble          = false;            // Jurik smooth double
extern enPrices           JurikPrice           = pr_habtbiased2;    // Price to use
extern double             JurikFilter          = .2;                // Filter to use for filtering (<=0 for no filtering)
extern int                JurikFilterType      = 2;          // Filter should be applied to :
extern int                JurikDisplayType     = 1;           // Display type
extern int                JurikLinesWidth      = 3;                // Lines width (when lines are included in display)
extern bool               JurikArrowOnFirst    = true;             // Arrow on first bars
extern int                JurikUpArrowSize     = 2;                // Up Arrow size
extern int                JurikDnArrowSize     = 2;                // Down Arrow size
extern int                JurikUpArrowCode     = 159;              // Up Arrow code
extern int                JurikDnArrowCode     = 159;              // Down arrow code
extern double             JurikUpArrowGap      = 0.5;              // Up Arrow gap        
extern double             JurikDnArrowGap      = 0.5;              // Dn Arrow gap
extern color              JurikUpArrowColor    = clrLimeGreen;     // Up Arrow Color
extern color              JurikDnArrowColor    = clrOrange;        // Down Arrow Color
extern int                JurikShift           = 0;                // JMA shift
extern bool               JurikInterpolate     = true;             // Interpolate in multi time frame mode?

//extra variables
int openOrderID1;
int openOrderID2;

input double riskPerTrade = 0.02;

int magicNB1 = 1111;
int magicNB2 = 2222;

double TP;

bool movedTP = false;

double movingSLATR;
double orderSL;
double openPrice;

bool newCandle = false;
bool oneCandleRule = false;

bool continuationTrade = false;

double ATRvaluefromPrice;

bool pullback = false;
int day;
int OnInit()
  {
//---
   day = Day();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentTime = TimeCurrent();
   MqlDateTime clock;
   TimeToStruct(currentTime,clock);
   if(clock.hour == 23 && clock.min >= 45)
   {
      if(!CheckIfOpenOrdersByMagicNB(magicNB2))//checks to see if there are any orders
      {  
         //C1
         sslBullCur = iCustom(NULL, 0, SSLname, lb, sslMaMethod,SSLBarLevel,alertsON,alertsMessageBox,alertsSound,alertsSoundfile,alertsEmail,alertsAfterBarClose,TimeFrame,TimeFrames,MAMethod,0,0);
         sslBullPrev = iCustom(NULL, 0, SSLname, lb, sslMaMethod,SSLBarLevel,alertsON,alertsMessageBox,alertsSound,alertsSoundfile,alertsEmail,alertsAfterBarClose,TimeFrame,TimeFrames,MAMethod,0,1);
         
         //Baseline
         JurikTrendCur = iCustom(NULL,0,JurikName,JurikTimeFrame,JurikLength,JurikPhase,JurikDouble,JurikPrice,JurikFilter,JurikFilterType,JurikDisplayType,JurikLinesWidth,JurikArrowOnFirst,JurikUpArrowSize,JurikDnArrowSize,JurikUpArrowCode,JurikDnArrowCode,JurikUpArrowGap,JurikDnArrowGap,JurikUpArrowColor,JurikDnArrowColor,JurikShift,JurikInterpolate,5,0);
         JurikTrendPrev = iCustom(NULL,0,JurikName,JurikTimeFrame,JurikLength,JurikPhase,JurikDouble,JurikPrice,JurikFilter,JurikFilterType,JurikDisplayType,JurikLinesWidth,JurikArrowOnFirst,JurikUpArrowSize,JurikDnArrowSize,JurikUpArrowCode,JurikDnArrowCode,JurikUpArrowGap,JurikDnArrowGap,JurikUpArrowColor,JurikDnArrowColor,JurikShift,JurikInterpolate,5,1);
         JurikValue = NormalizeDouble(iCustom(NULL,0,JurikName,JurikTimeFrame,JurikLength,JurikPhase,JurikDouble,JurikPrice,JurikFilter,JurikFilterType,JurikDisplayType,JurikLinesWidth,JurikArrowOnFirst,JurikUpArrowSize,JurikDnArrowSize,JurikUpArrowCode,JurikDnArrowCode,JurikUpArrowGap,JurikDnArrowGap,JurikUpArrowColor,JurikDnArrowColor,JurikShift,JurikInterpolate,0,0),Digits);
         
         //C2
         DpoValue = iCustom(NULL, 0, dpoName, DpoPeriod,DpoSmoothness,2,0);
         
         //Volume1
         WAEBullCur = iCustom(NULL, 0, WAEName, sensetive,deadZonePip,explosionPower,trendPower,BBandPeriod,BBandSD,FEMA,SEMA,signalMa,atrPeriod,WAEPrice,AlertWindow,AlertCount,AlertLong,AlertShort,AlertExitLong,AlertExitShort,0,0);
         WAEBearCur = iCustom(NULL, 0, WAEName, sensetive,deadZonePip,explosionPower,trendPower,BBandPeriod,BBandSD,FEMA,SEMA,signalMa,atrPeriod,WAEPrice,AlertWindow,AlertCount,AlertLong,AlertShort,AlertExitLong,AlertExitShort,1,0);
      
         WAEBullPrev = iCustom(NULL, 0, WAEName, sensetive,deadZonePip,explosionPower,trendPower,BBandPeriod,BBandSD,FEMA,SEMA,signalMa,atrPeriod,WAEPrice,AlertWindow,AlertCount,AlertLong,AlertShort,AlertExitLong,AlertExitShort,0,1);
         WAEBearPrev = iCustom(NULL, 0, WAEName, sensetive,deadZonePip,explosionPower,trendPower,BBandPeriod,BBandSD,FEMA,SEMA,signalMa,atrPeriod,WAEPrice,AlertWindow,AlertCount,AlertLong,AlertShort,AlertExitLong,AlertExitShort,1,1);
      
         WAESignalLineCur = iCustom(NULL, 0, WAEName, sensetive,deadZonePip,explosionPower,trendPower,BBandPeriod,BBandSD,FEMA,SEMA,signalMa,atrPeriod,WAEPrice,AlertWindow,AlertCount,AlertLong,AlertShort,AlertExitLong,AlertExitShort,2,0);
         WAESignalLinePrev = iCustom(NULL, 0, WAEName, sensetive,deadZonePip,explosionPower,trendPower,BBandPeriod,BBandSD,FEMA,SEMA,signalMa,atrPeriod,WAEPrice,AlertWindow,AlertCount,AlertLong,AlertShort,AlertExitLong,AlertExitShort,2,1);
      
         WAEDeadPip = iCustom(NULL, 0, WAEName, sensetive,deadZonePip,explosionPower,trendPower,BBandPeriod,BBandSD,FEMA,SEMA,signalMa,atrPeriod,WAEPrice,AlertWindow,AlertCount,AlertLong,AlertShort,AlertExitLong,AlertExitShort,3,0);
         
         //Volume2
         damianiVolume = iCustom(NULL, 0, damianiName, damianiViscosity ,damianiSedimentation,damianiThreshold,damianiLagSupressor,2,0);
         damianiNoVolume = iCustom(NULL, 0, damianiName, damianiViscosity ,damianiSedimentation,damianiThreshold,damianiLagSupressor,0,0);
         
         bool baselineCross = baselineCross();
         if(baselineCross == true)      
            continuationTrade = false;
             
         int pullbackEntry = pullbackEntry();
         if(pullbackEntry == 1)
         {
            Alert("PULLBACK BUY");
            EnterBuy();
            continuationTrade = true;
            oneCandleRule = false;
            pullback = false;
            return;
         }
         
         else if(pullbackEntry == 0)
         {
            Alert("PULLBACK SELL");
            EnterSell();
            continuationTrade = true;
            oneCandleRule = false;
            pullback = false;
            return;
         }
         
         int continuationEntry = continuationEntry();
         if(continuationEntry == 1)
         {
            Alert("CONTINUATION BUY");
            EnterBuy();
            continuationTrade = true;
            oneCandleRule = false;
            pullback = false;
            return;
         }
         else if(continuationEntry == 0)
         {
            Alert("CONTINUATION SELL");
            EnterSell();
            continuationTrade = true;
            oneCandleRule = false;
            pullback = false;
            return;
         }
         
         int standardEntry = standardEntry();
         if(standardEntry == 1)
         {
            Alert("STANDARD BUY");
            EnterBuy();
            continuationTrade = true;
            oneCandleRule = false;
            pullback = false;
            return;
         }  
          
         else if(standardEntry == 0)
         {
            Alert("STANDARD SELL");
            EnterSell();
            continuationTrade = true;
            oneCandleRule = false;
            pullback = false;
            return;
         }
         
         int baselineEntry = baselineEntry();
         if(baselineEntry == 1)
         {
            Alert("BASELINE BUY");
            EnterBuy();
            continuationTrade = true;
            oneCandleRule = false;
            pullback = false;
            return;
         }
         
         else if(baselineEntry == 0)
         {
            Alert("BASELINE SELL");
            EnterSell();
            continuationTrade = true;
            oneCandleRule = false;
            pullback = false;
            return;
         }
         
      } 
   }
   if(CheckIfOpenOrdersByMagicNB(magicNB2) && clock.hour == 23 && clock.min >= 45) //else if you already have a position, update orders every 15 mins if need too.
   {
      if(OrderSelect(openOrderID2,SELECT_BY_TICKET))
      {
         int orderType = OrderType();// Short = 1, Long = 0
         
         if(!isOrderExist(openOrderID1))//if the first position closed, moved the second to the first TP
         {
            if(!movedTP)
            {
               movedTP = true;
               double moveStopLoss = NormalizeDouble(OrderOpenPrice(),Digits);
               orderSL = moveStopLoss;
               bool Ans = OrderModify(openOrderID2,OrderOpenPrice(),moveStopLoss,0,0);
               
               if (Ans)      
                  Print("Order modified(moved SL to TP): ",openOrderID2);                       
               
               else
                  Print("Unable to modify order: ",openOrderID2);
               
            }
            
            
            if(orderType == 0)//buy
            {
               double priceDistanceWithATR = NormalizeDouble((Ask - orderSL),Digits) ;
               
               if(priceDistanceWithATR >=  movingSLATR )// if price is more than 2 * ATR from the SL,move SL 
               {
                  
                  double newSL = NormalizeDouble(orderSL + (1.5 * iATR(NULL,0,14,0)),Digits);
                  
                  if(newSL > orderSL && newSL < Ask)
                  {
                     orderSL = newSL;
                     bool Ans = OrderModify(openOrderID2,OrderOpenPrice(),newSL,0,0);
           
                     if (Ans)                     
                     {
                        Print("Order modified(moved SL to 1.5 Atr way from currrent price): ",openOrderID2);
                        return;                           
                     }
                     else
                        Print("Unable to modify order: ",openOrderID2);
                  }
               }
               
            }
            else if(orderType == 1)//short
            {
               double priceDistanceWithATR = NormalizeDouble(MathAbs(orderSL - Bid),Digits);
               if(priceDistanceWithATR >=  movingSLATR)// if price is more than 2 * ATR from the SL,move SL 
               {
                  double newSL =  NormalizeDouble(orderSL - (1.5 * iATR(NULL,0,14,0)),Digits);
                  
                  if(newSL < orderSL)
                  {
                     orderSL = newSL;
                     bool Ans = OrderModify(openOrderID2,OrderOpenPrice(),newSL,0,0);
               
                     if (Ans)                     
                        Print("Order modified(moved SL to 1.5 Atr way from currrent price): ",openOrderID2);
                     else
                        Print("Unable to modify order: ",openOrderID2);
                  }
               }
            }  
         }
         
         if(day != Day())
         {
            day = Day();
            newCandle = true;
            return;
         } 
            
         if(newCandle)
         {
            sslBullCur = iCustom(NULL, 0, SSLname, lb, sslMaMethod,SSLBarLevel,alertsON,alertsMessageBox,alertsSound,alertsSoundfile,alertsEmail,TimeFrame,TimeFrames,MAMethod,0,0);
            JurikTrendCur = iCustom(NULL,0,JurikName,JurikTimeFrame,JurikLength,JurikPhase,JurikDouble,JurikPrice,JurikFilter,JurikFilterType,JurikDisplayType,JurikLinesWidth,JurikArrowOnFirst,JurikUpArrowSize,JurikDnArrowSize,JurikUpArrowCode,JurikDnArrowCode,JurikUpArrowGap,JurikDnArrowGap,JurikUpArrowColor,JurikDnArrowColor,JurikShift,JurikInterpolate,5,0);
      
            if(orderType == 0)//buy signal switches to sell
            {
               
               if(sslBullCur != 50)
               {
                  Alert("C1 switch");
                  closeTrade(orderType);
               }
               
               else if(JurikTrendCur == -1)
               {
                  Alert("baseline switch");
                  closeTrade(orderType);
               }
            }
            else //sell signal switches to a buy
            {
               
               if(sslBullCur == 50)
               {
                  Alert("C1 switch");
                  closeTrade(orderType);
               }
               
               else if(JurikTrendCur == 1)
               {
                  Alert("baseline switch");
                  closeTrade(orderType);
               }
            }
         }

      }
      if(!isOrderExist(openOrderID2)) //if order was closed due to an exit strat
      {
         movedTP = false;
         newCandle = false;
         oneCandleRule = false;
         pullback = false;
      }
  }
}

//+------------------------------------------------------------------+
//created by Mohsen Hassan on Udemy
//https://www.udemy.com/course/forex-algorithmic-trading-course-code-a-forex-robot/
bool CheckIfOpenOrdersByMagicNB(int magicNB)
{
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber() == magicNB)
            return true;
      }
   }
   return false;
}

int NumOfOpenOrdersByMagicNB(int magicNB)
{
   int x = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber() == magicNB)
            x++;
      }
   }
   return x;
}

//created by Daniel Kniaz on StackOverFlow
//https://stackoverflow.com/questions/50599768/how-to-check-if-a-ticket-is-still-open-or-has-been-closed
bool isOrderExist(int ticket){
    if(OrderSelect(ticket,SELECT_BY_TICKET))
       return(OrderCloseTime()==0);
    else
    {
       int error=GetLastError();
       return(error!=4108 && error!=4051);
    }
}

void closeTrade(int orderType)
{

   for(int i = OrdersTotal();i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderSymbol() == Symbol())
         {
           int Ans;
           if(orderType == 0)
            Ans = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Red);
           else
            Ans = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Red);
           if (Ans)  
               Print("Order close: ",OrderTicket());
            else
               Print("Unable to modify order: ",OrderTicket());
               
         }
      }
   }
}

void EnterBuy()
{
   double stopLossPrice = Ask - (1.5*iATR(NULL,0,14,0));
   double takeProfitPrice = Ask + (1*iATR(NULL,0,14,0));
   TP = takeProfitPrice;
   orderSL = stopLossPrice;
   openPrice = OrderOpenPrice();
   
   double lotSize = OptimalLotSize(riskPerTrade,Ask,stopLossPrice);
   double lotSizeTrade1 = (lotSize/2) - .01;//split the trade into 2 halves
   double lotSizeTrade2 = (lotSize/2) + .01;
               
   openOrderID1 = OrderSend(NULL,OP_BUY,lotSizeTrade1,Ask,5,stopLossPrice,takeProfitPrice,NULL,magicNB1);
   openOrderID2 = OrderSend(NULL,OP_BUY,lotSizeTrade2,Ask,5,stopLossPrice,0,NULL,magicNB2);
   if(openOrderID1 < 0 || openOrderID2 < 0) 
      Alert("order rejected. Order error: " + GetLastError());
   
   movingSLATR =NormalizeDouble( 2 * iATR(NULL,0,14,0),Digits);//used for trailing stop
}

void EnterSell()
{
   double stopLossPrice = Bid + (1.5*iATR(NULL,0,14,0));
   double takeProfitPrice = Bid - (1*iATR(NULL,0,14,0));
   TP = takeProfitPrice;
   orderSL = stopLossPrice;
   openPrice = OrderOpenPrice();
   
   double lotSize = OptimalLotSize(riskPerTrade,Bid,stopLossPrice);
   double lotSizeTrade1 = (lotSize/2) - .01;
   double lotSizeTrade2 = (lotSize/2) + .01;
   
   openOrderID1 = OrderSend(NULL,OP_SELL,lotSizeTrade1,Bid,5,stopLossPrice,takeProfitPrice,NULL,magicNB1);
   openOrderID2 = OrderSend(NULL,OP_SELL,lotSizeTrade2,Bid,5,stopLossPrice,0,NULL,magicNB2);
   if(openOrderID1 < 0 || openOrderID2 < 0) 
      Alert("order rejected. Order error: " + GetLastError());
      
   movingSLATR = NormalizeDouble(2 * iATR(NULL,0,14,0),Digits);
               
}

int isSSLBuy()
{
   if(sslBullCur == 50 && sslBullPrev != 50) //buy
      return 1;
   else if(sslBullCur != 50 && sslBullPrev == 50)//sell
      return 0;
   else
      return -1;
}

int WAEVolume()
{
   if(WAEBullCur > WAESignalLineCur && WAEBullCur > WAEDeadPip)//long
      return 1;
   else if(WAEBearCur > WAESignalLineCur && WAEBearCur > WAEDeadPip)//short
      return -1;//short
   else
      return 0;
}

bool damianiCheckVolume()
{
   if(damianiVolume > damianiNoVolume)//long
      return true;
   else 
      return false;

}
//created by Mohsen Hassan on Udemy
//https://www.udemy.com/course/forex-algorithmic-trading-course-code-a-forex-robot/
double GetPipValue(){
   if(Digits >= 4)
      return .0001;
      
   else
      return .01;

}

//created by Mohsen Hassan on Udemy
//https://www.udemy.com/course/forex-algorithmic-trading-course-code-a-forex-robot/
double OptimalLotSize(double maxRiskPrc,int maxLossInPips)
{
   //Alert(" ");
   double accEquity = AccountEquity();
   //Print("AccEquity: " + accEquity);
   
   double lotSize = MarketInfo(NULL,MODE_LOTSIZE);
   //Print("LotSize : " + lotSize);
   
   double tickValue = MarketInfo(NULL,MODE_TICKVALUE);
   
   if(Digits <= 3)
      tickValue /= 100;
   
   Print("tickValue : " + tickValue);
   
   double maxLossDollar = accEquity * maxRiskPrc;
   //Print("maxLossDollar : " + maxLossDollar);
   
   double maxLossInQuoteCurr = maxLossDollar / tickValue;
   //Print("macLossInQuoteCurr : " + maxLossInQuoteCurr);
   
   double optimalLotSize = NormalizeDouble(maxLossInQuoteCurr / (maxLossInPips * GetPipValue())/lotSize,2);
   
   return optimalLotSize;
}

//created by Mohsen Hassan on Udemy
//https://www.udemy.com/course/forex-algorithmic-trading-course-code-a-forex-robot/
double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
{
   int maxLossInPips = MathAbs((entryPrice - stopLoss))/ GetPipValue();
   return OptimalLotSize(maxRiskPrc,maxLossInPips);
}

int standardEntry()
{
         
   if((isSSLBuy() == 1 || (sslBullPrev == 50 && sslBullCur == 50 && oneCandleRule == true)) && JurikTrendCur == 1)//standard buy entries
   {
      ATRvaluefromPrice = Ask - (1.5*iATR(NULL,0,14,0));
      if(ATRvaluefromPrice > JurikValue && oneCandleRule == false)
      {
         pullback = true;
         return -1;//no signal
      }
      
      if(WAEVolume() == 1 && damianiCheckVolume() == true && DpoValue > 0 )//if all volumes are saying to buy
      {
         return 1; //a buy signal
      }
      
      else //volume indicator did not give a signal
      {
         if(oneCandleRule == true)//only true it passed thru this if statement
         {
            oneCandleRule = false;
            return -1;//no signal
         }
         
         if(oneCandleRule == false)//the first time given a C1 signal but no other signal
            oneCandleRule = true;
         
         return -1;//no signal
      }
      
   
   }
   
   else if((isSSLBuy() == 0 || (sslBullPrev != 50 && sslBullCur != 50 && oneCandleRule == true)) && JurikTrendCur == -1)//standard sell entries
   {
      ATRvaluefromPrice = Bid + (1.5*iATR(NULL,0,14,0));
      if(ATRvaluefromPrice < Bid)
      {
         pullback = true;
         return -1;//no signal
      }
      
      if(WAEVolume() == -1  && damianiCheckVolume() == true && DpoValue < 0)// && ATRvaluefromPrice > JurikValue)//if all volumes are saying to sell
      {
         return 0;//sell signal
      }
      
      else//volume indicator did not give a signal
      {
         if(oneCandleRule == true)//only true it passed thru this if statement
         {
            oneCandleRule = false;
            return -1;//no signal
         }
         
         if(oneCandleRule == false)//the first time given a C1 signal but no other signal
            oneCandleRule = true;
            
         return -1;//no signal
      }
   
    }
    else //no signal was given
    {
      if(oneCandleRule == true)//incase it was true
         oneCandleRule = false;
         
      return -1;
    }
}

int baselineEntry()
{

   int i;
   if(JurikTrendCur == 1 && JurikTrendPrev != 1 && Ask > JurikValue)// if baseline changes to buy
   {  
      continuationTrade = false; // if baseline changes, then continuationtrade is not true
      
      ATRvaluefromPrice = Ask - (1.5*iATR(NULL,0,14,0));
      if(ATRvaluefromPrice < JurikValue)// if price is less than 1.5 atr from the baseline
      {
         if(damianiCheckVolume() == true && WAEVolume() == 1 && DpoValue > 0) 
         {
            for(i = 0; i < 7 ; i++)
            {
               sslBullCur = iCustom(NULL, 0, SSLname, lb, sslMaMethod,SSLBarLevel,alertsON,alertsMessageBox,alertsSound,alertsSoundfile,alertsEmail,TimeFrame,TimeFrames,MAMethod,0,i);
               sslBullPrev = iCustom(NULL, 0, SSLname, lb, sslMaMethod,SSLBarLevel,alertsON,alertsMessageBox,alertsSound,alertsSoundfile,alertsEmail,TimeFrame,TimeFrames,MAMethod,0,i+1);
      
               if(isSSLBuy() == 1)
                  return 1;  //a baseline buy if confirmation signal in the last 7 candles
               if(sslBullCur != 50)
                  return -1; // if opposite signal
            }
            
         }
      }

      else // if price is more than 1.5x the atr from the baseline
      {
         pullback = true;
      }
      
      return -1;//no entry if volumes are not true or if no confirmation signal in the last 7 candles
   }
   
   else if(JurikTrendCur == -1 && JurikTrendPrev != -1 && Bid < JurikValue)// if baseline changes to sell
   {
      continuationTrade = false; // if baseline changes, then continuationtrade is not true
      
      ATRvaluefromPrice = Bid + (1.5*iATR(NULL,0,14,0));
      if(ATRvaluefromPrice > JurikValue) // if price is less than 1.5 atr from the baseline
      {
         if(damianiCheckVolume() == true && WAEVolume() == -1 && DpoValue < 0) 
         {
            for(i = 0; i < 7 ; i++)
            {
               sslBullCur = iCustom(NULL, 0, SSLname, lb, sslMaMethod,SSLBarLevel,alertsON,alertsMessageBox,alertsSound,alertsSoundfile,alertsEmail,TimeFrame,TimeFrames,MAMethod,0,i);
               sslBullPrev = iCustom(NULL, 0, SSLname, lb, sslMaMethod,SSLBarLevel,alertsON,alertsMessageBox,alertsSound,alertsSoundfile,alertsEmail,TimeFrame,TimeFrames,MAMethod,0,i+1);
      
               if(isSSLBuy() == 0)
                  return 0; //baseline sell if confirmation signal in the last 7 candles
                  
               if(sslBullCur == 50)
                  return -1; // if opposite signal
             }
         }
      }
   }
      
   return -1;//no entry if volumes are not true or if no confirmation signal in the last 7 candles
}
   


int pullbackEntry()
{
   if(pullback == true)
   {
      if(JurikTrendCur == 1) //if price is above baseline
      {
         ATRvaluefromPrice = Ask - (1.5*iATR(NULL,0,14,0));
         if(ATRvaluefromPrice < JurikValue)// if price is less than 1.5 atr from the baseline
         {
            if(sslBullCur == 50 && WAEVolume() == 1 && damianiCheckVolume() == true && DpoValue > 0)
               return 1; //enter buy
            else
            {
               pullback = false;
               return -1; // do nothing
            }   
         }
         else // if price is not less than 1.5 atr from the baseline
         {
            pullback = false;
            return -1; // do nothing
         }
         
      }
      else if(JurikTrendCur == -1) //if price is below baseline
      {
         ATRvaluefromPrice = Bid + (1.5*iATR(NULL,0,14,0));
         
         if(ATRvaluefromPrice > JurikValue)// if price is less than 1.5 atr from the baseline
         {
            if(sslBullCur != 50 && damianiCheckVolume() == true && WAEVolume() == -1 && DpoValue < 0)
               return 0; //enter sell
            else
            {
               pullback = false;
               return -1; // do nothing
            }   
         }
         
         else // if price is not less than 1.5 atr from the baseline 
         {
           pullback = false;
           return -1; // do nothing
         }
      }
      else //JurikTrend is consolidating
      {
         pullback = false;
         return -1; // do nothing
      }
   }
   else
   {
      //pullback already false;
      return -1; // no pullback entry;
   }
}

int continuationEntry()
{
   if(continuationTrade == true)
   {
      if(isSSLBuy() == 1 && JurikTrendCur == 1 && DpoValue > 0)
         return 1;
      else if(isSSLBuy() == 0 && JurikTrendCur == -1 && DpoValue < 0)
         return 0;
      else
         return -1;
   }
   else
   {
      return -1;
   }

}

bool baselineCross()
{
   if(JurikTrendCur == 1 && JurikTrendPrev != 1 && Ask > JurikValue)// if baseline changes to buy
   { 
      return true;
   }
   else if(JurikTrendCur == -1 && JurikTrendPrev != -1 && Bid < JurikValue)// if baseline changes to sell
   {
      return true;
   }
   else
   {
      return false;
   }
}
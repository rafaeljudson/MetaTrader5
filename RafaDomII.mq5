//+------------------------------------------------------------------+
//|                                                    RafaDomII.mq5 |
//|                                                     Rafael Valle |
//|                                         rafaeljudson11@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rafael Valle"
#property link      "rafaeljudson11@gmail.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\Scrolls.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Controls\SpinEdit.mqh>
#include <Controls\CheckBox.mqh>
#include <Controls\Panel.mqh>
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Structs                                                          |
//+------------------------------------------------------------------+
struct DATA 
    {
        double               price;
        double                 vap;
        double                 ask;
        double                 bid;
        double              buyVap;
        double             sellVap;
        string            orderBuy;
        string           orderSell;
    };
    
struct COLUMNS
    {
        CPanel                cell;
        CPanel                 bar;
        CLabel                text;
        CButton             button;
    };
    
//+------------------------------------------------------------------+
//| Variables                                                        |
//+------------------------------------------------------------------+
CAppDialog                                                                                    mainWindown;
CScrollV                                                                                        scrollBar;
CLabel                                                     volumeQtyTitle, stopLossTitle, takeProfitTitle;
CSpinEdit                                                           volumeQty, stopLossQty, takeProfitQty;
CCheckBox                                                                enableStopLoss, enableTakeProfit;
CButton                                                         oneLot, twoLot, fiveLot, tenLot, fiftyLot;
CButton         closePosition, buyAtMarket, sellAtMarket, buyLimit, sellLimit, cancelOrdens, cancelLimits;


int     heightCells        = 20;
int     widthCells         = 70;
int     fontSize           = 12;
int     numberRowsTable    = 30;
double  upLimit            = 0;
double  botLimit           = 0;
int     sizeData           = 0;
int     numberRowsData     = 0;
int     numberTicks        = 1000;
double  sizeTicks          = 0;
datetime                 today;
datetime            lastUpdate;

DATA                                  rowData[];
COLUMNS                        rowPriceColumn[];
COLUMNS                          rowVapColumn[];
COLUMNS                          rowAskColumn[];
COLUMNS                          rowBidColumn[];
COLUMNS                       rowBuyVapColumn[];
COLUMNS                      rowSellVapColumn[];
COLUMNS                     rowBuyOrderColumn[];
COLUMNS                    rowSellOrderColumn[];

MqlRates          pricesReference[];
MqlBookInfo            offersBook[];
MqlTick               timesTrades[];
MqlDateTime                     now;
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string                editTable                = "#####   EDITAR TABELA   #####";         //#####   EDITAR TABELA   #####
input bool                  enableBorder             = true;                                    //Borda: Com (true)/ Sem (false)
input color                 colorBorder              = clrWhite;                                //Cor da Borda
input color                 colorButton              = clrNavy;                                 //Cor dos Botões de Quantidade
input string                editColorCell            = "#####   EDITAR CORES FUNDO  #####";     //#####   EDITAR CORES FUNDO  #####
input color                 colorCellVap             = C'0,43,53';                              //Plano de Fundo da Coluna VAP
input color                 colorCellPrice           = C'128,128,128';                          //Plano de Fundo da Coluna PRICE
input color                 colorCellBuy             = C'37,139,210';                           //Plano de Fundo da Coluna BUY
input color                 colorCellSellVap         = C'0,43,53';                              //Plano de Fundo da Coluna SELL VAP
input color                 colorCellBuyVap          = C'0,43,53';                              //Plano de Fundo da Coluna BUY VAP
input color                 colorCellSell            = C'220,49,46';                            //Plano de Fundo da Coluna SELL
input color                 colorCellOrderBuy        = clrWhite;                                //Plano de Fundo da Coluna ORDER BUY
input color                 colorCellOrderSell       = clrWhite;                                //Plano de Fundo da Coluna ORDER SELL
input string                editColorText            = "#####   EDITAR CORES TEXTO  #####";     //#####   EDITAR CORES TEXTO   #####
input color                 colorTextVap             = clrWhite;                                //Texto da Coluna VAP
input color                 colorTextPrice           = clrWhite;                                //Texto da Coluna PRICE
input color                 colorTextBuy             = clrWhite;                                //Texto da Coluna BUY
input color                 colorTextSellVap         = C'185,124,111';                          //Texto da Coluna SELL VAP
input color                 colorTextBuyVap          = C'113,176,182';                          //Texto da Coluna BUY VAP
input color                 colorTextSell            = clrWhite;                                //Texto da Coluna SELL
input color                 colorTextOrderBuy        = clrBlack;                                //Texto da Coluna ORDER BUY
input color                 colorTextOrderSell       = clrBlack;                                //Texto da Coluna ORDER SELL
input string                editColorBar             = "#####   EDITAR CORES BARRA  #####";     //#####   EDITAR CORES BARRA   #####
input color                 colorBarVap              = C'42,161,152';                           //Barra da Coluna VAP
input color                 colorBarPrice            = C'87,111,117';                           //Barra da Coluna PRICE
input color                 colorBarBuy              = C'0,64,128';                             //Barra da Coluna BUY
input color                 colorBarSellVap          = C'0,0,0';                                //Barra da Coluna SELL VAP
input color                 colorBarBuyVap           = C'87,111,117';                           //Barra da Coluna BUY VAP
input color                 colorBarSell             = C'128,64,64';                            //Barra da Coluna SELL
//+------------------------------------------------------------------+
//| InitializationVariables                                          |
//+------------------------------------------------------------------+
void InitializationVariables()
    {
        Print("Iniciando variaveis. Tempo: ", TimeCurrent());
         
        TimeCurrent(now); 
        today = StringToTime((string)now.day + "/" + (string)now.mon + "/" + (string)now.year + " 09:00:00");
        CopyTicksRange(_Symbol, timesTrades, COPY_TICKS_TRADE, today*1000, TimeCurrent()*1000); 
        lastUpdate = (timesTrades[ArraySize(timesTrades)-1].time_msc);
        
        MarketBookAdd(_Symbol);
        MarketBookGet(_Symbol, offersBook);
        
        ArrayResize(rowPriceColumn, numberRowsTable);
        ArrayResize(rowVapColumn, numberRowsTable);
        ArrayResize(rowAskColumn, numberRowsTable);
        ArrayResize(rowBidColumn, numberRowsTable);
        ArrayResize(rowBuyOrderColumn, numberRowsTable);
        ArrayResize(rowSellOrderColumn, numberRowsTable);
        ArrayResize(rowSellVapColumn, numberRowsTable);
        ArrayResize(rowBuyVapColumn, numberRowsTable);
         
        CopyRates(_Symbol, PERIOD_MN1, 0, 1, pricesReference);
        sizeTicks = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
        upLimit   = pricesReference[0].high + (numberTicks*sizeTicks);
        botLimit  = pricesReference[0].low  - (numberTicks*sizeTicks);
        sizeData  = (int)((upLimit-botLimit)/sizeTicks);
        ArrayResize(rowData,sizeData);
        for (int i = 0; i < sizeData; i++)
            {
                rowData[i].price = (upLimit - i*sizeTicks);
            }
             
        Print("Variaveis finalizadas com sucesso. Tempo: ", TimeCurrent());
        Print(GetLastError()); 
    }
//+------------------------------------------------------------------+
//| CreateDom                                                        |
//+------------------------------------------------------------------+
void CreateDom()
    {
        int y2        = (numberRowsTable*heightCells-(numberRowsTable-1)+28);
        int x1_scroll = (8*widthCells - 8);
        int y2_scroll = (numberRowsTable*(heightCells-1));
        if (!enableBorder)
            {;
                y2        = (numberRowsTable*heightCells-(numberRowsTable*2-2)+28);
                x1_scroll = (8*widthCells - 16);
                y2_scroll = (numberRowsTable*(heightCells-2)+2);
            }
            
        int x1_button1  = x1_scroll+18+15;
        int x2_button1  = x1_button1 + 20;
        int x1_button2  = x2_button1 +5;
        int x2_button2  = x1_button2 + 20;
        int x1_button5  = x2_button2 +5;
        int x2_button5  = x1_button5 + 20;
        int x1_button10 = x2_button5 +5;
        int x2_button10 = x1_button10 + 20;
        int x1_button50 = x2_button10 +5;
        int x2_button50 = x1_button50 + 20; 
        
        mainWindown.Create(ChartID(), "Depht Of Market: "+_Symbol, 0, 100, 0, 100 + (8*widthCells) + 18 + 150, y2);
        
        CreateColumn(mainWindown, rowPriceColumn, 1, "PRICE", colorCellPrice, colorBarPrice, colorTextPrice);
        CreateColumn(mainWindown, rowVapColumn, 0, "VAP", colorCellVap, colorBarVap, colorTextVap);
        CreateColumn(mainWindown, rowBuyOrderColumn, 2, "ORDER_BUY", colorCellBuy, clrBlack, clrBlack);
        CreateColumn(mainWindown, rowSellOrderColumn, 7, "ORDER_SELL", colorCellSell, clrBlack, clrBlack);
        CreateColumn(mainWindown, rowBidColumn, 3, "BID", colorCellBuy, colorBarBuy, colorTextBuy);
        CreateColumn(mainWindown, rowSellVapColumn, 4, "SELL_VAP", colorCellSellVap, colorBarSellVap, colorTextSellVap);
        CreateColumn(mainWindown, rowBuyVapColumn, 5, "SELL_VAP", colorCellBuyVap, colorBarBuyVap, colorTextBuyVap);
        CreateColumn(mainWindown, rowAskColumn, 6, "BID", colorCellSell, colorBarSell, colorTextSell);
        
        scrollBar.Create(ChartID(), "SCROLL", 0, x1_scroll, 0, x1_scroll+18, y2_scroll);
        scrollBar.MinPos(0);
        scrollBar.MaxPos(sizeData-numberRowsTable);
        mainWindown.Add(scrollBar);
        
        volumeQtyTitle.Create(ChartID(), "QTYTITLE", 0, x1_scroll+18+15, 10, x1_scroll+18+15+60, 30);
        volumeQtyTitle.Text("Quantidade");
        volumeQtyTitle.Color(colorButton);
        mainWindown.Add(volumeQtyTitle);
        
        volumeQty.Create(ChartID(), "QTY", 0, x1_scroll+18+15, 30, x1_scroll+18+15+120, 50);
        volumeQty.MaxValue(1000);
        volumeQty.MinValue(0);
        volumeQty.Value(1);
        mainWindown.Add(volumeQty);
        
        oneLot.Create(ChartID(), "ONE LOT", 0, x1_button1, 60, x2_button1, 80);
        oneLot.ColorBackground(colorButton);
        oneLot.ColorBorder(colorBorder);
        oneLot.Color(clrWhite);
        oneLot.Text("1");
        mainWindown.Add(oneLot);
        
        twoLot.Create(ChartID(), "TWO LOT", 0, x1_button2, 60, x2_button2, 80);
        twoLot.ColorBackground(colorButton);
        twoLot.ColorBorder(colorBorder);
        twoLot.Color(clrWhite);
        twoLot.Text("2");
        mainWindown.Add(twoLot);
        
        fiveLot.Create(ChartID(), "FIVE LOT", 0, x1_button5, 60, x2_button5, 80);
        fiveLot.ColorBackground(colorButton);
        fiveLot.ColorBorder(colorBorder);
        fiveLot.Color(clrWhite);
        fiveLot.Text("5");
        mainWindown.Add(fiveLot);
        
        tenLot.Create(ChartID(), "TEN LOT", 0, x1_button10, 60, x2_button10, 80);
        tenLot.ColorBackground(colorButton);
        tenLot.ColorBorder(colorBorder);
        tenLot.Color(clrWhite);
        tenLot.Text("10");
        mainWindown.Add(tenLot);
        
        fiftyLot.Create(ChartID(), "FIFTY LOT", 0, x1_button50, 60, x2_button50, 80);
        fiftyLot.ColorBackground(colorButton);
        fiftyLot.ColorBorder(colorBorder);
        fiftyLot.Color(clrWhite);
        fiftyLot.Text("50");
        mainWindown.Add(fiftyLot);
        
        stopLossTitle.Create(ChartID(), "STOPLOSSTITLE", 0, x1_scroll+18+15, 90, x1_scroll+18+15+60, 110);
        stopLossTitle.Text("Stop Loss");
        stopLossTitle.Color(colorButton);
        mainWindown.Add(stopLossTitle);
        
        enableStopLoss.Create(ChartID(), "ENABLESTOPLOSS", 0, x1_scroll+18+15, 110, x1_scroll+18+15+20, 130);
        mainWindown.Add(enableStopLoss);
        
        stopLossQty.Create(ChartID(), "STOPLOSSQTY", 0, x1_scroll+18+15+20+5, 110, x1_scroll+18+15+20+100, 130);
        stopLossQty.MaxValue(100);
        stopLossQty.MinValue(0);
        stopLossQty.Value(1);
        mainWindown.Add(stopLossQty);
        
        takeProfitTitle.Create(ChartID(), "TAKEPROFITTITLE", 0, x1_scroll+18+15, 140, x1_scroll+18+15+60, 160);
        takeProfitTitle.Text("Take Profit");
        takeProfitTitle.Color(colorButton);
        mainWindown.Add(takeProfitTitle);
        
        enableTakeProfit.Create(ChartID(), "ENABLETAKEPROFIT", 0, x1_scroll+18+15, 160, x1_scroll+18+15+20, 180);
        mainWindown.Add(enableTakeProfit);
        
        takeProfitQty.Create(ChartID(), "TAKEPROFITQTY", 0, x1_scroll+18+15+20+5, 160, x1_scroll+18+15+20+100, 180);
        takeProfitQty.MaxValue(100);
        takeProfitQty.MinValue(0);
        takeProfitQty.Value(1);
        mainWindown.Add(takeProfitQty);
        
        buyAtMarket.Create(ChartID(), "BUYMARKET", 0, x1_scroll+18+15, 190, x1_scroll+18+15+60, 220);
        buyAtMarket.Text("Buy Ask");
        buyAtMarket.FontSize(8);
        buyAtMarket.Color(clrWhite);
        buyAtMarket.ColorBackground(colorCellBuy);
        mainWindown.Add(buyAtMarket);
        
        buyLimit.Create(ChartID(), "BUYLIMIT", 0, x1_scroll+18+15, 225, x1_scroll+18+15+60, 255);
        buyLimit.Text("Buy Limit");
        buyLimit.FontSize(8);
        buyLimit.Color(clrWhite);
        buyLimit.ColorBackground(colorCellBuy);
        mainWindown.Add(buyLimit);
        
        sellAtMarket.Create(ChartID(), "SELLMARKET", 0, x1_scroll+18+15+60+5, 190, x1_scroll+18+15+60+5+60, 220);
        sellAtMarket.Text("Sell Ask");
        sellAtMarket.FontSize(8);
        sellAtMarket.Color(clrWhite);
        sellAtMarket.ColorBackground(colorCellSell);
        mainWindown.Add(sellAtMarket);
        
        sellLimit.Create(ChartID(), "SELLLIMIT", 0, x1_scroll+18+15+60+5, 225, x1_scroll+18+15+60+5+60, 255);
        sellLimit.Text("Sell Limit");
        sellLimit.FontSize(8);
        sellLimit.Color(clrWhite);
        sellLimit.ColorBackground(colorCellSell);
        mainWindown.Add(sellLimit);
        
        closePosition.Create(ChartID(), "CLOSEPOSITION", 0, x1_scroll+18+15, 260, x1_scroll+18+15+125, 290);
        closePosition.Text("Close Position");
        closePosition.Color(clrWhite);
        closePosition.ColorBackground(colorButton);
        closePosition.FontSize(8);
        mainWindown.Add(closePosition);
        
        cancelOrdens.Create(ChartID(), "CANCELORDERS", 0, x1_scroll+18+15, 295, x1_scroll+18+15+125, 325);
        cancelOrdens.Text("Cancel Orders");
        cancelOrdens.Color(clrWhite);
        cancelOrdens.ColorBackground(colorButton);
        cancelOrdens.FontSize(8);
        mainWindown.Add(cancelOrdens);
        
        cancelLimits.Create(ChartID(), "CANCELLIMITS", 0, x1_scroll+18+15, 330, x1_scroll+18+15+125, 360);
        cancelLimits.Text("Cancel Limits");
        cancelLimits.Color(clrWhite);
        cancelLimits.ColorBackground(colorButton);
        cancelLimits.FontSize(8);
        mainWindown.Add(cancelLimits);
    }
//+------------------------------------------------------------------+
//| CreateColumn                                                     |
//+------------------------------------------------------------------+
void CreateColumn(CAppDialog &windown, COLUMNS &column[], int position, string name, color colorCellLocal, color colorBarLocal, color colorTextLocal)
    {
        int aux_x1 = 2;
        int aux_y1 = 2;
        if (enableBorder) { aux_x1 = 1; aux_y1 = 1; }
        int x1 = (widthCells*position - aux_x1*position);
        int x2 = (x1 + widthCells);
        for (int i = 0; i < numberRowsTable; i++)
            {
                int y1 = (heightCells*i - aux_y1*i);
                int y2 = (y1 + heightCells);
                string object_name = (name + " [" + (string)position + "]" + "[" + (string)i + "]");
                if ((name == "ORDER_BUY") || (name == "ORDER_SELL"))
                    {
                        column[i].button.Create(ChartID(), (object_name + " Button"), 0, x1, y1, x2, y2);
                        column[i].button.ColorBackground(colorCellLocal);
                        column[i].button.Color(colorTextLocal);
                        column[i].button.Text("");
                        column[i].button.FontSize(fontSize);
                        
                        if (enableBorder)
                            {
                                column[i].button.ColorBorder(colorBorder);
                            }
                        else
                            {
                                column[i].button.ColorBorder(clrNONE);
                            }
                            
                        windown.Add(column[i].button);
                        
                    }
                else
                    {
                        column[i].cell.Create(ChartID(), (object_name+" Cell"), 0, x1, y1, x2, y2);
                        column[i].bar.Create(ChartID(), (object_name + " Bar"), 0, x1, y1, x2, y2);
                        column[i].text.Create(ChartID(), (object_name + " Text"), 0, x1 + 3, y1, x2, y2);
                        
                        column[i].cell.ColorBackground(colorCellLocal);
                        column[i].bar.ColorBackground(colorBarLocal);
                        column[i].bar.Width(3);
                        column[i].text.Color(colorTextLocal);
                        column[i].text.FontSize(fontSize);
                        
                        if (enableBorder)
                            {
                                column[i].cell.ColorBorder(colorBorder);
                                column[i].bar.ColorBorder(colorBorder);
                            }
                        else
                            {
                                column[i].cell.ColorBorder(clrNONE);
                                column[i].bar.ColorBorder(clrNONE);
                            }
                        
                        windown.Add(column[i].cell);
                        windown.Add(column[i].bar);
                        windown.Add(column[i].text);
                    }
            }
    }
//+------------------------------------------------------------------+
//| UpdateData                                                       |
//+------------------------------------------------------------------+
void UpdateData()
    {
        for (int k = 0; k < ArraySize(rowData); k++)
            {
                rowData[k].ask = 0;
                rowData[k].bid = 0;
            }
        for (int i = 0; i < ArraySize(offersBook); i++)
            {
                int auxIndex = (int)((upLimit - offersBook[i].price)/sizeTicks);
                if (offersBook[i].type == BOOK_TYPE_BUY)
                    {
                        rowData[auxIndex].bid = offersBook[i].volume_real;
                    }
                if (offersBook[i].type == BOOK_TYPE_SELL)
                    {
                        rowData[auxIndex].ask = offersBook[i].volume_real;
                    }
            }
        
        for (int j = 0; j < ArraySize(timesTrades); j++)
            {
                int auxIndex2 = (int)((upLimit - timesTrades[j].last)/sizeTicks);
                if ((timesTrades[j].flags == 56) || (timesTrades[j].flags == 312) || (timesTrades[j].flags == 88) || (timesTrades[j].flags == 344) || (timesTrades[j].flags == 120) || (timesTrades[j].flags == 376))
                    {
                        rowData[auxIndex2].vap += timesTrades[j].volume_real;
                    } 
            }
    }
//+------------------------------------------------------------------+
//| Updatetable                                                      |
//+------------------------------------------------------------------+
void UpdateTable(int position)
    {
        UpdateVapColumn(position);
        UpdatePriceColumn(position);
        UpdateAskColumn(position);
        UpdateBidColumn(position);
    }
//+------------------------------------------------------------------+
//| UpdateVapColumn                                                  |
//+------------------------------------------------------------------+
void UpdateVapColumn (int pos)
    {
        for (int i = 0; i < numberRowsTable; i++)
            {
                
                if (rowData[pos+i].vap == 0)
                    {
                        rowVapColumn[i].text.Text("");
                        rowPriceColumn[i].bar.Width(widthCells);
                    }
                else
                    {
                        rowVapColumn[i].text.Text(DoubleToString(rowData[pos+i].vap,0));
                        rowPriceColumn[i].bar.Width(1);
                    }
            }
    }
//+------------------------------------------------------------------+
//| UpdatePriceColumn                                                |
//+------------------------------------------------------------------+
void UpdatePriceColumn (int pos)
    {
        for (int i = 0; i < numberRowsTable; i++)
            {
                rowPriceColumn[i].text.Text(DoubleToString(rowData[pos+i].price,_Digits));
            }
    }
//+------------------------------------------------------------------+
//| UpdateBidColumn                                                  |
//+------------------------------------------------------------------+
void UpdateBidColumn (int pos)
    {
        for (int i = 0; i < numberRowsTable; i++)
            {
                if (rowData[pos+i].bid == 0)
                    {
                        rowBidColumn[i].text.Text("");
                    } 
                else
                    {
                        rowBidColumn[i].text.Text(DoubleToString(rowData[pos+i].bid,0));
                    }
            }
    }
//+------------------------------------------------------------------+
//| UpdateAskColumn                                                  |
//+------------------------------------------------------------------+
void UpdateAskColumn (int pos)
    {
        for (int i = 0; i < numberRowsTable; i++)
            {
                if (rowData[pos+i].ask == 0)
                    {
                        rowAskColumn[i].text.Text("");
                    } 
                else
                    {
                        rowAskColumn[i].text.Text(DoubleToString(rowData[pos+i].ask,0));
                    } 
            }
    }
//+------------------------------------------------------------------+
//| ShowDom                                                          |
//+------------------------------------------------------------------+
void ShowDom()
    {
        mainWindown.Run();
    }
//+------------------------------------------------------------------+
//| DestroywDom                                                      |
//+------------------------------------------------------------------+
void DestroyDom()
    {
        mainWindown.Destroy();
    }
//+------------------------------------------------------------------+
//| OnEventDom                                                       |
//+------------------------------------------------------------------+
void OnEventDom(int id, long lparam, double dparam, string sparam)
    {
        mainWindown.ChartEvent(id, lparam, dparam, sparam);
    }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
    {
//--- set the size of data and fill it with prices between up and bot limits
        InitializationVariables();
//--- create timer
        EventSetMillisecondTimer(1000);
//--- create dom and show
        CreateDom();
//--- update data
        UpdateData();
//--- update table
        UpdateTable(scrollBar.CurrPos());  
//--- show table        
        ShowDom();
        Print(sizeTicks);
        Print(upLimit);
        Print(botLimit);
        Print(sizeData);
//--- return        
        return(INIT_SUCCEEDED);
    }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
    {
//--- destroy timer
        EventKillTimer();
//--- close book
        MarketBookRelease(_Symbol); 
//--- destroy dom
        DestroyDom(); 
//--- zero memories
        ResetLastError();
    }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
    {
//---
   
    }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
    {
//--- update timestrades
        CopyTicksRange(_Symbol, timesTrades, COPY_TICKS_TRADE, lastUpdate, TimeCurrent()*1000); 
        lastUpdate = (timesTrades[ArraySize(timesTrades)-1].time_msc);
//--- update offersbook
        MarketBookGet(_Symbol, offersBook);
//--- update data
        UpdateData();
//--- update table
        UpdateTable(scrollBar.CurrPos());  
//--- show table        
        ShowDom();
    }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
    {
//---
        OnEventDom(id, lparam, dparam, sparam);
    }
//+------------------------------------------------------------------+

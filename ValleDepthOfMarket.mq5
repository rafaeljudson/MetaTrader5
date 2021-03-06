#property copyright "Rafael Valle"
#property link      "rafaeljudson11@gmail.com"
#property version   "1.00"


#include <Controls\Dialog.mqh>
#include <Controls\Scrolls.mqh>
#include <Controls\Label.mqh>

struct Coluna
    {
        CPanel          celula;
        CPanel      histograma;
        CLabel           texto;
    };

struct VolumeAtPrice
    {
        double          price;
        double         volume;
        double     buy_volume;
        double    sell_volume;
        datetime         time;
        
    };

CAppDialog                               Janela;
CScrollV                       Barra_de_Rolagem;

Coluna                                    Vap[];
Coluna                                    Buy[];
Coluna                                  Price[];
Coluna                                   Sell[];
Coluna                                  BuyTT[];
Coluna                                 SellTT[];

VolumeAtPrice             VolumesNegocios[2000];
VolumeAtPrice                          TT[1000];

string                       titulo_do_programa = "Valle Depth Of Market";
int                            numero_de_linhas = 38;
int                     comprimento_das_celulas = 60;
int                          altura_das_celulas = 16;
int                                   indiceVap = 0;
int                                   indiceTT  = 0;
bool                       primeiro_calculo_vap = false;

MqlTick                             ticks_vap[];
MqlTick                              ticks_tt[];
MqlDateTime                                hoje;
MqlBookInfo                  livro_de_ofertas[];

input color cor_do_vap                          = C'0,43,53';           //Plano de Fundo da Coluna VAP
input color cor_histograma_vap                  = C'42,161,152';        //Histrograma da Coluna VAP
input color cor_texto_vap                       = clrWhite;             //Texto da Coluna VAP

input color cor_do_preco                        = C'128,128,128';       //Plano de Fundo da Coluna Preço
input color cor_histograma_preco                = C'87,111,117';        //Histrograma da Coluna VAP
input color cor_texto_preco                     = clrWhite;             //Texto da Coluna VAP
 
input color cor_da_compra                       = C'37,139,210';        //Plano de Fundo da Coluna Compra
input color cor_histograma_compra               = C'0,64,128';          //Histrograma da Coluna Compra
input color cor_texto_compra                    = clrWhite;             //Texto da Coluna Compra

input color cor_da_agrvenda                     = C'0,43,53';           //Plano de Fundo da Coluna Agr. Venda
input color cor_histograma_agrvenda             = C'0,0,0';             //Histrograma da Coluna Agr. Venda
input color cor_texto_agrvenda                  = C'185,124,111';       //Texto da Coluna Agr. Venda

input color cor_do_agrcompra                    = C'0,43,53';           //Plano de Fundo da Coluna Agr. Compra
input color cor_histograma_agrcompra            = C'87,111,117';        //Histrograma da Coluna Agr. Compra
input color cor_texto_agrcompra                 = C'113,176,182';       //Texto da Coluna Agr. Compra

input color cor_da_venda                        = C'220,49,46';         //Plano de Fundo da Coluna Venda
input color cor_histograma_venda                = C'128,64,64';         //Histrograma da Coluna Venda
input color cor_texto_venda                     = clrWhite;             //Texto da Coluna Venda
 
int OnInit()
  {
    EventSetMillisecondTimer(50);
    
    ArrayResize(Vap,numero_de_linhas,numero_de_linhas);
    ArrayResize(Price,numero_de_linhas,numero_de_linhas);
    ArrayResize(Buy,numero_de_linhas,numero_de_linhas);
    ArrayResize(Sell,numero_de_linhas,numero_de_linhas);
    ArrayResize(BuyTT,numero_de_linhas,numero_de_linhas);
    ArrayResize(SellTT,numero_de_linhas,numero_de_linhas);
    
    ArraySetAsSeries(ticks_vap,true);
   
    
    MarketBookAdd(_Symbol);
    MarketBookGet(_Symbol,livro_de_ofertas);
    
    Janela.Create(ChartID(),titulo_do_programa,0,50,0,430,numero_de_linhas*altura_das_celulas-(numero_de_linhas-1)+28);
       
    Barra_de_Rolagem.Create(ChartID(),"Barra de Rolagem",0,Janela.Width()-18-8,0,Janela.Width()-8,numero_de_linhas*(altura_das_celulas-1));
    Barra_de_Rolagem.MinPos(0);
    Barra_de_Rolagem.MaxPos(numero_de_linhas);
    
    Janela.Add(Barra_de_Rolagem);
    
    CriarColuna(Vap,
                numero_de_linhas,
                0,
                "VAP",
                cor_do_vap,
                cor_histograma_vap,
                cor_texto_vap,
                comprimento_das_celulas,
                altura_das_celulas);
    CriarColuna(Price,
                numero_de_linhas,
                59,
                "PREÇO",
                cor_do_preco,
                cor_histograma_preco,
                cor_texto_preco,
                comprimento_das_celulas,
                altura_das_celulas);
    CriarColuna(Buy,
                numero_de_linhas,
                118,
                "COMPRA",
                cor_da_compra,
                cor_histograma_compra,
                cor_texto_compra,
                comprimento_das_celulas,
                altura_das_celulas);
    CriarColuna(SellTT,
                numero_de_linhas,
                177,
                "AGR.VENDA",
                cor_da_agrvenda,
                cor_histograma_agrvenda,
                cor_texto_agrvenda,
                comprimento_das_celulas,
                altura_das_celulas);
    CriarColuna(BuyTT,
                numero_de_linhas,
                236,
                "AGR.COMPRA",
                cor_do_agrcompra,
                cor_histograma_compra,
                cor_texto_compra,
                comprimento_das_celulas,
                altura_das_celulas);
    CriarColuna(Sell,
                numero_de_linhas,
                295,
                "VENDA",
                cor_da_venda,
                cor_histograma_venda,
                cor_texto_venda,
                comprimento_das_celulas,
                altura_das_celulas);
    
    int index_aux = ProcurarIndiceBid();
    
    AtualizarColunaPreco(index_aux);
    
    Janela.Run();

    Comment("");

    return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
    MarketBookRelease(_Symbol);
    
    EventKillTimer();
    
    Janela.Destroy(reason);
  }

void OnTimer()
  {
    
    
    MarketBookGet(_Symbol,livro_de_ofertas);
    
    if (CopyTicksRange(_Symbol,ticks_tt,COPY_TICKS_TRADE,TimeCurrent()*1000-3000,TimeCurrent()*1000) <= 0)
        {
            return;
        }
    
    
    int index_aux = ProcurarIndiceBid();    
    
    AtualizarVolumeNegociosTT();
    AtualizarColunaCompra(index_aux, ProcuraMaiorVolume());
    AtualizarColunaVenda(index_aux, ProcuraMaiorVolume());
    AtualizarColunasTT();
    
  }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
    
    Janela.ChartEvent(id,lparam,dparam,sparam);
    
  }
  

void CriarColuna(Coluna &coluna[],int linhas, int posicao_x, string id, color celula, color histograma, color texto, int comprimento, int altura)
    {
        for (int i = 0; i < linhas; i++)
            {
                int y = (altura-1)*i;
                
                coluna[i].celula.Create(ChartID(),"Coluna"+id+(string)i,0,posicao_x,y,posicao_x+comprimento,y+altura);
                coluna[i].histograma.Create(ChartID(),"Histograma"+id+(string)i,0,posicao_x,y,posicao_x+comprimento/2,y+altura);
                coluna[i].texto.Create(ChartID(),"Texto"+id+(string)i,0,posicao_x+3,y,posicao_x+comprimento,y+altura);
                coluna[i].texto.Text(id);
                
                
                coluna[i].celula.ColorBackground(celula);
                coluna[i].histograma.ColorBackground(histograma);
                coluna[i].texto.Color(texto);
                
                Janela.Add(coluna[i].celula);
                Janela.Add(coluna[i].histograma);
                Janela.Add(coluna[i].texto);
            }
    }
    
void AtualizarVolumeNegocios(datetime inicio, datetime fim)
    {
        if(CopyTicksRange(_Symbol,ticks_vap,COPY_TICKS_TRADE,inicio,fim)==-1)
            {
                Print("Erro ao acessar os dados de mercado no período desejado");
                Print(GetLastError());
                ResetLastError();
                return;
            }
        for (int i = 0; i < ArraySize(ticks_vap); i++)
            {
                int indice = ProcurarPrecoVap(ticks_vap[i].last);
                
                if (indice >= 0)
                    {
                        VolumesNegocios[indice].volume += ticks_vap[i].volume_real;
                    }
                else
                    {
                        AdicionarPrecoVap(ticks_vap[i].last, ticks_vap[i].volume_real); 
                    }
            }
    }

int ProcurarPrecoVap(double price)
    {
        for (int i = 0; i < ArraySize(VolumesNegocios); i++)
            {
                if (VolumesNegocios[i].price == price)
                    {
                        return i;
                    }
            }
            
        return -1;
    }
    
int ProcurarPrecoTT(double price)
    {
        for (int i = 0; i < ArraySize(TT); i++)
            {
                if (TT[i].price == price)
                    {
                        return i;
                    }
            }
            
        return -1;
    }

void AdicionarPrecoVap(double price, double volume)
    {
        VolumesNegocios[indiceVap].price  = price;
        VolumesNegocios[indiceVap].volume = volume;
        indiceVap ++;
    }
    
void AdicionarPrecoTT(double price, double volume, datetime time, int flag)
    {
        TT[indiceTT].price  = price;
        TT[indiceTT].time   = time;
        
        if (flag == 56)
            {
                TT[indiceTT].buy_volume = volume;
            }
        if (flag == 88)
            {
                TT[indiceTT].sell_volume = volume;
            }
            
        indiceTT ++;
    }
    
int ProcurarIndiceBid()
    {
        for (int i = 0; i < ArraySize(livro_de_ofertas); i++)
            {
                if (livro_de_ofertas[i].type == BOOK_TYPE_BUY)
                    {
                        return i;
                    }
            }
            
        return -1;   
    }
void AtualizarColunaPreco(int indiceBid)
    {
        int start = (numero_de_linhas/2);
        
        for (int i = start-1; i >= 0; i--)
            {
                Price[i].texto.Text((string)(livro_de_ofertas[indiceBid-1].price + 0.5*((start-1)-i)));
            }
        for (int i = start; i < numero_de_linhas; i++)
            {
                Price[i].texto.Text((string)(livro_de_ofertas[indiceBid].price - 0.5*(i-start)));
            }
    }
    
void AtualizarColunaCompra(int indice, double maior_volume)
    {
        for (int i = 0; i < numero_de_linhas; i++)
            {
                int indice_aux = AcharPrecoCompra(indice, Price[i].texto.Text());
                
                if (indice_aux >= 0)
                    {
                        Buy[i].histograma.Width(livro_de_ofertas[indice_aux].volume_real*comprimento_das_celulas/maior_volume);
                        Buy[i].texto.Text(DoubleToString(livro_de_ofertas[indice_aux].volume_real,0));
                    }
                else
                    {
                       Buy[i].histograma.Width(3);
                       Buy[i].texto.Text(""); 
                    }
            }
    }

void AtualizarColunaVenda(int indice, double maior_volume)
    {
        for (int i = 0; i < numero_de_linhas; i++)
            {
                int indice_aux = AcharPrecoVenda(indice, Price[i].texto.Text());
                
                if (indice_aux >= 0)
                    {
                        Sell[i].histograma.Width(livro_de_ofertas[indice_aux].volume_real*comprimento_das_celulas/maior_volume);
                        Sell[i].texto.Text(DoubleToString(livro_de_ofertas[indice_aux].volume_real,0));
                    }
                else
                    {
                       Sell[i].histograma.Width(3);
                       Sell[i].texto.Text(""); 
                    }
            }
    }
    
int AcharPrecoCompra(int indice, string preco)
    {
        for (int i = indice; i < ArraySize(livro_de_ofertas); i++)
            {
                if (StringToDouble(preco) == livro_de_ofertas[i].price)
                    return i;
            }
            
        return -1;
    }

int AcharPrecoVenda(int indice, string preco)
    {
        for (int i = 0; i < indice; i++)
            {
                if (StringToDouble(preco) == livro_de_ofertas[i].price)
                    return i;
            }
            
        return -1;
    }



double ProcuraMaiorVolumeVap()
    {
         double maior = 0;
         
         for (int i = 0; i<2000; i++)
             {
                  if (VolumesNegocios[i].volume > maior)
                      {
                            maior = VolumesNegocios[i].volume;
                      }
             }
         return maior;
    }
    
double ProcuraMaiorVolume()
    {
         double maior = 0;
         
         for (int i = 0; i < ArraySize(livro_de_ofertas); i++)
             {
                  if (livro_de_ofertas[i].volume_real > maior)
                      {
                            maior = livro_de_ofertas[i].volume_real;
                      }
             }
         return maior;
    }
    
void AtualizarVolumeNegociosTT()
    {
        for (int i = 0; i < ArraySize(ticks_tt); i++)
            {
                int indice = ProcurarPrecoTT(ticks_tt[i].last);
                
                if (indice >= 0) 
                    {
                        if (ticks_tt[i].time_msc > TT[indice].time)
                            {
                                TT[indice].time = ticks_tt[i].time_msc;
                            
                                if (ticks_tt[i].flags == 56)
                                    {
                                        TT[indice].buy_volume += ticks_tt[i].volume_real;
                                    }
                                    
                                if (ticks_tt[i].flags == 88)
                                    {
                                        TT[indice].sell_volume += ticks_tt[i].volume_real;
                                    }
                            }
                    }
                else
                    {
                        AdicionarPrecoTT(ticks_tt[i].last, ticks_tt[i].volume_real, ticks_tt[i].time_msc, ticks_tt[i].flags); 
                    }
            }
        
    }
    
void AtualizarColunasTT()
    {
        for (int i = 0; i < numero_de_linhas; i++)
            {
                int indice_aux = AcharPrecoTT(Price[i].texto.Text());
                
                if (indice_aux >= 0)
                    {
                        SellTT[i].texto.Text(DoubleToString(TT[indice_aux].sell_volume,0));
                        BuyTT[i].texto.Text(DoubleToString(TT[indice_aux].buy_volume,0));
                        
                        SellTT[i].histograma.Width(comprimento_das_celulas/2);
                        BuyTT[i].histograma.Width(comprimento_das_celulas/2);
                    }
                else
                  {
                        SellTT[i].texto.Text("");
                        BuyTT[i].texto.Text("");
                        
                        SellTT[i].histograma.Width(3);
                        BuyTT[i].histograma.Width(3);
                  }    
                         
            }
    }
    
int AcharPrecoTT(string preco)
    {
        for (int i = 0; i < ArraySize(TT); i++)
            {
                if (DoubleToString(TT[i].price,1) == preco)
                    return i;
            }
            
        return -1;
    }
    

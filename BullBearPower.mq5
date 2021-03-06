//+------------------------------------------------------------------+
//|                                                BullBearPower.mq5 |
//|                                                     Rafael Valle |
//|                                         rafaeljudson11@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rafael Valle"
#property link      "rafaeljudson11@gmail.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Estruturas                                                       |
//+------------------------------------------------------------------+
struct Report 
{
 string time;
 string simbolo;
 string sinal;
 string resultado;
};
//+------------------------------------------------------------------+
//| Variáveis Globais                                                |
//+------------------------------------------------------------------+
input int                            media_movel = 20;                                          //Período da Média Móvel usada para calcular os indicadores Bull e Bear Power
input int                       periodo_lookback = 5;                                          //Período mínimo onde os indicadores tem que estar iguais
input string                           diretorio = "C:\\Users\\rafae\\Desktop\\";             //nome do diretório
input string                             arquivo = "BackTeste_Ariel.txt";                    //nome do arquivo 
      bool                   lista_de_condicionais[];                                       //Array para armanezar as condicionais da entrada
      double                            bull_power[];                                      //Variável para salvar os valores do indicador Bull Power
      double                            bear_power[];                                     //Variável para salvar os valores do indicador Bear Power
      int                          handle_bull_power;                                    //Manipulador do indicador Bull Power
      int                          handle_bear_power;                                   //Manipulador do indicador Bear Power
      MqlRates                              precos[];                                  //Array com os valores dos preços OHLC
      int                        contador_compra = 0;                                 //Quantidades de sinais de compra gerados
      int                        contador_venda  = 0;                                //Quantidades de sinais de venda gerados
      int                        total_operacao  = 0;                               //Quantidades de operações
      bool                em_operacao_compra = false;                              //Variável para saber se estar comprado
      bool                em_operacao_venda  = false;                             //Variável para saber se estar vendido
      Report                         relatorio[5000];                            //Estrutura para armazenar o relatorio do backteste
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   ArraySetAsSeries(bull_power,true);                                          //Colocando o valor mais recente para o índice 0
   ArraySetAsSeries(bear_power,true);                                         //Colocando o valor mais recente para o índice 0
   ArraySetAsSeries(precos,true);                                            //Colocando o valor mais recente para o índice 0
   ArrayResize(lista_de_condicionais,periodo_lookback,periodo_lookback);    //Mudando o tamanho da array de condicionais
   ArraySetAsSeries(lista_de_condicionais,true);                           //Colocando o valor mais recente para o índice 0
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//Verificando nova barra
   if (!NovaBarra())
    {
     return;
    }  

//Criando os manipuladores

   handle_bear_power = iBearsPower(_Symbol,_Period,media_movel);  //Criando o manipulador do indicador Bear Power
   handle_bull_power = iBullsPower(_Symbol,_Period,media_movel);  //Criando o manipulador do indicador Bull Power
   
//Verificando a criação dos manipuladores de Bull e Bear Power
   
   if(handle_bear_power == INVALID_HANDLE)
    {
     Comment("Falha em criar o indicador Bear Power. Erro: ",GetLastError());
     ResetLastError();
    }
    
   if(handle_bull_power == INVALID_HANDLE)
    {
     Comment("Falha em criar o indicador Bull Power. Erro: ",GetLastError());
     ResetLastError();
    }
    
//Copiando os dados dos manipuladores para as arrays de bull e bear power

   if(CopyBuffer(handle_bear_power,0,0,periodo_lookback+10,bear_power) == -1)
    {
     Comment("Falha em copiar Bear Power Indicator. Erro: ",GetLastError());
     ResetLastError();
    }
   
   if(CopyBuffer(handle_bull_power,0,0,periodo_lookback+10,bull_power) == -1)
    {
     Comment("Falha em copiar Bull Power Indicator. Erro: ", GetLastError());
     ResetLastError();
    }
//Copiando e validando os dados dos preços para a array precos[]

   if(CopyRates(Symbol(),Period(),0,periodo_lookback+10,precos) == -1)
    {
     Comment("Falha em copiar os dados dos preços. Erro: ", GetLastError());
     ResetLastError();
    }  
   
//Condicionais
   bool pode_operar = true;
   
   for (int i = 0; i < periodo_lookback; i++)
   {
    lista_de_condicionais[i] = (((bear_power[i+3] < 0) && (bull_power[i+3] < 0)) || ((bear_power[i+3] > 0) && (bull_power[i+3] > 0)));
    if(lista_de_condicionais[i] == false)
    {
     pode_operar = false;
     break;
    }
   }

   if (em_operacao_compra && (precos[1].close>precos[1].open))
   {
    em_operacao_compra = false;
    contador_compra ++;
    
    relatorio[total_operacao].time         = TimeToString(precos[3].time);
    relatorio[total_operacao].simbolo      = _Symbol;
    relatorio[total_operacao].sinal        = "Compra";
    relatorio[total_operacao].resultado    = "Vencedora";
    
   }
   if (em_operacao_compra && (precos[1].close<precos[1].open))
   {
    em_operacao_compra = false;
    relatorio[total_operacao].time         = TimeToString(precos[3].time);
    relatorio[total_operacao].simbolo      = _Symbol;
    relatorio[total_operacao].sinal        = "Compra";
    relatorio[total_operacao].resultado    = "Perdedora";
   }
   
   if (em_operacao_venda && (precos[1].close<precos[1].open))
   {
    em_operacao_venda = false;
    contador_venda ++;
    relatorio[total_operacao].time         = TimeToString(precos[3].time);
    relatorio[total_operacao].simbolo      = _Symbol;
    relatorio[total_operacao].sinal        = "Venda";
    relatorio[total_operacao].resultado    = "Vencedora";
   }
   if (em_operacao_venda && (precos[1].close>precos[1].open))
   {
    em_operacao_venda = false;
    relatorio[total_operacao].time         = TimeToString(precos[3].time);
    relatorio[total_operacao].simbolo      = _Symbol;
    relatorio[total_operacao].sinal        = "Venda";
    relatorio[total_operacao].resultado    = "Perdedora";
   }

//Criando os sinais de compra e venda com base na diferença entre os indicadores bull e bear power

   //Sinal de Compra
   if ((bull_power[2] > 0) && (bear_power[2] < 0) && (pode_operar) && (precos[2].close<precos[2].open))
    {
     total_operacao ++;
     ObjectCreate(ChartID(),IntegerToString(total_operacao),OBJ_ARROW_BUY,0,precos[2].time,precos[2].open);
     Comment("Total de operações: ",total_operacao,
           "\nTotal de Compras Ganhadoras: ",contador_compra,
           "\nTotal de Vendas  Ganhadoras: ",contador_venda);
     em_operacao_compra = true;
    }
    
   //Sinal de Venda
   if ((bull_power[2] > 0) && (bear_power[2] < 0) && (pode_operar) && (precos[2].close>precos[2].open))
    {
     total_operacao ++;
     ObjectCreate(ChartID(),IntegerToString(total_operacao),OBJ_ARROW_SELL,0,precos[2].time,precos[2].open);
     Comment("Total de operações: ",total_operacao,
           "\nTotal de Compras Ganhadoras: ",contador_compra,
           "\nTotal de Vendas  Ganhadoras: ",contador_venda);
     em_operacao_venda = true;
    }
//Salvando os resutaldos em um arquivo CSV    
   CriaRelatorio();
  }
//+------------------------------------------------------------------+

//Função para identificar nova barra
bool NovaBarra(){
   static datetime tempo_velho= 0;
          datetime tempo_novo = iTime(Symbol(),Period(),0);
   if(tempo_novo!=tempo_velho){
      tempo_velho=tempo_novo;
      return true;
   } 
 return false;
}

//Função para criar um relatório
bool CriaRelatorio()
{
 int handle = FileOpen("Ariel.csv",FILE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_COMMON|FILE_CSV, ";");
 if (handle > 0)
  {
   for (int i = 1; i<=total_operacao;i++)
   {
    FileWrite(handle,relatorio[i].time,relatorio[i].simbolo,relatorio[i].sinal,relatorio[i].resultado);
   }
   FileClose(handle);
   Comment("Backup criado com sucesso");
   return true;
  }
  else
  {
   Comment(GetLastError());
   return false;
  }
}


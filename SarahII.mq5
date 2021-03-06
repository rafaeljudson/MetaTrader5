#property copyright "Rafael Valle"
#property link      "rafaeljudson11@gmail.com"
#property version   "1.01"

int         temporizador = 1;                                        //número de segundos que o evento OnTimer() vai ser acionado.
MqlTick                ticks;                                        //variável do tipo estrutura Mqltick para armazenar as informações de cada tick recebido.
MqlBookInfo           book[];                                        //variável do tipo estrutura MqlBookInfo para armazenar as informações do livro de ofertas.

int OnInit()
{

 if(!EventSetTimer(temporizador)) { return(INIT_FAILED); };          //cria e certifica se o temporizador do evento OnTimer() foi criado.
 if(!MarketBookAdd(_Symbol))      { return(INIT_FAILED); };          //seleciona e certifica se o livro de ofertas do ativo selecionado no gráfico foi aberto.
 
 Comment("");
 
 return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

 Comment("");
 EventKillTimer();                                                   //destrói o temporizador.
 MarketBookRelease(_Symbol);                                         //fecha o livro de ofertas do ativo selecionado no gráfico.
   
}

void OnTimer()
{
 if(!MarketBookGet(_Symbol,book)) { return; };
 if(ArraySize(book)<=0)           { return; };
 
 int index            = BidIndex(book);
 int nivel            = 4;
 double balance_atual = CalcularImbalance(book,nivel,index);
 
 Comment("Índice da melhor venda  : ",index-1,
       "\nÍndice da melhor compra : ",index,
       "\nImbalance : ",balance_atual);
       
}
  
int BidIndex(MqlBookInfo &_book[])
{
 if (ArraySize(_book)==2)
 {
  return (1);                               //Mercado em leilão.
 }
 if (ArraySize(_book)>2)
 {
  for (int i=0; i<ArraySize(_book); i++)
  {
   if ((_book[i].type == BOOK_TYPE_BUY)||(_book[i].type == BOOK_TYPE_BUY_MARKET))
   {
    return i;                            //Achado o index da melhor compra.
   }
  }
  return -1;                             //Erro em achar o index de Bid.
 }
 return -2;                              //Erro extraordinário
}

double CalcularImbalance(MqlBookInfo &_book[], int nivel, int index)
{
 double compra = 0;
 double venda  = 0;
 
 if (ArraySize(_book)==2)
 {
  return (_book[index].volume_real-_book[index-1].volume_real);
 }
 for (int i=0; i<nivel; i++ )
 {
  compra+= _book[index+i].volume_real;
  venda += _book[((index-1)-3)+i].volume_real;
 }
 return (compra-venda);
}


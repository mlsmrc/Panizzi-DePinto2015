#import "ConnectionToServer.h"
#import "Poll.h"
#import "Candidate.h"

/* Stringhe che appariranno a video per feedback di connessione e lista poll vuota */
NSString *SERVER_UNREACHABLE = @"Server non raggiungibile!\nAggiorna per riprovare.";
NSString *EMPTY_POLLS_LIST = @"Non sono presenti sondaggi.\nProva ad aggiornare la Home.";


NSMutableDictionary *dizionarioPolls;

@implementation ConnectionToServer {
    
    /* Dizionario che conterrà i poll scaricati per una determinata connessione */
    NSMutableDictionary *dizionarioPolls;
    
}

/*  La funzione inizialmente sostituisce alle sottostringhe del tipo _PARAMETRO_   *
 *  (all'interno della stringa url) i parametri propri della funzione.             *
 *  Crea successivamente una richiesta asincrona verso l'API, il cui risultato     *
 *  verrà inserito all'interno di un dizionario.                                   *
 *  Se non si vuole inserire un parametro si inserisce una stringa vuota ""        *
 *  (il php delle API lo avvertirà come se il parametro non fosse stato inserito). */
- (void) scaricaPollsWithPollId:(NSString*)pollId andUserId:(NSString*) userId andStart:(NSString*)start {
    
    /* Sostituzione dei parametri */
    NSString *url=[URL_GET_POLLS  stringByReplacingOccurrencesOfString:@"_POLL_ID_" withString:[NSString stringWithFormat:@"%@",pollId]];
    url=[url  stringByReplacingOccurrencesOfString:@"_USER_ID_" withString:userId];
    url=[url stringByReplacingOccurrencesOfString:@"_START_" withString:[NSString stringWithFormat:@"%@",start]];
    
    /* Creazione della richiesta ed invio */
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    /* Allocazione del dizionario che conterrà i poll scaricati per una determinata connessione */
    dizionarioPolls = [[NSMutableDictionary alloc]init];
    
    /* Viene controllato se la risposta del server è diversa da nil (connessione assente) */
    if(response!=nil) {
        
        /* Esito positivo: parsing del JSON nel dizionario polls (una entry per ogni poll) */
        NSMutableDictionary *polls = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        
        /* Controlliamo se la richiesta ha prodotto dei poll (se non ci fossero poll non succede nulla, il dizionario rimane vuoto) */
        if(polls!=nil) {
            
            /* Funzione che prende i pollid per ogni poll presente nel dizionario */
            NSArray *pollid = [polls valueForKey:@"pollid"];
            
            int i = 0;
            NSString *str;
            
            /* Controlla se pollid è un array, se lo è allora vuol dire che c'erano almeno due poll nel JSON altrimenti solo uno */
            if ([pollid isKindOfClass:[NSArray class]]) {
                
                /* Iterazione che permette di costruire il dizionario nel seguente modo: <pollid1,poll1>,<pollid2,poll2>,...,<pollidN,pollN> */
                for(id key in polls) {
                    
                    str = pollid[i];
                    [dizionarioPolls setObject:key forKey:[NSString stringWithString:str]];
                    i = i + 1;
                    
                }
                
            }
            
            else {
                
                /* Se c'è solo un poll scaricato non serve iterare, OBJ-C vede questa come una variabile e non come array da un elemento */
                [dizionarioPolls setObject:polls forKey:pollid];
                
            }
            
        }
        
    }
    
    /* Non c'è connessione */
    else dizionarioPolls = nil;
    
}

/* Funzione che ritorna le scelte per il voto di un determinato poll specificato tramite pollId */
- (NSMutableArray*) getCandidatesWithPollId:(NSString*)pollId
{
    
    NSString * url=[URL_GET_CANDIDATES stringByReplacingOccurrencesOfString:@"_POLL_ID_" withString:[NSString stringWithFormat:@"%@",pollId]];
    NSLog(@"URL RICHIESTA: %@",url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSDictionary *dict;
    
    NSMutableArray * arrayCandidates= [[NSMutableArray alloc]init];
    
    if(response!=nil)
    {
        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        response=nil;
       
        for(NSString * key in dict)
        {
            Candidate * candidate=[[Candidate alloc]init];
            [candidate setCandicateWithChar: [key valueForKey:@"candchar"] andName:[key valueForKey:@"candname"]  andDescription:[key valueForKey:@"canddescription"]] ;
            [arrayCandidates addObject:candidate];
            candidate=nil;
        }
            
    }
    
    return arrayCandidates;
}

/* Funzione che dato un pollId, che fa riferimento ad un particolare poll, uno userId, che indica chi sta votando e *
 * una classifica (sotto la forma a,b,c,d,e), invia il voto del poll                                                */
- (void) submitRankingWithPollId:(NSString*)pollId andUserId:(NSString*)userId andRanking:(NSString*) ranking
{
    /* Creazione URL */
    NSString * url=[URL_SUBMIT_RANKING stringByReplacingOccurrencesOfString:@"_POLL_ID_" withString:[NSString stringWithFormat:@"%@",pollId]];
    url=[url stringByReplacingOccurrencesOfString:@"_USER_ID_" withString:[NSString stringWithFormat:@"%@",userId]];
    url=[url stringByReplacingOccurrencesOfString:@"_RANKING_" withString:[NSString stringWithFormat:@"%@",ranking]];

    /* Invio richiesta */
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

/*  Funzione che dato un oggetto di tipo Poll, aggiunge un poll e   *
 *  ritorna l'id del poll appena inserito come stringa              */
- (NSString *) addPollWithPoll:(Poll*)newpoll
{
    /* Preparazione dati richiesta POST */
    NSString *post = [NSString stringWithFormat:@"newpoll=%@",[newpoll toJSON]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    /* Preparazione richiesta post */
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL_ADD_POLL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    /* Invio richiesta , che tornerà un json con il pollid*/
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *requestReply = [[NSString alloc] initWithBytes:[requestHandler bytes] length:[requestHandler length] encoding:NSASCIIStringEncoding];
    
    /* creazione dizionario per estrapolare il pollid */
    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[requestReply dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];

    /* si ritorna il pollid associato */
    return ([d valueForKey:@"pollid"]);
    
    
}

/* Ritorna il dizionario contenente i poll nel formato <pollid,poll> */
- (NSMutableDictionary*) getDizionarioPolls
{
    return dizionarioPolls;
}

@end
#import <Foundation/Foundation.h>
#import "File.h"

NSString *VOTES_PLIST = @"Votes.strings";
NSString *INFO_PLIST = @"Info";
NSString *CUSTOM_UDID = @"CustomUDID";
NSString *SAVE_RANK = @"SaveRank.strings";
NSString *VOTES_PLIST_DATE = @"VotesDate.strings";
NSString *RELOAD = @"Reload.strings";

@implementation File: NSObject

/* Dato un pollid e la classifica, scrive all'interno del file Votes.strings la votazione effettuata */
+ (BOOL) writeOnPListRanking:(NSString*)ranking OfPoll:(NSString*)pollid {
    
    return [File writeString:ranking forKey:pollid inPList:VOTES_PLIST];

}

/* Dato un pollid e la data, scrive all'interno del file VotesDate.strings la data relativa alla votazione effettuata */
+ (BOOL) writeOnPListRankDateOfPoll:(NSString*)pollid {

    return [File writeString: [[[NSDate alloc] init] description] forKey:pollid inPList:VOTES_PLIST_DATE];
    
}

/* Dato un pollid, legge all'interno del file Votes.plist la votazione effettuata */
+ (NSString*) getRankingOfPoll:(int)pollid {
    
    return [File readStringforKey:[NSString stringWithFormat:@"%d",pollid] inPList:VOTES_PLIST];

}

/* Dato un pollid, legge all'interno del file VotesDate.plist il giorno relativo alla votazione effettuata */
+ (NSString*) getRankDateOfPoll:(int)pollid {
    
    return [File readStringforKey:[NSString stringWithFormat:@"%d",pollid] inPList:VOTES_PLIST_DATE];
    
}

/* Lettura da info.plist dell'uuid salvato in precedenza. Se inesistente torna NULL */
+ (NSString*) getUDID {
    
    return [File readStringforKey:CUSTOM_UDID inPList:INFO_PLIST];

}

/* Scrittura su info.plist dell'uuid generato */
+ (BOOL) writeUDID {
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return [File writeString:uuid forKey:CUSTOM_UDID inPList:INFO_PLIST];

}

/* Funzione generica privata che scrive una coppia <chiave,info> su una plist */
+ (BOOL) writeString:(NSString*)Info forKey:(NSString*)key inPList:(NSString *)PList {
    
    
    NSString *path = [[self applicationDocumentsDirectory].path
                      stringByAppendingPathComponent:PList];
    
    NSString *filePath = [[self applicationDocumentsDirectory].path
                          stringByAppendingPathComponent:PList];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSMutableDictionary *votesPList;
    
    if([fileManager fileExistsAtPath:filePath])
        votesPList = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    else
        votesPList = [[NSMutableDictionary alloc] init];
    
    /* Aggiunta riga e scrittura su file */
    [votesPList setObject:Info forKey:key];
    
    return [[[NSDictionary alloc]initWithDictionary:votesPList] writeToFile:path atomically:YES];
    
}

/* Funzione generica privata che legge una stringa da una plist data una chiave */
+ (NSString *) readStringforKey:(NSString*)key inPList:(NSString *)PList {
    
    
    /* Cattura il path del file sulla Documents Directory */
    NSString *path = [[self applicationDocumentsDirectory].path
                      stringByAppendingPathComponent:PList];
    
    /* Cattura del file Votes.plist in un dizionario */
    NSMutableDictionary *votesPList = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    return [votesPList objectForKey:key];
    
}

/* Funzione che ritorna tutte le chiavi da una plist */
+ (NSArray *) getAllKeysinPList:(NSString *)PList {
    
    /* Catturo il path del file sulla Documents Directory */
    NSString *path = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:PList];
    
    /* Cattura del file Votes.plist in un dizionario */
    NSMutableDictionary *votesPList = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    return [votesPList allKeys];
    
}

/* Ritorna l'URL dell'application Documents Directory */
+ (NSURL *) applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
}

/* Elimina il contenuto a SaveRank.strings */
+ (BOOL) clearSaveRank {
    
    return [self clearFile:SAVE_RANK];

}

/* Salva una stringa di ranking sul file SaveRank.strings */
+ (BOOL) SaveRank:(NSString *)rank OfPoll:(NSString *)pollId {
    
    return [File writeString:rank forKey:pollId inPList:SAVE_RANK];

}

/* Elimina il contenuto ad un file generico */
+ (BOOL) clearFile:(NSString*)File {
    
    NSString *filePath = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:File];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if([fileManager fileExistsAtPath:filePath])
        return [fileManager removeItemAtPath:filePath error:&error];
    
    else
        return true;
    
}

/* Ritorna la classifica salvata in SaveRank.strings */
+ (NSString *) getSaveRankOfPoll:(NSString*)pollid {
    
    return [self readStringforKey:pollid inPList:SAVE_RANK];

}

/* Scrive il valore del flag sul file di Reload */
+ (void) writeOnReload:(NSString *)value ofFlags:(NSMutableArray*)FLAGS {
    
    NSString *view;
    
    for(int i=0;i<[FLAGS count];i++) {
        
        if([[FLAGS objectAtIndex:i] isEqualToString:(@"HOME")])
            view = @"FLAG_HOME";
        
        if([[FLAGS objectAtIndex:i] isEqualToString:(@"MYPOLL")])
            view = @"FLAG_MYPOLL";
        
        if([[FLAGS objectAtIndex:i] isEqualToString:(@"VOTATI")])
            view = @"FLAG_VOTATI";
        
        if([[FLAGS objectAtIndex:i] isEqualToString:(@"DETTAGLI")])
            view = @"FLAG_DETTAGLI";
        
        if([[FLAGS objectAtIndex:i] isEqualToString:(@"RISULTATI")])
            view = @"FLAG_RISULTATI";

        [File writeString:value forKey:view inPList:RELOAD];
        
    }
    
}

/* Data una chiave, legge all'interno del file Reload.strings e ritorna il valore */
+ (NSString*) readFromReload:(NSString*)key {
    
    return [File readStringforKey:key inPList:RELOAD];
    
}

@end
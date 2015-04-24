#import "ViewControllerVoto.h"
#import "ConnectionToServer.h"
#import "UtilTableView.h"

#define VOTI_OK 0

@interface ViewControllerVoto ()

@end

@implementation ViewControllerVoto

@synthesize candidateNames,candidateChars,name,poll,tableView;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    /* Impostata su "editing" la table view per poter muovere le celle */
    [tableView setEditing:YES animated:YES];
    
    /* Permette alla table view di non stampare celle vuote che vanno oltre quelle dei risultati */
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

/* Funzioni che permettono di visualizzare i nomi dei candidates nelle celle della schermata del voto */
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [candidateNames count];
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"VoteCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    
    name = [candidateNames objectAtIndex:indexPath.row];
    cell.textLabel.text = name;
    cell.imageView.image = [UtilTableView imageWithImage:[UIImage imageNamed:@"Poll-image"] scaledToSize:CGSizeMake(CELL_HEIGHT-20, CELL_HEIGHT-20)];
    [cell setSeparatorInset:UIEdgeInsetsZero];
    
    return cell;
    
}

/* Permette di modificare l'altezza delle righe della schermata "Home" */
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CELL_HEIGHT;
    
}

/* Funzioni che permettono di stilare la classifica mediante drag & drop delle celle */
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleNone;
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
    
}

/* Metodo che tiene conto della classifica fatta dall'utente mediante l'array */
- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSInteger sourceRow = sourceIndexPath.row;
    NSInteger destRow = destinationIndexPath.row;
    id object = [candidateNames objectAtIndex:sourceRow];
    [candidateNames removeObjectAtIndex:sourceRow];
    [candidateNames insertObject:object atIndex:destRow];
    object = [candidateChars objectAtIndex:sourceRow];
    [candidateChars removeObjectAtIndex:sourceRow];
    [candidateChars insertObject:object atIndex:destRow];
    
}

/* Invio della classifica al server */
- (IBAction)vota:(id)sender {
    
    ConnectionToServer *conn = [[ConnectionToServer alloc]init];
    NSMutableString *ranking = [[NSMutableString alloc]initWithString:@""];
    
    for(int i=0;i<[candidateChars count];i++) {
        
        if(i != [candidateChars count] - 1)
            ranking = [NSMutableString stringWithFormat:@"%@%@,",ranking,[candidateChars objectAtIndex:i]];
        
        else
            ranking = [NSMutableString stringWithFormat:@"%@%@",ranking,[candidateChars objectAtIndex:i]];
        
    }
    
    [conn submitRankingWithPollId:[NSString stringWithFormat:@"%d",poll.pollId]  andUserId:poll.userID andRanking:ranking];
    
    /* Popup per voto sottomesso */
    UIAlertView *alert = [UIAlertView alloc];
    alert.tag = VOTI_OK;
    alert = [alert initWithTitle:@"Messaggio" message:@"Votazione effettuata con successo!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
    
}

/* Funzione delegate per i Popup della view */
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    /* Titolo del bottone cliccato */
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    /* L'alert view conseguente ad una votazione effettuata */
    if(alertView.tag == VOTI_OK) {
        
        if([title isEqualToString:@"Ok"])
            
            /* Vai alla Home */
            [self.navigationController popToRootViewControllerAnimated:TRUE];

    }

}

@end
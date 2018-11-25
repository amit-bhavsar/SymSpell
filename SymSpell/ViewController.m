//
//  ViewController.h
//  SymSpell
//
//  Created by Amit on 25/11/18.
//  Copyright © 2018 Amit. All rights reserved.
//

#import "ViewController.h"

#import "ViewController.h"
#import "TapAutoCorrect.h"
#import "SuggestItem.h"
#import "HelpersForTapAutocorrect.h"
#import "WeightedDistance.h"
#import <Realm/Realm.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtWord;
@property (weak, nonatomic) IBOutlet UITableView *tblWords;
@property (strong, nonatomic) NSMutableArray<SuggestItem*> *arrSuggestion;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _tblWords.tableFooterView = [[UIView alloc]init];
    
    [_txtWord addTarget:self
                  action:@selector(editingChanged:)
        forControlEvents:UIControlEventEditingChanged];
    //[self lookupWord];
    
    //[self callSymspell];
    
    
    
    
    
}

- (void) lookupWord {
    TapAutoCorrect *ac = [[TapAutoCorrect alloc]init];
    
    [ac initSymSpellWithCapacity:25 MaxDictionaryEditDistance:3 PrefixLength:7 CountTHreshold:1 compactLevel:5 maxLength:0];
    
    
    
    NSMutableArray *array = [ac lookupRealmForWord:@"wgta" maxEditDistance:3 verbosity:2 includeUnknown:YES];
    NSLog(@"end lookup");
    for (SuggestItem *si in array){
        NSLog(@"correctedWord: %@, %lli ,%lli",si.term, (int64_t)si.distance, (int64_t)si.count);
    }
    
    NSMutableArray *array0 = [ac lookupRealmForWord:@"aojecm" maxEditDistance:3 verbosity:2 includeUnknown:YES];
    NSLog(@"end lookup");
    for (SuggestItem *si in array0){
        NSLog(@"correctedWord: %@, %i ,%i",si.term, (int)si.distance, (int)si.count);
    }
    
    NSMutableArray *array1 = [ac lookupRealmForWord:@"shoflg" maxEditDistance:3 verbosity:2 includeUnknown:YES];
    NSLog(@"end lookup");
    for (SuggestItem *si in array1){
        NSLog(@"correctedWord: %@, %i ,%i",si.term, (int)si.distance, (int)si.count);
    }
    
    NSMutableArray *array2 = [ac lookupRealmForWord:@"cant" maxEditDistance:3 verbosity:2 includeUnknown:YES];
    NSLog(@"end lookup");
    for (SuggestItem *si in array2){
        NSLog(@"correctedWord imediate -> %@",si.term);
    }
    
    
    NSMutableArray *array3 = [ac lookupCompoundForWord:@"wgatarw" maxEditDistance:2 ingnoreNonWords:NO];
    NSLog(@"end lookup");
    for (SuggestItem *si in array3){
        NSLog(@"correctedWord: %@",si.term);
    }
    
    NSMutableArray *array4 = [ac lookupCompoundForWord:@"internartionalbfunctional" maxEditDistance:3 ingnoreNonWords:YES];
    NSLog(@"end lookup");
    for (SuggestItem *si in array4){
        NSLog(@"correctedWord: %@",si.term);
    }
    
    
    [_tblWords reloadData];
}

- (void)callSymspell {
    TapAutoCorrect *ac = [[TapAutoCorrect alloc]init];
    
    [ac initSymSpellWithCapacity:16 MaxDictionaryEditDistance:2 PrefixLength:7 CountTHreshold:1 compactLevel:5 maxLength:0];
    
    [ac loadDictionaryWithStirng];
    
    NSLog(@"Start lookup");
    NSMutableArray *array = [ac lookupForWord:@"ygks" maxEditDistance:3 verbosity:0 includeUnknown:YES];
    NSLog(@"end lookup");
    for (SuggestItem *si in array){
        NSLog(@"correctedWord ygks : %@",si.term);
    }
    
    NSMutableArray *array0 = [ac lookupForWord:@"what" maxEditDistance:3 verbosity:0 includeUnknown:YES];
    NSLog(@"end lookup");
    for (SuggestItem *si in array0){
        NSLog(@"correctedWord what : %@",si.term);
    }
    
    NSMutableArray *array1 = [ac lookupForWord:@"qgat" maxEditDistance:3 verbosity:0 includeUnknown:YES];
    NSLog(@"end lookup");
    for (SuggestItem *si in array1){
        NSLog(@"correctedWord qgat : %@",si.term);
    }
    
    NSMutableArray *array2 = [ac lookupForWord:@"imediate" maxEditDistance:3 verbosity:0 includeUnknown:YES];
    NSLog(@"end lookup");
    for (SuggestItem *si in array2){
        NSLog(@"correctedWord imediate: %@",si.term);
    }
}

-(void) editingChanged:(id)sender {
    if (_txtWord.text.length > 0) {
        _arrSuggestion = [[NSMutableArray alloc]init];
        
        TapAutoCorrect *ac = [[TapAutoCorrect alloc]init];
        
        [ac initSymSpellWithCapacity:16 MaxDictionaryEditDistance:2 PrefixLength:7 CountTHreshold:1 compactLevel:5 maxLength:0];
        
        _arrSuggestion = [ac lookupRealmForWord:_txtWord.text maxEditDistance:2 verbosity:2 includeUnknown:YES];
        
        
        //Fuzzy text logic
//        NSArray *compoundWords = [ac lookupCompoundForWord:_txtWord.text maxEditDistance:3 ingnoreNonWords:YES];
//        [_arrSuggestion addObjectsFromArray:compoundWords];
        
        [_tblWords reloadData];
        
        //_arrSuggestion[indexPath.row].term
        
        
    } else {
        _arrSuggestion = [[NSMutableArray alloc]init];
        [_tblWords reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrSuggestion.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
    cell.textLabel.text = _arrSuggestion[indexPath.row].term;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance : %ld  ",_arrSuggestion[indexPath.row].distance];
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_txtWord resignFirstResponder];
    return true;
}
@end

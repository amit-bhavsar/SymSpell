# SymSpell

A Objective-C port of [SymSpell v6.3](https://github.com/wolfgarbe/SymSpell).  
Realm database is used for speed and memory efficiency.  

# Usage
```Objective-C

_arrSuggestion = [[NSMutableArray alloc]init];
        
TapAutoCorrect *ac = [[TapAutoCorrect alloc]init];
        
[ac initSymSpellWithCapacity:16 MaxDictionaryEditDistance:2 PrefixLength:7 CountTHreshold:1 compactLevel:5 maxLength:0];
        
_arrSuggestion = [ac lookupRealmForWord:_txtWord.text maxEditDistance:2 verbosity:2 includeUnknown:YES];

```

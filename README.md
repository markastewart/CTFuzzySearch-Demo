CTFuzzySearch is a lightweight framework for fast and fuzzy string searching.
=============================================================================

This repository contains the demo framework and an example project.

The demo version adds the word 'DEMO' after the first 2 matches but otherwise performs as the full version.

You can
* download the CTFuzzySearch.framework (demo version)
* drag it into your XCode project to the Frameworks group
* include the header file CTFuzzySearch/CTFuzzySearch.h

Code Sample
-----------
This minimalistic code sample should get you started within a few minutes:
```Objective-C
CTFuzzyIndex *index = [CTFuzzyIndex new];

// Add words to the index, these can be hundreds of thousands
NSArray *words = [NSArray arrayWithObjects:@"fast", @"fuzzy", @"string", @"searching", nil];
for(NSString *word in words) {
    [index addStringValue:word];
}
    
// Search the index for matches of word with 2 errors maximum
NSArray *matches = [index search:@"zearchin" withMaxDistance:2];
for(CTFuzzyMatch *match in matches) {
    NSLog("Found matching word '%@' with %d errors.", match.value, match.distance);
}
```
CTFuzzySearch is a lightweight framework for fast and fuzzy string searching.
=============================================================================

This repository contains the demo framework and an example project.

The demo version mofifies the first match (adds the word DEMO and removes context data) and is limited to a maximum serach distance of 2 but otherwise it performs as the full version.

Code Sample
-----------
This minimalistic code sample should get you started within a few minutes. For a bigger demo look into the Examples folder.
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

Embedding in own projects
-------------------------
* download the CTFuzzySearch.framework (demo version)
* drag it into your XCode project
* include the header file CTFuzzySearch/CTFuzzySearch.h
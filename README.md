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
[index addWordsFromString:@"fuzzy string searching using CTFuzzySearch" options:CTFuzzyIndexIncludeRanges];
    
// Search the index for matches of word with 2 errors maximum
NSArray *matches = [index search:@"zearchin" withMaxDistance:2];
for(CTFuzzyMatch *match in matches) {
    NSLog("Found %d occurrences of matching word '%@'.", [match.data count], match.value);
}
```

Embedding in own projects
-------------------------
* download the CTFuzzySearch.framework (demo version)
* drag it into your XCode project
* include the header file CTFuzzySearch/CTFuzzySearch.h
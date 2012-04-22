#import <Foundation/Foundation.h>

enum {
    CTFuzzyIndexIncludeRanges = 1
};
typedef NSUInteger CTFuzzyIndexOptions;

@interface CTFuzzyIndex : NSObject
- (void)addString:(NSString*)string;
- (void)addString:(NSString*)string withData:(id)data;
- (void)addWordsFromString:(NSString *)string options:(CTFuzzyIndexOptions)opts;
- (NSArray*)search:(NSString*)string withMaxDistance:(NSInteger)distance;
@end

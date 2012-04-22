#import <Foundation/Foundation.h>

@interface CTFuzzyIndex : NSObject
- (void)addStringValue:(NSString*)value;
- (void)addStringValue:(NSString*)value withData:(id)data;
- (NSArray*)search:(NSString*)word withMaxDistance:(NSInteger)distance;
@end

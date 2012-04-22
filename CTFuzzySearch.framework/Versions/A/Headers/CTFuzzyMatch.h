#import <Foundation/Foundation.h>

@interface CTFuzzyMatch : NSObject
@property (assign, nonatomic, readonly) NSInteger distance;
@property (strong, nonatomic, readonly) NSArray *data;
@property (copy, nonatomic, readonly) NSString *value;

- (id)init UNAVAILABLE_ATTRIBUTE;
+ (id)new UNAVAILABLE_ATTRIBUTE;
@end

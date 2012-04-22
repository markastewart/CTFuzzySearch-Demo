#import <UIKit/UIKit.h>

@class CTFuzzyMatch;

@interface CTMatchViewController : UITableViewController
- (id)initWithMatch:(CTFuzzyMatch*)match andFullText:(NSString*)fullText;
@end

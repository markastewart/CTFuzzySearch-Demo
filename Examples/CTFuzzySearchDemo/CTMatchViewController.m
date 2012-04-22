#import "CTMatchViewController.h"

#import <CTFuzzySearch/CTFuzzySearch.h>

@interface CTMatchViewController ()
@property (strong, nonatomic) CTFuzzyMatch *match;
@property (copy, nonatomic) NSString *fullText;
@end

@implementation CTMatchViewController
@synthesize match = match_;
@synthesize fullText = fullText_;

- (id)initWithMatch:(CTFuzzyMatch*)match andFullText:(NSString*)fullText
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.match = match;
        self.fullText = fullText;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.match.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MatchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSValue *rangeValue = [self.match.data objectAtIndex:indexPath.row];
    NSRange range = [rangeValue rangeValue];
    NSUInteger expandLeft = 10;
    NSUInteger expandRight = 20;
    
    if(range.location>expandLeft) range.location -= expandLeft;
    if(range.location+range.length+expandLeft+expandRight<[self.fullText length]) range.length += expandLeft+expandRight;
    cell.textLabel.text = [NSString stringWithFormat:@"…%@", [self.fullText substringWithRange:range]];
    
    return cell;
}

@end

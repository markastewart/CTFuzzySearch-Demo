#import "CTEditViewController.h"

#import <CTFuzzySearch/CTFuzzySearch.h>
#import "CTMatchViewController.h"

@interface CTEditViewController ()
@property (strong, nonatomic) UISearchDisplayController *search;
@property (strong, nonatomic) CTFuzzyIndex *index;
@property (strong, nonatomic) NSArray *matches;
@property (strong, nonatomic) UITextView *textView;
@property (assign, nonatomic) dispatch_queue_t serialSearchQueue;
- (void)startSearch;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
@end

@implementation CTEditViewController
@synthesize serialSearchQueue = serialSearchQueue_;
@synthesize search = search_;
@synthesize index = index_;
@synthesize matches = matches_;
@synthesize textView = textView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"CTFuzzySearch Demo";
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startSearch
{
    NSString *text = self.search.searchBar.text;
    NSInteger distance = self.search.searchBar.selectedScopeButtonIndex;
    
    dispatch_async(self.serialSearchQueue, ^{
        NSDate *searchingStart = [NSDate new];
        NSArray *matches = [self.index search:text withMaxDistance:distance];
        NSLog(@"Searching finished in %f secs.", -[searchingStart timeIntervalSinceNow]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.matches = matches;
            [self.search.searchResultsTableView reloadData];
        });
    });
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = self.textView.contentInset;
    contentInsets.bottom = keyboardSize.height;
    self.textView.contentInset = contentInsets;
    self.textView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, self.textView.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.textView.frame.origin.y - (keyboardSize.height-15));
        [self.textView setContentOffset:scrollPoint animated:YES];
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = self.textView.contentInset;
    contentInsets.bottom = 0.0;
    self.textView.contentInset = contentInsets;
    self.textView.scrollIndicatorInsets = contentInsets;
}

- (void)loadView
{
    [super loadView];
    
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:self.view.bounds];
    searchBar.placeholder = @"Search";
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.delegate = self;
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Exact Match", @"Max. 1 Error", @"Max. 2 Errors", nil];
    searchBar.selectedScopeButtonIndex = 1;
	[searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[searchBar sizeToFit];

    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.contentInset = UIEdgeInsetsMake(searchBar.frame.size.height, 0.0, 0.0, 0.0);
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(searchBar.frame.size.height, 0.0, 0.0, 0.0);
    
    NSString *wordPath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"txt"];
    self.textView.text = [NSString stringWithContentsOfFile:wordPath encoding:NSUTF8StringEncoding error:nil];

    [self.view addSubview:self.textView];
    [self.view addSubview:searchBar];

    
    self.search = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	[self.search setDelegate:self];
	[self.search setSearchResultsDataSource:self];
    [self.search setSearchResultsDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return NO;
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    NSString *placeholder = self.search.searchBar.placeholder;
    self.search.searchBar.placeholder = @"Indexing...";
    
    self.serialSearchQueue = dispatch_queue_create("org.wimberger.FuzzySearchQueue", NULL);
    NSString *text = self.textView.text;
    dispatch_async(self.serialSearchQueue, ^{
        CTFuzzyIndex *idx = [CTFuzzyIndex new];

        NSDate *indexingStart = [NSDate new];
        [idx addWordsFromString:text options:CTFuzzyIndexIncludeRanges];
        NSLog(@"Indexing finished in %f secs.", -[indexingStart timeIntervalSinceNow]);

        dispatch_async(dispatch_get_main_queue(), ^{
            self.search.searchBar.placeholder = placeholder;
            self.index = idx;
        });
    });
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    dispatch_async(self.serialSearchQueue, ^{
        dispatch_release(self.serialSearchQueue);
        self.index = nil;
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.matches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CTFuzzyMatch *match = [self.matches objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d matches)", match.value, [match.data count]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTFuzzyMatch *match = [self.matches objectAtIndex:indexPath.row];

    if ([[match.data objectAtIndex:0] isKindOfClass:NSValue.class]) {
        CTMatchViewController *mvc = [[CTMatchViewController alloc] initWithMatch:match andFullText:self.textView.text];
        [self.navigationController pushViewController:mvc animated:YES];
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Demo Version" message:@"This function is limited in the demo version. Please try another search result." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self.search.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self startSearch];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self startSearch];
}

@end

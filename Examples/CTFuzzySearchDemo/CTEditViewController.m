#import "CTEditViewController.h"

#import <CTFuzzySearch/CTFuzzySearch.h>

@interface CTEditViewController ()
@property (strong, nonatomic) UISearchDisplayController *search;
@property (strong, nonatomic) CTFuzzyIndex *index;
@property (strong, nonatomic) NSArray *matches;
@property (strong, nonatomic) UITextView *textView;
@property (assign, nonatomic) dispatch_queue_t serialSearchQueue;
- (void)startSearch;
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

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    NSString *placeholder = self.search.searchBar.placeholder;
    self.search.searchBar.placeholder = @"Indexing...";
    
    self.serialSearchQueue = dispatch_queue_create("org.wimberger.FuzzySearchQueue", NULL);
    NSString *wordString = self.textView.text;
    dispatch_async(self.serialSearchQueue, ^{
        NSArray *words = [wordString componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
        
        CTFuzzyIndex *idx = [CTFuzzyIndex new];
        for(NSString *word in words) {
            if([word length]>0) {
                [idx addStringValue:word];
            }
        }

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.matches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    CTFuzzyMatch *match = [self.matches objectAtIndex:indexPath.row];
    cell.textLabel.text = match.value;
    return cell;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return NO;
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self startSearch];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self startSearch];
}

- (void)startSearch
{
    NSString *text = self.search.searchBar.text;
    NSInteger distance = self.search.searchBar.selectedScopeButtonIndex;
    
    dispatch_async(self.serialSearchQueue, ^{
        NSArray *matches = [self.index search:text withMaxDistance:distance];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.matches = matches;
            [self.search.searchResultsTableView reloadData];
        });
    });
}

@end

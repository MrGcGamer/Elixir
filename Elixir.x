#import <UIKit/UIKit.h>




@interface OrionTweakSpecifiersController : UIViewController
@property (nonatomic, strong) UILabel *tweakCount;
- (UITableView*)table;
@end


@interface AdvancedSettingsListController : UIViewController
@property (nonatomic, strong) UILabel *tweakCount;
- (UITableView*)table;
@end


/*@interface PSUIPrefsListController : UIViewController
@property (nonatomic, strong) UILabel *tweakCount;
- (UITableView*)table;
@end*/




%hook OrionTweakSpecifiersController


%property (nonatomic, strong) UILabel *tweakCount;


- (void)viewDidLoad {


	%orig;


	NSString* bundlePath = @"/Library/PreferenceLoader/Preferences";
	NSArray *directoryContent  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundlePath error:nil];
	int numberOfFileInFolder = [directoryContent count];


	self.tweakCount = [[UILabel alloc] init];
	self.tweakCount.text = [NSString stringWithFormat:@"%d",numberOfFileInFolder];
	self.tweakCount.font = [UIFont boldSystemFontOfSize:20];


	[self.table addSubview:self.tweakCount];


	self.tweakCount.translatesAutoresizingMaskIntoConstraints = NO;


	[self.tweakCount.topAnchor constraintEqualToAnchor : [self.table.contentLayoutGuide topAnchor] constant:5].active = YES;
	[self.tweakCount.centerXAnchor constraintEqualToAnchor : [self.view centerXAnchor]].active = YES;


}


%end




%hook AdvancedSettingsListController


%property (nonatomic, strong) UILabel *tweakCount;


- (void)viewDidLoad {


	%orig;


	NSString* bundlePath = @"/Library/PreferenceLoader/Preferences";
	NSArray *directoryContent  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundlePath error:nil];
	int numberOfFileInFolder = [directoryContent count];


	self.tweakCount = [[UILabel alloc] init];
	self.tweakCount.text = [NSString stringWithFormat:@"%d",numberOfFileInFolder];
	self.tweakCount.font = [UIFont boldSystemFontOfSize:20];
	

	NSLog(@"Hmm");


	[self.view addSubview:self.tweakCount];


	self.tweakCount.translatesAutoresizingMaskIntoConstraints = NO;


	[self.tweakCount.topAnchor constraintEqualToAnchor : [self.view topAnchor] constant:98].active = YES;
	[self.tweakCount.centerXAnchor constraintEqualToAnchor : [self.view centerXAnchor]].active = YES;
	

}


%end
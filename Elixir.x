#import <UIKit/UIKit.h>




@interface UITableView ()
@property (nonatomic, strong) UILabel *tweakCount;
- (id)_viewControllerForAncestor;
@end


@interface TSRootListController : UIViewController
@property (nonatomic, copy) NSString *title;
@end


UIViewController *ancestor;


#define isCurrentApp(string) [[[NSBundle mainBundle] bundleIdentifier] isEqual : string]




%hook UITableView


%property (nonatomic, strong) UILabel *tweakCount;


- (void)didMoveToWindow {


	%orig;

	ancestor = [self _viewControllerForAncestor];


	if(([ancestor isKindOfClass:%c(OrionTweakSpecifiersController)]) || ([ancestor isKindOfClass:%c(TweakPreferencesListController)])) {


		NSString* bundlePath = @"/Library/PreferenceLoader/Preferences";
		NSArray *directoryContent  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundlePath error:nil];
		int numberOfFileInFolder = [directoryContent count];


		self.tweakCount = [[UILabel alloc] init];
		self.tweakCount.text = [NSString stringWithFormat:@"%d",numberOfFileInFolder];
		self.tweakCount.font = [UIFont boldSystemFontOfSize:18];

		[self addSubview:self.tweakCount];


		self.tweakCount.translatesAutoresizingMaskIntoConstraints = NO;


		if([ancestor isKindOfClass:%c(OrionTweakSpecifiersController)]) [self.tweakCount.topAnchor constraintEqualToAnchor : [self topAnchor] constant:8].active = YES;
		if([ancestor isKindOfClass:%c(OrionTweakSpecifiersController)]) [self.tweakCount.centerXAnchor constraintEqualToAnchor : [self centerXAnchor]].active = YES;


		if([ancestor isKindOfClass:%c(TweakPreferencesListController)]) {


			UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 10)];

			[footerView addSubview:self.tweakCount];


			self.tableFooterView = footerView;


			[self.tweakCount.centerXAnchor constraintEqualToAnchor : [footerView centerXAnchor]].active = YES;
			[self.tweakCount.centerYAnchor constraintEqualToAnchor : [footerView centerYAnchor] constant:4].active = YES;


		}

	}

}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {

 
	%orig(previousTraitCollection);


	if(previousTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)


		self.tweakCount.textColor = [UIColor blackColor];


	else


		self.tweakCount.textColor = [UIColor whiteColor];


}


%end




%hook TSRootListController


- (void)viewDidLoad {


	%orig;


	if(!(isCurrentApp(@"com.creaturecoding.tweaksettings"))) return;


	NSString* bundlePath = @"/Library/PreferenceLoader/Preferences";
	NSArray *directoryContent  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundlePath error:nil];
	int numberOfFileInFolder = [directoryContent count];
	

	self.title = [NSString stringWithFormat:@"%d", numberOfFileInFolder];


}


%end
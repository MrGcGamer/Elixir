#import <UIKit/UIKit.h>




@interface UITableView ()
@property (nonatomic, strong) UILabel *tweakCount;
- (id)_viewControllerForAncestor;
@end




%hook UITableView


%property (nonatomic, strong) UILabel *tweakCount;


- (void)didMoveToWindow {


	%orig;


	if(([[self _viewControllerForAncestor] isKindOfClass:%c(OrionTweakSpecifiersController)]) || ([[self _viewControllerForAncestor] isKindOfClass:%c(AdvancedSettingsListController)])) {


		NSString* bundlePath = @"/Library/PreferenceLoader/Preferences";
		NSArray *directoryContent  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundlePath error:nil];
		int numberOfFileInFolder = [directoryContent count];


		self.tweakCount = [[UILabel alloc] init];
		self.tweakCount.text = [NSString stringWithFormat:@"%d",numberOfFileInFolder];
		self.tweakCount.font = [UIFont boldSystemFontOfSize:20];

		[self addSubview:self.tweakCount];


		self.tweakCount.translatesAutoresizingMaskIntoConstraints = NO;


		if ([[self _viewControllerForAncestor] isKindOfClass:%c(AdvancedSettingsListController)]) [self.tweakCount.topAnchor constraintEqualToAnchor : [self topAnchor] constant:220].active = YES;
		else if ([[self _viewControllerForAncestor] isKindOfClass:%c(OrionTweakSpecifiersController)]) [self.tweakCount.topAnchor constraintEqualToAnchor : [self topAnchor] constant:6].active = YES;
		[self.tweakCount.centerXAnchor constraintEqualToAnchor : [self centerXAnchor]].active = YES;


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
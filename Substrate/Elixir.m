@import UIKit;
#import <substrate.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>


// Global

UIViewController *ancestor;

#define isCurrentApp(string) [[[NSBundle mainBundle] bundleIdentifier] isEqual : string]


@interface UITableView ()
- (id)_viewControllerForAncestor;
@end


@interface TSRootListController : UIViewController
@property (copy, nonatomic) NSString *title;
@end

@interface AMightyClass : UIView
@property (nonatomic, strong) UILabel *tweakCount;
@property (copy, nonatomic) NSString *bundlePath;
@property (nonatomic, strong) NSArray *directoryContent;
@property (nonatomic) int elixirTweakCount;
@property (nonatomic, strong) NSFileManager *fileM;
@end


@implementation AMightyClass // fancy way to avoid code duplication, haha thanks Codine. But properties >> iVars


+ (AMightyClass *)sharedInstance {

	static AMightyClass *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{

		sharedInstance = [AMightyClass new];

	});

	return sharedInstance;

}


- (instancetype)init {

	self = [super init];

	self.fileM = [NSFileManager defaultManager];

	self.bundlePath = @"/Library/PreferenceLoader/Preferences";
	self.directoryContent = [self.fileM contentsOfDirectoryAtPath:self.bundlePath error:nil];
	self.elixirTweakCount = [self.directoryContent count];

	[self setupElixirLabel];

	return self;

}


- (void)setupElixirLabel {

	self.tweakCount = [UILabel new];
	self.tweakCount.text = [NSString stringWithFormat:@"%d", self.elixirTweakCount];
	self.tweakCount.font = [UIFont boldSystemFontOfSize:18];
	self.tweakCount.translatesAutoresizingMaskIntoConstraints = NO;

}


@end


void(*origDidMoveToWindow)(UITableView *self, SEL _cmd);

void newDidMoveToWindow(UITableView *self, SEL _cmd) {

	origDidMoveToWindow(self, _cmd);

	ancestor = [self _viewControllerForAncestor];

	if([ancestor isKindOfClass:NSClassFromString(@"OrionTweakSpecifiersController")]) {

		[self addSubview:[AMightyClass sharedInstance].tweakCount];

		// Hi, if you've reached to this part, please, do yourself a favor if this is your case.
		// Stop doing cursed and weird af UIScreen calculations and math with frames for UI layout stuff, 
		// learn and embrace constraints instead, they are natural and beautiful. Also known as AutoLayout, AUTO (It does the thing for you!!!)

		[[AMightyClass sharedInstance].tweakCount.topAnchor constraintEqualToAnchor : self.topAnchor constant : 8].active = YES;
		[[AMightyClass sharedInstance].tweakCount.centerXAnchor constraintEqualToAnchor : self.centerXAnchor].active = YES;

	}

	else if([ancestor isKindOfClass:NSClassFromString(@"TweakPreferencesListController")]) { // Shuffle has a search bar so no space at the top :thishowitis:

		UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 10)];
		[footerView addSubview:[AMightyClass sharedInstance].tweakCount];

		self.tableFooterView = footerView;

		[[AMightyClass sharedInstance].tweakCount.centerXAnchor constraintEqualToAnchor : footerView.centerXAnchor].active = YES;
		[[AMightyClass sharedInstance].tweakCount.centerYAnchor constraintEqualToAnchor : footerView.centerYAnchor constant : 4].active = YES;

	}

}


void (*origTraitCollection)(UIView *self, SEL _cmd, UITraitCollection *);

void newTraitCollection(UIView *self, SEL _cmd, UITraitCollection *previousTraitCollection) {

	origTraitCollection(self, _cmd, previousTraitCollection);

	if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)

		[AMightyClass sharedInstance].tweakCount.textColor = UIColor.whiteColor;

	else

		[AMightyClass sharedInstance].tweakCount.textColor = UIColor.blackColor;

}


void(*origViewDidLoad)(TSRootListController *self, SEL _cmd);

void overrideViewDidLoad(TSRootListController *self, SEL _cmd) {

	origViewDidLoad(self, _cmd);

	if(!(isCurrentApp(@"com.creaturecoding.tweaksettings"))) return;

	self.title = [NSString stringWithFormat:@"%d", [AMightyClass sharedInstance].elixirTweakCount];

}


BOOL new_PSListController_areOrionOrShuffleInstalled(PSListController *self, SEL _cmd) {

	return (NSClassFromString(@"OrionTweakSpecifiersController") || NSClassFromString(@"TweakPreferencesListController"));

}


void (*origVDL)(PSListController *self, SEL _cmd);

void overrideVDL(PSListController *self, SEL _cmd) {

	origVDL(self, _cmd);

	if(new_PSListController_areOrionOrShuffleInstalled(self, _cmd)) return;

	if(![self isMemberOfClass:NSClassFromString(@"PSUIPrefsListController")]) return;

    PSSpecifier *emptySpecifier = [PSSpecifier emptyGroupSpecifier];

	NSString *elixirTweakCountLabel = [NSString stringWithFormat:@"%d Tweaks", [AMightyClass sharedInstance].elixirTweakCount];
	PSSpecifier *elixirSpecifier = [PSSpecifier preferenceSpecifierNamed:elixirTweakCountLabel target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
	[self insertContiguousSpecifiers:@[emptySpecifier, elixirSpecifier] afterSpecifier:[self specifierForID:@"APPLE_ACCOUNT"]];


}


__attribute__((constructor)) static void init() {

	MSHookMessageEx(NSClassFromString(@"UITableView"), @selector(didMoveToWindow), (IMP) &newDidMoveToWindow, (IMP*) &origDidMoveToWindow);
	MSHookMessageEx(NSClassFromString(@"UITableView"), @selector(traitCollectionDidChange:), (IMP) &newTraitCollection, (IMP*) &origTraitCollection);
	MSHookMessageEx(NSClassFromString(@"TSRootListController"), @selector(viewDidLoad), (IMP) &overrideViewDidLoad, (IMP*) &origViewDidLoad);
	MSHookMessageEx(NSClassFromString(@"PSListController"), @selector(viewDidLoad), (IMP) &overrideVDL, (IMP*) &origVDL);

	class_addMethod (
		
		NSClassFromString(@"PSListController"),
		@selector(areOrionOrShuffleInstalled),
		(IMP)&new_PSListController_areOrionOrShuffleInstalled,
		"B@:"

	);

}
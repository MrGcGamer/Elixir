@import UIKit;
#import <dlfcn.h>
#import <substrate.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>

#define isCurrentApp(string) [[[NSBundle mainBundle] bundleIdentifier] isEqual : string]

@interface UIView ()
- (id)_viewControllerForAncestor;
@end

@interface PSUIPrefsListController : PSListController
@end

@interface TSRootListController : UIViewController
@property (copy, nonatomic) NSString *title;
@end

@interface AMightyClass : UIView
@property (nonatomic, strong) UILabel *tweakCount;
@property (nonatomic, assign) NSUInteger elixirTweakCount;
@end


@implementation AMightyClass // fancy way to avoid code duplication, haha thanks Codine. But properties >> iVars


+ (instancetype)sharedInstance {

	static AMightyClass *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{

		sharedInstance = [AMightyClass new];

	});

	return sharedInstance;

}


- (instancetype)init {

	self = [super init];

	NSArray *prefsContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/PreferenceLoader/Preferences" error:nil];
	self.elixirTweakCount = [prefsContent count];

	[self setupElixirLabel];

	return self;

}


- (void)setupElixirLabel {

	self.tweakCount = [UILabel new];
	self.tweakCount.text = [NSString stringWithFormat:@"%lu", self.elixirTweakCount];
	self.tweakCount.font = [UIFont boldSystemFontOfSize:18];
	if (@available(iOS 13, *))
		self.tweakCount.textColor = [UIColor labelColor];
	else
		self.tweakCount.textColor = [UIColor blackColor];
	self.tweakCount.translatesAutoresizingMaskIntoConstraints = NO;

}


@end


void(*origDidMoveToWindow)(UITableView *self, SEL _cmd);

void newDidMoveToWindow(UITableView *self, SEL _cmd) {

	origDidMoveToWindow(self, _cmd);

	UIViewController *ancestor = [self _viewControllerForAncestor];

	if([ancestor isKindOfClass:objc_getClass("OrionTweakSpecifiersController")]) {

		[self addSubview:[AMightyClass sharedInstance].tweakCount];

		// Hi, if you've reached to this part, please, do yourself a favor if this is your case.
		// Stop doing cursed and weird af UIScreen calculations and math with frames for UI layout stuff,
		// learn and embrace constraints instead, they are natural and beautiful. Also known as AutoLayout, AUTO (It does the thing for you!!!)

		[[AMightyClass sharedInstance].tweakCount.topAnchor constraintEqualToAnchor : self.topAnchor constant : 8].active = YES;
		[[AMightyClass sharedInstance].tweakCount.centerXAnchor constraintEqualToAnchor : self.centerXAnchor].active = YES;

	}

	else if([ancestor isKindOfClass:objc_getClass("TweakPreferencesListController")]) { // Shuffle has a search bar so no space at the top :thishowitis:

		UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 10)];
		[footerView addSubview:[AMightyClass sharedInstance].tweakCount];

		self.tableFooterView = footerView;

		[[AMightyClass sharedInstance].tweakCount.centerXAnchor constraintEqualToAnchor : footerView.centerXAnchor].active = YES;
		[[AMightyClass sharedInstance].tweakCount.centerYAnchor constraintEqualToAnchor : footerView.centerYAnchor constant : 4].active = YES;

	}

}

void(*origViewDidLoad)(TSRootListController *self, SEL _cmd);

void overrideViewDidLoad(TSRootListController *self, SEL _cmd) {

	origViewDidLoad(self, _cmd);

	self.title = [NSString stringWithFormat:@"%lu", [AMightyClass sharedInstance].elixirTweakCount];

}

void (*origVDL)(PSUIPrefsListController *self, SEL _cmd);

void overrideVDL(PSUIPrefsListController *self, SEL _cmd) {

	origVDL(self, _cmd);

	PSSpecifier *emptySpecifier = [PSSpecifier emptyGroupSpecifier];

	NSString *elixirTweakCountLabel = [NSString stringWithFormat:@"%lu Tweaks", [AMightyClass sharedInstance].elixirTweakCount];
	PSSpecifier *elixirSpecifier = [PSSpecifier preferenceSpecifierNamed:elixirTweakCountLabel target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
	[elixirSpecifier setProperty:@YES forKey:@"enabled"];
	[self insertContiguousSpecifiers:@[emptySpecifier, elixirSpecifier] afterSpecifier:[self specifierForID:@"APPLE_ACCOUNT"]];

}


__attribute__((constructor)) static void init() {

	/* --- Not sure about the dylib name of Orion, as I don't own it --- */
	if (dlopen("/Library/MobileSubstrate/DynamicLibraries/Orion.dylib", RTLD_LAZY) != NULL || dlopen("/Library/MobileSubstrate/DynamicLibraries/shuffle.dylib", RTLD_LAZY) != NULL)
		MSHookMessageEx(objc_getClass("UITableView"), @selector(didMoveToWindow), (IMP) &newDidMoveToWindow, (IMP*) &origDidMoveToWindow);
	else
		MSHookMessageEx(objc_getClass("PSUIPrefsListController"), @selector(viewDidLoad), (IMP) &overrideVDL, (IMP*) &origVDL);
	MSHookMessageEx(objc_getClass("TSRootListController"), @selector(viewDidLoad), (IMP) &overrideViewDidLoad, (IMP*) &origViewDidLoad);

}
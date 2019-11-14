#include "SEListController.h"
#include "NSTask.h"

@implementation SEListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

-(void)paypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/noisyflake"] options:@{} completionHandler:nil];
}

-(void)_returnKeyPressed:(id)keyboard {
    [self.view endEditing:YES];

    [super _returnKeyPressed:keyboard];
}
@end

@implementation ShortcutEnablerLogo

- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Banner" specifier:specifier];
    if (self) {
        CGFloat width = 320;
        CGFloat height = 70;

        CGRect backgroundFrame = CGRectMake(-50, -35, width+50, height);
        background = [[UILabel alloc] initWithFrame:backgroundFrame];
        [background layoutIfNeeded];
        background.backgroundColor = [UIColor colorWithRed:1.00 green:0.58 blue:0.00 alpha:1.0];
        background.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self addSubview:background];


        CGRect tweakNameFrame = CGRectMake(0, -40, width, height);
        tweakName = [[UILabel alloc] initWithFrame:tweakNameFrame];
        [tweakName layoutIfNeeded];
        tweakName.numberOfLines = 1;
        tweakName.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0f];
        tweakName.textColor = [UIColor whiteColor];
        tweakName.text = @"ShortcutEnabler";
        tweakName.textAlignment = NSTextAlignmentCenter;
        [self addSubview:tweakName];

        NSPipe *pipe = [NSPipe pipe];

        NSTask *task = [[NSTask alloc] init];
        task.arguments = @[@"list", @"com.noisyflake.cozybadges"];
        task.launchPath = @"/usr/bin/apt";
        [task setStandardOutput: pipe];
        [task launch];
        [task waitUntilExit];

        NSFileHandle *file = [pipe fileHandleForReading];
        NSData *output = [file readDataToEndOfFile];
        NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
        [file closeFile];

        if ([outputString containsString:@"com.noisyflake"]) {
            NSArray *splitFirst = [outputString componentsSeparatedByString:@"com.noisyflake.cozybadges/now "];
            NSString *line = [splitFirst objectAtIndex:1];
            NSArray *splitSecond = [line componentsSeparatedByString:@" iphoneos"];
            NSString *versionString = [splitSecond objectAtIndex:0];

            CGRect versionFrame = CGRectMake(0, -5, width, height);
            version = [[UILabel alloc] initWithFrame:versionFrame];
            version.numberOfLines = 1;
            version.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            version.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
            version.textColor = [UIColor whiteColor];
            version.text = [NSString stringWithFormat:@"Version %@", versionString];
            version.backgroundColor = [UIColor clearColor];
            version.textAlignment = NSTextAlignmentCenter;
            [self addSubview:version];
        }

    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 100.0f;
}
@end

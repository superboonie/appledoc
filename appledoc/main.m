//
//  main.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "DDCliUtil.h"
#import "Settings+Appledoc.h"
#import "CommandLineArgumentsParser.h"
#import "Appledoc.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
		// Initialize the settings stack.
		Settings *factoryDefaults = [Settings appledocSettingsWithName:@"Factory" parent:nil];
		Settings *globalSettings = [Settings appledocSettingsWithName:@"Global" parent:factoryDefaults];
		Settings *projectSettings = [Settings appledocSettingsWithName:@"Project" parent:globalSettings];
		Settings *settings = [Settings appledocSettingsWithName:@"CmdLine" parent:projectSettings];

		// Initialize command line parser and parse settings.
		CommandLineArgumentsParser *parser = [[CommandLineArgumentsParser alloc] init];
		[settings registerOptionsToCommandLineParser:parser];
		__block BOOL commandLineValid = YES;
		[parser parseOptionsWithArguments:argv count:argc block:^(NSString *argument, id value, BOOL *stop) {
			if (value == GBCommandLineArgumentResults.unknownArgument) {
				ddprintf(@"Unknown command line argument %@!\n", argument);
				commandLineValid = NO;
			} else if (value == GBCommandLineArgumentResults.missingValue) {
				ddprintf(@"Missing value for command line argument %@!\n", argument);
				commandLineValid = NO;
			} else {
				[settings setObject:value forKey:argument];
			}
		}];
		if (!commandLineValid) return 1;
		
		// Prepare command line settings with additional data.
		settings.inputPaths = parser.arguments;
		
		// Apply factory defaults, global and project settings.
		[factoryDefaults applyFactoryDefaults];
		[globalSettings applyGlobalSettingsFromCmdLineSettings:settings];
		[projectSettings applyProjectSettingsFromCmdLineSettings:settings];

		// Initialize and run the application.
		Appledoc *appledoc = [[Appledoc alloc] init];
		appledoc.settings = settings;
	}
    return 0;
}
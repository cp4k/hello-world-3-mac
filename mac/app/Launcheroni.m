//
//  main.m
//  HelloWorld3
//
//  Created by Carter Sande on 8/18/19.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return true;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)openIdle:(id)sender {
    NSURL *url = [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"IDLE.app"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)openDesigner:(id)sender {
    NSURL *url = [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"Designer.app"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)openTerminal:(id)sender {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"setup_environment"
                                         withExtension:@"sh"];
    [[NSWorkspace sharedWorkspace] openURLs:@[url]
                    withAppBundleIdentifier:@"com.apple.Terminal"
                                    options:NSWorkspaceLaunchDefault
             additionalEventParamDescriptor:NULL
                          launchIdentifiers:NULL];
}

@end


int main(int argc, const char * argv[]) {
    return NSApplicationMain(argc, argv);
}

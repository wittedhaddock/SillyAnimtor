//
//  SAAppDelegate.m
//  SillyAnimator
//
//  Created by James William Graham on 5/18/14.
//  Copyright (c) 2014 Just a Door. All rights reserved.
//

#import "SAAppDelegate.h"

@interface SAAppDelegate()
@property (strong, nonatomic) NSMutableArray *images;
@property (weak) IBOutlet NSTextField *renameBaseTextField;
@end
@implementation SAAppDelegate

- (NSMutableArray *)images{
    if (!_images) {
        _images = [[NSMutableArray alloc] init];
    }
    return _images;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}
- (IBAction)openFileChooserUI:(NSButton *)sender {
    NSArray *allowedFileTypes = [NSArray arrayWithObjects:@"jpg", @"png", nil];
    
    NSOpenPanel *fileSelector = [NSOpenPanel openPanel];
    [fileSelector setAllowedFileTypes:allowedFileTypes];
    [fileSelector setAllowsMultipleSelection:YES];
    if([fileSelector runModal] == NSOKButton){
        NSArray *fileURLs = [fileSelector URLs];
    
        [self setRenameBaseValueWithFileURL:fileURLs[0]];
        
        for (NSURL *imageURL in fileURLs) {
            NSLog(@"%@", [[imageURL path]lastPathComponent]);
            NSImage *image = [[NSImage alloc] initByReferencingURL:imageURL];
            
            [self.images addObject:image];
        }
    }
}
- (void)setRenameBaseValueWithFileURL:(NSURL *)fileURL{
    NSString *withEnding = [fileURL lastPathComponent] ;
    
    NSString *base2 = [withEnding componentsSeparatedByString:@"0"][0];
    
    
    [self.renameBaseTextField setStringValue:base2];
}
- (IBAction)saveAs:(id)sender {
    NSString *renameBase = [[self.renameBaseTextField stringValue] copy];
    
    NSOpenPanel *destinationDirectory = [NSOpenPanel openPanel];
    [destinationDirectory setCanChooseDirectories:YES];
    [destinationDirectory setCanChooseFiles:NO];
    [destinationDirectory setCanCreateDirectories:YES];
    
    if ([destinationDirectory runModal] == NSOKButton) {
        for (int i = 0; i < [self.images count]; i++) {
            NSString *renameBaseWithIncrementalInteger = [NSString stringWithFormat:@"%@%i%@", renameBase, i, @".png"];
            
            NSURL *constructedURL = [NSURL URLWithString:renameBaseWithIncrementalInteger relativeToURL:[destinationDirectory directoryURL]];
            NSLog(@"%@", constructedURL);
            [self saveImageAsPNG:self.images[i] withName:nil atURL:constructedURL];
        }
    }
    
}

- (void)saveImageAsPNG:(NSImage *)imagePNG withName:(NSString *)imageName atURL:(NSURL *)URL{
    NSData *imageData = [imagePNG TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProperties = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0f] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProperties];
    [imageData writeToURL:URL atomically:YES];
    
}

@end

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
@property (strong, nonatomic) NSMutableArray *croppedImages;
@property (weak) IBOutlet NSTextField *renameBaseTextField;
@end
@implementation SAAppDelegate

- (NSMutableArray *)images{
    if (!_images) {
        _images = [[NSMutableArray alloc] init];
    }
    return _images;
}
- (NSMutableArray *)croppedImages{
    if (!_croppedImages) {
        _croppedImages = [[NSMutableArray alloc] init];
    }
    return _croppedImages;
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
            if ([self.croppedImages count] > 0) {
                [self saveImageAsPNG:self.croppedImages[i] withName:nil atURL:constructedURL];
            }
            else {
                [self saveImageAsPNG:self.images[i] withName:nil atURL:constructedURL];

            }
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
- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage {
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t width = CGImageGetWidth(inImage);
    size_t height = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (width * 4);
    bitmapByteCount = (bitmapBytesPerRow * height);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) return NULL;
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     width,
                                     height,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL) free (bitmapData);
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease(colorSpace);
    
    return context;
}
- (CGImageRef)imageRefForNSImage:(NSImage *)image{
    return [image CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil];
}
- (CGRect)cropRectForImage:(NSImage *)image {
    
    CGImageRef cgImage = [self imageRefForNSImage:image];
    CGContextRef context = [self createARGBBitmapContextFromImage:cgImage];
    if (context == NULL) return CGRectZero;
    
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextDrawImage(context, rect, cgImage);
    
    unsigned char *data = CGBitmapContextGetData(context);
    CGContextRelease(context);
    
    //Filter through data and look for non-transparent pixels.
    int lowX = width;
    int lowY = height;
    int highX = 0;
    int highY = 0;
    if (data != NULL) {
        for (int y=0; y<height; y++) {
            for (int x=0; x<width; x++) {
                int pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */;
                if (data[pixelIndex] != 0) { //Alpha value is not zero; pixel is not transparent.
                    if (x < lowX) lowX = x;
                    if (x > highX) highX = x;
                    if (y < lowY) lowY = y;
                    if (y > highY) highY = y;
                }
            }
        }
        free(data);
    } else {
        return CGRectZero;
    }
    
    return CGRectMake(lowX, lowY, highX-lowX, highY-lowY);
}
- (IBAction)crop:(id)sender {
        for (int i = 0; i < [self.images count]; i++) {
            CGRect minimumImageRect = [self cropRectForImage:self.images[i]];
            CGImageRef croppedImageRef = CGImageCreateWithImageInRect([self imageRefForNSImage:self.images[i]], minimumImageRect);
            NSImage *croppedImage = [[NSImage alloc] initWithCGImage:croppedImageRef size:NSZeroSize];
            [self.croppedImages addObject:croppedImage];
            
    
    }
}

@end

#import "UIImage+Resize.h"

@import UIKit;

@implementation UIImage (Resize)

- (UIImage *)imageRetainingAspectRatioWithSize:(CGSize)size {
    return [self imageWithSize:[self sizeRetainingAspectRatioForSize:size]];
}

- (UIImage *)imageWithSize:(CGSize)size
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (CGSize)sizeRetainingAspectRatioForSize:(CGSize)size {
    CGFloat oldWidth = self.size.width;
    CGFloat oldHeight = self.size.height;

    CGFloat scaleFactor = (oldWidth > oldHeight) ? size.width / oldWidth : size.height / oldHeight;

    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    
    return CGSizeMake(newWidth, newHeight);
}

@end

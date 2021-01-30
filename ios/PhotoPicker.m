#import "PhotoPicker.h"
#import "UIImage+Resize.h"
#import <React/RCTConvert.h>

@import UIKit;
@import PhotosUI;

@implementation PhotoPicker

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(pickPhoto:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback)
{
    NSNumber * maxWidth = [options objectForKey:@"maxWidth"];
    NSNumber * maxHeight = [options objectForKey:@"maxHeight"];

    if (@available(iOS 14, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            PHPickerConfiguration * configuration = [[PHPickerConfiguration alloc] initWithPhotoLibrary:[PHPhotoLibrary sharedPhotoLibrary]];
            configuration.filter = [PHPickerFilter imagesFilter];
            configuration.selectionLimit = 1;

            self.delegate = [[PhotoPickerDelegate alloc] initWithCallback:callback
                                                                 maxWidth:maxWidth
                                                                maxHeight:maxHeight];

            PHPickerViewController * picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
            picker.delegate = self.delegate;
            picker.modalPresentationStyle = UIModalPresentationFullScreen;

            id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;

            [appDelegate.window.rootViewController presentViewController:picker
                                                                animated:YES
                                                              completion:nil];
        });
    } else {
        callback(@[@"Requires iOS 14", [NSNull null]]);
        return;
    }
}

@end

#pragma mark - Photo picker delegate

@implementation PhotoPickerDelegate

- (nullable instancetype)initWithCallback:(nonnull RCTResponseSenderBlock)callback
                                 maxWidth:(nullable NSNumber *)maxWidth
                                maxHeight:(nullable NSNumber *)maxHeight;
{
    self = [super init];

    if (self) {
        _callback = callback;
        _maxWidth = maxWidth;
        _maxHeight = maxHeight;
    }

    return self;
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14))
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    if (results.count == 0) {
        // The user canceled choosing a photo
        self.callback(@[[NSNull null], [NSNull null]]);
        return;
    }

    // The user can only pick one photo
    PHPickerResult * result = results.firstObject;

    [result.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading> object, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.callback(@[error, [NSNull null]]);
                return;
            }

            // Ensure the asset is a UIImage

            if (![object isKindOfClass:[UIImage class]]) {
                self.callback(@[@"Invalid image type", [NSNull null]]);
                return;
            }

            UIImage * image = (UIImage *) object;

            // Resize the image if needed

            if (self.maxWidth != nil || self.maxHeight != nil) {
                CGSize size = CGSizeMake(self.maxWidth.doubleValue, self.maxHeight.doubleValue);

                image = [image imageRetainingAspectRatioWithSize:size];
            }

            // Save the image to a file so it is accessible via URL

            NSData * imageData = UIImageJPEGRepresentation(image, 1.0);

            NSString * documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            NSURL * imageURL = [NSURL fileURLWithPath:[[documentsDirectory stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"jpg"]];

            NSError * writeError;
            [imageData writeToURL:imageURL options:NSDataWritingAtomic error:&writeError];
            if (writeError) {
                self.callback(@[error, [NSNull null]]);
                return;
            }

            self.callback(@[[NSNull null], imageURL.absoluteString]);
        });
    }];
}

@end

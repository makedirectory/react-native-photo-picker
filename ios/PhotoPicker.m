#import "PhotoPicker.h"
#import <React/RCTConvert.h>

@import UIKit;
@import PhotosUI;

@implementation PhotoPicker

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(choosePhotoWithOptions:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback)
{
    if (@available(iOS 14, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            PHPickerConfiguration * configuration = [[PHPickerConfiguration alloc] initWithPhotoLibrary:[PHPhotoLibrary sharedPhotoLibrary]];
            configuration.filter = [PHPickerFilter imagesFilter];
            configuration.selectionLimit = 1;

            self.delegate = [[PhotoPickerDelegate alloc] initWithCallback:callback];

            PHPickerViewController * picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
            picker.delegate = self.delegate;
            picker.modalPresentationStyle = UIModalPresentationFullScreen;

            id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate.window.rootViewController presentViewController:picker animated:YES completion:nil];
        });
    } else {
        callback(@[@"Requires iOS 14", [NSNull null]]);
        return;
    }
}

@end

#pragma mark - Photo picker delegate

@implementation PhotoPickerDelegate

- (instancetype)initWithCallback:(RCTResponseSenderBlock)callback
{
    self = [super init];

    if (self) {
        _callback = callback;
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

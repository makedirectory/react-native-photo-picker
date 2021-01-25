#import <React/RCTBridgeModule.h>

@import PhotosUI;

@interface PhotoPickerDelegate : NSObject <PHPickerViewControllerDelegate>

@property RCTResponseSenderBlock _Nonnull callback;

- (nullable instancetype)initWithCallback:(nonnull RCTResponseSenderBlock)callback;

@end

@interface PhotoPicker : NSObject <RCTBridgeModule>

@property PhotoPickerDelegate * _Nullable delegate;

- (void)choosePhotoWithOptions:(nonnull NSDictionary *)options callback:(nonnull RCTResponseSenderBlock)callback;

@end

#import <React/RCTBridgeModule.h>

@import PhotosUI;

@interface PhotoPickerDelegate : NSObject <PHPickerViewControllerDelegate>

@property RCTResponseSenderBlock _Nonnull callback;

- (nullable instancetype)initWithCallback:(nonnull RCTResponseSenderBlock)callback;

@end

@interface PhotoPicker : NSObject <RCTBridgeModule>

@property PhotoPickerDelegate * _Nullable delegate;

- (void)pickPhoto:(nonnull RCTResponseSenderBlock)callback;

@end

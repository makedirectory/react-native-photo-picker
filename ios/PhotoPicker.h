#import <React/RCTBridgeModule.h>

@import PhotosUI;

@interface PhotoPickerDelegate : NSObject <PHPickerViewControllerDelegate>

@property RCTResponseSenderBlock _Nonnull callback;
@property NSNumber * _Nullable maxWidth;
@property NSNumber * _Nullable maxHeight;

- (nullable instancetype)initWithCallback:(nonnull RCTResponseSenderBlock)callback
                                 maxWidth:(nullable NSNumber *)maxWidth
                                maxHeight:(nullable NSNumber *)maxHeight;

@end

@interface PhotoPicker : NSObject <RCTBridgeModule>

@property PhotoPickerDelegate * _Nullable delegate;

- (void)pickPhoto:(nonnull NSDictionary *)options callback:(nonnull RCTResponseSenderBlock)callback;

@end

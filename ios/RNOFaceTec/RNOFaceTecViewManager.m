#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(RNOFaceTecViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(mode, NSString)
RCT_EXPORT_VIEW_PROPERTY(customization, NSString)
RCT_EXPORT_VIEW_PROPERTY(vocalGuidanceMode, NSString)
RCT_EXPORT_VIEW_PROPERTY(deviceKeyIdentifier, NSString)
RCT_EXPORT_VIEW_PROPERTY(productionKeyText, NSString)
RCT_EXPORT_VIEW_PROPERTY(faceScanEncryptionKey, NSString)

RCT_EXPORT_VIEW_PROPERTY(onUpdate, RCTBubblingEventBlock)

@end

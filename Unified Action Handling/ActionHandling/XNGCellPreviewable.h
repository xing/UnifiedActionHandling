@import Foundation;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CellPreviewable)
@protocol XNGCellPreviewable <NSObject>

@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, id> *previewAction NS_REFINED_FOR_SWIFT;

@end

NS_SWIFT_NAME(MutableCellPreviewable)
@protocol XNGMutableCellPreviewable <XNGCellPreviewable>

@property (nonatomic, copy, nullable, readwrite) NSDictionary<NSString *, id> *previewAction NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END

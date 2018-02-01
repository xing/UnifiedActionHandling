@import Foundation;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CellSelectable)
@protocol XNGCellSelectable <NSObject>

@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, id> *selectionAction NS_REFINED_FOR_SWIFT;

@end

NS_SWIFT_NAME(MutableCellSelectable)
@protocol XNGMutableCellSelectable <XNGCellSelectable>

@property (nonatomic, copy, nullable, readwrite) NSDictionary<NSString *, id> *selectionAction NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END

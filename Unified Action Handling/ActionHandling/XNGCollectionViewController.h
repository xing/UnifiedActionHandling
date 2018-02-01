@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface XNGCollectionViewController : UICollectionViewController

// This method is implemented to allow highlighting of cells that conform to XNGCellSelectable.
// Cells that conform to XNGCellSelectable will be selectable if and only if they hava a non-nil selectionAction.
- (BOOL)            collectionView:(UICollectionView *)collectionView
    shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;

// This method is implemented to allow selection of cells that conform to XNGCellSelectable.
// Cells that conform to XNGCellSelectable will be selectable if and only if they hava a non-nil selectionAction.
- (BOOL)         collectionView:(UICollectionView *)collectionView
    shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;

// This method is implemented to dispatch actions for cells that conform to XNGCellSelectable.
// Cells that conform to XNGCellSelectable will be selectable if and only if they hava a non-nil selectionAction.
- (void)         collectionView:(UICollectionView *)collectionView
       didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

@import SafariServices;
#import "XNGCollectionViewController.h"
#import "XNGCellSelectable.h"
#import "XNGCellPreviewable.h"
#import "XNGActionKey.h"
#import "UnifiedActionHandling-Swift.h"

// Responsibility: Carries a viewController in a settable property.
// Used to get/set a view controller from an action handler.
@interface XNGViewControllerPropertyImpl : NSObject <XNGViewControllerProperty>
@property (nonatomic, nullable) UIViewController *viewController;
@end

@implementation XNGViewControllerPropertyImpl
@end

@interface XNGCollectionViewController () <UIViewControllerPreviewingDelegate>

@property (nonatomic, copy) NSDictionary<NSString *, id> *latestPreviewAction;

@end

@implementation XNGCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
    }
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self xng_collectionView:collectionView shouldSelectOrHighlightItemAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self xng_collectionView:collectionView shouldSelectOrHighlightItemAtIndexPath:indexPath];
}

- (BOOL)xng_collectionView:(UICollectionView *)collectionView shouldSelectOrHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (![cell conformsToProtocol:@protocol(XNGCellSelectable)]) {
        return NO;
    }

    return ((id<XNGCellSelectable>)cell).selectionAction != nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (![cell conformsToProtocol:@protocol(XNGCellSelectable)]) {
        return;
    }
    [cell xng_dispatchAction:((id < XNGCellSelectable >)cell).selectionAction];
}

#pragma mark - UIViewControllerPreviewingDelegate

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (indexPath == nil) {
        return nil;
    }

    UICollectionViewCell <XNGCellPreviewable> *cell = (UICollectionViewCell <XNGCellPreviewable> *)[self.collectionView cellForItemAtIndexPath: indexPath];
    if (![cell conformsToProtocol:@protocol(XNGCellPreviewable)]) {
        return nil;
    }

    NSDictionary<NSString *, id> *previewAction = cell.previewAction;
    if (previewAction == nil) {
        return nil;
    }

    self.latestPreviewAction = previewAction;
    XNGViewControllerPropertyImpl *viewControllerProperty = [[XNGViewControllerPropertyImpl alloc] init];

    NSMutableDictionary<NSString *, id> *mutablePreviewAction = [previewAction mutableCopy];
    mutablePreviewAction[XNGActionKeyViewControllerProperty] = viewControllerProperty;

    previewingContext.sourceRect = [self.collectionView convertRect:cell.bounds fromView:cell];

    [self xng_dispatchAction:mutablePreviewAction sourceView:previewingContext.sourceView sourceRect:previewingContext.sourceRect];

    return viewControllerProperty.viewController;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    NSMutableDictionary<NSString *, id> *mutablePreviewAction = [self.latestPreviewAction mutableCopy];
    if (mutablePreviewAction == nil) {
        return;
    }

    XNGViewControllerPropertyImpl *viewControllerProperty = [[XNGViewControllerPropertyImpl alloc] init];
    viewControllerProperty.viewController = viewControllerToCommit;
    mutablePreviewAction[XNGActionKeyViewControllerProperty] = viewControllerProperty;

    [self xng_dispatchAction:mutablePreviewAction sourceView:previewingContext.sourceView sourceRect:previewingContext.sourceRect];

    UIViewController *viewController = viewControllerProperty.viewController;
    if (viewController != nil) {
        if ([viewController isKindOfClass:[SFSafariViewController class]]) {
            [self presentViewController:viewController animated:YES completion:nil];
        } else {
            [self showViewController:viewController sender:self];
        }
    }
}

@end

import UIKit

@objc(XNGViewControllerProperty)
public protocol ViewControllerProperty {
    var viewController: UIViewController? { get set }
}

public extension CellPreviewable {
    /// A previewAction is used to add preview support for cells (3D Touch Peek and Pop).
    ///
    /// When dispatched, the action will contain an object conforming to ViewControllerProperty
    /// under the key "viewControllerProperty". viewController on that object will be nil for the
    /// "Peek" case, and the previewing controller for the "Pop" case.
    ///
    /// To implement the "Peek" action, set viewControllerProperty.viewController to
    /// your preview controller. Don't forget to set the preferredContentSize, and to return
    /// preview action items from your view controller's previewActionItems property.
    ///
    /// To implement the "Pop" action, either do nothing (then the previewing view controller from
    /// the "Peek" case will be reused, or set viewControllerProperty.viewController to another
    /// view controller. The view controller will be automatically shown via show(_:sender:).
    public var previewAction: Action? {
        return __previewAction.map { Action($0) }
    }
}

public extension MutableCellPreviewable {
    public var previewAction: Action? {
        get {
            return __previewAction.map { Action($0) }
        }
        set {
            __previewAction = newValue?.values
        }
    }
}

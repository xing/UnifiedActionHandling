import UIKit

class CollectionViewCell: UICollectionViewCell, MutableCellSelectable, MutableCellPreviewable {

    var __previewAction: [String: Any]?
    var __selectionAction: [String: Any]?

    var color: UIColor = .white {
        didSet {
            backgroundColor = color
            previewAction = [.type: "previewColor", .color: color]
            selectionAction = [.type: "showColor", .color: color]
        }
    }
}

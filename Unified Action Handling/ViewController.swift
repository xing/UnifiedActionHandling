import UIKit

public class ViewController: XNGCollectionViewController {

    private let kNumberOfCells = 20

    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kNumberOfCells
    }

    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)

        if let cell = cell as? CollectionViewCell {
            let color = UIColor(hue: CGFloat(indexPath.item) / CGFloat(kNumberOfCells), saturation: 0.5, brightness: 1.0, alpha: 1.0)
            cell.color = color
        }

        return cell
    }
}

import UIKit

extension UIViewController {
    /// Shows a simple alert with one OK button (used for validation messages).
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension UIImage {
    /// Returns a smaller copy whose longest side is at most maxDimension pixels.
    /// Photos from the iPhone camera are huge; shrinking them keeps the database small.
    func resized(maxDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else { return self }
        let scale = maxDimension / longestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1 // 1 point = 1 pixel, so the pixel size is exactly newSize
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

/// A friendly empty state shared by lists and grids.
func emptyStateLabel(_ message: String) -> UIView {
    let imageView = UIImageView(image: UIImage(systemName: "sparkles.rectangle.stack"))
    imageView.tintColor = AppAppearance.teal
    imageView.contentMode = .scaleAspectFit
    imageView.heightAnchor.constraint(equalToConstant: 44).isActive = true

    let label = UILabel()
    label.text = message
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = .secondaryLabel
    label.font = .preferredFont(forTextStyle: .body)

    let stack = UIStackView(arrangedSubviews: [imageView, label])
    stack.axis = .vertical
    stack.spacing = 12
    stack.layoutMargins = UIEdgeInsets(top: 0, left: 36, bottom: 0, right: 36)
    stack.isLayoutMarginsRelativeArrangement = true
    return stack
}

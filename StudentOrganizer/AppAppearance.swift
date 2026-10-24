import UIKit

/// Centralizes the app's visual identity without changing its persistence or navigation logic.
enum AppAppearance {
    static let navy = UIColor(red: 0.08, green: 0.13, blue: 0.23, alpha: 1)
    static let teal = UIColor(red: 0.10, green: 0.58, blue: 0.55, alpha: 1)
    static let coral = UIColor(red: 0.96, green: 0.42, blue: 0.36, alpha: 1)
    static let paper = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.08, green: 0.10, blue: 0.14, alpha: 1)
            : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
    }
    static let card = UIColor { traits in
        traits.userInterfaceStyle == .dark ? .secondarySystemBackground : .white
    }

    static func configure() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = navy
        navigationAppearance.shadowColor = navy
        navigationAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]

        let navigationBar = UINavigationBar.appearance()
        navigationBar.standardAppearance = navigationAppearance
        navigationBar.scrollEdgeAppearance = navigationAppearance
        navigationBar.compactAppearance = navigationAppearance
        navigationBar.tintColor = .white

        UIBarButtonItem.appearance().tintColor = .white
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = teal
        UIButton.appearance().tintColor = teal
        UISwitch.appearance().onTintColor = teal

        let segmentedControl = UISegmentedControl.appearance()
        segmentedControl.selectedSegmentTintColor = teal
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: navy], for: .normal)
    }

    static func makeHeader(eyebrow: String, title: String, subtitle: String) -> UIView {
        let eyebrowLabel = UILabel()
        eyebrowLabel.text = eyebrow.uppercased()
        eyebrowLabel.font = .systemFont(ofSize: 12, weight: .bold)
        eyebrowLabel.textColor = teal

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [eyebrowLabel, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 5
        stack.layoutMargins = UIEdgeInsets(top: 18, left: 20, bottom: 14, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }
}

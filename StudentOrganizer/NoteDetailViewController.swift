import UIKit
import CoreData

class NoteDetailViewController: UIViewController {
    // MARK: - Data passed in from NotesViewController
    var note: Note?

    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Note"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = AppAppearance.paper
        photoImageView.backgroundColor = AppAppearance.teal.withAlphaComponent(0.10)
        photoImageView.layer.cornerRadius = 18
        photoImageView.clipsToBounds = true
        dateLabel.textColor = AppAppearance.teal
        noteLabel.font = .preferredFont(forTextStyle: .title3)

        var deleteConfiguration = UIButton.Configuration.filled()
        deleteConfiguration.title = "Delete Note"
        deleteConfiguration.baseBackgroundColor = .systemRed
        deleteConfiguration.baseForegroundColor = .white
        deleteConfiguration.cornerStyle = .medium
        deleteConfiguration.image = UIImage(systemName: "trash")
        deleteConfiguration.imagePadding = 8
        deleteButton.configuration = deleteConfiguration
        deleteButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        guard let note = note else { return }
        noteLabel.text = note.text
        dateLabel.text = note.createdAt?.formatted(date: .long, time: .shortened)
        if let data = note.photoData, let image = UIImage(data: data) {
            photoImageView.image = image
            photoImageView.contentMode = .scaleAspectFit
        } else {
            photoImageView.image = UIImage(systemName: "text.alignleft")
            photoImageView.contentMode = .center
            photoImageView.tintColor = AppAppearance.teal
        }
    }

    // MARK: - Actions
    @IBAction func deleteTapped(_ sender: UIButton) {
        // Ask first: deleting cannot be undone.
        let alert = UIAlertController(title: "Delete this note?",
                                      message: "This cannot be undone.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            [weak self] _ in
            guard let self = self, let note = self.note else { return }
            CoreDataStack.shared.context.delete(note)
            CoreDataStack.shared.save()
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
}

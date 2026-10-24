import UIKit
import CoreData

class NotesViewController: UIViewController,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    var subject: Subject?
    private var notes: [Note] = []
    private let context = CoreDataStack.shared.context
    private let columns: CGFloat = 2 // number of cells per row
    private let spacing: CGFloat = 12 // gap between cells and around the grid

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = AppAppearance.paper
        collectionView.backgroundColor = AppAppearance.paper
        collectionView.dataSource = self
        collectionView.delegate = self

        let headerHeight: CGFloat = 150
        collectionView.contentInset.top = headerHeight
        collectionView.verticalScrollIndicatorInsets.top = headerHeight

        let header = AppAppearance.makeHeader(
            eyebrow: subject?.name ?? "Subject",
            title: "Notes",
            subtitle: "Save whiteboards, reminders, and quick study thoughts."
        )
        header.frame = CGRect(
            x: 0,
            y: -headerHeight,
            width: collectionView.bounds.width,
            height: headerHeight
        )
        header.autoresizingMask = [.flexibleWidth]
        collectionView.addSubview(header)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotes()
    }

    // MARK: - Core Data
    private func loadNotes() {
        guard let subject = subject else { return }
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "subject == %@", subject)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            notes = try context.fetch(request)
        } catch {
            print("Could not fetch notes: \(error)")
            notes = []
        }
        collectionView.backgroundView = notes.isEmpty
            ? makeNotesEmptyState() : nil
        collectionView.reloadData()
    }

    private func makeNotesEmptyState() -> UIView {
        let container = UIView()
        let content = emptyStateLabel("No notes yet.\nTap + to add one.")
        container.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            content.centerYAnchor.constraint(
                equalTo: container.centerYAnchor,
                constant: 55
            ),
            content.leadingAnchor.constraint(
                greaterThanOrEqualTo: container.leadingAnchor,
                constant: 24
            ),
            container.trailingAnchor.constraint(
                greaterThanOrEqualTo: content.trailingAnchor,
                constant: 24
            )
        ])
        return container
    }

    // MARK: - Actions
    @IBAction func addNoteTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ShowNoteFormSegue", sender: nil)
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return notes.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NoteCell", for: indexPath) as? NoteCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: notes[indexPath.item])
        return cell
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        performSegue(withIdentifier: "ShowNoteDetailSegue",
                     sender: notes[indexPath.item])
    }

    // MARK: - UICollectionViewDelegateFlowLayout (grid size and spacing)
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // Total width minus all gaps, divided equally between the columns.
        let totalSpacing = spacing * (columns + 1)
        let width = floor((collectionView.bounds.width - totalSpacing) / columns)
        return CGSize(width: width, height: width + 40) // square photo + label area
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing,
                            bottom: spacing, right: spacing)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return spacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return spacing
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowNoteFormSegue":
            guard let destination = segue.destination as? NoteFormViewController
            else { return }
            destination.subject = subject
        case "ShowNoteDetailSegue":
            guard let destination = segue.destination as? NoteDetailViewController,
                  let note = sender as? Note else { return }
            destination.note = note
        default:
            break
        }
    }
}

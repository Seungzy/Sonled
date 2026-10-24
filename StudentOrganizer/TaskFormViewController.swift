import UIKit
import CoreData

class TaskFormViewController: UIViewController {
    // MARK: - Data passed in from TasksViewController
    var subject: Subject?
    var taskToEdit: TaskItem? // nil = adding a new task, not nil = editing

    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet weak var completedSwitch: UISwitch!

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let task = taskToEdit {
            // Edit mode: fill the controls with the saved values.
            title = "Edit Task"
            titleTextField.text = task.title
            detailsTextView.text = task.details
            dueDatePicker.date = task.dueDate ?? Date()
            prioritySegmentedControl.selectedSegmentIndex = Int(task.priority)
            completedSwitch.isOn = task.isDone
        } else {
            title = "New Task"
            dueDatePicker.date = Date()
        }

        applyDesign()

        // Tap anywhere on the background to hide the keyboard.
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false // do not block taps on the other controls
        view.addGestureRecognizer(tap)
    }

    private func applyDesign() {
        view.backgroundColor = AppAppearance.paper
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        // Emphasize the form's section headings without bolding user-entered text.
        styleSectionLabels(in: view)

        titleTextField.borderStyle = .none
        titleTextField.backgroundColor = AppAppearance.card
        titleTextField.layer.cornerRadius = 12
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = AppAppearance.teal
            .withAlphaComponent(0.18).cgColor
        titleTextField.font = .preferredFont(forTextStyle: .body)
        titleTextField.adjustsFontForContentSizeCategory = true
        titleTextField.clearButtonMode = .whileEditing
        titleTextField.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let leftPadding = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: 1)
        )
        titleTextField.leftView = leftPadding
        titleTextField.leftViewMode = .always

        let rightPadding = UIView(
            frame: CGRect(x: 0, y: 0, width: 12, height: 1)
        )
        titleTextField.rightView = rightPadding
        titleTextField.rightViewMode = .unlessEditing

        detailsTextView.backgroundColor = AppAppearance.card
        detailsTextView.layer.cornerRadius = 12
        detailsTextView.font = .preferredFont(forTextStyle: .body)
        detailsTextView.textContainerInset = UIEdgeInsets(
            top: 12, left: 10, bottom: 12, right: 10
        )

        // Keep the compact date and time controls on the left side of the form.
        if let formStack = dueDatePicker.superview as? UIStackView,
           let index = formStack.arrangedSubviews.firstIndex(of: dueDatePicker) {
            formStack.removeArrangedSubview(dueDatePicker)
            dueDatePicker.removeFromSuperview()
            dueDatePicker.setContentHuggingPriority(.required, for: .horizontal)
            // Compact date-and-time pickers otherwise fill the stack and push
            // their visible controls to the trailing edge.
            dueDatePicker.widthAnchor.constraint(equalToConstant: 230).isActive = true

            let dateRow = UIStackView(arrangedSubviews: [dueDatePicker, UIView()])
            dateRow.axis = .horizontal
            dateRow.alignment = .center
            formStack.insertArrangedSubview(dateRow, at: index)
        }

        if let completedRow = completedSwitch.superview as? UIStackView {
            completedRow.backgroundColor = AppAppearance.card
            completedRow.layer.cornerRadius = 12
            completedRow.layoutMargins = UIEdgeInsets(
                top: 10, left: 14, bottom: 10, right: 14
            )
            completedRow.isLayoutMarginsRelativeArrangement = true
        }
    }

    private func styleSectionLabels(in parentView: UIView) {
        let sectionTitles = [
            "Title", "Details (optional)", "Due Date", "Priority", "Completed"
        ]

        for subview in parentView.subviews {
            if let label = subview as? UILabel,
               let text = label.text,
               sectionTitles.contains(text) {
                let font = UIFont.systemFont(ofSize: 17, weight: .bold)
                label.font = UIFontMetrics(forTextStyle: .headline)
                    .scaledFont(for: font)
                label.adjustsFontForContentSizeCategory = true
            }
            styleSectionLabels(in: subview)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Actions
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        // Read the text field safely: it is optional, so never force-unwrap it.
        let taskTitle = (titleTextField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !taskTitle.isEmpty else {
            showAlert(title: "Title required",
                      message: "Please type a title for your task.")
            return
        }

        // Reuse the task being edited, or create a brand-new one.
        let task = taskToEdit ?? TaskItem(context: CoreDataStack.shared.context)
        task.title = taskTitle
        let details = detailsTextView.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
        task.details = details.isEmpty ? nil : details
        task.dueDate = dueDatePicker.date
        task.priority = Int16(prioritySegmentedControl.selectedSegmentIndex)
        task.isDone = completedSwitch.isOn
        if taskToEdit == nil {
            task.subject = subject // link the new task to its subject
        }
        CoreDataStack.shared.save()
        navigationController?.popViewController(animated: true)
    }
}

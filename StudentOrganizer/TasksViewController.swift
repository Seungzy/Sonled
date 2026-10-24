import UIKit
import CoreData

class TasksViewController: UITableViewController {
    // MARK: - Properties
    /// Set by SubjectsViewController in prepare(for:sender:).
    var subject: Subject?
    private var tasks: [TaskItem] = []
    private let context = CoreDataStack.shared.context

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = subject?.name
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        tableView.backgroundColor = AppAppearance.paper
        tableView.separatorStyle = .none
        tableView.register(OrganizerTableCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.tableHeaderView = AppAppearance.makeHeader(
            eyebrow: "Tasks",
            title: subject?.name ?? "Tasks",
            subtitle: "Swipe right to finish a task, or left to remove it."
        )
        tableView.tableHeaderView?.frame.size.height = 145
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasks() // refresh after returning from the Task Form
    }

    // MARK: - Core Data
    private func loadTasks() {
        guard let subject = subject else { return }
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        // Only the tasks that belong to THIS subject.
        request.predicate = NSPredicate(format: "subject == %@", subject)
        // Unfinished tasks first, then the earliest due date first.
        request.sortDescriptors = [
            NSSortDescriptor(key: "isDone", ascending: true),
            NSSortDescriptor(key: "dueDate", ascending: true)
        ]
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Could not fetch tasks: \(error)")
            tasks = []
        }
        tableView.backgroundView = tasks.isEmpty
            ? emptyStateLabel("No tasks yet.\nTap + to add one.") : nil
        tableView.reloadData()
    }

    // MARK: - Actions
    @IBAction func addTaskTapped(_ sender: UIBarButtonItem) {
        // sender: nil means "no existing task", so the form opens in "add" mode.
        performSegue(withIdentifier: "ShowTaskFormSegue", sender: nil)
    }

    @IBAction func notesTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ShowNotesSegue", sender: nil)
    }

    // MARK: - Table view data source
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return tasks.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell",
                                                 for: indexPath)
        let task = tasks[indexPath.row]
        let dueText = task.dueDate?.formatted(date: .abbreviated, time: .shortened)
            ?? "no due date"
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(
            systemName: task.isDone ? "checkmark.circle.fill" : prioritySymbol(for: task.priority)
        )
        content.imageProperties.tintColor = task.isDone
            ? AppAppearance.teal : priorityColor(for: task.priority)
        content.text = task.title ?? "Untitled task"
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.secondaryText = "Due \(dueText)  •  \(priorityName(for: task.priority))"
        content.textProperties.color = task.isDone ? .secondaryLabel : .label
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    private func priorityName(for value: Int16) -> String {
        switch value {
        case 0: return "Low"
        case 2: return "High"
        default: return "Medium"
        }
    }

    private func prioritySymbol(for value: Int16) -> String {
        return value == 2 ? "exclamationmark.circle.fill" : "circle.fill"
    }

    private func priorityColor(for value: Int16) -> UIColor {
        return value == 0 ? AppAppearance.teal
            : (value == 2 ? AppAppearance.coral : .systemOrange)
    }

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 88
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Pass the tapped task so the form opens in "edit" mode.
        performSegue(withIdentifier: "ShowTaskFormSegue",
                     sender: tasks[indexPath.row])
    }

    // Swipe right: mark done / undo.
    override func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]
        let title = task.isDone ? "Undo" : "Done"
        let action = UIContextualAction(style: .normal, title: title) {
            [weak self] _, _, completion in
            task.isDone.toggle()
            CoreDataStack.shared.save()
            self?.loadTasks()
            completion(true)
        }
        action.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [action])
    }

    // Swipe left: delete.
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] _, _, completion in
            guard let self = self else { completion(false); return }
            self.context.delete(self.tasks[indexPath.row])
            CoreDataStack.shared.save()
            self.loadTasks()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowTaskFormSegue":
            guard let destination = segue.destination as? TaskFormViewController
            else { return }
            destination.subject = subject
            destination.taskToEdit = sender as? TaskItem // nil when adding a new task
        case "ShowNotesSegue":
            guard let destination = segue.destination as? NotesViewController
            else { return }
            destination.subject = subject
        default:
            break
        }
    }
}

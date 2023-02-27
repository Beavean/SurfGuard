//
//  FiltersTableViewController.swift
//  WebsiteFilter
//
//  Created by Beavean on 25.02.2023.
//

import UIKit

final class FiltersTableViewController: UITableViewController {
    // MARK: - UI Elements

    private lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                                 target: self,
                                                 action: #selector(addButtonTapped))
    private lazy var addAction = UIAlertAction()
    private lazy var filterInputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Filter word"
        textField.addTarget(self, action: #selector(self.filterTextFieldChanged(_:)), for: .editingChanged)
        return textField
    }()

    // MARK: - Properties

    private let cellLabelFontSize: CGFloat = 22
    private var webPageFilters: [String] {
        get {
            WebPageManager.addedFilters
        }
        set {
            WebPageManager.addedFilters = newValue
            setTitle()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func configure() {
        setTitle()
        navigationItem.rightBarButtonItem = addButton
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterCell")
    }

    private func setTitle() {
        navigationItem.title = webPageFilters.isEmpty ? "Press + to add filter words" : "Filtered words:"
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        let addFilterAlertController = UIAlertController(title: "Add Filter",
                                                         message: "Enter a word to filter:",
                                                         preferredStyle: .alert)
        addFilterAlertController.addTextField { textField in
            textField.placeholder = "Filter word"
            textField.addTarget(self, action: #selector(self.filterTextFieldChanged(_:)), for: .editingChanged)
        }
        addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let filterString = addFilterAlertController.textFields?[0].text, !filterString.isEmpty else { return }
            self?.webPageFilters.append(filterString)
            self?.tableView.reloadData()
        }
        addAction.isEnabled = false
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        addFilterAlertController.addAction(addAction)
        addFilterAlertController.addAction(cancelAction)
        present(addFilterAlertController, animated: true, completion: nil)
    }

    @objc private func filterTextFieldChanged(_ textField: UITextField) {
        addAction.isEnabled = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 >= 2
    }

    // MARK: - Table view data source

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return webPageFilters.count
    }

    override func tableView(_: UITableView, titleForFooterInSection _: Int) -> String? {
        webPageFilters.isEmpty ? nil : "⇠ swipe to delete"
    }

    override func tableView(_: UITableView, willDisplayFooterView view: UIView, forSection _: Int) {
        guard let footer: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView else { return }
        footer.textLabel?.textAlignment = .center
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        cell.textLabel?.text = webPageFilters[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: cellLabelFontSize)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .clear
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            webPageFilters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

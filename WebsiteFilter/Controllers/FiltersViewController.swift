//
//  FiltersViewController.swift
//  WebsiteFilter
//
//  Created by Beavean on 25.02.2023.
//

import UIKit

final class FiltersViewController: UIViewController {
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
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        return tableView
    }()

    // MARK: - Properties

<<<<<<< HEAD
=======
    private let cellReuseIdentifier = "filterCell"
    private let footerTitle = "⇠ swipe to delete"
>>>>>>> 80bf49d (feat: Add extended functionality to FiltersTableViewController)
    private let cellLabelFontSize: CGFloat = 22
    private var webPageFilters: [String] {
        get {
            WebBrowserManager.addedFilters
        }
        set {
            WebBrowserManager.addedFilters = newValue
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
        view.backgroundColor = .backgroundColor
        navigationController?.isToolbarHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        navigationItem.rightBarButtonItem = addButton
<<<<<<< HEAD:WebsiteFilter/Controllers/FiltersTableViewController.swift
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
<<<<<<< HEAD
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterCell")
=======
=======
>>>>>>> 8bfaf67 (refactor: Rebuild UITableViewController to UIViewController with separate UITableView and improve UI):WebsiteFilter/Controllers/FiltersViewController.swift
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
>>>>>>> 80bf49d (feat: Add extended functionality to FiltersTableViewController)
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
        addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let filterString = addFilterAlertController.textFields?[0].text,
                  !filterString.isEmpty
            else { return }
            var filters = [String]()
            filters = self.webPageFilters.filter { $0 != filterString }
            filters.append(filterString)
            self.webPageFilters = filters
            self.tableView.reloadData()
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
}

extension FiltersTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        webPageFilters.count
    }

<<<<<<< HEAD:WebsiteFilter/Controllers/FiltersTableViewController.swift
    override func tableView(_: UITableView, titleForFooterInSection _: Int) -> String? {
<<<<<<< HEAD
        webPageFilters.isEmpty ? nil : "⇠ swipe to delete"
=======
        webPageFilters.isEmpty ? nil : footerTitle
>>>>>>> 80bf49d (feat: Add extended functionality to FiltersTableViewController)
    }

    override func tableView(_: UITableView, willDisplayFooterView view: UIView, forSection _: Int) {
        guard let footer: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView else { return }
        footer.textLabel?.textAlignment = .center
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
<<<<<<< HEAD
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
=======
=======
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
>>>>>>> 8bfaf67 (refactor: Rebuild UITableViewController to UIViewController with separate UITableView and improve UI):WebsiteFilter/Controllers/FiltersViewController.swift
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
>>>>>>> 80bf49d (feat: Add extended functionality to FiltersTableViewController)
        cell.textLabel?.text = webPageFilters[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: cellLabelFontSize)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            webPageFilters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_: UITableView, titleForFooterInSection _: Int) -> String? {
        webPageFilters.isEmpty ? nil : footerTitle
    }

    func tableView(_: UITableView, willDisplayFooterView view: UIView, forSection _: Int) {
        guard let footer: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView else { return }
        footer.tintColor = .backgroundColor
        footer.textLabel?.textAlignment = .center
    }
}

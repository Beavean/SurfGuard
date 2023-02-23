//
//  MainViewController.swift
//  WebsiteFilter
//
//  Created by Beavean on 23.02.2023.
//

import UIKit
import WebKit

final class MainViewController: UIViewController, WKNavigationDelegate {

    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private let urlField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter URL"
        textField.returnKeyType = .go
        return textField
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("<", for: .normal)
        return button
    }()

    private let forwardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(">", for: .normal)
        return button
    }()

    private let filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Filter", for: .normal)
        return button
    }()

    private let filtersButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Filters", for: .normal)
        return button
    }()

    private let filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private var filters: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        let topStack = UIStackView(arrangedSubviews: [filterButton, filtersButton])
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.distribution = .fillEqually

        let bottomStack = UIStackView(arrangedSubviews: [backButton, forwardButton])
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.distribution = .fillEqually

        view.addSubview(topStack)
        view.addSubview(urlField)
        view.addSubview(webView)
        view.addSubview(bottomStack)

        NSLayoutConstraint.activate([

            topStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topStack.heightAnchor.constraint(equalToConstant: 50),

            urlField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            urlField.topAnchor.constraint(equalTo: topStack.bottomAnchor),
            urlField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            urlField.heightAnchor.constraint(equalToConstant: 50),

            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.topAnchor.constraint(equalTo: urlField.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor),

            bottomStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomStack.heightAnchor.constraint(equalToConstant: 50)
        ])

        urlField.delegate = self

        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(didTapForwardButton), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        filtersButton.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)

        filtersTableView.dataSource = self
        filtersTableView.delegate = self
    }

    @objc private func didTapBackButton() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc private func didTapForwardButton() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc private func didTapFilterButton() {
        let alertController = UIAlertController(title: "Add Filter", message: "Enter a string to filter URLs:", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Filter String"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alertController] _ in
            guard let self = self else { return }
            guard let filterString = alertController?.textFields?[0].text else { return }
            if !filterString.isEmpty {
                self.filters.append(filterString)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func didTapFiltersButton() {
        view.addSubview(filtersTableView)
        NSLayoutConstraint.activate([
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filtersTableView.topAnchor.constraint(equalTo: filtersButton.bottomAnchor),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filtersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString {
            if !filters.isEmpty {
                for filter in filters {
                    if url.contains(filter) {
                        decisionHandler(.cancel)
                        let alertController = UIAlertController(title: "Blocked", message: "This page is blocked due to the filter string: \(filter)", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        present(alertController, animated: true, completion: nil)
                        return
                    }
                }
            }
        }
        decisionHandler(.allow)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            if let url = URL(string: text) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
        textField.resignFirstResponder()
        return true
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = filters[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            filters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

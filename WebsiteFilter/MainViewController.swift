//
//  MainViewController.swift
//  WebsiteFilter
//
//  Created by Beavean on 23.02.2023.
//

import UIKit
import WebKit

// TODO: Keyboard hide

// TODO: text to icons

final class MainViewController: UIViewController {
    // MARK: - UI Elements

    private let filterButton = CustomButton(title: "＋")
    private let filtersButton = CustomButton(title: "✐")
    private let backButton = CustomButton(title: "◀")
    private let reloadButton = CustomButton(title: "↻")
    private let forwardButton = CustomButton(title: "▶")

    private lazy var urlField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter URL"
        textField.clearButtonMode = .always
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.smartQuotesType = .no
        textField.returnKeyType = .go
        textField.clearButtonMode = .always
        textField.tintAdjustmentMode = .automatic
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: basePadding, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.font = UIFont.systemFont(ofSize: 18)
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let attributedPlaceholder = NSAttributedString(string: "Enter URL", attributes: attributes)
        textField.attributedPlaceholder = attributedPlaceholder
        return textField
    }()

    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.isHidden = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        headerLabel.text = "⇠ Swipe to delete filter"
        headerLabel.textAlignment = .center
        headerLabel.backgroundColor = .clear
        tableView.tableHeaderView = headerLabel
        tableView.sectionHeaderHeight = self.elementsHeight
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        return tableView
    }()

    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }()

    private lazy var addFilterAlertController: UIAlertController = {
        let addFilterAlertController = UIAlertController(title: "Add Filter",
                                                         message: "Enter a word to filter URLs:",
                                                         preferredStyle: .alert)
        addFilterAlertController.addTextField { (textField) in
            textField.placeholder = "Filter word"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self, let filterString = addFilterAlertController.textFields?[0].text else { return }
            if !filterString.isEmpty {
                self.filters.append(filterString)
                self.filtersTableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        addFilterAlertController.addAction(addAction)
        addFilterAlertController.addAction(cancelAction)
        return addFilterAlertController
    }()

    // MARK: - Properties

    private let basePadding: CGFloat = 8
    private let elementsHeight: CGFloat = 44
    private var filterTableViewIsHidden = true {
        didSet {
            let buttonTitle = filterTableViewIsHidden ? "✐" : "×"
            filtersButton.changeTitle(to: buttonTitle)
            filtersTableView.isHidden = filterTableViewIsHidden
            blurView.isHidden = filterTableViewIsHidden
        }
    }
    private var filters = [String]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        addTargets()
        configureViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureGradientLayer()
        filterButton.addCornerRadiusBasedOnSize()
        filtersButton.addCornerRadiusBasedOnSize()
        backButton.addCornerRadiusBasedOnSize()
        forwardButton.addCornerRadiusBasedOnSize()
        urlField.addCornerRadiusBasedOnSize()
        reloadButton.addCornerRadiusBasedOnSize()
    }

    // MARK: - Actions

    @objc private func didTapBackButton() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc private func didTapReloadButton() {
        webView.reload()
    }

    @objc private func didTapForwardButton() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc private func didTapFilterButton() {
        present(addFilterAlertController, animated: true, completion: nil)
    }

    @objc private func didTapFiltersButton() {
        if filterTableViewIsHidden {
            view.addSubview(blurView)
            view.addSubview(filtersTableView)
            blurView.frame = webView.frame
            filtersTableView.frame = webView.frame
            filterTableViewIsHidden = false
        } else {
            filterTableViewIsHidden = true
            blurView.removeFromSuperview()
            filtersTableView.removeFromSuperview()
        }
    }

    // MARK: - Configuration

    private func setupDelegates() {
        webView.navigationDelegate = self
        urlField.delegate = self
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
    }

    private func addTargets() {
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(didTapForwardButton), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        reloadButton.addTarget(self, action: #selector(didTapReloadButton), for: .touchUpInside)
        filtersButton.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
    }

    func configureGradientLayer() {
        // TODO: bug when changing orientation
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemOrange.cgColor, UIColor.orange.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func configureViews() {
        let spacer = UIView()
        let topStack = createStackView(with: [filterButton, urlField, filtersButton])
        let bottomStack = createStackView(with: [backButton, reloadButton, forwardButton])
        topStack.distribution = .fill
        bottomStack.distribution = .equalSpacing
        view.addSubview(topStack)
        view.addSubview(webView)
        view.addSubview(bottomStack)
        webView.addSubview(activityIndicator)
        let trailingAnchor = view.safeAreaLayoutGuide.trailingAnchor
        let leadingAnchor = view.safeAreaLayoutGuide.leadingAnchor
        NSLayoutConstraint.activate([
            topStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: basePadding),
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: basePadding),
            topStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -basePadding),
            topStack.heightAnchor.constraint(equalToConstant: elementsHeight),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: basePadding),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -basePadding),
            activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
            bottomStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: basePadding),
            bottomStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -basePadding),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomStack.heightAnchor.constraint(equalToConstant: elementsHeight)
        ])
    }

    // MARK: - Helpers

    private func createStackView(with arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = basePadding
        return stackView
    }

    private func convertStringToUrl(_ string: String) -> String {
        let trimmedString = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
        guard trimmedString.count >= 2 else { return "" }
        let hasDomainSuffix = trimmedString.contains(".")
        && trimmedString.range(of: ".", options: .backwards)?.lowerBound != trimmedString.startIndex
        let urlString: String
        if trimmedString.lowercased().hasPrefix("http://") || trimmedString.lowercased().hasPrefix("https://") {
            urlString = trimmedString
        } else if hasDomainSuffix {
            urlString = "https://\(trimmedString)"
        } else {
            urlString = "https://\(trimmedString).com"
        }
        guard URL(string: urlString) != nil else { return "" }
        return urlString
    }
}

// MARK: - WKNavigationDelegate

extension MainViewController: WKNavigationDelegate {
    // TODO: Switch off app and safari opens
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString {
            if !filters.isEmpty {
                for filter in filters {
                    let words = filter.components(separatedBy: " ")
                    for filterWord in words where url.contains(filterWord) {
                        decisionHandler(.cancel)
                        let message = "This page is blocked"
                        let alertController = UIAlertController(title: "Blocked",
                                                                message: message,
                                                                preferredStyle: .alert)
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

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
}

// MARK: - UITextFieldDelegate

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, let url = URL(string: convertStringToUrl(text)) else { return false }
        textField.text = convertStringToUrl(text)
        let request = URLRequest(url: url)
        webView.isHidden = false
        webView.load(request)
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = filters[indexPath.row]
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            filters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

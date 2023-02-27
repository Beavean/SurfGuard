//
//  WebPageViewController.swift
//  WebsiteFilter
//
//  Created by Beavean on 23.02.2023.
//

import UIKit
import WebKit

final class WebPageViewController: UIViewController {
    // MARK: - UI Elements

    private lazy var backButton = UIBarButtonItem(barButtonSystemItem: .rewind,
                                                  target: self,
                                                  action: #selector(didTapBackButton))
    private lazy var refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                     target: self,
                                                     action: #selector(didTapReloadButton))
    private lazy var forwardButton = UIBarButtonItem(barButtonSystemItem: .fastForward,
                                                     target: self,
                                                     action: #selector(didTapForwardButton))
    private let urlTextField = URLTextField()
    private lazy var filtersButton: UIBarButtonItem = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        button.setTitle(" Filters ", for: .normal)
        button.sizeToFit()
        let borderView = UIView(frame: button.bounds)
        borderView.addRoundedBorder()
        borderView.addSubview(button)
        let barButtonItem = UIBarButtonItem(customView: borderView)
        return barButtonItem
    }()

    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.isHidden = true
        webView.clipsToBounds = false
        webView.scrollView.clipsToBounds = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .tintColor
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    // MARK: - Properties

    private let defaultElementHeight: CGFloat = 44
    private let cellLabelFontSize: CGFloat = 22
    private let webPageManager = WebPageManager()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        addKeyboardDismissal()
        configureViews()
        configureNavigationBar()
        configureToolBar()
        showLoadLastPageAlert()
    }

    override func viewDidLayoutSubviews() {
        adjustUrlTextFieldFrame()
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

    @objc private func didTapFiltersButton() {
        navigationController?.pushViewController(FiltersTableViewController(), animated: true)
    }

    @objc private func dismissKeyboard() {
        urlTextField.resignFirstResponder()
    }

    // MARK: - Configuration

    private func setupDelegates() {
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        urlTextField.delegate = self
    }

    private func addKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    private func configureViews() {
        view.backgroundColor = .backgroundColor
        view.addSubview(webView)
        webView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
        ])
    }

    private func configureNavigationBar() {
        adjustUrlTextFieldFrame()
        navigationItem.rightBarButtonItem = filtersButton
        navigationItem.titleView = urlTextField
    }

    private func configureToolBar() {
        navigationController?.isToolbarHidden = false
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [spacer, backButton, spacer, refreshButton, spacer, forwardButton, spacer]
    }

    // MARK: - Helpers

    private func showLoadLastPageAlert() {
        guard let string = WebPageManager.lastOpenedPage, let url = URL(string: string) else { return }
        let alertController = UIAlertController(title: "Load last opened page?",
                                                message: "Do you want to load the last opened web page?",
                                                preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            self.loadWebPage(fromUrl: url)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true)
    }

    private func loadWebPage(fromUrl url: URL) {
        let request = URLRequest(url: url)
        webView.isHidden = false
        webView.load(request)
    }

    private func adjustUrlTextFieldFrame() {
        guard let navigationBarFrame = navigationController?.navigationBar.frame else { return }
        let width = navigationBarFrame.width
        let frame = CGRect(x: 0, y: 0, width: width - 40, height: 0)
        urlTextField.frame = frame
        urlTextField.addRoundedBorder()
    }

    private func showAlertWith(message string: String) {
        let alertController = UIAlertController(title: string,
                                                message: nil,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

// MARK: - WKNavigationDelegate & UIScrollViewDelegate

extension WebPageViewController: WKNavigationDelegate, UIScrollViewDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url?.absoluteString.lowercased(),
              !WebPageManager.addedFilters.isEmpty
        else {
            decisionHandler(.allow)
            return
        }
        let isBlocked = WebPageManager.addedFilters
            .flatMap { $0.components(separatedBy: " ") }
            .contains(where: { url.contains($0.lowercased()) })
        if isBlocked {
            decisionHandler(.cancel)
            webView.reload()
            showAlertWith(message: "Page is blocked")
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        activityIndicator.startAnimating()
        urlTextField.text = webView.url?.absoluteString
    }

    func webView(_ webView: WKWebView, didCommit _: WKNavigation!) {
        activityIndicator.stopAnimating()
        WebPageManager.lastOpenedPage = webView.url?.absoluteString
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showAlertWith(message: error.localizedDescription)
    }

    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showAlertWith(message: error.localizedDescription)
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {
        urlTextField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension WebPageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let inputString = textField.text,
              let url = webPageManager.createUrl(from: inputString)
        else { return false }
        textField.text = url.absoluteString
        loadWebPage(fromUrl: url)
        textField.resignFirstResponder()
        return true
    }
}

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

    private let onboardingLabel = OnboardingLabel()

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
    private let defaultBarItemWidth: CGFloat = 44
    private let cellLabelFontSize: CGFloat = 22
    private let defaultPadding: CGFloat = 24
    private let webBrowserManager = WebBrowserManager()
    private var shouldShowWebView = false {
        didSet {
            webView.isHidden = !shouldShowWebView
            navigationController?.isToolbarHidden = !shouldShowWebView
            onboardingLabel.isHidden = shouldShowWebView
            guard !shouldShowWebView else { return }
            urlTextField.text = ""
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        addKeyboardDismissal()
        configureViews()
        configureNavigationBar()
        configureOnboardingLabel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfPageShouldBeBlocked()
        configureToolBar()
        showLoadLastPageAlert()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        navigationController?.pushViewController(FiltersViewController(), animated: true)
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

    private func configureOnboardingLabel() {
        view.addSubview(onboardingLabel)
        let safeView = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            onboardingLabel.topAnchor.constraint(equalTo: safeView.topAnchor, constant: defaultPadding),
            onboardingLabel.leadingAnchor.constraint(equalTo: safeView.leadingAnchor, constant: defaultPadding),
            onboardingLabel.trailingAnchor.constraint(equalTo: safeView.trailingAnchor, constant: -defaultPadding),
            onboardingLabel.bottomAnchor.constraint(equalTo: safeView.bottomAnchor, constant: -defaultPadding)
        ])
    }

    private func configureNavigationBar() {
        adjustUrlTextFieldFrame()
        navigationItem.rightBarButtonItem = filtersButton
        navigationItem.titleView = urlTextField
    }

    private func configureToolBar() {
        navigationController?.isToolbarHidden = !shouldShowWebView
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [spacer, backButton, spacer, refreshButton, spacer, forwardButton, spacer]
    }

    // MARK: - Helpers

    private func showLoadLastPageAlert() {
        guard let urlString = WebBrowserManager.lastOpenedPage,
              let url = URL(string: urlString),
              !webBrowserManager.isUrlBlocked(urlString: urlString) && !shouldShowWebView
        else { return }
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
        webView.load(request)
    }

    private func adjustUrlTextFieldFrame() {
        guard let navigationBarFrame = navigationController?.navigationBar.frame else { return }
        let width = navigationBarFrame.width
        let frame = CGRect(x: 0, y: 0, width: width - defaultBarItemWidth, height: 0)
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

    private func checkIfPageShouldBeBlocked() {
        guard let currentUrlString = webView.url?.absoluteString,
              webBrowserManager.isUrlBlocked(urlString: currentUrlString)
        else { return }
        shouldShowWebView = false
        urlTextField.text = ""
    }
}

// MARK: - WKNavigationDelegate & UIScrollViewDelegate

extension WebPageViewController: WKNavigationDelegate, UIScrollViewDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let urlString = navigationAction.request.url?.absoluteString.lowercased(),
              !WebBrowserManager.addedFilters.isEmpty
        else {
            shouldShowWebView = true
            decisionHandler(.allow)
            return
        }
        if webBrowserManager.isUrlBlocked(urlString: urlString) {
            decisionHandler(.cancel)
            showAlertWith(message: "Page is blocked")
        } else {
            shouldShowWebView = true
            decisionHandler(.allow)
        }
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        activityIndicator.startAnimating()
        urlTextField.text = webView.url?.absoluteString
    }

    func webView(_ webView: WKWebView, didCommit _: WKNavigation!) {
        WebBrowserManager.lastOpenedPage = webView.url?.absoluteString
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        guard let error = error as NSError?, error.code != -999 else { return }
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
        if textField.text == "" {
            shouldShowWebView = false
            return false
        }
        guard let inputString = textField.text,
              let url = webBrowserManager.createUrl(from: inputString)
        else { return false }
        textField.text = url.absoluteString
        loadWebPage(fromUrl: url)
        textField.resignFirstResponder()
        return true
    }
}

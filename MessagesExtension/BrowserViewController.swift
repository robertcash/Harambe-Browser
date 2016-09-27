//
//  BrowserViewController.swift
//  MonkeySee Browser
//
//  Created by Robert Cash on 9/5/16.
//  Copyright © 2016 Robert Cash. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    // MARK: - Static Variables
    
    static let storyboardIdentifier = "BrowserViewController"
    weak var parentController: MessagesViewController?
    
    // MARK: - Variables
    
    var wkWebView: WKWebView!
    var browserSession: BrowserSession?
    var timer: Timer?
    
    // MARK: - Delegates
    
    weak var browserViewControllerDelegate: BrowserViewControllerDelegate?
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var webView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - UIViewController Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Delegate declarations
        self.websiteTextField.delegate = self
        self.parentController?.messagesViewControllerDelegate = self
        
        // Hide unneeded UI Elements
        self.errorLabel.isHidden = true
        self.progressView.isHidden = true
        
        // Set localized text for UILabels, UITextFields, and UIButtons
        self.errorLabel.text = "A connection error occured, please try again".localized
        self.goButton.setTitle("Go".localized, for: .normal)
        self.sendButton.setTitle("Send Browser".localized, for: .normal)
        self.websiteTextField.placeholder = "Search or enter website name".localized
        self.goButton.accessibilityLabel = "Go".localized
        self.sendButton.accessibilityLabel = "Send Browser".localized
        self.refreshButton.accessibilityLabel = "Refresh".localized
        self.backButton.accessibilityLabel = "Back".localized
        self.forwardButton.accessibilityLabel = "Forward".localized
        self.webView.accessibilityLabel = "Web Browser".localized
        self.websiteTextField.accessibilityLabel = "Address Bar".localized
        
        // Make rounded corners on UIButtons and UIViews
        self.goButton.layer.cornerRadius = 10
        self.goButton.layer.masksToBounds = true
        self.sendButton.layer.cornerRadius = 10
        self.sendButton.layer.masksToBounds = true
        self.refreshButton.layer.cornerRadius = 10
        self.refreshButton.layer.masksToBounds = true
        self.backButton.layer.cornerRadius = 10
        self.backButton.layer.masksToBounds = true
        self.forwardButton.layer.cornerRadius = 10
        self.forwardButton.layer.masksToBounds = true
        self.webView.layer.cornerRadius = 10
        self.webView.layer.masksToBounds = true
        self.websiteTextField.layer.cornerRadius = 10
        self.websiteTextField.layer.masksToBounds = true
        self.progressView.layer.cornerRadius = 10
        self.progressView.layer.masksToBounds = true
        
        // Set borders for UIViews
        self.webView.layer.borderColor = UIColor(colorLiteralRed: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor
        self.webView.layer.borderWidth = 1
        self.websiteTextField.layer.borderColor = UIColor(colorLiteralRed: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor
        self.websiteTextField.layer.borderWidth = 1
        
        // UITextField Customization
        self.websiteTextField.layer.sublayerTransform = CATransform3DMakeTranslation(2.5, 0, 0)
        self.websiteTextField.clearButtonMode = .whileEditing
        
        // Gesture setup
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BrowserViewController.tap))
        tapGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // WKWebView Setup
        self.wkWebView = WKWebView(frame:self.webView.frame)
        self.wkWebView.sizeToFit()
        self.wkWebView.navigationDelegate = self
        
        self.wkWebView.allowsBackForwardNavigationGestures = true
        
        self.webView.addSubview(self.wkWebView)
        self.wkWebView.frame = CGRect(x: Double(self.webView.bounds.origin.x), y: Double(self.webView.bounds.origin.y), width: Double(self.webView.frame.width), height: Double(self.webView.frame.height))
        
        self.webView.addSubview(self.progressView)
        
        if !(self.browserSession != nil) {
            self.browserSession = BrowserSession()
        }
        let req = URLRequest(url: checkInput(input: (self.browserSession?.currentWebsite)!))
        
        self.wkWebView.load(req)
        
        // Expand iMessage App
        browserViewControllerDelegate?.expand()
        
        // Empty URL TextField
        self.websiteTextField.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.wkWebView.frame = CGRect(x: Double(self.webView.bounds.origin.x), y: Double(self.webView.bounds.origin.y), width: Double(self.webView.frame.width), height: Double(self.webView.frame.height))
        
    }
    
    
    // MARK: - Gesture Functions
    
    func tap() {
        browserViewControllerDelegate?.expand()
        self.websiteTextField.resignFirstResponder()
    }
    
    // MARK: - WKNavigationDelegate Delegate Functions
    
    func webView(_: WKWebView, didStartProvisionalNavigation: WKNavigation!) {
        self.errorLabel.isHidden = true
        self.progressView.progress = 0.0
        self.progressView.isHidden = false
        timer = Timer(timeInterval: 0.01667, target: self, selector: #selector(BrowserViewController.progressViewTimerHandler), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .defaultRunLoopMode)
        if !(self.browserSession?.new!)! {
            setTextField()
        }
        self.browserSession?.new = false
        self.browserViewControllerDelegate?.expand()
    }
    
    func webView(_: WKWebView, didFinish: WKNavigation!) {
        self.progressView.isHidden = true
        self.browserSession?.currentWebsite = wkWebView.url?.absoluteString
        buttonImageHandler()
    }
    
    func webView(_:WKWebView, didFail: WKNavigation!, withError: Error) {
        self.progressView.isHidden = true
        self.errorLabel.isHidden = false
        buttonImageHandler()
    }
    
    // MARK: - UITextField Delegate Functions
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.browserViewControllerDelegate?.expand()
        self.wkWebView.frame = CGRect(x: Double(self.webView.bounds.origin.x), y: Double(self.webView.bounds.origin.y), width: Double(self.webView.frame.width), height: Double(self.webView.frame.height))
        if self.parentController?.presentationStyle == .compact{
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.websiteTextField.resignFirstResponder()
        let req = URLRequest(url: checkInput(input: (self.websiteTextField.text)!))
        self.wkWebView.load(req)
        setTextField()
        return true
    }
    
    // MARK: - IB Actions
    
    @IBAction func go(_ sender: AnyObject) {
        let req = URLRequest(url: checkInput(input: (self.websiteTextField.text)!))
        self.wkWebView.load(req)
    }
    @IBAction func send(_ sender: AnyObject) {
        browserSession?.snapBrowser(view: self.webView)
        browserViewControllerDelegate?.sendBrowser(browserSession: self.browserSession!)
    }
    @IBAction func refresh(_ sender: AnyObject) {
        self.wkWebView.reload()
        setTextField()
    }
    @IBAction func forward(_ sender: AnyObject) {
        if wkWebView.canGoForward {
            self.wkWebView.goForward()
            setTextField()
        }
    }
    @IBAction func back(_ sender: AnyObject) {
        if wkWebView.canGoBack {
            self.wkWebView.goBack()
            setTextField()
        }
    }
    
    // MARK: - UI Helper Functions
    
    func progressViewTimerHandler(){
        if (!(self.wkWebView.isLoading)) {
            if (self.progressView.progress >= 1) {
                self.progressView.isHidden = true
                timer?.invalidate()
            }
            else {
                self.progressView.progress += 0.1
            }
        }
        else {
            self.progressView.progress += 0.05
            if (self.progressView.progress >= 0.95) {
                self.progressView.progress = 0.95
            }
        }
    }
    
    func buttonImageHandler() {
        if wkWebView.canGoBack {
            self.backButton .setImage(UIImage(named:"left-arrow-active"), for: .normal)
        }
        if !wkWebView.canGoBack {
            self.backButton .setImage(UIImage(named:"left-arrow-unactive"), for: .normal)
        }
        if wkWebView.canGoForward {
            self.forwardButton .setImage(UIImage(named:"right-arrow-active"), for: .normal)
        }
        if !wkWebView.canGoForward {
            self.forwardButton .setImage(UIImage(named:"right-arrow-unactive"), for: .normal)
        }
    }
    
    // MARK: - Other Helpers
    
    func setTextField(){
        self.websiteTextField.text = self.wkWebView.url?.absoluteString
    }
    
    func checkInput(input: String) -> URL {
        if((input.contains("https://") || input.contains("http://")) && !input.contains(" ")) {
            // If url works, then load that
            self.websiteTextField.text = input
            return input.toUrl
        }
        else if(input.contains(".") && !input.contains(" ")) {
            // If url doesn't have https:// add it.
            let modifiedURLString = "https://\(input)"
            self.websiteTextField.text = modifiedURLString
            return modifiedURLString.toUrl
        }
        else {
            // If not url, make it a Google search
            let query = input.replacingOccurrences(of: " ", with: "+")
            let googleUrl = "https://www.google.com/#q=\(query)"
            let modifiedURLString = googleUrl
            return modifiedURLString.toUrl
        }
    }
    
}

// MARK: - Protocols

protocol BrowserViewControllerDelegate: class {
    func sendBrowser(browserSession: BrowserSession)
    func expand()
}

// MARK: - Extensions

extension BrowserViewController: MessagesViewControllerDelegate {
    func updateConstraints() {
        self.wkWebView.frame = CGRect(x: Double(self.webView.bounds.origin.x), y: Double(self.webView.bounds.origin.y), width: Double(self.webView.frame.width), height: Double(self.webView.frame.height))
    }
}


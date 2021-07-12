//
//  PaymentGatewayVC.swift
//  Payment
//
//  Created by DEV27 on 21/10/19.
//  Copyright © 2020 myApps. All rights reserved.
//

import UIKit
import WebKit
import Common

class PaymentGatewayVC: UIViewController {
    private let ERROR_TAG_BACK = 1
    
    var initiator:PaymentInitiatorModel!
    var successMessage:String?
    var successTitle:String?
    var delegate:PaymentGatewayDelegate!
    var successDelegate: PaymentSuccessDelegate?
    var amount:Double?
    var token:String?
    var fromModule:SuccessModule?
    var isOrderLabel:Bool = false
    var redirectUrl:String = ""
    
    @IBOutlet var progressView : UIActivityIndicatorView!
    private var webView:WKWebView!
    
    fileprivate var alert:BaseAlertVC?
    //MARK: - UIView methods
    var visualEffectView = UIVisualEffectView()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(willEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
 
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: PaymentsModule.getImage(Named: .Icon_Back), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back(sender:)))
        webView = WKWebView.init(frame: view.frame)
        webView.configuration.allowsInlineMediaPlayback = true
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isHidden = true
        
        if amount != 0{
            if let requestUrl = initiator.requestUrl,
                let redirect = initiator.redirectUrl,
                let string = requestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL.init(string:string){
                redirectUrl = redirect
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                webView.load(request)
                AlertUtils.showAlert(withTitle: "Please Note".localString(), andMessage: "In case you do not receive transaction receipt due to any technical issues, it shall be sent to you on your registered email id within 48 hours.".localString())
            }else{
                dismissSelf(WithError: CustomError.init(title: "Error - Invalid link".localString(), message: "Sorry we encountered an error while processing the payment. Please try again later.".localString()))
            }
        }
    }
 
    @objc func willResignActiveNotification() {
        if !self.visualEffectView.isDescendant(of: self.view) {
            let blurEffect = UIBlurEffect(style: .light)
            self.visualEffectView = UIVisualEffectView(effect: blurEffect)
            self.visualEffectView.frame = (self.view.bounds)
            self.view.addSubview(self.visualEffectView)
        }
    }
    @objc func willEnterForegroundNotification() {
        self.visualEffectView.removeFromSuperview()
        
    }
    @objc func didBecomeActiveNotification() {
        self.visualEffectView.removeFromSuperview()
    }
    
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
        view.insertSubview(webView, belowSubview: progressView)
        
        if amount == 0 {
            
            present(CommonResources.getSuccesssVC(success: SuccessModel(message: successMessage ?? "Booking Confirmed".localString(), orderId: initiator!.orderId)), animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func dismissSelf(WithError error:CustomError){
        if let nav = self.navigationController{
            nav.popViewController(animated: true)
            self.delegate?.didFailWithError(error)
        }else{
            dismiss(animated: true) { [weak self] in
                self?.delegate?.didFailWithError(error)
            }
        }
    }
    
    func dismissSelf(WithSuccess delegate:PaymentSuccessDelegate){
        if let nav = self.navigationController{
            nav.popViewController(animated: true)
            delegate.didSucceed()
        }else{
            dismiss(animated: true){ delegate.didSucceed() }
        }
    }
    //MARK: - Process Url
    
    @objc func back(sender: UIBarButtonItem) {
        let vc = CommonResources.getConfirmationVC(withTitle: "Alert".localString(), desc: "Are you sure you want to cancel the payment and go back?".localString(), okButtonString: "Go Back".localString(), cancelButtonString: "Stay Here".localString())
        vc.tagId = ERROR_TAG_BACK
        vc.delegate = self
        vc.shouldDismissOnTapButton = false
        self.present(vc, animated: true, completion: nil)
        alert = vc
    }
    
    
    
    func processReturnUrl(url:URL){
        if url.valueOf("Status") == "200"{
            if let successDelegate = successDelegate{
                dismissSelf(WithSuccess: successDelegate)
            }else{
                present(CommonResources.getSuccesssVC(success: SuccessModel(title : successTitle ?? "Booking Confirmed".localString(), message : successMessage ?? "Payment Successful".localString(), isOrderLabel: isOrderLabel, orderId: initiator!.orderId,transactionId: url.valueOf("TransactionId"), token: token, amount:amount, fromModule: fromModule)), animated: true, completion: nil)
            }
        }else{
            dismissSelf(WithError: CustomError.init(title: "Payment Failed".localString(), message: url.valueOf("Response") ?? "Unknown error occured.".localString()))
        }
    }
    
    
    
}
extension PaymentGatewayVC : BaseAlertDelegate {
    func onDismiss(_ tag: Int) {}
    
    func onOkTap(_ tag: Int) {
        alert?.dismissVC()
        alert = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
            self?.dismissSelf(WithError: CustomError.init(title: "Payment Failed".localString(), message: "Transaction was cancelled.".localString()))
        }
    }
    
    func onCancelTap(_ tag: Int) {
        alert?.dismissVC()
        alert = nil
    }
}


extension PaymentGatewayVC: WKNavigationDelegate, WKUIDelegate{
    //MARK: - Webview delegate methods
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        progressView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        progressView.stopAnimating()
        webView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        progressView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.absoluteString.starts(with: redirectUrl) == true {
                decisionHandler(.cancel)
                processReturnUrl(url: url)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        DispatchQueue.main.async {
        UIMenuController.shared.setMenuVisible(false, animated: false)
            UIMenuController.shared.update()
        }
        return false
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {

        let alertController = UIAlertController(title: "Alert".localString(), message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localString(), style: .default, handler: { (action) in
            completionHandler()
        }))

        present(alertController, animated: true, completion: nil)
    }


    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {

        let alertController = UIAlertController(title: "Alert".localString(), message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK".localString(), style: .default, handler: { (action) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel".localString(), style: .default, handler: { (action) in
            completionHandler(false)
        }))

        present(alertController, animated: true, completion: nil)
    }


    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {

        let alertController = UIAlertController(title: "Alert".localString(), message: prompt, preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.text = defaultText
        }

        alertController.addAction(UIAlertAction(title: "OK".localString(), style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "Cancel".localString(), style: .default, handler: { (action) in
            completionHandler(nil)
        }))

        present(alertController, animated: true, completion: nil)
    }
 }

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}

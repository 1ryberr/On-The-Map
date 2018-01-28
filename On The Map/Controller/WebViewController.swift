//
//  WebViewController.swift
//  On The Map
//
//  Created by Ryan Berry on 12/25/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    var subtitle: String!
    var webView: WKWebView!
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: subtitle)
        webView.load(URLRequest(url:url!))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }

}

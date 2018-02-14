//
//  ViewController.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 7/25/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var favorites: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var browserBack: UIBarButtonItem!
    @IBOutlet weak var browserFarward: UIBarButtonItem!
    
    var downloadableURL:URLRequest? = nil;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.loadRequest(URLRequest(url: URL(string: "http://google.com")!));
        self.browserBack.isEnabled = self.webView.canGoBack;
        self.browserFarward.isEnabled = self.webView.canGoForward;
    }

    @IBAction func reload(_ sender: Any) {
        self.webView.reload();
    }
    
    @IBAction func stop(_ sender: Any) {
        self.webView.stopLoading();
    }
    
    @IBAction func goFarward(_ sender: Any) {
        if self.webView.canGoForward {
            self.webView.goForward();
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        if (self.webView.canGoBack) {
            self.webView.goBack();
        }
    }
    
    @IBAction func Download(_ sender: UIButton) {
        let vc = FavoritesViewController();
        vc.urlRequest = self.downloadableURL! as NSURLRequest;
        self.addButton.isEnabled = false;
        self.present(vc, animated: true, completion: nil);
    }
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil);
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("start load %@\n", webView.request?.url! as Any);
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        textField.text = webView.request?.url?.absoluteString;
        self.browserBack.isEnabled = self.webView.canGoBack;
        self.browserFarward.isEnabled = self.webView.canGoForward;
        print("finish load %@\n", webView.request?.url! as Any);
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let nserror = error as NSError;
        if (nserror.code == 204) {
            let WebKitErrorMIMETypeKey = nserror.userInfo["WebKitErrorMIMETypeKey"] as! String;
            if WebKitErrorMIMETypeKey ==  "audio/mpeg" {
                self.downloadableURL = webView.request;
                self.addButton.isEnabled = true;
            }
        } else {
            print(error.localizedDescription);
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "save" {
            let vc:FavoritesViewController = segue.destination as! FavoritesViewController;
            vc.urlRequest = self.downloadableURL! as NSURLRequest;
            self.addButton.isEnabled = true;
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let urlString = textField.text!;
        var req:URLRequest;
        if let url = URL(string: urlString) {
            req = URLRequest(url: url);
        } else {
            req = URLRequest(url: URL(string: "http://google.com/search?q=" + urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!)!);
        }
        self.webView.loadRequest(req);
        textField.resignFirstResponder();
        return true;
    }
}


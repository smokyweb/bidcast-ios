//
//  LinkedInLoginScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 06/03/24.
//

import Foundation
import SwiftUI
import WebKit

//MARK: - LinkedIn Base Constant
struct LinkedInConstants {
    static let CLIENT_ID = "86rjcbvarpyazk"
    static let CLIENT_SECRET = "tEfOV49ttz7kL64N"
    static let REDIRECT_URI = "https://backend.imperiumjob.com/linkedin/callback-process"
    static let SCOPE = "profile,email,openid"
    static let AUTHURL = "https://www.linkedin.com/oauth/v2/authorization"
    static let TOKENURL = "https://www.linkedin.com/oauth/v2/accessToken"
}

//MARK: - LinkedIn Request Type and Message
enum LinkedInRequestType {
    case success(authCode: String)
    case inProgress
    case stopLoading
    case aceessDenied
    case loginCancel
    case loginFailed
    case error(error: Error)
    
    func message() -> String {
        switch self {
            case .error(error: let error): return "\(error.localizedDescription)"
            case .success(authCode: let authCode): return "\(authCode)"
            case .aceessDenied: return "LinkedIn Login access has be denied. Please re-try"
            case .loginCancel: return "LinkedIn Login cancelled"
            case .loginFailed: return "Failed to Login with LinkedIn."
            case .inProgress: return "Login In Process"
            case .stopLoading: return "Loader Hide"
        }
    }
}

//MARK: - LinkedIn Login VC
struct LinkedInViewContainer: UIViewRepresentable {
    
        //MARK: - Initializers
    @State var url: String
    @State var eventType: ((LinkedInRequestType) -> Void)?
    
    func makeCoordinator() -> LinkedInViewContainer.Coordinator {
        return LinkedInViewContainer.Coordinator(eventType: $eventType)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        DispatchQueue.main.async {
            WKWebView.clean()
        }
        guard let url = URL(string: url) else {
            return WKWebView()
        }
        let request = URLRequest(url: url)
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false
        webView.isUserInteractionEnabled = true
        webView.navigationDelegate = context.coordinator
        webView.load(request)
        return webView
    }
    
    func updateUIView(_: WKWebView, context _: Context) {}
}

    //MARK: - LinkedIn Login Cordinate Handler
extension LinkedInViewContainer {
    class Coordinator: NSObject, WKNavigationDelegate {
        
        @Binding var eventType: ((LinkedInRequestType) -> Void)?
        
        init(eventType: Binding<((LinkedInRequestType) -> Void)?>) {
            _eventType = eventType
        }
        
        func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
            self.eventType?(.inProgress)
        }
        
        func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
            self.eventType?(.stopLoading)
        }
        
        func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {
            self.eventType?(.stopLoading)
            self.eventType?(.error(error: error))
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            let requestURLString = (navigationAction.request.url?.absoluteString)! as String
            Log.s(requestURLString)
            if requestURLString.hasPrefix(LinkedInConstants.REDIRECT_URI) {
                if requestURLString.contains("?code=") {
                    if let range = requestURLString.range(of: "=") {
                        let linkedinCode = requestURLString[range.upperBound...]
                        self.eventType?(.stopLoading)
                        self.eventType?(.success(authCode: String(linkedinCode)))
                        decisionHandler(.cancel)
                        return
                    }
                }
                
                if requestURLString.contains("error=access_denied") {
                    self.eventType?(.stopLoading)
                    self.eventType?(.aceessDenied)
                    decisionHandler(.cancel)
                    return
                }
                
                if requestURLString.contains("login-cancel?") {
                    self.eventType?(.stopLoading)
                    self.eventType?(.loginCancel)
                    decisionHandler(.cancel)
                    return
                }
            }
            
            if requestURLString.contains("error=access_denied") {
                self.eventType?(.stopLoading)
                self.eventType?(.aceessDenied)
                decisionHandler(.cancel)
                return
            }
            
            if requestURLString.contains("login-cancel?") {
                self.eventType?(.stopLoading)
                self.eventType?(.loginCancel)
                decisionHandler(.cancel)
                return
            }
            
            if requestURLString.contains("login?report") {
                self.eventType?(.stopLoading)
                self.eventType?(.loginFailed)
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
    }
}

extension WKWebView {
    class func clean() {
        guard #available(iOS 9.0, *) else {return}
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
#if DEBUG
                Log.v("WKWebsiteDataStore record deleted: \(record)")
#endif
            }
        }
    }
}

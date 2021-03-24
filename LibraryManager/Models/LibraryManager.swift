//
//  LibraryManager.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 16/03/2021.
//

import UIKit


class LibraryManager: UIViewController {
    let libraryUrl = "https://192.168.1.145:44346/api/"
}



extension LibraryManager: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           //Trust the certificate even if not valid
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

           completionHandler(.useCredential, urlCredential)
        }
}


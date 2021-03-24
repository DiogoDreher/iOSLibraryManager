//
//  CustomerModel.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 17/03/2021.
//

import UIKit

struct CustomerModel {
    let id: String
    let name: String
    let email: String
    let address: String
    let phone: String
    let isActive: Bool
    let dateAdded: String
    let imageUrl: String
    let image: UIImage
    
    var completeImgUrl: String {
        var url = imageUrl
        url.remove(at: url.startIndex)
        return url
    }
}

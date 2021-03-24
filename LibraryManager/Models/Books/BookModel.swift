//
//  Book.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 13/03/2021.
//

import UIKit


struct BookModel {
    let id: String
    let name: String
    let description: String
    let author: String
    let genre: String
    let year: Int
    let publisher: String
    let isActive: Bool
    let loadDate: String?
    let imageUrl: String
    let image: UIImage
    
    var completeImgUrl: String {
        var url = imageUrl
        url.remove(at: url.startIndex)
        return url
    }
}

//
//  Image.swift
//  RentaTeam_app
//
//  Created by Vladimir Gorbunov on 02.09.2021.
//

import Foundation

final class Image {
    let id: String
    let title: String
    let url: String
    
    init(id: String, title: String, url: String) {
        self.id = id
        self.title = title
        self.url = url
    }
}

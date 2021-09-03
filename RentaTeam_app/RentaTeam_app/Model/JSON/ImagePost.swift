//
//  ImagePost.swift
//  RentaTeam_app
//
//  Created by Vladimir Gorbunov on 02.09.2021.
//

import Foundation

struct ImagePost: Codable {
    let data : [PostData]
}

struct PostData: Codable {
    let title: String
    let images: [ImageData]?
}

struct ImageData: Codable {
    let id: String
    let type: String
    let size: Int
    let link: String
}

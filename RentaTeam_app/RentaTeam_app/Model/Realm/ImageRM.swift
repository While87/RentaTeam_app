//
//  ImageRM.swift
//  RentaTeam_app
//
//  Created by Vladimir Gorbunov on 02.09.2021.
//

import Foundation
import RealmSwift

class ImageRM: Object {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    @Persisted var url: String
    @Persisted var downloadedAt: String?
    @Persisted var image: Data?
    
}

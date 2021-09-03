//
//  MainManager.swift
//  RentaTeam_app
//
//  Created by Vladimir Gorbunov on 02.09.2021.
//

import Foundation
import UIKit
import RealmSwift

class MainManager {
    
    func getNewGalleryItems() {
        
        let url = "https://api.imgur.com/3/gallery/hot/viral/all/1?q_tags=image"
        let clientID = "9a17a14b9f227d9" //From registered App section in admin section imgur site
        
        guard let url = URL(string: url) else {
            return
        }
        
        //Autentication on imgur.com
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            do {
                let posts = try JSONDecoder().decode(ImagePost.self, from: data)
                
                //check data and append to realm database
                for i in posts.data {
                    if i.images != nil && i.images?[0].type != "video/mp4" && (i.images?[0].size)! < 16777216 {
                        let image = Image(id: (i.images![0].id), title: i.title, url: i.images![0].link)
                        self.saveImageItem(image: image)
                    }
                }
            }
            catch {
            }
        }.resume()
    }
    
    func saveImageItem(image: Image) {
        
        let newItem = ImageRM()
        newItem.id = image.id
        newItem.title = image.title
        newItem.url = image.url
        
        DispatchQueue(label: "saveQueue").async {
            autoreleasepool {
                let realm = try! Realm()
                guard realm.object(ofType: ImageRM.self, forPrimaryKey: image.id) == nil else {
                    return
                }
                
                try! realm.write {
                    realm.add(newItem)
                }
                self.downloadImage(url: image.url, id: image.id)
            }
        }
    }
    
    func downloadImage(url: String?, id: String) {
        let url = URL(string: url!)
        guard let url = url else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue(label: "updateQueue").async {
                autoreleasepool {
                    let realm = try! Realm()
                    try! realm.write {
                        realm.create(ImageRM.self, value: ["id": id, "downloadedAt": self.localDate(), "image": data], update: .modified)
                    }
                }
            }
        }.resume()
    }
    
    func localDate() -> String {
        let now = Date()
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        let date = dateFormatter.string(from: now)
        return date
    }
    
    func reloadEmptyImages() {
        let realm = try! Realm()
        let items = realm.objects(ImageRM.self)
        let emptyImageItems = items.filter("image == nil")
        for element in emptyImageItems {
            downloadImage(url: element.url, id: element.id)
        }
    }
}

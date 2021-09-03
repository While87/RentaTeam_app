//
//  DetailVC.swift
//  RentaTeam_app
//
//  Created by Vladimir Gorbunov on 02.09.2021.
//

import UIKit

class DetailVC: UIViewController {

    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailDate: UILabel!
    
    var image: UIImage?
    var label: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func updateData(image: UIImage, label: String) {
        self.image = image
        self.label = label
    }
    
    func updateView(){
        detailImage.image = image
        detailDate.text = label
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateView()
    }
}

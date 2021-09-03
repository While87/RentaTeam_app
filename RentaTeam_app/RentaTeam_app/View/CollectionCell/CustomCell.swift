//
//  CustomCell.swift
//  RentaTeam_app
//
//  Created by Vladimir Gorbunov on 02.09.2021.
//

import UIKit

class CustomCell: UICollectionViewCell {

    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var labelCell: UILabel!
    @IBOutlet weak var waitIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageCell.image = nil
        labelCell.text = nil
        imageCell.isHidden = false
        waitIndicator.startAnimating()
    }

}

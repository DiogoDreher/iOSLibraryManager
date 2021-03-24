//
//  CustomerCell.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 18/03/2021.
//

import UIKit

class CustomerCell: UITableViewCell {
    @IBOutlet weak var customerImage: UIImageView!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var customerPhone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

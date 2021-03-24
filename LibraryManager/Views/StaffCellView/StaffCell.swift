//
//  StaffCell.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 18/03/2021.
//

import UIKit

class StaffCell: UITableViewCell {
    @IBOutlet weak var staffImage: UIImageView!
    @IBOutlet weak var staffName: UILabel!
    @IBOutlet weak var staffRole: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  BookCell.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 13/03/2021.
//

import UIKit

class BookCell: UITableViewCell {
    @IBOutlet weak var bookCell: UIView!
    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookYear: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

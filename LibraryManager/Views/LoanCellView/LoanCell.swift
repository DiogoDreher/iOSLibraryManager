//
//  LoanCell.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 18/03/2021.
//

import UIKit

class LoanCell: UITableViewCell {
    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var loanDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

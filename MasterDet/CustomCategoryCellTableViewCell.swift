//
//  CustomCategoryCellTableViewCell.swift
//  masterDet
//
//  Created by Mobile on 18/05/2021.
//  Copyright © 2021 Philip Trwoga. All rights reserved.
//

import UIKit

class CustomCategoryCellTableViewCell: UITableViewCell {

    @IBOutlet weak var labelCategoryName: UILabel!
    @IBOutlet weak var labelBudgetAmount: UILabel!
    @IBOutlet weak var labelNotes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

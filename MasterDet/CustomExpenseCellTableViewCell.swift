//
//  CustomExpenseCellTableViewCell.swift
//  masterDet
//
//  Created by Mobile on 22/05/2021.
//  Copyright © 2021 Philip Trwoga. All rights reserved.
//

import UIKit

class CustomExpenseCellTableViewCell: UITableViewCell {

    @IBOutlet weak var labelExpenseNotesAndAmount: UILabel!
    @IBOutlet weak var labelExpenseDate: UILabel!
    @IBOutlet weak var expenseProgress: UIProgressView!
    @IBOutlet weak var labelOccurence: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        labelExpenseNotesAndAmount.text = ""
        labelExpenseDate.text = ""
        labelOccurence.text = ""
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

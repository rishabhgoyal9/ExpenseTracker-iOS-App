//
//  CustomTableViewCell.swift
//  ExpenseTracker
//
//  Created by Rishabh Goyal on 08/05/22.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

  
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var tableCellTopContainer: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 35
        self.contentView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureUI( obj : DataClass ){
        titleLabel.text = obj.title ?? ""
        descriptionLabel.text = obj.description ?? ""
        
        if let amount = obj.amount {
            var amountPrefix : String = ""
            if obj.isIncome == true { // income
                amountPrefix.insert("+", at: amountPrefix.endIndex)
            }else{ // expense
                amountPrefix.insert("-", at: amountPrefix.endIndex)
            }
            amountPrefix.insert("₹", at: amountPrefix.endIndex)
            
            amountPrefix.append("\(amount)")
            amountLabel.text = amountPrefix
        }else{
            amountLabel.text = "₹0"
        }
        
        if let incomeBool = obj.isIncome {
            if incomeBool == true { // income -> down arrow
                myImageView.image = UIImage(systemName: "arrow.down.circle.fill")
                let templateImage = myImageView.image?.withRenderingMode(.alwaysTemplate)
                myImageView.image = templateImage
                myImageView.tintColor = UIColor(red: 120/255, green: 188/255, blue: 140/255, alpha: 1)
                
                amountLabel.textColor = UIColor(red: 120/255, green: 188/255, blue: 140/255, alpha: 1)
                
            }else{ // expense -> up arrow
                myImageView.image = UIImage(systemName: "arrow.up.circle.fill")
                let templateImage = myImageView.image?.withRenderingMode(.alwaysTemplate)
                myImageView.image = templateImage
                myImageView.tintColor = UIColor(red: 235/255, green: 133/255, blue: 126/255, alpha: 1)
                
                amountLabel.textColor = UIColor(red: 235/255, green: 133/255, blue: 126/255, alpha: 1)
            }
        }

    }
    
}

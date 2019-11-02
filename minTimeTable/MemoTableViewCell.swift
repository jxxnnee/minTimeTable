//
//  MemoTableViewCell.swift
//  minTimeTable
//
//  Created by 민경준 on 2019/11/03.
//  Copyright © 2019 민경준. All rights reserved.
//

import UIKit

class MemoTableViewCell: UITableViewCell {

   
    
    
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  TimeTableViewCell.swift
//  minTimeTable
//
//  Created by 민경준 on 2019/11/01.
//  Copyright © 2019 민경준. All rights reserved.
//

import UIKit

class TimeTableViewCell: UITableViewCell {

    @IBOutlet weak var lectureName: UILabel!
    @IBOutlet weak var sTime: UILabel!
    @IBOutlet weak var eTime: UILabel!
    @IBOutlet weak var lectureDay: UILabel!
    @IBOutlet weak var professor: UILabel!
    @IBOutlet weak var location: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

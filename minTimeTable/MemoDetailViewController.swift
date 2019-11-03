//
//  MemoDetailViewController.swift
//  minTimeTable
//
//  Created by 민경준 on 2019/11/03.
//  Copyright © 2019 민경준. All rights reserved.
//

import UIKit

class MemoDetailViewController: UIViewController {
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoDes: UITextView!
    @IBOutlet weak var memoType: UILabel!
    
    var receivedTitle = ""
    var receivedDes = ""
    var receivedDate = ""
    var receviedType = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        memoDes.isEditable = false
        
        date.text = receivedDate
        memoTitle.text = receivedTitle
        memoDes.text = receivedDes
        memoType.text = receviedType
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

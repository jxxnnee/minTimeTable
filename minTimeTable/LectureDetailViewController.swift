//
//  LectureDetailViewController.swift
//  minTimeTable
//
//  Created by 민경준 on 2019/11/01.
//  Copyright © 2019 민경준. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa


class LectureDetailViewController: UIViewController {
    let strURL = "https://k03c8j1o5a.execute-api.ap-northeast-2.amazonaws.com/v1/programmers"
    let headers = ["x-api-key": "QJuHAX8evMY24jvpHfHQ4pHGetlk5vn8FJbk70O6",
                   "Content-Type": "application/json"]

    @IBOutlet weak var lectureName: UILabel!
    @IBOutlet weak var sTime: UILabel!
    @IBOutlet weak var eTime: UILabel!
    @IBOutlet weak var dayOfWeek: UILabel!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var professor: UILabel!
    @IBOutlet weak var location: UILabel!
    
    let bag = DisposeBag()
    var name = "웹서버프로그래밍"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLecturesByName(name)
        // Do any additional setup after loading the view.
    }
    
    
    
    func getLecturesByName(_ name: String) {
        let urlString = strURL + "/lectures?lecture=" + name
        let encodingURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: encodingURL)
            else {return}
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            (response) in
            
            if response.result.isSuccess {
                
                guard let data = response.data else {return}
                
                do {
                    let lecture = try JSONDecoder().decode(Lectures.self, from: data)
                    
                    let item = Observable.of(lecture)
                    
                    item.subscribe(onNext: { element in
                            self.lectureName.text = element.Items.first?.lecture
                            self.code.text = element.Items.first?.code
                            self.professor.text = element.Items.first?.professor
                            self.location.text = element.Items.first?.location
                            self.sTime.text = element.Items.first?.start_time
                            self.eTime.text = element.Items.first?.end_time
                            if let dow = element.Items.first?.dayofweek {
                                self.dayOfWeek.text = "(" + dow.reversed().joined(separator: "), (") + ")"
                            }
                        })
                        .disposed(by: self.bag)
                    
                    /* 처리 할 내용 */
                    
                }
                catch let error {
                    print("ERROR: \(error)")
                    
                }
            }
        }
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

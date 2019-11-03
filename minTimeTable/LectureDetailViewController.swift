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

    @IBOutlet weak var lectureName: UILabel!
    @IBOutlet weak var sTime: UILabel!
    @IBOutlet weak var eTime: UILabel!
    @IBOutlet weak var dayOfWeek: UILabel!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var professor: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var lectureIntro: UITextView!
    
    let bag = DisposeBag()
    var name = "웹서버프로그래밍"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lectureIntro.isEditable = false
        getLecturesByName(name)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addLectureAtTimeTable(_ sender: UIButton) {
        if let code = self.code.text {
            postTimeTable(DataModel.userKEY, code: code)
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                // 최상위 뷰를 pop 시켜서 닫아준다.
            }
        }
        else {
            print("ERROR: 에러 발생")
        }
        
    }

    
    //이름으로 강좌 정보를 가져오는 함수
    func getLecturesByName(_ name: String) {
        let urlString = DataModel.strURL + "/lectures?lecture=" + name
        let encodingURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: encodingURL)
            else {return}
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: DataModel.headers).responseJSON {
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
    
    
    
    // 시간표를 추가하는 함수
    func postTimeTable(_ userkey: String, code: String) {
        guard let url = URL(string: DataModel.strURL + "/timetable")
            else {return}
        
        let param = [
            "user_key":userkey,
            "code":code
        ]
        
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: DataModel.headers)
        
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

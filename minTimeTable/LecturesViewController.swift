//
//  LecturesViewController.swift
//  minTimeTable
//
//  Created by 민경준 on 31/10/2019.
//  Copyright © 2019 민경준. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class LecturesViewController: UIViewController, UITableViewDelegate {
    
    let strURL = "https://k03c8j1o5a.execute-api.ap-northeast-2.amazonaws.com/v1/programmers"
    let headers = ["x-api-key": "QJuHAX8evMY24jvpHfHQ4pHGetlk5vn8FJbk70O6",
                   "Content-Type": "application/json"]
    
    let bag = DisposeBag()
    let viewmodel = ViewModel()
    
//    var lectures = [String]()
//    var lectureCode = [String]()
//    var professors = [String]()
//    var locations = [String]()
//    var startTimes = [String]()
//    var endTimes = [String]()
//    var dayofweeks = [[String]]()
    var lectureCount = 0
    
    let lectures: BehaviorRelay<[Lecture]> = BehaviorRelay(value: [])
    
    let soso = Observable.of(Lectures.self)

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
        self.tableView.rowHeight = 160
        //tableView.estimatedRowHeight = 5000
        getLectures()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        bindTableView()
        
    }
    

    
    private func bindTableView() {
        print("바인딩 시작...")
//        let lectureOb: Observable<[String]> = Observable.of(lectures)
//        print(lectures)
        
        
        lectures.bind(to: self.tableView.rx.items(cellIdentifier: "ListCell", cellType: LecturesViewCell.self)) { (row, element, cell) in
            cell.separatorInset = UIEdgeInsets.zero
            cell.lectureName.text = element.lecture
            cell.lectureCode.text = element.code
            cell.professor.text = element.professor
            cell.location.text = element.location
            cell.startTime.text = element.start_time
            cell.endTime.text = element.end_time
            cell.dayOfWeek.text = "(" + element.dayofweek.joined(separator: "), (") + ")"
            
            
            
            }.disposed(by: bag)
    }
    
    
    // 모든 강좌를 가져오는 함수
    func getLectures() {
        guard let url = URL(string: strURL + "/lectures")
            else {return}
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            (response) in
            
            if response.result.isSuccess {
                
                guard let data = response.data else {return}
                
                do {
                    let lecture = try JSONDecoder().decode(Lectures.self, from: data)

                    print("디코딩 성공")
                    self.lectures.accept(lecture.Items)
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

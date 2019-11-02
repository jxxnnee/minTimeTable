//
//  ViewController.swift
//  minTimeTable
//
//  Created by 민경준 on 30/10/2019.
//  Copyright © 2019 민경준. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa
import RxDataSources


class ViewController: UIViewController {
    
    let bag = DisposeBag()
    let datamodel = DataModel()
    var Items = [Lecture]()
    let lectures: PublishRelay<[Lecture]> = PublishRelay()
    let myLectures = PublishSubject<String>()
    
    @IBOutlet weak var timeTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeTable.rowHeight = 160
        bindTableView()
        subscribeMyLectures()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Items = []
        self.lectures.accept(Items)
        getTimeTable(DataModel.userKEY)
        self.timeTable.reloadData()
        self.timeTable.tableFooterView = UIView(frame: CGRect.zero)
    }

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let code: String
        
        if let cell = self.timeTable.cellForRow(at: indexPath) as? TimeTableViewCell {
            if let name = cell.lectureName.text {
                performSegue(withIdentifier: "showMyLectureDetail", sender: name)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  "삭제", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            // Call edit action
            print(self.Items[indexPath.row])
            self.deleteTimeTable(DataModel.userKEY, code: self.Items[indexPath.row].code)
//            self.Items.remove(at: indexPath.row)
//            self.lectures.accept(self.Items)
            
            // Reset state
            
            success(true)
            
        })
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "moveToSearchLecture") {
            let searchVC = segue.destination as! LecturesViewController
        }
        
        if(segue.identifier == "showMyLectureDetail"){
            let DetailVC = segue.destination as! MyLectureDetailViewController
            DetailVC.name = (sender as! String)
        }
    }
}

extension ViewController {
    
    private func bindTableView() {
        lectures.bind(to: self.timeTable.rx.items(cellIdentifier: "TimeTableList", cellType: TimeTableViewCell.self)) { (row, element, cell) in
            cell.separatorInset = UIEdgeInsets.zero
            cell.lectureName.text = element.lecture
            cell.professor.text = element.professor
            cell.location.text = element.location
            cell.sTime.text = element.start_time
            cell.eTime.text = element.end_time
            cell.lectureDay.text = "(" + element.dayofweek.reversed().joined(separator: "), (") + ")"
            
            }.disposed(by: bag)
    }
    
    private func subscribeMyLectures() {
        myLectures.subscribe(onNext: { element in
            self.getLecturesByCode(element)
            })
        .disposed(by: bag)
    }
    
}


extension ViewController {
    
    // 등록한 모든 시간표를 가져오는 함수
    func getTimeTable(_ userkey: String) {
        guard let url = URL(string: DataModel.strURL + "/timetable?user_key=" + userkey)
            else {return}
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: DataModel.headers).responseJSON {
            (response) in
            
            if response.result.isSuccess {
                guard let data = response.data else {return}
                
                do {
                    let timetable = try JSONDecoder().decode(TimeTables.self, from: data)
                    
                    /* 처리 할 내용 */
                    for item in timetable.Items {
                        self.myLectures.onNext(item.lecture_code)
                    }
                }
                catch let error {
                    print("ERROR: \(error)")
                    
                }
            }
        }
    }
    
    
    
    //코드로 강좌 정보를 가져오는 함수
    func getLecturesByCode(_ code: String) {
        let urlString = DataModel.strURL + "/lectures?code=" + code
        let encodingURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: encodingURL)
            else {return}
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: DataModel.headers).responseJSON {
            (response) in
            
            if response.result.isSuccess {
                
                guard let data = response.data else {return}
                
                do {
                    let lecture = try JSONDecoder().decode(Lectures.self, from: data)
                    
                    /* 처리 할 내용 */
                    self.Items.append(lecture.Items[0])
//                    print("ITEMS: \(self.Items)")
                    self.lectures.accept(self.Items)
                    
                }
                catch let error {
                    print("ERROR: \(error)")
                }
            }
        }
    }
    
    
    // 시간표를 삭제하는 함수
    func deleteTimeTable(_ userkey: String, code: String) {
        guard let url = URL(string: DataModel.strURL + "/timetable")
            else {return}
        
        let param = [
            "user_key":userkey,
            "code":code
        ]
        
        Alamofire.request(url, method: .delete, parameters: param, encoding: JSONEncoding.default, headers: DataModel.headers)
        
    }
}


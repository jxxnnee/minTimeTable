//
//  MyLectureDetailViewController.swift
//  minTimeTable
//
//  Created by 민경준 on 2019/11/02.
//  Copyright © 2019 민경준. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

class MyLectureDetailViewController: UIViewController {
    @IBOutlet weak var lectureName: UILabel!
    @IBOutlet weak var sTime: UILabel!
    @IBOutlet weak var eTime: UILabel!
    @IBOutlet weak var lectureDay: UILabel!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var professor: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var memoTableView: UITableView!
    
    var memoDes: Dictionary<String, String> = Dictionary<String, String>()
    var memoDate: Dictionary<String, String> = Dictionary<String, String>()
    var memoType: Dictionary<String, String> = Dictionary<String, String>()
    
    
    let bag = DisposeBag()
    var name = "웹서버프로그래밍"
    let memoList: BehaviorRelay<[Memo]> = BehaviorRelay(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getLecturesByName(name)
        self.bindTableView()
        self.memoTableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let code = self.code.text {
            getMemoByCode(DataModel.userKEY, code: code)
        }
        self.memoTableView.reloadData()
        self.memoTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    @IBAction func addLectureMemo(_ sender: UIButton) {
        if let code = self.code.text {
            performSegue(withIdentifier: "addToMemo", sender: code)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addToMemo" {
            let AddMemoVC = segue.destination as! AddMemoViewController
            AddMemoVC.code = (sender as! String)
        }
        
        if segue.identifier == "showMemoDetail" {
            let detailMemoVC = segue.destination as! MemoDetailViewController
            let title = sender as! String
            
            detailMemoVC.receivedTitle = title
            detailMemoVC.receivedDes = memoDes[title]!
            detailMemoVC.receivedDate = memoDate[title]!
            detailMemoVC.receviedType = memoType[title]!
        }
    }
    
    private func bindTableView() {
        memoList.bind(to: self.memoTableView.rx.items(cellIdentifier: "MemoListCell", cellType: MemoTableViewCell.self)) { (row, element, cell) in
            cell.separatorInset = UIEdgeInsets.zero
            cell.title.text = element.title
            self.memoDes[element.title] = element.description
            self.memoDate[element.title] = element.date
            self.memoType[element.title] = element.type
            
            }.disposed(by: bag)
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

extension MyLectureDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  "삭제", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            // Call edit action
            if let code = self.code.text {
                if let cell = self.memoTableView.cellForRow(at: indexPath) as? MemoTableViewCell {
                    if let title = cell.title.text {
                        if let type = self.memoType[title] {
                            self.deleteMemo(DataModel.userKEY, code: code, type: type)
                        }
                    }
                }
            }
            
            // Reset state
            
            success(true)
            
            
        })
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.memoTableView.cellForRow(at: indexPath) as? MemoTableViewCell {
            if let title = cell.title.text {
                performSegue(withIdentifier: "showMemoDetail", sender: title)
            }
        }
    }
}


extension MyLectureDetailViewController {
    
    
    // 이름을 기준으로 모든 강좌를 가져오는 함수
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
                    
                    /* 처리 할 내용 */
                    if let item = lecture.Items.first {
                        self.code.text = item.code
                        self.lectureName.text = item.lecture
                        self.professor.text = item.professor
                        self.location.text = item.location
                        self.sTime.text = item.start_time
                        self.eTime.text = item.end_time
                        self.lectureDay.text = "(" + item.dayofweek.reversed().joined(separator: "), (") + ")"
                    }
                }
                catch let error {
                    print("ERROR: \(error)")
                    
                }
            }
        }
    }
    
    
    // 코드를 기준으로 모든 메모를 가져오는 함수
    func getMemoByCode(_ userkey: String, code: String) {
        guard let url = URL(string: DataModel.strURL + "/memo?user_key=" + userkey + "&code=" + code)
            else {return}
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: DataModel.headers).responseJSON {
            (response) in
            
            print(response)
            if response.result.isSuccess {
                guard let data = response.data else {return}
                
                do {
                    let memo = try JSONDecoder().decode(Memos.self, from: data)
                    
                    self.memoList.accept(memo.Items)
                    
                    /* 처리 할 함수 */
                }
                catch let error {
                    print("ERROR: \(error)")
                    
                }
            }
            else {
                print(response.error ?? "response error")
            }
        }
    }
    
    
    
    // 특정 메모를 삭제하는 함수
    func deleteMemo(_ userkey: String, code: String, type: String) {
        guard let url = URL(string: DataModel.strURL + "/memo")
            else {return}
        
        let param = [
            "user_key": userkey,
            "code": code,
            "type": type
        ]
        
        Alamofire.request(url, method: .delete, parameters: param, encoding: JSONEncoding.default, headers: DataModel.headers)
        
    }
    
}

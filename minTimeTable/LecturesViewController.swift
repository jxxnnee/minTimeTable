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

class LecturesViewController: UIViewController {
    
    let bag = DisposeBag()
    let datamodel = DataModel()
    let lectures: BehaviorRelay<[Lecture]> = BehaviorRelay(value: [])

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 160
        bindTableView()
        observeSearchBar()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getLectures()
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    

    
    private func bindTableView() {
        lectures.bind(to: self.tableView.rx.items(cellIdentifier: "ListCell", cellType: LecturesViewCell.self)) { (row, element, cell) in
            cell.separatorInset = UIEdgeInsets.zero
            cell.lectureName.text = element.lecture
            cell.lectureCode.text = element.code
            cell.professor.text = element.professor
            cell.location.text = element.location
            cell.startTime.text = element.start_time
            cell.endTime.text = element.end_time
            cell.dayOfWeek.text = "(" + element.dayofweek.reversed().joined(separator: "), (") + ")"
            }.disposed(by: bag)
    }
    
    private func observeSearchBar() {
        self.searchBar
            .rx.text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter({ !$0.isEmpty })
            .subscribe(onNext: {
                self.getLecturesByName($0)
                DispatchQueue.main.async {
                    self.tableView.reloadSections(IndexSet.init(integersIn: 0...0), with: UITableView.RowAnimation.automatic)
                }
            })
            .disposed(by: bag)
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


extension LecturesViewController: UITableViewDelegate, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let code: String
        
        if let cell = self.tableView.cellForRow(at: indexPath) as? LecturesViewCell {
            if let name = cell.lectureName.text {
                performSegue(withIdentifier: "showLectureDetail", sender: name)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        getLectures()
        self.searchBar.text = nil
        self.searchBar.showsCancelButton = false
        self.searchBar.endEditing(true)
    }
    
    //뷰 이동을 도와주는 함수
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let DetailVC = segue.destination as! LectureDetailViewController
        DetailVC.name = sender as! String
    }
}


extension LecturesViewController {
    
    // 모든 강좌를 가져오는 함수
    func getLectures() {
        guard let url = URL(string: DataModel.strURL + "/lectures")
            else {return}
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: DataModel.headers).responseJSON {
            (response) in
            
            if response.result.isSuccess {
                
                guard let data = response.data else {return}
                
                do {
                    let lecture = try JSONDecoder().decode(Lectures.self, from: data)
                    
                    self.lectures.accept(lecture.Items)
                }
                catch let error {
                    print("ERROR: \(error)")
                }
            }
        }
    }
    
    
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
                    self.lectures.accept(lecture.Items)
                }
                catch let error {
                    print("ERROR: \(error)")
                    
                }
            }
        }
    }
}

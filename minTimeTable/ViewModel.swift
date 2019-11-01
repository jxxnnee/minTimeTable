//
//  ViewModel.swift
//  minTimeTable
//
//  Created by 민경준 on 31/10/2019.
//  Copyright © 2019 민경준. All rights reserved.
//

import Alamofire
import Foundation

class ViewModel {
    
    static let instance = ViewModel()
    
    let strURL = "https://k03c8j1o5a.execute-api.ap-northeast-2.amazonaws.com/v1/programmers"
    let headers = ["x-api-key": "QJuHAX8evMY24jvpHfHQ4pHGetlk5vn8FJbk70O6",
                   "Content-Type": "application/json"]
    let userKEY = "83fc39b7b33cb7f1af005a63642be65b"
    
    
    
    
    // 이름을 기준으로 모든 강좌를 가져오는 함수
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
                    let lectures = try JSONDecoder().decode(Lectures.self, from: data)
                    
                    /* 처리 할 내용 */
                }
                catch let error {
                    print("ERROR: \(error)")
                    
                }
            }
        }
    }
    
    
    
    // 등록한 모든 시간표를 가져오는 함수
    func getTimeTable(_ userkey: String) {
        guard let url = URL(string: strURL + "/timetable?user_key=" + userkey)
            else {return}
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            (response) in
            
            print(response)
            if response.result.isSuccess {
                guard let data = response.data else {return}
                
                do {
                    let timetable = try JSONDecoder().decode(TimeTables.self, from: data)
                    
                    
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
        guard let url = URL(string: strURL + "/timetable")
            else {return}
        
        let param = [
            "user_key":userkey,
            "code":code
        ]
        
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
        
    }
    
    // 시간표를 삭제하는 함수
    func deleteTimeTable(_ userkey: String, code: String) {
        guard let url = URL(string: strURL + "/timetable")
            else {return}
        
        let param = [
            "user_key":userkey,
            "code":code
        ]
        
        Alamofire.request(url, method: .delete, parameters: param, encoding: JSONEncoding.default, headers: headers)
        
    }
    
    // 모든 메모를 불러오는 함수
    func getMemo(_ userkey: String) {
        guard let url = URL(string: strURL + "/memo?user_key=" + userkey)
            else {return}
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            (response) in
            
            print(response)
            if response.result.isSuccess {
                guard let data = response.data else {return}
                
                do {
                    let memo = try JSONDecoder().decode(Memos.self, from: data)
                    
                    /* 처리 할 내용 */
                }
                catch let error {
                    print("ERROR: \(error)")
                }
            }
        }
    }
    
    // 코드를 기준으로 모든 메모를 가져오는 함수
    func getMemoByCode(_ userkey: String, code: String) {
        guard let url = URL(string: strURL + "/memo?user_key=" + userkey + "&code=" + code)
            else {return}
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            (response) in
            
            print(response)
            if response.result.isSuccess {
                guard let data = response.data else {return}
                
                do {
                    let memo = try JSONDecoder().decode(Memos.self, from: data)
                    
                    
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
    
    // 특정 강좌에 메모를 추가하는 함수
    func addMemo(_ userkey: String, code: String, type: String, title: String, description: String, date: String) {
        guard let url = URL(string: strURL + "/memo")
            else {return}
        
        let param = [
            "user_key": userkey,
            "code": code,
            "type": type,
            "title": title,
            "description": description,
            "date": date
        ]
        
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
    }
    
    // 특정 메모를 삭제하는 함수
    func deleteMemo(_ userkey: String, code: String, type: String) {
        guard let url = URL(string: strURL + "/memo")
            else {return}
        
        let param = [
            "user_key": userkey,
            "code": code,
            "type": type
        ]
        
        Alamofire.request(url, method: .delete, parameters: param, encoding: JSONEncoding.default, headers: headers)
        
    }
    
    
}

struct Lectures: Decodable {
    var Items: [Lecture]
    var Count: Int
    var ScannedCount: Int
}

struct Lecture: Decodable {
    var code: String
    var lecture: String
    var professor: String
    var location: String
    var start_time: String
    var end_time: String
    var dayofweek: [String]
}

struct TimeTables: Decodable {
    var Items: [TimeTable]
    var Count: Int
    var ScannedCount: Int
}

struct TimeTable: Decodable {
    var lecture_code: String
}

struct Memos: Decodable {
    var Items: [Memo]
    var Count: Int
    var ScannedCount: Int
}

struct Memo: Decodable {
    var user_key: String
    var lecture_code: String
    var type: String
    var title: String
    var description: String
    var date: String
}

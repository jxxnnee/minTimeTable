//
//  ViewModel.swift
//  minTimeTable
//
//  Created by 민경준 on 31/10/2019.
//  Copyright © 2019 민경준. All rights reserved.
//

import Alamofire
import Foundation

class DataModel {
    
    static let strURL = "https://k03c8j1o5a.execute-api.ap-northeast-2.amazonaws.com/v1/programmers"
    static let headers = ["x-api-key": "QJuHAX8evMY24jvpHfHQ4pHGetlk5vn8FJbk70O6",
                   "Content-Type": "application/json"]
    static let userKEY = "83fc39b7b33cb7f1af005a63642be65b"

    
    
    // 모든 메모를 불러오는 함수
    func getMemo(_ userkey: String) {
        guard let url = URL(string: DataModel.strURL + "/memo?user_key=" + userkey)
            else {return}
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: DataModel.headers).responseJSON {
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

struct ErrorStruct: Decodable {
    var httpMethod: String
    var message: String
    var resource: String
}


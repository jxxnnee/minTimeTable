//
//  AddMemoViewController.swift
//  minTimeTable
//
//  Created by 민경준 on 2019/11/03.
//  Copyright © 2019 민경준. All rights reserved.
//

import UIKit
import Alamofire

class AddMemoViewController: UIViewController {

    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var typeTextView: UITextField!
    
    var code = ""
    var errorStr: ErrorStruct?
    
    let types = ["EXAM", "STUDY", "HOMEWORK"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let picker = UIPickerView()
        picker.delegate = self
        self.typeTextView.inputView = picker
        
        desTextView.delegate = self
        desTextView.text = "설명 추가"
        desTextView.textColor = UIColor.lightGray
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addToMemo(_ sender: UIButton) {
        guard let title = self.titleTextView.text else {return}
        guard let des = self.desTextView.text else {return}
        guard let type = self.typeTextView.text else {return}
        
        
        let alert = UIAlertController(title: "메모 추가 실패", message: "빈칸을 모두 채워주세요.", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler : nil )
        alert.addAction(okAction)
        
        let today = Date() //현재 시각 구하기
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: today)
        
        
        if title.trimmingCharacters(in: .whitespaces).isEmpty || des.trimmingCharacters(in: .whitespaces).isEmpty || des == "설명 추가" || type.trimmingCharacters(in: .whitespaces).isEmpty {
            present(alert, animated: true, completion: nil)
        }
        
        addMemo(DataModel.userKEY, code: self.code, type: type, title: title, description: des, date: dateString)
        
        
        
        DispatchQueue.main.async {
//            self.navigationController?.popViewController(animated: true)
            // 최상위 뷰를 pop 시켜서 닫아준다.
            if let message = self.errorStr?.message {
                print("MESSAGE: ", message)
            }
        }
        
    }
    
}


extension AddMemoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.types.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.types[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.typeTextView.text = self.types[row]
        
        self.view.endEditing(true)
    }
    
}



extension AddMemoViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewSetupPlaceHolder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if desTextView.text == "" {
            textViewSetupPlaceHolder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            desTextView.resignFirstResponder()
        }
        
        return true
    }
    
    func textViewSetupPlaceHolder() {
        if desTextView.text == "설명 추가" {
            desTextView.text = ""
            desTextView.textColor = UIColor.black
        }
        else if desTextView.text.isEmpty {
            desTextView.text = "설명 추가"
            desTextView.textColor = UIColor.lightGray
        }
    }
}


extension AddMemoViewController {
    
    // 특정 강좌에 메모를 추가하는 함수
    func addMemo(_ userkey: String, code: String, type: String, title: String, description: String, date: String) {
        guard let url = URL(string: DataModel.strURL + "/memo")
            else {return}
        
        let param = [
            "user_key": userkey,
            "code": code,
            "type": type,
            "title": title,
            "description": description,
            "date": date
        ]
        
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: DataModel.headers).responseJSON {
            response in
            
            print(response)
            if response.result.isSuccess {
                guard let data = response.data else {return}
                
                do {
                    let errorStr = try JSONDecoder().decode(ErrorStruct.self, from: data)
                    
                    print(errorStr)
                    self.errorStr = errorStr
                    
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
    
    
}

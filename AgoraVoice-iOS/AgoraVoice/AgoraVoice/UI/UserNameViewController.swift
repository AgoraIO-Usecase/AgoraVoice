//
//  UserNameViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/5.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class UserNameViewController: MaskViewController {
    @IBOutlet weak var nameTextField: UITextField!
    
    private let nameLimit = 16
    
    var newName: BehaviorRelay<String>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navigation = self.navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        navigation.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let navigation = self.navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        navigation.rightButton = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = newName {
            nameTextField.text = name.value
        } else {
            nameTextField.text = nil
        }
        
        nameTextField.delegate = self
        
        setupRightButton()
    }
    
    @objc func didDonePressed() {
        guard let name = nameTextField.text,
              name.count > 0 else {
            
            if DeviceAssistant.Language.isChinese {
                self.showTextToast(text: "用户名不可为空")
            } else {
                self.showTextToast(text: "")
            }
            
            return
        }
        
        if name != newName.value {
            newName.accept(name)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

private extension UserNameViewController {
    func setupRightButton() {
        guard let navigation = self.navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        navigation.navigationBar.isHidden = false
        
        self.navigationItem.title = NSLocalizedString("Input_Name")
        
        let buttonFrame = CGRect(x: 0,
                                 y: 0,
                                 width: 69,
                                 height: 30)
         
        let doneButton = UIButton(frame: buttonFrame)
        doneButton.addTarget(self,
                             action: #selector(didDonePressed),
                             for: .touchUpInside)
        doneButton.setTitle(NSLocalizedString("Done"), for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        doneButton.titleLabel?.adjustsFontSizeToFitWidth = true
        doneButton.setTitleColor(UIColor.white, for: .normal)
        doneButton.backgroundColor = UIColor(hexString: "#008AF3")
        doneButton.cornerRadius(4)
        navigation.rightButton = doneButton
    }
}

extension UserNameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if range.length == 1 && string.count == 0 {
            return true
        } else if let text = textField.text, text.count >= nameLimit {
            if DeviceAssistant.Language.isChinese {
                self.showTextToast(text: "用户名称不能超过\(nameLimit)个字符")
            } else {
                self.showTextToast(text: "Maximum length of user name is \(nameLimit)")
            }
            return false
        } else {
            return true
        }
    }
}

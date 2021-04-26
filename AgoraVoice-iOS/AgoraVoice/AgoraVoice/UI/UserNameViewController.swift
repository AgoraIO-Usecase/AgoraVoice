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
    
    private let nameLimit: UInt = 16
    
    var newName: BehaviorRelay<String>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigation = navigationController as? CSNavigationController {
            navigation.navigationBar.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigation = navigationController as? CSNavigationController {
            navigation.rightButton = nil
        }
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
            self.showTextToast(text: MineLocalizable.nicknameMinLengthLimit())
            return
        }
        
        if name != newName.value {
            newName.accept(name)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

private extension UserNameViewController {
    func setupRightButton() {
        guard let navigation = navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        navigation.navigationBar.isHidden = false
        
        navigationItem.title = MineLocalizable.inputName()
        
        let buttonFrame = CGRect(x: 0,
                                 y: 0,
                                 width: 69,
                                 height: 30)
         
        let doneButton = UIButton(frame: buttonFrame)
        doneButton.addTarget(self,
                             action: #selector(didDonePressed),
                             for: .touchUpInside)
        doneButton.setTitle(NSLocalizedString("Done"),
                            for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        doneButton.titleLabel?.adjustsFontSizeToFitWidth = true
        doneButton.setTitleColor(UIColor.white,
                                 for: .normal)
        doneButton.backgroundColor = UIColor(hexString: "#008AF3")
        doneButton.cornerRadius(4)
        navigation.rightButton = doneButton
    }
}

extension UserNameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if range.length == 1,
            string.count == 0 {
            return true
        } else if let text = textField.text,
                  text.count >= nameLimit {
            self.showTextToast(text: MineLocalizable.nicknameMaxLengthLimit(nameLimit))
            return false
        } else {
            return true
        }
    }
}

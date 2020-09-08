//
//  ThreeDimensionalViewController.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/8.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

class ThreeDimensionalViewController: RxViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ableSwitch: UISwitch!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = NSLocalizedString("Three_Dimensional_Voice")
        descriptionLabel.text = NSLocalizedString("Three_Dimensional_Voice_Description")
        
        backButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: bag)
        
        ableSwitch.rx.isOn.subscribe(onNext: { (isOn) in
            
        }).disposed(by: bag)
        
        slider.rx.value.subscribe(onNext: { (value) in
            
        }).disposed(by: bag)
    }
}

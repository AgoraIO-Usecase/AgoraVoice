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
    
    var audioEffectVM: AudioEffectVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = NSLocalizedString("Three_Dimensional_Voice")
        descriptionLabel.text = NSLocalizedString("Three_Dimensional_Voice_Description")
        
        backButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: bag)
        
        //
        audioEffectVM.selectedAudioSpace.accept(.threeDimensionalVoice)
        
        ableSwitch.isOn = (audioEffectVM.selectedAudioSpace.value == .threeDimensionalVoice)
        
        ableSwitch.rx.isOn.map { (isOn) -> AudioSpace in
            return isOn ? .threeDimensionalVoice : .disable
        }.bind(to: audioEffectVM.selectedAudioSpace).disposed(by: bag)
        
        ableSwitch.rx.isOn.bind(to: slider.rx.isEnabled).disposed(by: bag)
        
        slider.value = Float(audioEffectVM.threeDimensionalVoice.value)
        
        slider.rx.value.subscribe(onNext: { [unowned self] (value) in
            self.audioEffectVM.threeDimensionalVoice.accept(Int(value))
        }).disposed(by: bag)
    }
}

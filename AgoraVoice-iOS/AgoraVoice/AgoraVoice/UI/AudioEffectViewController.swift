//
//  AudioEffectViewController.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/7.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class AudioEffectPreView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = AudioEffectsLocalizable.comingSoon()
    }
}

class AudioEffectViewController: RxViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tabView: TabSelectView!
    
    @IBOutlet weak var aecollectionView: UIView!
    @IBOutlet weak var electronicMusicView: UIView!
    @IBOutlet weak var preView: AudioEffectPreView!
    
    weak var collectionVC: AECollectionViewController?
    
    var audioEffectVM: AudioEffectVM!
    var audioEffect: AudioEffectType = .belCanto
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = audioEffect.description
        
        updateTabView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }
        
        switch segueId {
        case "AECollectionViewController":
            let vc = segue.destination as! AECollectionViewController
            collectionVC = vc
            subscribeAECollectionVC(vc)
        case "ThreeDimensionalViewController":
            let vc = segue.destination as! ThreeDimensionalViewController
            vc.audioEffectVM = audioEffectVM
        case "ElectronicMusicViewController":
            let vc = segue.destination as! ElectronicMusicViewController
            vc.audioEffectVM = audioEffectVM
        default:
            break
        }
    }
}

private extension AudioEffectViewController {
    func updateTabView() {
        var titles = [String]()
        
        switch audioEffect {
        case .belCanto:
            for item in BelCantoType.list.value {
                titles.append(item.description)
            }
            tabView.titleSpace = 53
        case .soundEffect:
            for item in SoundEffectType.list.value {
                titles.append(item.description)
            }
            
            tabView.titleSpace = 24
        }
        
        tabView.titleTopSpace = 14
        tabView.alignment = DeviceAssistant.Language.isChinese ? .center : .left
        
        tabView.selectedTitle = TabSelectView.TitleProperty(color: UIColor(hexString: "#EEEEEE"),
                                                            font: UIFont.systemFont(ofSize: 14, weight: .medium))
        
        tabView.unselectedTitle = TabSelectView.TitleProperty(color: UIColor(hexString: "#9BA2AB"),
                                                              font: UIFont.systemFont(ofSize: 14))
        
        tabView.update(titles)
        
        tabView.selectedIndex.subscribe(onNext: { [unowned self] (index) in
            switch self.audioEffect {
            case .belCanto:    let type = BelCantoType.list.value[index];    self.updateCollectionWithBelCanto(type: type)
            case .soundEffect: let type = SoundEffectType.list.value[index]; self.updateCollectionWithSoundEffect(type: type)
            }
        }).disposed(by: bag)
    }
    
    func updateCollectionWithBelCanto(type: BelCantoType) {
        guard let vc = collectionVC else {
            assert(false)
            return
        }
        vc.belCantoType.accept(type)
    }
    
    func updateCollectionWithSoundEffect(type: SoundEffectType) {
        guard let vc = collectionVC else {
            assert(false)
            return
        }
        vc.soundEffectType.accept(type)
    }
}

private extension AudioEffectViewController {
    func subscribeAECollectionVC(_ vc: AECollectionViewController) {
        electronicMusicView.isHidden = true
        
        vc.audioEffectType = audioEffect
        vc.audioEffectVM = audioEffectVM
                
        // SoundEffectType - ThreeDimension
        vc.selectedThreeDimension.subscribe(onNext: { [unowned self] in
            self.performSegue(withIdentifier: "ThreeDimensionalViewController", sender: nil)
        }).disposed(by: bag)
        
        // special for eletronic music
        vc.selectedSoundEffectType.subscribe(onNext: { [unowned self] (type) in
            switch type {
            case .pitchCorrection:
                self.aecollectionView.isHidden = true
                self.electronicMusicView.isHidden = false
                self.preView.isHidden = true
            case .magicTone:
                self.aecollectionView.isHidden = true
                self.electronicMusicView.isHidden = true
                self.preView.isHidden = false
            default:
                self.aecollectionView.isHidden = false
                self.electronicMusicView.isHidden = true
                self.preView.isHidden = true
            }
        }).disposed(by: vc.bag)
    }
}

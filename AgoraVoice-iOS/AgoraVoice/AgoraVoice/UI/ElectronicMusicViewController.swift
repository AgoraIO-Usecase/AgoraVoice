//
//  ElectronicMusicViewController.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/8.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class ScaleCell: RxCollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    var isSelectedNow: Bool = false {
        didSet {
            if isSelectedNow {
                contentView.cornerRadius(20)
                contentView.layer.borderWidth = 1
                contentView.layer.borderColor = UIColor(hexString: "#008AF3").cgColor
                contentView.backgroundColor = UIColor(hexString: "#10284B")
                
                nameLabel.textColor = .white
            } else {
                contentView.cornerRadius(20)
                contentView.layer.borderWidth = 1
                contentView.layer.borderColor = UIColor(hexString: "#9BA2AB").cgColor
                contentView.backgroundColor = UIColor(hexString: "#161D27")
                
                nameLabel.textColor = UIColor(hexString: "#9BA2AB")
            }
        }
    }
}

class ElectronicMusicViewController: RxViewController {
    @IBOutlet weak var switchNameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ableSwitch: UISwitch!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var selectScaleLabel: UILabel!
    @IBOutlet weak var segmentWidth: NSLayoutConstraint!
    
    var audioEffectVM: AudioEffectVM!
    
    private let scaleList = BehaviorRelay<[String]>(value: ["A", "Bb", "B",
                                                            "C", "Db", "D",
                                                            "Eb", "E", "F",
                                                            "Gb", "G", "Ab"])
    
    private lazy var selectedValueIndex: BehaviorRelay<Int> = {
        let index = audioEffectVM.selectedElectronicMusic.value.value - 1
        let object = BehaviorRelay<Int>(value: index)
        return object
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchNameLabel.text = AudioEffectsLocalizable.enablePitchCorrection()
        selectScaleLabel.text = AudioEffectsLocalizable.selectTheStartingKey()
        
        // audioEffectVM
        audioEffectVM.selectedElectronicMusic.map { (music) -> Bool in
            return music.isAvailable
        }.bind(to: ableSwitch.rx.isOn).disposed(by: bag)
        
        audioEffectVM.selectedElectronicMusic.map { (music) -> Bool in
            return music.isAvailable
        }.bind(to: segmentControl.rx.isEnabled).disposed(by: bag)
        
        audioEffectVM.selectedElectronicMusic.map { (music) -> Bool in
            return music.isAvailable
        }.bind(to: collectionView.rx.isUserInteractionEnabled).disposed(by: bag)
       
        // ableSwitch
        ableSwitch.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self] in
            let isOn = self.ableSwitch.isOn
            let type = (self.segmentControl.selectedSegmentIndex + 1)
            let value = (self.selectedValueIndex.value + 1)
            let music = ElectronicMusic(isAvailable: isOn, type: type, value: value)
            self.audioEffectVM.selectedElectronicMusic.accept(music)
            self.collectionView.alpha = isOn ? 1.0 : 0.5
        }).disposed(by: bag)
        
        // segmentControl
        segmentControl.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self] in
            let index = self.segmentControl.selectedSegmentIndex
            var music = self.audioEffectVM.selectedElectronicMusic.value
            music.type = index + 1
            self.audioEffectVM.selectedElectronicMusic.accept(music)
        }).disposed(by: bag)

        audioEffectVM.selectedElectronicMusic.map { (music) -> Int in
            return music.type - 1
        }.bind(to: segmentControl.rx.selectedSegmentIndex).disposed(by: bag)
        
        // collectionView
        collectionView.alpha = ableSwitch.isOn ? 1.0 : 0.5

        collectionView.rx.itemSelected.subscribe(onNext: { [unowned self] (index) in
            self.selectedValueIndex.accept(index.item)
            self.collectionView.reloadData()
            
            var music = self.audioEffectVM.selectedElectronicMusic.value
            music.value = index.item + 1
            self.audioEffectVM.selectedElectronicMusic.accept(music)
        }).disposed(by: bag)
        
        modeSegment()
        scaleCollection()
    }
}

private extension ElectronicMusicViewController {
    func modeSegment() {
        segmentControl.setTitle(AudioEffectsLocalizable.major(),
                                forSegmentAt: 0)
        segmentControl.setTitle(AudioEffectsLocalizable.minor(),
                                forSegmentAt: 1)
        segmentControl.setTitle(AudioEffectsLocalizable.japeneseStyle(),
                                forSegmentAt: 2)
                
        if #available(iOS 13.0, *) {
            segmentControl.selectedSegmentTintColor = UIColor(hexString: "#0088EB")
        } else {
            segmentControl.tintColor = UIColor(hexString: "#0088EB")
        }
        
        var font: CGFloat
        
        if DeviceAssistant.Language.isChinese {
            font = 14
        } else {
            segmentWidth.constant = 340
            font = 10
        }
        
        segmentControl.backgroundColor = UIColor(hexString: "#161D27")
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#686E78"),
                                               NSAttributedString.Key.font : UIFont.systemFont(ofSize: font)],
                                              for: .normal)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white,
                                               NSAttributedString.Key.font : UIFont.systemFont(ofSize: font)],
                                              for: .selected)
    }
    
    func scaleCollection() {
        let width: CGFloat = 68.0
        let height: CGFloat = 40.0
        let itemSize = CGSize(width: width, height: height)
        var space = (UIScreen.main.bounds.width - (width * 4)) / CGFloat(5)
        if space < 10 {
            space = (UIScreen.main.bounds.width - (width * 3)) / CGFloat(4)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = itemSize
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = 15
        collectionView.contentInset = UIEdgeInsets(top: 0,
                                                   left: space,
                                                   bottom: 0,
                                                   right: space)
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        scaleList.bind(to: collectionView.rx.items(cellIdentifier: "ScaleCell",
                                                   cellType: ScaleCell.self)) { [unowned self] (index, item, cell) in
                                                    cell.nameLabel.text = item.description
                                                    cell.isSelectedNow = (index == self.selectedValueIndex.value)
        }.disposed(by: bag)
    }
}

//
//  AECollectionViewController.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/7.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class AEImageLabelCell: RxCollectionViewCell {
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var isSelectedNow: Bool = false {
        didSet {
            if isSelectedNow {
                contentView.cornerRadius(4)
                contentView.layer.borderWidth = 1
                contentView.layer.borderColor = UIColor(hexString: "#008AF3").cgColor
                contentView.backgroundColor = UIColor(hexString: "#10284B")
                
                nameLabel.textColor = .white
            } else {
                contentView.cornerRadius(0)
                contentView.layer.borderWidth = 0
                contentView.layer.borderColor = UIColor.white.cgColor
                contentView.backgroundColor = UIColor(hexString: "#161D27")
                
                nameLabel.textColor = UIColor(hexString: "#9BA2AB")
            }
        }
    }
}

class AELabelCell: RxCollectionViewCell {
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

class AECollectionViewController: RxViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var lastSubscribes = [Disposable]()
    
    var audioEffectType = AudioEffectType.belCanto
    var audioEffectVM: AudioEffectVM!
    
    let belCantoType = BehaviorRelay<BelCantoType>(value: .chat)
//    let selectedChatOfBelcanto = BehaviorRelay<ChatOfBelCanto>(value: .disable)
//    let selectedSingOfBelcanto = BehaviorRelay<SingOfBelCanto>(value: .disable)
//    let selectedTimbre = BehaviorRelay<Timbre>(value: .disable)
    
    let soundEffectType = BehaviorRelay<SoundEffectType>(value: .space)
//    let selectedAudioSpace = BehaviorRelay<AudioSpace>(value: .disable)
//    let selectedTimbreRole = BehaviorRelay<TimbreRole>(value: .disable)
//    let selectedMusicGenre = BehaviorRelay<MusicGenre>(value: .disable)
    
    // special for eletronic music
    let selectedSoundEffectType = PublishRelay<SoundEffectType>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch audioEffectType {
        case .belCanto:
            belCantoType.subscribe(onNext: { [unowned self] (type) in
                self.updateCollectionWithBelCanto(type: type)
            }).disposed(by: bag)
        case .soundEffect:
            soundEffectType.subscribe(onNext: { [unowned self] (type) in
                self.updateCollectionWithSoundEffect(type: type)
            }).disposed(by: bag)
        }
    }
}

private extension AECollectionViewController {
    func updateCollectionWithBelCanto(type: BelCantoType) {
        if lastSubscribes.count > 0 {
            for subscribe in lastSubscribes {
                subscribe.dispose()
            }
        }
        
        switch type {
        case .chat:
            let width: CGFloat = 78.0
            let height: CGFloat = 98.0
            let itemSize = CGSize(width: width, height: height)
            let space = (UIScreen.main.bounds.width - (width * 3)) / CGFloat(4)
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = itemSize
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = space
            collectionView.contentInset = UIEdgeInsets(top: 20,
                                                       left: space,
                                                       bottom: 0,
                                                       right: space)
            collectionView.setCollectionViewLayout(layout, animated: false)
            
            let listSubscribe = ChatOfBelCanto.list.bind(to: collectionView.rx.items(cellIdentifier: "AEImageLabelCell",
                                                                                 cellType: AEImageLabelCell.self)) { [unowned self] (index, item, cell) in
                                                                                    
                                                                                    cell.tagImageView.image = item.image
                                                                                    cell.nameLabel.text = "\(item.description)"
                                                                                    cell.isSelectedNow = (item == self.selectedChatOfBelcanto.value)
            }
            
            let selectSubscribe = collectionView.rx.modelSelected(ChatOfBelCanto.self).subscribe(onNext: { [unowned self] (item) in
                if self.selectedChatOfBelcanto.value == item {
                    self.selectedChatOfBelcanto.accept(.disable)
                } else {
                    self.selectedChatOfBelcanto.accept(item)
                }
                
                self.collectionView.reloadData()
            })
            
            lastSubscribes.append(listSubscribe)
            lastSubscribes.append(selectSubscribe)
        case .sing:
            let width: CGFloat = 78.0
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
            layout.minimumLineSpacing = 30
            collectionView.contentInset = UIEdgeInsets(top: 20,
                                                       left: space,
                                                       bottom: 0,
                                                       right: space)
            collectionView.setCollectionViewLayout(layout, animated: false)
            
            let listSubscribe = SingOfBelCanto.list.bind(to: collectionView.rx.items(cellIdentifier: "AELabelCell",
                                                                                 cellType: AELabelCell.self)) { [unowned self] (index, item, cell) in
                                                                                    cell.nameLabel.text = "\(item.description)"
                                                                                    cell.isSelectedNow = (item == self.selectedSingOfBelcanto.value)
            }
            
            let selectSubscribe = collectionView.rx.modelSelected(SingOfBelCanto.self).subscribe(onNext: { [unowned self] (item) in
                if self.selectedSingOfBelcanto.value == item {
                    self.selectedSingOfBelcanto.accept(.disable)
                } else {
                    self.selectedSingOfBelcanto.accept(item)
                }
                
                self.collectionView.reloadData()
            })
            
            lastSubscribes.append(listSubscribe)
            lastSubscribes.append(selectSubscribe)
        case .timbre:
            let width: CGFloat = 78.0
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
            layout.minimumLineSpacing = 30
            collectionView.contentInset = UIEdgeInsets(top: 20,
                                                       left: space,
                                                       bottom: 0,
                                                       right: space)
            collectionView.setCollectionViewLayout(layout, animated: false)
            
            let listSubscribe = Timbre.list.bind(to: collectionView.rx.items(cellIdentifier: "AELabelCell",
                                                                                 cellType: AELabelCell.self)) { [unowned self] (index, item, cell) in
                                                                                    cell.nameLabel.text = "\(item.description)"
                                                                                    cell.isSelectedNow = (item == self.selectedTimbre.value)
            }
            
            let selectSubscribe = collectionView.rx.modelSelected(Timbre.self).subscribe(onNext: { [unowned self] (item) in
                if self.selectedTimbre.value == item {
                    self.selectedTimbre.accept(.disable)
                } else {
                    self.selectedTimbre.accept(item)
                }
                
                self.collectionView.reloadData()
            })
            
            lastSubscribes.append(listSubscribe)
            lastSubscribes.append(selectSubscribe)
        }
    }
}

private extension AECollectionViewController {
    func updateCollectionWithSoundEffect(type: SoundEffectType) {
        if lastSubscribes.count > 0 {
            for subscribe in lastSubscribes {
                subscribe.dispose()
            }
        }
        
        let width: CGFloat = 78.0
        let height: CGFloat = 98.0
        let itemSize = CGSize(width: width, height: height)
        let space = (UIScreen.main.bounds.width - (width * 3)) / CGFloat(4)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = itemSize
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = space
        collectionView.contentInset = UIEdgeInsets(top: 20,
                                                   left: space,
                                                   bottom: 0,
                                                   right: space)
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        selectedSoundEffectType.accept(type)
        
        switch type {
        case .space:
            let listSubscribe = AudioSpace.list.bind(to: collectionView.rx.items(cellIdentifier: "AEImageLabelCell",
                                                                                 cellType: AEImageLabelCell.self)) { [unowned self] (index, item, cell) in
                                                                                    cell.tagImageView.image = item.image
                                                                                    cell.nameLabel.text = "\(item.description)"
                                                                                    cell.isSelectedNow = (item == self.selectedAudioSpace.value)
            }
            
            let selectSubscribe = collectionView.rx.modelSelected(AudioSpace.self).subscribe(onNext: { [unowned self] (item) in
                if self.selectedAudioSpace.value == item {
                    self.selectedAudioSpace.accept(.disable)
                } else {
                    self.selectedAudioSpace.accept(item)
                }
                
                self.collectionView.reloadData()
            })
            
            lastSubscribes.append(listSubscribe)
            lastSubscribes.append(selectSubscribe)
        case .role:
            let listSubscribe = TimbreRole.list.bind(to: collectionView.rx.items(cellIdentifier: "AEImageLabelCell",
                                                                                 cellType: AEImageLabelCell.self)) { [unowned self] (index, item, cell) in
                                                                                    cell.tagImageView.image = item.image
                                                                                    cell.nameLabel.text = "\(item.description)"
                                                                                    cell.isSelectedNow = (item == self.selectedTimbreRole.value)
            }
            
            let selectSubscribe = collectionView.rx.modelSelected(TimbreRole.self).subscribe(onNext: { [unowned self] (item) in
                if self.selectedTimbreRole.value == item {
                    self.selectedTimbreRole.accept(.disable)
                } else {
                    self.selectedTimbreRole.accept(item)
                }
                
                self.collectionView.reloadData()
            })
            
            lastSubscribes.append(listSubscribe)
            lastSubscribes.append(selectSubscribe)
        case .musciGenre:
            let listSubscribe = MusicGenre.list.bind(to: collectionView.rx.items(cellIdentifier: "AEImageLabelCell",
                                                                                 cellType: AEImageLabelCell.self)) { [unowned self] (index, item, cell) in
                                                                                    cell.tagImageView.image = item.image
                                                                                    cell.nameLabel.text = "\(item.description)"
                                                                                    cell.isSelectedNow = (item == self.selectedMusicGenre.value)
            }
            
            let selectSubscribe = collectionView.rx.modelSelected(MusicGenre.self).subscribe(onNext: { [unowned self] (item) in
                if self.selectedMusicGenre.value == item {
                    self.selectedMusicGenre.accept(.disable)
                } else {
                    self.selectedMusicGenre.accept(item)
                }
                
                self.collectionView.reloadData()
            })
            
            lastSubscribes.append(listSubscribe)
            lastSubscribes.append(selectSubscribe)
        case .electronicMusic:
            break
        }
    }
}

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
    
    let scaleList = BehaviorRelay<[String]>(value: ["A", "Bb", "B",
                                                    "C", "Db", "D",
                                                    "Eb", "E", "F",
                                                    "Gb", "G", "Ab"])
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchNameLabel.text = "启动电音"
        selectScaleLabel.text = "选择起始音阶"
        
        modeSegment()
        scaleCollection()
    }
}

private extension ElectronicMusicViewController {
    func modeSegment() {
        segmentControl.setTitle("大调", forSegmentAt: 0)
        segmentControl.setTitle("小调", forSegmentAt: 1)
        segmentControl.setTitle("和风", forSegmentAt: 2)
                
        if #available(iOS 13.0, *) {
            segmentControl.selectedSegmentTintColor = UIColor(hexString: "#0088EB")
        } else {
            segmentControl.tintColor = UIColor(hexString: "#0088EB")
        }
        
        segmentControl.backgroundColor = UIColor(hexString: "#161D27")
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#686E78")],
                                              for: .normal)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white],
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
                                                    cell.isSelectedNow = (index == self.selectedIndex)
        }.disposed(by: bag)
        
        collectionView.rx.itemSelected.subscribe(onNext: { [unowned self] (index) in
            self.selectedIndex = index.item
            self.collectionView.reloadData()
        }).disposed(by: bag)
    }
}

//
//  BackgroundViewController.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/3.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ImageSelectCell: UICollectionViewCell {
    @IBOutlet weak var roomImageView: UIImageView!
    @IBOutlet weak var selectedTag: UIImageView!
    
    var isBySelected: Bool = false {
        didSet {
            selectedTag.isHidden = !isBySelected
            
            if isBySelected {
                layer.borderColor = UIColor(hexString: "#0088EB").cgColor
                layer.borderWidth = 1
            } else {
                layer.borderWidth = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerRadius(7)
    }
}

class ImageSelectViewController: RxViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottom: NSLayoutConstraint!
    
    private let images = BehaviorRelay(value: [UIImage]())
    
    let selectIndex = BehaviorRelay(value: 0)
    let selectImage = PublishRelay<UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("Background")
        
        collectionViewBottom.constant = UIScreen.main.heightOfSafeAreaBottom
        
        let minimumInteritemSpacing: CGFloat = 8
        let sectionInset = UIEdgeInsets(top: 0,
                                        left: 15,
                                        bottom: 0,
                                        right: 15)
        let width = (UIScreen.main.bounds.width - (minimumInteritemSpacing * 2) - sectionInset.left - sectionInset.right) / 3
        let height = width
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: 10,
                                           bottom: 0,
                                           right: 10)
        layout.minimumInteritemSpacing = minimumInteritemSpacing
        layout.itemSize = CGSize(width: width, height: height)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        let imageFile = Center.shared().centerProvideImagesHelper()
        images.accept(imageFile.roomPreviews)
        
        images.bind(to: collectionView.rx.items(cellIdentifier: "ImageSelectCell",
                                                cellType: ImageSelectCell.self)) { [unowned self] (index, image, cell) in
                                                    cell.roomImageView.image = image
                                                    cell.isBySelected = (self.selectIndex.value == index)
        }.disposed(by: bag)
        
        collectionView.rx.itemSelected.map { (index) -> Int in
            return index.item
        }.bind(to: selectIndex).disposed(by: bag)
        
        selectIndex.subscribe(onNext: { [unowned self] (_) in
            self.collectionView.reloadData()
        }).disposed(by: bag)
        
        selectIndex.map { [unowned imageFile]  (index) -> UIImage in
            return imageFile.roomBackgrounds[index]
        }.bind(to: selectImage).disposed(by: bag)
    }
}

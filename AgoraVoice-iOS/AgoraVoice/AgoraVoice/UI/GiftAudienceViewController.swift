//
//  GiftAudienceViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/23.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class GiftAudienceCell: UICollectionViewCell {
    @IBOutlet var headImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headImage.backgroundColor = UIColor.blue
        self.headImage.cornerRadius(14)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

class GiftAudienceViewController: UICollectionViewController {
//    private(set) var list = BehaviorRelay(value: [LiveRoleItem]())
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 28.0, height: 28.0)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        self.collectionView.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        self.collectionView.setCollectionViewLayout(layout, animated: true)
        self.collectionView.reloadData()
        
        self.collectionView.backgroundColor = .clear
        
//        list.subscribe(onNext: { [unowned self] (_) in
//            self.collectionView.reloadData()
//        }).disposed(by: bag)
    }
    
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return list.value.count
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GiftAudienceCell", for: indexPath) as! GiftAudienceCell
////        let audience = list.value[indexPath.item]
////        cell.headImage.image = Center.shared().centerProvideImagesHelper().getHead(index: audience.info.imageIndex)
//        return cell
//    }
}

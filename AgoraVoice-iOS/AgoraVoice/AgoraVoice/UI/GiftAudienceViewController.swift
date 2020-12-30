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
}

class GiftAudienceViewController: RxCollectionViewController {
    private(set) var list = BehaviorRelay(value: [LiveRole]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 28.0, height: 28.0)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        collectionView.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.backgroundColor = .clear
        
        collectionView.delegate = nil
        collectionView.dataSource = nil
        
        list.bind(to: collectionView.rx.items(cellIdentifier: "GiftAudienceCell",
                                                  cellType: GiftAudienceCell.self)) { (index, user, cell) in
                                                    cell.headImage.image = user.info.image
        }.disposed(by: bag)
    }
}

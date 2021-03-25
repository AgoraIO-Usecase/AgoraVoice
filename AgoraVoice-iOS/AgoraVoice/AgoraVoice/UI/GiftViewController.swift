//
//  GiftViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/4/9.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class GiftCell: UICollectionViewCell {
    @IBOutlet var giftImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    var isSelectedNow: Bool = false {
        didSet {
            if isSelectedNow {
                contentView.cornerRadius(4)
                contentView.layer.borderWidth = 1
                contentView.layer.borderColor = UIColor(hexString: "#008AF3").cgColor
                contentView.backgroundColor = UIColor(hexString: "#10284B")
                
                nameLabel.textColor = .white
                priceLabel.textColor = .white
            } else {
                contentView.cornerRadius(0)
                contentView.layer.borderWidth = 0
                contentView.layer.borderColor = UIColor.white.cgColor
                contentView.backgroundColor = UIColor(hexString: "#161D27")
                
                nameLabel.textColor = UIColor(hexString: "#9BA2AB")
                priceLabel.textColor = UIColor(hexString: "#9BA2AB")
            }
        }
    }
}

class GiftViewController: RxViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    private var selectedIndex: Int = 0
    
    var selectGift = PublishRelay<Gift>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#161D27")
        
        titleLabel.text = NSLocalizedString("Gift")
        titleLabel.textColor = UIColor(hexString: "#EEEEEE")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(hexString: "#161D27")
        
        let itemWidth: CGFloat = 60.0
        let itemHeight: CGFloat = 75.0
        
        let spacing = (UIScreen.main.bounds.width - (4 * itemWidth) - 30) / 3
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = 10

        collectionView.setCollectionViewLayout(layout,
                                               animated: false)
        
        confirmButton.setTitle(LiveVCLocalizable.giveGiftAction(),
                               for: .normal)
        confirmButton.setTitleColor(.white,
                                    for: .normal)
        confirmButton.backgroundColor = UIColor(hexString: "#0088EB")
        confirmButton.cornerRadius(22)
    }
    
    @IBAction func doConfirmButton(_ sender: UIButton) {
        let gift = Gift.list[selectedIndex]
        selectGift.accept(gift)
    }
}

extension GiftViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return Gift.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GiftCell",
                                                      for: indexPath) as! GiftCell
        let item = Gift.list[indexPath.row]
        cell.giftImageView.image = item.image
        cell.nameLabel.text = item.description
        cell.priceLabel.text = "(\(item.price)\(NSLocalizedString("Coin")))"
        
        if selectedIndex == indexPath.row {
            cell.isSelectedNow = true
        } else {
            cell.isSelectedNow = false
        }
        return cell
    }
}

extension GiftViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
    }
}

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
                self.contentView.cornerRadius(4)
                self.contentView.layer.borderWidth = 1
                self.contentView.layer.borderColor = UIColor(hexString: "#008AF3").cgColor
                self.contentView.backgroundColor = UIColor(hexString: "#FAFAFA")
            } else {
                self.contentView.cornerRadius(0)
                self.contentView.layer.borderWidth = 0
                self.contentView.layer.borderColor = UIColor.white.cgColor
                self.contentView.backgroundColor = UIColor.white
            }
        }
    }
}

class GiftViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    private var selectedIndex: Int = 0
    
    var selectGift = PublishRelay<Gift>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = NSLocalizedString("Gift")
        
        let color = UIColor(hexString: "#D8D8D8")
        let x: CGFloat = 15.0
        let width = UIScreen.main.bounds.width - (x * 2)
        self.titleLabel.containUnderline(color,
                                         x: x,
                                         width: width)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let itemWidth: CGFloat = 60.0
        let itemHeight: CGFloat = 98.0
        
        let spacing = (UIScreen.main.bounds.width - (4 * itemWidth) - 30) / 3
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = 10

        collectionView.setCollectionViewLayout(layout, animated: false)
        
        confirmButton.setTitle(NSLocalizedString("Present"), for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = UIColor(hexString: "#0088EB")
        confirmButton.cornerRadius(22)
    }
    
    @IBAction func doConfirmButton(_ sender: UIButton) {
        let gift = Gift.list[selectedIndex]
        selectGift.accept(gift)
    }
}

extension GiftViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Gift.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GiftCell", for: indexPath) as! GiftCell
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
    }
}

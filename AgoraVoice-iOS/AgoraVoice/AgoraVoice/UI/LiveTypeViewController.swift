//
//  LiveTypeViewController.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/1.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxRelay

enum LiveType {
    case chatRoom
    
    var image: UIImage {
        switch self {
        case .chatRoom: return UIImage(named: "pic-voice")!
        }
    }
    
    var background: UIImage {
        switch self {
        case .chatRoom: return UIImage(named: "BG-首页")!
        }
    }
    
    var name: String {
        switch self {
        case .chatRoom: return DeviceAssistant.Language.isChinese ? "语聊房" : "Chatroom"
        }
    }
}

protocol LiveTypeCellDelegate: NSObjectProtocol {
    func cell(_ cell: LiveTypeCell,
              didPressedStartButton: UIButton,
              on index: Int)
}

class LiveTypeCell: RxCollectionViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var typeLabel: UILabel!
    
    weak var delegate: LiveTypeCellDelegate?
    var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startButton.setTitle(LiveTypeLocalizable.startButton(),
                             for: .normal)
        
        startButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.delegate?.cell(self,
                                didPressedStartButton: self.startButton,
                                on: self.index)
        }).disposed(by: bag)
    }
}

class LiveTypeViewController: MaskViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let list = BehaviorRelay(value: [LiveType.chatRoom])
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = AppAssistant.name
        updateCollectionViewLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }
        
        switch segueId {
        case "LiveListViewController":
            guard let type = sender as? LiveType else {
                assert(false)
                return
            }
            
            let vc = segue.destination as! LiveListViewController
            vc.type = type
            setupBackButton()
            setupNavigationBarColor()
            setupNavigationTitleFontColor()
        default:
            break
        }
    }
}

private extension LiveTypeViewController {
    func updateCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        let collectionTop: CGFloat = 57
        let collectionBottom: CGFloat = 35
        
        let height = UIScreen.main.bounds.height
            - UITabBar.height
            - UIScreen.main.heightOfSafeAreaTop
            - collectionTop - collectionBottom
        
        let space: CGFloat = 33
        let width = UIScreen.main.bounds.width - (space * 2)
        
        layout.itemSize = CGSize(width: width,
                                 height: height)
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: space,
                                           bottom: 0,
                                           right: space)
        layout.scrollDirection = .horizontal
        collectionView.setCollectionViewLayout(layout,
                                               animated: false)
        
        list.bind(to: collectionView.rx.items(cellIdentifier: "LiveTypeCell",
                                                cellType: LiveTypeCell.self)) { [unowned self] (index, type, cell) in
                                                    cell.backgroundImageView.image = type.background
                                                    cell.typeImageView.image = type.image
                                                    cell.typeLabel.text = type.name
                                                    cell.index = index
                                                    cell.delegate = self
        }.disposed(by: bag)
    }
    
    func setupBackButton() {
        guard let navigation = navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        let frame = CGRect(x: 0,
                           y: 0,
                           width: 69,
                           height: 44)
        let backButton = UIButton(frame: frame)
        backButton.setImage(UIImage(named: "icon-back"),
                            for: .normal)
        navigation.setupBarOthersColor(color: UIColor.white)
        navigation.backButton = backButton
    }
    
    func setupNavigationBarColor() {
        guard let navigation = navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        navigation.setupBarOthersColor(color: UIColor(hexString: "#161D27"))
    }
    
    func setupNavigationTitleFontColor() {
        guard let navigation = navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        navigation.setupTitleFontColor(color: UIColor(hexString: "#EEEEEE"))
    }
}

extension LiveTypeViewController: LiveTypeCellDelegate {
    func cell(_ cell: LiveTypeCell,
              didPressedStartButton: UIButton,
              on index: Int) {
        let type = list.value[index]
        performSegue(withIdentifier: "LiveListViewController",
                     sender: type)
    }
}

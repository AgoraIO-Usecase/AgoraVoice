//
//  MineViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/2/28.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class TopView: UIImageView {
    var imageView: UIImageView
    var label: UILabel
    
    override init(frame: CGRect) {
        let image = UIImageView(frame: CGRect.zero)
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFit
        self.imageView = image
        
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor(hexString: "#FFFFFF")
        label.textAlignment = .center
        self.label = label
        
        super.init(frame: frame)
        self.addSubview(label)
        self.addSubview(image)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageViewWH: CGFloat = 86.0
        let imageViewY = (self.bounds.height - imageViewWH) * 0.5
        let imageViewX = (self.bounds.width - imageViewWH) * 0.5
        
        self.imageView.frame = CGRect(x: imageViewX,
                                      y: imageViewY,
                                      width: imageViewWH,
                                      height: imageViewWH)
        self.imageView.isCycle = true
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor.white.cgColor
        
        let labelX: CGFloat = 10.0
        let lableY: CGFloat = imageViewY + imageViewWH + 19.0
        let labelW: CGFloat = self.bounds.width - (labelX * 2)
        let labelH: CGFloat = 24.0
        self.label.frame = CGRect(x: labelX, y: lableY, width: labelW, height: labelH)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MineViewController: UITableViewController {
    @IBOutlet weak var placeholderView: UIView!
    
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameValueLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    private var topView: TopView?
    private var mineVM = MineVM()
    private let bag = DisposeBag()
    
    /*
    private lazy var imagePicker: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = true
        controller.sourceType = .savedPhotosAlbum
        controller.modalPresentationStyle = .fullScreen
        return controller
    }()
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        updateViewsWithVM()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }
        
        switch segueId {
        case "UserNameViewController":
            let vc = segue.destination as! UserNameViewController
            vc.hidesBottomBarWhenPushed = true
            vc.newName = BehaviorRelay(value: mineVM.userName.value)
            updateNameWithNameVC(vc)
            setupCancelBackButton()
            setupNavigationBarColor()
            setupNavigationTitleFontColor()
        case "AboutViewController":
            let vc = segue.destination
            vc.hidesBottomBarWhenPushed = true
            setupBackButton()
            setupNavigationBarColor()
            setupNavigationTitleFontColor()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        /*
        switch indexPath {
        case IndexPath(row: 0, section: 0): // pick head image
            self.present(imagePicker, animated: true, completion: nil)
        default:
            break
        }
         */
    }
}

/*
extension MineViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        self.topView?.imageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
*/

private extension MineViewController {
    func updateViews() {
        let y = UIScreen.main.heightOfSafeAreaTop
        let view = TopView(frame: CGRect(x: 0,
                                         y: -y,
                                         width: UIScreen.main.bounds.width,
                                         height: y + 220))
        
        let image = UIImage(named: "BG-我的")
        view.image = image
        
        self.topView = view
        self.view.addSubview(view)
        
        // table cell
        self.headLabel.text = NSLocalizedString("Mine_Head")
        self.aboutLabel.text = NSLocalizedString("About")
        self.nameLabel.text = NSLocalizedString("Mine_Name")
    }
    
    func setupBackButton() {
        guard let navigation = self.navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 69, height: 44))
        backButton.setImage(UIImage(named: "icon-back"), for: .normal)
        navigation.setupBarOthersColor(color: UIColor.white)
        navigation.backButton = backButton
    }
    
    func setupCancelBackButton() {
        guard let navigation = self.navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        let backButton = UIButton(frame: CGRect(x: 10, y: 0, width: 69, height: 44))
        backButton.setTitle(NSLocalizedString("Cancel"), for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backButton.setTitleColor(UIColor(hexString: "#FFFFFF"), for: .normal)
        navigation.backButton = backButton
    }
    
    func setupNavigationBarColor() {
        guard let navigation = self.navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        navigation.setupBarOthersColor(color: UIColor(hexString: "#161D27"))
    }
    
    func setupNavigationTitleFontColor() {
        guard let navigation = self.navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        navigation.setupTitleFontColor(color: UIColor(hexString: "#EEEEEE"))
    }
}

private extension MineViewController {
    func updateViewsWithVM() {
        mineVM.userName.subscribe(onNext: { [unowned self] (name) in
            self.topView?.label.text = name
            self.nameValueLabel.text = name
        }).disposed(by: bag)

        mineVM.head.subscribe(onNext: { [unowned self]  (head) in
            self.topView?.imageView.image = head
        }).disposed(by: bag)
    }
    
    func updateNameWithNameVC(_ vc: UserNameViewController) {
        vc.newName.subscribe(onNext: { [unowned self] (newName) in
            guard newName != self.mineVM.userName.value else {
                return
            }
            self.mineVM.updateNewName(newName) {

            }
        }).disposed(by: bag)
    }
}

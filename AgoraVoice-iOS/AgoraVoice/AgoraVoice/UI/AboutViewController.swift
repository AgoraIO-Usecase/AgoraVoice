//
//  AboutViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/6/18.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import AgoraRte

class DisclaimerViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = MineLocalizable.disclaimer()
        
        let para = NSMutableParagraphStyle()
        para.alignment = .natural
        para.firstLineHeadIndent = 20
        para.lineSpacing = 5
        para.lineBreakMode = .byCharWrapping
        para.paragraphSpacingBefore = 0
        
        let string = NSAttributedString(string: NSLocalizedString("Disclaimer_Detail"),
                                        attributes: [NSAttributedString.Key.paragraphStyle : para,
                                                     NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),
                                                     NSAttributedString.Key.foregroundColor : UIColor.white])
        textView.attributedText = string
    }
}

class AboutViewController: MaskTableViewController {
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var disclaimerLabel: UILabel!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var sdkLabel: UILabel!
    @IBOutlet weak var alLabel: UILabel!
    
    @IBOutlet weak var releaseDateValueLabel: UILabel!
    @IBOutlet weak var sdkValueLabel: UILabel!
    @IBOutlet weak var alValueLabel: UILabel!
    
    @IBOutlet weak var uploadLogLabel: UILabel!
    
    private let agoraLabel = UILabel(frame: CGRect.zero)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigation = self.navigationController as? CSNavigationController {
            navigation.navigationBar.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MineLocalizable.about()
        privacyLabel.text = MineLocalizable.privacy()
        disclaimerLabel.text = MineLocalizable.disclaimer()
        registerLabel.text = MineLocalizable.registerAgoraAccount()
        versionLabel.text = MineLocalizable.releaseDate()
        sdkLabel.text = MineLocalizable.sdkVersion()
        alLabel.text = MineLocalizable.appVersion()
        
        alValueLabel.text = "Ver \(AppAssistant.version)"
        sdkValueLabel.text = "Ver \(AgoraRteEngine.getVersion())"
        
        releaseDateValueLabel.text = "2021.3.4"
        
        uploadLogLabel.text = MineLocalizable.uploadLog()
        
        agoraLabel.text = "www.agora.io"
        agoraLabel.font = UIFont.systemFont(ofSize: 16)
        agoraLabel.textColor = UIColor(hexString: "#686E78")
        agoraLabel.textAlignment = .center
        
        guard let navigation = navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        let w: CGFloat = 100
        let h: CGFloat = 20
        let x: CGFloat = (UIScreen.main.bounds.width - w) * 0.5
        let y: CGFloat = UIScreen.main.bounds.height -
            UIScreen.main.heightOfSafeAreaBottom -
            UIScreen.main.heightOfSafeAreaTop -
            navigation.navigationBar.bounds.height -
            15 - h
        
        agoraLabel.frame = CGRect(x: x,
                                  y: y,
                                  width: w,
                                  height: h)
        view.addSubview(agoraLabel)
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let privacyItem = 0
        let agoraAccountItem = 2
        let uploadLogItem = 6
        
        switch indexPath.row {
        case privacyItem:
            if let termsVC = TermsAndPolicyViewController.loadFromStoryboard("Policy", "terms") {
                termsVC.modalPresentationStyle = .fullScreen
                termsVC.fromSetting = true
                self.present(termsVC, animated: true, completion: nil)
            }
        case agoraAccountItem:
            var accountURL: URL?
            if DeviceAssistant.Language.isChinese {
                accountURL = URL(string: "https://sso.agora.io/cn/signup/")
            } else {
                accountURL = URL(string: "https://sso.agora.io/en/signup/")
            }
            
            guard let url = accountURL else {
                return
            }
            
            UIApplication.shared.privateOpenURL(url)
        case uploadLogItem:
            self.showHUD()
            let log = Center.shared().centerProvideFilesGroup().logs
            log.upload(success: { [weak self] (logId) in
                self?.hiddenHUD()

                let pasteboard = UIPasteboard.general
                pasteboard.string = logId

                self?.showTextToast(text: MineLocalizable.logIdCopy())
            }) { [weak self] (error) in
                self?.hiddenHUD()
                
                if error.code == -1 {
                    self?.showTextToast(text: NetworkLocalizable.lostConnectionRetry())
                } else {
                    self?.showTextToast(text: MineLocalizable.uploadLogFail())
                }
            }
        default:
            break
        }
    }
}

extension UIApplication {
    func privateOpenURL(_ url: URL) {
        open(url,
             options: [UIApplication.OpenExternalURLOptionsKey(rawValue: ""): ""],
             completionHandler: nil)
    }
}

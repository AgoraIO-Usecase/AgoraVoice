//
//  AboutViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/6/18.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

class DisclaimerViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Test_Product_Disclaimer")
        
        let para = NSMutableParagraphStyle()
        para.alignment = .natural
        para.firstLineHeadIndent = 20
        para.lineSpacing = 5
        para.lineBreakMode = .byCharWrapping
        para.paragraphSpacingBefore = 0
        
        let string = NSAttributedString(string: NSLocalizedString("Disclaimer_Detail"),
                                        attributes: [NSAttributedString.Key.paragraphStyle : para,
                                                     NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)])
        self.textView.attributedText = string
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
        guard let navigation = self.navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        navigation.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("About")
        privacyLabel.text = NSLocalizedString("Privacy_Item")
        disclaimerLabel.text = NSLocalizedString("Disclaimer")
        registerLabel.text = NSLocalizedString("Register_Agora_Account")
        versionLabel.text = NSLocalizedString("Version_Release_Date")
        sdkLabel.text = NSLocalizedString("RTC_SDK_Version")
        alLabel.text = NSLocalizedString("AV_Version")
        
        alValueLabel.text = "Ver \(AppAssistant.version)"
//        sdkValueLabel.text = "Ver \(Center.shared().centerProvideMediaHelper().rtcVersion)"
        
        releaseDateValueLabel.text = "2020.6.18"
        
        uploadLogLabel.text = NSLocalizedString("Upload_Log")
        
        agoraLabel.text = "www.agora.io"
        agoraLabel.font = UIFont.systemFont(ofSize: 10)
        agoraLabel.textColor = UIColor(hexString: "#686E78")
        agoraLabel.textAlignment = .center
        
        guard let navigation = self.navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        let w: CGFloat = 100
        let h: CGFloat = 15
        let x: CGFloat = (UIScreen.main.bounds.width - w) * 0.5
        let y: CGFloat = UIScreen.main.bounds.height -
            UIScreen.main.heightOfSafeAreaBottom -
            UIScreen.main.heightOfSafeAreaTop -
            navigation.navigationBar.bounds.height -
            15 - h
        
        agoraLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        view.addSubview(agoraLabel)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            var privacyURL: URL?
            if DeviceAssistant.Language.isChinese {
                privacyURL = URL(string: "https://www.agora.io/cn/privacy-policy/")
            } else {
                privacyURL = URL(string: "https://www.agora.io/en/privacy-policy/")
            }
            
            guard let url = privacyURL else {
                return
            }
            
            UIApplication.shared.openURL(url)
        case 1:
            break
        case 2:
            var privacyURL: URL?
            if DeviceAssistant.Language.isChinese {
                privacyURL = URL(string: "https://sso.agora.io/cn/signup/")
            } else {
                privacyURL = URL(string: "https://sso.agora.io/en/signup/")
            }
            
            guard let url = privacyURL else {
                return
            }
            
            UIApplication.shared.openURL(url)
        case 6:
            self.showHUD()
//            let log = Center.shared().centerProvideFilesGroup().logs
//            log.upload(success: { [weak self] (logId) in
//                self?.hiddenHUD()
//
//                let pasteboard = UIPasteboard.general
//                pasteboard.string = logId
//
//                let view = TextToast(frame: CGRect(x: 0, y: 200, width: 0, height: 44), filletRadius: 8)
//                view.text = "LogId 已经复制"
//                self?.showToastView(view, duration: 1)
//            }) { [weak self] (_) in
//                self?.hiddenHUD()
//            }
        default:
            break
        }
    }
}

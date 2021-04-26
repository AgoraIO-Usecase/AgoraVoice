//
//  AgoraVoiceViewControllers.swift
//  AgoraVoice
//
//  Created by Cavan on 2021/1/11.
//  Copyright © 2021 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import MBProgressHUD

// MARK: - MaskViewController
class MaskViewController: RxViewController, ShowAlertProtocol, PresentChildProtocol, ShowHudProtocol, ShowToastProtocol {
    var presentedChild = PublishRelay<UIViewController>()
    var dimissChild = PublishRelay<UIViewController>()
    
    weak var presentingChild: UIViewController? = nil
    
    var hud: MBProgressHUD?
    
    var toastView: ToastView?
    var toastWork: AfterWorker?
    
    private var maskTapBlock: (() -> Void)?
    
    private(set) var maskView: UIControl = {
        let view = UIControl()
        view.isSelected = false
        view.backgroundColor = UIColor(red: 0.0,
                                       green: 0.0,
                                       blue: 0.0,
                                       alpha: 0.7)
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        view.frame = CGRect(x: 0,
                            y: 0,
                            width: w,
                            height: h)
        view.addTarget(self,
                       action: #selector(tapMaskView(_:)),
                       for: .touchUpInside)
        view.isHidden = true
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toastView?.removeFromSuperview()
    }
    
    func showErrorToast(_ text: String) {
        let view = TagImageTextToast(frame: CGRect(x: 0,
                                                   y: 200,
                                                   width: 0,
                                                   height: 44),
                                     filletRadius: 8)
        view.tagImage = UIImage(named: "icon-red warning")
        view.text = text
        showToastView(view, duration: 3)
    }
    
    func showMaskView(color: UIColor = UIColor(red: 0.0,
                                               green: 0.0,
                                               blue: 0.0,
                                               alpha: 0.7), tap: (() -> Void)? = nil) {
        maskTapBlock = tap
        maskView.isHidden = false
        maskView.backgroundColor = color
        view.addSubview(maskView)
    }
    
    func hiddenMaskView() {
        if let presentingChild = presentingChild {
            self.dismissChild(presentingChild, animated: true)
            self.presentingChild = nil
        }
        
        maskTapBlock = nil
        maskView.isHidden = true
        maskView.removeFromSuperview()
    }
    
    @objc private func tapMaskView(_ mask: UIControl) {
        if let maskTapBlock = maskTapBlock {
            maskTapBlock()
        }
        
        hiddenMaskView()
    }
}

class MaskTabBarController: UITabBarController, ShowHudProtocol {
    var hud: MBProgressHUD?
}

class MaskTableViewController: RxTableViewController, ShowHudProtocol, ShowToastProtocol {
    var toastView: ToastView?
    
    var toastWork: AfterWorker?
    
    var hud: MBProgressHUD?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toastView?.removeFromSuperview()
    }
}

// MARK: - MaskViewController
class MaskLogViewController: MaskViewController, AGELogBase {
    var logTube: LogTube = Center.shared().centerProvideLogTubeHelper()
}

extension MaskLogViewController {
    func log(info: String,
             extra: String? = nil,
             funcName: String = #function) {
        let className = type(of: self)
        logOutputInfo(info, extra: extra,
                      className: className,
                      funcName: funcName)
    }
    
    func log(warning: String,
             extra: String? = nil,
             funcName: String = #function) {
        let className = type(of: self)
        logOutputWarning(warning, extra: extra,
                         className: className,
                         funcName: funcName)
    }
    
    func log(error: Error,
             extra: String? = nil,
             funcName: String = #function) {
        let className = type(of: self)
        logOutputError(error, extra: extra,
                       className: className,
                       funcName: funcName)
    }
}

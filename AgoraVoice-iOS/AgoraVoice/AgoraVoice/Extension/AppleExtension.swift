//
//  AppleExtension.swift
//
//  Created by CavanSu on 2020/2/19.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import MBProgressHUD

//MARK: - Block
typealias DicCompletion = (([String: Any]) -> Void)?
typealias AnyCompletion = ((Any?) -> Void)?
typealias StringCompletion = ((String) -> Void)?
typealias IntCompletion = ((Int) -> Void)?
typealias Completion = (() -> Void)?

typealias ExCompletion = (() throws -> Void)?
typealias DicEXCompletion = (([String: Any]) throws -> Void)?
typealias StringExCompletion = ((String) throws -> Void)?
typealias DataExCompletion = ((Data) throws -> Void)?

typealias ErrorCompletion = ((Error) -> Void)?
typealias ErrorBoolCompletion = ((Error) -> Bool)?

typealias AGEErrorCompletion = ((AGEError) -> Void)?

//MARK: - Dictinary
typealias StringAnyDic = [String: Any]

public func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

extension UIView {
    func cornerRadius(_ value: CGFloat) {
        self.layer.cornerRadius = value
    }
    
    var isCycle: Bool {
        get {
            return self.bounds.height == self.layer.cornerRadius * 2
        }
        set {
            guard self.bounds.height == self.bounds.width else {
                return
            }
            
            self.layer.cornerRadius = self.bounds.height * 0.5
        }
    }
    
    @discardableResult func containUnderline(_ color: UIColor,
                                             x: CGFloat? = nil,
                                             width: CGFloat? = nil,
                                             height: CGFloat? = nil) -> CALayer {
        let underline = CALayer()
        underline.backgroundColor = color.cgColor
        
        var tX: CGFloat = 0.0
        var h: CGFloat = 1.0
        var w: CGFloat = self.bounds.width
        
        if let x = x {
            tX = x
        }
        
        if let height = height {
            h = height
        }
        
        if let width = width {
            w = width
        }
        
        underline.frame = CGRect(x: tX,
                                 y: self.bounds.height - h,
                                 width: w,
                                 height: h)
        
        self.layer.addSublayer(underline)
        return underline
    }
}

extension String {
    func size(font: UIFont, drawRange size: CGSize) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect = self.boundingRect(with: size,
                                     options: option,
                                     attributes: attributes,
                                     context: nil)
        return rect.size
    }
}

extension UIScreen {
    var isNotch: Bool {
        if #available(iOS 11.0, *),
           let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets  {
            return safeAreaInsets.left > 0.0 ||
                safeAreaInsets.top > 0.0 ||
                safeAreaInsets.right > 0.0 ||
                safeAreaInsets.bottom > 0.0
        } else {
            return false
        }
    }
    
    var heightOfSafeAreaTop: CGFloat {
        if #available(iOS 11.0, *),
           let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets  {
            return safeAreaInsets.top
        } else {
            return 20
        }
    }
    
    var heightOfSafeAreaBottom: CGFloat {
        if #available(iOS 11.0, *),
           let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets  {
            return safeAreaInsets.bottom
        } else {
            return 0
        }
    }
}

extension TimeInterval {
    static let animation: TimeInterval = 0.3
}

extension UIStoryboard {
    static func initViewController<T: Any>(of id: String,
                                           class: T.Type,
                                           on stroyName: String = "Main") -> T {
        let storyboard = UIStoryboard(name: stroyName, bundle: Bundle.main)
        let identifier = id
        let vc = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return vc
    }
}

extension NotificationCenter {
    func observerKeyboard(listening: (((endFrame: CGRect, duration: Double)) -> Void)? = nil) {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil,
                                               queue: nil) { (notify) in
            guard let userInfo = notify.userInfo else {
                return
            }
            
            let endKeyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            let endKeyboardFrame = endKeyboardFrameValue?.cgRectValue
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
            let duration = durationValue?.doubleValue
            
            if let listening = listening {
                let callbackParameter = (endFrame: endKeyboardFrame!, duration: duration!)
                listening(callbackParameter)
            }
        }
    }
}

protocol PresentChildProtocol where Self: UIViewController {
    var presentingChild: UIViewController? {get set}
    var presentedChild: PublishRelay<UIViewController> {get set}
    var dimissChild: PublishRelay<UIViewController> {get set}
    
    func presentChild(_ viewController: UIViewController,
                      animated flag: Bool,
                      presentedFrame: CGRect)
    func dismissChild(_ viewController: UIViewController,
                      animated flag: Bool)
}

extension PresentChildProtocol {
    func presentChild(_ viewController: UIViewController,
                      animated flag: Bool,
                      presentedFrame: CGRect) {
        if let child = presentingChild {
            dismissChild(child, animated: false)
        }
        
        self.presentingChild = viewController
        self.view.addSubview(viewController.view)
        
        let originRect = CGRect(x: presentedFrame.origin.x,
                                y: UIScreen.main.bounds.height,
                                width: presentedFrame.width,
                                height: presentedFrame.height)
        viewController.view.frame = originRect
        
        if flag {
            UIView.animate(withDuration: TimeInterval.animation) {
                viewController.view.frame = presentedFrame
            }
        } else {
            viewController.view.frame = presentedFrame
        }
        
        self.addChild(viewController)
        viewController.didMove(toParent: self)
        
        presentedChild.accept(viewController)
    }
    
    func dismissChild(_ viewController: UIViewController,
                      animated flag: Bool) {
        var endRect = viewController.view.frame
        endRect.origin.y = UIScreen.main.bounds.height
        
        viewController.willMove(toParent: nil)
        
        if flag {
            UIView.animate(withDuration: TimeInterval.animation, animations: {
                viewController.view.frame = endRect
            }) { (finish) in
                guard finish else {
                    return
                }
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
            }
        } else {
            viewController.view.frame = endRect
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
    }
}

protocol ShowAlertProtocol where Self: UIViewController {
    func showAlert(_ title: String?,
                   message: String?,
                   action: String,
                   handler: ((UIAlertAction) -> Void)?)
    func showAlert(_ title: String?,
                   message: String?,
                   preferredStyle: UIAlertController.Style,
                   action1: String,
                   action2: String,
                   handler1: ((UIAlertAction) -> Void)?,
                   handler2: ((UIAlertAction) -> Void)?)
    func showAlert(_ title: String?,
                   message: String?,
                   preferredStyle: UIAlertController.Style,
                   actions: [UIAlertAction]?,
                   completion: Completion)
}

extension ShowAlertProtocol {
    func showAlert(_ title: String? = nil,
                   message: String? = nil,
                   action: String = "OK",
                   handler: ((UIAlertAction) -> Void)? = nil) {
        let action = UIAlertAction(title: action,
                                   style: .default,
                                   handler: handler)
        showAlert(title,
                  message: message,
                  preferredStyle: .alert,
                  actions: [action],
                  completion: nil)
    }
    
    func showAlert(_ title: String? = nil,
                   message: String? = nil,
                   preferredStyle: UIAlertController.Style = .alert,
                   action1: String,
                   action2: String,
                   handler1: ((UIAlertAction) -> Void)? = nil,
                   handler2: ((UIAlertAction) -> Void)? = nil) {
        let act1 = UIAlertAction(title: action1,
                                 style: .default,
                                 handler: handler1)
        let act2 = UIAlertAction(title: action2,
                                 style: .default,
                                 handler: handler2)
        showAlert(title,
                  message: message,
                  preferredStyle: preferredStyle,
                  actions: [act1, act2],
                  completion: nil)
    }
    
    func showAlert(_ title: String? = nil,
                   message: String? = nil,
                   preferredStyle: UIAlertController.Style = .alert,
                   actions: [UIAlertAction]? = nil,
                   completion: Completion) {
        view.endEditing(true)
        
        if let vc = self.presentedViewController,
            let alert = vc as? UIAlertController {
            alert.dismiss(animated: false, completion: nil)
        }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: preferredStyle)
        
        var tActions: [UIAlertAction]
        
        if let actions = actions {
            tActions = actions
        } else {
            tActions = [UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: nil)]
        }
        
        for item in tActions {
            alert.addAction(item)
        }
        
        present(alert,
                animated: true,
                completion: completion)
    }
}

protocol ShowHudProtocol where Self: UIViewController {
    var hud: MBProgressHUD? {get set}
    func isShowingHUD() -> Bool
    func showHUD()
    func hiddenHUD(animated: Bool)
}

extension ShowHudProtocol {
    func isShowingHUD() -> Bool {
        if let _ = self.hud {
            return true
        } else {
            return false
        }
    }
    
    func showHUD() {
        guard self.hud == nil else {
            return
        }
        
        self.hud = MBProgressHUD.showAdded(to: self.view,
                                           animated: true)
        self.hud?.show(animated: true)
    }
    
    func hiddenHUD(animated: Bool = true) {
        self.hud?.hide(animated: animated)
        self.hud = nil
    }
}

protocol ShowToastProtocol where Self: UIViewController {
    var toastView: ToastView? {get set}
    var toastWork: AfterWorker? {get set}
    
    func showToastView(_ view: ToastView,
                       duration: TimeInterval,
                       completion: Completion )
}

extension ShowToastProtocol {
    func showToastView(_ view: ToastView,
                       duration: TimeInterval = TimeInterval.animation,
                       completion: Completion = nil) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        if let worker = toastWork {
            self.toastView?.removeFromSuperview()
            worker.cancel()
        }
        
        toastWork = AfterWorker()
        
        self.toastView = view
        
        window.addSubview(view)
        
        toastWork?.perform(after: duration,
                           on: DispatchQueue.main, { [weak self] in
            self?.toastView?.removeFromSuperview()
            if let completion = completion {
                completion()
            }
        })
    }
    
    func showTextToast(text: String,
                       duration: TimeInterval = 3,
                       completion: Completion = nil) {
        let frame = CGRect(x: 0,
                           y: 200,
                           width: 0,
                           height: 44)
        let view = TextToast(frame: frame, filletRadius: 8)
        view.text = text
        self.showToastView(view,
                           duration: duration,
                           completion: completion)
    }
}

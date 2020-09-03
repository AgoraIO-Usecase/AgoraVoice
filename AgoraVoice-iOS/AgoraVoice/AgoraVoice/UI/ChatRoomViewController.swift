//
//  ChatRoomViewController.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/3.
//  Copyright © 2020 CavanSu. All rights reserved.
//

import UIKit

class ChatRoomViewController: MaskViewController, LiveViewController {

    // LiveViewController
    var tintColor = UIColor(red: 0,
                            green: 0,
                            blue: 0,
                            alpha: 0.4)
    
    // ViewController
    var giftAudienceVC: GiftAudienceViewController?
    var bottomToolsVC: BottomToolsViewController?
    var chatVC: ChatViewController?
    
    // View
    @IBOutlet weak var personCountView: RemindIconTextView!
    
    internal lazy var chatInputView: ChatInputView = {
        let chatHeight: CGFloat = 50.0
        let frame = CGRect(x: 0,
                           y: UIScreen.main.bounds.height,
                           width: UIScreen.main.bounds.width,
                           height: chatHeight)
        let view = ChatInputView(frame: frame)
        view.isHidden = true
        return view
    }()
    
    // ViewModel
    var userListVM: LiveUserListVM!
    var giftVM: GiftVM!
    var musicVM = MusicVM()
    var chatVM = ChatVM()
    var deviceVM = MediaDeviceVM()
    var monitor = NetworkMonitor(host: "www.apple.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

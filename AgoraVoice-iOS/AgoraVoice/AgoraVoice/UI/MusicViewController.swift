//
//  MusicViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/31.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class MusicCell: UITableViewCell {
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    
    var isPlaying: Bool = false {
        didSet {
            self.contentView.backgroundColor = isPlaying ? UIColor(hexString: "#0088EB") : UIColor(hexString: "#161D27")
            self.nameLabel.textColor = isPlaying ? UIColor(hexString: "#FFFFFF") : UIColor(hexString: "#EEEEEE")
            self.singerLabel.textColor = isPlaying ? UIColor(hexString: "#FFFFFF") : UIColor(hexString: "#9BA2AB")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class MusicViewController: RxTableViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var musicLinkLabel: UILabel!
    
    let list = BehaviorRelay(value: [Music]())
    
    var playingImage = UIImage(named: "icon-pause")
    var pauseImage = UIImage(named: "icon-play")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = NSLocalizedString("BGM")
        
        self.tableView.rowHeight = 58.0
        
        let music = "Music: "
        let link = "https://www.bensound.com"
        
        let content = (music + link) as NSString
        let attrContent = NSMutableAttributedString(string: (content as String))
        
        attrContent.addAttributes([.foregroundColor: UIColor(hexString: "#999999"),
                                   .font: UIFont.systemFont(ofSize: 12)],
                                  range: NSRange(location: 0, length: music.count))
        
        attrContent.addAttributes([.foregroundColor: UIColor(hexString: "#0088EB"),
                                   .font: UIFont.systemFont(ofSize: 12)],
                                  range: NSRange(location: music.count, length: link.count))
        
        musicLinkLabel.attributedText = attrContent
        musicLinkLabel.backgroundColor = UIColor(hexString: "#0A0F17")
        musicLinkLabel.cornerRadius(4)
        musicLinkLabel.layer.masksToBounds = true
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        list.bind(to: tableView.rx.items(cellIdentifier: "MusicCell",
                                         cellType: MusicCell.self)) { [unowned self] (index, music, cell) in
                                            cell.tagImageView.image = music.isPlaying ? self.playingImage : self.pauseImage
                                            cell.isPlaying = music.isPlaying
                                            cell.nameLabel.text = music.name
                                            cell.singerLabel.text = music.singer
        }.disposed(by: bag)
    }
}

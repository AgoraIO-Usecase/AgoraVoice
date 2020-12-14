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
    @IBOutlet weak var volumeSlider: UISlider!
    
    var playingImage = UIImage(named: "icon-pause")
    var pauseImage = UIImage(named: "icon-play")
    var musicVM: MusicVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("BGM")
        volumeSlider.setThumbImage(UIImage(named: "icon-volume handle"), for: .normal)
        tableView.rowHeight = 58.0
        
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
        
        musicVM.list.bind(to: tableView.rx.items(cellIdentifier: "MusicCell",
                                         cellType: MusicCell.self)) { [unowned self] (index, music, cell) in
                                            cell.tagImageView.image = music.isPlaying ? self.playingImage : self.pauseImage
                                            cell.isPlaying = music.isPlaying
                                            cell.nameLabel.text = music.name
                                            cell.singerLabel.text = music.singer
        }.disposed(by: bag)
        
        tableView.rx.modelSelected(Music.self).subscribe(onNext: { [unowned self] (music) in
            if let last = self.musicVM.lastMusic {
                
                if last == music {
                    if music.isPlaying {
                        self.musicVM.pause(music: music)
                    } else {
                        self.musicVM.resume(music: music)
                    }
                } else {
                    self.musicVM.stop()
                    self.musicVM.play(music: music)
                }
            } else {
                self.musicVM.play(music: music)
            }
        }).disposed(by: bag)
        
        musicVM.volume.map { (volume) -> Float in
            return Float(volume)
        }.bind(to: volumeSlider.rx.value).disposed(by: bag)
        
        volumeSlider.rx.value.map { (volume) -> UInt in
            return UInt(volume)
        }.bind(to: musicVM.volume).disposed(by: bag)
    }
}

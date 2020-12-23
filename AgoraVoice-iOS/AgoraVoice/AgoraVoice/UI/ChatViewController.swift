//
//  ChatViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/25.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class ChatCell: UITableViewCell {
    fileprivate var fillet = FilletView(frame: CGRect.zero, filletRadius: 19.0)
    fileprivate var tagImageView = UIImageView(frame: CGRect.zero)
    var contentLabel = UILabel(frame: CGRect.zero)
    var contentWidth: CGFloat = 0
    
    var contentImage: UIImage? {
        didSet {
            tagImageView.image = contentImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        fillet.backgroundColor = .clear
        self.addSubview(fillet)
        
        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.backgroundColor = .clear
        self.addSubview(contentLabel)
        
        self.tagImageView.contentMode = .scaleAspectFit
        self.addSubview(tagImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let leftSpace: CGFloat = 15
        let topSpace: CGFloat = 5
        
        let labelTopSpace: CGFloat = 5 + topSpace
        
        contentLabel.frame = CGRect(x: (leftSpace * 2),
                                    y: labelTopSpace,
                                    width: contentWidth,
                                    height: self.bounds.height - (labelTopSpace * 2))
        
        if let _ = contentImage {
            tagImageView.isHidden = false
            let wh: CGFloat = 50.0
            let y = labelTopSpace - (wh - contentLabel.bounds.height) * 0.5
            tagImageView.frame = CGRect(x: contentLabel.frame.maxX + 5,
                                        y: y,
                                        width: wh,
                                        height: wh)
            
            fillet.frame = CGRect(x: leftSpace,
                                  y: topSpace,
                                  width: tagImageView.frame.maxX,
                                  height: self.bounds.height - 10)
        } else {
            tagImageView.isHidden = true
            fillet.frame = CGRect(x: leftSpace,
                                  y: topSpace,
                                  width: contentWidth + (leftSpace * 2),
                                  height: self.bounds.height - (topSpace * 2))
        }
    }
}

class ChatViewController: UITableViewController {
    private(set) var list = BehaviorRelay(value: [Chat]())
    private let bag = DisposeBag()
    
    var cellColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    var contentColor: UIColor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tableView.backgroundColor = .clear
        
        list.subscribe(onNext: { [unowned self] (list) in
            self.tableView.reloadData()
            
            guard list.count > 0 else {
                return
            }
            
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                       at: .bottom,
                                       animated: true)
        }).disposed(by: bag)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.value.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chat = list.value[indexPath.row]
        return chat.textSize.height + (5 * 2) + (10 * 2)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        let chat = list.value[indexPath.row]
        cell.contentLabel.attributedText = chat.content
        cell.fillet.insideBackgroundColor = cellColor
        cell.contentWidth = chat.textSize.width
        cell.contentImage = chat.image
        
        if let contentColor = contentColor {
            cell.contentLabel.textColor = contentColor
        }
        return cell
    }
}

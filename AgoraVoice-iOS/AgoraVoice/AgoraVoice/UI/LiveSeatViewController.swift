//
//  LiveSeatViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/23.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

struct LiveSeatAction {
    var seat: LiveSeat
    var command: LiveSeatView.Command
}

struct LiveSeatCommands {
    var seat: LiveSeat
    var commands: [LiveSeatView.Command]
}

class SeatButton: UIButton {
    var type: SeatState = .empty {
        didSet {
            switch type {
            case .empty:              setImage(UIImage(named: "icon-invite")!, for: .normal)
            case .close:              setImage(UIImage(named: "icon-lock")!, for: .normal)
            case .normal(let stream): setImage(stream.owner.info.image, for: .normal)
            }
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initViews()
    }
    
    private func initViews() {
        type = .empty
        backgroundColor = UIColor(hexString: "#000000-0.6")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isCycle = true
    }
}

class LiveSeatView: RxView {
    enum Command {
        // 禁麦， 解禁， 封麦，下麦， 解封， 邀请，
        case ban, unban, close, forceBroadcasterEnd, release, invitation
        // 申请成为主播， 主播下麦
        case application, endBroadcasting
        
        var description: String {
            switch self {
            case .ban:                  return NSLocalizedString("Seat_Ban")
            case .unban:                return NSLocalizedString("Seat_Unban")
            case .forceBroadcasterEnd:  return NSLocalizedString("End_Broadcasting")
            case .close:                return NSLocalizedString("Seat_Close")
            case .release:              return NSLocalizedString("Seat_Release")
            case .invitation:           return NSLocalizedString("Invitation")
            case .application:          return NSLocalizedString("Application_Of_Broadcasting")
            case .endBroadcasting:      return NSLocalizedString("End_Broadcasting")
            }
        }
    }
    
    fileprivate var commandButton = SeatButton(frame: CGRect.zero)
    fileprivate var commands = BehaviorRelay(value: [Command]())
    
    private(set) var index: Int = 0
    
    let audioSilenceTag = UIImageView()
    
    var perspective: LiveRoleType = .audience
    
    init(index: Int, frame: CGRect) {
        super.init(frame: frame)
        self.index = index
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: CGRect.zero)
        index = 0
        initViews()
    }
    
    func initViews() {
        backgroundColor = .clear
        
        commandButton.rx.tap.subscribe(onNext: { [unowned self] in
            switch (self.commandButton.type, self.perspective) {
            // owner
            case (.empty, .owner):
                self.commands.accept([.invitation, .close])
            case (.normal(let stream), .owner):
                if stream.hasAudio {
                    self.commands.accept([.ban, .forceBroadcasterEnd, .close])
                } else {
                    self.commands.accept([.unban, .forceBroadcasterEnd, .close])
                }
            case (.close, .owner):
                self.commands.accept([.release])
            // broadcaster
            case (.empty, .broadcaster):
                break
            case (.normal(let stream), .broadcaster):
                guard stream.owner.info == Center.shared().centerProvideLocalUser().info.value else {
                    return
                }
                self.commands.accept([.endBroadcasting])
            case (.close, .broadcaster):
                break
            // audience
            case (.empty, .audience):
                self.commands.accept([.application])
            case (.normal, .audience):
                break
            case (.close, .audience):
                break
            }
        }).disposed(by: bag)
        
        addSubview(commandButton)
        
        audioSilenceTag.image = UIImage(named: "icon-Mic-off-tag")
        audioSilenceTag.isHidden = true
        self.addSubview(audioSilenceTag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        commandButton.frame = bounds
        
        audioSilenceTag.frame = CGRect(x: self.bounds.width - 20,
                                       y: self.bounds.height - 20,
                                       width: 20,
                                       height: 20)
    }
}

class LiveSeatViewController: MaskViewController {
    private let seatCount = 8
    
    private lazy var seatViews: [LiveSeatView] = {
        var temp = [LiveSeatView]()
        for i in 0 ..< seatCount {
            let seatView = LiveSeatView(index: i,
                                        frame: CGRect.zero)
            
            seatView.commands.filter { (commands) -> Bool in
                return commands.isEmpty ? false : true
            }.subscribe(onNext: { [unowned self] (commands) in
                let seat = self.seats.value[seatView.index]
                let seatCommands = LiveSeatCommands(seat: seat, commands: commands)
                self.seatCommands.accept(seatCommands)
            }).disposed(by: bag)
            
            temp.append(seatView)
            view.addSubview(seatView)
        }
        return temp
    }()
    
    lazy var seats: BehaviorRelay<[LiveSeat]> = {
        var temp = [LiveSeat]()
        for i in 0 ..< self.seatCount {
            let seat = LiveSeat(index: i, state: .empty)
            temp.append(seat)
        }
        
        return BehaviorRelay(value: temp)
    }()
    
    let seatCommands = PublishRelay<LiveSeatCommands>()
    let perspective = BehaviorRelay<LiveRoleType>(value: .audience)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perspective.subscribe(onNext: { [unowned self] (type) in
            let value = self.seats.value
            self.seats.accept(value)
        }).disposed(by: bag)
        
        seats.subscribe(onNext: { (seats) in
            self.updateSeats(seats)
        }).disposed(by: bag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .clear
        
        let space: CGFloat = 26
        let width: CGFloat = (UIScreen.main.bounds.width - (space * 5)) / 4
        let height: CGFloat = width
        let rowCount: Int = 4
        
        for (index, item) in seatViews.enumerated() {
            let x = space + CGFloat(index % rowCount) * (space + width)
            let y = CGFloat(index / rowCount) * (height + space)
            item.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
}

private extension LiveSeatViewController {
    func updateSeats(_ seats: [LiveSeat]) {
        guard seats.count == seatCount else {
            return
        }
        
        for (index, item) in seats.enumerated() {
            let view = seatViews[index]
            view.perspective = self.perspective.value
            view.commandButton.type = item.state
            
            if let stream = item.state.stream {
                view.audioSilenceTag.isHidden = stream.hasAudio
            } else {
                view.audioSilenceTag.isHidden = true
            }
        }
    }
}

class CommandCell: UICollectionViewCell {
    private lazy var underLine: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(hexString: "#0C121B").cgColor
        self.contentView.layer.addSublayer(layer)
        return layer
    }()
    
    var needUnderLine: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hexString: "#161D27")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor(hexString: "#161D27")
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor(hexString: "#EEEEEE")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        self.contentView.addSubview(label)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = CGRect(x: 0,
                                       y: 0,
                                       width: self.bounds.width,
                                       height: self.bounds.height)
        
        if needUnderLine {
            self.underLine.frame = CGRect(x: 5,
                                          y: self.bounds.height - 1,
                                          width: self.bounds.width - 10,
                                          height: 1)
        } else {
            self.underLine.frame = CGRect.zero
        }
    }
}

class CommandViewController: RxCollectionViewController {
    let commands = BehaviorRelay(value: [LiveSeatView.Command]())
    let selectedCommand = PublishRelay<LiveSeatView.Command>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView.isScrollEnabled = false
        collectionView.register(CommandCell.self, forCellWithReuseIdentifier: "CommandCell")
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.backgroundColor = UIColor(hexString: "#161D27")
        
        commands.bind(to: collectionView.rx.items(cellIdentifier: "CommandCell",
                                                  cellType: CommandCell.self)) { (index, command, cell) in
                                                    cell.titleLabel.text = command.description
        }.disposed(by: bag)
        
        collectionView.rx
            .modelSelected(LiveSeatView.Command.self)
            .subscribe(onNext: { [unowned self] (command) in
                self.selectedCommand.accept(command)
        }).disposed(by: bag)
    }
}

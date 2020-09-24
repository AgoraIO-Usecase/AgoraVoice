//
//  TimestampModel.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/7/30.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

protocol TimestampModel {
    var id: String {get set}
    var timestamp: TimeInterval {get set}
}

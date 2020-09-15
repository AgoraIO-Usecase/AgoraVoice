//
//  CustomObserver.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/8/11.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class CustomObserver: RxObject {
    var message = PublishRelay<[String : Any]>()
}

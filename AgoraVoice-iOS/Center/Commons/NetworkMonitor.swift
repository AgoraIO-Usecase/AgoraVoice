//
//  NetworkMonitor.swift
//  AGECenter
//
//  Created by CavanSu on 2019/7/11.
//  Copyright © 2019 Agora. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import Alamofire

typealias ReachabilityStatus = NetworkReachabilityManager.NetworkReachabilityStatus

class NetworkMonitor: NSObject {
    private lazy var netListener = NetworkReachabilityManager(host: self.host)
    private let host: String
    
    var connect = PublishRelay<ReachabilityStatus>()
    
    init(host: String) {
        self.host = host
    }
}

extension ReachabilityStatus: CustomStringConvertible {
    public var description: String {
        return cusDescription()
    }
    
    func cusDescription() -> String {
        switch self {
        case .unknown:               return "unknown"
        case .notReachable:          return "notReachable"
        case .reachable(let type):   return  ((type == .ethernetOrWiFi ? "ethernetOrWiFi" : "wwan"))
        }
    }
}

extension NetworkMonitor {
    func action(_ action: AGESwitch) {
        guard let netListener = self.netListener else {
            return
        }

        switch action {
        case .on:
            netListener.listener = { [unowned self] status in
                self.connect.accept(status)
            }
            netListener.startListening()
        case .off:
            netListener.stopListening()
        }
    }
}

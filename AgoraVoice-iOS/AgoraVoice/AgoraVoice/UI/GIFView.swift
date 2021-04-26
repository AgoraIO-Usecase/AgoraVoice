//
//  GIFView.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/4/24.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import FLAnimatedImage

class GIFView: FLAnimatedImageView {
    enum State {
        case animating, stop
    }
    
    private var gifImage: Data?
    
    private var currentRepeatCount = 0
    private var state: State = .stop
    
    func stopAnimationg(releaseImage: Bool = true) {
        state = .stop
        self.stopAnimating()
        if releaseImage {
            self.image = nil
        }
        currentRepeatCount = 0
    }
    
    init(frame: CGRect,
         gif: Data) {
        super.init(frame: frame)
        self.gifImage = gif
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func startAnimating(of data: Data,
                        repeatCount: Int = 1,
                        completion: Completion = nil) {
        guard state == .stop else {
            return
        }
        state = .animating
        stopAnimationg()
        gifImage = data
        let image = FLAnimatedImage(animatedGIFData: data)
        animatedImage = image
        loopCompletionBlock = { [weak self] (loopCountRemaining) in
            self?.currentRepeatCount += 1
            
            guard self?.currentRepeatCount == repeatCount else {
                return
            }
            
            self?.stopAnimationg()
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    func startAnimating(repeatCount: Int = 1,
                        completion: Completion = nil) {
        guard let data = gifImage,
              state == .stop else {
            return
        }
        startAnimating(of: data,
                       repeatCount: repeatCount,
                       completion: completion)
    }
}

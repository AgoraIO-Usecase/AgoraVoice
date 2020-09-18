//
//  GifViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/4/9.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import FLAnimatedImage

class GIFViewController: RxViewController {
    @IBOutlet weak var imageView: FLAnimatedImageView!
    
    private var currentRepeatCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.0,
                                            green: 0.0,
                                            blue: 0.0,
                                            alpha: 0.7)
        self.imageView.backgroundColor = UIColor.clear
    }
    
    func stopAnimationg() {
        self.imageView.stopAnimating()
        self.imageView.image = nil
        self.currentRepeatCount = 0
    }
    
    func startAnimating(of data: Data, repeatCount: Int = 1, completion: Completion = nil) {
        self.stopAnimationg()
        
        let image = FLAnimatedImage(animatedGIFData: data)
        self.imageView.animatedImage = image
        self.imageView.loopCompletionBlock = { [weak self] (loopCountRemaining) in
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
}

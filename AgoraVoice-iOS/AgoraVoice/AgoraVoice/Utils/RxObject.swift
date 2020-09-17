//
//  RxObject.swift
//
//  Created by CavanSu on 2020/7/20.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift

class RxObject: NSObject {
    let bag = DisposeBag()
}

class RxView: UIView {
    let bag = DisposeBag()
}

class RxViewController: UIViewController {
    let bag = DisposeBag()
}

class RxCollectionViewCell: UICollectionViewCell {
    let bag = DisposeBag()
}

class RxCollectionViewController: UICollectionViewController {
    let bag = DisposeBag()
}

class RxTableViewController: UITableViewController {
    let bag = DisposeBag()
}

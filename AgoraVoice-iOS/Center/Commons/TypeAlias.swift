//
//  TypeAlias.swift
//  AgoraPremium
//
//  Created by GongYuhua on 4/11/16.
//  Copyright © 2016 Agora. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

//MARK: - Image
#if os(iOS)
public typealias AGEImage = UIImage
#else
public typealias AGEImage = NSImage
#endif

//MARK: - View
#if os(iOS)
public typealias ALView = UIView
#else
public typealias ALView = NSView
#endif

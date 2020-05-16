//
//  GifAnimationQuality.swift
//  JellyGif
//
//  Created by Linh Ta on 5/15/20.
//  Copyright © 2020 Linh Ta. All rights reserved.
//

import UIKit

///Type used to represent number of frames per second of a GIF
public enum GifAnimationQuality {
    case best
    case average
    case acceptable
    case custom(Int)
    
    public var preferredFramesPerSecond: Int {
        switch self {
        case .best:
            return 0
        case .average:
            return 30
        case .acceptable:
            return 15
        case .custom(let rate):
            return rate
        }
    }
}

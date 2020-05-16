//
//  GifPixelSize.swift
//  JellyGif
//
//  Created by Linh Ta on 5/15/20.
//  Copyright © 2020 Linh Ta. All rights reserved.
//

import UIKit

///Type used to represent the maximum size of a GIF. The closer it is to the actual size of the image holder the smaller the memory footprint and the better the CPU performance
public enum GifPixelSize {
    case original
    case custom(CGFloat)
}

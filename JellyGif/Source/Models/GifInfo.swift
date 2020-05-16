//
//  GifInfo.swift
//  JellyGif
//
//  Created by Linh Ta on 5/15/20.
//  Copyright © 2020 Linh Ta. All rights reserved.
//

import UIKit

///Type used to represent the source of a GIF
public enum GifInfo {
    case name(String)
    case localPath(URL)
    case data(Data)
}

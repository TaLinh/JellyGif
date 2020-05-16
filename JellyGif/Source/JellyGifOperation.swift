//
//  JellyGifOperation.swift
//  JellyGif
//
//  Created by Linh Ta on 5/15/20.
//  Copyright © 2020 Linh Ta. All rights reserved.
//

import UIKit

///An operation object used to prepare information needed to start GIF animation
public class JellyGifOperation: Operation {
    public let inputInfo: GifInfo
    public let pixelSize: GifPixelSize
    public var completionHandler: ([UIImage], [CFTimeInterval]) -> Void

    public init(info: GifInfo, pixelSize: GifPixelSize,
         completion: @escaping ([UIImage], [CFTimeInterval]) -> Void) {
        self.inputInfo = info
        self.pixelSize = pixelSize
        self.completionHandler = completion
        super.init()
    }
    
    override public func main() {
        guard isCancelled == false else { return }
        
        let imageSource = CGImageSource.sourceFromInfo(inputInfo)
        let frames = imageSource?.frameDurations ?? []
        var images: [UIImage] = []
        
        switch pixelSize {
        case .original:
            images = imageSource?.fullSizeImages ?? []
        case .custom(let size):
            images = imageSource?.imagesWithMaxSize(size) ?? []
        }
        
        DispatchQueue.main.async { [weak self] in
            guard self?.isCancelled == false else { return }
            self?.completionHandler(images, frames)
        }
    }
}

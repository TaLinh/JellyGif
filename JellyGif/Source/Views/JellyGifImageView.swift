//
//  JellyGifImageView.swift
//  JellyGif
//
//  Created by Linh Ta on 5/16/20.
//  Copyright © 2020 Linh Ta. All rights reserved.
//

import UIKit

///An object that displays a GIF in your interface
public class JellyGifImageView: UIImageView, JellyGifAnimatorDelegate {
    public var animator: JellyGifAnimator?
    
    ///Start animating with GifInfo
    ///- Parameters:
    ///     - info: Required information to generate a GIF
    ///     - pixelSize: The maximum size of a GIF. The closer a this property is to the actual size of the imageView (or the image holder) the smaller the memory footprint and the better the CPU performance
    ///     - animationQuality: Number of frames per second
    public func startGif(with info: GifInfo, pixelSize: GifPixelSize = .original, animationQuality: GifAnimationQuality = .best) {
        animator?.stopPreparingAnimation()
        animator = nil
        
        animator = JellyGifAnimator(imageInfo: info, pixelSize: pixelSize, animationQuality: animationQuality)
        animator?.delegate = self
        animator?.prepareAnimation()
    }
    
    public func resumeGif() {
        animator?.startAnimation()
    }
    
    public func pauseGif() {
        animator?.pauseAnimation()
    }
}

public extension JellyGifImageView {
    func gifAnimatorIsReady(_ sender: JellyGifAnimator) {
        sender.startAnimation()
    }
    
    func imageViewForAnimator(_ sender: JellyGifAnimator) -> UIImageView? {
        return self
    }
}

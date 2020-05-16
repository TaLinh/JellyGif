//
//  JellyGifAnimator.swift
//  JellyGif
//
//  Created by Linh Ta on 5/1/20.
//  Copyright © 2020 Linh Ta. All rights reserved.
//

import UIKit

///Methods for managing JellyGifAnimator
public protocol JellyGifAnimatorDelegate: class {
    func gifAnimatorIsReady(_ sender: JellyGifAnimator)
    
    ///Registers an UIImageView to display GIF frames
    func imageViewForAnimator(_ sender: JellyGifAnimator) -> UIImageView?
    func gifAnimatorDidChangeImage(_ image: UIImage, sender: JellyGifAnimator)
}

public extension JellyGifAnimatorDelegate {
    func gifAnimatorIsReady(_ sender: JellyGifAnimator) { }
    func imageViewForAnimator(_ sender: JellyGifAnimator) -> UIImageView? { return nil }
    func gifAnimatorDidChangeImage(_ image: UIImage, sender: JellyGifAnimator) { }
}

///An object that manages the preparation and animation of a GIF
public class JellyGifAnimator {
    public static var gifQueue = DispatchQueue(label: "custom.jelly.gif.animator.queue")
    
    public weak var delegate: JellyGifAnimatorDelegate?
    
    ///Required information to generate a GIF
    public let imageInfo: GifInfo
    
    ///The maximum size of a GIF. The closer a this property is to the actual size of the image holder the smaller the memory footprint and the better the CPU performance
    public let preferredPixelSize: GifPixelSize
    
    ///Number of frames per second
    public let preferredAnimationQuality: GifAnimationQuality

    ///The CADisplayLink used to animate the GIF
    public private(set) lazy var displayLink: CADisplayLink = {
        let displayLinkProxy = DisplayLinkProxy(animator: self)
        let displayLink = CADisplayLink(target: displayLinkProxy, selector: #selector(DisplayLinkProxy.animateGif(displayLink:)))
        displayLink.preferredFramesPerSecond = preferredAnimationQuality.preferredFramesPerSecond
        displayLink.add(to: .main, forMode: .common)
        return displayLink
    }()
    
    //Property used to save CPU power
    ///The frames of a GIF
    public private(set) var images: [UIImage] = []
    
    ///The lengths of each frame in a GIF
    public private(set) var frameDurations: [CFTimeInterval] = []
    
    ///An operation used to prepare information needed to start GIF animation
    public private(set) var preparingOperation: JellyGifOperation?
    
    //Property used to calculate the current frame of a GIF
    private var currentIndex = 0
    private var currentDuration: Double = 0
    private var oneCycleDuration: CFTimeInterval = 0
    
    ///An array of time mark to start the next frame
    private var framesStartDurations: [CFTimeInterval] = []
    
    ///The first frame of a GIF that can be used as a placeholder when the animator is preparing the GIF frames
    public var placeholder: UIImage? {
        guard let imageSource = CGImageSource.sourceFromInfo(imageInfo) else { return nil }
        guard CGImageSourceGetCount(imageSource) > 0 else { return nil }
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else { return nil}
        return UIImage(cgImage: cgImage)
    }
    
    ///A Boolean value indicating whether the GIF is being animated
    public var isStarted: Bool {
        return isReady && !displayLink.isPaused
    }
    
    ///A Boolean value indicating whether the GIF generated from the input GifInfo has one or more images
    public var hasImage: Bool {
        guard let imageSource = CGImageSource.sourceFromInfo(imageInfo) else { return false }
        return CGImageSourceGetCount(imageSource) > 0
    }
    
    ///A Boolean value indicating whether JellyGifAnimator has finished its preparation process and the GIF can be animated
    public var isReady: Bool {
        return !images.isEmpty && images.count == frameDurations.count
    }
    
    ///Initializes and returns a newly allocated JellyGifAnimator with the specified properties
    public init(imageInfo: GifInfo,
         pixelSize: GifPixelSize = .original,
         animationQuality: GifAnimationQuality = .best) {
        self.imageInfo = imageInfo
        self.preferredAnimationQuality = animationQuality
        self.preferredPixelSize = pixelSize
    }
    
    ///Stops preparing GIF frames and related information
    public func stopPreparingAnimation() {
        preparingOperation?.cancel()
        preparingOperation = nil
    }
    
    ///Starts preparing GIF frames and related information. Calling this method will stop the previous preparing process
    public func prepareAnimation() {
        stopPreparingAnimation()
        
        preparingOperation = JellyGifOperation(info: imageInfo, pixelSize: preferredPixelSize) { [weak self] images, frames in
            self?.setupWith(images: images, frames: frames)
            self?.preparingOperation = nil
        }
        
        JellyGifAnimator.gifQueue.async {
            self.preparingOperation?.start()
        }
    }
    
    ///Computes required properties to start animating
    private func setupWith(images: [UIImage], frames: [CFTimeInterval]) {
        self.images = images
        frameDurations = frames
        oneCycleDuration = frames.reduce(0.0, +)
        framesStartDurations = frames
                                .enumerated()
                                .map { index, _ -> CFTimeInterval in
                                    frames[0...index].reduce(0.0, +)
                                }
        guard isReady else { return }
        delegate?.gifAnimatorIsReady(self)
    }
    
    ///Starts animating or resume animation if the GIF is in mid animation
    public func startAnimation() {
        displayLink.isPaused = false
    }

    public func pauseAnimation() {
        displayLink.isPaused = true
    }
    
    ///Calculates the next frame and update frame if needed
    @objc fileprivate func animateGif(displayLink: CADisplayLink) {
        guard isReady else { return }
        
        if currentDuration >= oneCycleDuration {
            currentDuration = 0
            currentIndex = 0
            return
        } else if currentDuration >= framesStartDurations[currentIndex] {
            currentIndex += 1
        }
                
        currentDuration += displayLink.duration
        delegate?.gifAnimatorDidChangeImage(images[currentIndex], sender: self)
        delegate?.imageViewForAnimator(self)?.image = images[currentIndex]
    }
    
    deinit {
        displayLink.invalidate()
    }
}

///An object used to prevent retain cycle caused by CADisplayLink
private class DisplayLinkProxy {
    weak var animator: JellyGifAnimator?
    
    init(animator: JellyGifAnimator) {
        self.animator = animator
    }
    
    @objc func animateGif(displayLink: CADisplayLink) {
        animator?.animateGif(displayLink: displayLink)
    }
}

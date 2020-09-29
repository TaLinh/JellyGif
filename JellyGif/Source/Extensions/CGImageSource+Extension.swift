//
//  CGImageSource+Extension.swift
//  JellyGif
//
//  Created by Linh Ta on 5/10/20.
//  Copyright © 2020 Linh Ta. All rights reserved.
//

import UIKit

//MARK: - Create CGImageSource Helpers
public extension CGImageSource {
    ///A dictionary that specifies additional creation options of the CGImageSource.
    ///See [Image Source Option Dictionary Keys](https://developer.apple.com/documentation/imageio/cgimagesource/image_source_option_dictionary_keys) for the keys you can supply.
    static var defaultOptions: CFDictionary = [kCGImageSourceShouldCache: kCFBooleanFalse] as CFDictionary
    
    ///Returns a new CGImageSource from the input GifInfo
    ///- Parameters:
    ///     - info: Required information to generate a GIF
    ///     - options: A dictionary that specifies additional creation options of the CGImageSource. See [Image Source Option Dictionary Keys](https://developer.apple.com/documentation/imageio/cgimagesource/image_source_option_dictionary_keys) for the keys you can supply.
    class func sourceFromInfo(_ info: GifInfo, with options: CFDictionary = defaultOptions) -> CGImageSource? {
        switch info {
        case .name(let name):
            return sourceFromImageName(name)
        case .localPath(let url):
            return sourceFromImagePath(url)
        case .data(let data):
            return sourceFromData(data)
        }
    }
    
    ///Returns a new CGImageSource from the input local path
    ///- Parameters:
    ///     - path: The local path of a GIF
    ///     - options: A dictionary that specifies additional creation options of the CGImageSource. See [Image Source Option Dictionary Keys](https://developer.apple.com/documentation/imageio/cgimagesource/image_source_option_dictionary_keys) for the keys you can supply.
    class func sourceFromImagePath(_ path: URL, with options: CFDictionary = defaultOptions) -> CGImageSource? {
        guard let data = try? Data(contentsOf: path) as CFData else { return nil }
        return CGImageSourceCreateWithData(data, options)
    }
    
    ///Returns a new CGImageSource from the input GIF name
    ///- Parameters:
    ///     - name: The name of the GIF in the main Bundle
    ///     - options: A dictionary that specifies additional creation options of the CGImageSource. See [Image Source Option Dictionary Keys](https://developer.apple.com/documentation/imageio/cgimagesource/image_source_option_dictionary_keys) for the keys you can supply.
    class func sourceFromImageName(_ name: String, with options: CFDictionary = defaultOptions) -> CGImageSource? {
        guard let imageUrl = Bundle.main.url(forResource: name, withExtension: "gif") else { return nil }
        guard let data = try? Data(contentsOf: imageUrl) as CFData else { return nil }
        return CGImageSourceCreateWithData(data, options)
    }
    
    
    ///Returns a new CGImageSource from the input GIF data
    ///- Parameters:
    ///     - data: GIF data
    ///     - options: A dictionary that specifies additional creation options of the CGImageSource. See [Image Source Option Dictionary Keys](https://developer.apple.com/documentation/imageio/cgimagesource/image_source_option_dictionary_keys) for the keys you can supply.
    class func sourceFromData(_ data: Data, with options: CFDictionary = defaultOptions) -> CGImageSource? {
        return CGImageSourceCreateWithData(data as CFData, options)
    }
}


//MARK: - Generate Gif Information
public extension CGImageSource {
    ///Returns an array of resized frames of a GIF
    /// - Parameters:
    ///     - imageSource: The object that stores information of a GIF
    ///     - maxSize: The maximum size of generated images
    class func getResizedImages(from imageSource: CGImageSource, maxSize: CGFloat) -> [UIImage] {
        return [Int](0..<CGImageSourceGetCount(imageSource))
            .compactMap { index -> CGImage? in
                let options = [kCGImageSourceThumbnailMaxPixelSize: maxSize,
                               kCGImageSourceShouldCacheImmediately: true,
                               kCGImageSourceCreateThumbnailFromImageAlways: kCFBooleanTrue!] as CFDictionary
                return CGImageSourceCreateThumbnailAtIndex(imageSource, index, options)
        }
        .map { UIImage(cgImage: $0) }
    }
    
    ///Array of frame lengths of a GIF
    var frameDurations: [CFTimeInterval] {
        guard #available(iOS 13.0, *) else {
            return [Int](0..<CGImageSourceGetCount(self))
                .reduce(into: []) { (result, index) in
                    if let properties = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as? Dictionary<String, Any>,
                        let gifInfos = properties[kCGImagePropertyGIFDictionary as String] as? Dictionary<String, Any>,
                        let duration = gifInfos[kCGImagePropertyGIFUnclampedDelayTime as String] as? CFTimeInterval {
                        return result.append(duration)
                    }
                }
        }
        
        guard let properties = CGImageSourceCopyProperties(self, nil) as? Dictionary<String, Any>,
            let gifInfos = properties[kCGImagePropertyGIFDictionary as String] as? Dictionary<String, Any>,
            let frameInfos = gifInfos[kCGImagePropertyGIFFrameInfoArray as String] as? [Dictionary<String, CGFloat>]
            else { return [] }
        
        return frameInfos
            .compactMap { $0[kCGImagePropertyGIFDelayTime as String] }
            .map { CFTimeInterval($0) }
    }
    
    ///Array of original - unresized frames of a GIF
    var fullSizeImages: [UIImage] {
        return [Int](0..<CGImageSourceGetCount(self))
            .compactMap { CGImageSourceCreateImageAtIndex(self, $0, nil) }
            .map { UIImage(cgImage: $0) }
    }
    
    ///Returns an array of resized frames of a GIF
    /// - Parameters:
    ///     - size: The maximum size of generated images
    func imagesWithMaxSize(_ size: CGFloat) -> [UIImage] {
        return CGImageSource.getResizedImages(from: self, maxSize: size)
    }
}

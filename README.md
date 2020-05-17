[![Language](https://img.shields.io/badge/swift-5.0-blue.svg)](http://swift.org)
![Platform](https://img.shields.io/cocoapods/p/JellyGif)
![Pod License](https://img.shields.io/cocoapods/l/JellyGif)
[![Cover Image](https://i.postimg.cc/MKYQ7dp1/cover.png)](https://postimg.cc/ppprxQ8d)

Lightweight, performant, and memory efficient Gif framework

## Features
- [x] Honor Gif frame duration
- [x] Optimized for CPU and Memory performance
- [x] Designed with UITableViewCell and UICollectionViewCell in mind
- [x] Full control over even the smallest details i.e preparation process, animation quality, output image quality, etc...
- [x] Extensible and easy to use

## Installation

#### With CocoaPods
```ruby
source 'https://cocoapods.org/pods/JellyGif'
use_frameworks!
pod 'JellyGif'
```

## Usage
The easiest way to get started is using `JellyGifImageView` and calling `startGif(with:)`

~~~swift
import JellyGif

let imageView = JellyGifImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

//Animates Gif from the main bundle
imageView.startGif(with: .name("Gif name"))

//Animates Gif with a local path
let url = URL(string: "Gif path")!
imageView.startGif(with: .localPath(url))

//Animates Gif with data
imageView.startGif(with: .data(Data))
~~~

To fully utilize full power of JellyGif, use `JellyGifAnimator` and conform to its `JellyGifAnimatorDelegate`

~~~swift
import JellyGif

let imageView = UIImageView(CGRect(x: 0, y: 0, width: 100, height: 100))
let animator = JellyGifAnimator(imageInfo: .name("Gif name"), pixelSize: .custom(350), animationQuality: .best)
animator.delegate = self

//JellyGifAnimatorDelegate
func gifAnimatorIsReady(_ sender: JellyGifAnimator) {
  sender.startAnimation()
}

func imageViewForAnimator(_ sender: JellyGifAnimator) -> UIImageView? { 
  return imageView
}

func gifAnimatorDidChangeImage(_ image: UIImage, sender: JellyGifAnimator) {
  //Use this method if you want to manually update Gif frame instead of using an UIImageView
}
~~~

`JellyGifAnimator` let you control every aspect of a Gif including its maximum output size - `pixelSize` and its frames per second - `animationQuality`. The closer the `pixelSize` property is to the actual size of the image holder the smaller the memory footprint and the better the CPU performance.

#### UICollectionView & UITableView
To use `JellyGifAnimator` with an `UICollectionView` or an `UITableView`, creates a dictionary of `JellyGifAnimator` inside the owner of the `UICollectionView` or `UITableView` and conforms to `JellyGifAnimatorDelegate`

~~~swift
import JellyGif

class ViewController: UIViewController {
  var gifNames: [String] = []
  var animators: [IndexPath: JellyGifAnimator] = [:]
    
  //Your code
  //...
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  //Your Code
  //...
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //dequeue cell
    //...
    
    let gifName = gifNames[indexPath.item]
    
    if animators[indexPath] == nil {
        let animator = JellyGifAnimator(imageInfo: .name(gifName), pixelSize: .custom(350), animationQuality: .best)
        animators[indexPath] = animator
    }

    //If the Gif is not ready, show a placeholder image - which is the first frame of the Gif instead
    if animators[indexPath]?.isReady != true {
        cell.imageView.image = animators[indexPath]?.placeholder
    }

    animators[indexPath]?.delegate = self

    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if animators[indexPath]?.isReady == true {
      animators[indexPath]?.startAnimation()
    } else {
      animators[indexPath]?.prepareAnimation()
    }
  }

  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //Pause animation and the preparation process if the cell is not visible
    animators[indexPath]?.pauseAnimation()
    animators[indexPath]?.stopPreparingAnimation()
  }
}

extension ViewController: JellyGifAnimatorDelegate {
  func gifAnimatorIsReady(_ sender: JellyGifAnimator) {
    sender.startAnimation()
  }

  func imageViewForAnimator(_ sender: JellyGifAnimator) -> UIImageView? { 
    for indexPath in collectionView.indexPathsForVisibleItems {
      if animators[indexPath] === sender {
        return (collectionView.cellForItem(at: indexPath) as? YourCustomCell)?.imageView
      }
    }
    return nil
  }
}
~~~

## Benchmark
#### Displays 1 image
|               |CPU Usage |Memory Usage |
|:-------------:|:-----------------:|:-----------------------:|
|SwiftyGif      |2%                 |44.6Mb                   |
|Gifu           |2%                 |46.3Mb                   |
|***JellyGif*** |***1%***           |***46.3Mb***             |
|***JellyGif (optimized mode on)***|***1%***   |***30.3Mb***  |

#### Displays 10 images
|               |CPU Usage |Memory Usage |
|:-------------:|:-----------------:|:-----------------------:|
|SwiftyGif      |34%                |31.7Mb                   |
|Gifu           |6%                 |200Mb                    |
|***JellyGif*** |***6%***           |***200Mb***              |
|***JellyGif (optimized mode on)***|***5%***   |***39.1Mb***  |

Measured on an iPhone Xs Max, iOS 13.3.1 and Xcode 11.3.1

## Compatibility
- iOS 10.0+
- Swift 5.0
- Xcode 10+

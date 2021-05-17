import Foundation
import UIKit
import AVFoundation
import GPUImage

class Helper {
    
    static let shared = Helper()

    func getFirstVideoFrame(url: Any, image: inout UIImage?) {
        let asset = AVURLAsset(url: url as! URL)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        let cgImage = try? imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        image = UIImage(cgImage: cgImage!)
    }
    
    func buttonImageFiltred (b1: UIButton, b2: UIButton, b3: UIButton, b4: UIButton, image: UIImage) {
        b1.isEnabled = true
        
        buttonSetImage(
            button: b1,
            image: Filters.shared.filtredImage(
                image: image,
                f1: GPUImageColorInvertFilter()))
        
        b2.isEnabled = true
        let f2 = GPUImageBrightnessFilter()
        f2.brightness = 0.2
        
        buttonSetImage(
            button: b2,
            image: Filters.shared.filtredImage(
                image: image,
                f1: GPUImageSepiaFilter(),
                f2: GPUImageTransformFilter(),
                f3: f2))
        
        b3.isEnabled = true
        let f3 = GPUImagePixellateFilter()
        f3.fractionalWidthOfAPixel = 0.02
        
        buttonSetImage(
            button: b3,
            image: Filters.shared.filtredImage(
                image: image,
                f1: f3))
        
        b4.isEnabled = true
        let f41 = GPUImagePixellateFilter()
        f41.fractionalWidthOfAPixel = 0.03
        let f42 = GPUImagePolkaDotFilter()
        f42.fractionalWidthOfAPixel = 0.01
        
        buttonSetImage(
            button: b4,
            image: Filters.shared.filtredImage(
                image: image,
                f1: f41,
                f2: f42))
    }
    
    func buttonSetImage(button: UIButton, image: UIImage) {
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.layer.cornerRadius = 50
    }
    
    func buttonHighlighted (selfButton: UIButton, b1: UIButton, b2: UIButton, b3: UIButton) {
        selfButton.layer.borderWidth = 6
        selfButton.layer.borderColor = UIColor.systemBlue.cgColor
        b1.layer.borderWidth = 0
        b2.layer.borderWidth = 0
        b3.layer.borderWidth = 0
    }
    
    func createPlayer (
        playerItem: inout AVPlayerItem?,
        player: inout AVPlayer?,
        avPlayerLayer: inout AVPlayerLayer?,
        videoView: UIView, playButton: UIButton,
        sharingButton: UIButton
    ) {
        player?.pause()
        playerItem = AVPlayerItem(asset: AssetStore.shared.compose())
        
        if player != nil {
            player?.replaceCurrentItem(with: playerItem)
        } else {
            player = AVPlayer(playerItem: playerItem)
        }
        
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        avPlayerLayer?.frame = videoView.layer.bounds
        videoView.layer.addSublayer(avPlayerLayer!)
        playButton.isHidden = false
        sharingButton.isHidden = false
    }
}

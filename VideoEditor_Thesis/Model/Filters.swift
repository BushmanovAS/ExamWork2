import Foundation
import GPUImage

class Filters {
    
    static let shared = Filters()

    func first(
        playerItem: AVPlayerItem,
        avPlayerLayer: AVPlayerLayer,
        videoView: UIView,
        gpuMovie: inout GPUImageMovie?,
        filteredView: inout GPUImageView?
    ) {
        let filter = GPUImageColorInvertFilter()

        videoFilterOverlay(
            playerItem: playerItem,
            avPlayerLayer: avPlayerLayer,
            videoView: videoView,
            filter: filter,
            gpuMovie: &gpuMovie,
            filteredView: &filteredView)
    }
    
    func second(
        playerItem: AVPlayerItem,
        avPlayerLayer: AVPlayerLayer,
        videoView: UIView,
        gpuMovie: inout GPUImageMovie?,
        filteredView: inout GPUImageView?
    ) {
        let filter = GPUImageSepiaFilter()
        let filter2 = GPUImageTransformFilter()
        let filter3 = GPUImageBrightnessFilter()
        filter3.brightness = 0.2
                
        videoFilterOverlay(
            playerItem: playerItem,
            avPlayerLayer: avPlayerLayer,
            videoView: videoView,
            filter: filter,
            filter2: filter2,
            filter3: filter3,
            gpuMovie: &gpuMovie,
            filteredView: &filteredView)
        
    }
    
    func third(
        playerItem: AVPlayerItem,
        avPlayerLayer: AVPlayerLayer,
        videoView: UIView,
        gpuMovie: inout GPUImageMovie?,
        filteredView: inout GPUImageView?
    ) {
        let filter = GPUImagePixellateFilter()
        filter.fractionalWidthOfAPixel = 0.02
        
        videoFilterOverlay(
            playerItem: playerItem,
            avPlayerLayer: avPlayerLayer,
            videoView: videoView,
            filter: filter,
            gpuMovie: &gpuMovie,
            filteredView: &filteredView)
    }
    
    func fourth(
        playerItem: AVPlayerItem,
        avPlayerLayer: AVPlayerLayer,
        videoView: UIView,
        gpuMovie: inout GPUImageMovie?,
        filteredView: inout GPUImageView?
    ) {
        let filter = GPUImagePixellateFilter()
        filter.fractionalWidthOfAPixel = 0.03
        let filter2 = GPUImagePolkaDotFilter()
        filter2.fractionalWidthOfAPixel = 0.01
        
        videoFilterOverlay(
            playerItem: playerItem,
            avPlayerLayer: avPlayerLayer,
            videoView: videoView,
            filter: filter,
            filter2: filter2,
            gpuMovie: &gpuMovie,
            filteredView: &filteredView)
    }

    func videoFilterOverlay(
        playerItem: AVPlayerItem,
        avPlayerLayer: AVPlayerLayer,
        videoView: UIView,
        filter: GPUImageFilter,
        filter2: GPUImageFilter? = nil,
        filter3: GPUImageFilter? = nil,
        gpuMovie: inout GPUImageMovie?,
        filteredView: inout GPUImageView?
    ) {
        gpuMovie?.cancelProcessing()
        gpuMovie?.removeFramebuffer()
        filteredView?.removeFromSuperview()
        gpuMovie = GPUImageMovie(playerItem: playerItem)
        gpuMovie?.playAtActualSpeed = true
        filteredView = GPUImageView();
        filteredView?.frame = avPlayerLayer.frame
        videoView.addSubview(filteredView!)
        let filter = filter
        let filter2 = filter2
        let filter3 = filter3
        gpuMovie?.addTarget(filter)

        if filter2 != nil {
            if filter3 != nil {
                filter.addTarget(filter2)
                filter2!.addTarget(filter3)
                filter3!.addTarget(filteredView)
            } else {
            filter.addTarget(filter2)
            filter2!.addTarget(filteredView)
            }
        } else {
            filter.addTarget(filteredView)
        }
    
        gpuMovie?.startProcessing()
    }
    
    func filtredImage(
        image: UIImage,
        f1: GPUImageFilter,
        f2: GPUImageFilter? = nil,
        f3: GPUImageFilter? = nil
    ) -> UIImage {
        var image1 = UIImage()

        if f2 != nil {
            if f3 != nil {
                let picture = GPUImagePicture(image: image)
                picture?.addTarget(f1)
                f1.addTarget(f2)
                f2!.addTarget(f3)
                f3!.useNextFrameForImageCapture()
                picture?.processImage()
                image1 = f3!.imageFromCurrentFramebuffer()
                return image1
            } else {
                let picture = GPUImagePicture(image: image)
                picture?.addTarget(f1)
                f1.addTarget(f2)
                f2?.useNextFrameForImageCapture()
                picture?.processImage()
                image1 = f2!.imageFromCurrentFramebuffer()
                return image1
            }
        } else {
            let picture = GPUImagePicture(image: image)
            picture?.addTarget(f1)
            f1.useNextFrameForImageCapture()
            picture?.processImage()
            image1 = f1.imageFromCurrentFramebuffer()
            return image1
        }
    }
}

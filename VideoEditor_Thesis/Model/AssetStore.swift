import Foundation
import UIKit
import AVFoundation

class AssetStore {
    
    static let shared = AssetStore()
    
    var video: AVAsset?
    var audio: AVAsset?
    
    static func asset(_ resouce: String, type: String) -> AVAsset {
        
        guard let path = Bundle.main.path(forResource: resouce, ofType: type) else {
            fatalError()
        }
        
        let url = URL(fileURLWithPath: path)
        return AVAsset(url: url)
    }
    
    func startPlaying(asset: AVAsset, view: UIView ){
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.frame
        view.layer.addSublayer(playerLayer)
        player.play()
    }
    
    func compose() -> AVAsset {
        let composition = AVMutableComposition()
        
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { fatalError() }
        
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { fatalError() }
        
        if video != nil {
        try? videoTrack.insertTimeRange(
            CMTimeRange(start: CMTime.zero, duration: video!.duration),
            of: video!.tracks(withMediaType: .video)[0],
            at: CMTime.zero)
        } else {
            debugPrint("Video == nil <-----------------")
        }
        
        if audio != nil {
        try? audioTrack.insertTimeRange(
            CMTimeRange(start: CMTime.zero, duration: video!.duration),
            of: audio!.tracks(withMediaType: .audio)[0],
            at: CMTime.zero)
        } else {
            debugPrint("Audio == nil <-----------------")
        }
    
        return composition
    }
    
    func export(asset: AVAsset, url: URL, completion: @escaping (Bool) -> Void) {
                
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetLowQuality) else { fatalError() }
        exporter.outputURL = url
        exporter.outputFileType = .mov
        
        exporter.exportAsynchronously {            
            print(exporter.error)
            
            DispatchQueue.main.async {
                completion(exporter.status == .completed)
            }
        }
    }
}

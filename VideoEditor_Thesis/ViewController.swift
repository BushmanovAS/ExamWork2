import UIKit
import AVKit
import GPUImage


class ViewController: UIViewController {
    @IBOutlet weak var playButton: RoundedButton!
    @IBOutlet weak var addAudio: RoundedButton!
    @IBOutlet weak var firstButton: RoundedButton!
    @IBOutlet weak var secondButton: RoundedButton!
    @IBOutlet weak var thirdButton: RoundedButton!
    @IBOutlet weak var fourthButton: RoundedButton!    
    @IBOutlet weak var sharingButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var avPlayerLayer : AVPlayerLayer!
    var image: UIImage!
    var gpuMovie: GPUImageMovie!
    var filteredView: GPUImageView!
    var filterUsed = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        player?.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    @IBAction func playVideo(_ sender: Any) {
        player?.actionAtItemEnd = .none
        playButton.isHidden = true
        player.play()
    }
    
    @IBAction func addVideo(_ sender: Any) {
        addNewVideo()
        addAudio.isEnabled = true
    }
    
    @IBAction func addAudio(_ sender: Any) {
        addNewAudio()
    }

    @IBAction func sharing(_ sender: Any) {
        StartWritingvideo()
    }

    
 // MARK: Filters Buttons
    @IBAction func firstFilter(_ sender: Any) {
        filterUsed = true
        
        Helper.shared.buttonHighlighted(
            selfButton: firstButton,
            b1: secondButton,
            b2: thirdButton,
            b3: fourthButton)
        
        Filters.shared.first(
            playerItem: playerItem,
            avPlayerLayer: avPlayerLayer,
            videoView: videoView,
            gpuMovie: &gpuMovie,
            filteredView: &filteredView)
    }
    
    @IBAction func secondFilter(_ sender: Any) {
        filterUsed = true
        
        Helper.shared.buttonHighlighted(
            selfButton: secondButton,
            b1: firstButton,
            b2: thirdButton,
            b3: fourthButton)
        
        Filters.shared.second(
            playerItem: playerItem,
            avPlayerLayer: avPlayerLayer,
            videoView: videoView,
            gpuMovie: &gpuMovie,
            filteredView: &filteredView)
    }
    
    @IBAction func thirdFilter(_ sender: Any) {
        filterUsed = true
        
        Helper.shared.buttonHighlighted(
            selfButton: thirdButton,
            b1: secondButton,
            b2: firstButton,
            b3: fourthButton)
        
        Filters.shared.third(
            playerItem: playerItem,
            avPlayerLayer: avPlayerLayer,
            videoView: videoView,
            gpuMovie: &gpuMovie,
            filteredView: &filteredView)
    }
    
    @IBAction func fourthFilter(_ sender: Any) {
        filterUsed = true
        
        Helper.shared.buttonHighlighted(
            selfButton: fourthButton,
            b1: secondButton,
            b2: thirdButton,
            b3: firstButton)
        
        Filters.shared.fourth(
            playerItem: playerItem,
            avPlayerLayer: avPlayerLayer,
            videoView: videoView,
            gpuMovie: &gpuMovie,
            filteredView: &filteredView)
    }
}

// MARK: Ext. ImagePickerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func addNewVideo() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = ["public.movie"] //эта строчка позволяет увидеть только видео
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let videoURL = info[.mediaURL] else { return }
        
        AssetStore.shared.video = AVAsset(url: videoURL as! URL)
        
        Helper.shared.createPlayer(
            playerItem: &playerItem,
            player: &player,
            avPlayerLayer: &avPlayerLayer,
            videoView: videoView,
            playButton: playButton,
            sharingButton: sharingButton)

        Helper.shared.getFirstVideoFrame(url: videoURL, image: &image)

        Helper.shared.buttonImageFiltred(
            b1: firstButton,
            b2: secondButton,
            b3: thirdButton,
            b4: fourthButton,
            image: image)

        dismiss(animated: true)
    }
    
}

//MARK: Ext. DocumenPickerDelegate
extension ViewController: UIDocumentPickerDelegate {
    
    func addNewAudio() {
        let documentsPicker = UIDocumentPickerViewController(documentTypes: ["public.mp3"], in: .open)
        documentsPicker.delegate = self
        documentsPicker.allowsMultipleSelection = false
        present(documentsPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let url = urls.first else { return }
        
        defer {
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()                    
            }
        }
        
        let audioAsset = AVAsset(url: url)
        AssetStore.shared.audio = audioAsset
        
        Helper.shared.createPlayer(playerItem: &playerItem, player: &player, avPlayerLayer: &avPlayerLayer, videoView: videoView, playButton: playButton, sharingButton: sharingButton)
        
        print(audioAsset)
        
    }
}
extension ViewController {

    
    func StartWritingvideo() {
        var asset = playerItem.asset
        
        if AssetStore.shared.audio != nil {
            asset = AssetStore.shared.compose()
        } else {
            asset = AssetStore.shared.video!
        }
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    fatalError()
                }
                        
        let date = Date()
        let movieURL = documentDirectory.appendingPathComponent("Modified_Video\(date).mov")
        
        if filterUsed {
            player.pause()
            var movieFile = GPUImageMovie(asset: asset)
            movieFile?.runBenchmark = true
            movieFile?.playAtActualSpeed = false
            let filter = GPUImagePixellateFilter()
            movieFile?.addTarget(filter)
            let anAsset = AssetStore.shared.compose()
            let videoAssetTrack = anAsset.tracks(withMediaType: AVMediaType.video)[0]
            var naturalSize = CGSize()
            naturalSize = videoAssetTrack.naturalSize
            let movieWriter = GPUImageMovieWriter(movieURL: movieURL, size: naturalSize)
            let input = filter
            input.addTarget(movieWriter)
            movieWriter?.shouldPassthroughAudio = true
        
            if anAsset.tracks(withMediaType: AVMediaType.audio).count > 0 {
                movieFile?.audioEncodingTarget =  movieWriter
            } else {
                movieFile?.audioEncodingTarget = nil
            }
            
            movieFile?.enableSynchronizedEncoding(using: movieWriter)
            movieWriter?.startRecording()
            movieFile?.startProcessing()
            
            movieWriter?.completionBlock = {() -> Void in
                print("Writing success <------------------------")
                movieWriter?.finishRecording()
                movieFile?.cancelProcessing()
                input.removeAllTargets()
                movieFile?.removeAllTargets()
            
                DispatchQueue.main.async {
                    let items = [movieURL]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    self.present(ac, animated: true)
                }
            }
        } else {
            AssetStore.shared.export(asset: asset, url: movieURL) { (success) in
                
                if success {
                    print("Export success <------------------------")
                    
                    DispatchQueue.main.async {
                        let items = [movieURL]
                        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        self.present(ac, animated: true)
                    }
                } else {
                    print("Export fail <------------------------")
                }
            }
        }    
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
                
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero)
            player.pause()
            playButton.isHidden = false
        }
    }
}


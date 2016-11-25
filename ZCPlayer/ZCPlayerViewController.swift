//
//  ZCPlayerViewController.swift
//  ZCWeChat
//
//  Created by zcs on 2016/11/25.
//  Copyright © 2016年 zcs. All rights reserved.
//

import UIKit
import AVFoundation

class ZCPlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var bufferProgress: UIProgressView!
    @IBOutlet weak var playProgress: UISlider!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var totateBtn: UIButton!
    
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var playerLayer:AVPlayerLayer?
    
    var isPlaying:Bool = false
    var periodicTimeObserver:Any?
    var lastPlaybackRate: Float = 0.0
    
//    convenience init(url strUrl:String) {
//        super.init()
//    }
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playBtn.isEnabled = false
        toolView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).withAlphaComponent(0.5)

        playerItem = AVPlayerItem(url: URL(string:"http://120.25.226.186:32812/resources/videos/minion_01.mp4")!)
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerView.layer.addSublayer(playerLayer!)
        
        // 定期监听播放进度
        addPlayerItemTimeObserver()
        
        // 播放完成通知
        addNotification()
    }
    
    override func viewWillLayoutSubviews() {
        playerLayer?.frame = playerView.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        if let observer = periodicTimeObserver {
            player?.removeTimeObserver(observer)
            periodicTimeObserver = nil
        }
    }
    
    // MARK: - evern&action
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        guard let playerItem = object as? AVPlayerItem else { return }
        
        if keyPath == "loadedTimeRanges"{
            // 缓冲进度
            let timeRangeValue = playerItem.loadedTimeRanges.first?.timeRangeValue
            if let timeRange = timeRangeValue {
                let startSeconds = CMTimeGetSeconds(timeRange.start)
                let durationSeconds = CMTimeGetSeconds(timeRange.duration)
                let timeInterval = startSeconds + durationSeconds
                let totalDuration = CMTimeGetSeconds(playerItem.duration)
                let progress = timeInterval / totalDuration
                self.bufferProgress.setProgress(Float(progress), animated: true)
            }
        }
        else if keyPath == "status"{
            // 监听状态改变
            if playerItem.status == AVPlayerItemStatus.readyToPlay {
                self.playBtn.isEnabled = true
                self.playProgress.maximumValue = Float(CMTimeGetSeconds(playerItem.duration))
                self.totalTimeLabel.text = self.convertTime(self.playProgress.maximumValue)
            }
            else {
                print("加载异常")
            }
        }
    }
    
    func playbackFinished(_ notification:Notification) {
        // 播放完成
        playerItem?.seek(to: kCMTimeZero,
                         completionHandler: { [weak self] finished in
                            self?.pause()
            })
    }
    
    @IBAction func playOrPuse(_ sender: UIButton) {
        print("playOrPuse")
        if isPlaying {
            pause()
        }
        else {
            play()
        }
    }
    
    @IBAction func totateBtnClicked(_ sender: UIButton) {
        print("totateBtnClicked")
    }
    
    @IBAction func playerSliderDown(_ sender: UISlider) {
        print("playerSliderDown")
        lastPlaybackRate = (player?.rate)!
        pause()
    }
    
    @IBAction func playerSliderChanged(_ sender: UISlider) {
        print("playerSliderChanged")
        playerItem?.cancelPendingSeeks()
        let dragedCMTime = CMTimeMakeWithSeconds(Float64(playProgress.value), Int32(NSEC_PER_SEC))
        player?.seek(to: dragedCMTime)
    }
    
    @IBAction func playerSliderInside(_ sender: UISlider) {
        print("playerSliderInside")
        if lastPlaybackRate > 0.0 {
            play()
        }
    }
    
    // MARK: - private
    
    func convertTime(_ time:Float) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = DateFormatter()
        if time/3600 >= 1 {
            formatter.dateFormat = "HH:mm:ss"
        }
        else {
            formatter.dateFormat = "mm:ss"
        }
        return formatter.string(from: date)
    }

    func play() {
        if !isPlaying {
            player?.play()
            isPlaying = true
            playBtn.setImage(UIImage(named:"MoviePlayer_Play"), for: .normal)
        }
    }
    
    func pause() {
        if isPlaying {
            lastPlaybackRate = (player?.rate)!
            player?.pause()
            isPlaying = false
            playBtn.setImage(UIImage(named:"MoviePlayer_Stop"), for: .normal)
        }
    }
    
    func stop() {
        player?.rate = 0.0
        isPlaying = false
        playBtn.setImage(UIImage(named:"MoviePlayer_Stop"), for: .normal)
    }
    
    func addPlayerItemTimeObserver() {
        periodicTimeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 30),
                                                               queue: DispatchQueue.main,
                                                               using: { [weak self] time in
                //let currentPlayTime = time.value / Int64(time.timescale)
                let currentPlayTime = CMTimeGetSeconds(time)
                self?.playProgress.value = Float(currentPlayTime)
                self?.currentTimeLabel.text = self?.convertTime(Float(currentPlayTime))
            })
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playbackFinished(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
}

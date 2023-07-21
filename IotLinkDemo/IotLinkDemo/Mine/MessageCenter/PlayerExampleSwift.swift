//
//  PlayerExampleSwift.swift
//  IotLinkDemo
//
//  Created by admin on 2023/7/19.
//

import UIKit
import IJKMediaFramework
import SJBaseVideoPlayer
import SJVideoPlayer

class PlayerExampleSwift: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    lazy var player:SJVideoPlayer = {
        
        let player = SJVideoPlayer()
        return player
        
    }()
    
    func creatIjk(mediaUrl: String){
        
        let ijkVC : SJIJKMediaPlaybackController = SJIJKMediaPlaybackController()
        let options = IJKFFOptions.byDefault()
        ijkVC.options = options
        player.playbackController = ijkVC
        
        guard let url = URL(string: mediaUrl) else {
            return
        }
        
        player.urlAsset = SJVideoPlayerURLAsset(url: url)
        
    }

}

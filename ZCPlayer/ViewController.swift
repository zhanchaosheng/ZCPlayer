//
//  ViewController.swift
//  ZCPlayer
//
//  Created by Cusen on 2016/11/24.
//  Copyright © 2016年 Zcoder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var playerViewController:ZCPlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let width = UIScreen.main.bounds.width
        let height = width / 16 * 9
        let playerViewRect = CGRect(x: 0, y: 20, width: width, height: height)
        playerViewController = ZCPlayerViewController()
        if let playerVC = playerViewController {
            playerVC.view.frame = playerViewRect
            playerVC.prepareToPlay(url: "http://120.25.226.186:32812/resources/videos/minion_01.mp4",
                                   container:self)
            view.addSubview(playerVC.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


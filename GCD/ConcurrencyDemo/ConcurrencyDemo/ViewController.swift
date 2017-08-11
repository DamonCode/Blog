//
//  ViewController.swift
//  ConcurrencyDemo
//
//  Created by Hossam Ghareeb on 11/15/15.
//  Copyright © 2015 Hossam Ghareeb. All rights reserved.
//

import UIKit

let imageURLs = ["http://www.ikuku.cn/wp-content/uploads/user/u1497/POST/p231875/1424770482633994-818x818.jpg",
                 "http://www.ikuku.cn/wp-content/uploads/user/u1497/POST/p231875/1424770482633994-818x818.jpg",
                 "http://www.ikuku.cn/wp-content/uploads/user/u1497/POST/p231875/1424770482633994-818x818.jpg",
                 "http://www.ikuku.cn/wp-content/uploads/user/u1497/POST/p231875/1424770482633994-818x818.jpg"]

class Downloader {
    
    class func downloadImageWithURL(_ url:String) -> UIImage! {
       
        let data = try? Data(contentsOf: URL(string: url)!)
        return UIImage(data: data!)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var sliderValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didClickOnStart(_ sender: AnyObject) {
        
        let img1 = Downloader.downloadImageWithURL(imageURLs[0])
        self.imageView1.image = img1
        
        let img2 = Downloader.downloadImageWithURL(imageURLs[1])
        self.imageView2.image = img2
        
        let img3 = Downloader.downloadImageWithURL(imageURLs[2])
        self.imageView3.image = img3
        
        let img4 = Downloader.downloadImageWithURL(imageURLs[3])
        self.imageView4.image = img4
        
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        self.sliderValueLabel.text = "\(sender.value * 100.0)"
    }

}


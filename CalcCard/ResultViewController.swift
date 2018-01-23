//
//  ResultViewController.swift
//  SpeakWriter
//
//  Created by Satoru Takahashi on 2018/01/12.
//  Copyright © 2018年 Satoru Takahashi. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    public var result_type: Int = 0
    public var score: Int = 0
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let imageName: String!
        let resultMessage: String!
        switch (self.result_type) {
        case 0:
            imageName = "result1"
            resultMessage = "びっくり\nニャン"
            break
        case 1:
            imageName = "result2"
            resultMessage = "すごいニャン"
            break
        case 2:
            imageName = "result3"
            resultMessage = "なかなか\nやるニャン"
            break
        case 3:
            imageName = "result4"
            resultMessage = "がんばった\nニャン"
            break
        case 4:
            imageName = "result5"
            resultMessage = "よくできた\nニャン"
            break
        case 5:
            imageName = "result6"
            resultMessage = "あとちょっと\nニャン"
            break
        case 6:
            imageName = "result7"
            resultMessage = "がんばる\nニャン"
            break
        case 7:
            imageName = "result8"
            resultMessage = "この\n バカチンが!"
            break
        default:
            imageName = "result9"
            resultMessage = "まじめに\n やるニャン!"
            break
        }
        self.imageView.image = UIImage(named:imageName)
        self.resultLabel.text = resultMessage
        self.scoreLabel.text = String(self.score)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        //self.dismiss(animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

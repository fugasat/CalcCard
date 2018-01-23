//
//  TitleViewController.swift
//  SpeakWriter
//
//  Created by Satoru Takahashi on 2018/01/12.
//  Copyright © 2018年 Satoru Takahashi. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {

    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.titleImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.titleImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { _ in
            })
        })
        UIView.animate(withDuration: 0.15, delay: 0.3, options: [.curveEaseOut], animations: {
            self.logoImageView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
                self.logoImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { _ in
            })
        })
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

//
//  ViewController.swift
//  SpeakWriter
//
//  Created by Satoru Takahashi on 2018/01/08.
//  Copyright © 2018年 Satoru Takahashi. All rights reserved.
//

import UIKit
import Speech

let DEBUG_MODE: Bool = false
let QUERY_NUM: Int = 10
let EXP_ADD: Int = 0
let EXP_SUB: Int = 1

class ViewController: UIViewController, SFSpeechRecognitionTaskDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var testView: UITextView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var correctMarkLabel: UILabel!
    @IBOutlet weak var incorrectMarkLabel: UILabel!
    @IBOutlet weak var actionImageView1: UIImageView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?

    private let audioEngine = AVAudioEngine()

    private var timer: Timer!
    private var dummyInputTimer: Timer!
    private var lastWord: String?
    private var currentWord: String?
    
    private var q1: Int!
    private var q2: Int!
    private var q_exp: Int!
    private var q_correct: Int!
    private var answer: Int!
    private var q_count: Int!
    private var miss_count: Int!

    private var q_initialize: Bool = false

    var actionImages: [[UIImage]] = [
        [UIImage(named:"a00")!, UIImage(named:"a01")!, UIImage(named:"a02")!],
        [UIImage(named:"a10")!, UIImage(named:"a11")!, UIImage(named:"a12")!],
        [UIImage(named:"a20")!, UIImage(named:"a21")!, UIImage(named:"a22")!],
        [UIImage(named:"a30")!, UIImage(named:"a31")!, UIImage(named:"a32")!],
        [UIImage(named:"a40")!, UIImage(named:"a41")!, UIImage(named:"a42")!],
        [UIImage(named:"a50")!, UIImage(named:"a51")!, UIImage(named:"a52")!],
        [UIImage(named:"a60")!, UIImage(named:"a61")!, UIImage(named:"a62")!],
        [UIImage(named:"a70")!, UIImage(named:"a71")!, UIImage(named:"a72")!],
        [UIImage(named:"a80")!, UIImage(named:"a81")!, UIImage(named:"a82")!],
        [UIImage(named:"a90")!, UIImage(named:"a91")!, UIImage(named:"a92")!],
    ]
    var actionType: Int!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.actionImageView1.image = nil
        self.recordButton.isEnabled = false
        self.q_count = QUERY_NUM
        self.miss_count = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        speechRecognizer.delegate = self as? SFSpeechRecognizerDelegate
        
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:   // 許可OK
                    break
                case .denied:       // 拒否
                    self.recordButton.setTitle("録音許可なし", for: .disabled)
                    break
                case .restricted:   // 限定
                    self.recordButton.setTitle("このデバイスでは無効", for: .disabled)
                    break
                case .notDetermined:// 不明
                    self.recordButton.setTitle("録音機能が無効", for: .disabled)
                    break
                }
                self.recordButton.isEnabled = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !self.q_initialize {
            self.q_initialize = true
            self.startQuestion()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "result" {
            let resultViewController:ResultViewController = segue.destination as! ResultViewController
            //self.miss_count = Int(arc4random_uniform(11))
            resultViewController.score = 100 - self.miss_count * 10
            if self.miss_count <= 0 {
                resultViewController.result_type = 0
            } else if self.miss_count == 1 {
                resultViewController.result_type = 1
            } else if self.miss_count == 2 {
                resultViewController.result_type = 2
            } else if self.miss_count == 3 {
                resultViewController.result_type = 3
            } else if self.miss_count == 4 {
                resultViewController.result_type = 4
            } else if self.miss_count == 5 {
                resultViewController.result_type = 5
            } else if self.miss_count == 6 {
                resultViewController.result_type = 6
            } else if self.miss_count <= 8 {
                resultViewController.result_type = 7
            } else {
                resultViewController.result_type = 8
            }
        }
    }

    private func startRecording() throws {
        self.cancelRecognitionTask()
        self.timer = nil
        self.answer = -1

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("リクエスト生成エラー") }
        recognitionRequest.shouldReportPartialResults = true // 録音完了前に途中の結果を報告

        // マイク準備
        guard let inputNode:AVAudioInputNode = audioEngine.inputNode else { fatalError("InputNodeエラー") }

        self.recognitionTask = self.speechRecognizer.recognitionTask(with: recognitionRequest) { (result, error) in
            var isFinal = false
            
            if let result = result {
                var temp_answer = -1
                var temp_input = result.bestTranscription.formattedString
                if let temp_num = Int(temp_input) {
                    temp_answer = temp_num
                } else {
                    for trans in result.transcriptions {
                        let temp = trans.formattedString
                        if let temp_num = Int(temp) {
                            temp_answer = temp_num
                        }
                        temp_input = temp_input + "\n" + temp
                    }
                }
                if temp_answer >= 0 {
                    self.answer = temp_answer
                }
                self.testView.text = temp_input
                print("answer")
                print(self.answer)
                print("temp")
                print(temp_input)
                print("Input OK")
                if self.answer >= 0 {
                    self.answerLabel.text = String(self.answer)
                } else {
                    self.answerLabel.text = "?"
                }
                self.answerLabel.alpha = 0.3

                isFinal = result.isFinal
                
                self.currentWord = result.bestTranscription.formattedString
                
                if self.timer == nil {
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                    self.timer.fire()
                }
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        // マイクからの録音フォーマット
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        // オーディオエンジンで録音を開始して、テキスト表示を変更
        self.audioEngine.prepare()   // オーディオエンジン準備
        try audioEngine.start() // オーディオエンジン開始
        
        self.testView.text = nil
        self.answerLabel.text = nil
    }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            // 利用可能になったら、録音ボタンを有効にする
            recordButton.isEnabled = true
        } else {
            // 利用できないなら、録音ボタンは無効にする
            recordButton.setTitle("現在、使用不可", for: .disabled)
        }
    }
    
    private func cancelRecognitionTask() {
        if let recognitionTask = self.recognitionTask {
            // 既存タスクがあればキャンセルしてリセット
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    }
    
    @objc func update(tm: Timer) {
        print(self.testView.text)
        guard let currentWord = self.currentWord, currentWord.count > 0 else {
            print("cancel current")
            return
        }
        if currentWord == self.lastWord {
            self.stopRecord()
        } else {
            self.lastWord = currentWord
        }
    }

    @objc func dummyInput(tm: Timer) {
        if arc4random_uniform(3) == 0 {
            self.answer = self.q_correct + 1
        } else {
            self.answer = self.q_correct
        }
        self.currentWord = "0"
        self.lastWord = "0"
        self.stopRecord()
    }

    func startQuestion() {
        self.createQuestion()
        self.questionLabel.text = self.questionString()
        self.actionType = Int(arc4random_uniform(UInt32(self.actionImages.count)))
        self.actionImageView1.image = self.actionImages[self.actionType][0]
		startRecord()
        
        if DEBUG_MODE {
            self.dummyInputTimer = Timer.scheduledTimer(
                timeInterval: 1.0, target: self, selector: #selector(self.dummyInput), userInfo: nil, repeats: false)
            //self.dummyInputTimer.fire()
        }
    }
    
    func startRecord() {
        // 録音を開始する
        self.currentWord = nil
        try! startRecording()
    }
    
    func stopRecord() {
        // 音声エンジン動作中なら停止
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
		self.cancelRecognitionTask()
        if (self.timer != nil) {
            self.timer.invalidate()
        }
        if (self.dummyInputTimer != nil) {
            self.dummyInputTimer.invalidate()
        }
        if self.answer < 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
                DispatchQueue.main.async {
                    self.startRecord()
                }
            }
        } else {
            self.answerLabel.text = String(self.answer)
            self.answerLabel.alpha = 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
                DispatchQueue.main.async {
                    if self.answer == self.q_correct {
                        self.correctEffect()
                    } else {
                        self.miss_count = self.miss_count + 1
                        self.incorrectEffect()
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                        DispatchQueue.main.async {
                            self.correctMarkLabel.isHidden = true
                            self.incorrectMarkLabel.isHidden = true
                            self.q_count = self.q_count - 1
                            if self.q_count > 0 {
                                self.startQuestion()
                            } else {
                                self.performSegue(withIdentifier: "result", sender: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func correctEffect() {
        self.actionImageView1.image = self.actionImages[self.actionType][1]
        self.correctMarkLabel.isHidden = false
        self.correctMarkLabel.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.correctMarkLabel.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
            self.correctMarkLabel.alpha = 0.7
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.correctMarkLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { _ in
            })
        })
        for _ in 0..<15 {
            let isize: CGFloat = 120
            let origin = self.answerLabel.frame.origin
            let size = self.answerLabel.frame.size
            let sx = origin.x + size.width / 2 - isize / 2
            let sy = origin.y + size.height / 2 - isize / 2
            let x = CGFloat(arc4random_uniform(UInt32(size.width * 2))) - isize / 4 - size.width / 2
            let y = origin.y - 100 + CGFloat(arc4random_uniform(UInt32(size.height * 2 + 200))) - isize / 4 - size.height / 2
            let imageView = UIImageView()
            imageView.frame = CGRect(x: sx, y: sy, width: CGFloat(isize), height: CGFloat(isize))
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.image = UIImage(named: "star")
            imageView.alpha = 0.7
            self.view.addSubview(imageView)
            UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseOut], animations: {
                imageView.alpha = 0.0
                imageView.frame = CGRect(x: x, y: y, width: isize / 2, height: isize / 2)
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            }, completion: { _ in
                imageView.removeFromSuperview()
            })
        }
    }
    
    func incorrectEffect() {
        self.actionImageView1.image = self.actionImages[self.actionType][2]
        self.incorrectMarkLabel.isHidden = false
        self.incorrectMarkLabel.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.incorrectMarkLabel.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
            self.incorrectMarkLabel.alpha = 0.7
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.incorrectMarkLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { _ in
            })
        })
        for _ in 0..<15 {
            let isize: CGFloat = 120
            let size = self.answerLabel.frame.size
            let x = CGFloat(arc4random_uniform(UInt32(size.width))) - isize / 2
            let y = CGFloat(arc4random_uniform(UInt32(size.height + 100))) + self.answerLabel.frame.origin.y
            let imageView = UIImageView()
            imageView.frame = CGRect(x: x, y: y, width: CGFloat(isize), height: CGFloat(isize))
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.image = UIImage(named: "fire")
            imageView.alpha = 1.0
            self.view.addSubview(imageView)
            UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseOut], animations: {
                imageView.alpha = 0.0
                imageView.frame = CGRect(x: x + (isize / 4), y: y - 200, width: isize / 2, height: isize / 2)
            }, completion: { _ in
                imageView.removeFromSuperview()
            })
        }
    }
    
    func questionString() -> String {
        var question = String(describing: self.q1!)
        var q_exp: String
        switch(self.q_exp) {
        case EXP_ADD:
            q_exp = "+"
            break
        case EXP_SUB:
            q_exp = "-"
            break
        default:
            q_exp = "?"
        }
        question = question + " " + q_exp + " " + String(describing: self.q2!)
        //print(question)
        return question
    }
    
    func createQuestion() {
        self.q_exp = Int(arc4random_uniform(2))
        switch(self.q_exp) {
        case EXP_ADD:
            self.q_correct = 10 + Int(arc4random_uniform(10)) // 10..19
            self.q2 = 2 + Int(arc4random_uniform(8)) // 2..9
            self.q1 = self.q_correct - self.q2 // 1..17
            break
        case EXP_SUB:
            self.q_correct = 1 + Int(arc4random_uniform(9)) // 1..9
            self.q1 = 10 + Int(arc4random_uniform(UInt32(self.q_correct - 1))) // 8..0
            self.q2 = self.q1 - self.q_correct
            break
        default:
            self.q1 = 0
            self.q2 = 0
        }
        //print(self.q_correct)
    }
    
    func closeWindow() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if self.audioEngine.isRunning {
            self.stopRecord()
        }
        self.closeWindow()
    }

}




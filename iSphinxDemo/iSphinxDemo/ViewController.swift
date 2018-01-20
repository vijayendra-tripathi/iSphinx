//
//  ViewController.swift
//  iSphinxDemo
//
//  Created by Saiful I. Wicaksana on 19/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import UIKit
import iSphinx

class ViewController: UIViewController, iSphinxDelegete, UITextFieldDelegate {
    
    @IBOutlet weak var txtVocabularies: UITextField!
    @IBOutlet weak var txtWordDistractor: UITextField!
    @IBOutlet weak var btnUpdateVocabularies: UIButton!
    @IBOutlet weak var btnStartRecognizer: UIButton!
    @IBOutlet weak var btnPlayAudio: UIButton!
    @IBOutlet weak var lblUnsupportedWords: UILabel!
    @IBOutlet weak var lblPartialResult: UILabel!
    @IBOutlet weak var lblFinalResult: UILabel!
    
    fileprivate var isphinx: iSphinx = iSphinx()
    fileprivate var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtVocabularies.delegate = self
        self.txtWordDistractor.delegate = self
        self.isphinx.delegete = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupProgress()
        self.indicator.startAnimating()
        self.isphinx.prepareISphinx(onPreExecute: { (config) in
            // You can add new parameter pocketshinx here
            self.isphinx.silentToDetect = 1.0
            self.isphinx.isStopAtEndOfSpeech = false
            // config.setString(key: "-parameter", value: "value")
        }) { (isSuccess) in
            if isSuccess {
                self.indicator.stopAnimating()
                print("Preparation success!")
            }
        }
    }
    
    fileprivate func setupProgress() {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.frame = self.view.frame
        indicator.center = self.view.center
        self.navigationController?.view.addSubview(indicator)
        indicator.backgroundColor = .black
        indicator.alpha = 0.5
        indicator.bringSubview(toFront: (self.navigationController?.view)!)
        indicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleTopMargin]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    @IBAction func btnUpdateVocabularyOnTouch(_ sender: Any) {
        lblPartialResult.text = ""
        lblFinalResult.text = ""
        lblUnsupportedWords.text = ""
        indicator.startAnimating()
        isphinx.updateVocabulary(text: txtVocabularies.text!, oovWords: txtWordDistractor.text!.components(separatedBy: " ")) {
            self.indicator.stopAnimating()
        }
    }
    
    @IBAction func btnStartRecognizerOnTouch(_ sender: Any) {
        lblPartialResult.text = ""
        lblFinalResult.text = ""
        lblUnsupportedWords.text = ""
        /** Start speech recognition with timeout */
        isphinx.startISphinx(timeoutInSec: 10)
        /** Start speech recognition without timeout */
//        isphinx.startISphinx()
    }
    
    @IBAction func btnPlayAudioOnTouch(_ sender: Any) {
        isphinx.getRecorder().play {
            print("Play audio finished!")
        }
    }
    

    func iSphinxDidStop(reason: String, code: Int) {
        if code == 500 { // 500 code for error
            print(reason)
        } else if code == 522 { // 522 code for timed out
            print(reason)
        } else if code == 200 { // 200 code for finish speech
            print(reason)
        }
    }
    
    func iSphinxFinalResult(result: String, hypArr: [String], scores: [Double]) {
        lblFinalResult.text = result
        for score in scores {
            print("score: \(score)")
        }
    }
    
    func iSphinxPartialResult(partialResult: String) {
        lblPartialResult.text = partialResult
    }
    
    func iSphinxUnsupportedWords(words: [String]) {
        var unsuportedWords: String = ""
        for word in words {
            unsuportedWords += "\(word), "
        }
        lblUnsupportedWords.text = unsuportedWords
    }
    
    func iSphinxDidSpeechDetected() {
        print("Speech detected!")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


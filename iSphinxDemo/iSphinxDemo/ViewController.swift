//
//  ViewController.swift
//  iSphinxDemo
//
//  Created by Saiful I. Wicaksana on 19/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import UIKit
import iSphinx

class ViewController: UIViewController, iSphinxDelegete {
    
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
        self.setupProgress()
        self.isphinx.delegete = self
        self.indicator.startAnimating()
        self.isphinx.prepareISphinx(onPreExecute: { (config) in
            
        }) { (isSuccess) in
            if isSuccess {
                self.indicator.stopAnimating()
            }
        }
    }
    
    fileprivate func setupProgress() {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40, height: 40)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubview(toFront: view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    @IBAction func btnUpdateVocabularyOnTouch(_ sender: Any) {
        indicator.startAnimating()
        isphinx.updateVocabulary(text: txtVocabularies.text!) {
            self.indicator.stopAnimating()
        }
    }
    
    @IBAction func btnStartRecognizerOnTouch(_ sender: Any) {
        isphinx.startISphinx(timeoutInSec: 10)
    }
    
    @IBAction func btnPlayAudioOnTouch(_ sender: Any) {
        
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
    }
    
    func iSphinxPartialResult(partialResult: String) {
        lblPartialResult.text = partialResult
    }
    
    func iSphinxUnsupportedWords(words: [String]) {
        var unsuportedWords: String = ""
        for word in words {
            unsuportedWords += "\(word) "
        }
        lblUnsupportedWords.text = unsuportedWords
    }
    
    func iSphinxDidSpeechDetected() {
        print("Speech detected!")
    }

}


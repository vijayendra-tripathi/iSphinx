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
    
    var isphinx: iSphinx = iSphinx()

    override func viewDidLoad() {
        super.viewDidLoad()
        isphinx.delegete = self
        isphinx.prepareISphinx(onPreExecute: { (config) in
            
        }) { (isSuccess) in
            
        }
        
        isphinx.updateVocabulary(text: "") {
            
        }
        
        isphinx.startISphinx(timeoutInSec: 10)
        // Do any additional setup after loading the view, typically from a nib.
    }

    func iSphinxDidStop(reason: String, code: Int) {
        
    }
    
    func iSphinxFinalResult(result: String, hypArr: [String], scores: [Double]) {
        
    }
    
    func iSphinxPartialResult(partialResult: String) {
        
    }
    
    func iSphinxUnsupportedWords(words: [String]) {
        
    }
    
    func iSphinxDidSpeechDetected() {
        
    }

}


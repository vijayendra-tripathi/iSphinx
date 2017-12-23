//
//  iSphinxDelegete.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 19/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

public protocol iSphinxDelegete {
    // 500 code for error,  522 code for timed out,  200 code for finish speech
    func iSphinxDidStop(reason: String, code: Int);
    func iSphinxFinalResult(result: String, hypArr: [String], scores: [Double]);
    func iSphinxPartialResult(partialResult: String);
    func iSphinxUnsupportedWords(words: [String]);
    func iSphinxDidSpeechDetected();
}

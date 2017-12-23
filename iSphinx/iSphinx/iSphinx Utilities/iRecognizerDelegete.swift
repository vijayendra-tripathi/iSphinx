//
//  iRecognizerDelegete.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 22/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

internal protocol iRecognizerDelegete {
    func onBeginningOfSpeech()
    func onEndOfSpeech()
    func onSilent()
    func onPartialResult(hyp: Hypothesis?)
    func onResult(hyp: Hypothesis?)
    func onError(errorDesc: String)
    func onTimeout()
}

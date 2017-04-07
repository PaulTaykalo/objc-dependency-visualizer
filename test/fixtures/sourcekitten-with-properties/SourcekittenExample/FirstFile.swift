//
//  MainClass.swift
//  SourcekittenExample
//
//  Created by Paul Taykalo on 3/4/17.
//  Copyright © 2017 Paul Taykalo. All rights reserved.
//

import Foundation


protocol Protocol1 { }
class Protocol1Impl: Protocol1 {}

class Class1 {
    var p: Protocol1 = Protocol1Impl()
}





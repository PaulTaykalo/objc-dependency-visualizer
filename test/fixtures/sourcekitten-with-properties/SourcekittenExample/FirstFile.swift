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

protocol Protocol2 { }
class Protocol2Impl: Protocol2 {}

class Class1 {
    var p1: Protocol1 = Protocol1Impl()
    var p2: Protocol2? = Protocol2Impl()
    var p3: Int = 123
    var p4: Double = 24
    var p5: [Int] = [26]
    var p6: Any = 17
}


class ClassWithFunctions {

    func funcWithParam(item: Protocol1) {}
    func funcWithReturnValue() -> Protocol2 {
        return Protocol2Impl()
    }

}





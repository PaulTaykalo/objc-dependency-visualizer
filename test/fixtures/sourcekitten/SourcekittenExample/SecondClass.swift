//
//  SecondClass.swift
//  SourcekittenExample
//
//  Created by Paul Taykalo on 3/6/17.
//  Copyright © 2017 Paul Taykalo. All rights reserved.
//

import Foundation

protocol SecondClassProtocol {}


class ThirdClass {}

class SecondClass: MainClass, AwesomeProtocol, SecondClassProtocol {

    func createMainClass() {
       // This one won't be visible by sourcekitten :(
       let thirdInstance = ThirdClass()
       print("Instance created \(thirdInstance)")
    }

}

//
//  SecondClass.swift
//  SourcekittenExample
//
//  Created by Paul Taykalo on 3/6/17.
//  Copyright © 2017 Paul Taykalo. All rights reserved.
//

import Foundation
import UIKit

protocol ProtocolForGeneric {}
protocol ProtocolForGeneric2 {}

class GenericClass<A:ProtocolForGeneric> {}
class GenericClass2<B:ProtocolForGeneric & ProtocolForGeneric2> {}
class GenericClass3<C:ProtocolForGeneric, D:ProtocolForGeneric2> {}


class TheButton: UIButton {}

class GenericClassWithProp<E:ProtocolForGeneric> {
    var item: E
    init(item:E) {
        self.item = item
    }
}

protocol ProtocolWithGenericFunction {
    func genericFunction<F>(item:F) -> F
    func genericFunction2<G:ProtocolForGeneric2>(item:G) -> G
}

protocol ProtocolForTypeAlias {}

public class ClassWithTypeaLias {
    typealias H = ProtocolForTypeAlias
    var item: (H) -> () = {_ in}
}

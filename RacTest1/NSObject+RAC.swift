//
//  NSObject+RAC.swift
//
//  Created by Nahuel Marisi on 2016-06-06.
//  Copyright © 2016 TechBrewers. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

extension NSObject {
    func rac_WillDeallocSignalProducer() -> SignalProducer<(), NoError>{
        return self.rac_willDeallocSignal()
            .toSignalProducer()
            .flatMapError { _ in SignalProducer<AnyObject?, NoError>.empty}
            .map {_ in ()}
    }
}
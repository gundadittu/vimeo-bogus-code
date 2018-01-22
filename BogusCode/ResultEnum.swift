//
//  ResultEnum.swift
//  BogusCode
//
//  Created by Aditya Gunda on 1/20/18.
//  Copyright © 2018 Vimeo. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(NSError)
}

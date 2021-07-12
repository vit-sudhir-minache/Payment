//
//  PaymentInitiatorModel.swift
//  Payment
//
//  Created by DEV27 on 21/10/19.
//  Copyright © 2020 myApps. All rights reserved.
//

import Foundation

public struct PaymentInitiatorModel:Codable {
    let requestUrl:String?
    let redirectUrl:String?
    public var orderId:String?
    
    enum CodingKeys:String,CodingKey {
        case requestUrl,redirectUrl
        case orderId = "orderNumber"
    }
}

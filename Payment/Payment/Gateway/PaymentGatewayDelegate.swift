//
//  PaymentGatewayDelegate.swift
//  Payment
//
//  Created by DEV27 on 21/10/19.
//  Copyright © 2020 myApps. All rights reserved.
//

import Common

public protocol PaymentGatewayDelegate {
    func didFailWithError(_ error:CustomError)
}

public protocol PaymentSuccessDelegate {
    func didSucceed()
}

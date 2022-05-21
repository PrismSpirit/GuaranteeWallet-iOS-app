//
//  JWTClaims.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/03/04.
//

import Foundation
import SwiftJWT

struct QRClaims: Claims {
    let tid: Int
    let owner: String
    let exp: Date
}

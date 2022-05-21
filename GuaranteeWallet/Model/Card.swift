//
//  Card.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/02/21.
//

import Foundation

struct Card: Identifiable, Hashable {
    var id: Int
    var tokenID: String
    var logoImg: String
    var brand: String
    var productName: String
    var buildDate: String
    var expireDate: String
    var details: String
}

var cardColorList: [String] = ["CardColor_1", "CardColor_2", "CardColor_3", "CardColor_4", "CardColor_5", "CardColor_6"]

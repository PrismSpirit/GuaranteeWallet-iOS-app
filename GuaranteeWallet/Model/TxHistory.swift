//
//  TxHistory.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/04/19.
//

import Foundation

struct TxHistory: Identifiable, Hashable {
    let id: Int
    let txType: String
    let tokenID: Int
    let tokenFrom: String?
    let tokenTo: String
    let eventTime: String
}

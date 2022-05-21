//
//  TabViewModel.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/02/23.
//

import SwiftUI

var customerTabs = ["Show", "Verify", "History", "More"]
var resellerTabs = ["Show", "Approve", "Verify", "History", "More"]
var manufacturerTabs = ["Show", "Verify", "Mint", "History", "More"]

class TabViewModel: ObservableObject {
    @Published var currentTab: String = "Show"
    @Published var cardType: String?
    @Published var currentCard: Card?
    @Published var showDetail: Bool = false
}

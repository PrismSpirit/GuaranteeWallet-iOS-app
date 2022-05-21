//
//  tabButton.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/04/29.
//

import SwiftUI

struct tabButton: View {
    var title: String
    
    @EnvironmentObject var tabData: TabViewModel
    @Binding var showSendSheet: Bool
    @Binding var showWalletSheet: Bool
    
    var body: some View {
        Button(action: {
            withAnimation {
                if !showSendSheet && !showWalletSheet {
                    tabData.currentTab = title
                }
            }
        }) {
            VStack(spacing: 2) {
                Image(systemName: toImgName(tab: title))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(tabData.currentTab == title ? Color("AccentColor") : .white.opacity(0.6))
                    .frame(width: 25, height: 25)
                    .padding(.top, 10)
                Text(title)
                    .font(.system(size: 9))
                    .fontWeight(.semibold)
                    .foregroundColor(tabData.currentTab == title ? Color("AccentColor") : .white.opacity(0.6))
                    .padding(.bottom, 18)
            }
        }
    }
}

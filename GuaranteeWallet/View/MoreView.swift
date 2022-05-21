//
//  MoreView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/02/08.
//

import SwiftUI

struct MoreView: View {
    @AppStorage("AccessToken") var AccessToken: String!
    
    @Binding var isValidAccessToken: Bool
    
    var body: some View {
        Button(action: {
            AccessToken = ""
            isValidAccessToken = false
        }) {
            Text("Log out")
                .foregroundColor(.red)
        }
    }
}

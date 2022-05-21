//
//  ContentView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/01/24.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    @AppStorage("AccessToken") var AccessToken: String = ""
    @AppStorage("WalletAddress") var WalletAddress: String = ""
    @AppStorage("PUKey") var PUKey: String = ""
    
    @State var isValidAccessToken: Bool = false
    @State var userInfo: UserInfo?

    // When AccessToken is empty
    @ViewBuilder
    var body: some View {
        if isValidAccessToken {
            if userInfo != nil {
                switch userInfo!.userType {
                case "manufacturer":
                    ManufacturerView(isValidAccessToken: $isValidAccessToken)
                case "reseller":
                    ResellerView(isValidAccessToken: $isValidAccessToken)
                case "customer":
                    CustomerView(isValidAccessToken: $isValidAccessToken)
                default:
                    LoginView(isValidAccessToken: $isValidAccessToken, userInfo: $userInfo)
                }
            } else {
                LoginView(isValidAccessToken: $isValidAccessToken, userInfo: $userInfo)
            }
        } else {
            LoginView(isValidAccessToken: $isValidAccessToken, userInfo: $userInfo)
                .task {
                    do {
                        isValidAccessToken = try await AppNetworking.shared.validateAccessToken(accessToken: AccessToken)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
        }
    }
}

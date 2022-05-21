//
//  TokenDetailView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/02/23.
//

import SwiftUI

struct TokenDetailView: View {
    @EnvironmentObject var tabData: TabViewModel
    
    var animation: Namespace.ID
    
    @State var showData: Bool = false
    @State var isQRLoading: Bool = false
    @State var uiImage: UIImage? = nil
    @Binding var clickBan: Bool
    
    @AppStorage("AccessToken") var AccessToken: String!
    @AppStorage("WalletAddress") var WalletAddress: String!
    
    var body: some View {
        if let card = tabData.currentCard, tabData.showDetail {
            VStack {
                ZStack {
                    GuaranteeCardView(card: card)
                        .padding()
                        .matchedGeometryEffect(id: "\(tabData.cardType!)\(card.id)Card", in: animation)
                    
                    SendButton()
                        .matchedGeometryEffect(id: "\(tabData.cardType!)\(card.id)Send", in: animation)
                        .opacity(0)
                        .offset(x: 125, y: -80)
                    
                    Button(action: {
                        clickBan = true
                        
                        withAnimation(.spring()) {
                            tabData.currentCard = nil
                            tabData.cardType = nil
                            tabData.showDetail = false
                        }
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("AccentColor"))
                            .padding(10)
                            .background(Color("BGColor"), in: Circle())
                    })
                    .opacity(showData ? 1 : 0)
                    .offset(x: 145, y: -95)
                    
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        if tabData.cardType == "G" {
                            if uiImage != nil {
                                Image(uiImage: uiImage!)
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.width * 0.5, alignment: .center)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            else {
                                ProgressView()
                                    .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.width * 0.5, alignment: .center)
                            }
                        }
                        
                        HStack {
                            Text("BuiltDate")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                            Text(card.buildDate)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                        }
                        Text(card.details)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .opacity(showData ? 1 : 0)
                    .padding()
                }
                .task {
                    if tabData.cardType == "G" {
                        do {
                            isQRLoading = true
                            uiImage = try await AppNetworking.shared.loadQRCode(accessToken: AccessToken, tokenID: Int(card.tokenID) ?? -1, tokenOwner: WalletAddress)
                            isQRLoading = false
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            .background(Color("BGColor"))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation {
                        showData = true
                    }
                }
            }
            .onDisappear {
                withAnimation {
                    showData = false
                    isQRLoading = false
                    uiImage = nil
                    clickBan = false
                }
            }
        }
    }
}

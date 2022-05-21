//
//  ShowGuaranteeView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/02/08.
//

import SwiftUI

struct ShowGuaranteeView: View {
    @EnvironmentObject var tabData: TabViewModel
    
    var animation: Namespace.ID
    
    @State var isLoading: Bool = false
    @Binding var cards: [Card]
    @Binding var showSendSheet: Bool
    @Binding var showWalletSheet: Bool
    @Binding var clickBan: Bool
    
    @AppStorage("AccessToken") var AccessToken: String!
    @AppStorage("WalletAddress") var WalletAddress: String!
    
    var body: some View {
        VStack {
            TokenScrollRefreshable(showWalletSheet: $showWalletSheet, title: "Pull Down To Reload", tintColor: Color("AccentColor"), content: {
                ForEach(cards) { card in
                    ZStack {
                        Button {
                            withAnimation(.spring()) {
                                if !showSendSheet && !showWalletSheet && tabData.currentTab == "Show" && !clickBan {
                                    tabData.currentCard = card
                                    tabData.cardType = "G"
                                    tabData.showDetail = true
                                }
                            }
                        } label: {
                            DrawCardView(card: card)
                        }
                        .buttonStyle(CardButtonStyle())
                        
                        Button {
                            withAnimation(.spring()) {
                                if !tabData.showDetail && !showWalletSheet && tabData.currentTab == "Show" {
                                    showSendSheet = true
                                    tabData.currentCard = card
                                    tabData.cardType = "G"
                                }
                            }
                        } label: {
                            DrawSendButton(card: card)
                        }
                        .offset(x: 125, y: -80)
                        .buttonStyle(SendButtonStyle())
                    }
                }
            }) {
                do {
                    isLoading = true
                    cards = try await AppNetworking.shared.getTokenInfo(accessToken: AccessToken, wallet: WalletAddress)[0]
                    isLoading = false
                } catch let error {
                    debugPrint(error.localizedDescription)
                    isLoading = false
                }
            }
        }
        .task {
            do {
                isLoading = true
                cards = try await AppNetworking.shared.getTokenInfo(accessToken: AccessToken, wallet: WalletAddress)[0]
                isLoading = false
            } catch let error {
                debugPrint(error.localizedDescription)
                isLoading = false
            }
        }
    }
    
    @ViewBuilder
    func DrawCardView(card: Card) -> some View {
        if tabData.showDetail && tabData.currentCard == card {
            GuaranteeCardView(card: card)
                .padding()
                .opacity(0)
        }
        else {
            GuaranteeCardView(card: card)
                .padding()
                .matchedGeometryEffect(id: "G\(card.id)Card", in: animation)
        }
    }
    
    @ViewBuilder
    func DrawSendButton(card: Card) -> some View {
        if tabData.showDetail && tabData.currentCard == card {
            
        }
        else {
            SendButton()
                .matchedGeometryEffect(id: "G\(card.id)Send", in: animation)
        }
    }
}

//
//  ShowApprovedView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/05/06.
//

import SwiftUI

struct ShowApprovedView: View {
    @EnvironmentObject var tabData: TabViewModel
    
    var animation: Namespace.ID

    @State var isLoading: Bool = false
    @Binding var approved_cards: [Card]
    @Binding var showSendSheet: Bool
    @Binding var clickBan: Bool

    @AppStorage("AccessToken") var AccessToken: String!
    @AppStorage("WalletAddress") var WalletAddress: String!

    var body: some View {
        VStack {
            ApprovedScrollRefreshable(title: "Pull Down To Reload", tintColor: Color("AccentColor"), content: {
                ForEach(approved_cards) { card in
                    ZStack {
                        Button {
                            withAnimation(.spring()) {
                                if !showSendSheet && tabData.currentTab == "Approve" && !clickBan {
                                    tabData.currentCard = card
                                    tabData.cardType = "A"
                                    tabData.showDetail = true
                                }
                            }
                        } label: {
                            DrawCardView(card: card)
                        }
                        .buttonStyle(CardButtonStyle())
                        
                        Button {
                            withAnimation(.spring()) {
                                if !tabData.showDetail && tabData.currentTab == "Approve" {
                                    showSendSheet = true
                                    tabData.currentCard = card
                                    tabData.cardType = "A"
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
                    approved_cards = try await AppNetworking.shared.getTokenInfo(accessToken: AccessToken, wallet: WalletAddress)[1]
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
                approved_cards = try await AppNetworking.shared.getTokenInfo(accessToken: AccessToken, wallet: WalletAddress)[1]
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
                .matchedGeometryEffect(id: "\(card.tokenID)Card", in: animation)
        }
    }
    
    @ViewBuilder
    func DrawSendButton(card: Card) -> some View {
        if tabData.showDetail && tabData.currentCard == card {
            
        }
        else {
            SendButton()
                .matchedGeometryEffect(id: "\(card.tokenID)Send", in: animation)
        }
    }
}

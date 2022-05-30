//
//  HistoryView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/03/23.
//

import SwiftUI

struct HistoryView: View {
    @AppStorage("AccessToken") var AccessToken: String!
    @AppStorage("WalletAddress") var WalletAddress: String!
    
    @State var histories: [TxHistory] = []
    @State var clickedHistoryID: Int? = nil
    
    var body: some View {
        VStack {
            HistoryScrollRefreshable(title: "Pull Down to Reload", tintColor: Color("AccentColor"), content: {
                ForEach(histories) { history in
                    DrawHistoryCard(history: history)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if clickedHistoryID != nil {
                                if (clickedHistoryID != history.id) {
                                    clickedHistoryID = history.id
                                }
                                else {
                                    clickedHistoryID = nil
                                }
                            }
                            else {
                                clickedHistoryID = history.id
                            }
                        }
                    
                    if (clickedHistoryID == history.id) {
                        VStack {
                            if history.tokenFrom != nil {
                                Text("From.")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
        
                                Text(history.tokenFrom!)
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 1)
                            }
        
                            Text("To.")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
        
//                            Text(history.tokenTo != nil ? history.tokenTo! : "")
//                                .font(.footnote)
//                                .foregroundColor(.white)
                            Text(history.tokenTo)
                                .font(.footnote)
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }
            }) {
                do {
                    histories = try await AppNetworking.shared.loadHistory(accessToken: AccessToken, address: WalletAddress)
                    histories.reverse()
                } catch let error {
                    debugPrint(error.localizedDescription)
                }
            }
        }
        .task {
            do {
                histories = try await AppNetworking.shared.loadHistory(accessToken: AccessToken, address: WalletAddress)
                histories.reverse()
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
        
    }
    
    @ViewBuilder
    func DrawHistoryCard(history: TxHistory) -> some View {
        HistoryCardView(history: history)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

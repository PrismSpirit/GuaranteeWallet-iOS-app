//
//  HistoryCardView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/04/18.
//

import SwiftUI

struct HistoryCardView: View {
    var history: TxHistory
    
    var body: some View {
        ZStack {            
            VStack {
                HStack {
                    Text(history.txType)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("\(history.txType)HistoryTextColor"))
                        .padding(.leading, 5)
                    
                    Spacer()
                    
                    Text("No. \(history.tokenID)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.trailing, 5)
                }
                
                HStack {
                    Spacer()
                    
                    Text(history.eventTime)
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(.trailing, 5)
                }
                .padding(.bottom, 4)
                
//                Capsule()
//                    .frame(width: UIScreen.main.bounds.width * 0.92, height: 0.5)
//                    .foregroundColor(.white)
//                    .padding(.bottom)
                
                VStack(alignment: .leading) {
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
                    
                    Text(history.tokenTo != nil ? history.tokenTo! : "")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .padding()
    }
}

//
//  GuaranteeCardView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/02/24.
//

import SwiftUI

struct GuaranteeCardView: View {
    var card: Card
    
    init(card: Card?) {
        if card != nil {
            self.card = card!
        } else {
            self.card = Card(id: -1,
                             tokenID: "???",
                             logoImg: "",
                             brand: "???",
                             productName: "???",
                             buildDate: "????-??-??",
                             expireDate: "????-??-??",
                             details: "???")
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Int(card.id) >= 0 ? Color("\(cardColorList[Int(card.id) % 6])") : Color("CardColor_Unknown"))

            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("No. \(card.tokenID)")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("\(card.productName)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)

                HStack {
                    HStack {
                        Image("logo_Apple")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 45, height: 45)
//                            .clipShape(Circle())

                        Text("\(card.brand)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)

                    VStack(alignment: .trailing) {
                        Text("Expire Date")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("\(card.expireDate)")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
            .frame(maxHeight: .infinity, alignment: .top)
            .frame(maxWidth: .infinity, alignment: .leading)

            Circle()
                .stroke(.white.opacity(0.5), lineWidth: 18)
                .offset(x: 130, y: -90)
            Circle()
                .stroke(.white.opacity(0.5), lineWidth: 18)
                .offset(x: 170, y: 120)
    //            Circle()
        }
        .clipped()
        .frame(height: 250)
//        .frame(height: UIScreen.main.bounds.width / 1.618)
//        .padding()
    }
}

//struct GuaranteeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        GuaranteeCardView(card: Card(id: 1, tokenID: "dd", LogoImg: "dd", Brand: "dd", ProductName: "dd", BuildDate: "dd", ExpireDate: "dd", Details: "dd"))
//    }
//}

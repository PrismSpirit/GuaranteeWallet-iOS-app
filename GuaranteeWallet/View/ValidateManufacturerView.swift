//
//  ValidateManufacturerView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/06/06.
//

import SwiftUI

struct ValidateManufacturerView: View {
    @State var manuAddress: String = ""
    @Binding var scannedCard: Card?
    
    init(scannedCard: Binding<Card?>) {
        self._scannedCard = scannedCard
        
        let newAppearance = UINavigationBarAppearance()
        newAppearance.configureWithOpaqueBackground()
        newAppearance.backgroundColor = UIColor(Color("TabBarColor"))
        newAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = newAppearance
        UINavigationBar.appearance().compactAppearance = newAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = newAppearance
    }
    
    var body: some View {
        ZStack {
            Color("BGColor")
                .ignoresSafeArea(.all, edges: .all)
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("This is a")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Valid")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text("Manufacturer")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding()
                .padding(.vertical)
                
                VStack(alignment: .leading) {
                    Text("Address of Manufacturer:")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(manuAddress)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding()
                
                Text("This token is minted from a proper manufacturer.")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
            }
        }
        .task {
            do {
                manuAddress = try await AppNetworking.shared.getManufacturerAddress(tokenID: Int(value: scannedCard!.tokenID))
                print("fjiofsdoijfsidojfso")
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

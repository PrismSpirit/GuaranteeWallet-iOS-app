//
//  MintView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/04/20.
//

import SwiftUI

struct MintView: View {
    @AppStorage("AccessToken") var AccessToken: String!
    @AppStorage("WalletAddress") var WalletAddress: String!
    
    @Binding var cards: [Card]
    
    @Binding var isMintingToken: Bool
    @Binding var alertMintingSucceed: Bool
    @Binding var alertMintingFailed: Bool
    @State var walletPW: String = ""
    
    @State var productName: String = ""
    @State var details: String = ""
    @State private var productionDate = Date()
    @State private var expirationDate = Date()
    @State var loadKeyPadView: Bool = false
        
    var body: some View {
        VStack {
            HStack {
                Text("Mint Token")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.vertical, 15)
            
            HStack {
                Text("Product Name")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                
                Spacer()
            }
            
            HStack {
                TextField("Please enter product name", text: $productName)
                    .foregroundColor(.white)
            }
            .padding()
            .background(.white.opacity(0.05))
            .cornerRadius(15)
            .padding(.horizontal, 5)
            
            HStack {
                Text("Production Date")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                
                Spacer()
                
                DatePicker("", selection: $productionDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            .padding(.vertical)
            
            HStack {
                Text("Expiration Date")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                
                Spacer()
                
                DatePicker("", selection: $expirationDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            
            HStack {
                Text("Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                
                Spacer()
            }
            .padding(.top)
            
            HStack {
                TextEditor(text: $details)
                    .foregroundColor(.white)
            }
            .padding()
            .background(.white.opacity(0.05))
            .cornerRadius(15)
            .padding(.horizontal, 5)
            .padding(.bottom)
            .onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
            
            
            HStack {
                Button(action: {
                    loadKeyPadView = true
                }) {
                    Text("MINT TOKEN")
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width / 2)
                        .background(Color("AccentColor"))
                        .clipShape(Capsule())
                }
                .colorMultiply(productName != "" && details != "" ? .white : .gray)
                .disabled(!(productName != "" && details != ""))
            }
            .padding()
            
            Spacer()
        }
        .padding(.horizontal, 25)
        .background(Color("BGColor"))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        // KeyPadView
        .sheet(isPresented: $loadKeyPadView, onDismiss: {
            if walletPW.count == 8 {
                Task {
                    isMintingToken = true
                    print("MintView Activated!")
                    do {
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd"
                        
                        try await AppNetworking.shared.mintToken(accessToken: AccessToken,
                                                                 address: WalletAddress,
                                                                 productName: productName,
                                                                 productionDate: dateformatter.string(from: productionDate),
                                                                 expirationDate: dateformatter.string(from: expirationDate),
                                                                 details: details,
                                                                 walletPW: walletPW)
                        print("Minting Success!!!")
                        alertMintingSucceed = true
                        productName = ""
                        details = ""
                        productionDate = Date()
                        expirationDate = Date()
                        
                    } catch let error {
                        alertMintingFailed = true
                        print(error.localizedDescription)
                    }
                    walletPW = ""
                    isMintingToken = false
                    do {
                        cards = try await AppNetworking.shared.getTokenInfo(accessToken: AccessToken, wallet: WalletAddress)[0]
                    } catch let error {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
        }) {
            KeyPadView(loadKeyPadView: $loadKeyPadView, walletPW: $walletPW)
        }
    }
}

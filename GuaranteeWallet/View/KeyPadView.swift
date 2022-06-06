//
//  KeyPadView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/03/21.
//

import SwiftUI

var keypadNumbers: Array<Int> = [0,1,2,3,4,5,6,7,8,9]

struct KeyPadView: View {
    @Binding var loadKeyPadView: Bool
    @Binding var walletPW: String
    
    init(loadKeyPadView: Binding<Bool>, walletPW: Binding<String>) {
        keypadNumbers.shuffle()
        self._loadKeyPadView = loadKeyPadView
        self._walletPW = walletPW
        
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Text("Please Enter Your")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .kerning(0.25)
                
                Text("Wallet Password")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .kerning(0.25)
            }
            .padding()
            
            ZStack {
                HStack(spacing: 12) {
                    ForEach(0..<8) { _ in
                        Circle()
                            .stroke(lineWidth: 2)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                    }
                }
                
                HStack(spacing: 12) {
                    ForEach(0..<8) { n in
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .opacity(n + 1 <= walletPW.count ? 1 : 0)
                    }
                }
            }
            .padding()
            .padding(.vertical)
            
            VStack(spacing: 20) {
                ForEach(0..<3) { x in
                    HStack(spacing: 20) {
                        ForEach(0..<3) { y in
                            Button(action: {
                                HapticManager.instance.impact(style: .rigid)
                                
                                if walletPW.count < 8 {
                                    walletPW = walletPW + String(keypadNumbers[3 * x + y])
                                    if walletPW.count == 8 {
                                        loadKeyPadView = false
                                    }
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .frame(width: 85, height: 85)
                                        .foregroundColor(Color("KeyButtonColor"))
                                    
                                    Text("\(keypadNumbers[3 * x + y])")
                                        .font(.system(size: 34))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                HStack(spacing: 20) {
                    Circle()
                        .frame(width: 85, height: 85)
                        .foregroundColor(.clear)
                    
                    Button(action: {
                        HapticManager.instance.impact(style: .rigid)
                        
                        if walletPW.count < 8 {
                            walletPW = walletPW + String(keypadNumbers.last!)
                            if walletPW.count == 8 {
                                loadKeyPadView = false
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 85, height: 85)
                                .foregroundColor(Color("KeyButtonColor"))
                            
                            Text("\(keypadNumbers.last!)")
                                .font(.system(size: 34))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: {
                        HapticManager.instance.impact(style: .rigid)
                        
                        if walletPW.count != 0 {
                            walletPW = String(walletPW.dropLast())
                        }
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 85, height: 85)
                                .foregroundColor(Color("KeyButtonColor"))
                            
                            Image(systemName: "delete.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 26)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BGColor").edgesIgnoringSafeArea(.all))
    }
}

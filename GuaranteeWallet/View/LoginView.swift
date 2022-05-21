//
//  LoginView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/01/25.
//

import SwiftUI
import Alamofire

struct LoginView: View {
    @AppStorage("AccessToken") var AccessToken: String!
    @AppStorage("WalletAddress") var WalletAddress: String!
    @AppStorage("PUKey") var PUKey: String!
    
    @Binding var isValidAccessToken: Bool
    @Binding var userInfo: UserInfo?
    
    @State var isLoggingIn: Bool = false
    @State var alertLoginFailed: Bool = false
    
    @State var userID = ""
    @State var password = ""
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 35)
                .padding(.vertical)
            
            HStack {
                VStack(alignment: .leading, spacing: 12, content: {
                    Text("Log In")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Please sign in to continue")
                        .foregroundColor(.white.opacity(0.6))
                })
                
                Spacer(minLength: 0)
            }
            .padding()
            .padding(.leading, 15)
            
            HStack {
                Image(systemName: "person")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 35)
                
                TextField("User ID", text: $userID)
                    .foregroundColor(.white)
            }
            .padding()
            .background(.white.opacity(userID == "" ? 0 : 0.12))
            .cornerRadius(15)
            .padding(.horizontal)
            
            HStack {
                Image(systemName: "lock")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 35)
                
                SecureField("Password", text: $password)
                    .foregroundColor(.white)
            }
            .padding()
            .background(.white.opacity(password == "" ? 0 : 0.12))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top)
            
            Button(
                action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                    Task {
                        isLoggingIn = true
                        do {
                            AccessToken = try await AppNetworking.shared.signIn(userID: userID, password: password)
                            userInfo = try await AppNetworking.shared.getUserInfo(accessToken: AccessToken)
                            WalletAddress = userInfo!.userWallet
                            PUKey = userInfo!.publicKey
                            isValidAccessToken = true
                        } catch let error {
                            print(error.localizedDescription)
                            alertLoginFailed = true
                        }
                        isLoggingIn = false
                    }
                }, label: {
                Text("LOG IN")
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 150)
                    .background(Color("AccentColor"))
                    .clipShape(Capsule())
                }
            )
            .colorMultiply((userID != "" && password != "") ? .white : .gray)
            .disabled(!(userID != "" && password != ""))
            .padding(.top)
            
            Spacer(minLength: 0)
            
            HStack(spacing: 5) {
                Text("Don't have an account?")
                    .foregroundColor(Color.white.opacity(0.6))
                
                Button(action: {}, label: {
                    Text("Sign Up")
                        .fontWeight(.heavy)
                        .foregroundColor(Color("AccentColor"))
                })
                    .padding(.vertical)
                
            }
        }
        
        .background(Color("BGColor"))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .overlay(
            ProgressView("Logging in...")
                .progressViewStyle(.circular)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tint(.white)
                .foregroundColor(.white)
                .background(.black.opacity(0.4))
                .opacity(isLoggingIn ? 1 : 0)
        )
        .overlay(
            ZStack {
                Color(.black).opacity(0.4)

                VStack {
                    Text("Login Failed")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()

                    Text("Failed to log in")
                        .font(.title3)
                        .foregroundColor(.white)

                    Text("Please try again")
                        .font(.title3)
                        .foregroundColor(.white)

                    HStack {
                        Button(action: {
                            alertLoginFailed = false
                        }) {
                            Text("CONFIRM")
                                .fontWeight(.heavy)
                                .foregroundColor(.black)
                                .padding(.vertical)
                                .frame(width: UIScreen.main.bounds.width / 2.2)
                                .background(Color("AccentColor"))
                                .clipShape(Capsule())
                                .padding()
                        }
                    }
                }
                .padding()
                .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                .background(Color("BGColor").opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            .ignoresSafeArea(.all)
            .showIf(condition: alertLoginFailed)
        )
        .task {
            isLoggingIn = true
            if isValidAccessToken {
                do {
                    userInfo = try await AppNetworking.shared.getUserInfo(accessToken: AccessToken)
                    WalletAddress = userInfo!.userWallet
                    PUKey = userInfo!.publicKey
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            isLoggingIn = false
        }
    }
}

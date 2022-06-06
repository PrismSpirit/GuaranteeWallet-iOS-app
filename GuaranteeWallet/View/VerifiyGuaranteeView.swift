//
//  VerifiyGuaranteeView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/02/08.
//

import SwiftUI
import CodeScanner
import SwiftJWT

struct VerifiyGuaranteeView: View {
    @AppStorage("PUKey") var PUKey: String!
    @AppStorage("AccessToken") var AccessToken: String!
    
    @EnvironmentObject var tabData: TabViewModel
    @State var isScanned: Bool = false
    @State var scannedString: String = ""

    @State var validationResult: String? = nil
    @State var scannedCard: Card? = nil
    @State var scannedHistory: [String] = []
    
    @State var scannedOffset: CGFloat = 0
    @State var scannedLastOffset: CGFloat = 0
    @GestureState var scannedGestureOffset: CGFloat = 0
    
    var body: some View {
        VStack {
            if tabData.currentTab == "Verify" && isScanned == false {
                CodeScannerView(codeTypes: [.qr], showViewfinder: true) { response in
                    switch response {
                    case .success(let result):
                        scannedString = result.string
                        isScanned = true
                    case .failure(let error):
                        debugPrint(error.localizedDescription)
                    }
                }
                .ignoresSafeArea(.all, edges: .top)
            }
        }
        .fullScreenCover(isPresented: $isScanned, onDismiss: {
            scannedCard = nil
            validationResult = nil
        }) {
            ZStack {
                NavigationView() {
                    ZStack {
                        Color("BGColor")
                            .ignoresSafeArea(.all, edges: .all)

                        VStack {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    scannedCard = nil
                                    validationResult = nil
                                    isScanned = false
                                }) {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .foregroundColor(Color("AccentColor"))
                                        .frame(width: 15, height: 15)
                                        .padding(10)
                                        .background(Color("BGColor"), in: Circle())
                                }
                                .padding(.horizontal)
                                .padding(.top)
                            }
                            .padding(.bottom)

                            VStack {
                                if validationResult != nil {
                                    Image(systemName: validationResult! == "Valid" ? "checkmark.circle" : "xmark.circle")
                                        .resizable()
                                        .font(.largeTitle)
                                        .foregroundColor(validationResult! == "Valid" ? .green : .red)
                                        .frame(width: 170, height: 170)
                                        .padding()

                                    Text(validationResult!)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)

                                    VStack(spacing: 20) {
                                        HStack {
                                            Text("Token ID")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)

                                            Spacer()

                                            Text(scannedCard != nil ? scannedCard!.tokenID : "N/A")
                                                .font(.footnote)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal)

                                        HStack {
                                            Text("Name")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)

                                            Spacer()

                                            Text(scannedCard != nil ? scannedCard!.productName : "N/A")
                                                .font(.footnote)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal)

                                        HStack {
                                            Text("Brand")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)

                                            Spacer()

                                            if scannedCard != nil {
                                                NavigationLink {
                                                    ValidateManufacturerView(scannedCard: $scannedCard)
                                                        .navigationBarTitle("Validate Manufacuter", displayMode: .inline)
                                                } label: {
                                                    Text(scannedCard!.brand)
                                                        .font(.footnote)
                                                        .fontWeight(.semibold)
                                                        .underline()
                                                }
                                            }
                                            else {
                                                Text("N/A")
                                                    .font(.footnote)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.horizontal)

                                        HStack {
                                            Text("Production Date")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)

                                            Spacer()

                                            Text(scannedCard != nil ? scannedCard!.buildDate : "N/A")
                                                .font(.footnote)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal)

                                        HStack {
                                            Text("Expiration Date")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)

                                            Spacer()

                                            Text(scannedCard != nil ? scannedCard!.expireDate : "N/A")
                                                .font(.footnote)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal)

                                        HStack {
                                            Text("Details")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)

                                            Spacer()

                                            Text(scannedCard != nil ? scannedCard!.details : "N/A")
                                                .font(.footnote)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal)

                                        HStack {
                                            Text("Tx History")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)

                                            Spacer()

                                            if scannedCard != nil {
                                                NavigationLink {
                                                    TxHistoryView(txHistoryList: $scannedHistory)
                                                        .navigationBarTitle("Tx History", displayMode: .inline)
                                                } label: {
                                                    Text("Click me!")
                                                        .font(.footnote)
                                                        .fontWeight(.semibold)
                                                        .underline()
                                                }

                                            }
                                            else {
                                                Text("N/A")
                                                    .font(.footnote)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .padding()
                                }
                            }

                            Spacer()
                        }
                    }
                    .navigationBarHidden(true)
                }

            }
            .onAppear {
                if let verifyResult = try? verifyQRCode(base64String: scannedString) {
                    if verifyResult["result"] as! Bool {
                        Task {
                            if let resultOfVerify: [Any] = try? await AppNetworking.shared.verifyToken(accessToken: AccessToken,
                                                                                           tokenID: verifyResult["tid"] as! Int,
                                                                                           tokenOwner: verifyResult["owner"] as! String) {
                                scannedCard = resultOfVerify[0] as? Card
                                
                                for x in (resultOfVerify[1] as? [[String?]])! {
                                    scannedHistory.append(x[1]!)
                                }
                                
                                validationResult = "Valid"
                            }
                            else {
                                validationResult = "Invalid"
                            }
                        }
                    }
                    else {
                        validationResult = "Expired"
                    }
                }
                else {
                    validationResult = "Invalid"
                }
            }
        }
    }
    
    func scannedOnChange() {
        DispatchQueue.main.async {
            self.scannedOffset = scannedGestureOffset + scannedLastOffset
        }
    }
    
    func verifyQRCode(base64String: String) throws -> Dictionary<String, Any> {
        guard let decodedPUKeyData = Data(base64Encoded: PUKey) else {
            throw QRVerificationError.invalidQR
        }
        
        guard let decodedPUKeyString = String(data: decodedPUKeyData, encoding: .utf8) else {
            throw QRVerificationError.invalidQR
        }

        let jwtVerifier = JWTVerifier.rs256(publicKey: decodedPUKeyString.data(using: .utf8)!)
        
        if !JWT<QRClaims>.verify(scannedString, using: jwtVerifier) {
            throw QRVerificationError.invalidQR
        }
        
        let jwt = try! JWTDecoder(jwtVerifier: jwtVerifier).decode(JWT<QRClaims>.self, fromString: scannedString)

        if jwt.claims.exp < Date() {
            return ["result": false,
                    "tid": 0,
                    "owner": ""]
        }
        
        return ["result": true,
                "tid": jwt.claims.tid,
                "owner": jwt.claims.owner]
    }
}

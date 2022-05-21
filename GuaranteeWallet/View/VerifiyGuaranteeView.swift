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
    @State var scanResult: String = ""
    @State var showVerifyResult: Bool = false
    @State var scannedCard: Card? = nil
    
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
        .sheet(isPresented: $isScanned, onDismiss: {
            isScanned = false
            scannedCard = nil
            showVerifyResult = false
        }) {
            if let verifyResult = try? verifyQRCode(base64String: scannedString) {
                if verifyResult["result"] as! Bool {
                    VStack {
                        if showVerifyResult {
                            if scannedCard != nil {
                                VStack {
                                    Image(systemName: "checkmark.circle")
                                        .resizable()
                                        .font(.largeTitle)
                                        .foregroundColor(.green)
                                        .frame(width: 170, height: 170)
                                        .padding()
                                    
                                    HStack {
                                        Text("Valid")
                                            .font(.title2)
                                            .padding()
                                        
                                        Text("This is valid token")
                                            .font(.title2)
                                            .padding()
                                    }
                                }
                                
                                GuaranteeCardView(card: scannedCard!)
                                    .padding()
                            }
                            else {
                                VStack {
                                    Image(systemName: "xmark.circle")
                                        .resizable()
                                        .font(.largeTitle)
                                        .foregroundColor(.red)
                                        .frame(width: 170, height: 170)
                                        .padding()
                                    
                                    HStack {
                                        Text("Invalid")
                                            .font(.title2)
                                            .padding()
                                        
                                        Text("This is invalid token")
                                            .font(.title2)
                                            .padding()
                                    }
                                }
                            }
                        }
                    }
                    .task {
                        scannedCard = try? await AppNetworking.shared.verifyToken(accessToken: AccessToken, tokenID: verifyResult["tid"] as! Int, tokenOwner: verifyResult["owner"] as! String)
                        showVerifyResult = true
                    }
                }
                else {
                    VStack {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .frame(width: 170, height: 170)
                            .padding()

//                        GuaranteeCardView(card: )
                        
                        HStack {
                            Text("Expired")
                                .font(.title2)
                                .padding()

                            Text("fsijfodsj")
                                .font(.title2)
                                .padding()
                        }
                    }
                }
            }
            else {
                VStack {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .font(.largeTitle)
                        .foregroundColor(.red)
                        .frame(width: 170, height: 170)
                        .padding()
                    
                    HStack {
                        Text("Invalid")
                            .font(.title2)
                            .padding()
                        
                        Text("fsijfodsj")
                            .font(.title2)
                            .padding()
                    }
                }
            }
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
    
    func test(accessToken: String, tokenID: Int, tokenOwner: String) throws -> Card? {
//        Task {
//            if let aaa: Card = try! await AppNetworking.shared.verifyToken(accessToken: accessToken, tokenID: tokenID, tokenOwner: tokenOwner) {
//                return aaa
//            }
//        }
        
//        var c: Card? = nil
        
//        Task {
//            c = try? await AppNetworking.shared.verifyToken(accessToken: accessToken, tokenID: tokenID, tokenOwner: tokenOwner)
//        }
        print("task start")
        Task {
            return try? await AppNetworking.shared.verifyToken(accessToken: accessToken, tokenID: tokenID, tokenOwner: tokenOwner)
        }
        print("test end")
        
        return nil
    }
}

struct VerifiyGuaranteeView_Previews: PreviewProvider {
    static var previews: some View {
        VerifiyGuaranteeView()
    }
}

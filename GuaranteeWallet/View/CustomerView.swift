//
//  CustomerView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/02/08.
//

import SwiftUI
import CodeScanner
import EFQRCode

struct CustomerView: View {
    @StateObject var tabData = TabViewModel()
    
    var edges = UIApplication.shared.connectedScenes
                        .filter({$0.activationState == .foregroundActive})
                        .map({$0 as? UIWindowScene})
                        .compactMap({$0})
                        .first?.windows
                        .filter({$0.isKeyWindow}).first?.safeAreaInsets
    
    @Namespace var animation
    
    @State var showSendSheet: Bool = false
    @State var sendOffset: CGFloat = 0
    @State var sendLastOffset: CGFloat = 0
    @GestureState var sendGestureOffset: CGFloat = 0
    
    @State var showWalletSheet: Bool = false
    @State var walletOffset: CGFloat = 0
    @State var walletLastOffset: CGFloat = 0
    @GestureState var walletGestureOffset: CGFloat = 0
    
    @AppStorage("AccessToken") var AccessToken: String!
    @AppStorage("WalletAddress") var WalletAddress: String!
    @State var ToAddress: String = ""
    
    @State var activatePlaceHolder: Bool = false
    
    @State var loadKeyPadView: Bool = false
    @State var walletPW: String = ""
    
    @State private var addressFieldId: String = UUID().uuidString
    
    @State var clickBan: Bool = false
    
    @State var isSendingToken: Bool = false
    @State var isLoadingToken: Bool = false
    @State var alertSendingFailed: Bool = false
    @State var alertSendingSucceed: Bool = false
    
    @State var cards: [Card] = []
    
    @Binding var isValidAccessToken: Bool
    
    init(isValidAccessToken: Binding<Bool>) {
        self._isValidAccessToken = isValidAccessToken
        cardColorList.shuffle()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { _ in
                ZStack {
                    ShowGuaranteeView(animation: animation, cards: $cards, showSendSheet: $showSendSheet, showWalletSheet: $showWalletSheet, clickBan: $clickBan)
                        .environmentObject(tabData)
                        .opacity(tabData.currentTab == customerTabs[0] ? 1 : 0)
                    VerifiyGuaranteeView()
                        .environmentObject(tabData)
                        .opacity(tabData.currentTab == customerTabs[1] ? 1 : 0)
                    HistoryView()
                        .opacity(tabData.currentTab == customerTabs[2] ? 1 : 0)
                    MoreView(isValidAccessToken: $isValidAccessToken)
                        .opacity(tabData.currentTab == customerTabs[3] ? 1 : 0)
                }
            }
            HStack(spacing: 0) {
                ForEach(customerTabs, id: \.self) { tab in
                    tabButton(title: tab, showSendSheet: $showSendSheet, showWalletSheet: $showWalletSheet)

                    if tab != customerTabs.last {
                        Spacer(minLength: 0)
                    }
                }
            }
            .environmentObject(tabData)
            .padding(.horizontal, 30)
            .padding(.bottom, edges?.bottom == 0 ? 15 : edges?.bottom)
            .background(Color("TabBarColor"))
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color("BGColor"))
        .overlay(
            TokenDetailView(animation: animation, clickBan: $clickBan)
                .environmentObject(tabData)
        )
        .blur(radius: sendGetBlurRadius())
        .blur(radius: walletGetBlurRadius())
        // Block click when sheets are activated
        .overlay(
            ZStack {
                Color(UIColor(white: 1, alpha: 0)).ignoresSafeArea(.all)
            }
            .showIf(condition: showSendSheet || showWalletSheet)
        )
        // Sheet for sending token
        .overlay(
            GeometryReader { proxy -> AnyView in
                let height = proxy.frame(in: .global).height

                return AnyView(
                    ZStack {
                        BlurView(style: .systemThinMaterialDark)
                            .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 30))
                            .frame(height: UIScreen.main.bounds.height * 1.5)
                        
                        VStack {
                            Capsule()
                                .fill(.white)
                                .frame(width: 80, height: 4)
                                .padding(.top)
                            
                            HStack {
                                Text("Recipient's Address")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                            .padding(.top, 20)
                            
                            Capsule()
                                .frame(width: UIScreen.main.bounds.width * 0.92, height: 0.5)
                                .foregroundColor(.white)
                            
                            VStack {
                                HStack {
                                    HStack {
                                        Image(systemName: "paperplane")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .frame(width: 35)
                                                                                    
                                        TextField("Please Enter Address", text: $ToAddress)
                                            .foregroundColor(.white)
                                            .id(addressFieldId)
                                            .onTapGesture {
                                                
                                            }
                                    }
                                    .padding()
                                    .background(ToAddress == "" ? .white.opacity(0.12) : addressChecker(input: ToAddress) ? ToAddress != WalletAddress ? .green.opacity(0.4) : .red.opacity(0.4) : .red.opacity(0.4))
                                    .cornerRadius(15)
                                    .padding(.top)
                                
                                    Button(action: {
                                        activatePlaceHolder = true
                                    }) {
                                        Image(systemName: "qrcode.viewfinder")
                                            .resizable()
                                            .foregroundColor(.white)
                                            .frame(width: 35, height: 35)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal, 5)
                                    .padding(.trailing, 3)
                                }
                                
                                HStack {
                                    Image(systemName: ToAddress == "" ? "questionmark" : addressChecker(input: ToAddress) ? ToAddress != WalletAddress ? "checkmark" : "xmark" : "xmark")
                                        .font(.title2)
                                        .foregroundColor(ToAddress == "" ? .white.opacity(0) : addressChecker(input: ToAddress) ? ToAddress != WalletAddress ? .green : .red : .red)
                                        .frame(width: 35)

                                    
                                    Text(ToAddress == "" ? "" : addressChecker(input: ToAddress) ? ToAddress != WalletAddress ? "Valid Address Format" : "Receiver's address equals to sender's" : "Address should be 42 characters")
                                        .foregroundColor(ToAddress == "" ? .white.opacity(0) : addressChecker(input: ToAddress) ? ToAddress != WalletAddress ? .green : .red : .red)
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .frame(alignment: .leading)
                                    
                                    Spacer()
                                }
                                .frame(height: 25)
                                .padding(.horizontal)
                                
                                HStack {
                                    Text("Token Info to Send")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                .padding(.top, 20)
                                
                                Capsule()
                                    .frame(width: UIScreen.main.bounds.width * 0.92, height: 0.5)
                                    .foregroundColor(.white)
                                
                                GuaranteeCardView(card: tabData.currentCard)
                                    .padding(.top)
                                
                                Button(action: {
                                    loadKeyPadView = true
                                }) {
                                    Text("SEND")
                                        .fontWeight(.heavy)
                                        .foregroundColor(.black)
                                        .padding(.vertical)
                                        .frame(width: UIScreen.main.bounds.width / 2 - 50)
                                        .background(Color("AccentColor"))
                                        .clipShape(Capsule())
                                }
                                .colorMultiply(addressChecker(input: ToAddress) ? .white : .gray)
                                .disabled(!addressChecker(input: ToAddress))
                                .padding(.top, 20)
                            }
                        }
                        .padding(.horizontal)
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
//                        .offset(y: showSendSheet ? height - 265 : height + 100)
                        .offset(y: showSendSheet ? height - 640 : height + 100)
                    .offset(y: -sendOffset > 0 ? -1 * sqrt(-sendOffset) : sendOffset)
                    .gesture(DragGesture().updating($sendGestureOffset, body: {
                        value, out, _ in

                        out = value.translation.height
                        sendOnChange()
                    }).onEnded({ value in
                        withAnimation {
                            if sendOffset > 0 && sendOffset > 75 {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                tabData.currentCard = nil
                                tabData.cardType = nil
                                ToAddress = ""
                                showSendSheet = false
                            }
                            sendOffset = 0
                        }
                    }))
                    .onTapGesture {
                        addressFieldId = UUID().uuidString
                    }
                )
            }
            .ignoresSafeArea(.keyboard)
        )
        // Sheet for show my address QR
        .overlay(
            GeometryReader { proxy -> AnyView in
                let height = proxy.frame(in: .global).height

                return AnyView(
                    ZStack {
                        BlurView(style: .systemThinMaterialDark)
                            .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 30))
                            .frame(height: UIScreen.main.bounds.height * 1.5)

                        VStack {
                            Capsule()
                                .fill(.white)
                                .frame(width: 80, height: 4)
                                .padding(.top)

                            HStack {
                                Text("Share Your Wallet Address")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)

                                Spacer()
                            }
                            .padding(.top, 20)

                            Capsule()
                                .frame(width: UIScreen.main.bounds.width * 0.92, height: 0.5)
                                .foregroundColor(.white)
                            
                            Image(uiImage: UIImage.init(cgImage: EFQRCode.generate(for: WalletAddress)!))
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.width * 0.5, alignment: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding()
                            
                            Text("Scan this QR code to receive token")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                
                        }
                        .padding(.horizontal)
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .offset(y: showWalletSheet ? height - 360 : height + 100)
                    .offset(y: -walletOffset > 0 ? -1 * sqrt(-walletOffset) : walletOffset)
                    .gesture(DragGesture().updating($walletGestureOffset, body: {
                        value, out, _ in

                        out = value.translation.height
                        walletOnChange()
                    }).onEnded({ value in
                        withAnimation {
                            if walletOffset > 0 && walletOffset > 75 {
                                showWalletSheet = false
                            }
                            walletOffset = 0
                        }
                    }))
                )
            }
        )
        // Open QR Reader to read ToAddress
        .sheet(isPresented: $activatePlaceHolder, onDismiss: { activatePlaceHolder = false }) {
            CodeScannerView(codeTypes: [.qr], showViewfinder: true) { response in
                switch response {
                case .success(let result):
                    ToAddress = result.string
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
                activatePlaceHolder = false
            }
        }
        // KeyPadView for sending token
        .sheet(isPresented: $loadKeyPadView, onDismiss: {
            if walletPW.count == 8 {
                Task {
                    isSendingToken = true
                    do {
                        try await AppNetworking.shared.sendToken(accessToken: AccessToken,
                                                                 tokenOwner: WalletAddress,
                                                                 tokenReceiver: ToAddress,
                                                                 tokenID: Int(value: tabData.currentCard!.tokenID),
                                                                 walletPW: walletPW)
                        print("Sending Success!!!")
                        alertSendingSucceed = true
                        
                        withAnimation {
                            showSendSheet = false
                        }
                        sendOffset = 0
                        
                        tabData.currentCard = nil
                        tabData.cardType = nil
                        ToAddress = ""
                        showSendSheet = false
                        
                        isSendingToken = false
                        
                        isLoadingToken = true
                        
                        do {
                            cards = try await AppNetworking.shared.getTokenInfo(accessToken: AccessToken, wallet: WalletAddress)[0]
                        } catch let error {
                            debugPrint(error.localizedDescription)
                        }
                        
                        isLoadingToken = false
                    } catch let error {
                        alertSendingFailed = true
                        print(error.localizedDescription)
                    }
                    walletPW = ""
                    isSendingToken = false
                }
            }
        }) {
            KeyPadView(loadKeyPadView: $loadKeyPadView, walletPW: $walletPW)
        }
        // ProgressView Sending
        .overlay(
            ProgressView("Sending...")
                .progressViewStyle(.circular)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tint(.white)
                .foregroundColor(.white)
                .background(.black.opacity(0.4))
                .opacity(isSendingToken ? 1 : 0)
        )
        // Sending Success Alert
        .overlay(
            ZStack {
                Color(.black).opacity(0.4)
                
                VStack {
                    Text("Sending Succeed")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("Token sent successfully")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    HStack {
                        Button(action: {
                            ToAddress = ""
                            alertSendingSucceed = false
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
            .showIf(condition: alertSendingSucceed)
        )
        // Sending Fail Alert
        .overlay(
            ZStack {
                Color(.black).opacity(0.4)

                VStack {
                    Text("Sending Failed")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()

                    Text("Failed to send Token")
                        .font(.title3)
                        .foregroundColor(.white)

                    Text("Please try again")
                        .font(.title3)
                        .foregroundColor(.white)

                    HStack {
                        Button(action: {
                            alertSendingFailed = false
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
            .showIf(condition: alertSendingFailed)
        )
    }
    
    func sendOnChange() {
        DispatchQueue.main.async {
            self.sendOffset = sendGestureOffset + sendLastOffset
        }
    }
    
    func walletOnChange() {
        DispatchQueue.main.async {
            self.walletOffset = walletGestureOffset + walletLastOffset
        }
    }
    
    func sendGetBlurRadius() -> CGFloat {
        let progress: CGFloat

        if showSendSheet {
            if -sendOffset > 20 {
                progress = 120 / (UIScreen.main.bounds.height - 100)
            }
            else {
                progress = (100 - sendOffset) / (UIScreen.main.bounds.height - 100)
            }
        }
        else {
            progress = 0
        }

        return progress * 30
    }
    
    func walletGetBlurRadius() -> CGFloat {
        let progress: CGFloat

        if showWalletSheet {
            if -walletOffset > 20 {
                progress = 120 / (UIScreen.main.bounds.height - 100)
            }
            else {
                progress = (100 - walletOffset) / (UIScreen.main.bounds.height - 100)
            }
        }
        else {
            progress = 0
        }

        return progress * 30
    }
}

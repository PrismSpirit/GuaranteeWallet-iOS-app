//
//  ScrollRefreshableView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/04/18.
//

import SwiftUI

struct TokenScrollRefreshable<Content: View>: View {
    var content: Content
    var onRefresh: () async -> ()
    var showWalletSheet: Binding<Bool>
    
    init(showWalletSheet: Binding<Bool>, title: String, tintColor: Color, @ViewBuilder content: @escaping () -> Content, onRefresh: @escaping () async -> ()) {
        self.content = content()
        self.onRefresh = onRefresh
        self.showWalletSheet = showWalletSheet
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.6),
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10)
        ]
        UIRefreshControl.appearance().attributedTitle = NSAttributedString(string: title, attributes: attributes)
        UITableView.appearance().backgroundColor = .clear
//        UITableViewHeaderFooterView.appearance().backgroundView = .init()
    }
    
    var body: some View {
        List {
            Section(header:
                        HStack {
                            Text("Tokens")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring()) {
                                    showWalletSheet.wrappedValue = true
                                }
                            }) {
                                Image(systemName: "qrcode")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .frame(width: 35, height: 35)
                                    .padding(.trailing, 15)
                            }
                        }
                        .padding(.bottom, 5)
            ) {
                content
                    .listRowSeparatorTint(.clear)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .textCase(nil)
        }
        .listStyle(.grouped)
        .refreshable {
            await onRefresh()
        }
        .padding(.top, 1)
        .padding(.bottom, -35)
    }
}

struct HistoryScrollRefreshable<Content: View>: View {
    var content: Content
    var onRefresh: () async -> ()
    
    init(title: String, tintColor: Color, @ViewBuilder content: @escaping () -> Content, onRefresh: @escaping () async -> ()) {
        self.content = content()
        self.onRefresh = onRefresh
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.6),
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10)
        ]
        UIRefreshControl.appearance().attributedTitle = NSAttributedString(string: title, attributes: attributes)
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        List {
            Section(header:
                        HStack {
                            Text("History")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            
                            Spacer()
                        }
                        .padding(.bottom, 5)
            ) {
                content
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .textCase(nil)
        }
        .listStyle(.grouped)
        .refreshable {
            await onRefresh()
        }
        .padding(.top, 1)
        .padding(.bottom, -35)
    }
}

struct ApprovedScrollRefreshable<Content: View>: View {
    var content: Content
    var onRefresh: () async -> ()
    
    init(title: String, tintColor: Color, @ViewBuilder content: @escaping () -> Content, onRefresh: @escaping () async -> ()) {
        self.content = content()
        self.onRefresh = onRefresh
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.6),
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10)
        ]
        UIRefreshControl.appearance().attributedTitle = NSAttributedString(string: title, attributes: attributes)
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        List {
            Section(header:
                        HStack {
                            Text("Approved Tokens")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            
                            Spacer()
                        }
            ) {
                content
                    .listRowSeparatorTint(.clear)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .textCase(nil)
        }
        .listStyle(.grouped)
        .refreshable {
            await onRefresh()
        }
        .padding(.top, 1)
        .padding(.bottom, -35)
    }
}

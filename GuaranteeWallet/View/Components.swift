//
//  Components.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/04/29.
//

import SwiftUI

extension View {
   func showIf(condition: Bool) -> AnyView {
       if condition {
           return AnyView(self)
       } else {
           return AnyView(EmptyView())
       }
    }
}

func toImgName(tab: String) -> String {
    switch tab {
    case "Show":
        return "doc.text.fill"
    case "Approve":
        return "signature"
    case "Verify":
        return "doc.text.magnifyingglass"
    case "Mint":
        return "plus.diamond.fill"
    case "History":
        return "clock.arrow.circlepath"
    case "More":
        return "ellipsis"
    default:
        return ""
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}

func addressChecker(input: String) -> Bool {
    let pattern: String = "^0x[0-9|A-F|a-f]{40}$"
    
    if input.range(of: pattern, options: .regularExpression) != nil {
        return true
    }
    
    return false
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeIn, value: configuration.isPressed)
    }
}

struct SendButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeIn, value: configuration.isPressed)
    }
}

struct SendButton: View {
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color("BGColor"))
                .frame(width: 65, height: 65)
                .clipShape(Circle())
            Image(systemName: "paperplane.circle")
                .resizable()
                .frame(width: 55, height: 55)
                .foregroundColor(Color("AccentColor"))
                .clipShape(Circle())
        }
    }
}

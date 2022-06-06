//
//  TxHistoryView.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/06/03.
//

import SwiftUI
import StepperView

struct TxHistoryView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var txHistoryList: [String]
    @State var stepList: [CustomStepTextView] = []
    @State var indicatorList: [StepperIndicationType<AnyView>] = []
    @State var stepLifeCycleList: [StepLifeCycle] = []
    
    init(txHistoryList: Binding<[String]>) {
        self._txHistoryList = txHistoryList

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
            
            ScrollView() {
                StepperView()
                    .addSteps(stepList)
                    .indicators(indicatorList)
                    .lineOptions(StepperLineOptions.rounded(3, 8, .accentColor))
                    .stepLifeCycles(stepLifeCycleList)
                    .spacing(60)
                    .padding(.leading, 50)
                    .padding(.vertical, 30)
                    .padding(.top, 80)
            }
        }
        .ignoresSafeArea(.all, edges: .all)
        .background(Color("BGColor"))
        .onAppear {
            for txHistoryElement in txHistoryList {
                stepList.append(
                    CustomStepTextView(text: txHistoryElement)
                )
                indicatorList.append(
//                    StepperIndicationType.custom(IndicatorImageView(name: "completed").eraseToAnyView())
//                    StepperIndicationType.circle(.accentColor, 12)
                    StepperIndicationType.custom(IndicatorImageView().eraseToAnyView())
                )
                stepLifeCycleList.append(StepLifeCycle.completed)
            }
        }
//        .padding(.top, 1)
//        .padding(.bottom, 1)
    }
}

struct IndicatorImageView: View {
//    var name: String
    
    var body: some View {
        ZStack {
            Color("BGColor")
            
            Circle()
                .stroke(Color("AccentColor"), lineWidth: 3)
                .foregroundColor(Color("BGColor"))
                .frame(width: 20, height: 20)
        }
    }
}

struct CustomStepTextView: View {
    var text: String
    
    var body: some View {
        VStack {
            Text(text)
                .font(.system(size: 9))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
//                .offset(x: 0)
        }
    }
}

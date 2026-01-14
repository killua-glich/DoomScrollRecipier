//
//  ContentView.swift
//  DoomScrollRecipier
//
//  Created by Pandolfo Diego on 13.01.26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    @State private var pastedLink: String = ""

    @State var animate = false
    
    let gradientColors: [Color] = [
        .yellow.opacity(0.4),
        .mint.opacity(0.45),
        .yellow.opacity(0.4),
        .purple.opacity(0.9),
        .orange.opacity(0.9),
        .pink.opacity(0.9),
        .purple.opacity(0.9),
        .cyan.opacity(0.85),
        .purple.opacity(0.9),
        .pink.opacity(0.9),
        .orange.opacity(0.9),
        .yellow.opacity(0.4),
        .mint.opacity(0.45),
        .yellow.opacity(0.4)
    ]

    var body: some View {
        VStack {
            Text("Doom scroll Recipier").font(.system(.largeTitle, weight: .semibold))
        }

        //MARK: - Link Paste
        VStack(alignment: .center) {

            Spacer()

            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: UIScreen.main.bounds.width * 8.9, height: 400)
                .offset(
                    x: animate
                        ? UIScreen.main.bounds.width * -3.4
                        : UIScreen.main.bounds.width * 4
                )
                .animation(
                    .linear(duration: 15).repeatForever(autoreverses: false),
                    value: animate
                )
                .rotationEffect(.degrees(20)).rotationEffect(.degrees(180))
                .mask {
                    Text(viewModel.statusMessage).font(
                        .system(size: 35, weight: .bold)
                    )
                }
            }.onAppear{
                animate = true
            }

            Spacer()

            TextField("paste Link", text: $pastedLink).padding().glassEffect()

            Button(
                action: { print("test") }
            ) {
                Text("summerize recipe")
            }.buttonStyle(GlassButtonStyle()).glassEffect(.regular)
        }
        .padding()

        //MARK: History

        List {
            Section("History") {
                Text(
                    viewModel.summerizedHistory.first?.title
                        ?? "no saved recipies"
                )
                Text(
                    viewModel.summerizedHistory.first?.title
                        ?? "no saved recipies"
                )
            }

        }

    }
}

#Preview {
    ContentView()
}

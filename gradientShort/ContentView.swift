//
//  ContentView.swift
//  gradientShort
//
//  Created by Stephen Rivas on 11/7/25.
//

import SwiftUI

var colors = [
    Color.red,
    Color.orange,
    Color.yellow,
    Color.green,
    Color.blue,
    Color.purple,
    Color.mint,
    Color.pink,
    Color.indigo,
    Color.cyan
]

struct ContentView: View {
    @State var color1 = colors.randomElement()
    @State var color2 = colors.randomElement()
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [color1!, color2!], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            Button("Change Color") {
                color1 = colors.randomElement()
                color2 = colors.randomElement()
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue, in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    ContentView()
}

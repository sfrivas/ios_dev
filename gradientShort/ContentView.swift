//
//  ContentView.swift
//  gradientShort
//
//  Created by Stephen Rivas on 11/7/25.
//

import SwiftUI
import AudioToolbox

let colors = [
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
    @State private var color1: Color = colors.randomElement() ?? .red
    @State private var color2: Color = colors.randomElement() ?? .blue
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [color1, color2], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(formattedTime)
                    .font(.system(size: 64, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                
                HStack(spacing: 16) {
                    Button("Reset") {
                        resetTimer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    
                    Button(action: toggleTimer) {
                        Text(isRunning ? "Stop" : "Start")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 32)
                    .background(isRunning ? Color.yellow : Color.blue, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 24)
                
                HStack(alignment: .center, spacing: 32) {
                    Text("Work")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                    TimeWheel(label: "min", selection: $selectedMinutes)
                    TimeWheel(label: "sec", selection: $selectedSeconds)
                }
                .frame(height: 140)
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        playBeep()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
            if elapsedSeconds.isMultiple(of: 5) {
                playDoubleBeep()
            } else {
                playBeep()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    private func resetTimer() {
        guard !isRunning else { return }
        elapsedSeconds = 0
    }
    
    private func playBeep(after delay: TimeInterval = 0) {
        let play = {
            AudioServicesPlaySystemSound(1057) // short beep
        }
        
        if delay == 0 {
            play()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: play)
        }
    }
    
    private func playDoubleBeep() {
        playBeep()
        playBeep(after: 0.2)
    }
}

private struct TimeWheel: View {
    let label: String
    @Binding var selection: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Picker(label, selection: $selection) {
                ForEach(0..<60, id: \.self) { value in
                    Text("\(value)")
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(width: 80, height: 110)
            .clipped()
            
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

#Preview {
    ContentView()
}

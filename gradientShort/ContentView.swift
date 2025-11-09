//
//  ContentView.swift
//  gradientShort
//
//  Created by Stephen Rivas on 11/7/25.
//

import SwiftUI
import AudioToolbox

struct ContentView: View {
    @State private var remainingSeconds = 0
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var selectedInitialMinutes = 0
    @State private var selectedInitialSeconds = 0
    @State private var selectedWorkMinutes = 0
    @State private var selectedWorkSeconds = 0
    @State private var selectedRestMinutes = 0
    @State private var selectedRestSeconds = 0
    @State private var currentPhase: TimerPhase = .initial
    @State private var sequenceCompleted = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
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
                
                VStack(spacing: 12) {
                    TimeWheelRow(title: "Initial", minutes: $selectedInitialMinutes, seconds: $selectedInitialSeconds)
                    TimeWheelRow(title: "Work", minutes: $selectedWorkMinutes, seconds: $selectedWorkSeconds)
                    TimeWheelRow(title: "Rest", minutes: $selectedRestMinutes, seconds: $selectedRestSeconds)
                }
            }
            .onChange(of: selectedInitialMinutes, initial: false) { _, _ in
                syncRemaining(with: .initial)
            }
            .onChange(of: selectedInitialSeconds, initial: false) { _, _ in
                syncRemaining(with: .initial)
            }
            .onChange(of: selectedWorkMinutes, initial: false) { _, _ in
                syncRemaining(with: .work)
            }
            .onChange(of: selectedWorkSeconds, initial: false) { _, _ in
                syncRemaining(with: .work)
            }
            .onChange(of: selectedRestMinutes, initial: false) { _, _ in
                syncRemaining(with: .rest)
            }
            .onChange(of: selectedRestSeconds, initial: false) { _, _ in
                syncRemaining(with: .rest)
            }
        }
        .onDisappear {
            stopTimer()
        }
        .onAppear {
            remainingSeconds = seconds(for: currentPhase)
        }
    }
    
    private var formattedTime: String {
        let minutes = max(remainingSeconds, 0) / 60
        let seconds = max(remainingSeconds, 0) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var gradientColors: [Color] {
        switch currentPhase {
        case .initial:
            return [Color.blue.opacity(0.6), Color.blue]
        case .work:
            return [Color.green.opacity(0.6), Color.green]
        case .rest:
            return [Color.red.opacity(0.6), Color.red]
        }
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

        if sequenceCompleted {
            prepareForNewSequence(resetCompletion: true)
        }
        
        if remainingSeconds == 0 {
            advancePhaseOrFinish()
            if sequenceCompleted || remainingSeconds == 0 {
                return
            }
        }
        
        isRunning = true
        playBeep()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timerTick()
        }
    }
    
    private func stopTimer() {
        pauseTimer()
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    private func resetTimer() {
        guard !isRunning else { return }
        prepareForNewSequence(resetCompletion: true)
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
        playBeep(after: 0.1)
    }
    
    private func syncRemaining(with phase: TimerPhase) {
        guard !isRunning else { return }
        guard currentPhase == phase || (sequenceCompleted && phase == .initial) else { return }
        remainingSeconds = seconds(for: currentPhase)
    }
    
    private func seconds(for phase: TimerPhase) -> Int {
        switch phase {
        case .initial:
            return (selectedInitialMinutes * 60) + selectedInitialSeconds
        case .work:
            return (selectedWorkMinutes * 60) + selectedWorkSeconds
        case .rest:
            return (selectedRestMinutes * 60) + selectedRestSeconds
        }
    }
    
    private func timerTick() {
        guard remainingSeconds > 0 else {
            advancePhaseOrFinish()
            return
        }
        
        remainingSeconds -= 1
        playBeep()
        
        if remainingSeconds == 0 {
            advancePhaseOrFinish()
        }
    }
    
    private func advancePhaseOrFinish() {
        if let next = currentPhase.nextPhase {
            currentPhase = next
            remainingSeconds = seconds(for: currentPhase)
            if remainingSeconds > 0 {
                playDoubleBeep()
            }
            if remainingSeconds == 0 {
                advancePhaseOrFinish()
            }
        } else {
            finishSequence()
        }
    }
    
    private func finishSequence() {
        pauseTimer()
        sequenceCompleted = true
        currentPhase = .initial
        remainingSeconds = seconds(for: .initial)
    }
    
    private func prepareForNewSequence(resetCompletion: Bool = false) {
        currentPhase = .initial
        remainingSeconds = seconds(for: .initial)
        if resetCompletion {
            sequenceCompleted = false
        }
    }
}

private enum TimerPhase {
    case initial, work, rest
    
    var nextPhase: TimerPhase? {
        switch self {
        case .initial:
            return .work
        case .work:
            return .rest
        case .rest:
            return nil
        }
    }
}

private struct TimeWheel: View {
    let label: String
    @Binding var selection: Int
    
    var body: some View {
        VStack(spacing: 2) {
            Picker(label, selection: $selection) {
                ForEach(0..<60, id: \.self) { value in
                    Text("\(value)")
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(width: 70, height: 80)
            .clipped()
            
            Text(label.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

private struct TimeWheelRow: View {
    let title: String
    @Binding var minutes: Int
    @Binding var seconds: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            TimeWheel(label: "min", selection: $minutes)
            TimeWheel(label: "sec", selection: $seconds)
        }
        .frame(height: 110)
    }
}

#Preview {
    ContentView()
}

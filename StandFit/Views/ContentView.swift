//
//  ContentView.swift
//  StandFit iOS
//
//  Main view - Phase 1: Basic structure
//

import SwiftUI
import StandFitCore

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "figure.run")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("StandFit iOS")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Phase 1: Basic Structure")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
                    .frame(height: 20)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("iOS Target Created")
                    }

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("StandFitCore Imported")
                    }

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("App Structure Ready")
                    }
                }
                .font(.callout)

                Spacer()
            }
            .padding()
            .navigationTitle("StandFit")
        }
    }
}

#Preview {
    ContentView()
}

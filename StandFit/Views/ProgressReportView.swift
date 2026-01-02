//
//  ProgressReportView.swift
//  StandFit iOS
//
//  Comprehensive progress reporting with period selection
//

import SwiftUI
import StandFitCore

// Simple enum for picker binding (avoids associated value comparison issues)
enum PeriodType: Hashable {
    case today
    case week
    case month
}

struct ProgressReportView: View {
    @ObservedObject var store: ExerciseStore
    @ObservedObject var gamificationStore: GamificationStore
    @State private var selectedPeriodType: PeriodType = .today
    @Environment(\.dismiss) private var dismiss

    private let calendar = Calendar.current

    // Cached period values - computed once and stored to maintain stable Hashable identity
    @State private var cachedWeekPeriod: ReportPeriod?
    @State private var cachedMonthPeriod: ReportPeriod?

    private var weekPeriod: ReportPeriod {
        if let cached = cachedWeekPeriod {
            return cached
        }
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let period = ReportPeriod.weekStarting(calendar.startOfDay(for: weekStart))
        DispatchQueue.main.async {
            cachedWeekPeriod = period
        }
        return period
    }

    private var monthPeriod: ReportPeriod {
        if let cached = cachedMonthPeriod {
            return cached
        }
        let monthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let period = ReportPeriod.monthStarting(calendar.startOfDay(for: monthStart))
        DispatchQueue.main.async {
            cachedMonthPeriod = period
        }
        return period
    }

    // Convert selected type to actual period
    private var selectedPeriod: ReportPeriod {
        switch selectedPeriodType {
        case .today: return .today
        case .week: return weekPeriod
        case .month: return monthPeriod
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period selector (Picker instead of navigationLink for iOS)
                    Picker("Period", selection: $selectedPeriodType) {
                        Text("Today").tag(PeriodType.today)
                        Text("Week").tag(PeriodType.week)
                        Text("Month").tag(PeriodType.month)
                    }
                    .pickerStyle(.segmented)
                    
                    // Date range for selected period
                    periodDateRange

                    // Get stats for selected period
                    if let stats = currentStats {
                        if stats.totalCount > 0 {
                            // Show data
                            StatsHeaderView(stats: stats)

                            // Timeline view (only for Today)
                            if selectedPeriodType == .today {
                                timelineView
                            }

                            if shouldShowChart {
                                ProgressChartsView(period: selectedPeriod, store: store)
                            }

                            ExerciseBreakdownView(breakdown: stats.breakdown, period: selectedPeriod)
                        } else {
                            // Empty state
                            emptyStateView
                        }
                    } else {
                        ProgressView()
                    }
                }
                .padding()
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                // Reset cache when view appears to ensure fresh period calculations
                // Handles cases where app stays open across day/week/month boundaries
                cachedWeekPeriod = nil
                cachedMonthPeriod = nil
            }
        }
    }
    
    private var periodDateRange: some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startStr = formatter.string(from: selectedPeriod.startDate)
        let endStr = formatter.string(from: selectedPeriod.endDate.addingTimeInterval(-1))
        
        return Text("\(startStr) – \(endStr)")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var currentStats: ReportStats? {
        store.reportingService.getStats(
            for: selectedPeriod,
            logs: store.logs,
            customExercises: store.customExercises,
            currentStreak: gamificationStore.streak.currentStreak
        )
    }

    private var shouldShowChart: Bool {
        switch selectedPeriodType {
        case .today, .week, .month:
            return true
        }
    }

    private var timelineView: some View {
        let (notifications, exercises) = store.getTodaysTimeline()
        return DayActivityHeatmapView(notifications: notifications, exercises: exercises)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.title)
                .foregroundStyle(.secondary)
            Text("No activity logged")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(emptyMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var emptyMessage: String {
        switch selectedPeriodType {
        case .today:
            return "Start exercising to see today's stats"
        case .week:
            return "Log activity this week to see stats"
        case .month:
            return "Activity logged this month will appear here"
        }
    }
}

#Preview {
    NavigationStack {
        ProgressReportView(store: ExerciseStore.shared, gamificationStore: GamificationStore.shared)
    }
}

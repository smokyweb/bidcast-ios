//
//  DebugLogger.swift
//  BidCast
//
//  iOS Parity Phase 7h (2026-04-22): production logger.
//
//  Thin log gate so we can migrate stray `print()` calls over time without
//  needing to rewrite every call site right now. Behavior:
//    - DEBUG builds: prints to console
//    - Release builds: silent (no log allocation, no cost at runtime)
//
//  Usage:
//      DebugLogger.log("Something happened")
//      DebugLogger.warn("suspicious state: \(foo)")
//      DebugLogger.error("API failed: \(error)")
//
//  New code should use this in place of `print()` directly. The 49 stray
//  prints in legacy template code (PrivacyPolicy / SearchTextfieldCell /
//  EditProfile / etc.) are tracked in the Phase 7 TODO-TREY list and will
//  be swept in a follow-up pass; they don't ship info of any consequence
//  and are cheap in DEBUG but would be real drag in production. For now,
//  they remain intact to avoid churn before TestFlight.

import Foundation

enum DebugLogger {

    /// Informational log. No-op in release builds.
    static func log(_ message: @autoclosure () -> String,
                    file: StaticString = #fileID,
                    line: UInt = #line) {
        #if DEBUG
        print("[\(file):\(line)] \(message())")
        #endif
    }

    /// Warning-level log. No-op in release builds.
    static func warn(_ message: @autoclosure () -> String,
                     file: StaticString = #fileID,
                     line: UInt = #line) {
        #if DEBUG
        print("⚠️ [\(file):\(line)] \(message())")
        #endif
    }

    /// Error-level log. Currently DEBUG-only; wire to Crashlytics later.
    static func error(_ message: @autoclosure () -> String,
                      file: StaticString = #fileID,
                      line: UInt = #line) {
        #if DEBUG
        print("❌ [\(file):\(line)] \(message())")
        #endif
        // TODO-PHASE8: Crashlytics.record(error) when FirebaseCrashlytics
        // is added to the Podfile. Low-priority — Firebase Analytics
        // + APNs already installed.
    }
}

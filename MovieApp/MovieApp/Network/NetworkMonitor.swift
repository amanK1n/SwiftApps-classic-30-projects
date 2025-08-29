//
//  ToastMonitor.swift
//  MovieApp
//
//  Created by Sayed on 26/08/25.
//

import Foundation
import Network
import UIKit

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private var isPreviouslyConnected: Bool = true
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                let isConnected = path.status == .satisfied
                if isConnected != self.isPreviouslyConnected {
                    self.isPreviouslyConnected = isConnected
                    
                    if let topVC = UIApplication.topMostViewController() {
                        if isConnected {
                            topVC.showToast(message: "✅ Back Online")
                        } else {
                            topVC.showToast(message: "⚠️ No Internet Connection")
                        }
                    }
                }
            }
        }
        monitor.start(queue: queue)
    }
}


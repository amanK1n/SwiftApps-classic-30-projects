//
//  ViewController.swift
//  22Beacon
//
//  Created by Sayed on 19/08/25.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    @IBOutlet public var distancoMeter: UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
    }


    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
                if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                    if CLLocationManager.isRangingAvailable() {
                        // do stuff
                        startScanning()
                    }
                }
            }
    }
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")

        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .far:
                self.view.backgroundColor = UIColor.blue
                self.distancoMeter?.text = "FAR"

            case .near:
                self.view.backgroundColor = UIColor.orange
                self.distancoMeter?.text = "NEAR"

            case .immediate:
                self.view.backgroundColor = UIColor.red
                self.distancoMeter?.text = "RIGHT HERE"

            default:
                self.view.backgroundColor = UIColor.gray
                self.distancoMeter?.text = "UNKNOWN"
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
    
}


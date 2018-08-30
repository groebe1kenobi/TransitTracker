//
//  MockCLLocation.swift
//  GroebeCTA
//
//  Created by Sean Groebe on 5/30/18.
//  Copyright © 2018 DePaul University. All rights reserved.
//

import Foundation
import CoreLocation

struct MockLocationConfiguration {
	static var updateInterval = 0.5
	static var GpxFileName: String?
}

class MockCLLocationManager: CLLocationManager {
	private var parser: GpxParser?
	private var timer: Timer?
	private var locations: Queue<CLLocation>?
	private var _isRunning:Bool = false
	var updateInterval: TimeInterval = 0.5
	var isRunning: Bool {
		get {
			return _isRunning
		}
	}
	static let shared = MockCLLocationManager()
	private override init() {
		locations = Queue<CLLocation>()
	}
	func startMocks(usingGpx fileName: String) {
		if let fileName = MockLocationConfiguration.GpxFileName {
			parser = GpxParser(forResource: fileName, ofType: "gpx")
			parser?.delegate = self
			parser?.parse()
		}
	}
	func stopMocking() {
		self.stopUpdatingLocation()
	}
	private func updateLocation() {
		if let location = locations?.dequeue() {
			_isRunning = true
			delegate?.locationManager?(self, didUpdateLocations: [location])
			if let isEmpty = locations?.isEmpty, isEmpty {
				print("stopping at: \(location.coordinate)")
				stopUpdatingLocation()
			}
		}
	}
	override func startUpdatingLocation() {
		timer = Timer(timeInterval: updateInterval, repeats: true, block: {
			[unowned self](_) in
			self.updateLocation()
		})
		if let timer = timer {
			RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
		}
	}
	override func stopUpdatingLocation() {
		timer?.invalidate()
		_isRunning = false
	}
	override func requestLocation() {
		if let location = locations?.peek() {
			delegate?.locationManager?(self, didUpdateLocations: [location])
		}
	}
}

extension MockCLLocationManager: GpxParsing {
	func parser(_ parser: GpxParser, didCompleteParsing locations: Queue<CLLocation>) {
		self.locations = locations
		self.startUpdatingLocation()
	}
}

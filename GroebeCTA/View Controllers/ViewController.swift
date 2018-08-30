//
//  ViewController.swift
//  GroebeCTA
//
//  Created by Sean Groebe on 5/11/18.
//  Copyright © 2018 DePaul University. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit
import CoreLocation

let key = "78dda21bcdd54664884f4d402cddcda0"


class ViewController: UIViewController, CLLocationManagerDelegate {
	
	@IBOutlet weak var map: MKMapView!
	@IBOutlet weak var searchDistanceOutlet: UISegmentedControl!
	@IBOutlet weak var locationsOutlet: UIButton!
	
	let manager = CLLocationManager()
	
	var trainData: [TrainData] = []
	var closeTrainData: [TrainData] = []
	var searchDistance: Double = 3.0
	
	
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations[0]
		
		let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
		let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
		let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
		
		map.setRegion(region, animated: true)
		
		self.map.showsUserLocation = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//MockLocationConfiguration.GpxFileName = "TestLocation"
		
		manager.delegate = self
		
		manager.desiredAccuracy = kCLLocationAccuracyBest
		manager.requestWhenInUseAuthorization()
		if CLLocationManager.locationServicesEnabled() {
			manager.startUpdatingLocation()

		}
		
		DispatchQueue.main.async {
			self.manager.startUpdatingLocation()
		}

	
		
		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=red&outputType=JSON")
		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=blue&outputType=JSON")
		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=brn&outputType=JSON")
		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=g&outputType=JSON")
		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=pink&outputType=JSON")
		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=org&outputType=JSON")
		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=p&outputType=JSON")
		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=y&outputType=JSON")
		
		
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	

	
	override func viewWillAppear(_ animated: Bool) {

		if CLLocationManager.headingAvailable() {
			manager.startUpdatingHeading()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		manager.stopUpdatingLocation()
		manager.stopUpdatingHeading()
	}

	@IBAction func searchDistanceAction(_ sender: UISegmentedControl) {
		switch searchDistanceOutlet.selectedSegmentIndex {
		case 0:
			searchDistance = 3.0
		case 1:
			searchDistance = 5.0
		case 2:
			searchDistance = 10.0
		default:
			break
		}
	}
	@IBAction func locationsAction(_ sender: Any) {
		closeTrainData.removeAll()
		let upperBoundLAT: Double = (manager.location?.coordinate.latitude)! + searchDistance
		let lowerBoundLAT: Double = (manager.location?.coordinate.latitude)! - searchDistance
		let upperBoundLON: Double = (manager.location?.coordinate.longitude)! + searchDistance
		let lowerBoundLON: Double = (manager.location?.coordinate.longitude)! - searchDistance
		
		for train in trainData {
			let trainLat = (train.lat as! NSString).doubleValue
			let trainLon = (train.lon as! NSString).doubleValue
			
			if(lowerBoundLAT < trainLat && trainLat < upperBoundLAT) {
				if(lowerBoundLON < trainLon && trainLon < upperBoundLON) {
					closeTrainData.append(train)
					
					print("CLOSE TRAIN STOP DATA: \(String(describing: train.nextStop))")
				}
			}
		}
		trainData.removeAll()
		
		for closeStop in closeTrainData {
			if(closeTrainData.count > 0) {
				trainData.append(closeStop)
			} else {
				print("NO TRAINS!!!")
			}
		}
		dropPins(trainData)
	}
	
	func filterNearbyStops() {
		
	}
	
	func dropPins(_ trainsNearyby: [TrainData]) {
		var locations = [MKPointAnnotation]()
		
		for stop in trainsNearyby {
			let trainLat = (stop.lat as! NSString).doubleValue
			let trainLon = (stop.lon as! NSString).doubleValue
			let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: trainLat, longitude: trainLon)
			let dropPin = MKPointAnnotation()
			dropPin.coordinate = coordinate
			dropPin.title = stop.nextStop
			self.map.addAnnotation(dropPin)
			self.map.selectAnnotation(dropPin, animated: true)
			locations.append(dropPin)
			self.map.showAnnotations(locations, animated: true)
		}
	}
	
	
	func collectData(_ API: String) {
		let jsonURL = API
		
		guard let url = URL(string: jsonURL) else {
			print("ERROR OPENING URL LINE 28 ")
			return
		}
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let data = data else { return }
			
			do {
				let json = try JSON(data: data)
				let destination = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["destNm"]})})
				let nextStop = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["nextStaNm"]})})
				let trainLine = json["ctatt"][]["route"].arrayValue.map({$0["@name"]})
				let pTime = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["prdt"]})})
				let arrivalTime = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["arrT"]})})
				let stopID = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["nextStpId"]})})
				let stationID = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["nextStaId"]})})
				let lat = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["lat"]})})
				let lon = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["lon"]})})
				
				print(pTime)
				print(arrivalTime)
				let dataSize = destination[0].count
				if(dataSize > 0) {
					for i in 0...dataSize-1 {
						let newTrain = TrainData(destinationName: destination[0][i].stringValue,
												 nextStop: nextStop[0][i].stringValue,
												 trainLine: trainLine[0].stringValue,
												 pTime: pTime[0][i].stringValue,
												 arrivalTime: arrivalTime[0][i].stringValue,
												 nextStopID: stopID[0][i].intValue,
												 nextStationID: stationID[0][i].intValue,
												 lat: lat[0][i].stringValue,
												 lon: lon[0][i].stringValue
										
							
							
						)
						
						print("newTrain = \(String(describing: newTrain.trainLine))")
						self.trainData.append(newTrain)
						//print(newTrain.lat!)
					}
					
					DispatchQueue.main.async {
						//self.tableView.reloadData()
					}
					
				} else {
					print("Error line 185")
				}
			} catch let jsonErr { print("Error: ", jsonErr) }
			}.resume()
		
	}
	
	
	func convertString(_ dateStr: String) -> String {
		let arrival = dateStr.suffix(8)
		var arrivalInt: Int! = Int(arrival.replacingOccurrences(of: ":", with: ""))
		if (arrivalInt >= 130000) {
			arrivalInt = Int(arrivalInt - 120000)
		}
		var newArrivalStr: String = String(arrivalInt)
		if(arrivalInt >= 100000) {
			newArrivalStr.insert(":", at: newArrivalStr.index(newArrivalStr.startIndex, offsetBy: 2))
			newArrivalStr.insert(":", at: newArrivalStr.index(newArrivalStr.endIndex, offsetBy: 2))
			
		} else if (arrivalInt < 100000) {
			newArrivalStr.insert(":", at: newArrivalStr.index(newArrivalStr.startIndex, offsetBy: 1))
			newArrivalStr.insert(":", at: newArrivalStr.index(newArrivalStr.endIndex, offsetBy: -2))
			
			
		}
		return (newArrivalStr)
	}
	
	
	

}



////
////  TrainStopTableViewController.swift
////  GroebeCTA
////
////  Created by Sean Groebe on 5/11/18.
////  Copyright © 2018 DePaul University. All rights reserved.
////
//
//import UIKit
//import SwiftyJSON
//import Alamofire
//import CoreLocation
//import MapKit
//
//typealias CLLocationDistance = Double
//
//class TrainStopTableViewController: UITableViewController, CLLocationManagerDelegate {
//	
//	
//	let locationManager = CLLocationManager()
//	var records: [TrainData] = []
//
//		let alert = UIAlertController(title: "Cannot Load Data!", message: "Please look for another train", preferredStyle: .alert)
//	
//	
//    override func viewDidLoad() {
//		
//        super.viewDidLoad()
//		let status = CLLocationManager.authorizationStatus()
//		MockLocationConfiguration.GpxFileName = "TestLocation"
//		if status == .denied || status == .restricted {
//			print("Location services not authorized")
//		} else {
//			print("USER LOCATION: \(String(describing: locationManager.location))")
//			locationManager.desiredAccuracy = kCLLocationAccuracyBest
//			locationManager.distanceFilter = 1 // meter
//			locationManager.delegate = self
//			locationManager.requestWhenInUseAuthorization()
//			if CLLocationManager.locationServicesEnabled() {
//				locationManager.requestLocation();
//			}
//			locationManager.startUpdatingLocation()
//		}
//		
//		
//		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=red&outputType=JSON")
//		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=blue&outputType=JSON")
//		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=brn&outputType=JSON")
//		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=g&outputType=JSON")
//		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=pink&outputType=JSON")
//		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=org&outputType=JSON")
//		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=p&outputType=JSON")
//		self.collectData("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=\(key)&rt=y&outputType=JSON")
//	}
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//		
//    }
//	
//	override func viewWillAppear(_ animated: Bool) {
//		if CLLocationManager.locationServicesEnabled() {
//			locationManager.startUpdatingLocation()
//		}
//		if CLLocationManager.headingAvailable() {
//			locationManager.startUpdatingHeading()
//		}
//	}
//	
//	override func viewWillDisappear(_ animated: Bool) {
//		super.viewWillDisappear(animated)
//		
//		locationManager.stopUpdatingLocation()
//		locationManager.stopUpdatingHeading()
//	}
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//       
//        return self.records.count
//    }
//
//	func closeStopArray() -> [TrainData] {
//		
//		//let lat = stops[indexPath.row].lat
//		//let lon = stops[indexPath.row].lon
//		
//		
//		var closeStops: [TrainData] = []
//		for train in records {
//			let lat = train.lat
//			let lon = train.lon
//			let distance2 = CLLocation(latitude: lat!, longitude: lon!)
//			let distance: Double? = locationManager.location?.distance(from: distance2)
//			let newDistance = distance! / 1609 
//			if(newDistance.isLess(than: 2.0)) {
//				closeStops.append(train)
//			}
//			
//		}
//		return closeStops
//	}
//	
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
//		
//		guard let cell = tableView.dequeueReusableCell(withIdentifier: "StopCell", for: indexPath) as? TrainStopTableViewCell else { fatalError("Error loading cell") }
//		cell.stopNameLabel.adjustsFontSizeToFitWidth = true
//		cell.arrivalLabel.adjustsFontSizeToFitWidth = true
//		cell.distanceLabel.adjustsFontSizeToFitWidth = true
//		var backgroundColor: UIColor?
//		
//		var stops = closeStopArray()
//		//var closeStops: [TrainData]
//		//stops.sort(by: {$0.distance(to: locationManager.location) < $1.distance(to: locationManager.location)})
//		
//		//var closeStops: [TrainData] = []
//		//if (distance?.isLess(than: 2))! {
//		//print("distance: \(String(describing: roundedDistance))")
//		
//		//let roundedDistance = String(format: "%.2f", )
//		
//		switch stops[indexPath.row].trainLine {
//		case "y":
//			backgroundColor = UIColor.yellow
//		case "red":
//			backgroundColor = UIColor.red
//		case "p":
//			backgroundColor = UIColor.purple
//		case "pink":
//			backgroundColor = UIColor.magenta
//			
//		case "org":
//			backgroundColor = UIColor.orange
//		case "g":
//			backgroundColor = UIColor.green
//		case "brn":
//			backgroundColor = UIColor.brown
//		case "blue":
//			backgroundColor = UIColor.blue
//		default:
//			backgroundColor = UIColor.gray
//		}
//		//let arrivalTime =
//		
//		let validIndex = stops.indices.contains(indexPath.row)
//		
//		if validIndex {
//			cell.destinationNameLabel.text = stops[indexPath.row].destinationName
//			cell.stopNameLabel.text = stops[indexPath.row].nextStop
//			cell.arrivalLabel.text = convertString(stops[indexPath.row].arrivalTime!)
//			//cell.distanceLabel.text = roundedDistance
//			cell.backgroundColor = backgroundColor
//			
//			
//			
//		}
//		
//			return cell
//		
//	}
//		
//	
//
//	func collectData(_ API: String) {
//		let jsonURL = API
//
//		guard let url = URL(string: jsonURL) else {
//			print("ERROR OPENING URL LINE 28 ")
//			return
//		}
//		URLSession.shared.dataTask(with: url) { (data, response, error) in
//			guard let data = data else { return }
//
//			do {
//				let json = try JSON(data: data)
//				let destination = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["destNm"]})})
//				let nextStop = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["nextStaNm"]})})
//				let trainLine = json["ctatt"][]["route"].arrayValue.map({$0["@name"]})
//				let pTime = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["prdt"]})})
//				let arrivalTime = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["arrT"]})})
//				let stopID = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["nextStpId"]})})
//				let stationID = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["nextStaId"]})})
//				let lat = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["lat"]})})
//				let lon = json["ctatt"][]["route"].arrayValue.map({$0["train"].arrayValue.map({$0[]["lon"]})})
//				
//				print(pTime)
//				print(arrivalTime)
//				let dataSize = destination[0].count
//				if(dataSize > 0) {
//					for i in 0...dataSize-1 {
//						let newTrain = TrainData(destinationName: destination[0][i].stringValue,
//												 nextStop: nextStop[0][i].stringValue,
//												 trainLine: trainLine[0].stringValue,
//												 pTime: pTime[0][i].stringValue,
//												 arrivalTime: arrivalTime[0][i].stringValue,
//												 nextStopID: stopID[0][i].intValue,
//												 nextStationID: stationID[0][i].intValue,
//												 lat: lat[0][i].doubleValue,
//												 lon: lon[0][i].doubleValue
//												
//							
//												 
//						)
//						
//						print("newTrain = \(String(describing: newTrain.trainLine))")
//						self.records.append(newTrain)
//						//print(newTrain.lat!)
//					}
//			
//					DispatchQueue.main.async {
//						self.tableView.reloadData()
//					}
//					
//				} else {
//					print("Error line 185")
//				}
//			} catch let jsonErr { print("Error: ", jsonErr) }
//		}.resume()
//
//	}
//	
//	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//		print("error:: \(error.localizedDescription)")
//	}
//	
//	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//		if status == .authorizedWhenInUse {
//			locationManager.requestLocation()
//		}
//	}
//	
//	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//		
//		if locations.first != nil {
//			print("location:: (location)")
//		}
//		
//	}
//	
//	func convertString(_ dateStr: String) -> String {
//		let arrival = dateStr.suffix(8)
//		var arrivalInt: Int! = Int(arrival.replacingOccurrences(of: ":", with: ""))
//		if (arrivalInt >= 130000) {
//			arrivalInt = Int(arrivalInt - 120000)
//		}
//		var newArrivalStr: String = String(arrivalInt)
//		if(arrivalInt >= 100000) {
//			newArrivalStr.insert(":", at: newArrivalStr.index(newArrivalStr.startIndex, offsetBy: 2))
//			newArrivalStr.insert(":", at: newArrivalStr.index(newArrivalStr.endIndex, offsetBy: 2))
//			
//		} else if (arrivalInt < 100000) {
//			newArrivalStr.insert(":", at: newArrivalStr.index(newArrivalStr.startIndex, offsetBy: 1))
//			newArrivalStr.insert(":", at: newArrivalStr.index(newArrivalStr.endIndex, offsetBy: -2))
//			
//			
//		}
//		return (newArrivalStr)
//	}
//}
//
//	
//	
//	
//	
//	
//	
//	
//	
//	
//	
//	
//	
//

//
//  GpxParser.swift
//  GroebeCTA
//
//  Created by Sean Groebe on 5/30/18.
//  Copyright © 2018 DePaul University. All rights reserved.
//

import CoreLocation
import Foundation

public struct Queue<T> {
	fileprivate var array = [T]()
	
	public var isEmpty: Bool {
		return array.isEmpty
	}
	
	func peek() -> T? {
		if !array.isEmpty {
			return array[0]
		} else {
			return nil
		}
	}
	
	public var count: Int {
		return array.count
	}
	
	public mutating func enqueue(_ element: T) {
		array.append(element)
	}
	
	public mutating func dequeue() -> T? {
		if isEmpty {
			return nil
		} else {
			return array.removeFirst()
		}
	}
	
	public var front: T? {
		return array.first
	}
}

protocol GpxParsing: NSObjectProtocol {
	func parser(_ parser: GpxParser, didCompleteParsing locations: Queue<CLLocation>)
}

class GpxParser: NSObject, XMLParserDelegate {
	private var locations: Queue<CLLocation>
	weak var delegate: GpxParsing?
	private var parser: XMLParser?
	
	init(forResource file: String, ofType typeName: String) {
		self.locations = Queue<CLLocation>()
		super.init()
		if let content = try? String(contentsOfFile: Bundle.main.path(forResource: file, ofType: typeName)!) {
			let data = content.data(using: .utf8)
			parser = XMLParser.init(data: data!)
			parser?.delegate = self
		}
	}
	
	func parse() {
		self.parser?.parse()
	}
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		switch elementName {
		case "trkpt":
			if let latString =  attributeDict["lat"],
				let lat = Double.init(latString),
				let lonString = attributeDict["lon"],
				let lon = Double.init(lonString) {
				locations.enqueue(CLLocation(latitude: lat, longitude: lon))
			}
		default: break
		}
	}
	
	func parserDidEndDocument(_ parser: XMLParser) {
		delegate?.parser(self, didCompleteParsing: locations)
	}
}

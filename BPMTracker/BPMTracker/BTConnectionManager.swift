//
//  BTConnectionManager.swift
//  BPMTracker
//
//  Created by Jason Ferguson on 11/14/15.
//  Copyright © 2015 Jason Ferguson. All rights reserved.
//

import CoreBluetooth

//MARK:
//MARK: Constants
let kDeviceInfoServiceUUID = "180A"
let kHeartRateServiceUUID = "180D"
let kEnableServiceUUID = "2A39";
let kNotificationsServiceUUID = "2A37";
let kBodyLocationUUID = "2A38";
let kManufacturerNameUUID = "2A29";

class BTConnectionManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

	var btCentralManager : CBCentralManager?

	var currentlyConnectedPeripheral: CBPeripheral?

	let servicesArray: [CBUUID] = [CBUUID(string: kHeartRateServiceUUID), CBUUID(string: kDeviceInfoServiceUUID)]

	override init() {
		super.init()
		btCentralManager = CBCentralManager(delegate: self, queue: nil)
	}
	//MARK:
	func scanForPeripherals() {
		btCentralManager!.scanForPeripheralsWithServices(servicesArray, options: nil)
	}

	//MARK:
	//MARK: CBCentralManagerDelegate methods
	func centralManagerDidUpdateState(central: CBCentralManager) {
		switch central.state
		{
		case .PoweredOff:
			print("PoweredOff")
		case .PoweredOn:
			print("PoweredOn")
			scanForPeripherals()
		case .Resetting:
			print("Resetting")
		case .Unauthorized:
			print("Unauthorized")
		case .Unknown:
			print("Unknown")
		case .Unsupported:
			print("Unsupported")
		}
	}

	func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
		print("didDiscoverPeripheral \(peripheral)")
		currentlyConnectedPeripheral = peripheral
		peripheral.delegate = self
		btCentralManager!.connectPeripheral(peripheral, options: nil)
	}

	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		print("didConnectPeripheral \(peripheral)")

		btCentralManager!.stopScan()

		currentlyConnectedPeripheral = peripheral
		
		peripheral.delegate = self

		peripheral.discoverServices(servicesArray)
	}

	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		print("didFailToConnectPeripheral \(peripheral)")
	}

	func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		print("didDisconnectPeripheral \(peripheral)")
	}

	//MARK:
	//MARK: CBPeripheralDelegate methods

	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
		for service in peripheral.services! {
			print("didDiscoverServices \(service)")
			peripheral.discoverCharacteristics(nil, forService: service)
		}
	}

	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {

		if service.UUID == CBUUID(string: kHeartRateServiceUUID) {
			for characteristic in service.characteristics! {
				print("didDiscoverCharacteristicsForService \(service.UUID) \(characteristic)")
				if characteristic.UUID == CBUUID(string: kNotificationsServiceUUID) {
					peripheral.setNotifyValue(true, forCharacteristic: characteristic)
				} else if characteristic.UUID == CBUUID(string: kBodyLocationUUID) {
					peripheral.readValueForCharacteristic(characteristic)
				}
			}
		}

	}

	func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
		
		print("didUpdateValueForCharacteristic \(characteristic)")

		if characteristic.UUID == CBUUID(string: kNotificationsServiceUUID) {
			print("bpm = \(bpm(characteristic))")
		}
	}

	//MARK:
	//MARK: Processing Data methods

	func bpm(characteristic: CBCharacteristic) -> Double {

		if let rawData = characteristic.value {
			// the number of elements:
			let count = rawData.length / sizeof(UInt8)

			// create array of appropriate length:
			var dataArray = [UInt8](count: count, repeatedValue: 0)

			// copy bytes into array
			rawData.getBytes(&dataArray, length:count * sizeof(UInt8))

			if dataArray.count > 0 {
				print("dataArray.count = \(dataArray.count)")
				print("dataArray = \(dataArray[0]), \(dataArray[1])")
//				if dataArray[0] == 0 {
					return Double(dataArray[1])
//				}
			}
		}
		return 0.0
	}

}
//
//  ViewController.swift
//  currentLocation2
//
//  Created by Feng-iMac on 2/26/18.
//  Copyright © 2018 Feng-iMac. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager!
    
    
    @IBOutlet weak var long: UILabel!
    @IBOutlet weak var Lat: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        determineMyCurrentLocation()
    }
    
    //determine user's current location
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        

        //long.text = "\(userLocation.coordinate.latitude)"
        //Lat.text = "\(userLocation.coordinate.longitude)"
        
        let geoCoder=CLGeocoder();
        geoCoder.reverseGeocodeLocation(userLocation) { (pls: [CLPlacemark]?, error: Error?)  in
            if error == nil {
                print("Successfully set the location")
                guard let plsResult = pls else
                {
                    return
                    
                }
                let firstPL = plsResult.first
                //self.Lat.text = firstPL?.name;
                self.Lat.text = String(userLocation.coordinate.longitude) + "," + String(userLocation.coordinate.latitude);
            }else {
                print("Unable to get the location")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    // php post to the amazon cloud server
    @IBAction func sendPost(_ sender: Any) {
        // prepare json data
        let json: [String: Any] = ["coordinateA": "123",
                                   "coordinateB": "123"
            ,"deviceID": "alarm1" , "alarmNum": "alarm1"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: "http://ec2-18-217-212-185.us-east-2.compute.amazonaws.com/~ec2-user/Hermes/getTraffic.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        
        task.resume()
    
        
    }
    
}


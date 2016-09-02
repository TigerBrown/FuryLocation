//
//  FirstViewController.swift
//  TigerLocation
//
//  Created by taotao on 16/8/14.
//  Copyright © 2016年 taotao. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController ,CLLocationManagerDelegate{
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager=CLLocationManager()
    var location:CLLocation?
    
    var updatingLocation=false
    var lastLocationError:NSError?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    
    @IBAction func getLocation() { // do nothing yet
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
           
            if #available(iOS 8.0, *) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                // Fallback on earlier versions
            }
           
            return
        }
        if authStatus == .Denied || authStatus == .Restricted {
            //lastLocationError=
            showLocationServicesDeniedAlert()
            return
        }
       
        if updatingLocation {
            stopLocationManager()
        } else {
            startLocationManager()
        }
        //startLocationManager()
      
        //addressLabel.text="AHklsdf"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        
        if error.code==CLError.LocationUnknown.rawValue{
            return
        }
        
        lastLocationError=error
        
        stopLocationManager()
        
        showLocationInLabel()
        
        configureGetButton()

    }
    
 
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        if newLocation.timestamp.timeIntervalSinceNow < -5 || newLocation.horizontalAccuracy < 0 {
            print("newLocationTimeInterval:\(newLocation.timestamp.timeIntervalSinceNow)")
              print("newLocationLhorizontalAccuracy:\(newLocation.horizontalAccuracy)")
            showLocationInLabel()
            return
        }
        if location==nil || newLocation.horizontalAccuracy<location?.horizontalAccuracy{
            location = newLocation
            lastLocationError=nil
            
            print("Enough Accuracy")
            print("Enough newLocationLhorizontalAccuracy:\(newLocation.horizontalAccuracy)")
            showLocationInLabel()
            
            if newLocation.horizontalAccuracy<=locationManager.desiredAccuracy{
                print("We've done here.")
                stopLocationManager()
            }
                
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {placemarks, error in
                   
                   
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks where !p.isEmpty {
                        self.placemark = p.last!
                        print("*** Found placemarks: \(self.placemark), error: \(error)")
                    } else {
                        self.placemark = nil
                        print("*** Error while finding placemarks, error: \(error)")
                    }
                    self.performingReverseGeocoding = false
                    self.showLocationInLabel()
                    }
                )
            }
                
            return
        }
        print("Not enough Accuracy")
        print("Not enough newLocationLhorizontalAccuracy:\(newLocation.horizontalAccuracy)")
        print("Not enough locationLhorizontalAccuracy:\(location?.horizontalAccuracy)")
//      print("didUpdateLocations \(location)")
    
    
        
    }
    
    func showLocationInLabel(){
        if let location = location {
            latitudeLabel.text  = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                addressLabel.text = stringFromPlacemark(placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
        }else{
            latitudeLabel.text  = ""
            longitudeLabel.text = ""
            tagButton.hidden = true
            addressLabel.text = ""
            
            let statusMessage: String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                statusMessage = "Location Services Disabled"
            }else {
                statusMessage = "Error Getting Location" }
            }else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            }else if updatingLocation {
                statusMessage = "Searching..."
            }else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
       
        }
        func stringFromPlacemark(placemark: CLPlacemark) -> String {
            // 1
            var line1 = ""
            // 2
            if let s = placemark.subThoroughfare { line1 += s + " "
            }
            // 3
            if let s = placemark.thoroughfare { line1 += s
            }
            // 4
            var line2 = ""
            if let s = placemark.locality {
                line2 += s + " "
            }
            
            if let s = placemark.administrativeArea {
                line2 += s + " "
            
            }
            if let s = placemark.postalCode {
                line2 += s }
            // 5
            let result=line1 + "\n" + line2

            print("line1 :\(line1)");
            print("line2 :\(line2)");

            return result
        }
    
                
    
    func showLocationServicesDeniedAlert() {
        
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "Location Services Disabled",message:"Please enable location services for this app in Settings.",preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default,handler: nil)
            presentViewController(alert, animated: true, completion: nil)
            //   showLocationInLabel()
            alert.addAction(okAction)
            } else {
                // Fallback on earlier versions
            }
                
              
              
    }
    
    func stopLocationManager(){
        if updatingLocation{
        locationManager.stopUpdatingLocation()
        locationManager.delegate=nil
        lastLocationError=nil
        updatingLocation=false
        configureGetButton()
        }
    }
    
    func startLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        location=nil
        lastLocationError=nil
        performingReverseGeocoding=false
        updatingLocation=true
        locationManager.startUpdatingLocation()
        configureGetButton()
        
    }
    func configureGetButton(){
        if updatingLocation{
            getButton.setTitle("Stop", forState: .Normal)
        }else{
            getButton.setTitle("Get My Location", forState: .Normal)
        }
            
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="TagLocation"{
            let navigationController=segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
        }
        
    }
}


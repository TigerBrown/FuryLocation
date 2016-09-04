//
//  GlobalLet.swift
//  TigerLocation
//
//  Created by taotao on 16/9/4.
//  Copyright © 2016年 taotao. All rights reserved.
//

import Foundation
import CoreLocation


let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
}()

func formatDate(date: NSDate) -> String {
    return dateFormatter.stringFromDate(date)
}


func stringFromPlacemark(placemark: CLPlacemark) -> String {
    // 1
    var line1 = ""
    // 2
    if let s = placemark.subThoroughfare {
        line1 += s + " "
    }
    // 3
    if let s = placemark.thoroughfare {
        line1 += s
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
            line2 += s
    }
    if let s = placemark.country {
        line2 += s
    }
    // 5
    let result=line1 + " " + line2
    
    
  
    
   // print("line1 :\(line1)");
    //print("line2 :\(line2)");
    
    return result
}
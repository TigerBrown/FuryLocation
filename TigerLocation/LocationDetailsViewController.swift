//
//  LocationDetailsViewController.swift
//  TigerLocation
//
//  Created by taotao on 16/8/28.
//  Copyright © 2016年 taotao. All rights reserved.
//

import Foundation
import CoreLocation



import UIKit
class LocationDetailsViewController: UITableViewController {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark : CLPlacemark?
    
    var categoryName = "No Category"
    
    @IBAction func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        //categoryLabel.text = ""
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
        addressLabel.text = "No Address Found"
        }
        dateLabel.text = formatDate(NSDate())
        
        let gestureRecognizer = UITapGestureRecognizer(target: self,action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func tableView(tableView: UITableView,
            heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2 {
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
      //       print("view.bounds.size.width  : \(view.bounds.size.width )")
          
      
            addressLabel.sizeToFit()
            print("addressLabel.bounds.size.width : \(  addressLabel.bounds.size.width)")
            print("addressLabel.bounds.size.height : \(  addressLabel.bounds.size.height)")
            print("addressLabel.frame.size.width : \(addressLabel.frame.size.width)")
            print("addressLabel.frame.size.height : \(addressLabel.frame.size.height)")
            addressLabel.frame.origin.x = view.bounds.size.width-addressLabel.frame.size.width+15
            
            print("view.bounds.size.width  : \(view.bounds.size.width )")
            print("view.bounds.size.height  : \(view.bounds.size.height )")
            print("addressLabel.frame.size.width  : \(addressLabel.frame.size.width )")
            print("addressLabel.frame.origin.x  : \(addressLabel.frame.origin.x )")
          //  print("height : \(addressLabel.frame.size.height)")
            
            print(addressLabel.text)
            let result = addressLabel.frame.size.height + 20
            return result
        } else {
            return 44
        }
    }
    
    override func tableView(tableView:UITableView,willSelectRowAtIndexPath indexPath:NSIndexPath)->NSIndexPath?{
        if indexPath.section==1 || indexPath.section==0 {
            return indexPath
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section==0 && indexPath.section==0 {
           descriptionTextView.becomeFirstResponder()
        }

    }



    
    override func prepareForSegue(segue:UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerController
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory (segue : UIStoryboardSegue) {
        let controller = segue.sourceViewController as! CategoryPickerController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
//
//
}
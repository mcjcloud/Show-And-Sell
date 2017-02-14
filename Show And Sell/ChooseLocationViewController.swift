//
//  ChooseLocationViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 2/1/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit
import MapKit

class ChooseLocationViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {

    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var mapView: MKMapView!    
    @IBOutlet var searchBar: UISearchBar!
    
    var selectedAnnotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup searchbar
        searchBar.delegate = self
        
        // enable/disable button
        doneButton.isEnabled = selectedAnnotation != nil
    }

    // MARK: Searchbar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // asign map delegate
        mapView.delegate = self
        
        // put down keyboard
        searchBar.resignFirstResponder()
        
        // remove any annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // create search request
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        
        // start the search
        localSearch.start { searchResponse, error in
            if searchResponse == nil {
                let alert = UIAlertController(title: nil, message: "Location not found", preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(dismiss)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let pointAnnotation = MKPointAnnotation()
            var annText: String? = searchBar.text
            if let point = searchResponse?.mapItems[0] {
                print("address dict: \(point.placemark.addressDictionary?["FormattedAddressLines"])")
                annText = point.name
                pointAnnotation.subtitle = self.concat(point.placemark.addressDictionary!["FormattedAddressLines"] as! [Any])
            }
            pointAnnotation.title = annText
            let centerCoord = searchResponse!.boundingRegion.center
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: centerCoord.latitude, longitude: centerCoord.longitude)
            
            // create the pin
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            pinAnnotationView.animatesDrop = true
            
            self.mapView.setCenter(pointAnnotation.coordinate, animated: true)
            self.mapView.addAnnotation(pinAnnotationView.annotation!)
            
            // set zoom
            var region = MKCoordinateRegion(center: pointAnnotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            region = self.mapView.regionThatFits(region)
            self.mapView.setRegion(region, animated: true)
            
            print("coordinate: \(pointAnnotation.coordinate)")
        }
    }
    
    // MARK: MKMapView Delegate
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotation = view.annotation as? MKPointAnnotation
        doneButton.isEnabled = selectedAnnotation != nil
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        selectedAnnotation = nil
        doneButton.isEnabled = selectedAnnotation != nil
    }
    
    func concat(_ arr: [Any]) -> String {
        var result = ""
        for i in 0..<arr.count {
            result += i == arr.count - 1 ? "\(arr[i])" : "\(arr[i]) "
        }
        return result
    }
}

//
//  LocationManager.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 03/02/24.
//

import Foundation
import CoreLocation
import MapKit
import Contacts

extension CLPlacemark {
        /// street name, eg. Infinite Loop
    var streetName: String? { thoroughfare }
        /// // eg. 1
    var streetNumber: String? { subThoroughfare }
        /// city, eg. Cupertino
    var city: String? { locality }
        /// neighborhood, common name, eg. Mission District
    var neighborhood: String? { subLocality }
        /// state, eg. CA
    var state: String? { administrativeArea }
        /// county, eg. Santa Clara
    var county: String? { subAdministrativeArea }
        /// zip code, eg. 95014
    var zipCode: String? { postalCode }
        /// postal address formatted
    @available(iOS 11.0, *)
    var postalAddressFormatted: String? {
        guard let postalAddress = postalAddress else { return nil }
        return CNPostalAddressFormatter().string(from: postalAddress)
    }
}

//class LocationManager {
//
//    static let shared = LocationManager()
//    
//    private init() {}
//    
//    var latitude = 0.0
//    var longitude = 0.0
//    
//    func getCordinates() {
//        latitude = CLLocationManager().location?.coordinate.latitude ?? 0.0
//        longitude = CLLocationManager().location?.coordinate.longitude ?? 0.0
//    }
//    
//    func getCurrentAddress() -> String {
//        self.getCordinates()
//        
//        let location = CLLocation(latitude: latitude, longitude: longitude)
//        var address: String = ""
//        location.placemark { placemark, error in
//            guard let placemark = placemark else {
//                print("Error:", error ?? "nil")
//                return
//            }
//            
//            if placemark.streetNumber != nil {
//                address += placemark.streetNumber ?? ""
//            }
//            
//            if placemark.streetName != nil {
//                address += placemark.streetName ?? ""
//            }
//            
//            if placemark.neighborhood != nil {
//                address += placemark.neighborhood ?? ""
//            }
//        }
//        
//        return address
//    }
//}
//
//extension CLLocation {
//    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
//        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
//    }
//}

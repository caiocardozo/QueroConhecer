//
//  MapViewController.swift
//  QueroConhecer
//
//  Created by Caio Cardozo on 09/07/18.
//  Copyright © 2018 Caio Cardozo. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    enum MapMessageType {
        case routeError
        case authorizationWarning
    }
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAdress: UILabel!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    
    var places: [Place]!
    var poi: [MKAnnotation] = []
    lazy var locationManager = CLLocationManager()
    var btUserLocation : MKUserTrackingButton!
    var selectedAnnotation: PlaceAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden = true
        viInfo.isHidden = true
        mapView.mapType = .mutedStandard
        mapView.delegate = self
        locationManager.delegate = self
        
        if places.count == 1 {
            title = places[0].name
        }else{
            title = "Meus lugares"
        }
        
        for place in places{
            addPlace(place)
        }
        configureLocationButton()
        showPlaces()
        requestUserocationAuthorization()
    }
    
    func configureLocationButton() {
        btUserLocation = MKUserTrackingButton(mapView: mapView)
        btUserLocation.backgroundColor = .white
        btUserLocation.frame.origin.x = 10
        btUserLocation.frame.origin.y = 10
        btUserLocation.layer.cornerRadius = 5
        btUserLocation.layer.borderWidth = 1
        btUserLocation.layer.borderColor = UIColor(named: "main")?.cgColor
    }
    
    func requestUserocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways, .authorizedWhenInUse:
                //mostrar botao de localizacao no mapa
                mapView.addSubview(btUserLocation)
                break
            case .denied:
                showMessage(type: .authorizationWarning)
            case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
            case .restricted:
                break
            }
        }
    }
    
    func addPlace(_ place: Place) {
        let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place )
        annotation.adress = place.adress
        annotation.title = place.name
        mapView.addAnnotation(annotation)
    }
    
    func showPlaces() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func showInfo() {
        lbName.text = selectedAnnotation!.title
        lbAdress.text = selectedAnnotation!.adress
        viInfo.isHidden = false
    }
    
    @IBAction func showRoute(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            showMessage(type: .authorizationWarning)
            return
        }
        
        let request = MKDirectionsRequest()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: selectedAnnotation!.coordinate))
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if error == nil{
                if let response = response{
                    self.mapView.removeOverlays(self.mapView.overlays)
                    
                    let route = response.routes.first!
                    
                    self.mapView.add(route.polyline, level: .aboveRoads)
                    var annotations = self.mapView.annotations.filter({!($0 is PlaceAnnotation)})
                    annotations.append(self.selectedAnnotation!)
                    self.mapView.showAnnotations(annotations, animated: true)
                }
            }else{
                self.showMessage(type: .routeError)
            }
        }
    }
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }
    
    func showMessage(type: MapMessageType){
        let title = type == .authorizationWarning ? "Aviso" : "Erro"
        let message = type == .authorizationWarning ? "Para usar os recursos de localizaco do app, voce precisa permitir o uso na tela de ajustes" : "Nao foi possivel encontrar essa rota"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if type == .authorizationWarning {
            let confirmAction = UIAlertAction(title: "Ir para ajustes", style: .default, handler: { (action) in
                if let appSettigs  = URL(string: UIApplicationOpenSettingsURLString){
                    UIApplication.shared.open(appSettigs, options: [:], completionHandler: nil)
                }
            })
            alert.addAction(confirmAction)
        }
        present(alert, animated: true, completion: nil)
    }
    

}

//MARK: - MapViewDelegate
extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is PlaceAnnotation) {
            return nil
        }
        
        let type =  (annotation as! PlaceAnnotation).type
        let identifier = "\(type)"
        var annotationView =  mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "poi")
        annotationView?.glyphImage = type == .place ? #imageLiteral(resourceName: "placeGlyph") : #imageLiteral(resourceName: "poiGlyph")
        annotationView?.displayPriority = type == .place ? .required : .defaultHigh
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let camera = MKMapCamera()
        camera.centerCoordinate = view.annotation!.coordinate
        camera.pitch = 80
        camera.altitude = 100
        mapView.setCamera(camera, animated: true)
        
        selectedAnnotation = (view.annotation as! PlaceAnnotation)
        showInfo()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(named: "main")?.withAlphaComponent(0.8)
            renderer.lineWidth = 5.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
}

extension MapViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        aiLoading.startAnimating()
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                guard let response = response else{
                    self.aiLoading.stopAnimating()
                    return
                }
                self.mapView.removeAnnotations(self.poi)
                self.poi.removeAll()
                
                for item in response.mapItems{
                    let annotation = PlaceAnnotation(coordinate: item.placemark.coordinate, type: .poi)
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.adress = Place.getFormattedAdress(with: item.placemark)
                    self.poi.append(annotation)
                }
                self.mapView.addAnnotations(self.poi)
                self.mapView.showAnnotations(self.poi, animated: true)
            }
            self.aiLoading.stopAnimating()
        }
    }
}

extension MapViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            mapView.addSubview(btUserLocation)
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}


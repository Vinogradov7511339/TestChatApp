//
//  MapViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 01.11.2021.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    // MARK: - Public variables

    var location: CLLocation?
    var mapView: MKMapView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureMapView()
    }
}

// MARK: - Actions
extension MapViewController {
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Setup views
private extension MapViewController {
    func configureNavBar() {
        title = Const.title
        let button = UIBarButtonItem(
            image: .back,
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        navigationItem.leftBarButtonItem = button
    }

    func configureMapView() {
        mapView = MKMapView(frame: view.bounds)
        mapView.showsUserLocation = true
        if let location = location {
            mapView.setCenter(location.coordinate, animated: false)
            let annotation = MapAnnotation(title: nil, coordinate: location.coordinate)
            mapView.addAnnotation(annotation)
        }
        view.addSubview(mapView)
    }
}

extension MapViewController {
    enum Const {
        static let title = NSLocalizedString("", value: "Map view", comment: "")
    }
}

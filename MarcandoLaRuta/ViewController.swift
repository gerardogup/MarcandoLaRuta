//
//  ViewController.swift
//  MarcandoLaRuta
//
//  Created by Gerardo Guerra Pulido on 06/03/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    let manejador = CLLocationManager()
    var distanciaRecorrida = 0
    var posicionInicial: CLLocation? = nil
    var puntoActual: CLLocation? = nil
    var desfase: Bool = false
    var contadorDePuntos:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        mapa.centerCoordinate = mapa.userLocation.coordinate
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            manejador.startUpdatingLocation()
            mapa.showsUserLocation = true
        } else {
            manejador.stopUpdatingLocation()
            mapa.showsUserLocation = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if posicionInicial == nil && desfase == false {
            desfase = true
        } else if posicionInicial == nil && desfase == true {
            posicionInicial = locations.last! as CLLocation
            crearPin(posicionInicial!, distancia: 0)
        }
        let ubicacionActual = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: ubicacionActual.coordinate.latitude, longitude: ubicacionActual.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapa.setRegion(region, animated: true)
        
        if posicionInicial != nil && ubicacionActual != posicionInicial {
            let distanciaTotal = ubicacionActual.distanceFromLocation(posicionInicial!)
            print(distanciaTotal)
            
            let distanciaProximoPunto:Double = 50 * contadorDePuntos
            if distanciaTotal > distanciaProximoPunto {
                crearPin(ubicacionActual, distancia: distanciaTotal)
            }
        }
    }

    func crearPin(posicion: CLLocation, distancia: Double){
        puntoActual = posicion
        var punto = CLLocationCoordinate2D()
        punto.latitude = posicion.coordinate.latitude
        punto.longitude = posicion.coordinate.longitude
        let pin = MKPointAnnotation()
        pin.title = "Lon: \(punto.longitude), Lat: \(punto.latitude)"
        let distanciaStr:String =  NSString(format: "%.2f", distancia) as String
        pin.subtitle = "Distancia Recorrida: \(distanciaStr) mts."
        pin.coordinate = punto
        mapa.addAnnotation(pin)
        contadorDePuntos += 1
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alerta = UIAlertController(title: "ERROR", message: "error \(error.code)", preferredStyle: .Alert)
        let accionOK = UIAlertAction(title: "OK", style: .Default, handler: { accion in
        //..
        })
        alerta.addAction(accionOK)
        self.presentViewController(alerta, animated: true, completion: nil)
    }

    @IBAction func mostrarMapaStandard(sender: UIBarButtonItem) {
        print("standard")
        self.mapa.mapType = .Standard
    }
    
    @IBAction func mostrarMapaSatellite(sender: UIBarButtonItem) {
        print("satellite")
        self.mapa.mapType = .Satellite
    }
    
    @IBAction func mostrarMapaHybrid(sender: UIBarButtonItem) {
        print("hybrid")
        self.mapa.mapType = .Hybrid
    }

}


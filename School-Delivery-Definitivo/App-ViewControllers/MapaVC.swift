//
//  MapaVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 12/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SVProgressHUD
import CoreLocation


class MapaVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    //MARK: - Declaraciones de variables globales, y de variables de objetos de la Storyboard
    
    @IBOutlet weak var mapaView: MKMapView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var effect:UIVisualEffect!
    
    @IBOutlet var hazteRepartidorView: UIView!
    @IBOutlet weak var imagesEmpezarEntregar: UIImageView!
    
    @IBOutlet weak var btnPedir: UIBarButtonItem!
    
    
    private let locationManager = CLLocationManager()
    
    private var userLocation = CLLocationCoordinate2D()
    private var driverLocation = CLLocationCoordinate2D()
    private var userDefaultLocation = CLLocationCoordinate2D()
    
    private var timer = Timer()
    private var esPrimeraVez = true
    
   
    let pinUsuario = MKPointAnnotation()
    let pinRepartidor = MKPointAnnotation()
    
    var efecto:UIVisualEffect!
    
    let userID = Auth.auth().currentUser?.uid
    
    let DatabaseProvider = DBProvider()
    
    let pedido = PedidoHandler()
    let keyPasar = PasarKeyParametroBtn()
    let notificarDatos = PasarDatosNotificarUsuario()
    
    var estadoUsuario:Bool!
    
    var nombreUsuarioCompleto:String!
    var nombreRepartidorCompleto:String!
    
    var comprobarKeyPedido:String?
    var comprobarKeyPasadoPorAceptarPedido:String?
    
    var comprobarSiSeEmpezoPedido:Bool?
    var comprobarKeyRepartidorLocalizacion:String?
    
    var keyNotifUser = String()
    
    
    @IBOutlet weak var btnCancelar: UIBarButtonItem!
    @IBOutlet weak var btnLocalizacion: UIButton!
    
    @IBOutlet weak var viewDistanciaRestante: UIView!
    @IBOutlet weak var labelDistanciaMts: UILabel!
    
    
    
    //-------------------------------------------------------------------------------------------------
    
    struct keyVar {
        
        static var keyNotif = String()
        static var comprobarSiSeEmpezoPedido = Bool()
        
    }
    
    
    //MARK: - ViewDidLoad y ViewDidAppear
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarStyle = .lightContent //Para que la statusBar sea de color Blanco
        
        initializeLocationManager()                         //Para que se de inicio a la geolocalizacion
        
        effect = visualEffectView.effect                    //Config. el efecto de desvanizacion de la promo de repartidor
        visualEffectView.effect = nil
        
        hazteRepartidorView.layer.cornerRadius = 5          //Darle un aspecto redondo a la promo
        
        
        pedidoRequest() //Se esperará respuesta cuando se active un nuevo pedido de un cliente, y se le hará llegar al repartidor.
            
        btnCancelar.isEnabled = false
        btnCancelar.tintColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        
        notificarUsuarioDePedidoAceptado()     //Se esperará a que se agregue un child al de schoolDelivery_pedidoAceptado
        
        notificarRepartidorPedidoCancelado()   //Se esperá a que se quite el child de schoolDelivery_pedidoAceptado
        
        viewDistanciaRestante.alpha = 0
        
        
        //Checar si el usuario es repartidor, si no, hacer que aparezca la vista de hacerte repartidor.
        
        DatabaseProvider.userEsRepartidor.observeSingleEvent(of: .value) { (snapshot) in
            
            if let dic = snapshot.value as? [String:Any] {
                
                if dic["esRepartidor"] as? Bool == false {
                    self.animateIn()
                }
                
            }
            
        }
        
        
        //Checar si está en modo de repartidor activo
        
        DatabaseProvider.userIDRef.child("repartidorActivo").observeSingleEvent(of: .value) { (snapshot) in
            
            if let dic = snapshot.value as? [String:Any] {
                
                self.estadoUsuario = dic["repartidorActivo"] as! Bool
                print("Entraste a la app con repartidorActivo = \(self.estadoUsuario)")
                
            }
            
        }
        
        
        
        
        
    }
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        //Hacer funciones habilitando si está en modo repartidor o no
        DatabaseProvider.userIDRef.child("repartidorActivo").observeSingleEvent(of: .value) { (snapshot) in
            
            if let dic = snapshot.value as? [String:Any] {
                
                let usuarioEstado = dic["repartidorActivo"] as! Bool
                
                //Si se activa el modo repartidor
                if usuarioEstado == true {
                    
                    //self.pedidoRequest() //Cambiarlo de lugar
                    
                    self.nombreRepartidorCompleto = ""
                    
                    self.btnPedir.isEnabled = false
                    
                    self.DatabaseProvider.userIDRef.child("datosUserModificables").observeSingleEvent(of: .value) { (snapshot) in
                        
                        if let dic = snapshot.value as? [String:Any] {
                            
                            let nombres = dic["nombres"] as? String
                            let apellidos = dic["apellidos"] as? String
                            
                            self.nombreRepartidorCompleto = "\(nombres!) \(apellidos!)"
                            
                        }
                        
                    }
                    
                }
                   
                    //Si se desactiva el modo repartidor, está en cliente
                else
                {
                    
                    self.nombreUsuarioCompleto = ""
                    
                    self.btnPedir.isEnabled = true
                    
                    self.DatabaseProvider.userIDRef.child("datosUserModificables").observeSingleEvent(of: .value) { (snapshot) in
                        
                        if let dic = snapshot.value as? [String:Any] {
                            
                            let nombres = dic["nombres"] as? String
                            let apellidos = dic["apellidos"] as? String
                            
                            self.nombreUsuarioCompleto = "\(nombres!) \(apellidos!)"
                            
                        }
                        
                    }
                    
                    
                    
                }
                
            }
            
        }
        
        
        
        
        
    }
    
    
    
    
    //------------------------------------------------------------------------------------------
    
    
    
    //MARK: - Funciones para animar la vista de hacerte repartidor
    
    func animateIn() {
        
        self.view.addSubview(hazteRepartidorView)
        //hazteRepartidorView.center = self.view.center
        self.hazteRepartidorView.center = CGPoint(x: 188, y: 280) //Aqui tener en cuenta que no puede ser las mismas medidas en otros iPhones
        hazteRepartidorView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        hazteRepartidorView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.hazteRepartidorView.alpha = 1
            self.hazteRepartidorView.transform = CGAffineTransform.identity
        }
        
    }
    
   
    
    func animateOut() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.hazteRepartidorView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.hazteRepartidorView.alpha = 0
            
            self.visualEffectView.effect = nil
            
            
        }) { (success) in
            
            self.hazteRepartidorView.removeFromSuperview()
            
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------

    
    
    
    
    //MARK: - Funcionalidades para arrancar las funciones del mapa
    
    func initializeLocationManager() {
        
        mapaView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapaView.isZoomEnabled = true
        mapaView.isScrollEnabled = true
        
    }

    
    @IBAction func btnLocalizacionExacta(_ sender: Any)
    {
        
        if estadoUsuario == true {
            
            let region = MKCoordinateRegion(center: self.driverLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            
            self.mapaView.setRegion(region, animated: true)
            
        }else {
            
            let region = MKCoordinateRegion(center: self.userLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            
            self.mapaView.setRegion(region, animated: true)
            
        }
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        if estadoUsuario == true {
            
            //Si tenemos las coordenadas del Manager
            if let location = self.locationManager.location?.coordinate {
                
                self.driverLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                
                if self.esPrimeraVez {
                    
                    //Qué tanto estará cerca el zoom del mapa a nuestra localizacion, nosotros le moveremos todo a la medida perfecta probandolo
                    let region = MKCoordinateRegion(center: self.driverLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                    
                    self.mapaView.setRegion(region, animated: true)
                    self.esPrimeraVez = false
                    
                }
                
                self.mapaView.removeAnnotations(self.mapaView.annotations)
                
                //Comprobar si desde la var de comprobarKey, ya agarró un valor, de los que se dará al aceptar el pedido, se activa aqui
                if comprobarKeyPasadoPorAceptarPedido != nil {
                    
                    DatabaseProvider.pedidoAceptado.child(comprobarKeyPasadoPorAceptarPedido!).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        print("Ya entró al DB para ver la localicacion, \(self.comprobarKeyPasadoPorAceptarPedido!)")
                        
                        if let dicLocation = snapshot.value as? [String:Any] {
                            
                            let latitud = dicLocation["latitudPedido"] as! Double
                            let longitud = dicLocation["longitudPedido"] as! Double
                            
                            self.userLocation = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
                            
                            self.pinUsuario.coordinate = self.userLocation
                            
                            self.pinUsuario.title = "Posición del Cliente"
                            
                            self.mapaView.addAnnotation(self.pinUsuario)
                            
                            //Experimento, mostrar distancia de localizaciones
                            let latitud2 = self.driverLocation.latitude
                            let longitud2 = self.driverLocation.longitude
                            
                            let localDriver = CLLocation(latitude: latitud2, longitude: longitud2)
                            
                            let localCustomer = CLLocation(latitude: latitud, longitude: longitud)
                            
                            let distance = localDriver.distance(from: localCustomer) / 100
                            
                            let distanceRounded = String(format: "%.2f", distance)
                            
                            self.labelDistanciaMts.text = "\(distanceRounded) mts."
                            
                            //
                        }
                        
                    })
        
                    
                }
                
                if keyVar.comprobarSiSeEmpezoPedido == true {
                    
                   
                    let latitud = driverLocation.latitude
                    let longitud = driverLocation.longitude
                    
                    let dicCoordenadas:Dictionary<String,Double> = ["latitud":latitud,
                                                                    "longitud":longitud]
                
                    Database.database().reference().child("pedidoCoordenadas").child(keyVar.keyNotif).setValue(dicCoordenadas)
                    
                }
                
                
                
                self.pinRepartidor.coordinate = self.driverLocation
                
                self.pinRepartidor.title = "Repartidor"
                
                self.mapaView.addAnnotation(self.pinRepartidor)
                
                
                let dicLocation: Dictionary<String,Double> = ["latitud":driverLocation.latitude,
                                                              "longitud":driverLocation.longitude]
                
                DatabaseProvider.userIDRef.child("coordenadasActuales").setValue(dicLocation)
                
                
            }
            
        }else{
            
            //Si tenemos las coordenadas del Manager
            if let location = self.locationManager.location?.coordinate {
                
                self.userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                
                
                if self.esPrimeraVez {
                    
                    //Qué tanto estará cerca el zoom del mapa a nuestra localizacion, nosotros le moveremos todo a la medida perfecta probandolo
                    let region = MKCoordinateRegion(center: self.userLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                    
                    self.mapaView.setRegion(region, animated: true)
                    self.esPrimeraVez = false
                    
                }
                
                
                self.mapaView.removeAnnotations(self.mapaView.annotations)
                
                //Si se acepto el pedido, se acrivará aquí
                if keyVar.comprobarSiSeEmpezoPedido == true {
                    
                    print("Entró en el comprobarSiSeEmpezó")
                    
                    print("notificarDatos.keyReparto es igual a \(keyNotifUser)")
                    
                    Database.database().reference().child("pedidoCoordenadas").child(keyVar.keyNotif).observeSingleEvent(of: .value, with: { (snapshot) in   //Aquí se pasa a nil el child
                        
                        print("Entró en la comprobación del child ´PedidoCoordenadas´ ")
                        
                        if let dicCoord = snapshot.value as? [String:Double] {
                            
                            let coordLatitud = dicCoord["latitud"]
                            let coordLongitud = dicCoord["longitud"]
                            
                            self.pinRepartidor.coordinate = CLLocationCoordinate2D(latitude: coordLatitud!, longitude: coordLongitud!)
                            self.pinRepartidor.title = "Posición del Repartidor"
                            
                            self.mapaView.addAnnotation(self.pinRepartidor)
                            
                            //Experimento, para mostrar la distancia de ambas localizaciones
                            let latitud2 = self.userLocation.latitude
                            let longitud2 = self.userLocation.longitude
                            
                            let localUser = CLLocation(latitude: latitud2, longitude: longitud2)
                            
                            let localDriver = CLLocation(latitude: coordLatitud!, longitude: coordLongitud!)
                            
                            let distance = localUser.distance(from: localDriver)
                            
                            let distanceRounded = String(format: "%.2f", distance)
                            
                            self.labelDistanciaMts.text = "\(distanceRounded) mts."
                            
                            //
                            
                        }
                        
                    })
                    
                }
                
                
                self.pinUsuario.coordinate = self.userLocation
                
                self.pinUsuario.title = "Cliente"
                
                self.mapaView.addAnnotation(self.pinUsuario)
                
                let dicLocation: Dictionary<String,Double> = ["latitud":userLocation.latitude,
                                                              "longitud":userLocation.longitude]
                
                DatabaseProvider.userIDRef.child("coordenadasActuales").setValue(dicLocation)
                
            }
            
        }
        
        
        
        //Hará los cambios cuando note un cambio de estado
        
        DatabaseProvider.userIDRef.child("repartidorActivo").observe(.childChanged) { (snapshot) in
            
            let clienteORepartidor = snapshot.value as? Bool
            
            if let estado = clienteORepartidor {
                
                if estado == false /*O sea esta en modo de cliente*/ {
                    
                    //Aquí va codigo de localizacion de cliente
                    //Nomas se cambiará de valor, y seguirá el codigo de arriba, de seguir localizando
                    
                    self.estadoUsuario = false
                    
                }
                else if estado == true
                {
                    //Aquí va el codigo de localizacion de repartidor
                    //Nomas cambiará el valor, y seguirá el codigo de arriba, de seguir localizando
                    
                    self.estadoUsuario = true
                    
                }
                
            }
            
        }
        
        
    }
    
    
    
    
    //Personalizar pin del mapa
    /*func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKAnnotationView(annotation: pinRepartidor, reuseIdentifier: "DriverPin")
        
        //annotationView.image = #imageLiteral(resourceName: "car")
        
        annotationView.tintColor = UIColor.blue
        
        let transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        annotationView.transform = transform
        
        return annotationView
        
    }*/
    
    
    //--------------------------------------------------------------------------------------
    
    
    //MARK: - Botones, funciones, etc.
    
    @IBAction func btnEmpezarEntregar(_ sender: Any)
    {
        animateOut()
        
        //Hacer un segue a donde lleve para completar la informacion de repartidor
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let RegisEntregadorVC = storyBoard.instantiateViewController(withIdentifier: "RegisEntregadorVC")
        self.present(RegisEntregadorVC, animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnMasTarde(_ sender: Any)
    {
        animateOut()
    }
    

    
    //Aquí empeiza el desmadre a la hora de pedir, a pasar toda la info. necesaria
    @IBAction func btnPedirFunc(_ sender: Any)
    {
        //Lo que hace es agarrar el nombre del cliente, la latitud y la longitud del cliente, y las enviará en la base de datos
        
        let dataCliente: Dictionary<String, Any> = ["nombreCliente":self.nombreUsuarioCompleto!,
                                                    "latitude":userLocation.latitude,
                                                    "longitude":userLocation.longitude]
        
        Database.database().reference().child("schoolDelivery_pedidos").childByAutoId().setValue(dataCliente)
        
        Database.database().reference().child("schoolDelivery_pedidos").observeSingleEvent(of: .value) { (snapshot) in
            
            if let keyDic = snapshot.value as? [String:Any] {
                
                for (key, _) in keyDic {
                    self.comprobarKeyPedido = key
                    print("comprobarKeyPedido = \(self.comprobarKeyPedido!)")
                }
                
                
            }else{
                print("No paso por el if de key")
            }
            
        }
        
        //Desactivar el boton de pedir y hacerlo esperar con una vista, y que se desactive esa vista hasta que acepten su pedido
        
        //
        
        SVProgressHUD.show(withStatus: "Se está contactando con repartidores, para que se acepte tu pedido...")
        btnPedir.isEnabled = false
        
        
    }
    
    
    
    @IBAction func unwindSegueMapaVC(_ sender: UIStoryboardSegue){
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //---------------------------------------------------------------------------------------
    

    
    //MARK: - Funcion que hará que esté activa esta funcion cuando un cliente pide al repartidor un pedido, y que se le notifique al repartidor
    
    
    func pedidoRequest() {
        
        print("Ya pasó por aquí, el principio de pedidoRequest")
        
        Database.database().reference().child("schoolDelivery_pedidos").observe(.childAdded) { (snapshotPedido) in
            
            print("Se detectó un pedido, ahora pasará la comprobación si es un repartidor o no...")
            
            if self.estadoUsuario == true {
                
                self.DatabaseProvider.userIDRef.child("repartidorEstaEntregando").observeSingleEvent(of: .value, with: { (snapshotRepartidorOcupado) in
                    
                    if let dic = snapshotRepartidorOcupado.value as? [String:Any] {
                        
                        let repartidorOcupado = dic["repartidorEstaEntregando"] as! Bool
                        
                        print("Comprobaremos si estas en una entrega, tu estado de ocupado es: \(repartidorOcupado)")
                        
                        //Comprobar si estas ocupado en otra entrega, para que no te llegue la noticia
                        if repartidorOcupado == false {
                            
                            print("No estás ocupado!, te llegará la noticia")
                            
                            if let data = snapshotPedido.value as? [String:Any] {
                                
                                if let latitude = data["latitude"] as? Double {
                                    
                                    if let longitude = data["longitude"] as? Double {
                                        
                                        if let nombreUsuario = data["nombreCliente"] as? String {
                                            
                                            //Si se completan las 3 condiciones, las dos coordenadas y el nombre completo, aquí se ejecuta el codigo, o sea, se le informara al repartidor del pedido, lo que podemos hacer aquí es que le aparezca una vista, para poder aceptar o rechazar el pedido
                                            
                                            print("Pasó por todas las prubeas de if y ya tenemos los valores de la longitud, latitud y nombre del usuario pedido, ahora a cargar la alerta")
                                            
                                            print("La clave de este pedido es: \(snapshotPedido.key)") //Aquí se imprime la llave del pedido especifico, que se esta pidiendo en ese momento
                                            
                                            
                                            //Aquí se crea la alerta, que la podemos personalizar
                                            
                                            let alertController = UIAlertController(title: "Tienes un pedido!", message: "El nombre del cliente es: \(nombreUsuario) en las coordenadas: \(latitude) , \(longitude)", preferredStyle: .alert)
                                            
                                            alertController.addAction(UIAlertAction(title: "Aceptar pedido", style: .default, handler: { (action) in
                                                
                                                
                                                let keyPedido = snapshotPedido.key
                                                
                                                keyVar.keyNotif = snapshotPedido.key
                                                
                                                keyVar.comprobarSiSeEmpezoPedido = true
                                                
                                                self.comprobarKeyPasadoPorAceptarPedido = keyPedido
                                                
                                                Database.database().reference().child("pedidoCoordenadas").setValue(keyPedido)
                                                
                                                self.aceptarPedido(nombreClientePrueba: nombreUsuario, latitudePedido: latitude, longitudePedido: longitude, keyPedido: snapshotPedido.key, nombreRepartidorQueHaraLaEntrega: self.nombreRepartidorCompleto)
                                                
                                                //Cambiar dentro de la base de datos del repartidor, si está activo, cambiarlo a true, para que no le lleguen más pedidos, mientras está entregando.
                                                
                                                let dicEstadoOcupado: Dictionary<String,Any> = ["repartidorEstaEntregando":true]
                                                
                                                self.DatabaseProvider.userIDRef.child("repartidorEstaEntregando").setValue(dicEstadoOcupado)
                                                
                                                
                                                
                                            }))
                                            
                                            alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action) in
                                                
                                                alertController.dismiss(animated: true, completion: nil)
                                                
                                            }))
                                            
                                            self.present(alertController, animated: true, completion: nil)
                                            
                                            //------------------------------------------------------------------------------------
                                            
                                            print("Ya pasó por todo el procedimiento, ahuevotl!")
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        else {
                            print("Repartidor está en otra entrega")
                        }
                            
                        
                    }
                    
                })
                
                
                
            }
            else{
                print("Eres cliente por aquí no pasas")
            }
            
            
            
        }
        
    }
    
    
    func aceptarPedido(nombreClientePrueba: String, latitudePedido: Double, longitudePedido: Double, keyPedido:String, nombreRepartidorQueHaraLaEntrega:String) {
        
        print("Hola se aceptó el pedido de \(nombreClientePrueba), y el encargado de entregartelo será: \(nombreRepartidorQueHaraLaEntrega) , esto es una prueba...")
        
        //Cuando se acepte, lo que tenemos que hacer es, borrar del "child" de pedidos, el key especifico que se pasará, a pasarlo a pedidos aceptados, que sería otro child, y pasarlo por parametro, las coordenadas. LISTO
        
        //Aquí en esta ventana se mostrará en la pantalla del REPARTIDOR, la posición del cliente, que mandó, veremos si se puede agarrar la posición actual del cliente, y no hay ningun fallo.
        
        //Y hacer un if, si el repartidor está entregando un pedido, para que no le lleguen mensajes, o avisos, eso se tendrá que poner arriba a la hora de que le lleguen en pedidosRequest(). LISTO
        
        
        //Aquí del child "schoolDelivery_pedidos" se quitará el pedido estecifico, y ahora lo pasaremos a otro child de pedidos activos
        Database.database().reference().child("schoolDelivery_pedidos").child(keyPedido).removeValue()
        
        
        //Se agarra los datos, y se suben al nuevo child que será de pedidos activos
        
        let dataPedidoActivo: Dictionary<String,Any> = ["nombreCliente":nombreClientePrueba,
                                                        "latitudPedido":latitudePedido,
                                                        "longitudPedido":longitudePedido,
                                                        "nombreRepartidor":nombreRepartidorQueHaraLaEntrega,
                                                        "LlaveDelPedido":keyPedido]
        
        Database.database().reference().child("schoolDelivery_pedidosActivos").child(keyPedido).setValue(dataPedidoActivo)
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.viewDistanciaRestante.alpha = 1
            
        })
        
        
        let keyComprobar = keyPedido
        
        
        keyNotifUser = keyPedido
        
        comprobarKeyPasadoPorAceptarPedido = keyComprobar
        print("comprobarKeyPasadoPorAceptarPedido = \(comprobarKeyPasadoPorAceptarPedido!)")
        
        
        
        
        //Ahora mostrar por medio de un pin o algo los datos que estará recibiendo de las coordenadas y se muestre en el mapa
        
        //
        
        
        
       
        
        //Boton de cancelar activado
        
        keyPasar.keyRepartidor = keyPedido
        
        self.btnCancelar.isEnabled = true
        self.btnCancelar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        
        
        
        
        
    }
    

    
    func notificarUsuarioDePedidoAceptado() {
        
        Database.database().reference().child("schoolDelivery_pedidosActivos").observe(.childAdded) { (snapshot) in
            
            //comprobar si es cliente
            if self.estadoUsuario == false {
                
                print("SE ACTIVO AQUÍ PORQUE SE CAMBIÓ ALGO EN NOTIFICARPEDIDO")
                
                self.comprobarSiSeEmpezoPedido = true
                        
    
                //Comprobar si se cambio el estado para que se le notifique al usuario, pero aqui le tenemos que pasar el key especifico
                
                
                let comprobarKey = self.comprobarKeyPedido
                
                keyVar.comprobarSiSeEmpezoPedido = true
                keyVar.keyNotif = self.comprobarKeyPedido!
  
                
                print("\(comprobarKey!) es el key")
                
                        if let keyCorrecto = comprobarKey { //Ojo aquí
                            
                            
                            //Aquí esta funcion será activada y estar atenta solo por el cliente, cuando el repartidor acepte el pedido
                            
                            print("--------Se llamó a la funcion de notificar, veremos si entra como cliente a la condición------------")
                            
                            //Se activa todo el codigo viendo si es un cliente
                            if self.estadoUsuario == false {
                                
                                print("-----------Pasó por el ciclo de notificar al usuario----------------")
                                
                                //Agregar un botón que se pueda cancelar el pedido
                                
                                self.keyPasar.keyCliente = self.notificarDatos.keyReparto
                                
                                SVProgressHUD.dismiss()
                                
                                self.btnCancelar.isEnabled = true
                                self.btnCancelar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
                                
                                UIView.animate(withDuration: 0.4, animations: {
                                    
                                    self.viewDistanciaRestante.alpha = 1
                                    
                                })
                                
                                //Mostrarle al usuario que se aceptó el pedido
                                
                                //
                                
                                //Mostrale al usuario la posicion del repartidor
                                
                                //
                                
                                
                                
                            }
                            else{
                                
                                print("Eres repartidor, aquí no pasará nada en notificarUsuario")
                                
                            }
                            
                        }else {
                            print("Las llaves no coinciden, no se notificará")
                        }

                
                
            }else{
                print("Eres repartidor no pasas aqui")
            }
            
            
            
            
            
        }
        
        
        
    }
    
    
    //-------------------------------------------------------------------------------------------------------
    
    
   
    //MARK: - Funcion del Botón de Cancelar
    
    
    @IBAction func btnCancelarAction(_ sender: Any)
    {
        //Que sí es repartidor
        if estadoUsuario == true {
            
            //Mostrar un actionsheet, de si está seguro de cancelar o no
            
            //
            
            let actionSheet = UIAlertController(title: "¿Deseas cancelar la entrega?", message: "Se le notificará al cliente", preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Cancelar entrega", style: .destructive, handler: { (action) in
                
                //Aquí irá el codigo, de que se quiere cancelar la entrega
                //Si se cancela, se quitará del child "schoolDelivery_pedidosActivos" el key.
                
                //
                
                let keyPendiente = self.keyPasar.keyRepartidor
                
                print("Se canceló el pedido del id: \(keyPendiente)")
                
                Database.database().reference().child("schoolDelivery_pedidosActivos").child(keyPendiente).removeValue()
                
                let dicRepEntregando: Dictionary<String,Any> = ["repartidorEstaEntregando":false]
                
                self.DatabaseProvider.userIDRef.child("repartidorEstaEntregando").setValue(dicRepEntregando)
                
                Database.database().reference().child("pedidoCoordenadas").child(keyPendiente).removeValue() //
                
                self.comprobarKeyPasadoPorAceptarPedido = nil
                
                self.comprobarKeyPedido = nil
                
                keyVar.comprobarSiSeEmpezoPedido = false
                
                self.comprobarKeyPasadoPorAceptarPedido = nil
                
                self.keyNotifUser = ""
                
                UIView.animate(withDuration: 0.4, animations: {
                    
                    self.viewDistanciaRestante.alpha = 0
                    
                })
                
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Seguir con la entrega", style: .cancel, handler: nil))
            
            present(actionSheet, animated: true, completion: nil)
            
            
        }else {
            
            //Mostrar un actionsheet, de si está seguro de cancelar o no
            
            let actionSheet = UIAlertController(title: "¿Deseas cancelar el pedido?", message: "Se le notificará al repartidor", preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Cancelar pedido", style: .destructive, handler: { (action) in
                
                //Aquí irá el codigo, de que se quiere cancelar tu pedido
                //Si se cancela, se quitará del child "schoolDelivery_pedidosActivos" el key.
                
                
                Database.database().reference().child("schoolDelivery_pedidosActivos").child(self.comprobarKeyPedido!).removeValue()
                
                Database.database().reference().child("pedidoCoordenadas").child(keyVar.keyNotif).removeValue() //
                
                self.comprobarKeyPasadoPorAceptarPedido = nil
                
                self.comprobarKeyPedido = nil
                
                keyVar.comprobarSiSeEmpezoPedido = false
                
                self.comprobarKeyPasadoPorAceptarPedido = nil
                
                self.keyNotifUser = ""
                
                self.btnPedir.isEnabled = true
                
                UIView.animate(withDuration: 0.4, animations: {
                    
                    self.viewDistanciaRestante.alpha = 0
                    
                })
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Seguir con el pedido", style: .cancel, handler: nil))
            
            present(actionSheet, animated: true, completion: nil)
            
        }
        
    }
    
    
    func notificarRepartidorPedidoCancelado() {
        
        Database.database().reference().child("schoolDelivery_pedidosActivos").observe(.childRemoved) { (snapshot) in
            
            print("Se entró a la funcion de que detectó que se borró el child")
            
            if self.estadoUsuario == true {
                
                print("Se detectó que eres repartidor, se te notificará que se canceló tu reparto")
                
                SVProgressHUD.showInfo(withStatus: "Se canceló tu pedido de parte del cliente. A esperar al siguiente reparto")
                
                
                self.btnCancelar.isEnabled = false
                self.btnCancelar.tintColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
                
                Database.database().reference().child("pedidoCoordenadas").child(keyVar.keyNotif).removeValue() //
                
                self.comprobarKeyPasadoPorAceptarPedido = nil
                
                self.comprobarKeyPedido = nil
                
                keyVar.comprobarSiSeEmpezoPedido = false
                
                self.comprobarKeyPasadoPorAceptarPedido = nil
                
                self.keyNotifUser = ""
                
                keyVar.keyNotif = ""
                
                UIView.animate(withDuration: 0.4, animations: {
                    
                    self.viewDistanciaRestante.alpha = 0
                    
                })
                
                
                let dicPedidoAceptado: Dictionary<String,Any> = ["repartidorEstaEntregando":false]
                
                self.DatabaseProvider.userIDRef.child("repartidorEstaEntregando").setValue(dicPedidoAceptado) //Checar aquí por si todos los repartidores se cambian a false en repartidorActivo
                
            }else{
                
                
                print("Se detectó que eres cliente, se te notificará que se canceló tu reparto")
                
                SVProgressHUD.showInfo(withStatus: "Se canceló tu pedido de parte del repartidor. Puedes volver a pedir")
                
                
                self.btnCancelar.isEnabled = false
                self.btnCancelar.tintColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
                
                Database.database().reference().child("pedidoCoordenadas").child(keyVar.keyNotif).removeValue() //
                
                self.comprobarKeyPasadoPorAceptarPedido = nil
                
                self.comprobarKeyPedido = nil
                
                keyVar.comprobarSiSeEmpezoPedido = false
                
                self.comprobarKeyPasadoPorAceptarPedido = nil
                
                self.keyNotifUser = ""
                
                keyVar.keyNotif = ""
                
                self.btnPedir.isEnabled = true
                
                UIView.animate(withDuration: 0.4, animations: {
                    
                    self.viewDistanciaRestante.alpha = 0
                    
                })
                
            }
            
            
        }
        
        
    }
    
    
    
    //--------------------------------------------------------------------------------------------
    
    

}


















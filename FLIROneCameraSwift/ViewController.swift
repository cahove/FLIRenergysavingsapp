//
//  ViewController.swift
//  FLIROneCameraSwift
//
//  Created by FLIR on 2020-08-13.
//  Copyright © 2020 FLIR Systems AB. All rights reserved.
//

import UIKit
import ThermalSDK
import UniformTypeIdentifiers
import SwiftUI
import ReplayKit

class ViewController: UIViewController {
    
    // Data Info Message
    let DataMsg = "\n[Insulation] This section is enabled once the insulation isotherm is enabled. The insulation temperature is the calculated temperature based off of the indoor temperature, outdoor temperature, and insulation factor entered in Settings. Any temperatures above this temperature will be highlighted in the camera feed.\n\n[Humidity] \"Atmos. Temp\" is displayed regardless of if this section is enabled, however the \"Dew Point\" is only shown once the humidity isotherm is enabled. [Atmos. Temp] stands for \"Atmospheric Temperature\", and is the temperature of the atmosphere as measured by the camera. This temperature is in the humidity section as it is used in the calculation of the dew point. [Dew Point] stands for the dew point, or the temperature at which no more water can evaporate.\n\n[Other] Other important data values.\n\n[Battery] The percentage of the camera device. This value is updated everytime the \"Home\" page is refreshed.\n\n[Emiss.] \"Emissivity\". The emissivity is a rating of the reflectiveness of a material on the scale of 0 to 1 with 0 being that it reflects all light. A lower emissivity means that the temperature measured is the light reflected off of the material, rather than the object itself. Emissivity should generally be above 0.5 for accurate measurements of objects.\n\n[Dist.] \"Distance\". This value measures the distance of the central object in meteers.\n\n[Rel. Humid] \"Relative Humidity\". Relative Humidity is the amount of water vapor present in the atmosphere in the form of a percent. Relative Humidity is not under the category of \"Humidity\" as it is not used in the Humidity isotherm. Relative Humidity is not the same as Air Humidity.\n\n[Reflec. Temp] \"Reflected Temperature\". The reflected temperature is the temperature of the central object.\n\n[Atmos. Trans] \"Atmospheric Transmission\". This percentage refers to how much of the heat of the object is reaching the camera in order to determine its temperature. Since the Earth's atmosphere interferes between the camera and the object, this percentage gives an insight into how much of the temperature measured is obstructed by the atmosphere. If the percentage is low, than the temperature given of objects may be cooler than they actually are.\n\n[[Ext. Op] Temp] \"External Optics Temperature\". The temperature of the optic lens of a camera.\n\n[[Ext. Op] Trans] \"External Optics Transmission\". The light measured by the camera can be distorted if the lens is damaged such as from scratches. A value of around 1 means that the lens is in perfect shape, and a value of around 0 means that the lens is in bad condition, and that the intensity of light going through the lens is weak."
    
    
    //Individual items
    var discovery: FLIRDiscovery?
    var camera: FLIRCamera?
    var ironPalette: Bool = false
    var connected: Bool = false
    let defaults = UserDefaults.standard
    

    // Variables
    var InsulationEnabled: Bool = false
    var InsulationActivated: Bool = false // if showing on screen
    
    var HumidityEnabled: Bool = false
    var HumidityActivated: Bool = false // if showing on screen
   
    var viewAppeared: Bool = true // view appeared
    
    var TempUnitString: String = ""
    var TempUnit: TemperatureUnit = .CELSIUS
    
    var ThermalFilter: String = "Lava"
    var CameraFilter: String = "Thermal"
    var EmulatorStatus: Bool = false
    var Background: String = "Thermal"
    let BackgroundLayer = CAGradientLayer()
    
    var isRecording: Bool = false
    

    @IBOutlet weak var deviceManager: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var visualImageView: UIImageView!
    @IBOutlet weak var homeTitle: UINavigationItem!
    
    // UI Components
    @IBOutlet weak var panel: UIView!
    @IBOutlet weak var blurLayer: UIVisualEffectView!
    @IBOutlet weak var bottomPanel: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    // Data components
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var middleTemp: UILabel!
    
    @IBOutlet weak var batteryLabel: UILabel!
        
    @IBOutlet weak var InsulationStatus: UILabel!
    @IBOutlet weak var HumidityStatus: UILabel!
    @IBOutlet weak var scaleImageView: UIImageView!
    
        
    // Thermal SDK classes
    var thermalStreamer: FLIRThermalStreamer?
    var stream: FLIRStream?
    var battery: FLIRBattery?
    var cameraImport: FLIRCameraImport?
    var fusion: FLIRFusion?
    // Isotherm classes
    var isotherm: FLIRIsotherms?
    var thermalValue: FLIRThermalValue?
    var fillMode: FLIRIsothermFillmode?

    let renderQueue = DispatchQueue(label: "render")

    override func viewDidLoad() {
        super.viewDidLoad()
        discovery = FLIRDiscovery()
        discovery?.delegate = self
        
        // UI radius
        panel.layer.cornerRadius = 10
        deviceManager.layer.cornerRadius = 10
        bottomPanel.layer.cornerRadius = 10
        
        // Fine-tuning
        moreButton.setTitle("", for: .normal)
        cameraButton.setTitle("", for: .normal)
        recordButton.setTitle("", for: .normal)
        
        // Background (loading for the first time)
        self.Background = defaults.string(forKey: "Background")!
        setBackground(type: self.Background)
        view.layer.insertSublayer(BackgroundLayer, at: 0)
    }
    
    // UPDATING VALUES EVERYTIME VIEW APPEARS
    override func viewWillAppear(_ animated: Bool) {
        
        // Humidity indicator
        let HumidityVal = defaults.bool(forKey: "HumidityEnabled")
            if HumidityVal == true {
                HumidityStatus.text = "Enabled"
                HumidityStatus.textColor = .systemGreen
            }
            else {
                HumidityStatus.text = "Disabled"
                HumidityStatus.textColor = .systemRed
            }
        HumidityEnabled = HumidityVal
        
        // ^^ Keep at disabled
        
        // Insulation indicator
        let InsulationVal = defaults.bool(forKey: "InsulationEnabled")
            if InsulationVal == true {
                InsulationStatus.text = "Enabled"
                InsulationStatus.textColor = .systemGreen
            }
            else {
                InsulationStatus.text = "Disabled"
                InsulationStatus.textColor = .systemRed
            }
        InsulationEnabled = InsulationVal
        
        // Temperature Units
        if let unit = defaults.string(forKey: "Temperature") {
            switch unit {
            case "c":
                self.TempUnit = .CELSIUS
                self.TempUnitString = "°C"
            case "f":
                self.TempUnit = .FAHRENHEIT
                self.TempUnitString = "°F"
            case "k":
                self.TempUnit = .KELVIN
                self.TempUnitString = "°K"
            default: break
            }
        }
        else { // no value defined yet, default to celcius
            self.TempUnit = .CELSIUS
            self.TempUnitString = "°C"
        }
        
        // Styles
        self.ThermalFilter = defaults.string(forKey: "ThermalFilter")!
        self.EmulatorStatus = defaults.bool(forKey: "Emulator")
        self.CameraFilter = defaults.string(forKey: "CameraFilter")!
        self.Background = defaults.string(forKey: "Background")!
        setBackground(type: self.Background)
        
        self.viewAppeared = true // view appeared

    }
    
    // View Controller appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Creating the CameraImport
        cameraImport = FLIRCameraImport()
        cameraImport?.delegate = self
        

        // Creating other objects
        self.isotherm = FLIRIsotherms()
        self.fillMode = FLIRIsothermFillmode()
        self.fusion = FLIRFusion()
        
    }
    
    // View Controller disappears
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.isMovingFromParent {
            camera?.disconnect()
        }
    }
    
    func requireCamera() {
        guard camera == nil else {
            return
        }
        let camera = FLIRCamera()
        self.camera = camera
        camera.delegate = self

    }
    

    // MARK: Function events
    @IBAction func connectDeviceClicked(_ sender: Any) {
        discovery?.start(.lightning)
    }

    @IBAction func disconnectClicked(_ sender: Any) {
        camera?.disconnect()
    }
    
    @IBAction func connectDevice(_ sender: Any) {
        if (connected == false) { // connect device
            connected = true
            
            // Emulator vs real device
            if EmulatorStatus { // enabled emulator
                discovery?.start(.emulator)
            }
            else { // connect device
                discovery?.start(.lightning)
            }

            deviceManager.setTitle("Disconnect Device", for: UIControl.State.normal)

        }
        else { // disconnect device
            connected = false
            camera?.disconnect()
            
            deviceManager.setTitle("Connect Device", for: UIControl.State.normal)
            
            // reset insulation and humidity isotherm
            self.InsulationActivated = false
            self.HumidityActivated = false

        }
        
        
    }
        
    @IBAction func connectEmulatorClicked(_ sender: Any) {
        discovery?.start(.emulator)
    }

    @IBAction func ironPaletteClicked(_ sender: Any) {
        ironPalette = !ironPalette
    }
    
    // Functionalities pressed
    @IBAction func infoButtonPressed(_ sender: Any) {
        customAlert(title: "\nAbout the Data", message: DataMsg)
    }
    
    @IBAction func recordPressed(_ sender: Any) {
       record()
    }
    
    @IBAction func cameraPressed(_ sender: Any) {
        
        let screenshotOption = {(action: UIAction) in
            self.saveScreenshot()
            self.alert(title: "Screenshot taken", message: "")
        }
        
        let pictureOption = {(action: UIAction) in

            self.saveVideoCaptureImage()
            self.alert(title: "Camera feed saved", message: "")
        }
        
        cameraButton.menu = UIMenu(children: [
            UIAction(title: "Screenshot", image: UIImage(systemName: "camera.viewfinder"), state: .off, handler: screenshotOption),
            UIAction(title: "Capture Camera Feed", image: UIImage(systemName: "photo"), state: .off, handler: pictureOption)])
        
        cameraButton.showsMenuAsPrimaryAction = true
        
        }
    
    // UIAlert function
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    func customAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // TEXT STYLE
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let messageText = NSAttributedString(
            string: message,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.font : UIFont(name: "Arial", size: 15) as Any
            ]
        )

        alert.setValue(messageText, forKey: "attributedMessage")
        
        
        
        // WIDE WIDTH
        
        // Filtering width constraints of alert base view width
        let widthConstraints = alert.view.constraints.filter({ return $0.firstAttribute == .width })
        alert.view.removeConstraints(widthConstraints)
        // Here you can enter any width that you want
        let newWidth = UIScreen.main.bounds.width * 0.90
        // Adding constraint for alert base view
        let widthConstraint = NSLayoutConstraint(item: alert.view as Any,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: newWidth)
        alert.view.addConstraint(widthConstraint)
        let firstContainer = alert.view.subviews[0]
        // Finding first child width constraint
        let constraint = firstContainer.constraints.filter({ return $0.firstAttribute == .width && $0.secondItem == nil })
        firstContainer.removeConstraints(constraint)
        // And replacing with new constraint equal to alert.view width constraint that we setup earlier
        alert.view.addConstraint(NSLayoutConstraint(item: firstContainer,
                                                    attribute: .width,
                                                    relatedBy: .equal,
                                                    toItem: alert.view,
                                                    attribute: .width,
                                                    multiplier: 1.0,
                                                    constant: 0))
        // Same for the second child with width constraint with 998 priority
        let innerBackground = firstContainer.subviews[0]
        let innerConstraints = innerBackground.constraints.filter({ return $0.firstAttribute == .width && $0.secondItem == nil })
        innerBackground.removeConstraints(innerConstraints)
        firstContainer.addConstraint(NSLayoutConstraint(item: innerBackground,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: firstContainer,
                                                        attribute: .width,
                                                        multiplier: 1.0,
                                                        constant: 0))
        
        
        self.present(alert, animated: true)
    }
    
    func recordingStarted(){
                
        // Message with all the data, so that is recorded and isn't lost
        let insulFactor = defaults.string(forKey: "InsulationFactor")
        let indoorTemp = defaults.string(forKey: "IndoorTemperature")
        let outdoorTemp = defaults.string(forKey: "OutdoorTemperature")
        let airHumid = defaults.string(forKey: "AirHumidity")
        let airHumidAlarm = defaults.string(forKey: "AirHumidityAlarmLevel")
        let atmosTemp = defaults.string(forKey: "AtmosphericTemperature")
        
        var text = ""
        
        text = "[Insulation]\n\nInsulation Factor: " + insulFactor!
        text += "%\n\nIndoor Temperature: " + indoorTemp! + self.TempUnitString
        text += "\n\nOutdoor Temperature: " + outdoorTemp! + self.TempUnitString
        text += "\n\n[Humidity]\n\nAir Humidity: " + airHumid!
        text += "%\n\nAir Humidity Alarm Level: " + airHumidAlarm!
        text += "%\n\nAtmospheric Temperature: " + atmosTemp! + self.TempUnitString
        
        text += "\n\n*Important: Please ensure that your automatic screen turn-off timer is set to \"Never\" so that your phone does not turn off mid-recording."
        
        alert(title: "Data Parameters", message: text)
    }
    
    // Saving camera shots (screenshots + the camera)
    func saveScreenshot() {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
    }
    
    // Saving only camera feed
    func saveVideoCaptureImage() {
        self.thermalStreamer?.withThermalImage { image in
            let image = self.thermalStreamer?.getImage()
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
            }
    }
    
    
    // Truncation
    func roundValue(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.maximumSignificantDigits = 3 // so numbers don't get too long
        formatter.numberStyle = .decimal
        
        if let formattedString = formatter.string(for: value) {
            return formattedString
        }
        return "Error"
    }

    // ReplayKit
    fileprivate func record() {
        let recorder = RPScreenRecorder.shared()
        if !recorder.isRecording {
            recorder.startRecording { [unowned self] (error) in
                if let unwrappedError = error {
                    print(unwrappedError.localizedDescription)
                } else { // recording has started
                    self.recordButton.setImage(UIImage(systemName: "record.circle.fill"), for: .normal)
                    self.recordButton.tintColor = .red
                    
                    recordingStarted() // function to run once recording has started
                }
            }
        } else { // is recording
            recorder.stopRecording(handler: { [unowned self] (preview, error) in
                self.recordButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
                self.recordButton.tintColor = .link
                
                if let unwrappedPreview = preview {
                    unwrappedPreview.previewControllerDelegate = self
                    self.present(unwrappedPreview, animated: true)
                }
            })
        }
    }
    
    func setBackground(type: String) {
        self.BackgroundLayer.startPoint = CGPoint(x: 0, y: 0)
        self.BackgroundLayer.endPoint = CGPoint(x: 1, y: 1)
        
        if type == "Cool" {
            self.BackgroundLayer.colors = [UIColor.systemBlue.cgColor, UIColor.white.cgColor]
        }
        else if type == "Default" {
            self.BackgroundLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
        }
        else { // Thermal
            self.BackgroundLayer.colors = [UIColor.purple.cgColor, UIColor.orange.cgColor]

        }
        
        self.BackgroundLayer.frame = view.frame
    }
    

    /*@IBAction func distanceSliderValueChanged(_ sender: Any) {
        if let remoteControl = self.camera?.getRemoteControl(),
           let fusionController = remoteControl.getFusionController() {
            //let newDistance = distanceSlider.value
            try? fusionController.setFusionDistance(Double(newDistance))
        }
    } */
    
}


extension ViewController: FLIRDiscoveryEventDelegate {

    func cameraFound(_ cameraIdentity: FLIRIdentity) {
        switch cameraIdentity.cameraType() {
        case .flirOne:
            requireCamera()
            guard !camera!.isConnected() else {
                return
            }
            DispatchQueue.global().async {
                do {
                    try self.camera?.connect(cameraIdentity)
                    let streams = self.camera?.getStreams()
                    guard let stream = streams?.first else {
                        NSLog("No streams found on camera!")
                        return
                    }
                    self.stream = stream
                    self.thermalStreamer = FLIRThermalStreamer(stream: stream)
                    self.thermalStreamer?.autoScale = true
                    self.thermalStreamer?.renderScale = true
                    stream.delegate = self
                    do {
                        try stream.start()
                    } catch {
                        NSLog("stream.start error \(error)")
                    }
                } catch {
                    NSLog("Camera connect error \(error)")
                }
                
                // Subscribe to battery
                self.battery = FLIRBattery()
                self.battery = self.camera?.getRemoteControl()?.getBattery()
                
                do {
                    try self.battery?.subscribePercentage()
                }
                catch {
                    NSLog("Battery percentage subscription error: \(error)")
                }
                
                                
            }
        case .generic:
            ()
        @unknown default:
            fatalError("unknown cameraType")
        }
    }

    func discoveryError(_ error: String, netServiceError nsnetserviceserror: Int32, on iface: FLIRCommunicationInterface) {
        NSLog("\(#function)")
    }

    func discoveryFinished(_ iface: FLIRCommunicationInterface) {
        NSLog("\(#function)")
    }

    func cameraLost(_ cameraIdentity: FLIRIdentity) {
        NSLog("\(#function)")
    }
}

extension ViewController : FLIRDataReceivedDelegate {
    func onDisconnected(_ camera: FLIRCamera, withError error: Error?) {
        NSLog("\(#function) \(String(describing: error))")
        DispatchQueue.main.async {
            self.thermalStreamer = nil
            self.stream = nil
            let alert = UIAlertController(title: "Disconnected",
                                          message: "Flir One disconnected",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController : FLIRStreamDelegate {
    func onError(_ error: Error) {
        NSLog("\(#function) \(error)")
    }
    // When the image is received
    func onImageReceived() {
        renderQueue.async {
            do {
                try self.thermalStreamer?.update()
            } catch {
                NSLog("update error \(error)")
            }
            let image = self.thermalStreamer?.getImage()
            DispatchQueue.main.async {
                    self.imageView.image = image
                if let scaleImage = self.thermalStreamer?.getScaleImage() {
                    self.scaleImageView.image = scaleImage.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
                }
                self.thermalStreamer?.withThermalImage { image in // Thermal Filters
                    if self.ThermalFilter == "Iron" && image.palette?.name != image.paletteManager?.iron.name {
                        image.palette = image.paletteManager?.iron
                    }
                    else if self.ThermalFilter == "Coldest" && image.palette?.name != image.paletteManager?.coldest.name{
                        image.palette = image.paletteManager?.coldest
                    }
                    else if self.ThermalFilter == "Hottest" && image.palette?.name != image.paletteManager?.hottest.name{
                        image.palette = image.paletteManager?.hottest
                    }
                    else if self.ThermalFilter == "Lava" && image.palette?.name != image.paletteManager?.lava.name{
                        image.palette = image.paletteManager?.lava
                    }
                    else if self.ThermalFilter == "Arctic" && image.palette?.name != image.paletteManager?.arctic.name{
                        image.palette = image.paletteManager?.arctic
                    }
                    else if self.ThermalFilter == "Blackhot" && image.palette?.name != image.paletteManager?.blackhot.name{
                        image.palette = image.paletteManager?.blackhot
                    }
                    else if self.ThermalFilter == "Gray" && image.palette?.name != image.paletteManager?.gray.name{
                        image.palette = image.paletteManager?.gray
                    }
                    
                    // Visual Camera Filter
                    self.visualImageView.image = image.getPhoto()

                    // Temperature Unit
                    image.setTemperatureUnit(self.TempUnit)
                    
                    // Max, min temperatures
                    let minVal = image.getStatistics()?.getMin()
                    let maxVal = image.getStatistics()?.getMax()
                    self.maxTemp.text = self.roundValue(value: maxVal!.value) + self.TempUnitString
                    self.minTemp.text = self.roundValue(value: minVal!.value) + self.TempUnitString
                    // middle temperature on linear scale
                    self.middleTemp.text = self.roundValue(value: ((maxVal!.value + minVal!.value)/2)) + self.TempUnitString
                    
                    // Battery
                    if self.viewAppeared { // everytime the view loads for a new time
                        self.viewAppeared = false
                        self.batteryLabel.text = String(self.battery!.getPercentage()) + "%"
                    }
                                        
                    // Defining Isotherm
                    self.isotherm = image.getIsotherms()
                    
                    // Insulation Mode
                    if(self.InsulationEnabled && !self.InsulationActivated) {
                        self.InsulationActivated = true
                        let InsulFactor = self.defaults.integer(forKey: "InsulationFactor")
                        let IndoorTemp = self.defaults.integer(forKey: "IndoorTemperature")
                        let OutdoorTemp = self.defaults.integer(forKey: "OutdoorTemperature")
                        let insulation = self.isotherm?.addInsulation(withIndoorAirTemperature: FLIRThermalValue(value: Double(IndoorTemp), andUnit: self.TempUnit), outdoorAirTemperature: FLIRThermalValue(value: Double(OutdoorTemp), andUnit: self.TempUnit), insulationFactor: Float(InsulFactor), fillMode: self.fillMode!)
                    }
                    
                    // Humidity Mode
                    if(self.HumidityEnabled && !self.HumidityActivated) {
                        self.HumidityActivated = true
                        let AirHumidity = self.defaults.integer(forKey: "AirHumidity")
                        let AlarmTemp = self.defaults.integer(forKey: "AirHumidityAlarmTemperature")
                        let AtmosTemp = self.defaults.integer(forKey: "AtmosphericTemperature")
                        let humidity = self.isotherm?.add(withAirHumidity: Float(AirHumidity), airHumidityAlarmLevel: Float(AlarmTemp), atmosphericTemperature: FLIRThermalValue(value: Double(AtmosTemp), andUnit: self.TempUnit), fillMode: self.fillMode!)
                    }
                                                            
                    if let measurements = image.measurements {
                        if measurements.getAllSpots().isEmpty {
                            do {
                                let measure = try measurements.addSpot(CGPoint(x: CGFloat(image.getWidth()) / 2,
                                                                 y: CGFloat(image.getHeight()) / 2))
                                                                
                            } catch {
                                NSLog("addSpot error \(error)")
                            }
                        }
                        }
                    }

                    }
                }
            }
        }

extension ViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }
}

extension ViewController: FLIRCameraImportEventDelegate {
    func fileAdded(_ filename: String) {
        
    }
    
    func fileError(_ filename: String) {
        
    }
    
    func importError(_ e: [String : String]) {
        
    }
    
    func fileProgress(_ progress: Int, total: Int, file: FLIRFileReference) {
        
    }
}

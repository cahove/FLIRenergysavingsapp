//
//  InnerSettingsMenu.swift
//  FLIROneCameraSwift
//
//  Created by Christopher Hove on 01/10/2022.
//  Copyright © 2022 sample. All rights reserved.
//

import SwiftUI
import ThermalSDK

class InnerSettingsMenu: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
        
    /*
     Row keys and their buttons [Menu options]
     0 = Temperature
     1 = ThermalFilter
     2 = CameraFilter
     3 = Background
     3 = InsulationFactor
     4 = InsulationEnabled
     5 = (edit)
     6 = HumidityEnabled
     */
    
    var menuOption: String? // determines what menu was picked
    var checkMarkPos: String? // Where to put the checkmark
    var TempUnitString = "" // The temperature unit

    let defaults = UserDefaults.standard
    
    // Picker values
    var pickerView: UIPickerView!
    var pickerData: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update Temperature Unit
        if let unit = defaults.string(forKey: "Temperature") {
            switch unit {
            case "c":
                self.TempUnitString = "°C"
            case "f":
                self.TempUnitString = "°F"
            case "k":
                self.TempUnitString = "°K"
            default: break
            }
        }
        else { // no value defined yet, default to celcius
            self.TempUnitString = "°C"
        }
        
        
        // Creating picker data
        let min = 0
        let max = 100
         pickerData = Array(stride(from: min, to: max + 1, by: 1))
        
        // LOAD DATA VALUES
        if (menuOption == "Temperature") {
            if let tempValue = defaults.string(forKey: "Temperature") {  // load temperature
                checkMarkPos = tempValue
            }
            else {
                // default is celcius
                    checkMarkPos = "c"
            }
        }
        
        else if menuOption == "ThermalFilter" {
            if let value = defaults.string(forKey: "ThermalFilter") {
                checkMarkPos = value
            }
            else { // default
                checkMarkPos = "Iron"
            }
        }
        
        else if menuOption == "CameraFilter" {
            if let value = defaults.string(forKey: "CameraFilter") {
                checkMarkPos = value
            }
            else { // default
                checkMarkPos = "Thermal"
            }
        }
        
        else if menuOption == "Background" {
            if let value = defaults.string(forKey: "Background") {
                checkMarkPos = value
            }
            else { // default
                checkMarkPos = "Thermal"
            }
        }
        
        // for title
        var title = ""
        switch menuOption {
        case "Temperature": title = "Temperature"
        case "ThermalFilter": title = "Thermal Filter"
        case "CameraFilter": title = "Camera Filter"
        case "Background": title = "Background"
        case "InsulationFactor": title = "Insulation Factor"
        case "IndoorTemperature": title = "Indoor Temperature"
        case "OutdoorTemperature": title = "Outdoor Temperature"
        case "AirHumidity": title = "Air Humidity"
        case "AirHumidityAlarmLevel": title = "Air Humidity Alarm Level"
        default: break
        }
        navigationItem.title = title
        
    }
    
    
    // BUTTON PRESSED
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // VALUE SAVED
        if menuOption == "Temperature" { // Temperature
            
            switch indexPath.row {
            case 0:
                checkMarkPos = "c"
                
            case 1:
                checkMarkPos = "f"
                
            case 2:
                checkMarkPos = "k"
            default:
                break
            }
        }
        
        if menuOption == "ThermalFilter" {
            switch indexPath.row {
            case 0: checkMarkPos = "Iron"
            case 1: checkMarkPos = "Coldest"
            case 2: checkMarkPos = "Hottest"
            case 3: checkMarkPos = "Lava"
            case 4: checkMarkPos = "Arctic"
            case 5: checkMarkPos = "Blackhot"
            case 6: checkMarkPos = "Gray"
            default: break
            }
        }
        
        if menuOption == "CameraFilter" {
            switch indexPath.row {
            case 0: checkMarkPos = "Thermal"
            case 1: checkMarkPos = "Visual"
            default: break
            }
        }
        
        if menuOption == "Background" {
            switch indexPath.row {
            case 0: checkMarkPos = "Thermal"
            case 1: checkMarkPos = "Default"
            case 2: checkMarkPos = "Cool"
            default: break
            }
        }
        
        // DESELECT ROW
        tableView.deselectRow(at: indexPath, animated: true) // dims
        
        if menuOption == "Temperature" || menuOption == "ThermalFilter" ||
            menuOption == "Background" || menuOption == "CameraFilter" {
            defaults.set(checkMarkPos, forKey: menuOption!)
            
            // clears check marks
            for num in 0...tableView.numberOfRows(inSection: indexPath.section) {
                tableView.cellForRow(at: IndexPath(row: num, section: indexPath.section))?.accessoryType = UITableViewCell.AccessoryType.none
            }
            // update check mark
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        else { // it's an input option
            if (indexPath.row == 1) { // edit button pressed
                if (menuOption == "InsulationFactor" || menuOption == "AirHumidity" || menuOption == "AirHumidityAlarmLevel") { // percentage
                    userPicksNumber(keyName: menuOption!)
                }
                else { // user enters number
                    userEntersNumber(keyName: menuOption!)
                }
            }
        }
        
    }
    
    
    // MAX NUMBER OF SECTIONS
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // NUMBER OF ROWS IN SECTION BASED ON BUTTON
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch menuOption {
        case "Temperature": return 3
        case "ThermalFilter": return 7
        case "CameraFilter": return 2
        case "Background": return 3
        case "x": return 0
        default: return 2 // for all the input options
        }
    }
    
    
    // CELL LAYOUT
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        // FOR ALL: Create cell and content
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath)
        var content = UIListContentConfiguration.accompaniedSidebarCell()

        
        // Temperature Unit
        if (menuOption == "Temperature") {
            // Text
            switch indexPath.row {
            case 0:
                content.text = "Celcius (°C)"
                
            case 1:
                content.text = "Farenheit (°F)"
                
            case 2:
                content.text = "Kelvin (°K)"
                
            default: break
            }
        }
                    
        else if (menuOption == "ThermalFilter") {
            switch indexPath.row {
            case 0: content.text = "Iron"
            case 1: content.text = "Coldest"
            case 2: content.text = "Hottest"
            case 3: content.text = "Lava"
            case 4: content.text = "Arctic"
            case 5: content.text = "Blackhot"
            case 6: content.text = "Gray"
            default: break
            }
        }

        else if (menuOption == "Background") {
            switch indexPath.row {
            case 0: content.text = "Thermal"
            case 1: content.text = "Default (white)"
            case 2: content.text = "Cool"
            default: break
            }
        }
        
        else if (menuOption == "InsulationFactor" || menuOption == "IndoorTemperature" ||
                menuOption == "OutdoorTemperature" || menuOption == "AirHumidity" ||
                menuOption == "AirHumidityAlarmLevel" || menuOption == "AtmosphericTemperature") {
            switch indexPath.row {
            case 0:
                content.text = String(defaults.integer(forKey: menuOption!))
                cell.selectionStyle = .none
                
                // Add Temperature
                if (menuOption == "IndoorTemperature" || menuOption == "OutdoorTemperature" ||
                    menuOption == "AtmosphericTemperature") {
                    content.text = content.text! + TempUnitString
                } // Add Percent
                else if (menuOption == "InsulationFactor" || menuOption == "AirHumidity" || menuOption == "AirHumidityAlarmLevel") {
                    content.text = content.text! + "%"
                }
                
            case 1:
                content.text = "Edit"
                content.textProperties.color = .systemBlue
                cell.accessoryType = .detailButton
            default: break
            }
        }
            
            // Checkmark
        if ((checkMarkPos == "c" && indexPath.row == 0) ||
            (checkMarkPos == "f" && indexPath.row == 1) ||
            (checkMarkPos == "k" && indexPath.row == 2) ||
            (checkMarkPos == "Iron" && indexPath.row == 0 ||
            (checkMarkPos == "Coldest" && indexPath.row == 1) ||
            (checkMarkPos == "Hottest" && indexPath.row == 2) ||
            (checkMarkPos == "Lava" && indexPath.row == 3) ||
            (checkMarkPos == "Arctic" && indexPath.row == 4) ||
            (checkMarkPos == "Blackhot" && indexPath.row == 5) ||
            (checkMarkPos == "Gray" && indexPath.row == 6) ||
            (checkMarkPos == "Thermal" && indexPath.row == 0) ||
            (checkMarkPos == "Default" && indexPath.row == 1) ||
            (checkMarkPos == "Cool" && indexPath.row == 2)))
            {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
            
        
        // Update content
            cell.contentConfiguration = content
        
        return cell
    }
    
    
    // NUMBER PICKER
    func userPicksNumber(keyName: String) {
        // picker data
        pickerView = UIPickerView(frame: CGRect(x: 10, y: 50, width: 250, height: 170))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(defaults.integer(forKey: keyName), inComponent: 0, animated: true)
        
        // alert
        let alert = UIAlertController(title: "Select a percentage", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.view.addSubview(pickerView)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let pickerValue = self.pickerData[self.pickerView.selectedRow(inComponent: 0)]
            self.defaults.set(pickerValue, forKey: keyName)
            self.tableView.reloadData() // reloads page
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func userEntersNumber(keyName: String) {
        // TextField
        let textField = UITextField(frame: CGRect(x: 10, y: 80, width: 250, height: 50))
        textField.addNumericAccessory(addPlusMinus: true)
        textField.borderStyle = .roundedRect
        textField.text = String(self.defaults.integer(forKey: keyName))
        textField.clearsOnBeginEditing = true
        textField.delegate = self
        textField.keyboardType = UIKeyboardType.decimalPad
        
        // alert
        let alert = UIAlertController(title: "Enter a number", message: "\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.view.addSubview(textField)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let number = Double(textField.text!)
            if (number != nil) {
                self.defaults.set(number, forKey: keyName)
                self.tableView.reloadData() // reloads page
            }
            else { // value entered isn't a number
                self.alert(title: "Input Error", message: "The value entered is not a valid number. If a number with decimals was entered, try again without using decimals.")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    // UIALERT FUNCTION
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row])"
    }
    
    // HEADER (default)
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    // FOOTER (information about each field)
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var text = ""
        switch menuOption {
        case "Temperature": text = "Select a temperature unit."
        case "ThermalFilter": text = "Select a thermal filter. Thermal filters change the colors of the camera feed. Some thermal filters are specified for specific purposes, such as the coldest filter is for determining the coldest temperatures, and the hottest filter determined the hottest temperatures."
        case "Background": text = "Select the background of the \"Home\" page."
        case "InsulationFactor": text = "Choose the insulation factor percentage of your home based off where you live. A typical r-value would be between 60%-70%. Visit \"Read More\" to learn more or visit energy.gov/insulation"
        case "IndoorTemperature": text = "Enter the temperature inside your house."
        case "OutdoorTemperature": text = "Enter the temperature outside."
        case "AirHumidity": text = "Select the percentage humidity outside."
        case "AirHumidityAlarmLevel": text = "Select the humidity percentage threshold. Any value above this temperature will be marked on the camera feed."
        case "AtmosphericTemperature": text = "Select the atmospherice temperature."
        default: return ""
        }
        return text
    }
    
    
}

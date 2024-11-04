//
//  ContentView.swift
//  Roof Inspection
//
//  Created by Christopher Hove on 29/08/2022.
//

import SwiftUI
import ThermalSDK

class Settings: UITableViewController {
    
    /*
     [MenuOption names]
     "Temperature"
     "ThermalFilter"
     "CameraFilter"
     "Background"
     
     "InsulationFactor"
     "IndoorTemperature"
     "OutdoorTemperature"
     "InsulationEnabled"
     
     "AirHumidity"
     "AirHumidityAlarmLevel"
     "AtmosphericTemperature"
     "HumidityEnabled"
     
     "Emulator"
     */
    
    // Read More Messages
    let InsulationMsg = "\nThe Insulation isotherm, when enabled, highlights temperatures above a certain temperature range. These temperature ranges can be viewed on the camera feed. It is important to note that the accuracy of this isotherm is limited to the accuracy of the temperature measurements.\n\n[The Insulation Section] of the settings page allows you to customize values to point out areas that are unusually high.\n\n[\"Insulation Factor\"] the insulation factor of a building, or its r-value, describes a material's resistence to heat flow. The higher it is, the more insulated the material should be, and the lower it is, the less insulated the material should be. To determine your r-value, visit energy.gov/insulation. R-values depend on the county and region you live in.\n\n[\"Indoor Temperature\"] the indoor temperature of your house.\n\n[\"Outdoor Temperature\"] the outdoor temperature.\n\n[How it works] The indoor and outdoor temperature values as well as the insulation factor calculate an \"Insulation Temperature\" that defines the maximum amount of heat that should be measured on your roof. Any areas of your roof that are measured above that threshold will be highlighted and may be an area that has a heat leak. You can see this calculated temperature value under \"Insulation\" on the \"Home\" page.\n\n[How to enable it] In order to enable this filter, you have to ensure that the \"Toggle Filter\" button is set to on.\n\n[The Importance of Insulation] The insulation of your house is very important and it's ability to insulate should be check regularly. A poorly insulated house means that there is heat escaping the house or heat entering the house, if it hotter outside. If you are using an air conditioner to cool down your house or heat it up, this energy can be lost through leaks in your house where it can escape. This can be costly and consume a lot of energy. The roof is particularly an area of a house prone to leaks and needs to be well maintained. Using this tool, you may be able to identify any insulation issues so that you can save energy and money. Read energy.gov/insulation for more."
    let HumidityMsg = "\nThe Humidity isotherm, when enabled, highlights humidity levels above a certain threshold. These areas are highlighted on the camera feed. This isotherm also takes into account the atmospheric temperature, which is measured by the radiometric camera. It is important to note that the accuracy of this isotherm is limited to the accuracy of the camera device and its measurements.\n\n[The Humidity Section] of the settings page allows you to customize values to point out areas that have an unusually high humidity percentage.\n\n[\"Air Humidity\"] the percentage humidity in the atmosphere.\n\n[\"Air Humidity Alarm Level\"] The threshold of air humidity, in which any percent of humidity above this percentage will be flagged on the camera feed.\n\n[How it works] The current humidity level as well as the humidity alarm level will calculate a \"Dew Point Temperature\" that is the temperature where relative humidity reaches 100%. This means that at that temperature, the water vapor in the atmosphere is at its maximum capacity and no more water vapor can evaporate. To determine the relative humidity, see \"Re. Humid.\" on the \"Home\" page. Relative humidity is calculated independent of this filter. To see the calculated Dew Point value, look under \"Humidity\" on the \"Home\" page.\n\n[How to enable it] In order to enable this filter, you have to ensure that the \"Toggle Filter\" button is set to on.\n\n[The Importance of being careful of areas of high humidity] High humidity, or high amounts of water vapor in the atmosphere can lead to the development of mold. Mold can weaken the house's structure and lead to health problems. This isotherm flags areas of high humidity which may be subject to mold growth and may require that you personally inspect them. To learn how to fix areas of high humidity and manage humidity, visit energy.gov/energysaver/moisture-control."
    let AboutAppMsg = "\nRoof Inspection is an application that helps you analyze insulation and humidity through thermal images taken by the FLIR ONE Pro camera. This app only works in companion with the FLIR ONE Pro, however if you do not have the camera, you can still test this app's features by enabling the \"Emulator\" option. Otherwise, turn it off in order to connect your camera.\n\n[How to use this app] The \"Home\" page provides you with three sections. At the top, you are able to connect your device. Once connected, a camera feed will pop up in the middle section. Alongside it will be a linear scale showing the color scale of the filter and the maximum, middle, and smallest values measured from top to bottom. On the right of that, there is a screen-recording feature, a camera-feature that can take screenshots or only capture the camera's feed, and an Info feature that explains what the data values mean in the third section. The third section shows the data values. If you would like to know what they mean, visit the Info feature on the \"Home\" page. On the \"Settings\" page, you can edit some styles, or enabled the insulation isotherm (filter), or the humidity isotherm (filter). Click \"Read More\" under both to understand what they do. The function of the styles is provided in the new tab that they open when clicked."
    
    
    
    let defaults = UserDefaults.standard // data
    
    // cell that has been pressed
    var row = 0
    var section = 0
    
    // Temperature unit
    var TempUnitString = ""
    
    // HEADERS
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = .black
        header.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        header.textLabel?.frame = header.bounds
        header.textLabel?.textAlignment = .left
    }
    
    // TABLE APPEARS >> RELOADS DATA
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        // Reload data
        tableView.reloadData()
    }
    
    // BUTTON SELECTED
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         row = indexPath.row
         section = indexPath.section
        
        if (indexPath.section == 0 ||
            (indexPath.section == 1 && indexPath.row != 3 && indexPath.row != 4) ||
            (indexPath.section == 2 && indexPath.row != 3 && indexPath.row != 4)) { // only certain buttons have new tabs
            performSegue(withIdentifier: "showdetail", sender: self)
        }
        
        // About insulation
        else if (indexPath.section == 1 && indexPath.row == 4) {
            // deselect
            tableView.deselectRow(at: indexPath, animated: true)
            
            // send message
            customAlert(title: "\nAbout the Insulation Feature", message: self.InsulationMsg)
        }
        
        // About Humidity
        else if (indexPath.section == 2 && indexPath.row == 4) {
            // deselect
            tableView.deselectRow(at: indexPath, animated: true)
            
            // send message
            customAlert(title: "\nAbout the Humidity Feature", message: self.HumidityMsg)
        }
        
        // About this App
        else if (indexPath.section == 3 && indexPath.row == 1) {
            // deselect
            tableView.deselectRow(at: indexPath, animated: true)
            
            // send message
            customAlert(title: "\nAbout This App", message: self.AboutAppMsg)
            }
        
    }
        
    // MAIN UI LAYOUT
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var content = UIListContentConfiguration.accompaniedSidebarSubtitleCell()
        
        var officialDataName = "" // used to figure out what each data point refers to

        // STYLES
        if (indexPath.row == 0 && indexPath.section == 0) {
            
            var val = ""
            if let tempValue = defaults.string(forKey: "Temperature") { // load temperature
                val = tempValue
            }
            
            var text = ""
            
            switch val {
            case "c":
                text = "°C"
            case "f":
                text = "°F"
            case "k":
                text = "°K"
            default: text = "°C"
            }
            content.text = "Temperature Unit"
            content.secondaryText = text
            content.secondaryTextProperties.font = .systemFont(ofSize: 16.5)
        }
        else if (indexPath.row == 1 && indexPath.section == 0) {
            content.text = "Thermal Filter"
            officialDataName = "ThermalFilter"
        }
        
        else if (indexPath.row == 2 && indexPath.section == 0) {
            content.text = "Background"
            officialDataName = "Background"
        }
        
        // INSULATION
        else if (indexPath.row == 0 && indexPath.section == 1) {
            content.text = "Insulation Factor"
            officialDataName = "InsulationFactor"
        }
        
        else if (indexPath.row == 1 && indexPath.section == 1) {
            content.text = "Indoor Temperature"
            officialDataName = "IndoorTemperature"
        }
        
        else if (indexPath.row == 2 && indexPath.section == 1) {
            content.text = "Outdoor Temperature"
            officialDataName = "OutdoorTemperature"
        }
        
        else if (indexPath.row == 3 && indexPath.section == 1) {
            content.text = "Toggle Filter"
            officialDataName = "InsulationEnabled"
            
            // SWITCH
            let InsulationSwitch = UISwitch()
            InsulationSwitch.addTarget(self, action: #selector(self.InsulationSwitchChange(_:)), for: .valueChanged)
            
            InsulationSwitch.setOn(defaults.bool(forKey: "InsulationEnabled"), animated: true)
            InsulationSwitch.tag = indexPath.row
            cell.accessoryView = InsulationSwitch
        }
        
        else if (indexPath.row == 4 && indexPath.section == 1) {
            content.text = "Read More"
            content.textProperties.color = .systemBlue
        }
        
        //HUMIDITY
        else if (indexPath.row == 0 && indexPath.section == 2) {
            content.text = "Air Humidity"
            officialDataName = "AirHumidity"
        }
        
        else if (indexPath.row == 1 && indexPath.section == 2) {
            content.text = "Air Humidity Alarm Level"
            officialDataName = "AirHumidityAlarmLevel"
        }
        
        else if (indexPath.row == 2 && indexPath.section == 2) {
            content.text = "Atmospheric Temperature"
            officialDataName = "AtmosphericTemperature"
        }
        
        else if (indexPath.row == 3 && indexPath.section == 2) {
            content.text = "Toggle Filter"
            officialDataName = "HumidityEnabled"
            
            // SWITCH
            let InsulationSwitch = UISwitch()
            InsulationSwitch.addTarget(self, action: #selector(self.HumiditySwitchChange(_:)), for: .valueChanged)
            
            InsulationSwitch.setOn(defaults.bool(forKey: "HumidityEnabled"), animated: true)
            InsulationSwitch.tag = indexPath.row
            cell.accessoryView = InsulationSwitch
        }
        
        else if (indexPath.row == 4 && indexPath.section == 2) {
            content.text = "Read More"
            content.textProperties.color = .systemBlue
        }
        
        else if (indexPath.row == 0 && indexPath.section == 3) {
            content.text = "Emulator"
            officialDataName = "Emulator"
            
            // SWITCH
            let EmulatorSwitch = UISwitch()
            EmulatorSwitch.addTarget(self, action: #selector(self.EmulatorSwitchChange(_:)), for: .valueChanged)
            
            EmulatorSwitch.setOn(defaults.bool(forKey: "Emulator"), animated: true)
            EmulatorSwitch.tag = indexPath.row
            cell.accessoryView = EmulatorSwitch
        }
        
        else if (indexPath.row == 1 && indexPath.section == 3) {
            content.text = "About This App"
            content.textProperties.color = .systemBlue
        }
        
        
        // SIDEBAR INFORMATION
        
        // extra information for every item except the first, Insulation and Humidity toggle filters
        if ((indexPath.section == 0 && indexPath.row != 0) ||
            (indexPath.section == 1 && indexPath.row != 3 && indexPath.row != 4) ||
            (indexPath.section == 2 && indexPath.row != 3 && indexPath.row != 4)) {
            if let val = defaults.string(forKey: officialDataName) {
                content.secondaryText = val
            }
            else {
                content.secondaryText = "0"
            }
            
            // Add on units
            
            // Add Temperature
            if (officialDataName == "IndoorTemperature" || officialDataName == "OutdoorTemperature" ||
            officialDataName == "AtmosphericTemperature") {
                content.secondaryText = content.secondaryText! + TempUnitString
            } // Add Percent
            else if (officialDataName == "InsulationFactor" || officialDataName == "AirHumidity" ||
            officialDataName == "AirHumidityAlarmLevel") {
                content.secondaryText = content.secondaryText! + "%"
            }
            
            
            content.secondaryTextProperties.font = .systemFont(ofSize: 16.5)
        }
        
        // side view for all except toggle filters
        if (!(indexPath.section == 1 && indexPath.row == 3) &&
            !(indexPath.section == 2 && indexPath.row == 3)) {
            content.prefersSideBySideTextAndSecondaryText = true
            cell.contentConfiguration = content
        }
    }
        
    // PREPARING FOR TRANSITION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let VC = segue.destination as? InnerSettingsMenu else { return }
        // Identifier based on button clicked
        switch section {
        case 0:
            switch row {
            case 0: VC.menuOption = "Temperature"
            case 1: VC.menuOption = "ThermalFilter"
            case 2: VC.menuOption = "Background"
            default: break
            }
        case 1:
            switch row {
            case 0: VC.menuOption = "InsulationFactor"
            case 1: VC.menuOption = "IndoorTemperature"
            case 2: VC.menuOption = "OutdoorTemperature"
            default: break
            }
        case 2:
            switch row {
            case 0: VC.menuOption = "AirHumidity"
            case 1: VC.menuOption = "AirHumidityAlarmLevel"
            case 2: VC.menuOption = "AtmosphericTemperature"
            default: break
            }
        default: break
        }
    }
    
    // Insulation Switch Change of State
    @objc func InsulationSwitchChange(_ sender: UISwitch!) {
        
        defaults.set(sender.isOn, forKey: "InsulationEnabled") // updating value
        
        if(defaults.bool(forKey: "HumidityEnabled") == true) { // Humidity is enabled, so disable
            // update other value
            defaults.set(false, forKey: "HumidityEnabled")
            
            // alert and refresh
            alert(title: "Humidity filter is already enabled", message: "You cannot have the humidity filter and the insulation filter on at the same time")
            tableView.reloadData() // refreshes values
        }
    }
    // Humidity version
    @objc func HumiditySwitchChange(_ sender: UISwitch!) {
    
        defaults.set(sender.isOn, forKey: "HumidityEnabled") // updating value
        
        if(defaults.bool(forKey: "InsulationEnabled") == true) { // Humidity is enabled, so disable
            // update other value
            defaults.set(false, forKey: "InsulationEnabled") // updating value

            // alert and refresh
            alert(title: "Insulation filter is already enabled", message: "You cannot have the humidity filter and the insulation filter on at the same time")
            tableView.reloadData() // refreshes values
        }
    }
    
    // Emulator version
    @objc func EmulatorSwitchChange(_ sender: UISwitch!) {
        defaults.set(sender.isOn, forKey: "Emulator") // updating value
        tableView.reloadData() // refreshes values
    }
    
    // UIALERT FUNCTION
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        
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
}

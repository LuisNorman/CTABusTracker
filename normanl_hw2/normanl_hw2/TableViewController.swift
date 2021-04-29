//
//  TableViewController.swift
//  normanl_hw2
//
//  Created by Luis Norman Jr on 4/28/21.
//


// Disscusstion: I build a an app that fetched bus numbers and their routes and display that information in a table


import UIKit


let url = "http://www.ctabustracker.com/bustime/api/v2/getroutes?key=aEtwGtM5VihPceZyyYhUDZwm4&format=json"


class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    class Bus {
        var busRoute : String = ""
        var busNumber : String = ""
    }
    
    var dataAvailable = false
    var busses : [Bus] = []


    // MARK: - Table view data source

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        for bus in busses {
            bus.busRoute = ""
            bus.busNumber = ""
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataAvailable ? busses.count : 15
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (dataAvailable) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LazyTableCell", for: indexPath)
            let currentBus = busses[indexPath.row]
            cell.textLabel?.text = currentBus.busNumber
            cell.detailTextLabel?.text = currentBus.busRoute
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell", for: indexPath)
            return cell
        }
        
    }
    

    
    func loadData() {
        print("Starting")
        guard let feedURL = URL(string: url) else {

            return
        }
        
        let request = URLRequest(url: feedURL)
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let data = data else { return }
            
            print(data)
            
            do {
                if let json =
                    try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {

                    guard let bustime_response = json["bustime-response"] as? [String:Any]
                    else { throw SerializationError.missing("bustime-response") }

                    guard let routes = bustime_response["routes"] as? [Any]
                    else { throw SerializationError.missing("routes") }
                    
                    
                    for route in routes {
                        do {
                            if let currentRoute = route as? [String:Any] {
                                guard let busNumber = currentRoute["rt"] as? String else {
                                    throw SerializationError.missing("bus number")
                                }
                                guard let busRoute = currentRoute["rtnm"] as? String else {
                                    throw SerializationError.missing("route")
                                }
                                let bus = Bus()
                                bus.busNumber = busNumber
                                bus.busRoute = busRoute
                                self.busses.append(bus)
                            }
                        }
                        catch SerializationError.missing(let msg) {
                            print("Missing \(msg)")
                        } catch SerializationError.invalid(let msg, let data) {
                            print("Invalid \(msg): \(data)")
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }
                    
                    self.dataAvailable = true
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                    
                }
            } catch SerializationError.missing(let msg) {
                print("Missing \(msg)")
            } catch SerializationError.invalid(let msg, let data) {
                print("Invalid \(msg): \(data)")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }.resume()
    }
    

}

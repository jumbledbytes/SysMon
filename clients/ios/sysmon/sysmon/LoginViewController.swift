//
//  LoginViewController.swift
//  sysmon
//
//  Created by Jeff on 4/24/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import UIKit
import CoreData

@objc class LoginViewController: UIViewController, NSFetchedResultsControllerDelegate {

    
    var sysmonPort = 7588;
    var sysmonHost = "";
    var sysmonUser = "";
    var sysmonPassword = "";
    var coreDataLoaded = false;
    var dataSource : Datasource.DatasourceInterface? = nil;
    var validDataSource = false;
    var errorMessage = "";
    var authenticator : Authenticator?;
    
    var deviceName : String = "";
    var deviceToken : String = "";
    
    
    @IBOutlet weak var hostNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var connectingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var validateSSLSwitch: UISwitch!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    
    static var managedObjectContext: NSManagedObjectContext? = nil;
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("LoginData", inManagedObjectContext: LoginViewController.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "username", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: LoginViewController.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        loadLoginData();
        connectingIndicator.stopAnimating();
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        connectingIndicator.startAnimating();
        if identifier != "showSystemMonitor" {
            return false;
        }
        var testServer = hostNameField.text;
        if(testServer!.characters.indexOf(":") == nil) {
            testServer = testServer! + ":" + String(sysmonPort)
        }
        let testManager = ServerTestManager();
        dataSource = Datasource.Rest(testManager: testManager, testServer: hostNameField.text!);
        authenticator = BasicHttpAuthenticator(host: testServer!, user: usernameField.text!, password: passwordField.text!);
        dataSource?.setAuthenticator(authenticator!);
        
        connectingIndicator.stopAnimating();
        
        return validDataSource;
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        connectingIndicator.startAnimating();
        if segue.identifier == "showSystemMonitor" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! SystemViewController
            controller.setDatasource(self.dataSource!);
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = false
            
        }
        connectingIndicator.stopAnimating();
    }
    
    
    @IBAction func onLoginAttempt(sender: AnyObject) {
        self.validateCredentials();
    }
    
    func validateCredentials() {
        var testServer = hostNameField.text;
        if(testServer!.characters.indexOf(":") == nil) {
            testServer = testServer! + ":" + String(sysmonPort)
        }
        let testManager = ServerTestManager();
        dataSource = Datasource.Rest(testManager: testManager, testServer: hostNameField.text!);
        authenticator = BasicHttpAuthenticator(host: testServer!, user: usernameField.text!, password: passwordField.text!);
        dataSource?.setAuthenticator(authenticator!);
        
        self.authenticate(
            self.login,
            onError: {(errorMessage: String) -> Void in
                let alert = UIAlertController(title: "Error", message: errorMessage,  preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
        });
    }
    
    func login() {
        let systemMonitor = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("SystemMonitor") as! SystemViewController
        
        saveLoginData();
        saveDeviceToken();
        
        systemMonitor.setDatasource(self.dataSource!);
        systemMonitor.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        systemMonitor.navigationItem.leftItemsSupplementBackButton = false
        self.navigationController?.pushViewController(systemMonitor, animated:true)
    }
    
    func loadLoginData() {
        if(self.coreDataLoaded || LoginViewController.managedObjectContext == nil) {
            return;
        }
        self.coreDataLoaded = true;
        
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "LoginData")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do  {
            if let fetchResults = try LoginViewController.managedObjectContext!.executeFetchRequest(fetchRequest) as? [LoginData] {
                
                if(fetchResults.count > 0) {
                    let username = fetchResults[0].username;
                    let password = fetchResults[0].password;
                    let hostname = fetchResults[0].hostname;
                    let rememberMe = fetchResults[0].rememberMe;
                    let validateSSL = fetchResults[0].validateSSL;
                    
                    self.rememberMeSwitch.on = rememberMe;
                    if (rememberMe) {
                        self.usernameField.text = username;
                        self.passwordField.text = password;
                        self.hostNameField.text = hostname;
                        self.validateSSLSwitch.on = validateSSL;
                    }
                }
            }
            
        } catch  {
            
        }
    }
    
    func saveDeviceToken() {
        if(deviceToken != "" && deviceName != "" && self.dataSource != nil) {
            self.dataSource?.saveDeviceToken(deviceName, deviceToken: deviceToken);
        }
    }
    
    func saveLoginData() {
        
        let context = self.fetchedResultsController.managedObjectContext
        //let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName("LoginData", inManagedObjectContext: context)
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(self.rememberMeSwitch.on, forKey: "rememberMe")
        
        if(self.rememberMeSwitch.on) {
            newManagedObject.setValue(hostNameField.text, forKey: "hostname")
            newManagedObject.setValue(usernameField.text, forKey: "username")
            newManagedObject.setValue(passwordField.text, forKey: "password")
        }
        
        // Save the context
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            //abort()
            let alert = UIAlertController(title: "Error", message: "Unable to remember credentials",  preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func authenticate(onSuccess: () -> Void, onError: (errorMessage: String) -> Void)  {
        self.authenticator!.authenticate(
            {(session: NSURLSession) -> Void in
                self.validDataSource = true;
                onSuccess();
            },
            onError: {(message: String) -> Void in
                self.validDataSource = false;
                self.errorMessage = message;
                onError(errorMessage: message);
                
        });
    }
}

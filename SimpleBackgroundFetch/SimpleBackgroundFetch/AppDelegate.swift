//
//  AppDelegate.swift
//  SimpleBackgroundFetch
//
//  Created by Samrez Ikram on 31/10/2021.
//

import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    // Declared at the "Permitted background task scheduler identifiers" in info.plist
    let backgroundFetchTaskSchedulerIdentifier = "com.samrez.fetchBitcoinRate"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
        registerBackgroundTasks()
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    func registerBackgroundTasks() {
        // Use the identifier which represents your needs
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundFetchTaskSchedulerIdentifier, using: nil) { (task) in
           print("BackgroundAppRefreshTaskScheduler is executed NOW!")
           print("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
            
            self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
         }
    }
    
    func handleAppRefreshTask(task: BGAppRefreshTask) {
        print("handleAppRefreshTask")
        task.expirationHandler = {
        task.setTaskCompleted(success: false)
            NetworkManager.urlSession.invalidateAndCancel()
        }
        NetworkManager.getBitoinExchangeRate { (exchangeRates: BitcoinExchangeRate?) in
            
            if let newRates = exchangeRates {
                self.scheduleNotificationForExpectedRates(newRates: newRates)
            }
           
            task.setTaskCompleted(success: true)
        }
        scheduleBackgroundBitcoinExchnageResultsFetch()
    }
    
    func scheduleBackgroundBitcoinExchnageResultsFetch() {
      let bitcoinExchangeResultsFetchTask = BGAppRefreshTaskRequest(identifier: backgroundFetchTaskSchedulerIdentifier)
        bitcoinExchangeResultsFetchTask.earliestBeginDate = Date(timeIntervalSinceNow: 15)
      do {
        print("task scheduleding")
        try BGTaskScheduler.shared.submit(bitcoinExchangeResultsFetchTask)
        print("task scheduled")
      } catch {
        print("Unable to submit task: \(error.localizedDescription)")
      }
    }

    func scheduleNotificationForExpectedRates(newRates: BitcoinExchangeRate) {
        if(!SharedPrefs.shared.minimumDesiredRate.isEmpty &&
           !newRates.bpi.usd.rate.isEmpty &&
           SharedPrefs.shared.minimumDesiredRate.toDouble()! >= newRates.bpi.usd.rate.toDouble()! &&
           SharedPrefs.shared.maximumDesiredRate.toDouble()! <= newRates.bpi.usd.rate.toDouble()! ) {
            
            NotificationCenter.default.post(name: .latestExchangeRatesFetched,
                                        object: self,
                                            userInfo: ["ExchangeRates": newRates])
        }
 
    }
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


//
//  GameAPIClient.swift
//  MapQuiz
//
//  Created by Anna Rogers on 9/3/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation

class GameAPIClient {
    
    static let sharedInstance = GameAPIClient()
    private init() {}
    
    func postUserId (user_id:String, completionHandlerUserId: (data: AnyObject?, error: String?) -> Void) {
        let body:[String : AnyObject] = [
            "user_id" : user_id
        ]
        let request = makeRequest("http://localhost:5000/api/users", method: "POST", jsonBody: body)
        //send back user_secret to include in all future requests
        sendRequest(request) { (data, response, error) in
            if error == nil {
                print("no error", data)
                if data!.count == 2 {
                    if let dataReturned = data!["user_secret"]  {
                        completionHandlerUserId(data: dataReturned, error: nil)
                    } else {
                        completionHandlerUserId(data: nil, error: "The data returned did not contain the correct information")
                    }
                } else {
                    completionHandlerUserId(data: nil, error: "Wrong data returned")
                }
            } else {
                print("bad request", error)
                completionHandlerUserId(data: nil, error: error)
            }
        }
    }
    
    func postNewGame (game:[String:AnyObject], completionHandlerForGame: (data: AnyObject?, error: String?) -> Void) {
        let body:[String : AnyObject] = [
            "game" : game,
            "user_id": NSUserDefaults.standardUserDefaults().objectForKey("user_id")!,
            "user_secret": NSUserDefaults.standardUserDefaults().objectForKey("user_secret")!
        ]
        let request = makeRequest("http://localhost:5000/api/users/games", method: "POST", jsonBody: body)
        //send back rank and game id to add to models
        sendRequest(request) { (data, response, error) in
            if error == nil {
                if data!.count == 2  {
                    completionHandlerForGame(data: data, error: nil)
                }
            } else {
                completionHandlerForGame(data: nil, error: error)
            }
        }
    }
    
    func getLatestRanking (completionHandlerForRank: (data: AnyObject?, error: String?) -> Void) {
        let body = [
            "user_id": NSUserDefaults.standardUserDefaults().objectForKey("user_id")!,
            "user_secret": NSUserDefaults.standardUserDefaults().objectForKey("user_secret")!
        ]
        let request = makeRequest("http://localhost:5000/api/users/games", method: "PUT", jsonBody: body)
        //updated games returned - update core data
        sendRequest(request) { (data, response, error) in
            if error == nil {
                print("not error", data)
                //expect the game_ids and the updated ranks
                completionHandlerForRank(data: data, error: nil)
            } else {
                print("bad request", error)
                completionHandlerForRank(data: nil, error: "Count not get latest ranking")
            }
        }
    }
    
    func makeRequest (url: String, method: String, jsonBody: [String : AnyObject]) -> NSURLRequest  {
        //format the url
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        //format headers if there are any
        request.HTTPMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let serealisedBody: NSData?
        do {
            serealisedBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch {
            serealisedBody = nil
        }
        request.HTTPBody = serealisedBody
        return request
    }
    
    private func sendRequest (request: NSURLRequest, completionHandlerForRequest: (data: AnyObject?, response: NSHTTPURLResponse?, error: String?) -> Void) {
        
        //if Reachability.isConnectedToNetwork() == true {
            //print("Internet connection OK")
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
                if error != nil {
                    print("error", error)
                    completionHandlerForRequest(data: nil, response: nil, error: "There was an error in the request response")
                    return
                }
                let statusCode = (response as? NSHTTPURLResponse)?.statusCode
                print("Status code", statusCode)
                if statusCode >= 400 && statusCode <= 499 {
                    completionHandlerForRequest(data: nil, response: nil, error: "There was an error in the inforamtion sent to the server.")
                    return
                }
                if statusCode >= 500 && statusCode <= 599 {
                    completionHandlerForRequest(data: nil, response: nil, error: "This service is unavailable. Please try again later.")
                    return
                }
                guard let data = data else {
                    completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "No data returned from the API")
                    return
                }
                var parsedResult: AnyObject?
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                } catch {
                    completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "Could not parse the response to a readable format")
                    return
                }
                print("result",parsedResult)
                completionHandlerForRequest(data: parsedResult, response: (response as! NSHTTPURLResponse), error: nil)
            }
            task.resume()
//        }  else {
//            print("No internet connection")
//            completionHandlerForRequest(data: nil, response: nil, error: "There was no internet connection found")
//        }
        
    }
}
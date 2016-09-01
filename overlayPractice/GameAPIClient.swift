//
//  GameAPIClient.swift
//  MapQuiz
//
//  Created by Anna Rogers on 9/1/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation

class GameAPIClient {
    
    static let sharedInstance = GameAPIClient()
    private init() {}
    
    func postUserId (completionHandlerForQuote: (data: AnyObject?, error: String?) -> Void) {
        print("sending request")
        let request = NSMutableURLRequest(URL: NSURL(string: "/user/UUID")!)
        sendRequest(request) { (data, response, error) in
            if error == nil {
//                guard let data = data!["contents"]! else {
//                    completionHandlerForQuote(data: nil, error: "Not have content key on response")
//                    return
//                }
//                guard let quotes = data["quotes"] else {
//                    completionHandlerForQuote(data: nil, error: "Not have quotes key on response")
//                    return
//                }
//                guard let quoteObj = quotes![0] else {
//                    completionHandlerForQuote(data: nil, error: "No quote data")
//                    return
//                }
                //completionHandlerForQuote(data: quoteObj, error: nil)
            } else {
                print("bad request", error)
                completionHandlerForQuote(data: nil, error: "No user data")
            }
        }
    }
    
    func postNewGame (completionHandlerForQuote: (data: AnyObject?, error: String?) -> Void) {
        print("sending request")
        let request = NSMutableURLRequest(URL: NSURL(string: "/user/UUID/newGame")!)
        //where put saved second UUID? In the url??
        //in the body send the new game: match_length,wrong,attempts
        //in the response get back the rank and the gameID to store on the game model
        sendRequest(request) { (data, response, error) in
            if error == nil {
//                guard let data = data!["contents"]! else {
//                    completionHandlerForQuote(data: nil, error: "Not have content key on response")
//                    return
//                }
//                guard let quotes = data["quotes"] else {
//                    completionHandlerForQuote(data: nil, error: "Not have quotes key on response")
//                    return
//                }
//                guard let quoteObj = quotes![0] else {
//                    completionHandlerForQuote(data: nil, error: "No quote data")
//                    return
//                }
                //completionHandlerForQuote(data: quoteObj, error: nil)
            } else {
                print("bad request", error)
                completionHandlerForQuote(data: nil, error: "Game data not posted")
            }
        }
    }
    
    func getLatestRanking (completionHandlerForQuote: (data: AnyObject?, error: String?) -> Void) {
        print("sending request")
        let request = NSMutableURLRequest(URL: NSURL(string: "/user/UUID/newGame")!)
        //where put saved second UUID? In the url??
        //in the body send the new game: match_length,wrong,attempts
        //in the response get back the rank and the gameID to store on the game model
        sendRequest(request) { (data, response, error) in
            if error == nil {
//                guard let data = data!["contents"]! else {
//                    completionHandlerForQuote(data: nil, error: "Not have content key on response")
//                    return
//                }
//                guard let quotes = data["quotes"] else {
//                    completionHandlerForQuote(data: nil, error: "Not have quotes key on response")
//                    return
//                }
//                guard let quoteObj = quotes![0] else {
//                    completionHandlerForQuote(data: nil, error: "No quote data")
//                    return
//                }
                //completionHandlerForQuote(data: quoteObj, error: nil)
            } else {
                print("bad request", error)
                completionHandlerForQuote(data: nil, error: "Count not get latest ranking")
            }
        }
    }
    
    private func sendRequest (request: NSMutableURLRequest, completionHandlerForRequest: (data: AnyObject?, response: NSHTTPURLResponse?, error: String?) -> Void) {
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            if error != nil {
                completionHandlerForRequest(data: nil, response: nil, error: "There was an error in the request response")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "The status code returned was not OK")
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
            completionHandlerForRequest(data: parsedResult, response: (response as! NSHTTPURLResponse), error: nil)
        }
        task.resume()
    }
}
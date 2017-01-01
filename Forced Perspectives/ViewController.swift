//
//  ViewController.swift
//  Forced Perspectives
//
//  Created by Zulwiyoza Putra on 1/2/17.
//  Copyright © 2017 Zulwiyoza Putra. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var imageTitleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nextRandomImageButtonOutlet: UIButton!
    
    
    //Actions
    @IBAction func nextRandomImageButton(_ sender: Any) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    
    //Configure UI
    private func setUIEnabled(_ enabled: Bool) {
        imageTitleLabel.isEnabled = enabled
        nextRandomImageButtonOutlet.isEnabled = enabled
    }
    
    //Make network request
    private func getImageFromFlickr() {
        let methodParamters = Constants.methodParametersDictionary
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(parameters: methodParamters as [String : AnyObject])
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                }
            }
            //If no error
            if error == nil {
                //There was data returned
                if let data = data {
                    let parsedResult: [String:AnyObject]!
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    } catch {
                        displayError("Could not parse the data as JSON: '\(data)'")
                        return
                    }
                    if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] {
                        
                        let randomPhotoNumber = self.generateRandomNumber(upperBound: photoArray.count)
                        let photoDictionary = photoArray[randomPhotoNumber] as [String: AnyObject]
                        
                        if let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String, let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String {
                            let imageURL = URL(string: imageURLString)
                            if let imageData = try? Data(contentsOf: imageURL!) {
                                performUIUpdatesOnMain {
                                    self.imageTitleLabel.text = photoTitle
                                    self.backgroundImageView.image = UIImage(data: imageData)
                                    self.setUIEnabled(true)
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
        print("making network request to \(request) is done")
    }
    
    //Escaping paramters
    private func escapedParameters(parameters: [String: AnyObject]) -> String {
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            for (key, value) in parameters {
                let stringValue = "\(value)"
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
    //Helper Methods
    func generateRandomNumber(upperBound: Int) -> Int {
        let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: upperBound)
        return randomNumber
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

}


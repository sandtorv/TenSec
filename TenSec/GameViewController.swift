//
//  GameViewController.swift
//  TenSec
//
//  Created by Sebastian Sandtorv on 09/12/14.
//  Copyright (c) 2014 Sebastian Sandtorv. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

// What game type
var gameType:Int = 0
// Initialize var/int/etc for game handling
var gameActive:Int = 0
var gameOver:Int = 0
// Score
var scoreCount:Int = 0

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GKChallengeListener, GKLocalPlayerListener{
    // Init buttons
    @IBOutlet weak var startButton : UIButton?
    @IBOutlet weak var infiniteGame: UIButton?
    @IBOutlet weak var stopButton  : UIButton?
    @IBOutlet weak var gameCenter  : UIButton?
    @IBOutlet weak var highscoreLabel  : UILabel?
    @IBOutlet weak var totalClickLabel : UILabel?
    @IBOutlet weak var currentScore    : UILabel?
    @IBOutlet weak var startTextLabel  : UILabel?
    
    // Countdown variables
    var startTime = NSTimeInterval()
    var timer = NSTimer()
    var gameTime:Double = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateUser()
        
        self.updateScoreLabel()
        
        self.startButton?.hidden  = false
        self.stopButton?.hidden   = true
        self.currentScore?.hidden = true
        self.startTextLabel?.hidden = true
        
        // Determin screen size
        let screenSize: CGRect = UIScreen.mainScreen().bounds

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            // skView.showsFPS = true
            // skView.showsNodeCount = true
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }

    
    func gameCountdown(){
        let aSelector : Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }

    func updateTime() {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime = currentTime - startTime
        var seconds = gameTime-elapsedTime
        if seconds > 0 {
            elapsedTime -= NSTimeInterval(seconds)
            self.currentScore?.text = String("Time left: \(Int(seconds))")
            println("\(Int(seconds))")
            if(scoreCount > 0){
                self.startTextLabel?.hidden = true
            }
        } else {
            self.stopButton(self)
            timer.invalidate()
        }
    }
    
    func updateScoreLabel(){
        var highscore   =  NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        var totalClicks = NSUserDefaults.standardUserDefaults().integerForKey("totalScore")
        self.highscoreLabel?.text = ("Highscore is \(highscore) clicks")
        self.totalClickLabel?.text = ("Totally \(totalClicks) clicks")
    }
    
    // Hide game buttons
    func hideButtons(){
        self.startButton?.hidden  = true
        self.infiniteGame?.hidden = true
        self.stopButton?.hidden   = true
        self.gameCenter?.hidden   = true
        self.highscoreLabel?.hidden  = true
        self.totalClickLabel?.hidden = true
        self.currentScore?.hidden = false
        self.startTextLabel?.hidden = false
    }
    
    // Show game buttons
    func showButtons(){
        self.startButton?.hidden  = false
        self.infiniteGame?.hidden = false
        self.stopButton?.hidden   = true
        self.gameCenter?.hidden   = false
        self.highscoreLabel?.hidden  = false
        self.totalClickLabel?.hidden = false
        self.currentScore?.hidden    = true
        self.startTextLabel?.hidden  = true
    }
    
    @IBAction func startButton(sender: AnyObject) {
        println("startButton")
        gameOver = 0
        gameActive = 1
        scoreCount = 0
        self.hideButtons()
        self.gameCountdown()
    }
    
    @IBAction func infiniteGame(sender: AnyObject) {
        println("infiniteGame")
        gameOver = 0
        gameActive = 1
        scoreCount = 0
        self.hideButtons()
        self.stopButton?.hidden  = false
    }
    
    @IBAction func stopButton(sender: AnyObject) {
        println("stopButton")
        gameOver = 1
        gameActive = 0
        self.showButtons()
        self.updateScore()
    }
    
    // Opens the how to play alert
    @IBAction func helpButton(sender: AnyObject) {
        let alertController = UIAlertController(title: "How to play", message:
            "In normal mode you have 10 seconds to click as many times as possible. \n In infinite mode you can play for as long as you'd like, to increase the total clicks. \n Everything is connected to Game Center so you can compare your scores with the world! \n Close this box and get back to the game. ", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Game center functions
    func authenticateUser(){
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController!, error : NSError!) -> Void in
            if ((viewController) != nil) {
                self.presentViewController(viewController, animated: true, completion: nil)
            }else{
                println("PLayer authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
            }
        }
    }
    
    @IBAction func showGameCenter(sender: AnyObject){
        var gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        self.presentViewController(gcViewController, animated: true, completion: nil)
    }
    
    func updateScore(){
        self.updateTotalScore()
        var score = scoreCount
        
        if score > NSUserDefaults.standardUserDefaults().integerForKey("highscore") {
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highscore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        if GKLocalPlayer.localPlayer().authenticated {
            let gkScore = GKScore(leaderboardIdentifier: "no.protodesign.TenSec_Single_Score")
            gkScore.value = Int64(NSUserDefaults.standardUserDefaults().integerForKey("highscore"))
            GKScore.reportScores([gkScore], withCompletionHandler: ( { (error: NSError!) -> Void in
                if (error != nil) {
                    // handle error
                    println("Error: " + error.localizedDescription);
                } else {
                    println("highscore reported: \(gkScore.value)")
                }
            }))
        }

    }
    
    func updateTotalScore(){
        var score = scoreCount + NSUserDefaults.standardUserDefaults().integerForKey("totalScore")
        println("Score is \(score)")
        if score > NSUserDefaults.standardUserDefaults().integerForKey("totalScore") {
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "totalScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        if GKLocalPlayer.localPlayer().authenticated {
            let gkScore = GKScore(leaderboardIdentifier: "no.protodesign.TenSec_Total_Score")
            gkScore.value = Int64(NSUserDefaults.standardUserDefaults().integerForKey("totalScore"))
            GKScore.reportScores([gkScore], withCompletionHandler: ( { (error: NSError!) -> Void in
                if (error != nil) {
                    // handle error
                    println("Error: " + error.localizedDescription);
                } else {
                    println("totalScore reported: \(gkScore.value)")
                }
            }))
        }
        self.updateScoreLabel()

    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    // End of Game center functions
    
    // Apple standard functions
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

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

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GKChallengeListener, GKLocalPlayerListener{
    // Init buttons
    @IBOutlet weak var startButton : UIButton!
    @IBOutlet weak var infiniteGame: UIButton!
    @IBOutlet weak var stopButton  : UIButton!
    @IBOutlet weak var gameCenter  : UIButton!
    @IBOutlet weak var colorSchemeButton: UIButton!
    @IBOutlet weak var highscoreLabel  : UILabel!
    @IBOutlet weak var currentScore    : UILabel!
    @IBOutlet weak var startTextLabel  : UILabel!
    @IBOutlet weak var userText: UILabel!
    
    // Countdown variables
    var startTime = NSTimeInterval()
    var timer = NSTimer()
    var gameTime:Double = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateUser()
        
        self.updateScoreLabel()
        
        gameCenter.setImage(UIImage(named: "LeaderboardDeactivated"), forState: .Disabled)
        
        self.startButton?.hidden  = false
        self.stopButton?.hidden   = true
        self.currentScore?.hidden = true
        self.startTextLabel?.hidden = true
        
        // Determin screen size
        let screenSize: CGRect = UIScreen.mainScreen().bounds

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            let skView = self.view as! SKView
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
        }
    }

    override func viewDidAppear(animated: Bool) {
        textColor()
        if(GKLocalPlayer.localPlayer().authenticated){
            userText.text = "Welcome \(GKLocalPlayer.localPlayer().alias)"
            gameCenter.enabled = false
        } else {
            userText.text = "Welcome to \(UIDevice.currentDevice().name)\n log in to GameCenter to compare your scores"
            gameCenter.enabled = false
        }
    }
    
    func gameCountdown(){
        let aSelector : Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        self.currentScore.text = "10"
    }

    func updateTime() {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime = currentTime - startTime
        var seconds = gameTime-elapsedTime
        if seconds > 0 {
            elapsedTime -= NSTimeInterval(seconds)
            self.currentScore.text = "\(Int(ceil(seconds)))"
            println("\(Int(seconds))")
            if(scoreCountSingle > 0){
                self.startTextLabel.hidden = true
            }
        } else {
            self.stopButton(self)
            timer.invalidate()
        }
    }
    
    func updateScoreLabel(){
        var highscore   =  NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        var totalClicks = NSUserDefaults.standardUserDefaults().integerForKey("totalScore")
        if(totalClicks > 0 && highscore > 0){
             self.highscoreLabel?.text = ("Max \(highscore) , \(totalClicks) total clicks")
        } else{
            self.highscoreLabel?.text = "No highscore reported yet"
        }
    }
    
    // Hide game buttons
    func hideButtons(){
        startButton.hidden  = true
        infiniteGame.hidden = true
        stopButton.hidden   = true
        gameCenter.hidden   = true
        colorSchemeButton.hidden = true
        highscoreLabel.hidden  = true
        userText.hidden = true
        currentScore.hidden = false
        startTextLabel.hidden = false
        stopButton.hidden  = false
    }
    
    // Show game buttons
    func showButtons(){
        startButton.hidden  = false
        infiniteGame.hidden = false
        stopButton.hidden   = true
        gameCenter.hidden   = false
        colorSchemeButton.hidden = false
        highscoreLabel.hidden  = false
        userText.hidden = false
        currentScore.hidden    = true
        startTextLabel.hidden  = true
    }
    
    @IBAction func startButton(sender: AnyObject) {
        println("startButton")
        gameType = 0
        oldGameScore = 0
        gameOver = 0
        gameActive = 1
        scoreCountSingle = 0
        hideButtons()
        gameCountdown()
    }
    
    @IBAction func infiniteGame(sender: AnyObject) {
        println("infiniteGame")
        gameType = 1
        gameOver = 0
        gameActive = 1
        scoreCountInfinite = NSUserDefaults.standardUserDefaults().integerForKey("totalScore")
        oldGameScore = NSUserDefaults.standardUserDefaults().integerForKey("totalScore")
        self.hideButtons()
        self.currentScore?.hidden = true
    }
    
    @IBAction func stopButton(sender: AnyObject) {
        println("stopButton")
        gameOver = 1
        gameActive = 0
        self.showButtons()
        self.updateScore()
    }
    
    // Game center functions
    func authenticateUser(){
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController!, error : NSError!) -> Void in
            if ((viewController) != nil) {
                self.presentViewController(viewController, animated: true, completion: nil)
            }else{
                println("Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
            }
        }
    }
    
    @IBAction func showGameCenter(sender: AnyObject){
        var gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        self.presentViewController(gcViewController, animated: true, completion: nil)
    }
    
    @IBAction func changeTextColor(){
        if(changeColorTheme()){
            textColor()
        }
    }
    
    func textColor(){
        colorThemeLight = NSUserDefaults.standardUserDefaults().boolForKey("colorThemeLight")
        if(colorThemeLight){
            colorForText = lightColor
            viewBGColor = darkColor
            colorSchemeButtonImg = UIImage(named: "LightButton")!
        } else{
            colorForText = darkColor
            viewBGColor = lightColor
            colorSchemeButtonImg = UIImage(named: "DarkButton")!
        }
        UIView.animateWithDuration(0.1, animations: {
            self.view.backgroundColor = viewBGColor
            self.colorSchemeButton.setImage(colorSchemeButtonImg, forState: .Normal)
            self.highscoreLabel.textColor = colorForText
            self.currentScore.textColor = colorForText
            self.startTextLabel.textColor = colorForText
            self.userText.textColor = colorForText
        })
    }
    
    func updateScore(){
        self.updateTotalScore()
        var score:Int = scoreCountSingle
        
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
        var score = scoreCountInfinite
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

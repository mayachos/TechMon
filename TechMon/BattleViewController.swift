//
//  BattleViewController.swift
//  TechMon
//
//  Created by maya on 2020/05/15.
//  Copyright © 2020 maya. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerMPLabel: UILabel!
    @IBOutlet var playerTPLabel: UILabel!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPLabel: UILabel!
    @IBOutlet var enemyMPLabel: UILabel!
    
    let techMonManager = TechMonManager.shared //音楽再生などで便利なクラス
    
    //Characterクラスのステータス
    var player: Character!
    var enemy: Character!
    var gameTimer: Timer! //ゲーム用タイマー
    var isPlayerAttackAvailable: Bool = true //プレイヤーが攻撃できるか

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //キャラクターの読み込み
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        //プレイヤー
        playerNameLabel.text = player.name
        playerImageView.image = player.image
        //敵
        enemyNameLabel.text = enemy.name
        enemyImageView.image = enemy.image
        //初期化
        techMonManager.resetStatus()
        //ステータス表示メソッドを呼び出し
        updateUI()
        
        //ゲームスタート
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                         selector: #selector(updateGame), userInfo: nil, repeats: true)
        gameTimer.fire()

        // Do any additional setup after loading the view.
    }
    //バトル画面表示時に呼び出し
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    
    //バトル画面消去時に呼び出し
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
    
    //ステータス表示メソッド
    func updateUI () {
        //プレイヤーのステータスを反映
        playerHPLabel.text = String(player.currentHP) + " / \(player.maxHP)"
        playerMPLabel.text = String(player.currentMP) + " / \(player.maxMP)"
        playerTPLabel.text = String(player.currentTP) + " / \(player.maxTP)"
        //敵のステータスを反映
        enemyHPLabel.text = String(enemy.currentHP) + " / \(enemy.maxHP)"
        enemyMPLabel.text = String(enemy.currentMP) + " / \(enemy.maxMP)"
    }
    
    //0.1秒毎にゲーム状態を更新
    @objc func updateGame() {
        
        //プレイヤーのステータスを更新
        player.currentMP += 1
        if player.currentMP >= player.maxMP {
            isPlayerAttackAvailable = true //攻撃可能
            player.currentMP = 20 //MPは20を超えない
        } else {
            isPlayerAttackAvailable = false //攻撃不可
        }
        
        //敵のステータスを更新
        enemy.currentMP += 1
        if enemy.currentMP >= 35 {
            // MPが35になったら自動攻撃
            enemyAttack()
            enemy.currentMP = 0
        }
        updateUI()
    }
    
    //勝利判定
    func judgeBattle() {
        
        if player.currentHP <= 0 {
            
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        } else if enemy.currentHP <= 0 {
            
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
    //敵の攻撃
    func enemyAttack() {
        
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= 20
        updateUI()
        judgeBattle()
    }
    
    //勝敗が決定した時の処理
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool) {
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        var finishMessage: String = ""
        if isPlayerWin {
            
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！"
        } else {
            
            techMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北..."
        }
        
        let alert = UIAlertController(title: "バトル終了", message: finishMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //プレイヤーの攻撃
    @IBAction func attackAction() {
        
        if isPlayerAttackAvailable {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
            let number = Int.random(in: 0..<3)
            if number == 2 {
                enemy.currentHP -= player.attackPoint * 2
            } else {
                enemy.currentHP -= player.attackPoint
            }
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP {
                
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
            updateUI()
            judgeBattle()
        }
    }
    
    @IBAction func tameruAction() {
        
        if isPlayerAttackAvailable {
            
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP {
                
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
        }
    }
    
    @IBAction func fireAction() {
        
        if isPlayerAttackAvailable && player.currentTP >= 40 {
            
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            let number = Int.random(in: 0..<3)
            if number == 2 {
                enemy.currentHP -= 200
            } else {
                enemy.currentHP -= 100
            }
            player.currentTP -= 40
            if player.currentTP <= 0 {
                
                player.currentTP = 0
            }
            player.currentMP = 0
            updateUI()
            judgeBattle()
        }
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

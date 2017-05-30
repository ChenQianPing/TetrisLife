//
//  GameViewController.swift
//  TetrisLife
//
//  Created by ChenQianPing on 16/7/5.
//  Copyright (c) 2016年 ChenQianPing. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    var swiftris:Swiftris!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    // #21
    var panPointReference:CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // #1
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.delegate = self
        swiftris.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
        
        // #2
//        scene.addPreviewShapeToScene(swiftris.nextShape!) {
//            self.swiftris.nextShape?.moveTo(StartingColumn, row: StartingRow)
//            self.scene.movePreviewShape(self.swiftris.nextShape!) {
//                let nextShapes = self.swiftris.newShape()
//                self.scene.startTicking()
//                self.scene.addPreviewShapeToScene(nextShapes.nextShape!) {}
//            }
//        }
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    
    // 移动手势
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        // #22
        let currentPoint = sender.translation(in: self.view)
        if let originalPoint = panPointReference {
            // #23
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                // #24
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .began {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        swiftris.dropShape()
    }
    
    // #31
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // #32
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    
    // #3
    func didTick() {
        swiftris.letShapeFall()
//        swiftris.fallingShape?.lowerShapeByOneRow()
//        scene.redrawShape(swiftris.fallingShape!, completion: {})
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
        self.scene.movePreviewShape(fallingShape) {
            // #16
            self.view.isUserInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(_ swiftris: Swiftris) {
        
        // 我们把分数和关卡和我们的界面关联起来
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(_ swiftris: Swiftris) {
        view.isUserInteractionEnabled = false
        scene.stopTicking()
        
        // 程序结束的时候,播放结束的声音,然后开始新的游戏.
        // 当然,我们也可以做更多的功能,比如添加一个按钮,点击以后才会重新开始.
        scene.playSound("Sounds/gameover.mp3")
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: swiftris.removeAllBlocks()) {
            swiftris.beginGame()
        }
    }
    
    func gameDidLevelUp(_ swiftris: Swiftris) {
        levelLabel.text = "\(swiftris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("Sounds/levelup.mp3")
    }
    
    // 这部分是游戏level提升以后,下落的间隔也会变短,游戏难度越来越大
    func gameShapeDidDrop(_ swiftris: Swiftris) {
        // #33
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        
        scene.playSound("Sounds/drop.mp3")
    }
    
    func gameShapeDidLand(_ swiftris: Swiftris) {
        scene.stopTicking()
//        nextShape()
        
        self.view.isUserInteractionEnabled = false
        // #41
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // #42
                self.gameShapeDidLand(swiftris)
            }
            scene.playSound("Sounds/bomb.mp3")
        } else {
            nextShape()
        }
        
    }
    
    // #17
    func gameShapeDidMove(_ swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }
}

/*
 *  #1 我们给我们的tick 闭包设置了一个函数,
 * 看,之前我们不能理解的()->() 到这里也能明白了,
 * 每当屏幕刷新一下时,我们就执行didTick函数,我们把fallingShape往下移动一行,然后在scene上重新画出来它的形状.
 
 * 好了,让我们运行下程序,看一看我们的俄罗斯方块下落的动态吧.
 
 * #21 我们定义个panPointReference点来追踪pan手势的位置。
 * #22 我们把起始点位置记录下来,然后在#23中计算当前的位置有没有和起始点相差绝对值（abs）超过0.9个block,
 * 如果超过了,就执行移动命令
 * #24 可以通过velocityInView来判断手势的方向,正值是向右,负值是向左,
 * 然后我们把swiftris向对应的方向移动一格.并且把当前的位置设置成开始的位置,这样确保用户一次可以移动好几格.
 * 但是我在后来玩游戏的过程中发现,很容易移动超过自己想象的位置,
 * 而且如果在后面的swipe动作中很容易出发pan,因为0.9个blocksize其实是很小的位置.
 * 不过这都不是问题,我们知道了原理,怎样调整就随意了！
 
 * #31 部分允许我们的手势同时执行,当然,有些时候我们的手势可能会冲突,所以需要在做些调整
 * 注意到在#32中 如果当前手势是swipe而panRec 手势是otherGestureRecognizer时,
 * 在我的代码里面需要return false,因为我刚开始发现如果是return ture,那么swipe手势一直没法识别,
 * 因为它被pan覆盖掉了.而改成false后就正常了.这里算是原版教材俩面的第2处错误。
 * 大家也可以试试是不是这样的
 */

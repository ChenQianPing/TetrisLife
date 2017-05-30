//
//  GameScene.swift
//  TetrisLife
//
//  Created by ChenQianPing on 16/7/5.
//  Copyright (c) 2016年 ChenQianPing. All rights reserved.
//

import SpriteKit

// #7
let BlockSize:CGFloat = 20.0

// #1
let TickLengthLevelOne = TimeInterval(600)

class GameScene: SKScene {
    
    // #8
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x: 6, y: -6)
    
    // #2
    var tick:(() -> ())?
    var tickLengthMillis = TickLengthLevelOne
    var lastTick:Date?
    
    var textureCache = Dictionary<String, SKTexture>()

    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // #0
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)
        
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSize(width: BlockSize * CGFloat(NumColumns), height: BlockSize * CGFloat(NumRows)))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        // Sound Is Good
        // #8
        run(SKAction.repeatForever(SKAction.playSoundFileNamed("Sounds/do-re-mi.mp3", waitForCompletion: true)))
    }
    
    // #9
    func playSound(_ sound:String) {
        
        // Don't know why the function "playSound" couldn't be recognized without this playTheSound function
        run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // #3
        guard let lastTick = lastTick else {
            return
        }
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis {
            self.lastTick = Date()
            tick?()
        }
    }
    
    // #4
    func startTicking() {
        lastTick = Date()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    // #9
    func pointForColumn(_ column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPoint(x: x, y: y)
    }
    
    func addPreviewShapeToScene(_ shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            // #10
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture)
            // #11
            sprite.position = pointForColumn(block.column, row:block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            // #12
            let moveAction = SKAction.move(to: pointForColumn(block.column, row: block.row), duration: TimeInterval(0.2))
            moveAction.timingMode = .easeOut
            let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.4)
            fadeInAction.timingMode = .easeOut
            sprite.run(SKAction.group([moveAction, fadeInAction]))
        }
        run(SKAction.wait(forDuration: 0.4), completion: completion)
    }
    
    func movePreviewShape(_ shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.2)
            moveToAction.timingMode = .easeOut
            sprite.run(
                SKAction.group([moveToAction, SKAction.fadeAlpha(to: 1.0, duration: 0.2)]), completion: {})
        }
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    func redrawShape(_ shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.05)
            moveToAction.timingMode = .easeOut
            if block == shape.blocks.last {
                sprite.run(moveToAction, completion: completion)
            } else {
                sprite.run(moveToAction)
            }
        }
    }
    
    // 接下来我们就开始写代码了,让我们给消除做个动画吧.
    // #1
    func animateCollapsingLines(_ linesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion:@escaping () -> ()) {
        var longestDuration: TimeInterval = 0
        // #2
        for (columnIdx, column) in fallenBlocks.enumerated() {
            for (blockIdx, block) in column.enumerated() {
                let newPosition = pointForColumn(block.column, row: block.row)
                let sprite = block.sprite!
                // #3
                let delay = (TimeInterval(columnIdx) * 0.05) + (TimeInterval(blockIdx) * 0.05)
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        moveAction]))
                longestDuration = max(longestDuration, duration + delay)
            }
        }
        
        for rowToRemove in linesToRemove {
            for block in rowToRemove {
                // #4
                let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
                let goLeft = arc4random_uniform(100) % 2 == 0
                
                var point = pointForColumn(block.column, row: block.row)
                point = CGPoint(x: point.x + (goLeft ? -randomRadius : randomRadius), y: point.y)
                
                let randomDuration = TimeInterval(arc4random_uniform(2)) + 0.5
                // #5
                var startAngle = CGFloat(M_PI)
                var endAngle = startAngle * 2
                if goLeft {
                    endAngle = startAngle
                    startAngle = 0
                }
                let archPath = UIBezierPath(arcCenter: point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
                let archAction = SKAction.follow(archPath.cgPath, asOffset: false, orientToPath: true, duration: randomDuration)
                archAction.timingMode = .easeIn
                let sprite = block.sprite!
                // #6
                sprite.zPosition = 100
                sprite.run(
                    SKAction.sequence(
                        [SKAction.group([archAction, SKAction.fadeOut(withDuration: TimeInterval(randomDuration))]),
                            SKAction.removeFromParent()]))
            }
        }
        // #7
        run(SKAction.wait(forDuration: longestDuration), completion:completion)
    }
    
}


/* #0 坐标系
 * SpriteKit是基于OpenGL的,因此它的坐标系统也是iOS原生的cocoa 坐标系,0,0
 * 在SpriteKit中就是左下角.Swiftris将从上往下,
 * 所以,我们的anchor point将从左上角开始,也就是(0,1.0).
 * 这里可以看到,其实这个是个百分比,坐标的范围是从0到1的,而（0.5,0.5）就是屏幕的中间
 
 * #1 滴答作响的时钟机制,A Ticking Clock
 * 首先我们定义了一个常量,TickLengthlevelOne,这个常量将会用来显示我们最慢的游戏速度,
 * 因为每一幅图片之间的间隔越长,它就看起来越慢,对吧?
 * 我们先把它设置成600毫秒,也就是说每隔0.6秒,我们的形状将会往下掉落一行.
 
 * #2
 * 我们定义了一些新的变量。
 * tickLengthMillis和lastTick很简单,我们之前已经遇到过这样的定义方式。
 * 第一个被赋予之前我们已经定义过的常量TickLenghtLevelOne;
 * 第二个用来表示我们最后一次记录的时间，一个NSDate类型的实例。
 * 但是,你知道tick:(()->())? 是个什么么？它看起来确实非常诡异的.
 * tick其实是一个在Swift被叫做闭包（closure）的东西,如果你熟悉object-c,那么闭包就是那里面的块（block）.
 * 之前我们已经接触过函数的定义方式,知道了 -> 这个符号的意思,那在tick里面，(()->())？ 表示这个闭包不需要参数,也不返回任何东西。
 * 因为它是optional的，所以它当然有可能是nil。
 * 刚开始学的时候,我对这个()->()百思不得其解,它不需要任何参数,它又返回了noting,那它是干嘛的？
 * 后来没憋住上Stackoverflow上问了有位大神的回复让我总算明白了它的含义。
 
 * 是的,在这里,到目前为止,我们这个tick,指向函数的你叫它变量也好,叫它指针也罢,我们叫它closure;
 * 目前为止,这个closure没有什么意义,它就是一个占位的,告诉你这里是有个东西的,
 * 当然,到项目的中期,我们的tick 闭包就会派上用处了.
 * 所以大家不要急,你可以认为这里的closure就是个占位符,好比我先把楼给占了,
 * 等我想好说什么了我在说,而且这次觉得说的不好,我还可以换,就这么nb.
 
 * #3
 * 让我们接着往下看,我们将会引入一个新的变量.
 * 如果lastTick是nil,那么我们当前处于一个暂停状态,所以我们直接return就好了,不需要做任何动作;
 * 但是如果不是,说明目前游戏是在进行中的,我们得做点什么东西.
 * timePassed这个变量从它的名字上就能看出来是表示过去了多久的一个变量,过去多久,和啥时候作为参照呢？
 * 把lastTick和now作为比较,因为lastTick记录的是最后一次记录的时间点,那它相对现在肯定是倒退的,
 * 所以,timeIntervalSinceNow这个函数可以返回和当前的时间比相差多少。
 * 因为是过去的时间点,所有这个值肯定是负数,而且单位是毫秒,所以我们需要* -1000 把它变成一个正的而且单位是秒的数,
 * 因为我们的tickLengthMillis可是0.6秒。
 
 * 也就是说 如果现在的时间和最后一次记录的时间间隔超过了0.6秒,我们就执行接下来的动作:
 * 记录下当前的时间,然后tick一下;
 * 在现在这个阶段,因为tick是个真正空的东西,所以不会发生什么,但是你要知道,它是可以发生点什么的,只要我们赋予tick某个函数就行了。
 * 因为我们用到了lastTick.timeIntervalSinceNow,所以感兴趣的东西学深入学习一下swift的dot语法
 
 * #4
 * 这里的两个函数都比较简单,调用start,因为lastTick不在是nil,scene将开始刷新屏幕;
 * 调用stop后 update函数将一直返回,所以就不在刷新屏幕
 
 
 * #7,我们定义了每个block的大小,20x20
 * #8,我们定义了一些SKNodes,最下面的是gameLayer,它上一层是shapeLayer,然后是gameBoard
 * #9,不要小看这个函数,这其实是我们整个GameScene中最重要的函数,pointForColumn(int,int) .
 * 他根据column和row来计算每一个block的锚点位置,所以返回的是一个point坐标,
 * 只有根据这个坐标,我们才能把每个block放置在shapeLayer上.其实它计算的就是每个block的中心点的坐标.
 
 * #10 我们把新生成的nextShape添加到屏幕中去,注意函数其中的一个参数用的是一个空的闭包,
 * 因为函数最后有个添加动作的函数runAction,它里面有个参数 completion,这里我们用个()->() 闭包还是个占位的,
 * 如果有我们就用,没有就空着.和最开始我们接触到的那个tick闭包一样,
 * 不过,很快我们就能看到tick不在是一个空的闭包了.这个我们后面会讲到.
 * 这里我们把SKTexture对象存在一个字典里面,因为每一个shape会有很多block,而我们是要重复利用这些image的.
 
 * #11 这里我们用到了之前定义的pointForColumn函数精确地每一个block添加到准确的位置,
 * 我们是从row-2开始的,这样可以显得我们的动画更加平滑地进入画面中
 
 * #12我们添加了一组动画,我们让每个block的alpha从0变化到0.7,
 * 因为这样更容易让用户有一种动画的感觉.关于里面各个参数,以及时间的长短,大家可以自己手动改变一下,然后看看效果上有什么变化.
 * 接下来的两个函数确保同样的SKAction移动和重画不同shape的每一个block
 
 * 消除动作本身并不复杂,复杂的是我们要计算一个角度给每个block

 
 */


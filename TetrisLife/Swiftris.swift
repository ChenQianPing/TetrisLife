//
//  Swiftris.swift
//  TetrisLife
//
//  Created by ChenQianPing on 16/7/6.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

// #1
let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

let PointsPerLine = 10
let LevelThreshold = 500

protocol SwiftrisDelegate {
    // Invoked when the current round of Swiftris ends
    func gameDidEnd(_ swiftris: Swiftris)
    
    // Invoked after a new game has begun
    func gameDidBegin(_ swiftris: Swiftris)
    
    // Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(_ swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location
    func gameShapeDidMove(_ swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(_ swiftris: Swiftris)
    
    // Invoked when the game has reached a new level
    func gameDidLevelUp(_ swiftris: Swiftris)
}

class Swiftris {
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:SwiftrisDelegate?
    
    var score = 0
    var level = 1
    
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(self)
    }
    
    // #2
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(StartingColumn, row: StartingRow)
        
        // #3
        guard detectIllegalPlacement() == false else {
            nextShape = fallingShape
            nextShape!.moveTo(PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
        }
        
        return (fallingShape, nextShape)
    }
    
    // #4
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for block in shape.blocks {
            if block.column < 0 || block.column >= NumColumns
                || block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        return false
    }
    
    // #5
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidDrop(self)
    }
    
    // #6
    func letShapeFall() {
        guard let shape = fallingShape else {
            return
        }
        shape.lowerShapeByOneRow()
        if detectIllegalPlacement() {
            shape.raiseShapeByOneRow()
            if detectIllegalPlacement() {
                endGame()
            } else {
                settleShape()
            }
        } else {
            delegate?.gameShapeDidMove(self)
            if detectTouch() {
                settleShape()
            }
        }
    }
    
    // #7
    func rotateShape() {
        guard let shape = fallingShape else {
            return
        }
        shape.rotateClockwise()
        guard detectIllegalPlacement() == false else {
            shape.rotateCounterClockwise()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    // #8
    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftLeftByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftRightByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftLeftByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    // #9
    func settleShape() {
        guard let shape = fallingShape else {
            return
        }
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        fallingShape = nil
        delegate?.gameShapeDidLand(self)
    }
    
    // #10
    func detectTouch() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for bottomBlock in shape.bottomBlocks {
            if bottomBlock.row == NumRows - 1
                || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                return true
            }
        }
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameDidEnd(self)
    }
    
    // #11
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        for row in (1..<NumRows).reversed() {
            var rowOfBlocks = Array<Block>()
            // #12
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
            }
            if rowOfBlocks.count == NumColumns {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        // #13
        if removedLines.count == 0 {
            return ([], [])
        }
        // #14
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
        if score >= level * LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        for column in 0..<NumColumns {
            var fallenBlocksArray = Array<Block>()
            // #15
            for row in (1..<removedLines[0][0].row).reversed() {
                guard let block = blockArray[column, row] else {
                    continue
                }
                var newRow = row
                while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                    newRow += 1
                }
                block.row = newRow
                blockArray[column, row] = nil
                blockArray[column, newRow] = block
                fallenBlocksArray.append(block)
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    // 允许用户一次性将所有的block都移除出去
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
    
}

/* 目前看来,我们的swiftris类挺简单的,放心,一会它会变得复杂起来.
 * 我们注意到在swiftris里面我们声明了3个变量,
 * 一个是用来表示每个block位置的二维数组blockArray,
 * 一个是nextShape,
 * 最后是fallingShape,
 * 我们可以很容易从名字上得出nextShape就是我们用来预览下一个是什么形状的,玩过俄罗斯方块的童鞋都想起来了吧,
 * 而相对应的,fallingShape就是游戏中我们正在操作的shape,我们可以旋转,移动等等来操作它。
 * 接下来init函数我们生成一个20行,10列的二维数组,用来表示blocks的位置。
 * beginGame中我们随机生成一个shape,用我们shape类中最后写的那个函数,然后把它放在我们制定的位置中。
 
 * 在#2 中,我们有一个函数,返回的值是fallingshape和nextshape,当然fallingshape就是我们之前已经生成的nextshape了,
 * 我们用在shape类中新建的movtTo函数把他一到我们的游戏区域的中间,然后生成一个新的nextshape.逻辑上没有问题吧.
 * OK,逻辑关系处理好了,接下来轮到我们处理视觉上的效果了.终于可以在scene上大展手脚了!
 *
 
 * 游戏规则
 * 每个游戏都有它自己的规则,我们的俄罗斯方块的规则很明显,shape落到最底端时就停止下落,
 * 然后下一个shape开始往下落;当任一一个点挡住下落的shape时,整个shape就认为是已经到底了;
 * 当一行充满所有blocks时,这行消除,然后所有的往下落一行等等等等。
 
 * #5 dropshape函数中,我们每次将shape往下移动一行,如果它没有处于非法的位置,
 * 就循环执行下去,知道它处于非法的位置,因为它已经处于非法的位置了,所以我们需要把它复原到最后一个合法的位置,
 * 所以我们需要把它往上移动一行.
 * #6 我们定义了每次tick都会被调用的函数,不用担心没有见到的settle函数,我们稍后会来完善它
 * #7 我们可以让我们的shape在下落的过程中旋转
 
 * #9中的settleShape函数会在shape无法再往下落的时候调用,
 * 我们把当前shape中的所有block都写入到blockArray里面,然后告诉程序,
 * 这个shape已经成功着陆了,不管它是真的着陆还是降落在别的shape头上
 
 * #10中的函数正是完成这样的检测;
 * 同时fallingshape设置成nil,这样swiftris就会开始新的fallingshape.
 * 得分机制
 * 我们应该还记得,玩游戏大部分都有得分的,让我们来完善得分机制吧:

 * 我们需要一组变量score和level来表示得分和关卡数
 * 当我们移除掉一整行的时候,我们就得分了,整个游戏就是依靠这样来得分的,对吧.
 
 * #11 这是一段很长很长的代码,但是里面应该没有什么特别难以理解的内容,整个逻辑看起来也很清楚.
 * 返回两个数组,linesRemoved和fallenBlocks

 */

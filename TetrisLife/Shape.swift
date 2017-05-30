//
//  Shape.swift
//  TetrisLife
//
//  Created by ChenQianPing on 16/7/6.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

import SpriteKit

let NumOrientations: UInt32 = 4

enum Orientation: Int, CustomStringConvertible {
    case zero = 0, ninety, oneEighty, twoSeventy
    
    var description: String {
        switch self {
        case .zero:
            return "0"
        case .ninety:
            return "90"
        case .oneEighty:
            return "180"
        case .twoSeventy:
            return "270"
        }
    }
    
    static func random() -> Orientation {
        return Orientation(rawValue:Int(arc4random_uniform(NumOrientations)))!
    }
    
    // #0
    static func rotate(_ orientation:Orientation, clockwise: Bool) -> Orientation {
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        if rotated > Orientation.twoSeventy.rawValue {
            rotated = Orientation.zero.rawValue
        } else if rotated < 0 {
            rotated = Orientation.twoSeventy.rawValue
        }
        return Orientation(rawValue:rotated)!
    }
    
}

// The number of total shape varieties
let NumShapeTypes: UInt32 = 7

// Shape indexes
let FirstBlockIdx: Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx: Int = 2
let FourthBlockIdx: Int = 3

class Shape: Hashable, CustomStringConvertible {
    // The color of the shape
    let color:BlockColor
    
    // The blocks comprising the shape
    var blocks = Array<Block>()
    // The current orientation of the shape
    var orientation: Orientation
    // The column and row representing the shape's anchor point
    var column, row:Int
    
    // Required Overrides
    // #1
    // Subclasses must override this property
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [:]
    }
    
    // #2
    // Subclasses must override this property
    var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [:]
    }
    
    // #3
    var bottomBlocks:Array<Block> {
        guard let bottomBlocks = bottomBlocksForOrientations[orientation] else {
            return []
        }
        return bottomBlocks
    }
    
    // Hashable
    var hashValue:Int {
        // #4
        return blocks.reduce(0) { $0.hashValue ^ $1.hashValue }
    }
    
    // CustomStringConvertible
    var description:String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column:Int, row:Int, color: BlockColor, orientation:Orientation) {
        self.color = color
        self.column = column
        self.row = row
        self.orientation = orientation
        initializeBlocks()
    }
    
    // #5
    convenience init(column:Int, row:Int) {
        self.init(column:column, row:row, color:BlockColor.random(), orientation:Orientation.random())
    }
    
    // #6
    final func initializeBlocks() {
        // #7
        guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else {
            return
        }
        blocks = blockRowColumnTranslations.map { (diff) -> Block in
            return Block(column: column + diff.columnDiff, row: row + diff.rowDiff, color: color)
        }
    }
    
    final func rotateBlocks(_ orientation: Orientation) {
        guard let blockRowColumnTranslation:Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] else {
            return
        }
        
        // #1
        for (idx, diff) in blockRowColumnTranslation.enumerated() {
            blocks[idx].column = column + diff.columnDiff
            blocks[idx].row = row + diff.rowDiff
        }
    }
    
    // #8
    final func rotateClockwise() {
        let newOrientation = Orientation.rotate(orientation, clockwise: true)
        rotateBlocks(newOrientation)
        orientation = newOrientation
    }
    
    final func rotateCounterClockwise() {
        let newOrientation = Orientation.rotate(orientation, clockwise: false)
        rotateBlocks(newOrientation)
        orientation = newOrientation
    }
    
    final func lowerShapeByOneRow() {
        shiftBy(0, rows:1)
    }
    
    final func raiseShapeByOneRow() {
        shiftBy(0, rows:-1)
    }
    
    final func shiftRightByOneColumn() {
        shiftBy(1, rows:0)
    }
    
    final func shiftLeftByOneColumn() {
        shiftBy(-1, rows:0)
    }
    
    // #2
    final func shiftBy(_ columns: Int, rows: Int) {
        self.column += columns
        self.row += rows
        for block in blocks {
            block.column += columns
            block.row += rows
        }
    }
    
    // #3
    final func moveTo(_ column: Int, row:Int) {
        self.column = column
        self.row = row
        rotateBlocks(orientation)
    }
    
    final class func random(_ startingColumn:Int, startingRow:Int) -> Shape {
        switch Int(arc4random_uniform(NumShapeTypes)) {
        // #4
        case 0:
            return SquareShape(column:startingColumn, row:startingRow)
        case 1:
            return LineShape(column:startingColumn, row:startingRow)
        case 2:
            return TShape(column:startingColumn, row:startingRow)
        case 3:
            return LShape(column:startingColumn, row:startingRow)
        case 4:
            return JShape(column:startingColumn, row:startingRow)
        case 5:
            return SShape(column:startingColumn, row:startingRow)
        default:
            return ZShape(column:startingColumn, row:startingRow)
        }
    }
    
}

func ==(lhs: Shape, rhs: Shape) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}


/*
 * shape父类
 
 * 角度:
 * 在代码的第一部分,我们先建立了一个枚举类型,这个enumeration用来辅助我们定义我们的shape的4个方向,
 * 无论我们的形状处于什么角度,我们都将把它修正成4个方向: 0,90,180和270.
 * 在这部分代码里面,还有两个函数,一个是随机生成函数(random),一个是旋转函数(rotate).
 * random函数我们之前有接触过,而且代码看起来也很清楚,就不多说了.
 * 而rotate函数其实也不难,传入两个参数,一个是我们上面建立好的枚举类型Orientation,
 * 一个是bool型的变量,表示是顺时针还是逆时针旋转,如果是顺时针,枚举类型就+1,如果是逆时针就-1
 * 当然,这样很容易出现4和-1的情况,如果是270°(3)再顺时针转一圈就+1变成了4,我们要手动把它修复成0度;
 * 同理-1的情况修复成270°,然后我们把这个经过旋转后的角度返回出来。
 
 * shape类其实是一个父类,我们游戏中用到的所有shapes都将继承自这个类,所以NumShapeTypes被定义为7,因为我们一共有7种形状.
 * 而对于每一个shape,我们都可以用4个block来组建成,所以我们把4个block分别加上index.
 
 * #1和#2介绍了新的swift 特性,你一定会很感兴趣.
 * 这里我们定义了两个 computed properties.然后把它们的返回值设置为空,这就好比是C++里面的纯虚函数,
 * 必须在它的子类中进行重新定义.我们一会将会看到它。
 * 在#1中,blockRowColumnPositions 定义了一个computed 的字典，字典是被一对方括弧【】定义的：字典中的内容都是成对出现的，一个是key（关键字），对应的是value（值）。
 
 * 字典我们知道的,可以当我第一次看到Array<(columnDiff:Int, rowDiff: Int)>的时候,还是特别不能理解这又是个啥？
 * 这个在Swift里面其实还是一个传统的数组,我们从Array上面也能理解,只不过里面是一个叫做tuple的类型.
 * tuple其实就是为了简化开发者的工作量,让我们可以直接定义一个返回multiple variable的结构.
 * 总体说来,这个blockRowColumnPositions字典,里面定义的是一个shape的4个方向（这就是为什么key是orientation）时,
 * block的位置（一个shape是由多个block组成的,所以是一个数组;而位置需要坐标来定义,所以需要tuple）.
 
 * #3 我们定义了一个完整的computed property,
 * 我们需要返回处于底部的blocks,你可以想象下你的shape落到底层,或者和别的shape堆叠起来时的样子,这也是为什么我们需要这样的定义.
 
 * #4 这里我们用到了
 reduce<S : Sequence, U>(sequence: S, initial: U, combine: (U, S.GeneratorType.Element) -> U) -> U
 * 方式 去hash我们的整个blocks数组,和之前一样,我们用$0表示第一个参数,$1,表示第二个参数,用他们的亦或值来唯一的定位他们
 
 * #5 这里我们遇到了swift的一个新的关键字:convenience.
 * 其实就相当于构造函数的重载,之前的那个init在swift里面叫做 designated init,也就是必须要有的,
 * 而为什么要叫 convenience 就如它的字面意思一样,是一个便利用户的init,在这里面必须调用之前的 designated init,
 * 否则会出错.其实就是在convenience init里面做了一些定制化的操作,例如在我们的程序里面,构造了一个随机颜色,随机方向的shape。
 
 * #6 我们定义了一个final func意味着这个函数不能被子类重写,而且这个initializeBlocks只能被shape类及它的子类所调用.
 
 * #7 上去的if语句其实相当于这样:
 * 我们注意到里面还有个符号 ..< 其实就是 i >=0 && i< blockRowColumnTranslations.count,
 * 而如果是 ...就表示    0 <=  i <= count了.
 
 
 
 * 在#1,函数在执行时会根据上一章节写的每个不同shape子类的blockRowColumnPosition关系,决定每一个block旋转后的位置。
 * 接下来,我们可以简单地从函数的名字上得出他们的作用,lowerShapeByOneRow, 每次将shape下落一行,
 * 而具体如何下落,就看 #2 中的shiftBy函数,这个都很简单,就不用详细解释了。
 * #3 的moveto函数是直接将blocks移动到指定的行和列,为什么有这个函数呢?别急,很快我们就将看到它了
 * #4 中,我们将随机生成之前建立的7个不同形状的shape中的一个。

 * 接下来我们添加一些函数,用来旋转,移动我们的shape
 * #8 中我们分别添加了两个函数让shape可以顺时针和逆时针的旋转,接下来我们添加了可以使shape左右上下移动的函数
 
 */

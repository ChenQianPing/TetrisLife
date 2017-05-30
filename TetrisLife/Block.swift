//
//  Block.swift
//  TetrisLife
//
//  Created by ChenQianPing on 16/7/6.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//


import SpriteKit

// #1
let NumberOfColors: UInt32 = 6

// #2
enum BlockColor: Int, CustomStringConvertible {
    // #3
    case blue = 0, orange, purple, red, teal, yellow
    
    // #4
    var spriteName: String {
        switch self {
            case .blue:
                return "blue"
            case .orange:
                return "orange"
            case .purple:
                return "purple"
            case .red:
                return "red"
            case .teal:
                return "teal"
            case .yellow:
                return "yellow"
        }
    }
    
    // #5
    var description: String {
        return self.spriteName
    }
    
    // #6
    static func random() -> BlockColor {
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
}

// #7
class Block: Hashable, CustomStringConvertible {
    
    // #8
    // Constants
    let color: BlockColor
    
    // #9
    // Properties
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    
    // #10
    var spriteName: String {
        return color.spriteName
    }
    
    // #11
    var hashValue: Int {
        return self.column ^ self.row
    }
    
    // #12
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }
    
}

// #13
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}


/*
 * 在俄罗斯方块游戏中,我们的主体就是那些形状,而每一个形状都是由不同的块组成的.
 * 所以,我们需要建立一个基础类,block,用来为我们更上层的显示打基础。
 * 这部分只是定义了一个enumeration,
 * 枚举类型:BlockColor,如果你看了之前我们放进来的资源文件,我们的游戏一共有6种颜色的快
 
 * 在#1 我们定义了一个变量表示可以显示的颜色种类:6
 
 * 在#2 我们定义了一个枚举类型,这是一个int行的,然后它遵循一个协议printable.
 * 在你实际输入代码的时候,如果你没有定义description函数,那么会一直提示你printable是有错的,
 * 所以我们可以猜测如果遵循了协议Printable,那么description是必须的.
 
 * 在#3 我们提供了所有可以枚举的选择,它们从Blue(0)开始,结束于Yellow(5)
 
 * 在#4 我们定义个可供计算的性质(computed property),spriteName,
 * computed property类似一个变量,但是每次访问它的时候,它都会执行在其内部的代码块,
 * 我们原本可以在其内部放置一个函数名字,例如getSpriteName（）,但是很明显,computed property是一个更棒的选择
 * 我们用一个switch...case 来完成这个功能
 
 * 在#5 我们用了另一个computed property,description,前面我们已经提到过了,
 * 因为我们采用了协议printable,所以这个description是必须的.
 
 * 最后在#6 我们定义了一个static 函数,名字叫random(),
 * 你可以很容易从它的名字已经它内部的计算知道,这是一个返回随机颜色的函数
 
 * 在#7,我们定义了一个class,它将会同时执行协议Printable和Hashable,其中hashable将允许我们的Block存储在Array2D中.
 
 * 在#8,我们把我们的属性color定义为let，意味着一旦我们对它赋值之后,我们就不能再对它进行赋值了.
 * 在游戏中就表现为,当一个block颜色被分配以后,它就不能再换成别的颜色了。
 
 * 在#9,我们定义了column和row,这两个参数将决定我们的block在屏幕上的位置.
 * SKSpriteNode将会在GameScene对每一个block着色和动画的时候将其描绘在屏幕上.
 
 * 在#10,我们其实定义了一个快照,当我们调用block.spriteName的时候其实我们调用的是block.color.spriteName
 
 * 在#11,我们定义了hashable协议需要的内容,我们定义了当前block的行数和列数的亦或值以确保他们都是独一无二的,这样才能被hash出来
 
 * 在#12这个应该比较熟悉了吧,我们要完成printable协议需要的内容,
 * 注意我们不在需要@“...%@..，string”这样繁琐的形式来写一个string了,
 * 而用\()就可以轻松把我们想要的内容写入字符串,如果你的row是3, column是8,而color是blue,那么将会返回blue:[8,3]
 * 同时还定义了init函数,这个函数比较简单吧。
 
 * 最后#13,我们自定义了一个符号=,它有两个参数lhs和rhs,返回bool类型的值;
 * l和r其实是等号的left和right,如果这个block的row,column和color都一样,那么我就返回ture
 */

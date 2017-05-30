//
//  SquareShape.swift
//  TetrisLife
//
//  Created by ChenQianPing on 16/7/6.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

class SquareShape:Shape {
    /*
     // #9
     | 0•| 1 |
     | 2 | 3 |
     
     • marks the row/column indicator for the shape
     
     */
    
    // The square shape will not rotate
    
    // #10
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.zero: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.oneEighty: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.ninety: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.twoSeventy: [(0, 0), (1, 0), (0, 1), (1, 1)]
        ]
    }
    
    // #11
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.zero:       [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.oneEighty:  [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.ninety:     [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.twoSeventy: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}


/*
 * 我们可以在注释掉的内容里面看懂,其实一个方块的shape,就是4个block堆积起来的,仿佛你画一个草稿,4个方块,
 * 以此是0,1,2,3,
 * 我们只需要补充一下在父类里面的两个“纯虚函数”blockRowColumnPositions 和bottomBlocksForOrientations
 * 因为方块无论你怎样旋转,它看起来都是不变的,所以对于4个方向,我们的0,1,2,3号block其实不需要变换位置,坐标都是固定的。
 */

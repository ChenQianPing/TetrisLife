//
//  TShape.swift
//  TetrisLife
//
//  Created by ChenQianPing on 16/7/6.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

class TShape:Shape {
    /*
     Orientation 0
     
     •   | 0 |
     | 1 | 2 | 3 |
     
     Orientation 90
     
     • | 1 |
       | 2 | 0 |
       | 3 |
     
     Orientation 180
     
     •
     | 1 | 2 | 3 |
         | 0 |
     
     Orientation 270
     
     •   | 1 |
     | 0 | 2 |
         | 3 |
     
     • marks the row/column indicator for the shape
     
     */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.zero:       [(1, 0), (0, 1), (1, 1), (2, 1)],
            Orientation.ninety:     [(2, 1), (1, 0), (1, 1), (1, 2)],
            Orientation.oneEighty:  [(1, 2), (0, 1), (1, 1), (2, 1)],
            Orientation.twoSeventy: [(0, 1), (1, 0), (1, 1), (1, 2)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.zero:       [blocks[SecondBlockIdx], blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.ninety:     [blocks[FirstBlockIdx], blocks[FourthBlockIdx]],
            Orientation.oneEighty:  [blocks[FirstBlockIdx], blocks[SecondBlockIdx], blocks[FourthBlockIdx]],
            Orientation.twoSeventy: [blocks[FirstBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}

/*
 * 这里我把它的程序中 180和270°的位置换一下,
 * 我的是完全按照顺时针的顺序转下去时每个block的位置计算的,
 * 而原始教材里面的代码会出现的一个情况是,旋转的时候会出现类似跳帧的情况,
 * 你会看到左上角的方块直接到右下角了,大家可以按照两种不同的位置试一下。
 */

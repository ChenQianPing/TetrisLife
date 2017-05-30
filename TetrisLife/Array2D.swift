//
//  Array2D.swift
//  TetrisLife
//
//  Created by ChenQianPing on 16/7/5.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

// #1
class Array2D<T> {
    let columns: Int
    let rows: Int
    
    // #2
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        
        // #3
        array = Array<T?>(repeating: nil, count: rows * columns)
    }
    
    // #4
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}

/*
 * 二维数组
 * Swift提供了我们array[index]供我们使用,
 * 但是我们还需要一个自定义的array2D[x,y]来更方便我们的使用,所以,让我们来自定义属于自己的二维数组吧！
 
 * #1
 * 这里我们命名了一个叫做Array2D的class,在Swift里面通常array是用struct 而不是用class,
 * 但是这里我们却需要一个class,因为在我们的程序里面,我们需要传引用（pass by reference）,
 * 而不是传值(pass by value),class是传引用的,而struct是传值的。
 
 * 另外我们还看到,我们的class类型是<T>,这里如果学过c++的应该也很容易理解,其实就是模板类了,
 * T表示任意类型,可以是int,可以是string,可以是char等等等等;
 * 就是说,我们的这个array2D是一个通用的二维数组,你想在数组里面存任何都是可以的
 
 * #2
 * 首先我们定义了一个传统的Swift array,数组里面的类型和我们的二维数组类型一样是<T>,
 * 但是我们注意到其实这里是<T?>,多了一个？
 * 我们已经介绍过了,它表示这是一个optional的变量,也就是说可以是nil,可以不包含任何数据,
 * 而在我们的面板上,如果数组里面是ni就表示这个地方不显示任何的block
 * 接下来是定义我们自己的init函数,init一个二维数组需要两个参数,行数和列数,
 * 前两行代码很简单,把形参中的值传给实例化后的类的两个私有变量,而用来存储数据的数组,就得用到swift原生的array类来建立了.
 
 * #3
 * 接下来是定义我们自己的init函数,init一个二维数组需要两个参数,行数和列数,前两行代码很简单,
 * 把形参中的值传给实例化后的类的两个私有变量,而用来存储数据的数组,就得用到swift原生的array类来建立了.
 * 这里重点讲解一下关于Swift array的 init函数 init(cout: repeatedValue:),repeatedValue就表示初始化的值
 
 * #4
 * 这里我们其实是定义了二维数组的查找符号。
 */

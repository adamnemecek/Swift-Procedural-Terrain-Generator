//
//  Noise.swift
//  Noise
//
//  Created by William Vabrinskas on 5/18/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    static func random(lower: UInt32, upper: UInt32) -> UInt32 {
        return arc4random_uniform(upper - lower) + lower
    }
}
//generates a "Perlin" like noise for procedural generation
class Noise {
    //how quickly the change is between each point
    var steepness:UInt32 = 30
    //the x spacing between each point
    var spacing:CGFloat = 10.0
    //how likely the y direction of the noise changes between each point
    var hillFactor:UInt32 = 10
    
    //returns an array of CGPoints describing the noise generated
    func generate(samples: Int, maxHeight: CGFloat, minHeight:CGFloat) -> [CGPoint] {
        var values = [CGPoint]()
        
        let max = maxHeight
        let min = minHeight
        
        var previousY = CGFloat(arc4random_uniform(UInt32(min)))

        var previousDirection = 1
        
        for x in 0..<samples {
            var newY = previousY
            
            if previousDirection == 0 {
                let down = CGFloat(Int.random(lower: UInt32(previousY), upper: UInt32(previousY) + arc4random_uniform(steepness)))
                newY = down
                if down > min {
                    newY = min
                }
            } else {
                let preUp = previousY - CGFloat(arc4random_uniform(steepness))
                if preUp < 0 {
                    newY = 0
                } else {
                    let up = CGFloat(Int.random(lower:  UInt32(preUp), upper: UInt32(previousY)))
                    newY = up
                    if up < max {
                        newY = max
                    }
                }
            }
            
            let randomDirection = arc4random_uniform(hillFactor)
            if randomDirection == 0 {
                if previousDirection == 0 {
                    previousDirection = 1
                } else {
                    previousDirection = 0
                }
            }
            
            previousY = newY
            let point = CGPoint(x: CGFloat(x) * spacing, y: newY)
            values.append(point)
        }
        return values
    }
    
    func twoD(rect: CGRect) -> [[CGFloat]] {
        let xCount = Int(rect.size.width / self.spacing)
        let yCount = Int(rect.size.height / self.spacing)
        
        var pointCloud: [[CGFloat]] = Array(repeating: Array(repeating: CGFloat(arc4random_uniform(10)) / 10.0, count: xCount), count: yCount)
        
        var previousDirection = 1

        for i in 0..<pointCloud.count {
            for j in 0..<pointCloud[i].count {

                let x = i
                let y = j
                
                if x > 0 && y > 0 {
                    
                    let top = pointCloud[x][y - 1]
                    let left = pointCloud[x - 1][y]
                    
                    var upper = 10
                    var lower = 0
                    
                    let average = (top * left) / 2.0
                    
                    if previousDirection == 1 {
                        //up
                        lower = Int(average)
                    } else {
                        //down
                        upper = Int(average)
                    }
                    
                    let alpha = CGFloat(Int.random(lower: UInt32(lower), upper: UInt32(upper))) / 10.0
                    pointCloud[x][y] = alpha
                    
                }
                
                let randomDirection = arc4random_uniform(hillFactor)
                if randomDirection == 0 {
                    if previousDirection == 0 {
                        previousDirection = 1
                    } else {
                        previousDirection = 0
                    }
                }
            }
        }
        return pointCloud
    }
}

//
//  ViewController.swift
//  WordCloudCollectionView
//
//  Created by SonJihyun on 04/02/2018.
//  Copyright © 2018 DoInsight. All rights reserved.
//

import UIKit

struct Topic: Codable {
    let sentence: String
    let frequency: UInt
}

class ViewController: UIViewController {
    @IBOutlet weak var wordCloudCollectionView: UICollectionView!
    
    var topicList = [Topic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let topicString = """
[
{
"sentence": "끈적임 없는",
"frequency": 9
},
{
"sentence": "저자극의",
"frequency": 40
},
{
"sentence": "흡수력 좋은",
"frequency": 100
},
{
"sentence": "산뜻한",
"frequency": 20
},
{
"sentence": "유분감 적은",
"frequency": 50
},
{
"sentence": "약간 건조함",
"frequency": 5
},
{
"sentence": "피부장벽강화",
"frequency": 10
}
]
"""
        
        do {
            let data = topicString.data(using: .utf8)
            let decoder = JSONDecoder()
            let topicList = try decoder.decode([Topic].self, from: data!)
            
            if topicList.count == 0 {
                return
            }
            
            var shuffledTopicList = topicList
            
            for index in shuffledTopicList.indices {
                let toIndex: Int = numericCast(arc4random_uniform(numericCast(shuffledTopicList.count - 1)))
                shuffledTopicList.swapAt(index, toIndex)
            }
            
            //제일 frequency 높은 것을 가운데로
            let frequencyList = shuffledTopicList.map{$0.frequency}
            let maxFrequency = frequencyList.max()
            
            for i in 0..<frequencyList.count {
                if shuffledTopicList[i].frequency == maxFrequency {
                    let maxTopic = shuffledTopicList[i]
                    shuffledTopicList.remove(at: i)
                    shuffledTopicList.insert(maxTopic, at: (shuffledTopicList.count + 1)/2)
                }
            }
            
            if let flowLayout = self.wordCloudCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.estimatedItemSize = CGSize(width: 1, height:1)
                flowLayout.minimumLineSpacing = 0
            }
            self.topicList = shuffledTopicList
            
            self.wordCloudCollectionView.dataSource = self
            self.wordCloudCollectionView.reloadData()
        } catch {
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topicList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KeywordCollectionViewCell", for: indexPath)
        
        if let sentenceLabel = cell.contentView.subviews.first as? UILabel {
            sentenceLabel.text = topicList[indexPath.row].sentence
            
            let frequencyList = topicList.map{$0.frequency}
            let maxFrequency = frequencyList.max()
            let minFrequency = frequencyList.min()
            let maxFontSize:CGFloat = 36
            let minFontSize:CGFloat = 12
            let maxAlpha:CGFloat = 1
            let minAlpha:CGFloat = 0.5
            
            let fontSize = self.calculateItemValue(minValue: minFontSize, maxValue: maxFontSize, itemFrequency: topicList[indexPath.row].frequency, minFrequency: minFrequency!, maxFrequency: maxFrequency!)
            sentenceLabel.font = sentenceLabel.font.withSize(fontSize)
            
            sentenceLabel.alpha = self.calculateItemValue(minValue: minAlpha, maxValue: maxAlpha, itemFrequency: topicList[indexPath.row].frequency, minFrequency: minFrequency!, maxFrequency: maxFrequency!)
        }
        
        return cell
    }
    
    func calculateItemValue(minValue:CGFloat, maxValue:CGFloat, itemFrequency:UInt, minFrequency:UInt, maxFrequency:UInt) -> CGFloat {
        if maxFrequency == minFrequency {
            return (maxValue + minValue)/2
        }
        let itemFrequency = CGFloat(itemFrequency)
        let minFrequency = CGFloat(minFrequency)
        let maxFrequency = CGFloat(maxFrequency)
        
        let a = (maxValue - minValue)/(maxFrequency-minFrequency)
        let b = (maxFrequency*minValue-minFrequency*maxValue)/(maxFrequency - minFrequency)
        return a*itemFrequency + b
    }
}


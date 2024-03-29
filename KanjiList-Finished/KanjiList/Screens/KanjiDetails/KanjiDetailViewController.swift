/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UIKit

protocol KanjiDetailViewControllerDelegate: class {
  func kanjiDetailViewController(_ kanjiDetailViewController: KanjiDetailViewController,
                                 didSelectWord word: String)
}

class KanjiDetailViewController: KanjiViewController {
  let selectedKanji: Kanji
  var delegate: KanjiDetailViewControllerDelegate?
  
  @IBOutlet weak var detailTableView: UITableView? {
    didSet {
      guard let detailTableView = detailTableView else { return }
      detailTableView.dataSource = self
      detailTableView.delegate = self
      
      // Word cell
      let wordCellNib = UINib(nibName: "WordExampleTableViewCell", bundle: nil)
      detailTableView.register(wordCellNib, forCellReuseIdentifier: "WordExampleTableViewCell")
      
      // Detail cell
      let detailCellNib = UINib(nibName: "KanjiDataTableViewCell", bundle: nil)
      detailTableView.register(detailCellNib, forCellReuseIdentifier: "KanjiDataTableViewCell")
    }
  }
  
  init(kanji: Kanji) {
    selectedKanji = kanji
    super.init(nibName: nil, bundle: nil)
    title = "Kanji details"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UITableViewDataSource
extension KanjiDetailViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 1: return "Words"
    default: return nil
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return 1
    case 1: return selectedKanji.examples.count
    default: return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: "KanjiDataTableViewCell", for: indexPath)
      (cell as? KanjiDataTableViewCell)?.setupCell(data: selectedKanji)
      return cell
    case 1:
      let cell = tableView.dequeueReusableCell(withIdentifier: "WordExampleTableViewCell", for: indexPath)
      let word = selectedKanji.examples[indexPath.row]
      (cell as? WordExampleTableViewCell)?.setupCell(data: word)
      return cell
    default:
      fatalError()
    }
  }
}

// MARK: - UITableViewDelegate
extension KanjiDetailViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    defer {
      tableView.deselectRow(at: indexPath, animated: true)
    }
    
    guard indexPath.section == 1 else {
      return
    }
    let word = selectedKanji.examples[indexPath.row].word
    delegate?.kanjiDetailViewController(self, didSelectWord: word)
  }
}

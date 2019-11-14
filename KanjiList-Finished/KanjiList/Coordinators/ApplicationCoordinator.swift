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

import UIKit

class ApplicationCoordinator: Coordinator {
  let kanjiStorage: KanjiStorage
  let window: UIWindow
  let rootViewController: UINavigationController
  let stateMachine: KanjiStateMachine

  init(window: UIWindow) {
    self.window = window
    kanjiStorage = KanjiStorage()
    rootViewController = UINavigationController()
    rootViewController.navigationBar.prefersLargeTitles = true
    
    stateMachine = KanjiStateMachine(presenter: rootViewController,
                                     kanjiStorage: kanjiStorage,
                                     states: [AllState(), DetailState(), ListState()])
  }
  
  func start() {
    stateMachine.enter(AllState.self)
    window.rootViewController = rootViewController
    window.makeKeyAndVisible()
    subscribeToNotifications()
  }
  
  func subscribeToNotifications() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(receivedAllKanjiNotification),
      name: Notifications.AllKanji, object: nil)
    
    NotificationCenter.default.addObserver(
      self, selector: #selector(receivedKanjiDetailNotification),
      name: Notifications.KanjiDetail, object: nil)
    
    NotificationCenter.default.addObserver(
      self, selector: #selector(receivedKanjiListNotification),
      name: Notifications.KanjiList, object: nil)
  }
  
  @objc func receivedAllKanjiNotification() {
    stateMachine.enter(AllState.self)

  }
  
  @objc func receivedKanjiDetailNotification(notification: NSNotification) {
    // 1
    guard
      let kanji = notification.object as? Kanji,
      // 2
      let detailState = stateMachine.state(forClass: DetailState.self)
      else {
        return
    }
    
    // 3
    detailState.kanji = kanji
    
    // 4
    stateMachine.enter(DetailState.self)
  }
  
  @objc func receivedKanjiListNotification(notification: NSNotification) {
    // 1
    guard
      let word = notification.object as? String,
      let listState = stateMachine.state(forClass: ListState.self)
      else {
        return
    }
    
    // 2
    listState.word = word
    
    // 3
    stateMachine.enter(ListState.self)
  }
}

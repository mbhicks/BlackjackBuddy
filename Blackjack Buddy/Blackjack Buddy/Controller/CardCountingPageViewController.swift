//
//  CardCountingPageViewController.swift
//  Blackjack Buddy
//
//  Created by MTSS on 12/5/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import UIKit

class CardCountingPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

     var pageControl = UIPageControl()
    
    let pageViewControllers: [UIViewController] = {
        return [UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroductionViewController"),
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NumberingViewController"),
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CountTypesViewController"),
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StrategyViewController"),
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DoneViewController")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        pageControl.currentPage = 0
        setViewControllers([pageViewControllers.first!], direction: .forward, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let currentPage = pageControl.currentPage
        pageControl.removeFromSuperview()
        let frame = CGRect(x: 0, y: view.bounds.maxY - 50, width: view.bounds.width, height: 50)
        pageControl = UIPageControl(frame: frame)
        pageControl.numberOfPages = pageViewControllers.count

        view.addSubview(pageControl)
        pageControl.currentPage = currentPage
    }
    
    func viewController(with id: String) -> UIViewController{
        return self.storyboard!.instantiateViewController(withIdentifier: id)
    }
    
    //MARK: - UIPageViewController Data Source
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = pageViewControllers.firstIndex(of: viewController)!
        let nextIndex = index + 1
        let count = pageViewControllers.count

        guard count != nextIndex else {
            return nil
        }
        
        return pageViewControllers[nextIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = pageViewControllers.firstIndex(of: viewController)!
        let previousIndex = index - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pageViewControllers[previousIndex]

    }
    
    // MARK: - UIPageViewController Delegate Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentViewController = pageViewController.viewControllers![0]
        pageControl.currentPage = pageViewControllers.firstIndex(of: currentViewController)!
    }

}

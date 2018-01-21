//
//  Created by chan bill on 21/1/2018.
//  Copyright © 2018 chan bill. All rights reserved.
//

import XCTest
@testable import testNavigationContollerRetain

protocol StrongDelegateViewControllerDelegate: class {
    func strongDelegateViewController(_ strongDelegateViewController: StrongDelegateViewController, didSomething complete: Bool)
}

class StrongDelegateViewController : UIViewController {
    var delegate : StrongDelegateViewControllerDelegate?
}

extension ViewController: StrongDelegateViewControllerDelegate {
    
    func strongDelegateViewController(_ strongDelegateViewController: StrongDelegateViewController, didSomething complete: Bool) {
        print("complete")
    }
}


class testNavigationContollerRetainTests: XCTestCase {

    weak var sut: ViewController!
    
    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
        
        sut = nil
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    
    func testSetViewControllerAsRootViewControllerDoesNotHaveRetain() {
        autoreleasepool{
            // GIVEN
            let viewController = ViewController()
            XCTAssertNotNil(viewController.view)
            
            // If we use UIApplication.shared.keyWindow, viewController is retained
            let window = UIWindow()
            window.rootViewController = viewController
            sut = viewController

        }
        
        // THEN
        XCTAssertNil(sut)
    }
    
    func testSetViewControllerAsRootViewControllerRetains() {
        autoreleasepool{
            // GIVEN
            let window = (UIApplication.shared.delegate as! AppDelegate).window
            window?.rootViewController = ViewController()
            sut = (window?.rootViewController)! as! ViewController
            XCTAssertNotNil(sut.view)
            window?.makeKeyAndVisible()

            // WHEN
            window?.rootViewController = nil
            sut.view.removeFromSuperview()
        }
        
        // THEN
        XCTAssertNotNil(sut)
    }
    
    func testThatRootViewControllerPresentAndDismissDoesNotRetain() {
        autoreleasepool{
            // GIVEN
            let window = (UIApplication.shared.delegate as! AppDelegate).window
            window?.rootViewController = UIViewController()

            let viewController = ViewController()
            sut = viewController

            window?.makeKeyAndVisible()
            window?.rootViewController?.viewDidAppear(false)

            let exp = expectation(description: "Wait for present and dismiss")

            // WHEN
            window?.rootViewController?.present(viewController, animated: false){
                XCTAssertNotNil(viewController.view)
                viewController.viewDidAppear(false)

                XCTAssertNotNil(self.sut)

                viewController.dismiss(animated: false){
                    XCTAssertNotNil(viewController.view)

                    XCTAssertNotNil(self.sut)
                    exp.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 1.0, handler: nil)

        // THEN
        XCTAssertNil(sut)
    }
    
    func testThatRootViewControllerPresentAndDismissNavigationControllerDoesNotRetain() {
        
        weak var sutNavi: UINavigationController!
        
        autoreleasepool{
            // GIVEN
            let window = (UIApplication.shared.delegate as! AppDelegate).window
            window?.rootViewController = UIViewController()
            
            let viewController = ViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            sutNavi = navigationController
            sut = viewController
            
            
            window?.makeKeyAndVisible()
            window?.rootViewController?.viewDidAppear(false)
            
            let exp = expectation(description: "Wait for present and dismiss")
            
            // WHEN
            window?.rootViewController?.present(navigationController, animated: false){
                XCTAssertNotNil(viewController.view)
                viewController.viewDidAppear(false)
                
                XCTAssertNotNil(sutNavi)
                XCTAssertNotNil(self.sut)

                navigationController.dismiss(animated: false){
                    window?.rootViewController?.viewDidAppear(false)
                    XCTAssertNotNil(sutNavi)
                    XCTAssertNotNil(self.sut)
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // THEN
        XCTAssertNil(sutNavi)
        XCTAssertNil(sut)
    }

    func testThatRootViewControllerPresentAndDismissNavigationControllerWithStrongDelegateDoesNotRetain() {
        
        weak var sutNavi: UINavigationController!
        
        autoreleasepool{
            // GIVEN
            let window = (UIApplication.shared.delegate as! AppDelegate).window
            window?.rootViewController = UIViewController()
            
            let viewController = ViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            sutNavi = navigationController
            sut = viewController
            
            
            window?.makeKeyAndVisible()
            window?.rootViewController?.viewDidAppear(false)
            
            let exp = expectation(description: "Wait for present and dismiss")
            
            // WHEN
            window?.rootViewController?.present(navigationController, animated: false){
                XCTAssertNotNil(viewController.view)
                viewController.viewDidAppear(false)
                
                XCTAssertNotNil(sutNavi)
                XCTAssertNotNil(self.sut)
                
                let strongDelegateViewController = StrongDelegateViewController()
                strongDelegateViewController.delegate = viewController
                navigationController.pushViewController(strongDelegateViewController, animated: false)
                strongDelegateViewController.viewDidAppear(false)
                strongDelegateViewController.delegate?.strongDelegateViewController(strongDelegateViewController, didSomething: true)
                
                XCTAssertEqual(navigationController.topViewController, strongDelegateViewController)
                
                navigationController.dismiss(animated: false){
                    window?.rootViewController?.viewDidAppear(false)
                    XCTAssertNotNil(sutNavi)
                    XCTAssertNotNil(self.sut)
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // THEN
        XCTAssertNil(sutNavi)
        XCTAssertNil(sut)
    }
}

//
//  AnomaliesTestCase.swift
//  Tests-iOS
//
//  Created by Denys Telezhkin on 02.05.2018.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTTableViewManager
import DTModelStorage

#if swift(>=4.1)

enum TestAnomaly : Equatable, CustomDebugStringConvertible {
    case itemEventCalledWithCellType(ObjectIdentifier)
    case weirdIndexPathAction(IndexPath)
    
    var debugDescription: String { return "" }
}

class DTTestAnomalyHandler : AnomalyHandler {
    var anomalyAction : (TestAnomaly) -> Void = { print($0.debugDescription) }
}

extension XCTestExpectation {
    func expect(anomaly: TestAnomaly) -> (TestAnomaly) -> Void {
        return {
            guard $0 == anomaly else { return }
            self.fulfill()
        }
    }
    
    func expect(anomaly: DTTableViewManagerAnomaly) -> (DTTableViewManagerAnomaly) -> Void {
        return {
            guard $0 == anomaly else { return }
            self.fulfill()
        }
    }
}

class AnomaliesTestCase: XCTestCase {
    
    var sut: DTTestAnomalyHandler!
    
    override func setUp() {
        super.setUp()
        sut = DTTestAnomalyHandler()
    }
    
    func testAnomaliesCanBePositivelyValidated()  {
        let exp = expectation(description: "Should receive item event anomaly")
        sut.anomalyAction = exp.expect(anomaly: .itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        sut.reportAnomaly(.itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        waitForExpectations(timeout: 0.1)
    }
    
    func testWrongAnomalyFailsTheTest() {
        let exp = expectation(description: "Should receive item event anomaly")
        exp.isInverted = true
        sut.anomalyAction = exp.expect(anomaly: .itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        sut.reportAnomaly(.weirdIndexPathAction(indexPath(0, 0)))
        waitForExpectations(timeout: 0.1)
    }
}

#endif

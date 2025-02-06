//
//  ReportPickerRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//
import UIKit

protocol ReportPickerRoutable: Routable {

}

protocol ReportPickerBuildable {
    static func createReportPickerModule() -> UIViewController
}

final class ReportPickerRouter: ReportPickerRoutable {

}

extension ReportPickerRouter: ReportPickerBuildable {
    static func createReportPickerModule() -> UIViewController {
        let view: ReportPickerViewable & UIViewController = ReportPickerViewController()
        let router: ReportPickerRoutable & ReportPickerBuildable = ReportPickerRouter()
        return view
    }
}

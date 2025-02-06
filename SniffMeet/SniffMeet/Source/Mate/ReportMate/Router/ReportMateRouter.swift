//
//  ReportMateRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//

import UIKit

protocol ReportMateRoutable: Routable {

}

protocol ReportMateBuildable {
    static func createReportMateModule(profile: Mate) -> UIViewController
}

final class ReportMateRouter: ReportMateRoutable {

}

extension ReportMateRouter: ReportMateBuildable {
    static func createReportMateModule(profile: Mate) -> UIViewController {
        let view: ReportMateViewable & UIViewController = ReportMateViewController()
        let router: ReportMateRoutable & ReportMateBuildable = ReportMateRouter()

        return view
    }
}

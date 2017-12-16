//
//  DetailViewController.swift
//  sysmon
//
//  Created by Jeff on 3/21/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import UIKit
import SwiftCharts

class DetailViewController: UIViewController {
    
    var chart : Chart?;
    var historyTableController : TestHistoryTableViewController?;
    
    var readFormatter = NSDateFormatter()
    var displayFormatter = NSDateFormatter()
    
    var chartDuration = 24;
    var chartInterval = 2;
    
    @IBOutlet weak var testHistoryTable: UITableView!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var graphContainerView: UIView!
    @IBOutlet weak var serverTitleLabel: UINavigationItem!
    
    var detailTest: ServerTest? {
        didSet {
            // Update the view.
            self.loadTest()
        }
    }

    func createChartPoint(dateStr dateStr: String, percent: Double, readFormatter: NSDateFormatter, displayFormatter: NSDateFormatter) -> ChartPoint {
        return ChartPoint(x: self.createDateAxisValue(dateStr, readFormatter: readFormatter, displayFormatter: displayFormatter), y: ChartAxisValuePercent(percent))
    }
    
    func createDateAxisValue(dateStr: String, readFormatter: NSDateFormatter, displayFormatter: NSDateFormatter) -> ChartAxisValue {
        let date = readFormatter.dateFromString(dateStr)!
        let labelSettings = ChartLabelSettings(font: DefaultChartSettings.labelFont, rotation: 90, rotationKeep: .Top)
        return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
    }
    
    class ChartAxisValuePercent: ChartAxisValueDouble {
        var description: String {
            return "\(self.formatter.stringFromNumber(self.scalar)!)%"
        }
    }
    
    func createChart() {
        
        if(chart != nil) {
            chart!.view.removeFromSuperview();
        }
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        var chartHeight = screenHeight * 0.7;
        let chartWidth = screenWidth;
        
        switch UIDevice.currentDevice().orientation{
        case .Portrait:
            chartHeight = screenHeight * 0.33;
        case .PortraitUpsideDown:
            chartHeight = screenHeight * 0.33;
            //case .LandscapeLeft:
            //    text="LandscapeLeft"
            //case .LandscapeRight:
        //    text="LandscapeRight"
        default:
            chartHeight = screenHeight;
        }

        
        let labelSettings = ChartLabelSettings(font: DefaultChartSettings.labelFont)
        
        readFormatter.dateFormat = "dd-HH:mm"
        
        displayFormatter.dateFormat = "dd-HH:mm"
        
        let calendar = NSCalendar.currentCalendar()
        let chartStartDate = calendar.dateByAddingUnit(
            NSCalendarUnit.Hour, // adding hours
            value: -chartDuration,
            toDate: NSDate(),
            options: NSCalendarOptions(rawValue: 0)
        )
        
        // Define X Axis
        var chartAxisPoints = Array<ChartAxisValue>();
        let chartSteps = self.chartDuration / self.chartInterval;
        for chartPointIndex in 0...chartSteps {
            let hoursInPast = self.chartDuration - (chartPointIndex * self.chartInterval);
            let newDate = calendar.dateByAddingUnit(
                NSCalendarUnit.Hour, // adding hours
                value: -hoursInPast, // adding two hours
                toDate: NSDate(),
                options: NSCalendarOptions(rawValue: 0)
            )
            let chartDay = newDate!.day();
            let chartHour = newDate!.hour();
            let chartMinute = newDate!.minute();
            let axis = self.createDateAxisValue("\(chartDay)-\(chartHour):\(chartMinute)", readFormatter: readFormatter, displayFormatter: displayFormatter)
            chartAxisPoints.append(axis);
            
            print("Chart Axis \(chartHour):\(chartMinute)");
        }
        
        // Load results for display
        var chartPoints = Array<ChartPoint>();
        let history = detailTest?.getHistory();
        for result in history! {
            if result.resultTime.earlierDate(chartStartDate!).isEqualToDate(result.resultTime) {
                continue;
            }
            let resultDay = result.resultTime.day();
            let resultHour = result.resultTime.hour();
            let resultMinute = result.resultTime.minute();
            let testScore : Double = Double(result.testScore);
            let point = createChartPoint(dateStr: "\(resultDay)-\(resultHour):\(resultMinute)", percent: testScore, readFormatter: readFormatter, displayFormatter: displayFormatter)
            chartPoints.append(point)
            print("Chart Point (\(resultDay)-\(resultHour):\(resultMinute), \(testScore)");
        }
        
        let yValues = 0.stride(through: 100, by: 10).map {ChartAxisValuePercent($0, labelSettings: labelSettings)}
        yValues.first?.hidden = true
        
        let xModel = ChartAxisModel(axisValues: chartAxisPoints, axisTitleLabel: ChartAxisLabel(text: "Time", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Test Score", settings: labelSettings.defaultVertical()))
        
        self.graphContainerView.bounds = CGRectMake(0, 5, chartWidth, chartHeight);
        let chartFrame = self.graphContainerView.bounds;
        let chartSettings = DefaultChartSettings.chartSettings
        chartSettings.trailing = 80
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let lineColor = UIColor.blackColor();
        let fillColor = UIColor.greenColor().colorWithAlphaComponent(0.5);
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: lineColor, animDuration: 0.0, animDelay: 0)
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
        
        let chartFillLayer = ChartPointsAreaLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, areaColor: fillColor, animDuration: 3, animDelay: 0, addContainerPoints: true)
        
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: DefaultChartSettings.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        // touch labels
        /*
        let touchLayer = ChartPointsTrackerLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, locChangedFunc: {[weak chartPointsLineLayer, weak infoView] screenLoc in
            chartPointsLineLayer?.highlightChartpointView(screenLoc: screenLoc)
            if let chartPoint = chartPointsLineLayer?.chartPointsForScreenLocX(screenLoc.x).first {
                infoView?.showChartPoint(chartPoint)
            } else {
                infoView?.clear()
            }
            }, lineColor: UIColor.redColor(), lineWidth: 1)*/
        
        chart = Chart(
            frame: chartFrame,
            layers: [
                coordsSpace.xAxis,
                coordsSpace.yAxis,
                chartFillLayer,
                guidelinesLayer,
                chartPointsLineLayer]
        )
        
        self.graphContainerView.addSubview(chart!.view)

    }
    
    
    
    func configureView() {
        if(self.tableContainerView == nil ) {
            return;
        }
        if(self.detailTest != nil) {
            self.serverTitleLabel.title = (detailTest?.testProtocol)! + "://" + (detailTest?.testHost)!
        }
        self.configureTableView();
        self.createChart();
        self.configureTable();
    }
    
    func configureChart() {
        if(chart == nil) {
            return
        }
        
    }
    
    func configureTable() {
        if(self.historyTableController != nil || self.testHistoryTable == nil) {
            return;
        }
        
        self.historyTableController = TestHistoryTableViewController();
        
        self.testHistoryTable.dataSource = self.historyTableController;
        self.testHistoryTable.delegate = self.historyTableController;
        self.historyTableController!.tableView = self.testHistoryTable;
        self.historyTableController!.serverTest = detailTest!;
    }
    
    func loadTest() {
        if(self.historyTableController == nil){
            return;
        }
        self.serverTitleLabel.title = (detailTest?.testProtocol)! + "://" + (detailTest?.testHost)!
        self.historyTableController!.serverTest = detailTest!;
        self.historyTableController?.reloadHistory();
    }

    func configureTableView() {
        switch UIDevice.currentDevice().orientation{
        case .Portrait:
            self.tableContainerView.hidden = false;
        case .PortraitUpsideDown:
            self.tableContainerView.hidden = false;
        case .LandscapeLeft:
            self.tableContainerView.hidden = true;
        case .LandscapeRight:
            self.tableContainerView.hidden = true;
        default:
            self.tableContainerView.hidden = false;
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        configureTableView();
        createChart();
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // Test Result table delegate
        
}


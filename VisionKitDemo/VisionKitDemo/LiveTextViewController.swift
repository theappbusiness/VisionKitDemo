////
////  LiveTextViewController.swift
////  VisionKitDemo
////
////  Created by Raynelle Francisca on 11/11/22.
////
//
//import UIKit
//import VisionKit
//import Vision
//
//@available(iOS 16.0, *)
//class LiveTextViewController: UIViewController {
//
//	let analyser = ImageAnalyzer()
//	let interaction = ImageAnalysisInteraction()
//
//
//	let dataScannerViewController = DataScannerViewController(recognizedDataTypes: [ .barcode(symbologies: [.upce, .ean8, .ean13]), .text()],
//															  qualityLevel: .fast,
//	isHighlightingEnabled: true)
//
//	var image: UIImage? {
//		didSet {
//			interaction.preferredInteractionTypes = []
//			interaction.analysis = nil
//			analyzeCurrentImage()
//		}
//	}
//
//	func analyzeCurrentImage() {
//		guard let image = image else {
//			return
//		}
//
//		Task {
//			do {
//				let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
//				let analysis = try await analyser.analyze(image, configuration: configuration)
//
//
//				guard let analysis = analysis, _ = self.image else { return }
//
//				interaction.analysis = analysis
//				interaction.preferredInteractionTypes = .automatic
//
//			}
//			catch {
//				print(error)
//
//			}
//		}
//	}
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//
//		try? dataScannerViewController.stopScanning()
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
//
//
//@available(iOS 16.0, *)
//extension LiveTextViewController: DataScannerViewControllerDelegate {
//	func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
//		switch item {
//		case let .barcode(barcodeText): self.rec
//		}
//	}
//
//}

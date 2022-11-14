//
//  ViewController.swift
//  VisionKitDemo
//
//  Created by Raynelle Francisca on 04/11/22.
//

import UIKit
import VisionKit
import Vision

class ViewController: UIViewController {

	@IBOutlet var scanImageView: UIImageView!
	@IBOutlet var ocrTextView: UITextView!
	
	@IBOutlet var scanButton: UIButton!
	var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		configureOCR()
	}


	func displayScanningController() {
			guard VNDocumentCameraViewController.isSupported else { return }

			let controller = VNDocumentCameraViewController()
			controller.delegate = self

			present(controller, animated: true)
		}


	@IBAction func scanDocument(_ sender: Any) {
		scanDocument()
	}


	@objc private func scanDocument() {
		let scanVC = VNDocumentCameraViewController()
		scanVC.delegate = self
		present(scanVC, animated: true)
	}


	private func processImage(_ image: UIImage) {
		guard let cgImage = image.cgImage else { return }

		ocrTextView.text = ""
		scanButton.isEnabled = false

		let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
		do {
			try requestHandler.perform([self.ocrRequest])
		} catch {
			print(error)
		}
	}


	private func configureOCR() {
		ocrRequest = VNRecognizeTextRequest { (request, error) in
			guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

			var ocrText = ""
			for observation in observations {
				guard let topCandidate = observation.topCandidates(1).first else { return }

				ocrText += topCandidate.string + "\n"
			}


			DispatchQueue.main.async {
				print("OCR Text \(ocrText)")
				self.ocrTextView.text = ocrText
				self.scanButton.isEnabled = true
			}
		}

		ocrRequest.recognitionLevel = .accurate
		ocrRequest.recognitionLanguages = ["en-US", "en-GB"]
		ocrRequest.usesLanguageCorrection = true
	}



}


extension ViewController: VNDocumentCameraViewControllerDelegate {
	func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
		guard scan.pageCount >= 1 else {
			controller.dismiss(animated: true)
			return
		}

		scanImageView.image = scan.imageOfPage(at: 0)
		processImage(scan.imageOfPage(at: 0))
		controller.dismiss(animated: true)
}
	func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
		dismiss(animated: true, completion: nil)
	}
}

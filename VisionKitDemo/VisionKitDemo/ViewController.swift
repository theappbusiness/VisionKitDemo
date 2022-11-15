//
//  ViewController.swift
//  VisionKitDemo
//
//  Created by Raynelle Francisca on 04/11/22.
//

import UIKit
import VisionKit
import Vision


@available(iOS 16.0, *)
class ViewController: UIViewController {

	@IBOutlet var scanImageView: UIImageView!
	@IBOutlet var ocrTextView: UITextView!
	
	@IBOutlet var scanButton: UIButton!
	var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)


	//live text
	private lazy var interaction: ImageAnalysisInteraction = {
		let interaction = ImageAnalysisInteraction()
		interaction.preferredInteractionTypes = .automatic
		return interaction
	}()

	private let imageAnalyzer = ImageAnalyzer()

	var scanLiveText = false

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

		configureOCR()
		scanImageView.addInteraction(interaction)
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


	@IBAction func scanForLiveText(_ sender: Any) {
		scanLiveText = true
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


	//livetext API
	private func showLiveText() {
		guard let image = scanImageView.image else {
			return
		}

		Task {
			let configuration = ImageAnalyzer.Configuration([.text])

			do {
				let analysis = try await imageAnalyzer.analyze(image, configuration: configuration)

				DispatchQueue.main.async {
					self.interaction.analysis = analysis
					self.interaction.preferredInteractionTypes = .automatic
				}

			} catch {
				print(error.localizedDescription)
			}
		}
	}

}



@available(iOS 16.0, *)
extension ViewController: VNDocumentCameraViewControllerDelegate {
	func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
		guard scan.pageCount >= 1 else {
			controller.dismiss(animated: true)
			return
		}
		scanImageView.image = scan.imageOfPage(at: 0)
		if scanLiveText == true {
			showLiveText()

		} else {
			processImage(scan.imageOfPage(at: 0))
		}
		scanLiveText = false
		controller.dismiss(animated: true)
}
	func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
		dismiss(animated: true, completion: nil)
	}
}

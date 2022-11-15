# VisionKitDemo

**VisionKit** is a framework Apple introduced in iOS 13 that lets your app use the system’s document scanner to scan documents or papers.

It has support for OCR (Optical Character Recognition), which can detect and recognise text on scanned documents.

In this repo we will see how to:
- Scan an image/document.
- Recognize & extract the text from the scanned document  (using Vision framework) and display it in a textView.
- Explore the LiveText API introduced in iOS 16. This API can recognise any image taken from a camera on the iPhone and grab the data. (You will need Xocde 14 to run this)


<table>
<tr>
<td>

Using Vision

https://user-images.githubusercontent.com/38100299/201903075-5b61b70d-37f9-47eb-bb98-f75a8235c7d2.mov

</td>

<td>

Using LiveText API

https://user-images.githubusercontent.com/38100299/201903115-5f8bfffa-9421-4483-ba0d-308371c2a3a1.MP4


</td>
</tr>

</table>




**Using VisionKit and Vision** <br>
`VNDocumentCameraViewController` is used to scan the document. We also need to implement its delegates `VNDocumentCameraViewControllerDelegate`

`func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan)` 
- is called when we have scanned one or more pages and saved them.

`func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error)`
- is called when an error occurs when scanning the document.

`func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController)`
- is called when the Cancel button of the VNDocumentCameraViewController controller is ttapped. And will dismiss the controller.



To recognize and extract the text of the documents we have scanned, we will use the Apple Vision framework. We will use the VNRecognizeTextRequest class.
`var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)`
This class  searches and recognizes the text in an image.


The function `configureOCR` contains the code to analyze, recognize, and extract the text from the image. This is called from viewDidload.

```
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
```


We create a `VNRecognizeTextRequest` that contains one argument, a completionHandler, which is called every time text is detected in an image.

`request.results` contains a list of observations, which relate to the lines and sentences that the Vision framework has detected.

We then loop through this list of observations. Each of these observations is made up of a series of possible candidates of what the recognized text may be, each of them with a certain level of confidence. We choose the first candidate and add it to a text string.

We then add this text to our texview.


The function  `processImage` is where we create an instance of type `VNImageRequestHandler`, which is where we will pass the ocrRequest instance that we created at the start.

```
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

```

This function will be called at the end of the `documentCameraViewController (_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan)`
 method and just before dismissing the controller.

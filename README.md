# VisionKit

**VisionKit** is a framework Apple introduced in iOS 13 that lets your app use the system’s document scanner to scan documents or papers.

It has support for OCR (Optical Character Recognition), which can detect and recognise text on scanned documents.

In this repo we will see how to:
- Scan, recognize & extract the text from the scanned document  (using Vision framework) and display it in a textView.
Click [here](https://github.com/theappbusiness/VisionKitDemo/edit/main/README.md#using-visionkit-and-vision-) to go to this section. 
- Explore the LiveText API introduced in iOS 16. This API can recognise any image taken from a camera on the iPhone and grab the data. (You will need Xocde 14 to run this) Click [here](https://github.com/theappbusiness/VisionKitDemo/edit/main/README.md#using-visionkits-livetext-api-) to go to this section. 






# Using VisionKit and Vision <br>
## Scan the Document
`VNDocumentCameraViewController` is used to scan the document. We also need to implement its delegates `VNDocumentCameraViewControllerDelegate`

`func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan)` 
- is called when we have scanned one or more pages and saved them.

`func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error)`
- is called when an error occurs when scanning the document.

`func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController)`
- is called when the Cancel button of the VNDocumentCameraViewController controller is ttapped. And will dismiss the controller.


## Recognize and extract text
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

The result will look as below:

https://user-images.githubusercontent.com/38100299/201903075-5b61b70d-37f9-47eb-bb98-f75a8235c7d2.mov




# Using VisionKit's LiveText API <br>
The classes that need to be used are `ImageAnalyzer` and `ImageAnalysisInteraction`.

`ImageAnalyzer` - finds items in images that the user can interact with, such as text and QR codes.
`ImageAnalysisInteraction` - Will provide a A Live Text interaction for a view that contains an image.

We first need to define these objects.

```
private lazy var interaction: ImageAnalysisInteraction = {
    let interaction = ImageAnalysisInteraction()
    interaction.preferredInteractionTypes = .automatic
    return interaction
}()

private let imageAnalyzer = ImageAnalyzer()

```

In `viewDidLoad` we set up the interaction with the imageView.

```
override func viewDidLoad() {
    super.viewDidLoad()

    imageView.addInteraction(interaction)
}
```

We need to use `VNDocumentCameraViewController` to get the image. Once we have the image we can run the below code to show the live text on the image.


```
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
	
```

The result will look as below:

https://user-images.githubusercontent.com/38100299/201903115-5f8bfffa-9421-4483-ba0d-308371c2a3a1.MP4


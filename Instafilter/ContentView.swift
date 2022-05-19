//
//  ContentView.swift
//  Instafilter
//
//  Created by Michael & Diana Pascucci on 5/18/22.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    
    // MARK: - PROPERTIES
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 200.0
    @State private var filterScale = 10.0
    @State private var filterAngle = 3.1
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    
    @State private var processedImage: UIImage?
    
    @State private var noPictureSelected = true
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                VStack {
                    HStack {
                        Text("Intensity (\(filterIntensity, specifier: "%.1f"))")
                        Slider(value: $filterIntensity, in: 0...1, step: 0.1)
                            .onChange(of: filterIntensity) { _ in
                                applyProcessing()
                            }
                    }
                    
                    HStack {
                        Text("Radius (\(filterRadius, specifier: "%.0f"))")
                        Slider(value: $filterRadius, in: 0...1000, step: 1)
                            .onChange(of: filterRadius) { _ in
                                applyProcessing()
                            }
                    }
                    
                    HStack {
                        Text("Scale (\(filterScale, specifier: "%.0f"))")
                        Slider(value: $filterScale, in: 0...20, step: 1)
                            .onChange(of: filterScale) { _ in
                                applyProcessing()
                            }
                    }
                    
                    HStack {
                        Text("Angle (\(filterAngle, specifier: "%.0f"))")
                        Slider(value: $filterAngle, in: 0...12.5, step: 0.5)
                            .onChange(of: filterAngle) { _ in
                                applyProcessing()
                            }
                    }
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter") {
                        showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save", action: save)
                        .disabled(noPictureSelected)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }         // Requires Radius (Default: 20.0)
                Button("Edges") { setFilter(CIFilter.edges()) }                     // Requires Intensity (Default 1.0)
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }      // Requires Radius (Default: 10.0)
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }             // Requires Scale (Default: 8.0)
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }            // Requires Intensity (Default: 1.0)
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }        // Requires Intensity (Default: 0.5) and Radius (Default 2.5)
                Button("Vignette") { setFilter(CIFilter.vignette()) }               // Requires Intensity (Default: 0.0) and Radius (Default: 1.0)
                Button("Twirl Distortion") { setFilter(CIFilter.twirlDistortion()) } // Requires Radius (Default: 300.0) and Angle (Defualt: 3.14)
                Button("Cancel", role: .cancel) { }
            }
            .onChange(of: inputImage) { _ in loadImage() }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * filterRadius, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * filterScale, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputAngleKey) { currentFilter.setValue(filterAngle, forKey: kCIInputAngleKey)}
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
            
            noPictureSelected = false
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        imageSaver.successHandler = { print("Success") }
        imageSaver.errorHandler = { print("Oops: \($0.localizedDescription)") }
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
}

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

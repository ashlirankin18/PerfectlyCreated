//
//  AddProductView.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 2/24/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import SwiftUI
import Combine
import PhotosUI
import Camera_SwiftUI
import AVFoundation

struct AddProductView: View {
    
    @State private var isPresented: Bool = false
    
    @State private var alertIsPresented: Bool = false
    
    @ObservedObject var viewModel: ViewModel
    
    var backButtonTapped: (() -> Void)?
    
    var saveButtonTapped: (() -> Void)?
    
    var body: some View {
        NavigationView {
            VStack {
                Form(content: {
                    Section(footer:
                                Text("This product has no description").foregroundColor(.secondary).bold()) {
                        HStack {
                            Text("Barcode Number: ")
                            Spacer()
                            Text(viewModel.barcodeString)
                        }
                        
                        TextField("Enter Product Name", text: $viewModel.productName)
                    }
                    Section(header:
                                Text("Add an image to the product."),
                            footer:
                                Text("Adding this product helps our community greatly")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                    ) {
                        Button(action: {
                            isPresented.toggle()
                        }, label: {
                            Text("Take a photo")
                        })
                        .sheet(isPresented: $isPresented, content: {
                            GeometryReader { geo in
                                CameraView(isPresented: $isPresented, model: viewModel.cameraModel)
                                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                            }
                        })
                        Button(action: {
                            isPresented.toggle()
                        }, label: {
                            Text("Upload a photo")
                        })
                        .sheet(isPresented: $isPresented, content: {
                            PhotoPicker(isPresented: $isPresented, viewModel: viewModel)
                        })
                        HStack {
                            Spacer()
                            Image(uiImage: (viewModel.retrieveImage()))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 250, height: 250, alignment: .center)
                                .foregroundColor(Color(.appPurple))
                            Spacer()
                        }
                    }
                })
            }
            .navigationBarItems(leading:
                                    Button(action: {
                                        backButtonTapped?()
                                    }, label: {
                                        Image(systemName: "multiply")
                                    })
                                    .foregroundColor(Color(UIColor.appPurple)), trailing:
                                        Button(action: {
                                            if viewModel.productName.isEmpty || viewModel.productName.count == 1 {
                                                alertIsPresented.toggle()
                                            } else {
                                                saveButtonTapped?()
                                            }
                                        }, label: {
                                            Text("Save")
                                        })
                                        .alert(isPresented: $alertIsPresented, content: {
                                            Alert(title: Text("Add product name to save it."))
                                        })
                                        .foregroundColor(Color(UIColor.appPurple)))
            .navigationTitle(Text("Add Product"))
        }
    }
}

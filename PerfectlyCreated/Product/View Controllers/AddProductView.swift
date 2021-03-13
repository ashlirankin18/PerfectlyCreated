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

struct AddProductView: View {
    
    @State private var isPresented: Bool = false
    
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
                    Section(header: Text("Add an image to the product."), footer:
                                Text("Adding this product helps our community greatly")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                    ) {
                        Button(action: {    
                        }, label: {
                            Text("Take a photo")
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
                                .frame(width: 300, height: 300, alignment: .center)
                            Spacer()
                        }
                    }
                })
            }
            .navigationBarItems(leading:
                                    Button(action: {
                                        backButtonTapped?()
                                    }, label: {
                                        Image(systemName: "chevron.left")
                                    })
                                    .foregroundColor(.pink), trailing:
                                        Button(action: {
                                            saveButtonTapped?()
                                        }, label: {
                                            Text("Save")
                                        })
                                        .foregroundColor(.pink))
            
            .navigationTitle(Text("Add Product"))
        }
    }
}

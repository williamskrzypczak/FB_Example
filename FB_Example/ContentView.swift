
//  FB_ExampleApp.swift
//  FB_Example
//
//  Created by Bill Skrzypczak on 3/31/24.
//

//----------------------------------------------------------------]
//
// Import the appropriate Libraries
//
//----------------------------------------------------------------]

import SwiftUI
//import FireBase
import FirebaseFirestore

//----------------------------------------------------------------]
//
// Define the CRUD App UI
//
//----------------------------------------------------------------]


// Define the Attributes of the fields of the DB
struct ContentView: View {
    @State private var manufacturer: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var documentIDToEdit: String? = nil

// Setup the main view
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                    Text("Firebase CRUD App")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    TextField("Manufacturer", text: $manufacturer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    TextField("Model", text: $model)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    TextField("Year", text: $year)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Add Record") {
                        addRecord(manufacturer: manufacturer, model: model, year: year)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(5)
                    
                    Button("Fetch Document ID") {
                        fetchDocumentForModel(modelName: model)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(5)
                    
                    Button("Edit/Update Record") {
                        if let docID = documentIDToEdit {
                            editRecord(documentID: docID, manufacturer: manufacturer, model: model, year: year)
                        }
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(documentIDToEdit != nil ? Color.green : Color.gray)
                    .cornerRadius(5)
                    .disabled(documentIDToEdit == nil)
                    
                    
                    
                    // Add Clear Button
                    Button("Clear Fields") {
                        // Reset all fields to their initial state
                        self.manufacturer = ""
                        self.model = ""
                        self.year = ""
                        self.documentIDToEdit = nil
                    }
                    .padding()
                    .foregroundColor(.white) // This makes the lettering white
                    .background(Color.red) // This makes the button's background red
                    .cornerRadius(5)
                } // Bottom of VStack
                
                .padding()
                
        } // Bottom of ZStack
        
    }
 
    //----------------------------------------------------------------]
    //
    // Define the Behaviours of the App
    //
    //----------------------------------------------------------------]
    
    // Add a record
    func addRecord(manufacturer: String, model: String, year: String) {
        let db = Firestore.firestore()
        
        let yearInt = Int(year) ?? 0
        
        db.collection("guitars").addDocument(data: [
            "manufacturer": manufacturer,
            "model": model,
            "year": yearInt
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document successfully added!")
                self.manufacturer = ""
                self.model = ""
                self.year = ""
            }
        }
    }
    
    // Edit or Update a Record
    func editRecord(documentID: String, manufacturer: String, model: String, year: String) {
        let db = Firestore.firestore()
        
        let yearInt = Int(year) ?? 0
        
        db.collection("guitars").document(documentID).updateData([
            "manufacturer": manufacturer,
            "model": model,
            "year": yearInt
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated!")
                self.manufacturer = ""
                self.model = ""
                self.year = ""
            }
        }
    }
    
    // Find a Specific Record
    func fetchDocumentForModel(modelName: String) {
        let db = Firestore.firestore()
        
        db.collection("guitars").whereField("model", isEqualTo: modelName).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                let document = querySnapshot.documents.first!
                let data = document.data()
                self.documentIDToEdit = document.documentID
                self.manufacturer = data["manufacturer"] as? String ?? ""
                self.model = data["model"] as? String ?? ""
                self.year = (data["year"] as? Int)?.description ?? ""
                
                print("Document fetched with ID: \(document.documentID)")
            } else {
                print("No document found")
                self.manufacturer = ""
                self.model = ""
                self.year = ""
                self.documentIDToEdit = nil
            }
        }
    }
}

// Preview
#Preview {
    ContentView()
}

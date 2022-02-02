//
//  DataScreenLayoutEditor.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/19/21.
//

import SwiftUI

struct DataScreenLayoutEditor: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: DataScreenLayoutEditorViewModel
    @State var currentIndex = 0
    var body: some View {
        GeometryReader { geo in
            VStack {
                TabView(selection: $currentIndex) {
                    ForEach(0..<viewModel.dataScreens.count, id: \.self) { index in
                        ZStack {
                            DataScreen(screenLayout: viewModel.dataScreens[index])
                            DataScreenEditorOverlay(dataScreenIndex: index)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .edgesIgnoringSafeArea(.top)
                .frame(height: geo.size.height * 7/8)
                
                CustomTabIndicator(count: viewModel.dataScreens.count, current: $currentIndex)
                
                HStack {
                    CustomButton(text: "Cancel") {
                        print("cancel")
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(8)
                    
                    CustomButton( text: "Save") {
                        viewModel.setDataScreens()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(8)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
            }
        }
    }
}

//struct DataScreenLayoutEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        DataScreenLayoutEditor()
//    }
//}

struct DataScreenEditorOverlay: View {
    @EnvironmentObject var viewModel: DataScreenLayoutEditorViewModel
    @State var dataScreenIndex: Int
    @State var showEditingRow = false
    @State var selectedRow = -1
    @State var selectedItem = -1
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                let dataScreenLayout = viewModel.dataScreens[dataScreenIndex]
                ForEach(0..<dataScreenLayout.dataRows.count, id: \.self) { index in // rename index
                    let dataItems = dataScreenLayout.dataRows[index].dataItems
                    let dataRow = dataScreenLayout.dataRows[index]
                    if dataItems.count == 1 {
                        if dataItems[0].dataType == .map {
                            ZStack {
                                InvisibleView()
                                    .edgesIgnoringSafeArea(.top)
                                    .frame(width: geo.size.width, height: (geo.size.height / 8) * CGFloat(dataRow.size))
                                    .onTapGesture {
                                        selectedRow = index
                                        selectedItem = 0
                                        showEditingRow = true
                                    }
                                RemoveDataFieldButton(action: {
                                    viewModel.removeDataRow(dataScreenIndex: dataScreenIndex, dataRowIndex: index)
                                })
                            }
                            .frame(width: geo.size.width, height: (geo.size.height / 8) * CGFloat(dataRow.size))
                            
                        } else if dataItems[0].dataType == .interval {
                            ZStack {
                                InvisibleView()
                                    .edgesIgnoringSafeArea(.top)
                                    .onTapGesture {
                                        selectedRow = index
                                        selectedItem = 0
                                        showEditingRow = true
                                    }
                                RemoveDataFieldButton(action: {
                                    viewModel.removeDataRow(dataScreenIndex: dataScreenIndex, dataRowIndex: index)
                                })
                            }
                            .frame(width: geo.size.width, height: (geo.size.height / 8) * CGFloat(dataRow.size))
                        } else {
                            ZStack {
                                InvisibleView()
                                    .onTapGesture {
                                        selectedRow = index
                                        selectedItem = 0
                                        showEditingRow = true
                                    }
                                VStack {
                                    HStack {
                                        Spacer()
                                        CustomButton(text: "Add Column", action:  {
                                            viewModel.addColumn(dataScreenIndex: dataScreenIndex, dataRowIndex: index)
                                        }, fontSize: 12)
                                        .frame(width: 100, height: 30)
                                        .padding(.top, 16)
                                        .padding(.trailing, 16)
                                    }
                                    Spacer()
                                }
                                RemoveDataFieldButton(action: {
                                        viewModel.removeDataRow(dataScreenIndex: dataScreenIndex, dataRowIndex: index)
                                })
                            }
                            .frame(width: geo.size.width, height: (geo.size.height / 8) * CGFloat(dataRow.size))
                            
                        }
                    } else {
                        HStack(spacing: 0) {
                            ZStack {
                                InvisibleView()
                                    .onTapGesture {
                                        selectedRow = index
                                        selectedItem = 0
                                        showEditingRow = true
                                    }
                                RemoveDataFieldButton(action: {
                                    viewModel.removeDataItem(dataScreenIndex: dataScreenIndex, dataRowIndex: index, dataItemIndex: 0)
                                })
                            }
                            ZStack {
                                InvisibleView()
                                    .onTapGesture {
                                        selectedRow = index
                                        selectedItem = 1
                                        showEditingRow = true
                                    }
                                RemoveDataFieldButton(action: {
                                    viewModel.removeDataItem(dataScreenIndex: dataScreenIndex, dataRowIndex: index, dataItemIndex: 1)
                                })
                            }
                            
                        }
                        .frame(width: geo.size.width, height: (geo.size.height / 8) * CGFloat(dataRow.size))
                    }
                }
                VStack {
                    if viewModel.dataScreens[dataScreenIndex].spaceAvailable > 0 {
                        CustomButton(text: "Add Row", action:  {
                            viewModel.addRow(dataScreenIndex: dataScreenIndex)
                        }, fontSize: 16)
                        .padding()
                    }
                }
                .frame(width: geo.size.width/2, height: (geo.size.height / 9))
                
            }
            .sheet(isPresented: $showEditingRow) {
                DataRowEditView(dataScreenIndex: $dataScreenIndex, dataRowIndex: $selectedRow, dataItemIndex: $selectedItem)
            }
        }
        
        
        
    }
}

struct RemoveDataFieldButton: View {
    var action: () -> ()
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: action, label: {
                    Image(systemName: "trash.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(4)
                        
                })
                .frame(width: 30, height: 30)
                .background(Color.orange)
                .cornerRadius(4)
                .foregroundColor(.white)
                .padding(.bottom, 8)
                .padding(.leading, 8)
                Spacer()
            }
            
        }
    }
}

struct DataRowEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: DataScreenLayoutEditorViewModel
    @Binding var dataScreenIndex: Int
    @Binding var dataRowIndex: Int
    @Binding var dataItemIndex: Int
    @State private var selectedSize = -1
    @State private var selectedDataType: DataType = .time
    @State private var selectedDataTypeDidSet = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Picker(selectedDataType.rawValue, selection: $selectedDataType) {
                        ForEach(DataType.allCases) { dataType in
                            if dataType == .map {
                                if canAddMap() {
                                    Text(dataType.rawValue).tag(dataType)
                                }
                            } else {
                                if checkValidDataTypeInRow(dataType: dataType) {
                                    Text(dataType.rawValue).tag(dataType)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Size")) {
                        Picker("Size", selection: $selectedSize) {
                            ForEach(getLowerSizeRange()..<getUpperSizeRange(), id: \.self) { size in
                                if selectedDataType == .interval {
                                    
                                }
                                Text("\(size)").tag(size)
                            }
                        }
                    }
                }
                
                Text("Note: Your data screens can only contain at most one Map. Some data fields have minimum size requirements.")
                    .font(.system(size: 18))
                    .padding()
                
                Spacer()
                
                HStack {
                    CustomButton(text: "Save") {
                        viewModel.saveChange(dataScreenIndex: dataScreenIndex, dataRowIndex: dataRowIndex, dataRowSize: selectedSize, dataItemIndex: dataItemIndex, dataType: selectedDataType)
                        dismiss()
                    }
                }
                .frame(height: 40)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                
            }
            .onAppear {
                if selectedSize == -1 {
                    selectedSize = viewModel.dataScreens[dataScreenIndex].dataRows[dataRowIndex].size
                }
                if !selectedDataTypeDidSet {
                    selectedDataType = viewModel.dataScreens[dataScreenIndex].dataRows[dataRowIndex].dataItems[dataItemIndex].dataType
                    selectedDataTypeDidSet = true
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Edit")
        }
        
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func getUpperSizeRange() -> Int {
        let dataScreen = viewModel.dataScreens[dataScreenIndex]
        if dataScreen.dataRows.count >= 1 {
            let max = dataScreen.spaceAvailable + dataScreen.dataRows[dataRowIndex < dataScreen.dataRows.count ? dataRowIndex : 0].size + 1
            return max
        }
        return 1
    }
    
    private func getLowerSizeRange() -> Int {
        if selectedDataType == .interval {
            return 2
        } else {
            return 1
        }
    }
    
    private func checkValidDataTypeInRow(dataType: DataType) -> Bool {
        if dataType == .map || dataType == .interval {
            if viewModel.dataScreens[dataScreenIndex].dataRows[dataRowIndex].dataItems.count == 1 &&
            selectedSize >= 2 {
                return true
            } else {
                return false
            }
        } else {
             return true
        }
    }
    
    private func canAddMap() -> Bool {
        for i in 0..<viewModel.dataScreens.count {
            if i != dataScreenIndex {
                let dataScreen = viewModel.dataScreens[i]
                for row in dataScreen.dataRows {
                    for dataItem in row.dataItems {
                        if dataItem.dataType == .map {
                            return false
                        }
                    }
                }
            } else {
                let dataScreen = viewModel.dataScreens[i]
                for rowIndex in 0..<dataScreen.dataRows.count {
                    if rowIndex != dataRowIndex {
                        for dataItem in dataScreen.dataRows[rowIndex].dataItems {
                            if dataItem.dataType == .map {
                                return false
                            }
                        }
                    }
                }
            }
        }
        return true
    }
}

class DataScreenLayoutEditorViewModel: ObservableObject {
    @Published var dataScreens = Profile.default.dataScreens
    
    func removeDataRow(dataScreenIndex: Int, dataRowIndex: Int) {
        if dataRowIndex >= dataScreens[dataScreenIndex].dataRows.count {
             return
        }
        dataScreens[dataScreenIndex].dataRows.remove(at: dataRowIndex)
    }
    
    func removeDataItem(dataScreenIndex: Int, dataRowIndex: Int, dataItemIndex: Int) {
        if dataItemIndex >= dataScreens[dataScreenIndex].dataRows[dataRowIndex].dataItems.count {
             return
        }
        dataScreens[dataScreenIndex].dataRows[dataRowIndex].dataItems.remove(at: dataItemIndex)
    }
    
    func saveChange(dataScreenIndex: Int, dataRowIndex: Int, dataRowSize: Int, dataItemIndex: Int, dataType: DataType) {
        dataScreens[dataScreenIndex].dataRows[dataRowIndex].size = dataRowSize
        dataScreens[dataScreenIndex].dataRows[dataRowIndex].dataItems[dataItemIndex].dataType = dataType
    }
    
    func addColumn(dataScreenIndex: Int, dataRowIndex: Int) {
        if dataScreens[dataScreenIndex].dataRows[dataRowIndex].dataItems.count >= 2 {
             return
        }
        let dataItem = dataScreens[dataScreenIndex].dataRows[dataRowIndex].dataItems[0]
        dataScreens[dataScreenIndex].dataRows[dataRowIndex].dataItems.append(dataItem)
    }
    
    func addRow(dataScreenIndex: Int) {
        // check if you can add
        let layoutDataRow = LayoutDataRow(dataItems: [LayoutDataItem(dataType: .time)], size: 1)

        dataScreens[dataScreenIndex].dataRows.append(layoutDataRow)
    }
    
    func setDataScreens() {
        Profile.default.setDataScreen(dataScreens: dataScreens)
    }
}

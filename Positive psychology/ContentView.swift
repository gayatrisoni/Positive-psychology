//
//  ContentView.swift
//  Positive Psycology
//
//  Created by Gayatri Soni on 2/20/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Meditation for \(item.duration) minutes on  \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text("Meditation for \(item.duration) minutes on \(item.timestamp!, formatter: itemFormatter)")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        addItem()
                    }) {
                        Label("Add Meditation", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingMeditation) {
                    AddMeditationView()
            }
            .navigationBarTitle("Meditations")
        }
    }
    
    @State private var isAddingMeditation = false

    private func addItem() {
        isAddingMeditation = true
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AddMeditationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var duration = 0
    @State private var isTimerRunning = false
    @State private var timerValue = 0
    
    var formattedTime: String {
        let minutes = timerValue / 60
        let seconds = timerValue % 60
        return String(format: "%02d minutes :%02d seconds", minutes, seconds)
    }

    var body: some View {
        VStack {
            Text("Meditate Now")
                .font(.title)
                .padding()
            
            if isTimerRunning {
//                let minutes = timerValue / 60
//                let seconds = timerValue % 60
                Text(formattedTime)
                    .font(.title)
                    .padding()
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                            if timerValue  == duration * 60 {
                                timer.invalidate()
                                saveMeditation()
                            } else {
                                timerValue += 1
                            }
                        }
                    }
                Button (action: {
                    isTimerRunning = false
                }) {
                    Text ("Cancel")
                }
            } else {
                Stepper(value: $duration, in: 0...120) {
                    Text("Duration: \(duration) minutes")
                }
                
                Button (action: {
                    isTimerRunning = true
                    timerValue = 0
                }) {
                    Text("Start timer")
                }
                .padding()
                
                Button(action: {
                    saveMeditation()
                }) {
                    Text("Log without timer")
                }
                .padding()
                
                Button (action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text ("Cancel")
                }
            }
        }
        .padding()
        
        
    }

    private func saveMeditation() {
        withAnimation {
            let newMeditation = Item(context: viewContext)
            newMeditation.timestamp = Date()
            newMeditation.duration = Int16(duration)

            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

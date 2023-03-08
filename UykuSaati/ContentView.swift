//
//  ContentView.swift
//  UykuSaati
//
//  Created by Zehra Coşkun on 8.03.2023.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeUp
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    static var defaultWakeUp : Date {
        var component = DateComponents()
        component.hour = 7
        component.minute = 0
        return Calendar.current.date(from: component) ?? Date.now
        
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: 50)
            Text("UYKU VERİMİ")
                .font(.largeTitle)
                .foregroundColor(.mint)
            Form{
                Section(header: Text("Kaçta uyanmayı planlıyorsun?"), content: {
                    DatePicker("Uyanmak istediğin saat", selection: $wakeUp, displayedComponents: .hourAndMinute )
                })
                
                Section(header: Text("Kaç saat uyumayı düşünüyorsun?"),content: {
                    Stepper("\(sleepAmount.formatted()) saat", value: $sleepAmount, in: 1...12)
                })
                
                Section(header: Text("Ne kadar kahve içtin?"), content: {
                    Picker("İçtiğin kahve", selection: $coffeeAmount) {
                        ForEach (1..<11) {
                            Text("\($0) kupa")
                        }
                    }
                })
                
                Section(header: Text("Yatağa girmek için ideal saat"), content: {
                    Text(calculatedBedTime())
                })
                VStack{
                    Text("İyi bir uyku için en az bir saat öncesinde ekrana bakmayı bırakmalısın... İyi uykular...")
                        .font(/*@START_MENU_TOKEN@*/.caption/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.mint)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background(.mint)
            .cornerRadius(20)
            
            
            //.navigationTitle("Uyku Verimi")
        
        }
        
    }
    func calculatedBedTime () -> String {
        do {
            let config = MLModelConfiguration()
            let model = try UykuSaati(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hours = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hours + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            let bedTime = sleepTime.formatted(date: .omitted, time: .shortened)
            
            return bedTime
        }
        catch {
            return "HATA !"
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

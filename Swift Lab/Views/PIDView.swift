//
//  PIDView.swift
//  Swift Lab
//
//  Created by Tom Hill on 25/7/2024.
//

import SwiftUI
import Charts

/**
A PID controller continiously monitors the error between a user-specified set point
 and the current measured value.
 
 This error is used to
 
 Gain value = multiplication factor. These are values that are set by the user
 
 Proportional computed by p-gain x error (kp x error)
 Integral is i-gain x error x cycle time (delta time) and accumulating this value
 */
class PIDController {
    // p gain
    var kp: Double;
    // i gain
    var ki: Double;
    // d gain
    var kd: Double;
    
    var previousError: Double = 0;
    var integral: Double = 0;
    
    init(kp: Double, ki: Double, kd: Double) {
        self.kp = kp
        self.ki = ki
        self.kd = kd
    }
    
    /**
setPoint is the user-specified intended value for the system
measuredValue is the value we observed (AKA process value)
     */
    func compute(setPoint: Double, measuredValue: Double, deltaTime: Double) -> Double {
        let error = setPoint - measuredValue
        
        // derivative aims to "predict" where the process value is going and bias the output in the opposite direction of the proportional and integral
        let derivative = kd * (error - previousError) / deltaTime
        let proportional = kp * error;
        integral += ki * error * deltaTime
        
        let output = integral + derivative + proportional;
        
        previousError = error;
        return output
    }
    
}

struct TemperatureData: Identifiable {
    let id = UUID()
    let time: Double
    let temperature: Double
    let controlOutput: Double
    let setPoint: Double
}

struct PIDView: View {
    @State private var temperature: Double = 20.0
    @State private var setpoint: Double = 25.0
    @State private var output: Double = 0.0
    @State private var time: Double = 0.0
    @State private var temperatureData: [TemperatureData] = []
    
    @State private var kp: Double = 1.0
    @State private var ki: Double = 1.0
    @State private var kd: Double = 0.1
    
    let pid = PIDController(kp: 1.0, ki: 1.0, kd: 0.1)
    let deltaTime: Double = 0.1
    
    var body: some View {
        VStack {
            Chart(temperatureData) { data in
                LineMark(
                    x: .value("Time", data.time),
                    y: .value("Temperature", data.temperature)
                )
                .foregroundStyle(.blue)
                RuleMark(y: .value("Setpoint", self.setpoint))
                    .foregroundStyle(.red)
            }
            .frame(height: 300)
            
            Button(action: {
                temperatureData = []
                time = 0.0
            }) {
                Text("Reset")
            }
            Text("Current Temperature: \(temperature, specifier: "%.2f")°C")
            Text("Setpoint: \(setpoint, specifier: "%.2f")°C")
            Text("Control Output: \(output, specifier: "%.2f")")
            Group {
                Stepper {
                    Text("kp: \(kp, specifier: "%.2f")")
                } onIncrement: {
                    kp += 0.1
                    pid.kp = kp
                } onDecrement: {
                    kp -= 0.1
                    pid.kp = kp
                }
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(10)
                
                Stepper {
                    Text("ki: \(ki, specifier: "%.2f")")
                } onIncrement: {
                    ki += 0.1
                    pid.ki = ki
                } onDecrement: {
                    ki -= 0.1
                    pid.ki = ki
                }
                .padding()
                .background(Color.orange.opacity(0.2))
                .cornerRadius(10)
                
                Stepper {
                    Text("kd: \(kd, specifier: "%.2f")")
                } onIncrement: {
                    kd += 0.1
                    pid.kd = kd
                } onDecrement: {
                    kd -= 0.1
                    pid.kd = kd
                }
                .padding()
                .background(Color.purple.opacity(0.2))
                .cornerRadius(10)
            }.padding(.horizontal)
            
            Button(action: {
                kp = 0.0
                ki = 0.0
                kd = 0.0
                pid.kp = kp
                pid.ki = ki
                pid.kd = kd
            }) {
                Text("Zero Gains")
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            Slider(value: $setpoint, in: 0...30.0, step: 0.1) {
                Text("Set Setpoint")
            }
            .padding()
        }
        .onAppear(perform: startSimulation)
    }
    
    func startSimulation() {
        Timer.scheduledTimer(withTimeInterval: deltaTime, repeats: true) { _ in
            self.output = self.pid.compute(
                setPoint: self.setpoint,
                measuredValue: self.temperature,
                deltaTime: self.deltaTime
            )
            self.temperature += self.output * 0.1 // Multiplication simulates non-instantaneous effect
            
            self.time += self.deltaTime
            let newData = TemperatureData(
                time: self.time,
                temperature: self.temperature,
                controlOutput: self.output,
                setPoint: self.setpoint
            )
            self.temperatureData.append(newData)
        }
    }
}

#Preview {
    PIDView()
}

<p align="center">
  <img src="https://github.com/olildu/EchoNet-Frontend/blob/main/assets/images/logo/app_logo.png?raw=true" 
       alt="EchoNet Logo" 
       width="180">
</p>

# 🚀 EchoNet: Tactical Disaster Response Network

A high-performance, real-time disaster coordination and response platform built with **Flutter**. It bridges the gap between citizens in distress and volunteer responders using spatial intelligence and secure live communications.

## 📺 Demo

<p align="center">
  <img src="https://github.com/olildu/EchoNet-Frontend/blob/main/project_assets/echonet_demo.gif?raw=true" width="500">
</p>

<p align="center">
  <a href="https://youtu.be/HdIgbg-pKwM">
    ▶️ Watch Full Demo on YouTube
  </a>
</p>

## 🌟 Project Highlights & Technical Differentiators

This project showcases dual-role architecture (Citizen/Volunteer), real-time map tracking, responsive tactical UI, and event-driven state management.

| Feature | Technical Implementation | Engineering Value Demonstrated |
| :--- | :--- | :--- |
| **Real-Time Tactical Mesh** | **Flutter BLoC** + **WebSockets** (`LocationTrackingBloc`, `WebSocketService`) | Live personnel tracking, asynchronous event buses, scalable pub/sub architecture. |
| **Spatial Intelligence** | **MapBloc** with custom coordinate projection (`MapsScreen`, `VolunteerMapsScreen`) | Complex UI rendering based on geolocation data, independent of heavy third-party map SDKs. |
| **Live Mission Control** | **TaskBloc** and **AvailableTasksBloc** for real-time mission updates | Dynamic task lifecycle management (Accept, En Route, On Scene, Complete). |
| **Responsive Tactical UI** | Built using **ScreenUtil** and a custom `TacticalTheme` | Highly stylized, dark-mode-first interfaces ensuring consistent rendering across all device sizes. |

## 🧱 Architecture Overview: BLoC Pattern

The project strictly follows the **BLoC Architecture**, separating the UI from business logic to ensure testability and robust state management.

### **App Entry (`main.dart`)**
- Initializes global blocs and repositories using `MultiBlocProvider` and `MultiRepositoryProvider`.
- Handles role-based initial routing, seamlessly directing users to either `/citizen_dashboard` or `/volunteer_dashboard` based on persistent session data.
- Core blocs loaded here include: `LoginBloc`, `IncidentBloc`, `TaskBloc`, and `LocationTrackingBloc`.

### **BLoC Layer (Logic)**
- **IncidentBloc** — Handles emergency SOS broadcasts and evidence image picking.
- **ChatBloc** — Manages secure communication logs and real-time message streams via WebSocket triggers.
- **AvailableTasksBloc** — Maintains a live feed of active incidents and handles client-side filtering for declined missions.

### **Data Layer (Services / Models)**
- **ApiClient** — A robust wrapper for HTTP operations (GET, POST, PUT, Multipart Uploads) to the backend.
- **SessionManager** — Handles secure local storage of JWT tokens, User IDs, and Roles using `SharedPreferences`.
- **WebSocketService** — Manages persistent socket connections and provides a broadcast stream for multiple BLoC listeners.

## ⚙️ Core Modules & Components

| Module | Purpose | Key Files |
| :--- | :--- | :--- |
| **Auth & Identity** | Dual-flow registration for Citizens and Volunteers (with skill selection). | `login_screen.dart`, `registration_bloc.dart`. |
| **Incident Reporting** | Form for creating SOS broadcasts with priorities and field intelligence photos. | `report_emergency_screen.dart`, `incident_bloc.dart`. |
| **Tactical Radar Maps** | Visualizes live incidents and tracks active volunteer locations. | `maps_screen.dart`, `volunteer_maps_screen.dart`. |
| **Reusable UI Kit** | Custom-styled components designed for the tactical aesthetic. | `tactical_button.dart`, `tactical_text_field.dart`, `tactical_card.dart`. |


## 🛠 Deep Technical Deep-Dive

### 📡 The Tactical Mesh: Real-Time Event Bus
EchoNet avoids traditional, "heavy" polling by utilizing a centralized WebSocket Service that acts as a global event bus.

**Infrastructure:**  
When a backend state change occurs (e.g., a new SOS broadcast or a secure message), the FastAPI server pushes a lightweight JSON signal through the persistent socket.

**Reactive UI:**  
Multiple Flutter BLoCs (`AvailableTasks`, `Chat`, `LocationTracking`) subscribe to this single broadcast stream simultaneously. This architecture ensures that data remains synchronized across all active devices in under 50ms without draining the user's battery with constant HTTP requests.


### 🗺 Spatial Intelligence & Coordinate Projection
Unlike standard consumer apps that rely on heavy Map SDKs, EchoNet features a custom Map Projection Engine.

**The Math:**  
The `MapBloc` utilizes a linear projection algorithm to convert raw GPS Latitude/Longitude coordinates into precise pixel offsets on the UI's tactical radar grid.

**Visual Fidelity:**  
This allows for custom-rendered tactical icons, pulse animations for personnel tracking, and sector-based filtering that remains fast and responsive even on low-end hardware.


### 🛡 Hybrid Lifecycle Management
EchoNet manages a complex "Dual-Actor" mission lifecycle through a robust state machine implemented via Flutter BLoC.

**State Integrity:**  
A mission moves through:  
`PENDING ➔ ACCEPTED ➔ EN_ROUTE ➔ ON_SCENE ➔ COMPLETED`

**Native Integration:**  
The system seamlessly switches between the EchoNet internal mesh and external tactical tools. For example, clicking **"Start Mission"** triggers a native deep-link into Google or Apple Maps for precise GPS navigation while maintaining the internal mission state.


### 📸 Field Intelligence & Evidence Handling
Information accuracy is critical in disasters. EchoNet supports instant field intelligence through multipart evidence uploads.

**Transmission:**  
Reporters can capture and upload live scene photos which are processed and served as static assets by the FastAPI backend.

**Tactical Overlay:**  
Responders receive these images with a **"Field Intelligence" overlay**, providing immediate visual context of the emergency before they arrive on-scene.


## 🛠️ Development Setup

Requires **Flutter 3.x**.

### **Prerequisites**
- Flutter SDK installed.
- Working emulator or connected device.
- EchoNet FastAPI backend running locally (configured to `192.168.137.1` by default).

### **Installation**

```bash
git clone https://github.com/olildu/echonet-frontend.git
cd echonet-frontend
flutter pub get
flutter run
```


# 📱 Live Beta Testing

The application supports distinct user experiences based on the registered role.

## 🧪 Test Credentials

To explore the coordination features, create two separate accounts using the registration flow with the following roles:


## 🛡️ Role: CITIZEN

**Use Case:**
- Access the SOS dashboard  
- Report emergencies  
- View live incident history  



## 🚁 Role: VOLUNTEER

**Use Case:**
- View the tactical deployment map  
- Accept active missions  
- Use the secure communications channel  



## 🚀 Getting Started

1. Register a new account via the app.
2. Select a role (**Citizen** or **Volunteer**).
3. Repeat the process to create a second account with the alternate role.
4. Use both accounts to simulate real-time coordination.


## ⚠️ Notes

- Ensure both accounts are active simultaneously for full feature testing.
- Recommended to use separate devices or browsers for each role.



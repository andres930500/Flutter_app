# RealMe

Aplicación móvil de **finanzas personales** desarrollada con **Flutter y Dart**, que integra **inteligencia artificial** para generar recomendaciones financieras con enfoque ecológico, promoviendo un consumo responsable y sostenible.

---

## 💡 Descripción del proyecto

**RealMe** es una aplicación móvil multiplataforma enfocada en la **gestión de finanzas personales**, que permite a los usuarios visualizar su información financiera, controlar gastos y recibir **recomendaciones ecológicas inteligentes** basadas en su comportamiento de consumo.

En su versión actual, la aplicación integra **inteligencia artificial mediante el modelo Gemini 1.1**, utilizado para analizar información financiera y generar recomendaciones orientadas a un consumo más consciente y sostenible.

---

## 🎯 Objetivo del proyecto

Desarrollar una aplicación móvil que combine:

- Gestión financiera personal
- Inteligencia artificial aplicada a finanzas
- Recomendaciones ecológicas
- Arquitectura moderna y escalable
- Integración entre frontend móvil y backend externo

El proyecto busca demostrar la integración real de **Flutter + IA + servicios backend**, más allá de una aplicación básica.

---

## ✨ Funcionalidades implementadas

- Visualización de información financiera del usuario
- Control de gastos y saldo disponible
- Generación de **alertas** cuando el usuario está próximo a consumir el saldo límite
- Recomendaciones ecológicas personalizadas basadas en el consumo
- Integración de **inteligencia artificial (Gemini 1.1)** para análisis y recomendaciones
- Consumo de endpoints backend desarrollados en **.NET**
- Arquitectura preparada para escalar y añadir nuevas funcionalidades

---

## 🤖 Inteligencia Artificial

La aplicación integra **Gemini 1.1** en su versión actual para:

- Analizar patrones de consumo
- Generar recomendaciones financieras
- Promover decisiones de gasto más responsables y ecológicas

Esta es la **primera versión** de la implementación de IA dentro del proyecto, sentando las bases para mejoras futuras en modelos y análisis más avanzados.

---

## 🧠 Arquitectura del sistema

El sistema sigue una arquitectura distribuida:

### 📱 Frontend (Mobile)
- Desarrollado en **Flutter**
- Lenguaje **Dart**
- Manejo de UI, estados y experiencia de usuario
- Consumo de servicios externos mediante HTTP

### 🖥 Backend
- Endpoints desarrollados en **.NET**
- Encargados de la lógica de negocio y gestión de datos
- Publicados en un repositorio independiente

Esta separación permite:
- Escalabilidad
- Independencia entre frontend y backend
- Facilidad de mantenimiento y evolución del sistema

---

## 🛠 Tecnologías utilizadas

### Mobile
- **Flutter**
- **Dart**
- Arquitectura por capas
- Widgets personalizados
- Manejo de estados
- Navegación Flutter

### Backend
- **.NET**
- API REST
- Endpoints consumidos desde la aplicación móvil

### Inteligencia Artificial
- **Gemini 1.1**
- Generación de recomendaciones inteligentes

### Otras herramientas
- Git & GitHub
- Visual Studio Code
- Android Studio
- Postman (pruebas de endpoints)

---

## 📂 Estructura del proyecto (Flutter)

lib/
├── data/
├── domain/
├── features/
├── presentation/
├── utils/
└── main.dart


---

## ▶️ Ejecución del proyecto

### Requisitos
- Flutter SDK
- Android Studio o VS Code
- Dispositivo físico o emulador
- Conexión a internet

### Pasos
```bash
flutter pub get
flutter run

📌 Estado del proyecto

🚧 Versión 1 – Funcional
La aplicación cuenta con integración inicial de IA y backend, con una base sólida para evolución futura.

🚀 Posibles mejoras futuras

Análisis financiero más avanzado con IA

Nuevos modelos de recomendación

Persistencia local de datos

Autenticación de usuarios

Gráficas financieras avanzadas

Optimización del sistema de alertas

👨‍💻 Autor

Andrés González
Ingeniería Informática – Universidad de Caldas


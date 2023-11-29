# Proyecto Informático - EventiCAA

Proyecto realizado para el ramo Proyecto Informático.

## Requisitos previos 📋

Se deben tener instaladas o instalar y configurar los siguientes programas:
- Node.js
- Flutter
- Android Studio (para ejecutar en android)
- Xcode (para ejecutar en iOS)

## Configuración 💽

Se debe clonar este repositorio en su sistema y seguir los siguientes pasos.

### Backend 🗄️

ir a la carpeta backend y ejecutar los siguientes pasos:

1. Instalar los módulos necesarios con el siguiente comando:
    ```
    npm install
    ```

2. Copiar el archivo `.env.example` y renómbrarlo a `.env`.

3. Dentro del archivo `.env`, se añade el enlace de tu base de datos MongoDB a la variable `MONGODB_URI`.

### Frontend 📱

Ir a la carpeta frontend y ejecutar el siguiente paso:

1. Instalar las dependencias con el comando:
   ```
   flutter pub get
   ```

## Ejecución ▶️

Una vez completada la configuración, se debe ejecutar el servidor con el comando:
    
    npm run dev

Finalmente se puede ejecutar la aplicación con el comando:

    flutter run
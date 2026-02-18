# 🚀 SoccerLife - Documentación Completa

## 📋 Estructura del Proyecto

### Backend (Node.js + Express + MongoDB)

```
backend/
├── controllers/
│   ├── partidos/
│   │   ├── partidosController.js          # CRUD de partidos
│   │   └── partidosActualizarController.js  # Actualizar y registrar resultados
│   ├── entrenamientos/
│   │   ├── entrenamientosController.js      # CRUD de entrenamientos
│   │   └── entrenamientosActualizarController.js  # Actualizar y completar
│   ├── loginController.js                # Login con JWT
│   ├── usuarioController.js              # Gestión de usuarios
│   ├── recuperarController.js            # Recuperación de contraseña
│   ├── estadisticasController.js         # Estadísticas del jugador
│   └── logrosController.js               # Sistema de logros/achievements
├── models/
│   ├── Usuario.js                        # Modelo de usuario
│   ├── Partido.js                        # Modelo de partido
│   ├── Entrenamiento.js                  # Modelo de entrenamiento
│   ├── Estadistica.js                    # Modelo de estadísticas
│   ├── Logro.js                          # Modelo de logros
│   └── UsuarioLogro.js                   # Relación usuario-logro
├── middleware/
│   └── auth.js                           # Middleware de autenticación JWT
├── routes/
│   ├── usuarios.js                       # Rutas de usuarios
│   ├── partidos.js                       # Rutas de partidos
│   ├── entrenamientos.js                 # Rutas de entrenamientos
│   ├── estadisticas.js                   # Rutas de estadísticas
│   └── logros.js                         # Rutas de logros
├── services/
│   ├── emailService.js                   # Servicio de correo
│   └── tokenService.js                   # Servicio de tokens JWT
└── scripts/
    └── inicializarLogros.js              # Script para crear logros

```

### Frontend (Flutter)

```
lib/
├── login/
│   ├── iniciosesion.dart                 # Pantalla de login
│   ├── registrarse.dart                  # Pantalla de registro
│   └── recuperar.dart                    # Recuperación de contraseña
├── pantallas/
│   ├── principal.dart                    # Dashboard principal
│   ├── perfil.dart                       # Perfil del usuario
│   ├── editarperfil.dart                 # Editar perfil
│   ├── estadisticas.dart                 # Estadísticas del jugador
│   ├── logros.dart                       # Logros desbloqueados
│   ├── partidos/
│   │   ├── partidosfuturos.dart          # Partidos programados
│   │   └── partidosjugados.dart          # Historial de partidos
│   └── entrenamientos/
│       ├── proximos.dart                 # Entrenamientos próximos
│       └── anteriores.dart               # Historial de entrenamientos
└── services/
    ├── api_config.dart                   # Configuración de API
    ├── auth_service.dart                 # ✨ Servicio de autenticación
    ├── storage_service.dart              # ✨ Almacenamiento local
    ├── partidos_service.dart             # ✨ API de partidos
    ├── partidos_resultado_service.dart   # ✨ Registrar resultados
    ├── entrenamientos_service.dart       # ✨ API de entrenamientos
    ├── estadisticas_service.dart         # ✨ API de estadísticas
    ├── logros_service.dart               # ✨ API de logros
    ├── user_login.dart                   # Login (legacy)
    ├── user_registration.dart            # Registro (legacy)
    └── user_recuperar.dart               # Recuperación (legacy)
```

## 🔧 Configuración Inicial

### 1. Backend

```bash
cd backend

# Instalar dependencias
npm install

# Inicializar logros en la base de datos
node scripts/inicializarLogros.js

# Iniciar servidor
npm start
```

### 2. Frontend

```bash
# Instalar dependencias
flutter pub get

# Ejecutar app
flutter run -d windows
```

## 🔑 Autenticación JWT

### Flujo de Autenticación

1. **Login**: Usuario ingresa credenciales → Backend genera token JWT → Token se guarda en `shared_preferences`
2. **Peticiones**: Todas las peticiones autenticadas incluyen header: `Authorization: Bearer <token>`
3. **Logout**: Elimina token y datos del usuario del almacenamiento local

### Uso en Flutter

```dart
// Login
final resultado = await AuthService.login(
  email: 'usuario@ejemplo.com',
  password: 'password123',
);

// Verificar autenticación
bool autenticado = await AuthService.estaAutenticado();

// Obtener headers autenticados (auto-incluye token)
final headers = await AuthService.obtenerHeadersAutenticados();

// Logout
await AuthService.logout();
```

## 📊 Endpoints Disponibles

### Partidos

```
POST   /api/partidos                    # Crear partido
GET    /api/partidos/futuros            # Obtener partidos próximos
GET    /api/partidos/jugados            # Obtener partidos jugados
PUT    /api/partidos/:id                # Actualizar partido
PUT    /api/partidos/:id/resultado      # Registrar resultado
DELETE /api/partidos/:id                # Eliminar partido
```

### Entrenamientos

```
POST   /api/entrenamientos              # Crear entrenamiento
GET    /api/entrenamientos/proximos     # Obtener próximos
GET    /api/entrenamientos/anteriores   # Obtener completados
PUT    /api/entrenamientos/:id          # Actualizar
PUT    /api/entrenamientos/:id/completar # Marcar como completado
DELETE /api/entrenamientos/:id          # Eliminar
```

### Estadísticas

```
GET    /api/estadisticas                # Obtener estadísticas del usuario
```

### Logros

```
GET    /api/logros/mis-logros           # Obtener logros con progreso
POST   /api/logros/verificar            # Verificar nuevos logros
```

## 🎯 Características Implementadas

### ✅ Completamente Funcional

- Autenticación JWT
- Registro de usuarios
- Recuperación de contraseña
- Gestión de partidos (CRUD)
- Gestión de entrenamientos (CRUD)
- Sistema de estadísticas automáticas
- Sistema de logros con progreso
- Almacenamiento persistente de sesión
- Arquitectura modular (archivos < 200 líneas)

### 🔄 Próximas Mejoras Sugeridas

- Hash de contraseñas con `bcrypt`
- Refresh tokens
- Paginación en listados
- Filtros avanzados
- Notificaciones push para logros
- Gráficas de estadísticas
- Exportar estadísticas a PDF

## 📝 Notas Importantes

### Variables de Entorno (.env)

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/soccerlife
JWT_SECRET=secret_key_soccerlife_2026
JWT_EXPIRES_IN=7d
```

### Configuración de IP (Flutter)

En `lib/services/api_config.dart`:

```dart
// Para desarrollo local
static const String _localhost = '127.0.0.1:3000';

// Para otros dispositivos en la misma red
static const String _casaIP = '192.168.1.44:3000';
```

## 🐛 Solución de Problemas Comunes

### Error: "Cannot send Null"
**Solución**: Es un bug de Flutter Windows con hot reload. Usa Hot Restart (`Shift + R`) o reinicia la app.

### Error: "Connection refused"
**Solución**: Verifica que el backend esté corriendo (`npm start`) y que la IP en `api_config.dart` sea correcta.

### Sin logros en la app
**Solución**: Ejecuta `node scripts/inicializarLogros.js` para crear los logros en la base de datos.

## 📚 Dependencias

### Backend
- express: ^5.1.0
- mongoose: ^8.19.1
- jsonwebtoken: ^9.0.2
- cors: ^2.8.5
- nodemailer: ^7.0.9
- dotenv: ^17.2.3

### Frontend
- http: ^1.1.0
- shared_preferences: ^2.2.3
- provider: ^6.1.2
- image_picker: ^1.0.4

## 👨‍💻 Desarrollado con

- Backend: Node.js + Express + MongoDB
- Frontend: Flutter + Dart
- Autenticación: JWT
- Arquitectura: Modular y escalable

---

**¡Todo listo para usar! 🎉**

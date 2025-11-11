# 📋 INSTRUCCIONES - CRUD USUARIOS SOCCERLIFE

## 🚀 CÓMO USAR EL PANEL ADMINISTRATIVO

### 📁 **Archivos Creados:**
- `admin-usuarios.html` - Panel de administración completo

### 🔧 **Configuración Inicial:**

1. **Asegúrate que tu backend esté corriendo:**
   ```bash
   cd backend
   npm start
   ```

2. **Abre el archivo HTML:**
   - Navega a: `Validaciones_Mongodb/Crud de colecciones/admin-usuarios.html`
   - Ábrelo con tu navegador web
   - O usa Live Server en VS Code

### ⚡ **FUNCIONALIDADES DISPONIBLES:**

#### ✅ **1. CREAR USUARIOS**
- Llena el formulario "Crear Nuevo Usuario"
- Campos obligatorios: Nombre, Email, Contraseña
- Campos opcionales: Posición, Número, Teléfono, Club, Edad, Estatura, Peso
- Haz clic en "💾 Crear Usuario"

#### 🔍 **2. BUSCAR USUARIOS**
- Usa la barra de búsqueda para filtrar por:
  - Nombre
  - Email  
  - Club
  - Posición
- Presiona Enter o botón "Buscar"
- Usa "Ver Todos" para mostrar todos los usuarios

#### ✏️ **3. EDITAR USUARIOS**
- Haz clic en "✏️ Editar" en la tabla
- El formulario se llena automáticamente
- Modifica los datos necesarios
- Haz clic en "💾 Actualizar Usuario"
- Usa "❌ Cancelar" para salir del modo edición

#### 🗑️ **4. ELIMINAR USUARIOS**
- Haz clic en "🗑️ Eliminar" en la tabla
- Confirma la eliminación en el diálogo
- El usuario se marca como inactivo (soft delete)

### 🎨 **CARACTERÍSTICAS DEL DISEÑO:**

#### 📱 **Responsive**
- Funciona en desktop y móviles
- Tabla adaptable
- Formularios optimizados

#### 🎯 **UX/UI**
- Colores temáticos de fútbol (verde)
- Iconos descriptivos
- Mensajes de confirmación
- Estados de carga
- Animaciones suaves

#### 🔒 **Validaciones**
- Campos requeridos marcados con *
- Validación de tipos de datos
- Límites de edad, peso, estatura
- Email único en el sistema

### 🛠️ **CONFIGURACIÓN TÉCNICA:**

#### 📡 **API Endpoints Utilizados:**
- `GET /api/usuarios` - Listar todos
- `GET /api/usuarios/:id` - Obtener uno por ID
- `POST /api/usuarios` - Crear nuevo
- `PUT /api/usuarios/:id` - Actualizar
- `DELETE /api/usuarios/:id` - Eliminar (soft delete)

#### 🔧 **URL de la API:**
Por defecto está configurada para `http://localhost:3000/api/usuarios`

Si necesitas cambiarla, modifica la variable `API_URL` en el JavaScript del HTML.

### ⚠️ **NOTAS IMPORTANTES:**

1. **Backend Requerido:** El panel necesita que tu backend Node.js esté funcionando
2. **CORS:** Ya configurado en tu backend para permitir conexiones
3. **Soft Delete:** Los usuarios eliminados solo se marcan como inactivos, no se borran físicamente
4. **Contraseñas:** En modo edición, deja la contraseña vacía si no quieres cambiarla

### 🐛 **SOLUCIÓN DE PROBLEMAS:**

#### ❌ **Error de conexión:**
- Verifica que el backend esté corriendo en puerto 3000
- Comprueba la URL de la API en el código
- Revisa la consola del navegador para errores

#### 📊 **No aparecen usuarios:**
- Verifica que tengas usuarios en la base de datos
- Comprueba que los usuarios tengan `activo: true`

#### 🔄 **Problemas de CORS:**
- Tu backend ya tiene CORS configurado
- Si persiste, verifica la configuración en `backend/index.js`

---

## 🎉 **¡LISTO PARA USAR!**

Ahora tienes un panel de administración completo para gestionar todos los usuarios de SoccerLife de forma visual e intuitiva.

# Guia generica para implementar una app Flutter con Supabase y despliegue por GitHub

Esta guia sirve como documento base para crear una nueva aplicacion movil con el mismo tipo de stack tecnologico: Flutter para la app, Supabase para backend/base de datos/funciones, GitHub Actions para despliegues y APK Android firmado para distribucion.

El documento es intencionadamente generico. Sustituir los nombres de ejemplo, secretos, package IDs, URLs y rutas por los de la nueva aplicacion.

## 1. Objetivo

Crear una aplicacion multiplataforma basada en:

- App movil Android creada con Flutter/Dart.
- Posible soporte web o escritorio si el producto lo necesita.
- Backend gestionado en Supabase Cloud.
- Base de datos PostgreSQL con migraciones versionadas.
- Autenticacion con Supabase Auth.
- Reglas de seguridad con Row Level Security.
- Archivos privados con Supabase Storage.
- Logica backend en Supabase Edge Functions.
- Trabajos asincronos mediante tablas de jobs, RPCs y workers.
- Actualizaciones en tiempo real con Supabase Realtime.
- CI/CD con GitHub Actions.
- APK release firmado publicado en GitHub Releases.

## 2. Arquitectura recomendada

### 2.1 Frontend

Usar Flutter como cliente principal.

Responsabilidades del cliente:

- Inicializar Supabase con `SUPABASE_URL` y `SUPABASE_ANON_KEY`.
- Gestionar login, registro, cierre de sesion y estado del usuario.
- Mostrar la UI principal de la aplicacion.
- Leer y escribir datos permitidos por RLS.
- Subir archivos a Supabase Storage cuando aplique.
- Invocar Edge Functions para operaciones que requieran backend.
- Escuchar cambios en tiempo real si la experiencia lo necesita.
- Registrar errores no sensibles para diagnostico.

El cliente nunca debe contener:

- `service_role`.
- Secretos de proveedores externos.
- Passwords de base de datos.
- Keystores Android.
- Tokens privados de CI/CD.

### 2.2 Backend

Usar Supabase como backend principal.

Componentes recomendados:

- PostgreSQL para datos persistentes.
- Migraciones SQL en `supabase/migrations/`.
- RLS activado en todas las tablas expuestas.
- RPCs para consultas o mutaciones complejas.
- Storage privado para archivos de usuario.
- Edge Functions en `supabase/functions/`.
- Realtime para pantallas que deban actualizarse sin refrescar.
- Cron o workers para tareas recurrentes o en segundo plano.

### 2.3 Edge Functions

Las Edge Functions deben resolver logica que no pertenece al cliente:

- Operaciones con secretos.
- Integraciones con APIs externas.
- Procesamiento de archivos.
- Trabajos asincronos.
- Envio de notificaciones.
- Tareas administrativas validadas.
- Flujos que necesiten idempotencia.

Estructura recomendada:

```text
supabase/functions/
|-- nombre-funcion/
|   `-- index.ts
`-- _shared/
    |-- domain/
    |-- application/
    |-- ports/
    `-- adapters/
```

Separacion sugerida:

- `domain`: reglas puras y modelos de negocio.
- `application`: casos de uso y orquestacion.
- `ports`: contratos para base de datos, storage, proveedores externos y logging.
- `adapters`: implementaciones concretas con Supabase, APIs externas y Deno.
- `index.ts`: validacion HTTP, autenticacion, llamada al caso de uso y respuesta.

## 3. Estructura base del repositorio

```text
.
|-- lib/
|   `-- main.dart
|-- android/
|-- web/
|-- assets/
|-- test/
|-- integration_test/
|-- supabase/
|   |-- migrations/
|   `-- functions/
|       `-- _shared/
|-- .github/
|   `-- workflows/
|       |-- checks.yml
|       |-- supabase-deploy.yml
|       |-- android-release-apk.yml
|       `-- nightly-android-e2e.yml
|-- pubspec.yaml
|-- README.md
|-- OPERACION.md
`-- DOCUMENTACION.md
```

Documentos recomendados:

- `README.md`: resumen publico del proyecto.
- `DOCUMENTACION.md`: arquitectura, modulos, modelo de datos y decisiones funcionales.
- `OPERACION.md`: comandos, despliegues, secretos, validaciones y mantenimiento.
- Este documento o una variante: guia del stack reutilizable.

## 4. Configuracion de entorno

Variables publicas para Flutter:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
APP_TIME_ZONE
```

Secretos backend o CI/CD:

```text
SUPABASE_ACCESS_TOKEN
SUPABASE_PROJECT_ID
SUPABASE_DB_PASSWORD
SERVICE_ROLE_KEY
WORKER_SECRET
ANDROID_RELEASE_KEYSTORE_BASE64
ANDROID_RELEASE_KEYSTORE_PASSWORD
ANDROID_RELEASE_KEY_ALIAS
ANDROID_RELEASE_KEY_PASSWORD
```

Reglas:

- Las variables publicas pueden llegar al cliente.
- Los secretos solo deben vivir en Supabase, GitHub Secrets o entorno local seguro.
- No commitear `.env`, keystores, `key.properties`, certificados ni passwords.
- Mantener archivos `.example` para documentar la forma esperada de configuracion.

## 5. Supabase

### 5.1 Base de datos

Crear todo cambio de esquema mediante migraciones SQL:

```text
supabase/migrations/
```

Buenas practicas:

- Una migracion debe ser pequena, revisable y con nombre descriptivo.
- Activar RLS en tablas expuestas.
- Crear politicas por usuario, organizacion, workspace o tenant, segun el modelo.
- Evitar `SECURITY DEFINER` salvo que haya una razon clara y revisada.
- Usar indices para claves foraneas, filtros frecuentes y busquedas.
- Separar datos de usuario de datos operativos internos cuando convenga.

Patrones utiles:

- Tabla principal de entidades.
- Tabla de perfiles o preferencias por usuario.
- Tabla de pertenencia a workspace/organizacion si hay multi-tenant.
- Tablas de jobs para trabajos asincronos.
- Tablas de logs operativos sin guardar datos sensibles.
- RPCs para operaciones que requieran consistencia, bloqueo o consultas complejas.

### 5.2 Auth

Flujos recomendados:

- Email/password.
- OAuth solo si el producto lo necesita.
- Recuperacion de contrasena.
- Sesion persistente en cliente.

Reglas:

- No basar permisos en `user_metadata` editable por el usuario.
- Para autorizacion, usar datos propios de tablas protegidas o `app_metadata`.
- Las politicas RLS deben comprobar propiedad real de filas.

### 5.3 Storage

Usar buckets privados para archivos de usuario.

Recomendaciones:

- Separar rutas por usuario o tenant.
- Guardar metadatos del archivo en tablas.
- Procesar archivos desde Edge Functions.
- No exponer URLs publicas permanentes para contenido privado.
- Usar signed URLs cuando se necesite acceso temporal.

### 5.4 Realtime

Usar Realtime para:

- Chat.
- Jobs en progreso.
- Notificaciones.
- Cambios de estado visibles por el usuario.
- Dashboards o paneles vivos.

Aplicar Realtime solo donde aporte valor. Para datos estaticos, una consulta normal suele ser suficiente.

## 6. Trabajos asincronos

Para procesos largos o sensibles a reintentos, usar tablas de jobs.

Campos recomendados:

```text
id
user_id
workspace_id
status
payload
result
error_message
attempt_count
locked_at
locked_by
created_at
updated_at
completed_at
```

Estados habituales:

```text
pending
processing
completed
failed
cancelled
```

Reglas:

- Reclamar jobs con bloqueo transaccional.
- Evitar duplicados con claves idempotentes.
- Registrar errores de forma util, sin secretos ni datos personales extensos.
- Hacer workers reintentables.
- Separar el efecto visible al usuario del procesamiento interno.

## 7. GitHub Actions

### 7.1 Checks de pull request

Workflow recomendado:

```text
.github/workflows/checks.yml
```

Debe ejecutar:

- Instalacion de Flutter.
- `flutter pub get`.
- Formato o verificacion de formato.
- `flutter analyze`.
- `flutter test`.
- Validaciones especificas de migraciones o arquitectura.
- Escaneo basico para evitar secretos en frontend.

### 7.2 Deploy de Supabase

Workflow recomendado:

```text
.github/workflows/supabase-deploy.yml
```

Disparadores:

- Push a `main` con cambios en `supabase/**`.
- Cambio del propio workflow.
- Ejecucion manual con `workflow_dispatch`.

Pasos:

1. Checkout del repositorio.
2. Instalar Supabase CLI con version fijada.
3. Enlazar proyecto usando `SUPABASE_PROJECT_ID`.
4. Ejecutar `supabase db push`.
5. Desplegar Edge Functions.

Secrets requeridos:

```text
SUPABASE_ACCESS_TOKEN
SUPABASE_PROJECT_ID
SUPABASE_DB_PASSWORD
```

Regla principal:

- El despliegue de backend debe hacerse por commit y push a `main`, no por cambios manuales sueltos desde local.

### 7.3 APK Android release

Workflow recomendado:

```text
.github/workflows/android-release-apk.yml
```

Debe poder ejecutarse:

- Manualmente con `workflow_dispatch`.
- Opcionalmente con tags `v*`.
- Opcionalmente en push a `main` cuando cambie codigo movil.

Debe hacer:

1. Checkout.
2. Instalar Flutter.
3. Restaurar dependencias.
4. Decodificar keystore desde `ANDROID_RELEASE_KEYSTORE_BASE64`.
5. Crear configuracion temporal de firma.
6. Compilar APK release.
7. Calcular checksum SHA-256.
8. Crear o actualizar GitHub Release.
9. Subir APK versionado.
10. Subir APK con nombre estable, por ejemplo `app-android-latest.apk`.
11. Subir archivo `.sha256`.

Secrets requeridos:

```text
ANDROID_RELEASE_KEYSTORE_BASE64
ANDROID_RELEASE_KEYSTORE_PASSWORD
ANDROID_RELEASE_KEY_ALIAS
ANDROID_RELEASE_KEY_PASSWORD
SUPABASE_URL
SUPABASE_ANON_KEY
```

Reglas para actualizaciones Android:

- Mantener el mismo `applicationId`.
- Firmar siempre con la misma clave release.
- Incrementar siempre `versionCode`.
- Cambiar `versionName` para version visible.
- Si una app instalada fue firmada con otra clave, Android exigira desinstalar antes de instalar la nueva.

## 8. Flutter Android

Configuracion clave:

- Definir `applicationId` definitivo desde el inicio.
- Configurar versionado con `versionCode` y `versionName`.
- Preparar firma release mediante Gradle y secrets.
- Mantener `android/key.properties.example`.
- No commitear `android/key.properties`.
- Revisar permisos Android reales que necesita el producto.
- Validar deep links, OAuth redirects y permisos en dispositivo real.

Comandos locales frecuentes:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

Ejemplo de build con variables:

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<anon-key> --dart-define=APP_TIME_ZONE=<zona>
```

## 9. Observabilidad

Crear una estrategia minima de logs:

- Logs de cliente para errores no sensibles.
- Logs de Edge Functions.
- Tabla de logs operativos si se necesita diagnostico desde la app o el panel interno.
- Logs de CI/CD como artifacts de GitHub Actions.

No guardar en logs:

- Secretos.
- Tokens.
- Passwords.
- Documentos completos.
- Datos personales innecesarios.
- Respuestas completas de proveedores externos si contienen informacion sensible.

Campos recomendados para logs:

```text
id
created_at
level
source
area
message
metadata
user_id
function_name
workflow
job
```

## 10. Testing y validacion

Checks minimos antes de cerrar cambios:

```powershell
flutter analyze
flutter test
git diff --check
```

Validar tambien:

- Migraciones SQL cuando haya cambios de base de datos.
- RLS y permisos cuando haya datos de usuario.
- Edge Functions cuando haya backend.
- Android real cuando cambien permisos, auth, storage, notificaciones o instalacion.
- GitHub Actions despues de push a `main`.
- GitHub Releases cuando se publique APK.

Tests recomendados:

- Tests unitarios Flutter.
- Tests de widgets importantes.
- Tests de contratos para Edge Functions.
- Tests de reglas puras de dominio.
- Tests de migraciones o SQL critico.
- Integration tests Android para flujos principales.

## 11. Flujo de implementacion recomendado

1. Crear repositorio GitHub.
2. Crear proyecto Supabase.
3. Inicializar app Flutter.
4. Configurar `SUPABASE_URL` y `SUPABASE_ANON_KEY`.
5. Crear estructura `supabase/migrations/` y `supabase/functions/`.
6. Definir modelo minimo de usuario/datos.
7. Activar RLS desde la primera migracion.
8. Implementar autenticacion en Flutter.
9. Implementar primera pantalla conectada a Supabase.
10. Crear workflow de checks.
11. Crear workflow de deploy Supabase.
12. Crear firma Android release.
13. Configurar secrets en GitHub.
14. Crear workflow de APK release.
15. Publicar primera release interna.
16. Validar instalacion y actualizacion en Android.
17. Documentar operacion y mantenimiento.

## 12. Checklist de seguridad

- RLS activado en tablas expuestas.
- Politicas con ownership real, no solo `TO authenticated`.
- `UPDATE` con `USING` y `WITH CHECK`.
- Frontend solo usa claves publicas.
- `service_role` solo en backend seguro.
- Buckets privados para contenido de usuario.
- Signed URLs con expiracion para archivos privados.
- Edge Functions validan autenticacion y propiedad.
- Workers son idempotentes.
- Logs sin secretos ni contenido sensible.
- GitHub Secrets configurados sin duplicarlos en archivos.
- Keystore release fuera del repositorio.
- Dependencias y lockfiles commiteados.

## 13. Checklist de despliegue

- `main` protegido o con revision antes de merge.
- Workflow de checks pasando.
- Workflow de Supabase deploy configurado.
- Supabase CLI con version fijada en CI.
- Secrets de Supabase configurados.
- Edge Functions desplegadas desde GitHub Actions.
- Migraciones aplicadas por CI.
- Workflow Android release configurado.
- Firma release establecida.
- `versionCode` monotonicamente creciente.
- APK y checksum publicados en GitHub Releases.
- Instalacion Android validada.
- Actualizacion Android validada con una version superior.

## 14. Plantilla de documentos operativos

Para la nueva app, mantener estos documentos desde el principio:

```text
DOCUMENTACION.md
OPERACION.md
README.md
```

Contenido minimo de `DOCUMENTACION.md`:

- Resumen del producto.
- Stack tecnologico.
- Arquitectura.
- Modulos funcionales.
- Modelo de datos.
- Edge Functions.
- Seguridad.
- Testing.
- Deploy.

Contenido minimo de `OPERACION.md`:

- Ruta local del repositorio.
- Version de Flutter.
- Comandos frecuentes.
- Variables de entorno.
- Secrets requeridos.
- Web local si aplica.
- Android local.
- Supabase deploy.
- APK release.
- Validacion por tipo de cambio.
- Checklist antes de publicar.

## 15. Decisiones que deben fijarse antes de empezar

- Nombre de la app.
- `applicationId` Android.
- Repositorio GitHub.
- Proyecto Supabase de desarrollo.
- Proyecto Supabase de produccion, si se separan entornos.
- Estrategia de tenants: usuario simple, workspace u organizacion.
- Metodo de autenticacion.
- Buckets de Storage.
- Edge Functions iniciales.
- Politica de releases Android.
- Version inicial `versionName` y `versionCode`.
- Lista de secrets de GitHub.

## 16. Principio final

El stack debe tratar a GitHub como la fuente de despliegue, Supabase como contrato backend, Flutter como cliente publico y Android release signing como identidad estable de instalacion. Cualquier dato secreto debe quedar fuera del cliente y fuera del repositorio.

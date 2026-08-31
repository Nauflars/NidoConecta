# Flujo de desarrollo NidoConecta

Este documento define la rutina obligatoria despues de cada bloque de desarrollo.

## 1. Antes de tocar codigo

- Revisar `git status --short --branch`.
- Leer los archivos afectados antes de editar.
- Mantener cambios pequenos y orientados a una funcionalidad concreta.
- No guardar secretos en el repositorio.

## 2. Tests y validacion local

Antes de subir codigo a git, siempre ejecutar:

```powershell
dart format .
flutter analyze
flutter test
flutter build web --dart-define=SUPABASE_URL= --dart-define=SUPABASE_ANON_KEY=
git diff --check
```

Si hay cambios de Supabase:

- Revisar migraciones SQL.
- Asegurar RLS en tablas nuevas.
- Asegurar indices en claves foraneas y filtros habituales.
- Asegurar que las Edge Functions validan autenticacion y permisos.

Si hay cambios de frontend:

- Crear o actualizar tests de widgets para las pantallas/flujos afectados.
- Verificar estados de carga, vacio, error, guardado y permisos cuando aplique.
- Confirmar que no hay overflow en pantallas moviles.

Si hay cambios de backend:

- Crear o actualizar tests de dominio/contrato cuando el stack lo permita.
- Para Edge Functions, validar payload, permisos y errores esperados.
- No llamar servicios externos con secretos desde Flutter.

## 3. Preparar web para testeo

Despues de cada desarrollo y validacion local, dejar Flutter Web preparado para probar:

```powershell
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 53000 --dart-define=SUPABASE_URL= --dart-define=SUPABASE_ANON_KEY=
```

URL de test:

```text
http://127.0.0.1:53000
```

Si el puerto esta ocupado, usar otro puerto y comunicar la URL exacta.

Cuando haya que ejecutar tests/builds de nuevo, parar el servidor web para liberar locks de Flutter.

## 3.1 Capturas y pruebas visuales

Cuando haya cambios visuales importantes:

- Usar Playwright MCP o Playwright local para abrir `http://127.0.0.1:53000`.
- Revisar al menos vista familia, educadora, direccion y formularios tocados.
- Capturar o inspeccionar escritorio y movil cuando cambie layout.

Ver `PLAYWRIGHT_MCP.md` para arrancar el servidor MCP.

## 4. Git y GitHub

Solo hacer commit cuando las validaciones locales esten en verde.

Despues:

```powershell
git status --short
git add <archivos>
git commit -m "<mensaje claro>"
git push
```

Tras el push, comprobar GitHub Actions:

- `Checks` debe quedar en `success`.
- Si hubo cambios en `supabase/**`, `Supabase Deploy` debe quedar en `success`.

## 5. Supabase Deploy

Todo cambio de base de datos o Edge Function debe ir por GitHub Actions.

El workflow `Supabase Deploy` aplica:

- `supabase db push`
- `supabase secrets set WORKER_SECRET`
- `supabase functions deploy create-enrollment`
- `supabase functions deploy bootstrap-center`

Si se crea una nueva Edge Function, anadirla al workflow en el mismo desarrollo.

## 6. Cierre de cada bloque

Al terminar, reportar:

- Que se implemento.
- Tests ejecutados y resultado.
- Commit subido.
- Estado de GitHub Actions.
- URL web activa para testeo.
- Cualquier bloqueo real o dato que falte.

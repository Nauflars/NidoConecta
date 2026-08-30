# NidoConecta - Operacion

## Ruta Local

`C:\www\NidoConecta`

## Entorno Local

Crear `.env` con las claves reales. Este archivo esta ignorado por git.

Flutter recibe variables publicas con `--dart-define`:

```powershell
flutter run --dart-define=SUPABASE_URL=$env:SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY
```

## Comandos

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Supabase

Instalar Supabase CLI antes de desplegar migraciones desde local o CI.

Secrets necesarios en GitHub:

- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_ID`
- `SUPABASE_DB_PASSWORD`
- `WORKER_SECRET`

Para crear el primer centro y usuario de direccion, invocar la Edge Function `bootstrap-center` con el secreto interno:

```powershell
$headers = @{
  "Authorization" = "Bearer $env:SERVICE_ROLE_KEY"
  "apikey" = $env:SERVICE_ROLE_KEY
  "x-worker-secret" = $env:WORKER_SECRET
  "Content-Type" = "application/json"
}

$body = @{
  centerName = "NidoConecta"
  centerSlug = "nidoconecta"
  adminName = "Nombre Direccion"
  adminEmail = "direccion@centro.com"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$env:SUPABASE_URL/functions/v1/bootstrap-center" -Method Post -Headers $headers -Body $body
```

## Android Release

Secrets necesarios en GitHub:

- `ANDROID_RELEASE_KEYSTORE_BASE64`
- `ANDROID_RELEASE_KEYSTORE_PASSWORD`
- `ANDROID_RELEASE_KEY_ALIAS`
- `ANDROID_RELEASE_KEY_PASSWORD`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Mantener siempre el mismo `applicationId`: `com.nauflars.nidoconecta`.

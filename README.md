# NidoConecta

NidoConecta es una aplicacion Flutter + Supabase para escuelas infantiles y guarderias. El objetivo es centralizar agenda diaria, asistencia por QR, comunicacion con familias, comedor, siestas, panales, fotos, comunicados, calendario y menus.

## Estado Inicial

- App Flutter creada para Android y web.
- Integracion preparada con `supabase_flutter`.
- Configuracion por `--dart-define` para no guardar claves en el cliente.
- Migracion inicial Supabase con modelo multi-centro y RLS.
- Workflows base para checks, despliegue Supabase y APK release.

## Configuracion

Rellena `.env` localmente con tus claves reales. El archivo esta ignorado por git.

Variables publicas para la app:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
APP_TIME_ZONE
```

## Ejecutar

```powershell
flutter pub get
flutter run --dart-define=SUPABASE_URL=$env:SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY
```

## Documentacion

- `NidoConecta.md`: concepto funcional del producto.
- `GUIA_STACK_APP_FLUTTER_SUPABASE.md`: guia tecnica base.
- `DOCUMENTACION.md`: arquitectura y MVP del repo.
- `OPERACION.md`: comandos, secretos y despliegue.

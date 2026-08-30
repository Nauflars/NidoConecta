# NidoConecta - Documentacion

## Resumen

NidoConecta es una aplicacion Flutter + Supabase para escuelas infantiles. Centraliza asistencia, agenda diaria, comedor, siestas, panales, fotos, comunicados, calendario, menus y comunicacion familia-escuela.

## Stack

- Flutter/Dart para Android y web.
- Supabase Auth, PostgreSQL, Storage, Realtime y Edge Functions.
- Migraciones versionadas en `supabase/migrations`.
- GitHub Actions para checks, despliegue Supabase y APK release.

## MVP V1

1. Login y roles.
2. Centros, aulas, ninos, familias y educadoras.
3. Entrada y salida con QR.
4. Registros diarios: comida, siesta, panales y observaciones.
5. Fotos y comunicados.
6. Calendario y menu mensual.
7. Notificaciones.

## Modelo De Datos Inicial

El esquema parte de una estructura multi-centro:

- `centers`
- `profiles`
- `center_memberships`
- `classrooms`
- `children`
- `child_guardians`
- `daily_logs`
- `announcements`
- `calendar_events`
- `menus`

Todas las tablas expuestas deben tener RLS activo. Las familias solo acceden a sus hijos. Educadoras y direccion acceden por pertenencia al centro.

## IA

La app movil nunca llama directamente a OpenAI. Los flujos de IA se haran con Edge Functions y revision humana antes de publicar datos criticos.

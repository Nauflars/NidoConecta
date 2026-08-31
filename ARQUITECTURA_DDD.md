# Arquitectura DDD de NidoConecta

NidoConecta se organiza por capas para que las reglas del negocio no dependan de Flutter, Supabase ni de detalles visuales.

## Capas

- `lib/src/domain/`: lenguaje del negocio, entidades ligeras, objetos de valor, validadores y mapeos de conceptos como roles, comida, sueno y reportes diarios.
- `lib/src/application/`: casos de uso y builders de payloads. Convierte acciones de pantalla en comandos seguros para backend/Supabase.
- `lib/src/app_repository.dart`: infraestructura actual contra Supabase. Su responsabilidad es leer/escribir datos, no decidir reglas del negocio.
- `lib/main.dart`: presentacion Flutter. Captura interacciones, muestra estados y delega transformaciones a aplicacion/dominio.
- `supabase/`: persistencia, RLS, migraciones y Edge Functions. Toda integracion sensible vive en backend.

## Reglas

- La UI no debe construir mapas complejos de Supabase ni conocer nombres de columnas salvo en llamadas delegadas ya encapsuladas.
- Los secretos nunca se guardan en Git. `.env` queda local y `.env.example` documenta variables.
- OpenAI nunca se llama desde Flutter. El flujo sera app -> backend propio -> OpenAI -> validacion -> revision humana -> base de datos.
- Toda tabla con datos de centro debe mantener aislamiento por `center_id` o tenant equivalente y RLS.
- Los flujos de salud, medicacion, menores, fotos y documentos requieren criterio conservador y, cuando aplique, revision legal/RGPD.

## Testing

- Dominio: tests unitarios para validadores, mapeos y reglas puras.
- Aplicacion: tests unitarios para payloads de casos de uso.
- Presentacion: widget tests para flujos principales por rol.
- Supabase: validacion por GitHub Actions cuando cambien migraciones o Edge Functions.

## Puerto Web

El puerto de trabajo para Flutter Web es siempre `53000`.

Antes de levantar la app hay que liberar procesos anteriores que escuchen en `127.0.0.1:53000`. Despues:

```powershell
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 53000 --dart-define=SUPABASE_URL= --dart-define=SUPABASE_ANON_KEY=
```

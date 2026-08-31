# Datos demo NidoConecta

La Edge Function `seed-demo-school` crea un centro ficticio completo para pruebas de roles.

## Que crea

- Centro: `Escola Bressol Nido Demo`
- Curso: `2026-2027`
- Direccion: 1 usuaria administrativa
- Educadoras: 3 usuarias
- Aulas: `Petits 0-1`, `Mitjans 1-2`, `Grans 2-3`
- Ninos: 30, 10 por aula
- Familias: padre y madre imaginarios para cada nino
- Agenda diaria de hoy para cada nino
- Entradas QR demo, mensajes, fotos privadas, comunicados, calendario y menus

## Accesos principales

Todos los usuarios se crean con el `defaultPassword` que mandes en la peticion. No lo guardes en Git.

- Direccion: `direccion@nido-demo.test`
- Educadora Petits: `laura.marti@nido-demo.test`
- Educadora Mitjans: `marta.soler@nido-demo.test`
- Educadora Grans: `julia.pons@nido-demo.test`

Ejemplos de familias:

- `aina.padre@nido-demo.test`
- `aina.madre@nido-demo.test`
- `lucas.padre@nido-demo.test`
- `lucas.madre@nido-demo.test`
- `martina.padre@nido-demo.test`
- `martina.madre@nido-demo.test`

## Ejecutar

La funcion esta protegida con `WORKER_SECRET`.

```powershell
$headers = @{
  "x-worker-secret" = "<WORKER_SECRET>"
  "Content-Type" = "application/json"
}

$body = @{
  defaultPassword = "<password-demo-temporal>"
} | ConvertTo-Json

Invoke-RestMethod `
  -Method Post `
  -Uri "<SUPABASE_URL>/functions/v1/seed-demo-school" `
  -Headers $headers `
  -Body $body
```

La funcion es repetible: actualiza usuarios, centro, aulas, ninos, relaciones y limpia la actividad demo antes de regenerarla.

## Privacidad de prueba

Las familias tienen login real, pero las politicas RLS quedan ajustadas para que solo puedan leer los ninos vinculados por `child_guardians`. Direccion y educadoras pueden ver los datos del centro para gestionar la prueba.

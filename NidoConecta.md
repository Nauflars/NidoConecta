# NidoConecta

## Documento de concepto de producto

**NidoConecta** es una plataforma digital para escuelas infantiles y guarderías que centraliza en una sola aplicación el seguimiento diario de los niños, la comunicación con las familias, la gestión del centro y la documentación.

El objetivo principal es sustituir herramientas dispersas como la libreta física, carpetas de Google Drive, correos electrónicos, circulares en papel, documentos PDF, calendarios separados y registros manuales.

La filosofía del producto es simple:

> **Toda la escuela infantil en una sola aplicación.**

Para las familias:

> **Todo el día de tu peque, estés donde estés.**

Y como principio de diseño:

> **Si una tarea tarda más de 10 segundos, buscamos cómo automatizarla.**

---

# 1. Problema que resuelve

Muchas escuelas infantiles todavía gestionan el día a día mediante una combinación de:

- libreta física;
- Google Drive para fotos;
- correos electrónicos;
- circulares;
- PDFs;
- hojas de cálculo;
- llamadas;
- conversaciones presenciales;
- documentos impresos;
- sistemas separados para cobros o facturación.

Esto genera varios problemas:

- información dispersa;
- duplicación de tareas;
- errores manuales;
- pérdida de tiempo para educadoras;
- poca trazabilidad;
- dificultad para consultar el historial de un niño;
- falta de visibilidad para las familias;
- exceso de comunicación por canales distintos;
- gestión manual de calendarios, menús y autorizaciones.

NidoConecta centraliza toda esta información.

---

# 2. Usuarios de la plataforma

La aplicación tendrá tres grandes tipos de usuario.

## Dirección / administración

Puede gestionar:

- centros;
- aulas;
- niños;
- familias;
- educadoras;
- horarios;
- calendario;
- menús;
- tarifas;
- comunicados;
- documentación;
- autorizaciones;
- pagos;
- configuración;
- permisos;
- estadísticas.

## Educadoras

Pueden registrar rápidamente:

- entrada;
- salida;
- comida;
- biberones;
- siestas;
- pañales;
- observaciones;
- actividades;
- incidencias;
- materiales que faltan;
- fotos;
- vídeos;
- comunicaciones.

## Familias

Pueden consultar:

- resumen diario;
- horarios;
- menú;
- calendario;
- fotos;
- observaciones;
- comunicados;
- pagos;
- documentación;
- autorizaciones;
- mensajes;
- personas autorizadas para recoger al niño.

---

# 3. Arquitectura del producto

Desde el principio NidoConecta debe diseñarse como plataforma multi-centro.

Estructura conceptual:

**Plataforma → Centros → Aulas → Niños → Familias**

Ejemplo:

- Centro 1: guardería piloto.
- Centro 2: futura escuela de Barcelona.
- Centro 3: futura escuela de Girona.
- Centro 200: escuela infantil en Madrid.

Cada centro podrá tener:

- su propio logo;
- colores;
- horarios;
- tarifas;
- menús;
- personal;
- aulas;
- documentos;
- configuraciones;
- políticas;
- calendario.

El objetivo es que el primer centro sea un piloto real, pero que el software ya esté preparado para escalar a Barcelona, Cataluña y toda España.

---

# 4. Pantalla principal para familias

La pantalla principal debe mostrar de forma clara lo que ha ocurrido durante el día.

Ejemplo:

## Mateo

**Hoy, martes 15 de septiembre**

🟢 En la escuela desde **08:37**

🍽️ Comida  
**Ha comido muy bien**

😴 Siesta  
**12:47 → 14:09 · 1h 22min**

🧷 Pañales  
**3 cambios**

🎨 Actividad  
**Pintura con esponjas**

📸 **4 fotos nuevas**

📝 Observación de la educadora  
“Hoy Mateo ha participado muchísimo en la actividad de pintura y ha estado muy contento.”

🏠 Observación de casa  
“Esta noche ha dormido un poco peor de lo habitual.”

Botón principal:

**Enviar mensaje a la educadora**

---

# 5. Entrada y salida con código QR

La entrada al centro puede automatizarse mediante QR.

Flujo:

1. El centro tiene un QR en la entrada.
2. El padre abre NidoConecta.
3. Escanea el código.
4. La cuenta autenticada identifica al padre y al niño.
5. Se registra automáticamente la hora de entrada.

Ejemplo:

> Mateo ha llegado — 08:37

La educadora ve inmediatamente la lista de asistencia.

También puede usarse para la salida:

> Mateo recogido — 16:43  
> Persona: Carlos Fernández

El QR no debería identificar directamente al niño. El QR identifica el centro o punto de acceso, mientras que el usuario autenticado identifica a la familia.

---

# 6. Personas autorizadas

La plataforma debe permitir gestionar quién puede recoger al niño.

Ejemplo:

- Carlos — Padre
- Laura — Madre
- María — Abuela
- Antonio — Abuelo

También podría permitirse una autorización puntual:

> Elena García  
> Autorizada solo hoy hasta las 18:00

Esto permite mejorar la trazabilidad y seguridad de las recogidas.

---

# 7. Observaciones de casa

Antes de llegar al centro, las familias podrán comunicar información relevante.

Ejemplo:

## Información para hoy

**¿Cómo ha dormido?**

- Bien
- Regular
- Mal

**¿Ha desayunado?**

- Sí
- No

**Observaciones**

> “Se ha despertado varias veces esta noche. Esta mañana no ha querido leche.”

La educadora recibe esta información al comenzar el día.

El objetivo es mantener comunicación bidireccional:

**Casa → Escuela**

y

**Escuela → Casa**

---

# 8. Comedor

El módulo de comedor debe ser rápido para las educadoras.

Ejemplo:

## Comida de hoy

- Macarrones
- Merluza
- Manzana

Para cada niño:

- 🟢 Todo
- 🟡 Bastante
- 🟠 Poco
- 🔴 Nada

Para lactantes:

- biberones;
- cantidad en ml;
- hora;
- papillas;
- introducción de alimentos.

Ejemplo:

> 🍼 Leche: 180 ml  
> Hora: 10:15

También puede existir un registro de:

- alergias;
- intolerancias;
- dietas especiales;
- alimentos introducidos.

---

# 9. Menús mensuales

La dirección podrá gestionar el menú del mes.

En lugar de introducir cada día manualmente, NidoConecta incluirá una función:

## Importar menú con IA

Flujo:

1. Dirección hace una foto o sube un PDF.
2. El backend envía la imagen/documento a OpenAI.
3. La IA interpreta la tabla.
4. Devuelve datos estructurados.
5. La plataforma muestra una pantalla de revisión.
6. Dirección confirma.
7. Se publican todos los días automáticamente.

Ejemplo de resultado estructurado:

```json
{
  "mes": "septiembre",
  "anio": 2026,
  "dias": [
    {
      "fecha": "2026-09-07",
      "primer_plato": "Arroz",
      "segundo_plato": "Pollo",
      "postre": "Fruta"
    }
  ]
}
```

Regla importante:

> **La IA propone; una persona confirma antes de publicar.**

---

# 10. Siestas

La educadora podrá registrar las siestas con dos acciones.

**Iniciar siesta**

12:47

**Finalizar siesta**

14:09

La aplicación calcula automáticamente:

> 1h 22min

Más adelante podría mostrar estadísticas simples, por ejemplo:

> Siesta media esta semana: 1h 17min

---

# 11. Pañales e higiene

Registro extremadamente rápido.

Ejemplo:

10:14 — Pis  
12:32 — Deposición  
15:08 — Pis

También puede existir:

## Material que falta

La educadora marca:

- pañales;
- toallitas;
- muda;
- babero;
- otros.

La familia recibe una notificación automática:

> Mateo necesita pañales mañana.

---

# 12. Fotos y vídeos

NidoConecta sustituirá el uso de carpetas dispersas en Google Drive.

Se podrá organizar contenido por:

- niño;
- aula;
- actividad;
- excursión;
- evento;
- fecha;
- curso.

Ejemplo:

## Momentos

**Hoy**

🎨 Pintura — 4 fotos  
🌳 Parque — 7 fotos  
🎵 Música — 2 vídeos

Las familias verán exclusivamente el contenido autorizado.

---

# 13. Consentimientos de imagen

Cada niño tendrá configuraciones de consentimiento.

Ejemplo:

- Fotografías privadas para familia.
- Fotografías del grupo.
- Vídeos.
- Uso promocional.
- Uso en redes sociales.

Estas autorizaciones deben quedar registradas y ser fácilmente consultables por el centro.

---

# 14. Calendario escolar

Cada centro podrá configurar su calendario anual.

Incluirá:

- inicio de curso;
- fin de curso;
- vacaciones;
- festivos;
- días de libre disposición;
- jornadas intensivas;
- reuniones;
- excursiones;
- eventos;
- actividades;
- fiestas.

Las familias podrán ver todo el año desde un único calendario.

También recibirán recordatorios.

Ejemplos:

> Mañana la guardería permanecerá cerrada.

> Este viernes hay salida. Recordad traer mochila y agua.

---

# 15. Importación automática del calendario con IA

Dirección podrá subir una imagen o PDF del calendario oficial.

La IA podrá detectar:

- festivos;
- vacaciones;
- eventos;
- jornadas especiales;
- reuniones.

Después aparecerá una pantalla de revisión.

Ejemplo:

- 7 diciembre — Centro cerrado
- 8 febrero — Libre disposición
- 20–29 marzo — Semana Santa
- 17 mayo — Fiesta local
- 15–22 julio — Jornada intensiva

Botón:

**Importar eventos**

---

# 16. Horarios del centro

Cada centro podrá configurar:

- acogida;
- entrada;
- actividades;
- recreo;
- comedor;
- siesta;
- merienda;
- salida;
- horas extra.

Los horarios no se codificarán específicamente para un centro.

Serán configurables desde administración.

---

# 17. Información y normas del centro

Todo el contenido que tradicionalmente se entrega en un libro o PDF podrá integrarse en la aplicación.

Ejemplo:

## Nuestro centro

- Quiénes somos
- Proyecto educativo
- Adaptación
- Día a día
- Horarios
- Calendario
- Tarifas
- Comedor
- Qué hay que traer
- Normas
- Salud
- Contacto

La dirección podrá modificar esta información sin publicar nuevos PDFs.

---

# 18. Tarifas

La plataforma podrá almacenar:

- escolarización;
- comedor mensual;
- comedor eventual;
- acogida;
- horas extra;
- matrícula;
- materiales;
- descuentos;
- otros servicios.

También podrá existir:

## Importar tarifas con IA

La dirección sube una foto o PDF con precios.

La IA detecta:

- concepto;
- precio;
- periodicidad;
- condiciones.

Dirección revisa y confirma.

---

# 19. Pagos y extras

El módulo puede comenzar simplemente como registro de cargos.

Ejemplo:

## Mis pagos

Escolarización — 203,45 € — Pagado  
Comedor — 171,12 € — Pagado  
Acogida — 13,75 € — Pagado  
Material — 115,56 € — Pagado

Extras:

Comedor eventual — 13,34 €  
Hora extra — 9,52 €

Más adelante podrá integrarse:

- SEPA;
- tarjeta;
- recibos;
- domiciliaciones;
- facturación.

---

# 20. Documentación y matrícula

Cada niño tendrá un expediente digital.

Ejemplo:

- DNI padre/madre;
- certificado de nacimiento;
- tarjeta sanitaria;
- vacunación;
- autorizaciones;
- datos bancarios;
- contacto de emergencia;
- documentos adicionales.

La aplicación mostrará qué documentos están completos y cuáles faltan.

Ejemplo:

✅ DNI padre  
✅ DNI madre  
✅ Certificado nacimiento  
✅ Tarjeta sanitaria  
✅ Vacunación  
⚠️ Autorización pendiente

---

# 21. Digitalización de documentos con IA

OpenAI podrá utilizarse para extraer información de documentos.

Ejemplos:

- ficha de matrícula;
- hoja de tarifas;
- circular;
- menú;
- calendario;
- documentación antigua;
- albarán;
- factura.

Flujo recomendado:

**Foto/PDF → OpenAI → JSON estructurado → revisión humana → base de datos**

OpenAI nunca debe ser la base de datos.

---

# 22. Salud y medicación

Este módulo requiere especial cuidado.

Podrá registrar:

- alergias;
- intolerancias;
- información relevante;
- contactos de emergencia;
- autorizaciones;
- medicación;
- receta adjunta;
- hora de administración.

Ejemplo:

## Medicación

Medicamento X  
Hora: 13:00

📄 Receta adjunta  
✍️ Autorización firmada

Centro:

✅ Autorizado

Después:

> Administrado a las 13:04 por Marta.

La plataforma deberá guardar trazabilidad.

---

# 23. Comunicados

NidoConecta centralizará todos los avisos.

Ejemplo:

## Dirección

> Recordamos que el viernes realizaremos la salida mensual.

La dirección podrá ver:

> 52 de 64 familias han leído el comunicado.

Los comunicados podrán tener:

- fecha;
- archivos;
- confirmación de lectura;
- recordatorios;
- traducciones.

---

# 24. Consultas y mensajes

No se pretende crear un WhatsApp.

La comunicación debe ser organizada.

Categorías:

- Ausencia
- Comedor
- Horario
- Administración
- Educadora
- Salud
- Otro

Ejemplo:

> Mañana Mateo llegará sobre las 10:00 porque tiene pediatra.

El mensaje queda relacionado con el niño correspondiente.

---

# 25. Panel de educadora

Debe ser extremadamente rápido.

Ejemplo:

## Clase Mariposas — 13 niños

| Niño | Comida | Siesta | Pañal | Nota |
|---|---|---|---|---|
| Mateo | 🟢 | 😴 | ✅ | |
| Lucas | 🟡 | ✅ | ✅ | 📝 |
| Ana | 🟢 | ✅ | — | |
| Leo | 🔴 | ✅ | ✅ | ⚠️ |

También se podrán realizar acciones en grupo.

Ejemplo:

Seleccionar varios niños → Actividad: Patio → Añadir fotos.

---

# 26. Registro por voz con IA

Una de las funciones diferenciales será registrar información mediante voz.

Ejemplo:

La educadora dice:

> “Lucas ha comido todo, ha dormido de una menos cuarto a dos y cuarto, hemos cambiado dos pañales y hoy ha estado muy contento.”

La IA propone:

- Comida: Todo.
- Siesta: 12:45–14:15.
- Pañales: 2.
- Observación: Ha estado muy contento.

Educadora:

**Confirmar**

La IA reduce el trabajo administrativo.

---

# 27. Panel de dirección

La dirección tendrá un dashboard general.

Ejemplo:

## Hoy

👶 57 / 64 niños presentes

👩‍🏫 8 educadores

🍽️ Comedor: 46 niños

⚠️ 3 incidencias

💬 7 mensajes pendientes

📄 4 documentos pendientes

💳 6 pagos pendientes

📸 42 nuevas fotografías

Secciones:

- Alumnos
- Familias
- Clases
- Personal
- Horarios
- Calendario
- Menús
- Facturación
- Documentos
- Comunicados
- Fotos
- Configuración

---

# 28. Automatización con OpenAI

La IA debe utilizarse solamente cuando aporte una ventaja real.

Principio:

> **No usar IA cuando un botón es más rápido.**

Ejemplos adecuados:

### Menú mensual

Foto/PDF → IA → menú estructurado.

### Calendario

PDF → IA → eventos.

### Tarifas

Foto → IA → conceptos y precios.

### Circular

Documento → IA → comunicado + fecha + recordatorio + acción requerida.

### Voz

Audio/texto → IA → campos de agenda.

### Documentación

Foto/PDF → IA → campos estructurados.

### Comunicaciones

Texto informal → IA → comunicado profesional.

### Traducciones

Español ↔ Catalán ↔ Inglés.

---

# 29. Cámara como interfaz

NidoConecta puede tener un botón:

## ✨ Importar con IA

Opciones:

- Menú
- Calendario
- Circular
- Tarifas
- Documento
- Factura
- Detectar automáticamente

Si la dirección no sabe qué tipo de documento está subiendo, la IA puede clasificarlo.

Ejemplo:

> Parece un menú mensual de octubre de 2026.

> ¿Quieres importarlo en Menús?

---

# 30. IA para fotografías

La IA podría ayudar a:

- detectar fotos borrosas;
- generar títulos de álbum;
- generar descripciones;
- clasificar por actividad;
- ordenar contenido.

No se recomienda basar el producto en reconocimiento facial automático de menores.

La privacidad debe tener prioridad.

---

# 31. Resumen diario automático

La plataforma podrá generar automáticamente un resumen del día utilizando los datos ya registrados.

Ejemplo:

> Mateo ha llegado a las 08:37. Ha comido muy bien, ha dormido 1h 22min y ha participado en una actividad de pintura. Se han registrado tres cambios de pañal y cuatro fotografías nuevas.

Este resumen no requiere que la educadora vuelva a escribir información.

---

# 32. Privacidad y seguridad

NidoConecta trabajará con datos especialmente sensibles por tratarse de menores.

Debe diseñarse desde el principio con:

- RGPD;
- privacidad por diseño;
- control de roles;
- permisos;
- cifrado;
- logs de acceso;
- separación entre centros;
- separación entre familias;
- consentimiento de imágenes;
- borrado de datos;
- exportación de datos;
- política de retención;
- autenticación segura.

Los padres solo podrán acceder a información autorizada.

---

# 33. Arquitectura recomendada para OpenAI

La API de OpenAI nunca debería llamarse directamente desde la aplicación móvil.

Arquitectura:

**App → Backend propio → OpenAI API → Backend → Base de datos**

La API key permanece exclusivamente en el servidor.

Los datos devueltos por IA deben convertirse a estructuras verificables antes de guardarse.

---

# 34. Principio de revisión humana

Para documentos, salud, pagos, menús, calendarios y datos importantes:

> **La IA nunca publica directamente información crítica sin revisión.**

Flujo:

**IA detecta → usuario revisa → usuario confirma → se guarda**

---

# 35. MVP para la primera guardería

La primera versión debe ser sencilla pero suficientemente completa para utilizarse durante un curso real.

## MVP V1

1. Usuarios y login.
2. Niños y familias.
3. Clases/grupos.
4. Entrada y salida con QR.
5. Comidas.
6. Siestas.
7. Pañales.
8. Observaciones casa → escuela.
9. Observaciones escuela → familia.
10. Fotos.
11. Comunicados.
12. Calendario.
13. Menú mensual.
14. Información y normas del centro.
15. Notificaciones.

El objetivo es sustituir:

- libreta física;
- Google Drive;
- correos básicos;
- calendario separado;
- menús en PDF;
- comunicaciones dispersas.

---

# 36. V2

Después de validar el MVP:

- pagos y extras;
- documentación;
- autorizaciones;
- personas autorizadas;
- ausencias;
- medicación;
- material que falta;
- firma digital;
- importaciones con IA más avanzadas.

---

# 37. V3

Fase de escalado:

- facturación;
- domiciliación SEPA;
- pagos;
- matrícula online;
- informes;
- estadísticas;
- multi-centro avanzado;
- IA avanzada;
- integraciones;
- API pública;
- administración de cadenas de centros.

---

# 38. Posicionamiento comercial

NidoConecta no debería presentarse únicamente como una agenda digital.

Propuesta principal:

> **NidoConecta — toda tu escuela infantil en una sola aplicación.**

Otra opción:

> **La plataforma que conecta escuela y familia y automatiza el día a día.**

Para dirección:

> **Menos papeles. Menos tareas repetitivas. Más tiempo para los niños.**

Para familias:

> **Todo el día de tu peque, estés donde estés.**

---

# 39. Diferenciación frente a competidores

En España ya existen agendas digitales y software de gestión para escuelas infantiles.

Por tanto, NidoConecta no debe competir únicamente por tener:

- agenda;
- fotos;
- menús;
- mensajes;
- calendario.

El diferencial debe ser:

## Automatización extrema

Ejemplos:

- foto del menú → mes completo;
- PDF del calendario → eventos;
- foto de tarifas → precios;
- circular → comunicado y recordatorio;
- voz → agenda diaria;
- documento → datos estructurados;
- registro QR → asistencia automática;
- datos del día → resumen automático.

Conceptualmente:

> **Otros digitalizan la agenda. NidoConecta automatiza la guardería.**

---

# 40. Estrategia de lanzamiento

## Fase 1 — Piloto

Crear una primera versión para una guardería real.

Ofrecerla gratuitamente durante la fase piloto.

Objetivos:

- ver cómo trabajan las educadoras;
- detectar qué funciones realmente utilizan;
- medir ahorro de tiempo;
- mejorar usabilidad;
- corregir errores;
- obtener feedback de familias;
- obtener feedback de dirección.

## Fase 2 — Caso de éxito

Documentar resultados.

Ejemplos de métricas:

- tiempo ahorrado por educadora;
- reducción de papel;
- número de familias activas;
- uso diario;
- fotografías publicadas;
- mensajes enviados;
- satisfacción;
- reducción de tareas administrativas.

## Fase 3 — Barcelona

Utilizar el primer centro como referencia para conseguir nuevas escuelas.

## Fase 4 — Cataluña

Expandir mediante recomendaciones y referencias entre centros.

## Fase 5 — España

Adaptar:

- idioma;
- calendario;
- documentación;
- normativa;
- integraciones;
- facturación.

---

# 41. Modelo de negocio futuro

NidoConecta será un SaaS B2B.

El cliente que paga es la escuela infantil.

Posibles modelos:

## Por centro

Ejemplo:

- Básico.
- Profesional.
- Premium.

## Por número de alumnos

Ejemplo:

- hasta 50 niños;
- hasta 100;
- hasta 200.

## Multi-centro

Precio especial para grupos y cadenas.

## Módulos adicionales

- facturación;
- pagos;
- IA;
- matrícula;
- firma;
- almacenamiento;
- analítica avanzada.

---

# 42. Principios de diseño

NidoConecta debe ser:

- muy fácil de aprender;
- usable con una mano;
- rápido;
- visual;
- claro;
- con pocas pantallas;
- con pocos campos manuales;
- preparado para tablets;
- preparado para móviles;
- accesible;
- seguro;
- configurable.

Regla para educadoras:

> **Las tareas habituales deben resolverse en uno o dos toques.**

---

# 43. Visión a largo plazo

La visión no es crear una simple aplicación de agenda.

La visión es construir:

> **El sistema operativo de las escuelas infantiles en España.**

NidoConecta podría gestionar todo el ciclo:

**Matrícula → documentación → entrada → día a día → comunicación → fotos → comedor → calendario → pagos → facturación → informes → fin de curso.**

Todo centralizado en una sola plataforma.

---

# 44. Resumen

NidoConecta nace para resolver un problema muy concreto:

**La información de una escuela infantil está demasiado dispersa.**

La plataforma centraliza:

- seguimiento diario;
- asistencia;
- QR;
- comedor;
- siestas;
- pañales;
- observaciones;
- fotografías;
- vídeos;
- calendario;
- menús;
- horarios;
- comunicados;
- pagos;
- documentación;
- autorizaciones;
- salud;
- mensajes;
- administración.

Y utiliza inteligencia artificial para reducir drásticamente la introducción manual de información.

La combinación principal es:

**Escuela infantil + familia + automatización + IA.**

Objetivo final:

> **NidoConecta — toda tu escuela infantil en una sola aplicación.**

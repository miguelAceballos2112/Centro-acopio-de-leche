```
# Centro de Acopio de Leche — Sistema de Liquidación y Reportes

Sistema de procesamiento de entregas, validación de calidad y liquidación financiera para un centro regional de acopio de leche, desarrollado en Elixir para la asignatura Programación III (Universidad del Quindío).

---
## Características Principales

Validación Secuencial Rigurosa (`with`): Canalización de entregas verificando en orden estricto: existencia de productor, existencia de tanque, día válido (1 a 6), volumen de litros (1-800 L) y porcentaje de grasa (0-15%).
Cálculos Financieros y Reglas de Negocio:**
  * Ajustes por porcentaje de grasa (bonificaciones del 6% y descuentos escalonados hasta del 20%).
  * Bonificación por volumen diario (+\$25.000 para entegas \\(\ge\\) 450 L).
  * Descuento por servicio de transporte (\$18.000 por día con entregas válidas).
  * Generación de Reportes Administrativos (R1 a R8):
  * R1: Entregas rechazadas por motivo de rechazo.
  * R2: Almacenamiento por tanque y % de ocupación.
  * R3: Balance diario vs. meta operativa (2.000 L).
  * R4: Tabla de liquidación ordenada por pago neto.
  * R5: Productor destacado por día y acumulado semanal.
  * R6: Calidad promedio ponderada de grasa por productor.
  * R7: Total consolidado pagado y costo promedio por litro.
  * R8: Productores con cobertura completa de tanques.
* Interfaz de Consola (CLI): Captura e integración de entregas adicionales y consulta de comprobantes detallados por productor.
* Integración de Fuentes Externas: Combinación de datos entre centros de acopio utilizando `Map.merge/3`.

---

## Tecnologías y Restricciones Arquitectónicas

* Lenguaje: Elixir (Scripts `.exs`)
* Paradigma: Programación Funcional Pura.
* Manejo de Errores: Exclusivamente con tuplas de estado `{:ok, valor}` y `{:error, motivo}`.
* Restricciones del Proyecto:
  *  Sin uso de `mix`, `defstruct`/structs ni procesos (`spawn`, `Task`).
  *  Sin lectura/escritura de archivos (`File`) ni librerías externas.
  *  Sin recursividad ni bloques `try/rescue`.
  *  Uso de colecciones puras (`List`, `Map`, `Tuple`) y transformaciones con `Enum`.

---

## Estructura del Proyecto

```text
.
├── Util2.ex          # Utilidades del curso (mostrar, ordenar, convertir colecciones)
├── datos.exs         # Base de datos inicial (productores, tanques y entregas)
├── validacion.exs    # Módulo de validación de entregas con `with`
├── calculos.exs      # Módulo con fórmulas financieras y reglas de negocio
├── reportes.exs      # Módulo para la generación de reportes R1 a R8 y ranking/2
├── interaccion.exs   # Entrega adicional y comprobante por consola
├── investigacion.exs # Combinación de centros con Map.merge/3
├── main.exs          # Orquestador principal
├── DOCUMENTORIA.md   # Contenido del PDF (Partes A, C, D, R6 y salida)
└── README.md         # Documentación del proyecto
```

---

## Instrucciones de Ejecución

Asegúrate de tener instalado **Elixir** en tu sistema.

1. **Clonar el repositorio:**

```
git clone https://github.com/TU_USUARIO/centro-acopio-leche-elixir.git
cd centro-acopio-leche-elixir

```

1. **Ejecutar la solución:**

```
elixir main.exs

```

---

## Autores

* **Miguel Angel Ceballos Soler:** Datos, Validaciones y Lógica de Negocio.
* **Victor Manuel Bolaños Guzman:** Reportes Estadísticos y Financieros (R1 a R8).
* **Juan José Ramírez Londoño:** Interacción CLI, Comprobantes y Documentación.

*Universidad del Quindío — Ingeniería de Sistemas y Computación*

```

---

```

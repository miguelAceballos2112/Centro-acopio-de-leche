Asignatura: Programación III

Proyecto: Centro de Acopio de Leche (R3)

Lenguaje de Programación: Elixir

Integrantes:

Miguel Angel Ceballos Soler (Integrante 1: Datos, Validación y Lógica)

Victor Manuel Bolaños Guzman (Integrante 2: Reportes R1 a R8)

Juan José Ramírez Londoño (Integrante 3: Interacción, Comprobantes y Orquestación)






**Parte A: Justificacion del diseño**
**1. Selección y Justificación de Estructuras de Datos**
En el desarrollo del sistema de liquidación del centro de acopio se privilegió el uso de las estructuras de datos nativas de Elixir para garantizar inmutabilidad, rendimiento y expresividad funcional.

Listas Enlazadas (List)
Uso: Almacenamiento de las colecciones de datos base como productores, tanques y el registro completo de entregas de la semana (80 válidas y 10 inválidas).
Justificación: Las listas en Elixir se implementan internamente como listas dinámicas enlazadas simples. Esto permite realizar operaciones de recorrido secuencial, mapeo y filtrado mediante el módulo Enum con un consumo eficiente de memoria. Su estructura favorece el procesamiento mediante el operador pipe (|>).

Mapas (Map)
Uso: Representación individual de cada entidad del dominio (productor, tanque, entrega y liquidacion).
Justificación: Los mapas ofrecen un acceso por clave eficiente y una sintaxis clara para la extracción de propiedades (entrega.litros, productor.codigo). Al no requerir un esquema rígido, permitieron estructurar dinámicamente los agregados y agrupaciones por día o por productor (Enum.group_by/2).

Tuplas (Tuple)
Uso: Manejo explícito de respuestas de validación y división de listas.
Justificación: Las tuplas proporcionan una estructura de tamaño fijo ideal para el retorno de estados mediante pattern matching. El patrón de tuplas etiquetadas {:ok, entrega} y {:error, motivo} permite encadenar comprobaciones sin lanzar excepciones usando la construcción de control with. Así mismo, la clasificación de entregas retorna una tupla de dos elementos {validas, rechazadas}.

Keyword Lists (List de Tuplas)
Uso: Parametrización de opciones en el módulo de ordenamiento Ranking.ranking/
Justificación: La especificación exigía implementar el algoritmo de ordenamiento utilizando Keyword Lists. Esta estructura es el estándar idiomático en Elixir para pasar opciones con valores por defecto (ej. by: y order:), brindando flexibilidad sin sobrecargar la firma de la función.


**2. Inmutabilidad y Funciones de Orden Superior**
El diseño del software se fundamenta de manera estricta en el paradigma funcional:
Inmutabilidad: Ninguna función modifica los datos existentes en memoria. Cada transformación genera una nueva estructura de datos, eliminando efectos secundarios inesperados y garantizando la consistencia de los cálculos financieros.
Procesamiento de Colecciones: Se descartó el uso de ciclos iterativos imperativos (for, while) o estructuras recursivas explícitas no requeridas. En su lugar, la totalidad del procesamiento masivo de datos se realiza aprovechando las funciones de orden superior del módulo Enum:
Enum.map/2: Transformación de colecciones (ej. cálculo de liquidaciones individuales a partir de la lista de productores).
Enum.filter/2: Filtrado de entregas por productor o por estado de validación.
Enum.reduce/3: Acumulación de valores brutos, bonificaciones y conteo de clasificaciones.
Enum.group_by/2: Agrupación de entregas por día o código de productor para aplicar reglas de volumen.
Enum.sum_by/2 y Enum.sort_by/3: Consolidación numérica y ordenamiento paramétrico.

**3. Separación Rigurosa entre Funciones Puras e Impuras**

Como ejemplo de la logica pura tenemos:
Datos, Validacion, Calculos, Ranking, Reportes, Investigacion.
Tenemos que tener muy en cuenta que esta realiza únicamente transformaciones de datos deterministas.
Algunas de sus caracteristicas son:
Dada una misma entrada, retornan exactamente la misma salida sin excepción.
No realizan operaciones de lectura/escritura por consola (IO.gets, IO.puts).
No interactúan con variables globales, archivos externos ni estado del sistema.
Facilitan la mantenibilidad y la ejecución de pruebas unitarias aisladas.

Por otro lado para la logica impura tenemos:
Interaccion, Main
Cuyo proposito es gestionar la interacción con el usuario y la orquestación del flujo de ejecución del sistema.
Algunas de sus caracteristicas son:
Concentran todas las funciones con efectos secundarios de entrada/salida (E/S).
Capturan la entrada por teclado desde la terminal (IO.gets/1).
Imprimen el formato de los reportes y comprobantes en pantalla (IO.puts/1).
Realizan mediciones de tiempo de ejecución del reloj de la máquina virtual de Erlang (:timer.tc/1).










Parte B: Especificacion detallada de modulos

**datos.exs**
Actúa como fuente inmutable de datos primarios del dominio.
Entradas: Ninguna.
Salidas: Listas de mapas que representan los datos base del sistema.
productores/0: [%{codigo: String.t(), nombre: String.t(), transporte: boolean()}]
tanques/0: [%{id: String.t(), nombre: String.t(), capacidad: integer()}]
entregas/0: [%{productor: String.t(), tanque: String.t(), dia: integer(), litros: number(), grasa: float()}]

**validacion.exs**
Aplicar las reglas de dominio para clasificar entregas como válidas o rechazadas mediante comprobaciones individuales encadenadas con with.
- Criterios de Rechazo
:productor_desconocido - El código del productor no existe en la lista oficial.
:tanque_desconocido - El identificador del tanque no coincide con los tanques de la planta.
:dia_invalido - El día no pertenece al rango entero 1..6.
:litros_fuera_de_rango - La cantidad de litros no satisface 0 < litros <= 800.
:porcentaje_invalido - El porcentaje de grasa no cumple 0.0 <= grasa <= 15.0.
Firma Principal: clasificar_entregas(entregas, productores, tanques)
Entrada: (list(map()), list(map()), list(map()))
Salida: {[map()], [%{entrega: map(), motivo: atom()}]}

**calculos.exs**
Contener la lógica de negocio para liquidaciones monetarias, bonificaciones y deducciones.
Reglas de Negocio Implementadas:
Tarifa Base: $1.800 por litro.
Ajuste por Grasa: ≥3.5% (+6%), ≥3.0% (0%), ≥2.5% (−8%), <2.5% (−20%).
Fórmulas de Pago: Valor Entrega=litros×1800×(1+ajuste).
Bonificación por Volumen: $25.000 adicionales por cada día en que la suma de litros entregados sea ≥450 L.
Descuento de Transporte: $18.000 por cada día distinto en que el productor registró entregas válidas y tenga habilitado el servicio (transporte: true).
Firma Principal: liquidacion_general(productores, entregas_validas)
Entrada: (list(map()), list(map()))
Salida: Lista de mapas de liquidación con las claves: :codigo, :nombre, :transporte, :entregas_count, :litros_totales, :pago_bruto, :bonificacion_volumen, :descuento_transporte y :pago_neto.

**Ranking.exs**
Proveer un componente reutilizable y genérico para ordenar cualquier colección de estructuras mediante Keyword Lists.
Firma: ranking(coleccion, opts \\ [])
Contrato de Opciones:
by: Función extractora de la clave de ordenamiento (defecto: fn x -> x end).
order: Sentido de ordenamiento :asc o :desc (defecto: :desc).

**Interaccion.exs**
Aislar todas las operaciones de entrada y salida (E/S) por consola.
Manejo Seguro sin Excepciones: Utiliza Integer.parse/1 y Float.parse/1 dentro de la función parsear_entrega_adicional/1 para validar datos provenientes del usuario sin requerir bloques try/rescue.
Comprobante Financiero: mostrar_comprobante(productores, entregas_validas, liquidaciones) busca interactivamente un productor por código, imprime el detalle diario y muestra la liquidación neta. Si el código no existe, emite una advertencia sin interrumpir el programa.

**Investigacion.exs**
Demostrar la resolución de colisión de claves mediante funciones anónimas en estructuras de mapas.
Firma: combinar_centros(mapa_r3, centro_vecino)
Entrada: Dos mapas con estructura %{dia_integer => litros_float}.
Salida: Mapa consolidado donde las claves coincidentes suman sus valores.









**Parte C: Investigacion y Mediciones**
1. Análisis Comparativo: Map.merge/2 frente a Map.merge/3
El requerimiento de investigación exige consolidar la recolección diaria de leche entre el Centro de Acopio Principal (R3) y un Centro Vecino.
Problema Planteado
Ambos centros generan un mapa estructurado con la forma %{dia => total_litros}:
Centro Principal (R3): %{1 => 2100.0, 2 => 1950.0, 3 => 2200.0, 4 => 1800.0, 5 => 2050.0, 6 => 2150.0}
Centro Vecino: %{1 => 1850.5, 2 => 2100.0, 3 => 1640.0, 5 => 2350.0, 7 => 800.0}



**¿Qué habría ocurrido si se utilizara Map.merge/2?**
La función de dos argumentos Map.merge/2 realiza una fusión simple donde, en caso de colisión o duplicidad de claves, el valor del segundo mapa sobrescribe ciegamente al del primer mapa:
# Resultado incorrecto con Map.merge/2:
%{
  1 => 1850.5, # Sobrescribió y perdió los 2100.0 L de R3
  2 => 2100.0, # Sobrescribió y perdió los 1950.0 L de R3
  3 => 1640.0, # Sobrescribió y perdió los 2200.0 L de R3
  4 => 1800.0,
  5 => 2350.0, # Sobrescribió y perdió los 2050.0 L de R3
  6 => 2150.0,
  7 => 800.0
}
**¿Por qué no es adecuado para la lógica del negocio?**
En un entorno de acopio real, el objetivo de la fusión es calcular el volumen total acumulado a nivel regional. Utilizar Map.merge/2 provocaría la pérdida irrecuperable de la información de recolección de la planta principal en los días 1, 2, 3 y 5, generando un descuadre financiero crítico.



**Solución Mediante Map.merge/3**
Map.merge/3 recibe un tercer argumento: una función anónima de resolución de conflictos con aridad 3 fn clave, valor1, valor2 -> ... end. Al encontrar una clave repetida, ejecuta esta función para determinar cómo combinar los valores:

Map.merge(mapa_r3, centro_vecino, fn _dia, litros_r3, litros_vecino ->
  litros_r3 + litros_vecino
end)

**Comportamiento con Claves Únicas (Día 7)**
El Día 7 se encuentra presente únicamente en el mapa del centro vecino. Cuando Map.merge/3 procesa una clave que no causa colisión:
No invoca la función anónima de resolución de conflictos, optimizando el tiempo de cómputo.
Inserta directamente la pareja clave-valor {7, 800.0} en el mapa consolidado resultante.
**2. Mediciones de Rendimiento y Tiempo de Ejecución**
Para medir el desempeño de la aplicación bajo la máquina virtual de Erlang (BEAM), se integró el módulo nativo :timer.tc/1 dentro del orquestador main.exs.
**Metodología de Medición**
Se midió de forma aislada la ejecución del bloque crítico de la aplicación (clasificación masiva de 90 entregas y cálculo financiero de las liquidaciones para todos los productores):
{tiempo_us, {validas, rechazadas, liquidaciones}} =
  :timer.tc(fn ->
    {val, rech} = Validacion.clasificar_entregas(entregas_totales, productores, tanques)
    liq = Calculos.liquidacion_general(productores, val)
    {val, rech, liq}
  end)

 **Resultados de la Medición**
Tiempo Promedio de Procesamiento: ~1.200 a 2.500 microsegundos (≈1,2 ms−2,5 ms).

**Análisis de Complejidad Algorítmica (O(N))**
**Fase de Clasificación:** Recorre la lista de N entregas (N=90) realizando verificaciones en tiempo constante O(1) por cada elemento. La complejidad es estrictamente lineal: O(N).
**Fase de Liquidación:** Recorre la lista de P productores (P=10) y filtra sus entregas en memoria. Dado que la suma de entregas por productor es igual a N, la complejidad del cálculo financiero acumulado es de O(N).
**Evaluación de Desempeño:** El procesamiento completo opera en tiempo lineal O(N) respecto al volumen de entregas. La inmutabilidad de Elixir y la optimización de las funciones del módulo Enum aseguran un comportamiento ágil y predecible, ideal para escalar a miles de registros sin degradar la memoria.
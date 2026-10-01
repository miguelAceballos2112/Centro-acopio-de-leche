# Integrantes: Miguel Angel Ceballos Soler (Integrante 1), Victor Manuel Bolaños Guzman (Integrante 2),
#              Juan José Ramírez Londoño (Integrante 3)
#
# Integrante 2: Reportes estadísticos y financieros (R1 a R8).
#
# Se reutiliza Util2 (visto en clase) con el mismo patrón de los ejemplos:
#
#   coleccion
#   |> Util2.ordenar(:desc, & &1.campo)
#   |> Util2.convertir_coleccion_mensaje(fn elemento -> "texto\n" end)
#   |> Util2.mostrar(:mensaje)
#
# Cada reporte tiene:
#   - una función PURA que calcula los datos (no imprime nada);
#   - una función rX IMPURA que solo muestra el resultado.

defmodule Reportes do
  @meta_diaria 2000
  @dias 1..6
  @minimo_entregas_r6 3
  @motivos [
    :productor_desconocido,
    :tanque_desconocido,
    :dia_invalido,
    :litros_fuera_de_rango,
    :porcentaje_invalido
  ]

  # Imprime todos los reportes en el orden exigido.
  def generar(validas, rechazadas, productores, tanques, liquidacion) do
    r1(rechazadas)
    r2(validas, tanques)
    r3(validas)
    r4(liquidacion)
    r5(validas)
    r6(validas)
    r7(liquidacion)
    r8(validas, productores, tanques)
  end

  # -------------------------------------------------------------
  # ranking/2 con keyword list: ranking(lista, por: :pago_neto, orden: :desc)
  # -------------------------------------------------------------
  def ranking(lista, opciones) do
    campo = Keyword.get(opciones, :por)
    orden = Keyword.get(opciones, :orden, :desc)

    Util2.ordenar(lista, orden, &Map.get(&1, campo))
  end

  # -------------------------------------------------------------
  # R1: entregas rechazadas agrupadas por motivo
  # -------------------------------------------------------------

  # rechazadas es una lista de mapas %{entrega: entrega, motivo: motivo}.
  # Retorna un mapa %{motivo => [entregas]}.
  def agrupar_rechazadas(rechazadas) do
    Enum.group_by(rechazadas, fn %{motivo: motivo} -> motivo end, fn %{entrega: entrega} -> entrega end)
  end

  def r1(rechazadas) do
    Util2.mostrar("\n===== R1. Entregas rechazadas =====", :mensaje)
    grupos = agrupar_rechazadas(rechazadas)

    Enum.each(@motivos, fn motivo ->
      entregas = Map.get(grupos, motivo, [])
      Util2.mostrar("#{motivo}: #{length(entregas)} rechazo(s)", :mensaje)

      entregas
      |> Util2.convertir_coleccion_mensaje(fn e ->
        "   - #{e.productor}, #{e.tanque}, día #{e.dia}, #{e.litros} L, grasa #{e.grasa}\n"
      end)
      |> Util2.mostrar(:mensaje)
    end)

    Util2.mostrar("Total rechazadas: #{length(rechazadas)}", :mensaje)
  end

  # -------------------------------------------------------------
  # R2: litros por tanque y porcentaje de ocupación
  # -------------------------------------------------------------

  # Retorna una lista de mapas %{id, nombre, capacidad, litros, ocupacion}.
  # Un tanque sin entregas queda con 0 litros.
  def ocupacion_tanques(validas, tanques) do
    Enum.map(tanques, fn tanque ->
      litros =
        validas
        |> Enum.filter(&(&1.tanque == tanque.id))
        |> sumar_litros()

      Map.merge(tanque, %{litros: litros, ocupacion: litros * 100 / tanque.capacidad})
    end)
  end

  def r2(validas, tanques) do
    Util2.mostrar("\n===== R2. Litros por tanque =====", :mensaje)

    validas
    |> ocupacion_tanques(tanques)
    |> ranking(por: :ocupacion, orden: :desc)
    |> Util2.convertir_coleccion_mensaje(fn t ->
      "- #{t.id} #{t.nombre}: #{t.litros} L de #{t.capacidad} L (#{redondear(t.ocupacion)} %)\n"
    end)
    |> Util2.mostrar(:mensaje)
  end

  # -------------------------------------------------------------
  # R3: litros por día y meta diaria
  # -------------------------------------------------------------

  # Retorna un mapa %{dia => litros} con los 6 días.
  # (Este mapa es el que se combina después con Map.merge/3.)
  def litros_por_dia(validas) do
    Enum.reduce(@dias, %{}, fn dia, acumulador ->
      litros =
        validas
        |> Enum.filter(&(&1.dia == dia))
        |> sumar_litros()

      Map.put(acumulador, dia, litros)
    end)
  end

  def cumple_meta?(litros), do: litros >= @meta_diaria

  def r3(validas) do
    Util2.mostrar("\n===== R3. Litros por día (meta #{@meta_diaria} L) =====", :mensaje)
    por_dia = litros_por_dia(validas)

    por_dia
    |> Util2.ordenar(:asc)
    |> Util2.convertir_coleccion_mensaje(fn {dia, litros} ->
      "- Día #{dia}: #{litros} L -> #{if cumple_meta?(litros), do: "cumple", else: "no cumple"}\n"
    end)
    |> Util2.mostrar(:mensaje)

    litros = Map.values(por_dia)
    Util2.mostrar("¿Cumplió todos los días? #{si_no(Enum.all?(litros, &cumple_meta?/1))}", :mensaje)
    Util2.mostrar("¿Cumplió al menos un día? #{si_no(Enum.any?(litros, &cumple_meta?/1))}", :mensaje)
  end

  # -------------------------------------------------------------
  # R4: liquidación ordenada por neto (mayor a menor)
  # -------------------------------------------------------------

  def r4(liquidacion) do
    Util2.mostrar("\n===== R4. Liquidación (por neto, mayor a menor) =====", :mensaje)

    liquidacion
    |> ranking(por: :pago_neto, orden: :desc)
    |> Enum.with_index(1)
    |> Util2.convertir_coleccion_mensaje(fn {p, numero} ->
      "#{numero}. #{p.codigo} #{p.nombre} | litros: #{p.litros_totales} | entregas: $#{round(p.pago_bruto)}" <>
        " | bonif: $#{p.bonificacion_volumen} | transporte: $#{p.descuento_transporte} | neto: $#{round(p.pago_neto)}\n"
    end)
    |> Util2.mostrar(:mensaje)
  end

  # -------------------------------------------------------------
  # R5: productor con más litros cada día y ganador de la semana
  # -------------------------------------------------------------

  # Retorna una lista de {dia, litros_maximos, [codigos_ganadores]}.
  # Si hay empate quedan todos los códigos.
  def mayor_por_dia(validas) do
    Enum.map(@dias, fn dia ->
      totales =
        validas
        |> Enum.filter(&(&1.dia == dia))
        |> Enum.group_by(& &1.productor, & &1.litros)
        |> Enum.map(fn {codigo, litros} -> {codigo, Enum.sum(litros)} end)

      maximo = totales |> Enum.map(fn {_codigo, litros} -> litros end) |> mayor()
      ganadores = for {codigo, litros} <- totales, litros == maximo, do: codigo

      {dia, maximo, ganadores}
    end)
  end

  # Retorna {[codigos], cantidad_de_dias} de quien(es) ganó más días.
  def ganador_semana(mayores) do
    veces =
      mayores
      |> Enum.reduce([], fn {_dia, _litros, ganadores}, acumulador -> acumulador ++ ganadores end)
      |> Enum.frequencies_by(fn codigo -> codigo end)

    maximo = veces |> Map.values() |> mayor()
    {for({codigo, n} <- veces, n == maximo, do: codigo), maximo}
  end

  def r5(validas) do
    Util2.mostrar("\n===== R5. Mayor productor por día =====", :mensaje)
    mayores = mayor_por_dia(validas)

    mayores
    |> Util2.convertir_coleccion_mensaje(fn {dia, litros, ganadores} ->
      "- Día #{dia}: #{Enum.join(ganadores, ", ")} con #{litros} L\n"
    end)
    |> Util2.mostrar(:mensaje)

    {codigos, dias} = ganador_semana(mayores)
    Util2.mostrar("Ganador de la semana: #{Enum.join(codigos, ", ")} (#{dias} días en primer lugar)", :mensaje)
  end

  # -------------------------------------------------------------
  # R6: mejor calidad (grasa ponderada por litros)
  # -------------------------------------------------------------

  # suma(grasa × litros) / suma(litros)
  def grasa_ponderada(entregas) do
    suma_grasa_litros = entregas |> Enum.map(&(&1.grasa * &1.litros)) |> Enum.sum()
    suma_grasa_litros / sumar_litros(entregas)
  end

  # Promedio simple de la grasa (solo para comparar con el ponderado).
  def grasa_simple(entregas) do
    (entregas |> Enum.map(& &1.grasa) |> Enum.sum()) / length(entregas)
  end

  # Productores con al menos 3 entregas válidas, con sus dos promedios.
  def calidad_productores(validas) do
    validas
    |> Enum.group_by(& &1.productor)
    |> Enum.filter(fn {_codigo, entregas} -> length(entregas) >= @minimo_entregas_r6 end)
    |> Enum.map(fn {codigo, entregas} ->
      %{
        codigo: codigo,
        entregas: length(entregas),
        ponderada: grasa_ponderada(entregas),
        simple: grasa_simple(entregas)
      }
    end)
  end

  def r6(validas) do
    Util2.mostrar("\n===== R6. Calidad (grasa ponderada, mínimo #{@minimo_entregas_r6} entregas) =====", :mensaje)
    calidad = ranking(calidad_productores(validas), por: :ponderada, orden: :desc)

    calidad
    |> Util2.convertir_coleccion_mensaje(fn c ->
      "- #{c.codigo}: #{c.entregas} entregas | ponderada #{redondear(c.ponderada, 3)} % | simple #{redondear(c.simple, 3)} %\n"
    end)
    |> Util2.mostrar(:mensaje)

    case calidad do
      [] -> Util2.mostrar("Ningún productor tiene #{@minimo_entregas_r6} entregas válidas", :mensaje)
      [mejor | _] -> Util2.mostrar("Mejor calidad: #{mejor.codigo} con #{redondear(mejor.ponderada, 3)} %", :mensaje)
    end
  end

  # -------------------------------------------------------------
  # R7: total pagado y costo promedio por litro
  # -------------------------------------------------------------

  # Retorna {total_pagado, total_litros, costo_por_litro}.
  def total_pagado(liquidacion) do
    total = liquidacion |> Enum.map(& &1.pago_neto) |> Enum.sum()
    litros = liquidacion |> Enum.map(& &1.litros_totales) |> Enum.sum()
    {total, litros, total / litros}
  end

  def r7(liquidacion) do
    {total, litros, costo_litro} = total_pagado(liquidacion)

    Util2.mostrar("\n===== R7. Total pagado =====", :mensaje)
    Util2.mostrar("Total pagado en la semana: $#{round(total)}", :mensaje)
    Util2.mostrar("Litros pagados: #{litros} L", :mensaje)
    Util2.mostrar("Costo promedio por litro: $#{redondear(costo_litro, 2)}", :mensaje)
  end

  # -------------------------------------------------------------
  # R8: productores con entregas válidas en todos los tanques
  # -------------------------------------------------------------

  # Un productor cumple si, para TODOS los tanques (Enum.all?), tiene AL MENOS
  # UNA entrega válida en ese tanque (Enum.any?).
  def en_todos_los_tanques(validas, productores, tanques) do
    Enum.filter(productores, fn productor ->
      Enum.all?(tanques, fn tanque ->
        Enum.any?(validas, &(&1.productor == productor.codigo and &1.tanque == tanque.id))
      end)
    end)
  end

  def r8(validas, productores, tanques) do
    Util2.mostrar("\n===== R8. Productores que entregaron en los #{length(tanques)} tanques =====", :mensaje)

    validas
    |> en_todos_los_tanques(productores, tanques)
    |> Util2.convertir_coleccion_mensaje(fn p -> "- #{p.codigo} #{p.nombre}\n" end)
    |> Util2.mostrar(:mensaje)
  end

  # -------------------------------------------------------------
  # Auxiliares
  # -------------------------------------------------------------

  defp sumar_litros(lista), do: lista |> Enum.map(& &1.litros) |> Enum.sum()

  # Mayor valor de una lista de números positivos. Si la lista está vacía, retorna 0.
  defp mayor(numeros) do
    Enum.reduce(numeros, 0, fn numero, mayor_actual ->
      if numero > mayor_actual, do: numero, else: mayor_actual
    end)
  end

  defp redondear(numero, decimales \\ 1), do: Float.round(numero / 1, decimales)

  defp si_no(true), do: "Sí"
  defp si_no(false), do: "No"
end

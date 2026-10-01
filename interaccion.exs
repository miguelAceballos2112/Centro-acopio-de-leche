# Integrantes: Miguel Angel Ceballos Soler (Integrante 1), Victor Manuel Bolaños Guzman (Integrante 2),
#              Juan José Ramírez Londoño (Integrante 3)

defmodule Interaccion do
  @moduledoc """
  Entrada y salida por consola: entrega adicional y comprobante del productor.
  """

  @doc """
  Pide una entrega adicional con el formato `productor;tanque;dia;litros;grasa`.
  Si el usuario solo presiona Enter, retorna `:omitir`.
  Si el formato no es correcto, retorna `{:error, :formato_invalido}`.
  """
  def solicitar_entrega_adicional do
    Util2.mostrar("\n==================================================", :mensaje)
    Util2.mostrar("          REGISTRO DE ENTREGA ADICIONAL           ", :mensaje)
    Util2.mostrar("==================================================", :mensaje)
    Util2.mostrar("Ingrese una entrega adicional (productor;tanque;dia;litros;grasa)", :mensaje)
    entrada = IO.gets("o Enter para omitir: ")

    case entrada do
      :eof ->
        :omitir

      texto ->
        parsear_entrega_adicional(texto)
    end
  end

  @doc """
  Convierte el texto en una entrega sin usar try/rescue.
  Usa Integer.parse/1 para el día y Float.parse/1 para los litros y la grasa.
  """
  def parsear_entrega_adicional(texto) when is_binary(texto) do
    limpio = String.trim(texto)

    if limpio == "" do
      :omitir
    else
      campos = String.split(limpio, ";")

      case campos do
        [productor, tanque, texto_dia, texto_litros, texto_grasa] ->
          with {:ok, dia} <- convertir_entero(texto_dia),
               {:ok, litros} <- convertir_numero(texto_litros),
               {:ok, grasa} <- convertir_numero(texto_grasa) do
            {:ok, %{
              productor: String.trim(productor),
              tanque: String.trim(tanque),
              dia: dia,
              litros: litros,
              grasa: grasa
            }}
          else
            _error -> {:error, :formato_invalido}
          end

        _otro ->
          {:error, :formato_invalido}
      end
    end
  end

  # Integer.parse("4") retorna {4, ""}. Si sobra texto, no es un entero.
  defp convertir_entero(texto) do
    case Integer.parse(String.trim(texto)) do
      {numero, ""} -> {:ok, numero}
      _otro -> {:error, :formato_invalido}
    end
  end

  # Float.parse acepta "300" y "320.5". Si sobra texto, no es un número.
  defp convertir_numero(texto) do
    case Float.parse(String.trim(texto)) do
      {numero, ""} -> {:ok, numero}
      _otro -> {:error, :formato_invalido}
    end
  end

  @doc """
  Pide el código de un productor y muestra su comprobante.
  Si el código no existe, muestra un mensaje de error sin detener el programa.
  """
  def mostrar_comprobante(productores, entregas_validas, liquidaciones) do
    Util2.mostrar("\n==================================================", :mensaje)
    Util2.mostrar("             COMPROBANTE DE PRODUCTOR             ", :mensaje)
    Util2.mostrar("==================================================", :mensaje)
    entrada = IO.gets("Ingrese el código del productor (ej. P01): ")

    codigo =
      case entrada do
        :eof -> ""
        texto -> String.trim(texto)
      end

    productor = Enum.find(productores, fn p -> p.codigo == codigo end)

    if productor == nil do
      Util2.mostrar("\n  [ERROR] El código de productor '#{codigo}' no existe en el sistema.", :mensaje)
    else
      liquidacion = Enum.find(liquidaciones, fn l -> l.codigo == codigo end)
      entregas_productor = Enum.filter(entregas_validas, fn e -> e.productor == codigo end)

      Util2.mostrar("\n--------------------------------------------------", :mensaje)
      Util2.mostrar("COMPROBANTE FINANCIERO - CENTRO DE ACOPIO DE LECHE", :mensaje)
      Util2.mostrar("--------------------------------------------------", :mensaje)
      Util2.mostrar("Productor: #{productor.nombre} (#{productor.codigo})", :mensaje)
      Util2.mostrar("Usa Servicio de Transporte: #{if productor.transporte, do: "SÍ", else: "NO"}", :mensaje)
      Util2.mostrar("--------------------------------------------------", :mensaje)
      Util2.mostrar("DETALLE POR DÍA CON ENTREGAS VÁLIDAS:", :mensaje)

      entregas_por_dia = Enum.group_by(entregas_productor, & &1.dia)

      if Enum.empty?(entregas_por_dia) do
        Util2.mostrar("  (No registró entregas válidas en la semana)", :mensaje)
      else
        Enum.each(Enum.sort(Map.keys(entregas_por_dia)), fn dia ->
          entregas_dia = Map.get(entregas_por_dia, dia)
          litros_dia = Enum.sum_by(entregas_dia, & &1.litros)
          valor_dia = Enum.reduce(entregas_dia, 0.0, fn e, acumulado -> acumulado + Calculos.valor_entrega(e) end)
          bonificacion_dia = Calculos.bonificacion_dia(litros_dia)

          Util2.mostrar("  - Día #{dia}: #{litros_dia} L | Valor Entregas: $#{round(valor_dia)} | Bonificación Día: $#{bonificacion_dia}", :mensaje)
        end)
      end

      Util2.mostrar("--------------------------------------------------", :mensaje)
      Util2.mostrar("RESUMEN GENERAL DE LA SEMANA:", :mensaje)
      Util2.mostrar("  Total Entregas Válidas: #{liquidacion.entregas_count}", :mensaje)
      Util2.mostrar("  Total Litros Entregados: #{liquidacion.litros_totales} L", :mensaje)
      Util2.mostrar("  Valor Bruto Entregas:  $#{round(liquidacion.pago_bruto)}", :mensaje)
      Util2.mostrar("  (+) Bonif. Volumen:    $#{liquidacion.bonificacion_volumen}", :mensaje)
      Util2.mostrar("  (-) Descuento Transp:  $#{liquidacion.descuento_transporte}", :mensaje)
      Util2.mostrar("--------------------------------------------------", :mensaje)
      Util2.mostrar("  NETO A PAGAR:          $#{round(liquidacion.pago_neto)}", :mensaje)
      Util2.mostrar("--------------------------------------------------\n", :mensaje)
    end
  end
end

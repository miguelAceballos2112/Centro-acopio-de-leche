defmodule Interaccion do
  @moduledoc """
  Módulo para la gestión de Entrada/Salida (E/S) con el usuario por consola.
  Maneja la captura de entregas adicionales y la consulta de comprobantes por productor.
  """

  @doc """
  Solicita por consola una entrega adicional en formato `productor;tanque;dia;litros;grasa`.
  Si el usuario presiona Enter sin escribir nada, retorna `:omitir`.
  Si la entrada es inválida, retorna `{:error, :formato_invalido}`.
  """
  def solicitar_entrega_adicional do
    IO.puts("\n==================================================")
    IO.puts("          REGISTRO DE ENTREGA ADICIONAL           ")
    IO.puts("==================================================")
    IO.puts("Ingrese una entrega adicional (productor;tanque;dia;litros;grasa)")
    input = IO.gets("o Enter para omitir: ")

    case input do
      :eof ->
        :omitir

      cadena ->
        parsear_entrega_adicional(cadena)
    end
  end

  @doc """
  Parsea una cadena recibida por consola sin utilizar try/rescue.
  Usa Integer.parse/1 y Float.parse/1 de forma segura.
  """
  def parsear_entrega_adicional(cadena) when is_binary(cadena) do
    limpia = String.trim(cadena)

    if limpia == "" do
      :omitir
    else
      campos = String.split(limpia, ";")

      case campos do
        [prod, tanq, dia_str, lit_str, grasa_str] ->
          with {:ok, dia} <- parse_integer(dia_str),
               {:ok, litros} <- parse_number(lit_str),
               {:ok, grasa} <- parse_number(grasa_str) do
            {:ok, %{
              productor: String.trim(prod),
              tanque: String.trim(tanq),
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

  defp parse_integer(str) do
    str = String.trim(str)
    case Integer.parse(str) do
      {num, ""} -> {:ok, num}
      _otro -> {:error, :formato_invalido}
    end
  end

  defp parse_number(str) do
    str = String.trim(str)
    case Float.parse(str) do
      {num, ""} -> {:ok, num}
      _otro ->
        case Integer.parse(str) do
          {num, ""} -> {:ok, num * 1.0}
          _otro -> {:error, :formato_invalido}
        end
    end
  end

  @doc """
  Solicita el código del productor e imprime el comprobante detallado.
  Si el productor no existe, lo notifica amablemente sin fallar el programa.
  """
  def mostrar_comprobante(productores, entregas_validas, liquidaciones) do
    IO.puts("\n==================================================")
    IO.puts("             COMPROBANTE DE PRODUCTOR             ")
    IO.puts("==================================================")
    input = IO.gets("Ingrese el código del productor (ej. P01): ")

    codigo =
      case input do
        :eof -> ""
        str -> String.trim(str)
      end

    productor = Enum.find(productores, fn p -> p.codigo == codigo end)

    if productor == nil do
      IO.puts("\n️  [ERROR] El código de productor '#{codigo}' no existe en el sistema.")
    else
      liq = Enum.find(liquidaciones, fn l -> l.codigo == codigo end)
      entregas_p = Enum.filter(entregas_validas, fn e -> e.productor == codigo end)

      IO.puts("\n--------------------------------------------------")
      IO.puts("COMPROBANTE FINANCIERO - CENTRO DE ACOPIO DE LECHE")
      IO.puts("--------------------------------------------------")
      IO.puts("Productor: #{productor.nombre} (#{productor.codigo})")
      IO.puts("Usa Servicio de Transporte: #{if productor.transporte, do: "SÍ", else: "NO"}")
      IO.puts("--------------------------------------------------")
      IO.puts("DETALLE POR DÍA CON ENTREGAS VÁLIDAS:")

      entregas_por_dia = Enum.group_by(entregas_p, & &1.dia)

      if Enum.empty?(entregas_por_dia) do
        IO.puts("  (No registró entregas válidas en la semana)")
      else
        Enum.each(Enum.sort(Map.keys(entregas_por_dia)), fn dia ->
          entregas_dia = Map.get(entregas_por_dia, dia)
          litros_dia = Enum.sum_by(entregas_dia, & &1.litros)
          valor_dia = Enum.reduce(entregas_dia, 0.0, fn e, acc -> acc + Calculos.valor_entrega(e) end)
          bonif_dia = if litros_dia >= 450, do: 25000, else: 0

          IO.puts("  • Día #{dia}: #{litros_dia} L | Valor Entregas: $#{Float.round(valor_dia, 2)} | Bonificación Día: $#{bonif_dia}")
        end)
      end

      IO.puts("--------------------------------------------------")
      IO.puts("RESUMEN GENERAL DE LA SEMANA:")
      IO.puts("  Total Entregas Válidas: #{liq.entregas_count}")
      IO.puts("  Total Litros Entregados: #{liq.litros_totales} L")
      IO.puts("  Valor Bruto Entregas:  $#{Float.round(liq.pago_bruto, 2)}")
      IO.puts("  (+) Bonif. Volumen:    $#{liq.bonificacion_volumen}")
      IO.puts("  (-) Descuento Transp:  $#{liq.descuento_transporte}")
      IO.puts("--------------------------------------------------")
      IO.puts("  NETO A PAGAR:          $#{Float.round(liq.pago_neto, 2)}")
      IO.puts("--------------------------------------------------\n")
    end
  end
end

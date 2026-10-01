# Carga de todos los módulos del proyecto
Code.require_file("Util2.ex", __DIR__)
Code.require_file("datos.exs", __DIR__)
Code.require_file("validacion.exs", __DIR__)
Code.require_file("calculos.exs", __DIR__)
Code.require_file("reportes.exs", __DIR__)
Code.require_file("investigacion.exs", __DIR__)
Code.require_file("interaccion.exs", __DIR__)

defmodule Main do
  @moduledoc """
  Orquestador principal del sistema de liquidación del Centro de Acopio de Leche.
  Autores:
    - Miguel Angel Ceballos Soler (Integrante 1: Datos, Validación y Lógica)
    - Victor Manuel Bolaños Guzman (Integrante 2: Reportes R1 a R8)
    - Juan josé Ramírez londoño (Integrante 3: Interacción, Comprobantes y Orquestación)
  """

  def ejecutar do
    IO.puts("==================================================")
    IO.puts("   SISTEMA DE ACOPIO DE LECHE - PROGRAMACIÓN III  ")
    IO.puts("==================================================\n")

    # 1. Cargar datos iniciales
    productores = Datos.productores()
    tanques = Datos.tanques()
    entregas_base = Datos.entregas()

    # 2. Solicitar entrega adicional (Interacción E/S)
    entregas_totales =
      case Interaccion.solicitar_entrega_adicional() do
        {:ok, entrega_nueva} ->
          IO.puts(" Entrega adicional aceptada e incorporada al procesamiento.\n")
          entregas_base ++ [entrega_nueva]

        {:error, :formato_invalido} ->
          IO.puts("  [ERROR] Formato de entrega inválido. Se omitirá la entrega adicional.\n")
          entregas_base

        :omitir ->
          IO.puts("  Entrega adicional omitida.\n")
          entregas_base
      end

    # 3. Medir tiempo de procesamiento con :timer.tc/1
    {tiempo_us, {validas, rechazadas, liquidaciones}} =
      :timer.tc(fn ->
        {val, rech} = Validacion.clasificar_entregas(entregas_totales, productores, tanques)
        liq = Calculos.liquidacion_general(productores, val)
        {val, rech, liq}
      end)

    IO.puts("--------------------------------------------------")
    IO.puts("  Tiempo de procesamiento de datos: #{tiempo_us} µs (#{:erlang.float_to_binary(tiempo_us / 1000, decimals: 2)} ms)")
    IO.puts("--------------------------------------------------\n")

    # 4. Generar Reportes R1 a R8 (Módulo del Integrante 2)
    Reportes.generar(validas, rechazadas, productores, tanques, liquidaciones)

    # 5. Generar Comprobante Individual por Productor
    Interaccion.mostrar_comprobante(productores, validas, liquidaciones)

    # 6. Demostración de Investigación (Map.merge/3)
    IO.puts("\n==================================================")
    IO.puts("        INVESTIGACIÓN: COMBINACIÓN DE CENTROS     ")
    IO.puts("==================================================")
    mapa_r3 = Reportes.litros_por_dia(validas)
    centro_vecino = %{1 => 1850.5, 2 => 2100.0, 3 => 1640.0, 5 => 2350.0, 7 => 800.0}
    mapa_combinado = Investigacion.combinar_centros(mapa_r3, centro_vecino)

    IO.puts("Mapa R3 (Centro Principal): #{inspect(mapa_r3)}")
    IO.puts("Mapa Centro Vecino:         #{inspect(centro_vecino)}")
    IO.puts("Mapa Combinado (Merge/3):   #{inspect(mapa_combinado)}")
    IO.puts("==================================================\n")
  end
end

Main.ejecutar()

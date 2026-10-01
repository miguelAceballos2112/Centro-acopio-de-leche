# Integrantes: Miguel Angel Ceballos Soler (Integrante 1), Victor Manuel Bolaños Guzman (Integrante 2),
#              Juan José Ramírez Londoño (Integrante 3)

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
    - Juan José Ramírez Londoño (Integrante 3: Interacción, Comprobantes y Orquestación)
  """

  @repeticiones 1000

  def ejecutar do
    IO.puts("==================================================")
    IO.puts("   SISTEMA DE ACOPIO DE LECHE - PROGRAMACIÓN III  ")
    IO.puts("==================================================\n")

    # 1. Cargar datos iniciales
    productores = Datos.productores()
    tanques = Datos.tanques()
    entregas_base = Datos.entregas()

    # 2. Validar las entregas iniciales
    {validas_base, rechazadas_base} =
      Validacion.clasificar_entregas(entregas_base, productores, tanques)

    # 3. Solicitar entrega adicional y pasarla por las mismas reglas de validación
    {validas, rechazadas} =
      agregar_entrega_adicional(validas_base, rechazadas_base, productores, tanques)

    # 4. Liquidar a todos los productores
    liquidaciones = Calculos.liquidacion_general(productores, validas)

    # 5. Mediciones con :timer.tc/1 (promedio de varias repeticiones)
    tiempo_validacion =
      medir_promedio(fn -> Validacion.clasificar_entregas(entregas_base, productores, tanques) end)

    tiempo_liquidacion =
      medir_promedio(fn -> Calculos.liquidacion_general(productores, validas) end)

    IO.puts("--------------------------------------------------")
    IO.puts("  Promedio de #{@repeticiones} repeticiones medidas con :timer.tc/1")
    IO.puts("  Validación (#{length(entregas_base)} entregas): #{Float.round(tiempo_validacion, 2)} µs")
    IO.puts("  Liquidación (#{length(productores)} productores): #{Float.round(tiempo_liquidacion, 2)} µs")
    IO.puts("--------------------------------------------------\n")

    # 6. Generar Reportes R1 a R8 (Módulo del Integrante 2)
    Reportes.generar(validas, rechazadas, productores, tanques, liquidaciones)

    # 7. Generar Comprobante Individual por Productor
    Interaccion.mostrar_comprobante(productores, validas, liquidaciones)

    # 8. Demostración de Investigación (Map.merge/2 frente a Map.merge/3)
    IO.puts("\n==================================================")
    IO.puts("        INVESTIGACIÓN: COMBINACIÓN DE CENTROS     ")
    IO.puts("==================================================")
    mapa_r3 = Reportes.litros_por_dia(validas)
    centro_vecino = %{1 => 1850.5, 2 => 2100, 3 => 1640, 5 => 2350, 7 => 800}

    IO.puts("Mapa R3 (Centro Principal): #{inspect(mapa_r3)}")
    IO.puts("Mapa Centro Vecino:         #{inspect(centro_vecino)}")
    IO.puts("Con Map.merge/2:            #{inspect(Investigacion.combinar_sin_sumar(mapa_r3, centro_vecino))}")
    IO.puts("Con Map.merge/3:            #{inspect(Investigacion.combinar_centros(mapa_r3, centro_vecino))}")
    IO.puts("==================================================\n")
  end

  # Ejecuta la función @repeticiones veces y retorna el tiempo promedio en microsegundos.
  # Se repite porque una sola ejecución tarda menos que la resolución del reloj.
  defp medir_promedio(funcion) do
    {tiempo_total, :ok} = :timer.tc(fn -> Enum.each(1..@repeticiones, fn _ -> funcion.() end) end)
    tiempo_total / @repeticiones
  end

  # Pide la entrega adicional. Si el formato es correcto, se valida con las mismas
  # reglas que los datos iniciales y se agrega a las válidas o a las rechazadas.
  defp agregar_entrega_adicional(validas, rechazadas, productores, tanques) do
    case Interaccion.solicitar_entrega_adicional() do
      {:ok, entrega} ->
        case Validacion.validar_entrega(entrega, productores, tanques) do
          {:ok, entrega_valida} ->
            IO.puts("  Entrega adicional válida. Se incorpora a todos los reportes.\n")
            {validas ++ [entrega_valida], rechazadas}

          {:error, motivo} ->
            IO.puts("  Entrega adicional rechazada por #{motivo}. Aparecerá en R1.\n")
            {validas, rechazadas ++ [%{entrega: entrega, motivo: motivo}]}
        end

      {:error, :formato_invalido} ->
        IO.puts("  [ERROR] Formato de entrega inválido. Se omitirá la entrega adicional.\n")
        {validas, rechazadas}

      :omitir ->
        IO.puts("  Entrega adicional omitida.\n")
        {validas, rechazadas}
    end
  end
end

Main.ejecutar()

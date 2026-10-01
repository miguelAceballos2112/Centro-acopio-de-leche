defmodule Reportes do
  @moduledoc """
  Módulo de reportes R1 a R8 (provisional para pruebas del orquestador).
  """

  def generar_todos(_productores, _tanques, _validas, _rechazadas, _liquidaciones) do
    IO.puts("\n--- GENERANDO REPORTES R1 A R8 ---")
    IO.puts("   (Esperando implementación final de Integrante 2)\n")
  end

  def litros_diarios_mapa(validas) do
    validas
    |> Enum.group_by(& &1.dia)
    |> Enum.map(fn {dia, entregas} -> {dia, Enum.sum_by(entregas, & &1.litros)} end)
    |> Enum.into(%{})
  end
end

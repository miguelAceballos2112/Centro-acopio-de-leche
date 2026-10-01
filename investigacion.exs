defmodule Investigacion do
  @moduledoc """
  Modulo para investigacion: combinacion de datos entre centros de acopio.
  Aqui demostramos el uso de Map.merge/3 para consolidar los litros diarios de leche
  """

  @doc """
  Combina el mapa de litros diarios de R3 (centro principal) con el mapa de centro vecino.
  Aqui sumamos los litros d elos dias que coinciden y conserva los dias unicos de cada centro.
  """
  def combinar_centros(mapa_r3, centro_vecino) do
    Map.merge(mapa_r3, centro_vecino, fn _dia, litros_r3, litros_vecio
    -> litros_r3 + litros_vecio
    end)
  end

  @doc """
  Esta funcion es auxiliar para comparar los resultados entre Map.merge/2 y Map.merge/3
  en la terminal
  """
  def demo_diferencia_merge(mapa_r3, centro_vecino) do
    %{
      merge_2_sobrescrito: Map.merge(mapa_r3, centro_vecino),
      merge_3_sumado: Map.merge(mapa_r3, centro_vecino, fn _k, v1, v2 -> v1 + v2 end)
    }
  end
end

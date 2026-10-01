# Integrantes: Miguel Angel Ceballos Soler (Integrante 1), Victor Manuel Bolaños Guzman (Integrante 2),
#              Juan José Ramírez Londoño (Integrante 3)

defmodule Investigacion do
  @moduledoc """
  Modulo para investigacion: combinacion de datos entre centros de acopio.
  Aqui demostramos el uso de Map.merge/3 para consolidar los litros diarios de leche
  """

  @doc """
  Combina el mapa de litros diarios de R3 (centro principal) con el mapa de centro vecino.
  Aqui sumamos los litros de los dias que coinciden y se conservan los dias unicos de cada centro.
  """
  def combinar_centros(mapa_r3, centro_vecino) do
    Map.merge(mapa_r3, centro_vecino, fn _dia, litros_r3, litros_vecino ->
      litros_r3 + litros_vecino
    end)
  end

  @doc """
  Combinacion con Map.merge/2 (sin funcion). Solo se usa para mostrar en la terminal
  que el valor del centro vecino sobrescribe al de R3 cuando el dia se repite.
  """
  def combinar_sin_sumar(mapa_r3, centro_vecino) do
    Map.merge(mapa_r3, centro_vecino)
  end
end

defmodule Ranking do
  @moduledoc """
  Módulo de ordenamiento genérico para el proyecto.
  Cumple con la exigencia de implementar ranking/2 utilizando Keyword Lists
  """

  @doc """
  Ordena una colección según las opciones especificadas en la Keyword List `opts`
  """
  def ranking(coleccion, opts \\ []) when is_list(coleccion) and is_list(opts) do
    by_func = Keyword.get(opts, :by, fn x -> x end)
    order = Keyword.get(opts, :order, :desc)

    Enum.sort_by(coleccion, by_func, fn a, b ->
      case order do
        :desc -> a >= b
        :asc -> a <= b
      end
    end)
  end
end

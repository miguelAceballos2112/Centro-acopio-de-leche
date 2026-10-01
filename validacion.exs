# Integrantes: Miguel Angel Ceballos Soler (Integrante 1), Victor Manuel Bolaños Guzman (Integrante 2),
#              Juan José Ramírez Londoño (Integrante 3)

defmodule Validacion do
  @dias 1..6
  @max_litros 800
  @grasa_minima 0
  @grasa_maxima 15

  def validar_entrega(entrega, productores, tanques) do
    with {:ok, _productor} <- verificar_productor(entrega.productor, productores),
         {:ok, _tanque} <- verificar_tanque(entrega.tanque, tanques),
         {:ok, _dia} <- verificar_dia(entrega.dia),
         {:ok, _litros} <- verificar_litros(entrega.litros),
         {:ok, _grasa} <- verificar_grasa(entrega.grasa) do
      {:ok, entrega}
    else
      {:error, motivo} -> {:error, motivo}
    end
  end

  def clasificar_entregas(entregas, productores, tanques) do
    Enum.reduce(entregas, {[], []}, fn entrega, {validas, rechazadas} ->
      case validar_entrega(entrega, productores, tanques) do
        {:ok, entrega_valida} ->
          {[entrega_valida | validas], rechazadas}
        {:error, motivo} ->
          {validas, [%{entrega: entrega, motivo: motivo} | rechazadas]}
      end
    end)
    |> reparar_orden()
  end

  defp reparar_orden({validas, rechazadas}) do
    {Enum.reverse(validas), Enum.reverse(rechazadas)}
  end

  defp verificar_productor(codigo, productores) do
    if Enum.any?(productores, fn p -> p.codigo == codigo end) do
      {:ok, codigo}
    else
      {:error, :productor_desconocido}
    end
  end

  defp verificar_tanque(id_tanque, tanques) do
    if Enum.any?(tanques, fn t -> t.id == id_tanque end) do
      {:ok, id_tanque}
    else
      {:error, :tanque_desconocido}
    end
  end

  defp verificar_dia(dia) when is_integer(dia) and dia in @dias, do: {:ok, dia}
  defp verificar_dia(_), do: {:error, :dia_invalido}

  defp verificar_litros(litros) when is_number(litros)
  and litros > 0 and litros <= @max_litros, do: {:ok, litros}
  defp verificar_litros(_), do: {:error, :litros_fuera_de_rango}

  defp verificar_grasa(grasa) when is_number(grasa)
  and grasa >= @grasa_minima and grasa <= @grasa_maxima, do: {:ok, grasa}
  defp verificar_grasa(_), do: {:error, :porcentaje_invalido}
end

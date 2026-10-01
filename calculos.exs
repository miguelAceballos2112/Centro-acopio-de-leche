defmodule Calculos do
  @moduledoc """
   Modulo para las reglas de negocio y calculos financieron para la liquidacion de la leche
   Aplica las tarifas base, bonificaciones por grasa, bonificaciones por volumen diario
   y descuentos por transporte exigidos en el proyecto
"""
  @tarifa_base 1800
  @bonificacion_volumen 25000
  @litros_min_volumen 450
  @costo_transporte 18000

  def valor_entrega(entrega) do
    ajuste = factor_grasa(entrega.grasa)
    entrega.litros * @tarifa_base * (1*ajuste)
  end

  def factor_grasa(grasa) when grasa >= 3.5, do: 0.06
  def factor_grasa(grasa) when grasa >= 3.0, do: 0.0
  def factor_grasa(grasa) when grasa >= 2.5, do: -0.08
  def factor_grasa(_grasa), do: -0.20

  def bonificacion_volumen_total(entregas_productor) do
    entregas_productor
    |> Enum.group_by(& &1.dia)
    |> Enum.reduce(0, fn {_dia, entregas_dia}, acumulado ->
      litros_dia = Enum.sum_by(entregas_dia, & &1.litros)
      if litros_dia > @litros_min_volumen do
        acumulado + @bonificacion_volumen
      else
        acumulado
      end
    end)
  end

  def descuento_transporte_total(productor, entregas_productor) do
    if productor.transporte do
      entregas_productor
      |> Enum.map(& &1.dia)
      |> Enum.uniq()
      |> Enum.count()

    dias_activos * @costo_transporte
    else
      0
    end
  end

  def liquidacion_productor(productor, entregas_validas_totales) do
    entregas_p = Enum.filter(entregas_validas_totales, fn e -> e.productor == productor.codigo
    end)
    litros_totales = Enum.sum_by(entregas_p, & &1.litros)
    pago_bruto = Enum.reduce(entregas_p, 0.0, fn e, acc -> acc + valor_entrega(e)
    end)
    bonif_volumen = bonificacion_volumen_total(entregas_p)
    descuento_transporte = descuento_transporte_total(productor, entregas_p)
    pago_neto = pago_bruto + bonif_volumen - descuento_transporte

    %{
      codigo: productor.codigo,
      nombre: productor.nombre,
      transporte: productor.transporte,
      entregas_count: Enum.count(entregas_p),
      litros_totales: litros_totales,
      pago_bruto: pago_bruto,
      bonificacion_volumen: bonif_volumen,
      descuento_transporte: descuento_transporte,
      pago_neto: pago_neto
    }
  end

  def liquidacion_general(productores, entregas_validas_totales) do
    Enum.map(productores, fn p -> liquidacion_productor(p, entregas_validas_totales)
    end)
  end
end

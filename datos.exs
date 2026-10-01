# Integrantes: Miguel Angel Ceballos Soler (Integrante 1), Victor Manuel Bolaños Guzman (Integrante 2),
#              Juan José Ramírez Londoño (Integrante 3)

defmodule Datos do
  @moduledoc """
   Módulo de datos iniciales para el proyecto del Centro de Acopio de Leche.
   Contiene los productores, tanques y el registro completo de entregas (10 inválidas y 80 válidas).
  """

  @doc"""
   Retorna la lista de 10 productores de la región. 4 de ellos utilizan servicio de transporte
   """
  def productores do
    [
      %{codigo: "P01", nombre: "Marta Gómez", transporte: true},
      %{codigo: "P02", nombre: "Luis Cardona", transporte: false},
      %{codigo: "P03", nombre: "Ana Rodríguez", transporte: true},
      %{codigo: "P04", nombre: "Jorge Valencia", transporte: true},
      %{codigo: "P05", nombre: "Sofía Jaramillo", transporte: false},
      %{codigo: "P06", nombre: "Carlos Ospina", transporte: true},
      %{codigo: "P07", nombre: "Elena Morales", transporte: false},
      %{codigo: "P08", nombre: "Mario Ríos", transporte: false},
      %{codigo: "P09", nombre: "Diana Beltrán", transporte: false},
      %{codigo: "P10", nombre: "Gonzalo Patiño", transporte: false}
    ]
  end

  @doc"""
   Retorna los 4 tanques del centro de acopio con su respectiva capacidad nominal en litros
   """
  def tanques do
    [
      %{id: "T1", nombre: "Tanque Norte", capacidad: 5000},
      %{id: "T2", nombre: "Tanque Central", capacidad: 4000},
      %{id: "T3", nombre: "Tanque Sur", capacidad: 4500},
      %{id: "T4", nombre: "Tanque Reserva", capacidad: 3000}
    ]
  end

  @doc """
  Retorna el total de entregas (10 entregas inválidas + 80 entregas válidas)
  """
  def entregas do
    invalidas() ++ validas()
  end

  defp invalidas do
    [
      %{productor: "P99", tanque: "T1", dia: 1, litros: 200, grasa: 3.6},
      %{productor: "PX0", tanque: "T2", dia: 2, litros: 150, grasa: 3.2},

      %{productor: "P01", tanque: "T99", dia: 1, litros: 180, grasa: 3.4},
      %{productor: "P02", tanque: "TX4", dia: 3, litros: 210, grasa: 3.1},

      %{productor: "P01", tanque: "T1", dia: 0, litros: 200, grasa: 3.8},
      %{productor: "P03", tanque: "T2", dia: 7, litros: 250, grasa: 3.5},

      %{productor: "P02", tanque: "T1", dia: 2, litros: 0, grasa: 3.2},
      %{productor: "P04", tanque: "T3", dia: 4, litros: 850, grasa: 3.6},

      %{productor: "P05", tanque: "T2", dia: 3, litros: 190, grasa: -0.5},
      %{productor: "P06", tanque: "T4", dia: 5, litros: 220, grasa: 15.5}
    ]
  end

  defp validas do
    [
      {"P01", "T1", 1, 250, 3.8},
      {"P01", "T2", 1, 220, 3.6},
      {"P02", "T1", 1, 180, 3.2},
      {"P03", "T1", 1, 300, 3.7},
      {"P03", "T3", 1, 200, 3.5},
      {"P04", "T2", 1, 280, 3.4},
      {"P05", "T3", 1, 150, 2.8},
      {"P06", "T4", 1, 190, 3.9},
      {"P07", "T1", 1, 120, 2.4},
      {"P08", "T2", 1, 160, 3.1},
      {"P09", "T3", 1, 700, 2.6},
      {"P10", "T4", 1, 140, 2.9},
      {"P01", "T3", 1, 100, 3.6},
      {"P03", "T4", 1, 120, 3.8},

      {"P01", "T2", 2, 260, 3.9},
      {"P01", "T4", 2, 200, 3.7},
      {"P02", "T2", 2, 190, 3.1},
      {"P03", "T2", 2, 280, 3.6},
      {"P04", "T1", 2, 270, 3.5},
      {"P05", "T3", 2, 160, 2.7},
      {"P06", "T1", 2, 210, 3.8},
      {"P07", "T4", 2, 130, 2.3},
      {"P08", "T3", 2, 170, 3.2},
      {"P09", "T1", 2, 60, 4.2},
      {"P10", "T2", 2, 150, 2.8},
      {"P03", "T4", 2, 180, 3.5},
      {"P06", "T3", 2, 110, 3.6},

      {"P01", "T1", 3, 240, 3.7},
      {"P02", "T3", 3, 200, 3.0},
      {"P03", "T1", 3, 290, 3.8},
      {"P04", "T3", 3, 260, 3.3},
      {"P05", "T2", 3, 170, 2.9},
      {"P06", "T2", 3, 230, 3.7},
      {"P07", "T2", 3, 140, 2.5},
      {"P08", "T4", 3, 180, 3.3},
      {"P09", "T3", 3, 60, 4.2},
      {"P10", "T2", 3, 160, 3.0},
      {"P01", "T3", 3, 210, 3.8},
      {"P03", "T3", 3, 170, 3.6},
      {"P06", "T3", 3, 120, 3.9},

      {"P01", "T4", 4, 250, 3.6},
      {"P02", "T1", 4, 210, 3.2},
      {"P03", "T2", 4, 310, 3.9},
      {"P04", "T4", 4, 250, 3.4},
      {"P05", "T1", 4, 180, 2.8},
      {"P06", "T1", 4, 240, 3.8},
      {"P07", "T3", 4, 150, 2.4},
      {"P08", "T1", 4, 190, 3.1},
      {"P09", "T1", 4, 60, 4.2},
      {"P10", "T1", 4, 170, 2.9},
      {"P01", "T1", 4, 200, 3.7},
      {"P03", "T1", 4, 160, 3.7},
      {"P04", "T3", 4, 140, 3.5},

      {"P01", "T2", 5, 270, 3.8},
      {"P02", "T4", 5, 190, 3.1},
      {"P03", "T3", 5, 100, 3.8},
      {"P04", "T1", 5, 80, 3.6},
      {"P05", "T4", 5, 160, 2.6},
      {"P06", "T2", 5, 220, 3.7},
      {"P07", "T1", 5, 130, 2.5},
      {"P08", "T2", 5, 180, 3.2},
      {"P09", "T1", 5, 60, 4.2},
      {"P10", "T4", 5, 150, 2.8},
      {"P01", "T1", 5, 170, 3.6},
      {"P03", "T1", 5, 150, 3.9},
      {"P06", "T3", 5, 130, 3.8},

      {"P01", "T3", 6, 260, 3.7},
      {"P02", "T1", 6, 200, 3.0},
      {"P03", "T4", 6, 320, 3.9},
      {"P04", "T3", 6, 270, 3.5},
      {"P05", "T2", 6, 170, 2.7},
      {"P06", "T4", 6, 230, 3.8},
      {"P07", "T4", 6, 140, 2.4},
      {"P08", "T3", 6, 190, 3.1},
      {"P09", "T3", 6, 60, 4.2},
      {"P10", "T1", 6, 160, 2.9},
      {"P01", "T1", 6, 210, 3.8},
      {"P03", "T2", 6, 180, 3.7},
      {"P04", "T1", 6, 150, 3.4},
      {"P06", "T1", 6, 120, 3.9}
    ]
    |> Enum.map(fn {prod, tanq, dia, lit, grasa} ->
      %{productor: prod, tanque: tanq, dia: dia, litros: lit, grasa: grasa}
    end)
  end
end

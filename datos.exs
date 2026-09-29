defmodule Datos do
  @moduledoc
  # Módulo de datos iniciales para el proyecto del Centro de Acopio de Leche.
  # Contiene los productores, tanques y el registro completo de entregas (10 inválidas y 80 válidas).

  @doc
  # Retorna la lista de 10 productores de la región. 4 de ellos utilizan servicio de transporte
  # (\`transporte: true\`).

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

  @doc
  # Retorna los 4 tanques del centro de acopio con su respectiva capacidad nominal en litros.
  def tanques do
    [
      %{id: "T1", nombre: "Tanque Norte", capacidad: 5000},
      %{id: "T2", nombre: "Tanque Central", capacidad: 4000},
      %{id: "T3", nombre: "Tanque Sur", capacidad: 4500},
      %{id: "T4", nombre: "Tanque Reserva", capacidad: 3000}
    ]
  end

  @doc
  # Retorna el total de entregas (10 entregas inválidas + 80 entregas válidas)
  def entregas do
    invalidas() ++ validas()
  end

  # Entregas inválidas: 10 en total: exactamente 2 por cada motivo
  defp invalidas do
    [
      # 1 - Productor desconocido
      %{productor: "P99", tanque: "T1", dia: 1, litros: 200, grasa: 3.6},
      %{productor: "PX0", tanque: "T2", dia: 2, litros: 150, grasa: 3.2},

      # 2 - Tanque desconocido
      %{productor: "P01", tanque: "T99", dia: 1, litros: 180, grasa: 3.4},
      %{productor: "P02", tanque: "TX4", dia: 3, litros: 210, grasa: 3.1},

      # 3 - Dia invalido
      %{productor: "P01", tanque: "T1", dia: 0, litros: 200, grasa: 3.8},
      %{productor: "P03", tanque: "T2", dia: 7, litros: 250, grasa: 3.5},

      # 4 - Litros fuera de rango
      %{productor: "P02", tanque: "T1", dia: 2, litros: 0, grasa: 3.2},
      %{productor: "P04", tanque: "T3", dia: 4, litros: 850, grasa: 3.6},

      # 5 - porcentaje invalido
      %{productor: "P05", tanque: "T2", dia: 3, litros: 190, grasa: -0.5},
      %{productor: "P06", tanque: "T4", dia: 5, litros: 220, grasa: 15.5}
    ]
  end
end

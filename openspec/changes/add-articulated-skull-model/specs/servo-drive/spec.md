# Spec Delta

## Purpose

Define el alojamiento del servomotor y la transmisión que mueve la mandíbula, para que el esqueleto simule hablar al accionar el servo.

## ADDED Requirements

### Requirement: Alojamiento para servo micro
El cráneo SHALL incluir una cavidad que aloje un servo micro tipo SG90/MG90S (aprox. 23×12.5×22 mm) con orejas de fijación y tornillos, con holgura parametrizable.

#### Scenario: Instalación del servo
- **WHEN** se coloca el servo en la cavidad y se atornilla por las orejas
- **THEN** el servo queda inmovilizado y su eje de salida queda en la posición prevista por el modelo

### Requirement: Paso de cable
El alojamiento SHALL ofrecer una salida para el cable del servo hacia la parte posterior o inferior del cráneo.

#### Scenario: Cable conectado
- **WHEN** el servo está instalado
- **THEN** el cable sale por la abertura sin quedar pellizcado por la mandíbula ni por la tapa

### Requirement: Transmisión al movimiento de la mandíbula
La transmisión SHALL convertir el giro del servo en la apertura de la mandíbula mediante un horn y una varilla o enlace, de forma que el recorrido angular del servo cubra el rango completo de apertura.

#### Scenario: Barrido del servo
- **WHEN** el servo se mueve entre su posición mínima y máxima configuradas
- **THEN** la mandíbula se mueve entre cerrada y abierta sin atascarse ni forzar el servo

### Requirement: Retorno a posición cerrada
El mecanismo SHALL permitir que la mandíbula vuelva a la posición cerrada accionada por el propio servo, sin depender de resortes.

#### Scenario: Cierre por servo
- **WHEN** el servo vuelve a su posición mínima
- **THEN** la mandíbula queda cerrada

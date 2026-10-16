/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.entities;

public class Equipamento {
    private Integer idEquipamento;
    private ModeloEquipamento modelo;
    private String numeroSerie;
    private String status;

    public Equipamento() {
    }

    public Equipamento(Integer idEquipamento, ModeloEquipamento modelo, String numeroSerie, String status) {
        this.idEquipamento = idEquipamento;
        this.modelo = modelo;
        this.numeroSerie = numeroSerie;
        this.status = status;
    }

    public Integer getIdEquipamento() {
        return idEquipamento;
    }

    public void setIdEquipamento(Integer idEquipamento) {
        this.idEquipamento = idEquipamento;
    }

    public ModeloEquipamento getModelo() {
        return modelo;
    }

    public void setModelo(ModeloEquipamento modelo) {
        this.modelo = modelo;
    }

    public String getNumeroSerie() {
        return numeroSerie;
    }

    public void setNumeroSerie(String numeroSerie) {
        this.numeroSerie = numeroSerie;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return modelo.getNome();
    }
}

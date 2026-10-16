/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.entities;

public class ItemEmprestimo {
    private Integer idItem;
    private Equipamento equipamento;
    private Double valorDiariaAplicado;
    private Integer dias;
    private Double subtotal;

    public Integer getIdItem() {
        return idItem;
    }

    public void setIdItem(Integer idItem) {
        this.idItem = idItem;
    }

    public Equipamento getEquipamento() {
        return equipamento;
    }

    public void setEquipamento(Equipamento equipamento) {
        this.equipamento = equipamento;
    }

    public Double getValorDiariaAplicado() {
        return valorDiariaAplicado;
    }

    public void setValorDiariaAplicado(Double valorDiariaAplicado) {
        this.valorDiariaAplicado = valorDiariaAplicado;
    }

    public Integer getDias() {
        return dias;
    }

    public void setDias(Integer dias) {
        this.dias = dias;
    }

    public Double getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(Double subtotal) {
        this.subtotal = subtotal;
    }
    
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.entities;

public class FormaPagamento {
    private Integer idFormaPgmt;
    private String nomeForma;

    public FormaPagamento() {
    }

    public FormaPagamento(Integer idFormaPgmt, String nomeForma) {
        this.idFormaPgmt = idFormaPgmt;
        this.nomeForma = nomeForma;
    }

    public Integer getIdFormaPgmt() {
        return idFormaPgmt;
    }

    public void setIdFormaPgmt(Integer idFormaPgmt) {
        this.idFormaPgmt = idFormaPgmt;
    }

    public String getNomeForma() {
        return nomeForma;
    }

    public void setNomeForma(String nomeForma) {
        this.nomeForma = nomeForma;
    }

    @Override
    public String toString() {
        return nomeForma;
    }
}

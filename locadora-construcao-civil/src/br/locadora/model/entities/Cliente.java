/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.entities;

/**
 *
 * @author Usuario
 */
public class Cliente extends Pessoa{
    private Double limiteCredito;

    public Cliente() {
        super();
    }

    public Cliente(Integer idPessoa, String nome, String docCpfCnpj, String email, String telefone, Double limiteCredito) {
        super(idPessoa, nome, docCpfCnpj, email, telefone);
        this.limiteCredito = limiteCredito;
    }

    public Double getLimiteCredito() {
        return limiteCredito;
    }

    public void setLimiteCredito(Double limiteCredito) {
        this.limiteCredito = limiteCredito;
    }
}

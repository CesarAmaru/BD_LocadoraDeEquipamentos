/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.dto;

import java.time.LocalDate;

public class EstatisticaClienteDTO {

    private Integer idCliente;
    private String nomeCliente;
    private String docCpfCnpj;
    private Integer qtdEmprestimos;
    private Double totalGasto;
    private LocalDate ultimaLocacao;

    public EstatisticaClienteDTO() {
    }

    public EstatisticaClienteDTO(Integer idCliente, String nomeCliente, String docCpfCnpj, Integer qtdEmprestimos, Double totalGasto, LocalDate ultimaLocacao) {
        this.idCliente = idCliente;
        this.nomeCliente = nomeCliente;
        this.docCpfCnpj = docCpfCnpj;
        this.qtdEmprestimos = qtdEmprestimos;
        this.totalGasto = totalGasto;
        this.ultimaLocacao = ultimaLocacao;
    }

    public Integer getIdCliente() {
        return idCliente;
    }

    public void setIdCliente(Integer idCliente) {
        this.idCliente = idCliente;
    }

    public String getNomeCliente() {
        return nomeCliente;
    }

    public void setNomeCliente(String nomeCliente) {
        this.nomeCliente = nomeCliente;
    }

    public String getDocCpfCnpj() {
        return docCpfCnpj;
    }

    public void setDocCpfCnpj(String docCpfCnpj) {
        this.docCpfCnpj = docCpfCnpj;
    }

    public Integer getQtdEmprestimos() {
        return qtdEmprestimos;
    }

    public void setQtdEmprestimos(Integer qtdEmprestimos) {
        this.qtdEmprestimos = qtdEmprestimos;
    }

    public Double getTotalGasto() {
        return totalGasto;
    }

    public void setTotalGasto(Double totalGasto) {
        this.totalGasto = totalGasto;
    }

    public LocalDate getUltimaLocacao() {
        return ultimaLocacao;
    }

    public void setUltimaLocacao(LocalDate ultimaLocacao) {
        this.ultimaLocacao = ultimaLocacao;
    }
}

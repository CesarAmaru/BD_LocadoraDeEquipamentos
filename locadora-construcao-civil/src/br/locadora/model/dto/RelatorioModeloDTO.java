/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.dto;

public class RelatorioModeloDTO {
    
    private String categoria;
    private Integer idModelo;
    private String nomeModelo;
    private String marca;
    private Double valorDiariaPadrao;
    private Integer totalLocacoes;
    private Double faturamentoAcumulado;

    public RelatorioModeloDTO() {}

    // Getters e Setters
    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }

    public Integer getIdModelo() { return idModelo; }
    public void setIdModelo(Integer idModelo) { this.idModelo = idModelo; }

    public String getNomeModelo() { return nomeModelo; }
    public void setNomeModelo(String nomeModelo) { this.nomeModelo = nomeModelo; }

    public String getMarca() { return marca; }
    public void setMarca(String marca) { this.marca = marca; }

    public Double getValorDiariaPadrao() { return valorDiariaPadrao; }
    public void setValorDiariaPadrao(Double valorDiariaPadrao) { this.valorDiariaPadrao = valorDiariaPadrao; }

    public Integer getTotalLocacoes() { return totalLocacoes; }
    public void setTotalLocacoes(Integer totalLocacoes) { this.totalLocacoes = totalLocacoes; }

    public Double getFaturamentoAcumulado() { return faturamentoAcumulado; }
    public void setFaturamentoAcumulado(Double faturamentoAcumulado) { this.faturamentoAcumulado = faturamentoAcumulado; }  
}

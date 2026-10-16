/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.entities;


public class ModeloEquipamento {
    private Integer idModelo;
    private Categoria categoria;
    private String nome;
    private String marca;
    private Double valorDiariaPadrao;

    public ModeloEquipamento() {
    }

    public ModeloEquipamento(Integer idModelo, Categoria categoria, String nome, String marca, Double valorDiariaPadrao) {
        this.idModelo = idModelo;
        this.categoria = categoria;
        this.nome = nome;
        this.marca = marca;
        this.valorDiariaPadrao = valorDiariaPadrao;
    }

    public Integer getIdModelo() {
        return idModelo;
    }

    public void setIdModelo(Integer idModelo) {
        this.idModelo = idModelo;
    }

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getMarca() {
        return marca;
    }

    public void setMarca(String marca) {
        this.marca = marca;
    }

    public Double getValorDiariaPadrao() {
        return valorDiariaPadrao;
    }

    public void setValorDiariaPadrao(Double valorDiariaPadrao) {
        this.valorDiariaPadrao = valorDiariaPadrao;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("id_categoria: " + categoria.getIdCategoria() + "|");
        sb.append("Nome: " + nome + "|");
        sb.append("Marca: " + marca + "|");
        sb.append("Valor diária padrão: " + valorDiariaPadrao + "|");
         
         return sb.toString();
    }
}

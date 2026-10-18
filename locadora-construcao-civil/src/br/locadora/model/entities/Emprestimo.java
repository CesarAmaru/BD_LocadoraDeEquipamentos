/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.entities;

import br.locadora.model.enums.StatusEmprestimo;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class Emprestimo {

    private Integer idEmprestimo;
    private Cliente cliente;
    private Funcionario funcionario;
    private FormaPagamento formaPagamento;
    private LocalDate dataEmprestimo;
    private LocalDate dataDevolucaoPrevista;
    private Double valorTotal;
    private StatusEmprestimo status;
    private Integer quantidadeItensAgregada;

    private List<ItemEmprestimo> itens = new ArrayList<>();

    public Integer getIdEmprestimo() {
        return idEmprestimo;
    }

    public void setIdEmprestimo(Integer idEmprestimo) {
        this.idEmprestimo = idEmprestimo;
    }

    public Cliente getCliente() {
        return cliente;
    }

    public void setCliente(Cliente cliente) {
        this.cliente = cliente;
    }

    public Funcionario getFuncionario() {
        return funcionario;
    }

    public void setFuncionario(Funcionario funcionario) {
        this.funcionario = funcionario;
    }

    public FormaPagamento getFormaPagamento() {
        return formaPagamento;
    }

    public void setFormaPagamento(FormaPagamento formaPagamento) {
        this.formaPagamento = formaPagamento;
    }

    public LocalDate getDataEmprestimo() {
        return dataEmprestimo;
    }

    public void setDataEmprestimo(LocalDate dataEmprestimo) {
        this.dataEmprestimo = dataEmprestimo;
    }

    public LocalDate getDataDevolucaoPrevista() {
        return dataDevolucaoPrevista;
    }

    public void setDataDevolucaoPrevista(LocalDate dataDevolucaoPrevista) {
        this.dataDevolucaoPrevista = dataDevolucaoPrevista;
    }

    public Double getValorTotal() {
        return valorTotal;
    }

    public void setValorTotal(Double valorTotal) {
        this.valorTotal = valorTotal;
    }

    public StatusEmprestimo getStatus() {
        return status;
    }

    public void setStatus(StatusEmprestimo status) {
        this.status = status;
    }

    public Integer getQuantidadeItensAgregada() {
        return quantidadeItensAgregada;
    }

    public void setQuantidadeItensAgregada(Integer quantidadeItensAgregada) {
        this.quantidadeItensAgregada = quantidadeItensAgregada;
    }
    
    

    public List<ItemEmprestimo> getItens() {
        return itens;
    }

    public void insertItens(ItemEmprestimo item) {
        itens.add(item);
    }

    public void removeItem(ItemEmprestimo item) {
        this.itens.remove(item);
        calcularValorTotal(); 
    }

    public void calcularValorTotal() {
        double soma = 0.0;
        for (ItemEmprestimo item : itens) {
            if (item.getSubtotal() != null) {
                soma += item.getSubtotal();
            }
        }
        this.valorTotal = soma;
    }
}
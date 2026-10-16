/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.controller;

import br.locadora.model.dao.EmprestimoDAO;
import br.locadora.model.entities.Cliente;
import br.locadora.model.entities.Emprestimo;
import br.locadora.model.entities.FormaPagamento;
import br.locadora.model.entities.Funcionario;
import br.locadora.model.entities.ItemEmprestimo;
import br.locadora.model.enums.StatusEmprestimo;
import br.locadora.model.exceptions.DomainException;
import java.time.LocalDate;
import java.util.List;

public class EmprestimoController {

    private final EmprestimoDAO dao;

    public EmprestimoController() {
        this.dao = new EmprestimoDAO();
    }

    public void salvar(Cliente cliente, Funcionario funcionario, FormaPagamento formaPagamento, LocalDate dataEmprestimo, LocalDate dataDevolucaoPrevista, List<ItemEmprestimo> itens) {
        
        validarDados(cliente, funcionario, formaPagamento, dataEmprestimo, dataDevolucaoPrevista, itens);

        Emprestimo emprestimo = new Emprestimo();
        emprestimo.setCliente(cliente);
        emprestimo.setFuncionario(funcionario); 
        emprestimo.setFormaPagamento(formaPagamento);
        emprestimo.setDataEmprestimo(dataEmprestimo);
        emprestimo.setDataDevolucaoPrevista(dataDevolucaoPrevista);
        emprestimo.setStatus(StatusEmprestimo.EM_ABERTO); 

        double valorTotal = 0.0;
        
        for (ItemEmprestimo item : itens) {
            emprestimo.insertItens(item); 
            
            if (item.getSubtotal() != null) {
                valorTotal += item.getSubtotal(); 
            }
        }
        
        emprestimo.setValorTotal(valorTotal);
        dao.inserir(emprestimo);
    }

    public void atualizar(Integer idEmprestimo, Cliente cliente, Funcionario funcionario, FormaPagamento formaPagamento, LocalDate dataEmprestimo, LocalDate dataDevolucaoPrevista, StatusEmprestimo status) {
        
        if (idEmprestimo == null) {
            throw new DomainException("ID do empréstimo não pode ser nulo para atualização.");
        }
        
        validarDados(cliente, funcionario, formaPagamento, dataEmprestimo, dataDevolucaoPrevista, null);

        Emprestimo emprestimo = dao.buscarporID(idEmprestimo);
        if (emprestimo == null) {
            throw new DomainException("Empréstimo não encontrado no banco de dados.");
        }

        emprestimo.setCliente(cliente);
        emprestimo.setFuncionario(funcionario); 
        emprestimo.setFormaPagamento(formaPagamento);
        emprestimo.setDataEmprestimo(dataEmprestimo);
        emprestimo.setDataDevolucaoPrevista(dataDevolucaoPrevista);
        emprestimo.setStatus(status);
        dao.update(emprestimo);
    }

    public void excluir(Emprestimo emprestimo) {
        if (emprestimo == null || emprestimo.getIdEmprestimo() == null) {
            throw new DomainException("Empréstimo inválido para exclusão.");
        }
        dao.deletar(emprestimo);
    }

    public List<Emprestimo> listarTodos() {
        return dao.bucarTodos();
    }
    
    private void validarDados(Cliente cliente, Funcionario funcionario, FormaPagamento formaPagamento, LocalDate dataEmprestimo, LocalDate dataDevolucaoPrevista, List<ItemEmprestimo> itens) {
        if (cliente == null) {
            throw new DomainException("Selecione um cliente válido.");
        }
        if (funcionario == null) {
            throw new DomainException("O funcionário responsável pelo empréstimo deve ser informado.");
        }
        if (formaPagamento == null) {
            throw new DomainException("Selecione uma forma de pagamento.");
        }
        if (dataEmprestimo == null || dataDevolucaoPrevista == null) {
            throw new DomainException("As datas de empréstimo e devolução são obrigatórias.");
        }
        if (dataDevolucaoPrevista.isBefore(dataEmprestimo)) {
            throw new DomainException("A data de devolução não pode ser anterior à data de empréstimo.");
        }
        if (itens != null && itens.isEmpty()) {
            throw new DomainException("O empréstimo deve conter pelo menos um equipamento.");
        }
    }
    
    public List<ItemEmprestimo> buscarItensDoEmprestimo(Integer idEmprestimo) {
        if (idEmprestimo == null) {
            throw new DomainException("ID do empréstimo não pode ser nulo.");
        }
        return dao.buscarItensPorEmprestimo(idEmprestimo);
    }
    
    public void registrarDevolucao(Integer idEmprestimo) {
        if (idEmprestimo == null) {
            throw new DomainException("ID do empréstimo inválido.");
        }
        dao.registrarDevolucao(idEmprestimo);
    }
    
}
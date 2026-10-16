/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.controller;

import br.locadora.model.dao.FormaPagamentoDAO;
import br.locadora.model.entities.FormaPagamento;
import br.locadora.model.exceptions.DomainException;
import java.util.List;

public class FormaPagamentoController {
    private final FormaPagamentoDAO formaPagamentoDAO;

    public FormaPagamentoController() {
        this.formaPagamentoDAO = new FormaPagamentoDAO();
    }

    public void salvar(String nomeForma) {
        if (nomeForma == null || nomeForma.trim().isEmpty()) {
            throw new DomainException("O nome da forma de pagamento é obrigatório.");
        }

        FormaPagamento fp = new FormaPagamento();
        fp.setNomeForma(nomeForma.trim());
        formaPagamentoDAO.inserir(fp);
    }

    public void atualizar(Integer id, String nomeForma) {
        if (id == null) {
            throw new DomainException("Selecione uma forma de pagamento para atualizar.");
        }
        if (nomeForma == null || nomeForma.trim().isEmpty()) {
            throw new DomainException("O nome da forma de pagamento é obrigatório.");
        }

        FormaPagamento fp = new FormaPagamento(id, nomeForma.trim());
        formaPagamentoDAO.update(fp);
    }

    public void excluir(FormaPagamento formaPagamento) {
        if (formaPagamento == null || formaPagamento.getIdFormaPgmt() == null) {
            throw new DomainException("Selecione uma forma de pagamento para excluir.");
        }
        formaPagamentoDAO.deletar(formaPagamento);
    }

    public List<FormaPagamento> listarTodas() {
        return formaPagamentoDAO.bucarTodos();
    }
}

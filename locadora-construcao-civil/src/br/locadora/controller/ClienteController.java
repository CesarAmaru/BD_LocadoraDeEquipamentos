/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.controller;

import br.locadora.model.dao.ClienteDAO;
import br.locadora.model.entities.Cliente;
import br.locadora.model.exceptions.DomainException;
import java.util.List;

/**
 *
 * @author Usuario
 */
public class ClienteController {
    private final ClienteDAO clienteDAO;

    public ClienteController() {
        this.clienteDAO = new ClienteDAO();
    }

    public void salvar(String nome, String docCpfCnpj, String email, String telefone, String strLimiteCredito) {
        validarCampos(nome, docCpfCnpj, email, strLimiteCredito);
        Double limiteCredito = converterLimite(strLimiteCredito);

        Cliente c = new Cliente(null, nome.trim(), docCpfCnpj.trim(), email.trim(), telefone != null ? telefone.trim() : "", limiteCredito);
        clienteDAO.inserir(c);
    }

    public void atualizar(Integer id, String nome, String docCpfCnpj, String email, String telefone, String strLimiteCredito) {
        if (id == null) {
            throw new DomainException("Selecione um cliente para atualizar.");
        }
        validarCampos(nome, docCpfCnpj, email, strLimiteCredito);
        Double limiteCredito = converterLimite(strLimiteCredito);

        Cliente c = new Cliente(id, nome.trim(), docCpfCnpj.trim(), email.trim(), telefone != null ? telefone.trim() : "", limiteCredito);
        clienteDAO.update(c);
    }

    public void excluir(Cliente cliente) {
        if (cliente == null || cliente.getIdPessoa() == null) {
            throw new DomainException("Selecione um cliente para excluir.");
        }
        clienteDAO.deletar(cliente);
    }

    public List<Cliente> listarTodos() {
        return clienteDAO.bucarTodos();
    }

    private void validarCampos(String nome, String docCpfCnpj, String email, String strLimiteCredito) {
        if (nome == null || nome.trim().isEmpty()) {
            throw new DomainException("O nome do cliente é obrigatório.");
        }
        if (docCpfCnpj == null || docCpfCnpj.trim().isEmpty()) {
            throw new DomainException("O documento (CPF/CNPJ) é obrigatório.");
        }
        if (email == null || email.trim().isEmpty()) {
            throw new DomainException("O e-mail é obrigatório.");
        }
        if (strLimiteCredito == null || strLimiteCredito.trim().isEmpty()) {
            throw new DomainException("O limite de crédito é obrigatório.");
        }
    }

    private Double converterLimite(String strLimite) {
        try {
            double limite = Double.parseDouble(strLimite.replace(",", "."));
            if (limite < 0) {
                throw new DomainException("O limite de crédito não pode ser negativo.");
            }
            return limite;
        } catch (NumberFormatException e) {
            throw new DomainException("O limite de crédito informado é inválido.");
        }
    }
}

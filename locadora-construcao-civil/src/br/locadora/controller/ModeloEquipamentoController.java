/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.controller;

import br.locadora.model.dao.ModeloEquipamentoDAO;
import br.locadora.model.entities.Categoria;
import br.locadora.model.entities.ModeloEquipamento;
import br.locadora.model.exceptions.DomainException;
import java.util.List;

public class ModeloEquipamentoController {
    private final ModeloEquipamentoDAO modeloEquipamentoDAO;

    public ModeloEquipamentoController() {
        this.modeloEquipamentoDAO = new ModeloEquipamentoDAO();
    }

    public void salvar(Categoria categoria, String nome, String marca, String strValorDiaria) {
        validarCampos(categoria, nome, marca, strValorDiaria);
        Double valorDiaria = converterValor(strValorDiaria);

        ModeloEquipamento me = new ModeloEquipamento(null, categoria, nome.trim(), marca.trim(), valorDiaria);
        modeloEquipamentoDAO.inserir(me);
    }

    public void atualizar(Integer id, Categoria categoria, String nome, String marca, String strValorDiaria) {
        if (id == null) {
            throw new DomainException("Selecione um modelo de equipamento para atualizar.");
        }
        validarCampos(categoria, nome, marca, strValorDiaria);
        Double valorDiaria = converterValor(strValorDiaria);

        ModeloEquipamento me = new ModeloEquipamento(id, categoria, nome.trim(), marca.trim(), valorDiaria);
        modeloEquipamentoDAO.update(me);
    }

    public void excluir(ModeloEquipamento modelo) {
        if (modelo == null || modelo.getIdModelo() == null) {
            throw new DomainException("Selecione um modelo de equipamento para excluir.");
        }
        modeloEquipamentoDAO.deletar(modelo);
    }

    public List<ModeloEquipamento> listarTodos() {
        return modeloEquipamentoDAO.bucarTodos();
    }

    private void validarCampos(Categoria categoria, String nome, String marca, String strValorDiaria) {
        if (categoria == null) {
            throw new DomainException("Selecione uma categoria válida.");
        }
        if (nome == null || nome.trim().isEmpty()) {
            throw new DomainException("O nome do modelo é obrigatório.");
        }
        if (marca == null || marca.trim().isEmpty()) {
            throw new DomainException("A marca do modelo é obrigatória.");
        }
        if (strValorDiaria == null || strValorDiaria.trim().isEmpty()) {
            throw new DomainException("O valor da diária é obrigatório.");
        }
    }

    private Double converterValor(String strValor) {
        try {
            double valor = Double.parseDouble(strValor.replace(",", "."));
            if (valor <= 0) {
                throw new DomainException("O valor da diária deve ser maior que zero.");
            }
            return valor;
        } catch (NumberFormatException e) {
            throw new DomainException("O valor da diária informado é inválido.");
        }
    }
}

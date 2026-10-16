/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.controller;

import br.locadora.model.dao.EquipamentoDAO;
import br.locadora.model.entities.Equipamento;
import br.locadora.model.entities.ModeloEquipamento;
import br.locadora.model.exceptions.DomainException;
import java.util.List;

public class EquipamentoController {
   private final EquipamentoDAO equipamentoDAO;

    public EquipamentoController() {
        this.equipamentoDAO = new EquipamentoDAO();
    }

    public void salvar(ModeloEquipamento modelo, String numeroSerie, String status) {
        validarCampos(modelo, numeroSerie, status);

        Equipamento eq = new Equipamento(null, modelo, numeroSerie.trim(), status.trim());
        equipamentoDAO.inserir(eq);
    }

    public void atualizar(Integer id, ModeloEquipamento modelo, String numeroSerie, String status) {
        if (id == null) {
            throw new DomainException("Selecione um equipamento para atualizar.");
        }
        validarCampos(modelo, numeroSerie, status);

        Equipamento eq = new Equipamento(id, modelo, numeroSerie.trim(), status.trim());
        equipamentoDAO.update(eq);
    }

    public void excluir(Equipamento equipamento) {
        if (equipamento == null || equipamento.getIdEquipamento() == null) {
            throw new DomainException("Selecione um equipamento para excluir.");
        }
        equipamentoDAO.deletar(equipamento);
    }

    public List<Equipamento> listarTodos() {
        return equipamentoDAO.bucarTodos();
    }

    private void validarCampos(ModeloEquipamento modelo, String numeroSerie, String status) {
        if (modelo == null) {
            throw new DomainException("Selecione um modelo de equipamento.");
        }
        if (numeroSerie == null || numeroSerie.trim().isEmpty()) {
            throw new DomainException("O número de série é obrigatório.");
        }
        if (status == null || status.trim().isEmpty()) {
            throw new DomainException("O status do equipamento é obrigatório.");
        }
    } 
}

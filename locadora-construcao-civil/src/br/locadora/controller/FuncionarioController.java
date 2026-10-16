/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */


package br.locadora.controller;

import br.locadora.model.dao.FuncionarioDAO;
import br.locadora.model.entities.Funcionario;
import java.util.List;

public class FuncionarioController {
    
    private final FuncionarioDAO dao;

    public FuncionarioController() {
        this.dao = new FuncionarioDAO();
    }

    public List<Funcionario> listarTodos() {
        return dao.bucarTodos();
    }
}

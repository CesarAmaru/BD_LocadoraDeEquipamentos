/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.controller;

import br.locadora.model.dao.CategoriaDAO;
import br.locadora.model.entities.Categoria;
import br.locadora.model.exceptions.DomainException;
import java.util.List;

public class CategoriaController {
    private final CategoriaDAO categoriaDAO;

    public CategoriaController() {
        this.categoriaDAO = new CategoriaDAO();
    }

    public void salvar(String nome) {
        if (nome == null || nome.trim().isEmpty()) {
            throw new DomainException("O nome da categoria é obrigatório.");
        }
        
        Categoria cat = new Categoria();
        cat.setNomeCategoria(nome.trim());
        categoriaDAO.inserir(cat);
    }

    public void atualizar(Integer id, String nome) {
        if (id == null) {
            throw new DomainException
        ("Selecione uma categoria para atualizar.");
        }
        if (nome == null || nome.trim().isEmpty()) {
            throw new DomainException
        ("O nome da categoria é obrigatório.");
        }

        Categoria cat = new Categoria(id, nome.trim());
        categoriaDAO.update(cat);
    }

    public void excluir(Categoria categoria) {
        if (categoria == null || categoria.getIdCategoria() == null) {
            throw new DomainException
        ("Selecione uma categoria para excluir.");
        }
        categoriaDAO.deletar(categoria);
    }

    public List<Categoria> listarTodas() {
        return categoriaDAO.bucarTodos();
    }

    public Categoria buscarPorId(Integer id) {
        if (id == null) {
            throw new DomainException
        ("ID inválido para busca.");
        }
        return categoriaDAO.buscarporID(id);
    }
}

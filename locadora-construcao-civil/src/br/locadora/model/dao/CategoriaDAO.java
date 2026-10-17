/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.dao;

import br.locadora.model.dao.interfaces.InterfaceDAO;
import br.locadora.model.entities.Categoria;
import br.locadora.model.exceptions.DataBaseException;
import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 *
 * @author Usuario
 */
public class CategoriaDAO implements InterfaceDAO<Categoria> {

    @Override
    public void inserir(Categoria objeto) {
        String sql = "INSERT INTO categoria(id_categoria, nome_categoria) VALUES (null, ?)";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, objeto.getNomeCategoria());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao inserir categoria" + e.getLocalizedMessage(), e);
        }

    }

    @Override
    public Categoria buscarporID(Integer id) {
        String sql = "SELECT * FROM categoria WHERE id_categoria = ?";
        Categoria cat = null;
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    cat = new Categoria();
                    cat.setIdCategoria(rs.getInt("id_categoria"));
                    cat.setNomeCategoria(rs.getString("nome_categoria"));
                }
            }

        } catch (SQLException e) {
            throw new DataBaseException("Erro ao buscar a categoria por ID: " + e.getMessage(), e);
        }
        return cat;
    }

    @Override
    public List<Categoria> bucarTodos() {
        String sql = "SELECT * FROM categoria";
        List<Categoria> lista = new ArrayList<>();

        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Categoria cat = new Categoria();
                cat.setIdCategoria(rs.getInt("id_categoria"));
                cat.setNomeCategoria(rs.getString("nome_categoria"));
                lista.add(cat);
            }
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao listar as categorias: " + e.getMessage(), e);
        }
        return lista;
    }

    @Override
    public void deletar(Categoria v) {
        String sql = "DELETE FROM categoria WHERE id_categoria = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, v.getIdCategoria());
            ps.executeUpdate();
        } catch (SQLException e) {
            if("23000".equals(e.getSQLState())){
                throw new DataBaseException("Não é possível excluir esse registro pois ele está sendo utilizado em outro lugar", e);
            }
            throw new DataBaseException("Erro ao deletar a categoria: " + e.getMessage(), e);
        }
    }

    @Override
    public void update(Categoria v) {
        String sql = "UPDATE categoria SET nome_categoria = ? WHERE id_categoria = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, v.getNomeCategoria());
            ps.setInt(2, v.getIdCategoria());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao atualizar a categoria: " + e.getMessage(), e);
        }
    }

}

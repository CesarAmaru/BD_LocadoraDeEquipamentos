/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.dao;

import br.locadora.model.dao.interfaces.InterfaceDAO;
import br.locadora.model.entities.Categoria;
import br.locadora.model.entities.ModeloEquipamento;
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
public class ModeloEquipamentoDAO implements InterfaceDAO<ModeloEquipamento> {

    @Override
    public void inserir(ModeloEquipamento objeto) {
        String sql = "INSERT INTO modelo_equipamento (id_categoria, nome, marca, valor_diaria_padrao) VALUES (?, ?, ?, ?)";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, objeto.getCategoria().getIdCategoria());
            ps.setString(2, objeto.getNome());
            ps.setString(3, objeto.getMarca());
            ps.setDouble(4, objeto.getValorDiariaPadrao());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao inserir o modelo de equipamento: " + e.getMessage(), e);
        }
    }

    @Override
    public ModeloEquipamento buscarporID(Integer id) {
        String sql = "SELECT m.*, c.nome_categoria FROM modelo_equipamento m "
                + "INNER JOIN categoria c ON m.id_categoria = c.id_categoria "
                + "WHERE m.id_modeloE = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Categoria cat = new Categoria(rs.getInt("id_categoria"), rs.getString("nome_categoria"));
                    ModeloEquipamento me = new ModeloEquipamento();
                    me.setIdModelo(rs.getInt("id_modeloE"));
                    me.setCategoria(cat);
                    me.setNome(rs.getString("nome"));
                    me.setMarca(rs.getString("marca"));
                    me.setValorDiariaPadrao(rs.getDouble("valor_diaria_padrao"));
                    return me;
                }
            }
            return null;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao buscar o modelo de equipamento por ID: " + e.getMessage(), e);
        }
    }

    @Override
    public List<ModeloEquipamento> bucarTodos() {
        String sql = "SELECT m.*, c.nome_categoria FROM modelo_equipamento m "
                + "INNER JOIN categoria c ON m.id_categoria = c.id_categoria";
        List<ModeloEquipamento> lista = new ArrayList<>();

        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Categoria cat = new Categoria(rs.getInt("id_categoria"), rs.getString("nome_categoria"));
                ModeloEquipamento me = new ModeloEquipamento();
                me.setIdModelo(rs.getInt("id_modeloE"));
                me.setCategoria(cat);
                me.setNome(rs.getString("nome"));
                me.setMarca(rs.getString("marca"));
                me.setValorDiariaPadrao(rs.getDouble("valor_diaria_padrao"));
                lista.add(me);
            }
            return lista;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao listar os modelos de equipamento: " + e.getMessage(), e);
        }
    }

    @Override
    public void deletar(ModeloEquipamento v) {
        String sql = "DELETE FROM modelo_equipamento WHERE id_modeloE = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, v.getIdModelo());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao deletar o modelo de equipamento: " + e.getMessage(), e);
        }
    }

    @Override
    public void update(ModeloEquipamento v) {
        String sql = "UPDATE modelo_equipamento SET id_categoria = ?, nome = ?, marca = ?, valor_diaria_padrao = ? WHERE id_modeloE = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, v.getCategoria().getIdCategoria());
            ps.setString(2, v.getNome());
            ps.setString(3, v.getMarca());
            ps.setDouble(4, v.getValorDiariaPadrao());
            ps.setInt(5, v.getIdModelo());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao atualizar o modelo de equipamento: " + e.getMessage(), e);
        }
    }
}

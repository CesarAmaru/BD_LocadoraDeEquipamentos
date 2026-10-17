/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.dao;

import br.locadora.model.dao.interfaces.InterfaceDAO;
import br.locadora.model.entities.Equipamento;
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
public class EquipamentoDAO implements InterfaceDAO<Equipamento> {

    @Override
    public void inserir(Equipamento objeto) {
        String sql = "INSERT INTO equipamento (id_modeloE, numero_serie, status) VALUES (?, ?, ?)";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, objeto.getModelo().getIdModelo());
            ps.setString(2, objeto.getNumeroSerie());
            ps.setString(3, objeto.getStatus());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao inserir o equipamento: " + e.getMessage(), e);
        }
    }

    @Override
    public Equipamento buscarporID(Integer id) {
        String sql = "SELECT e.*, m.nome AS nome_modelo FROM equipamento e "
                + "INNER JOIN modelo_equipamento m ON e.id_modeloE = m.id_modeloE "
                + "WHERE e.id_equipamento = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ModeloEquipamento mod = new ModeloEquipamento();
                    mod.setIdModelo(rs.getInt("id_modeloE"));
                    mod.setNome(rs.getString("nome_modelo"));
                    mod.setValorDiariaPadrao(rs.getDouble("valor_diaria"));
                    
                    Equipamento eq = new Equipamento();
                    eq.setIdEquipamento(rs.getInt("id_equipamento"));
                    eq.setModelo(mod);
                    eq.setNumeroSerie(rs.getString("numero_serie"));
                    eq.setStatus(rs.getString("status"));
                    return eq;
                }
            }
            return null;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao buscar o equipamento por ID: " + e.getMessage(), e);
        }
    }

    @Override
    public List<Equipamento> bucarTodos() {
        String sql = "SELECT e.*, m.nome AS nome_modelo, m.valor_diaria_padrao FROM equipamento e "
                   + "INNER JOIN modelo_equipamento m ON e.id_modeloE = m.id_modeloE";
        
        List<Equipamento> lista = new ArrayList<>();

        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ModeloEquipamento mod = new ModeloEquipamento();
                mod.setIdModelo(rs.getInt("id_modeloE"));
                mod.setNome(rs.getString("nome_modelo"));
                mod.setValorDiariaPadrao(rs.getDouble("valor_diaria_padrao"));
                Equipamento eq = new Equipamento();
                eq.setIdEquipamento(rs.getInt("id_equipamento"));
                eq.setModelo(mod);
                eq.setNumeroSerie(rs.getString("numero_serie"));
                eq.setStatus(rs.getString("status"));
                lista.add(eq);
            }
            return lista;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao listar os equipamentos: " + e.getMessage(), e);
        }
    }

    @Override
    public void deletar(Equipamento v) {
        String sql = "DELETE FROM equipamento WHERE id_equipamento = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, v.getIdEquipamento());
            ps.executeUpdate();
        } catch (SQLException e) {
            if("23000".equals(e.getSQLState())){
                throw new DataBaseException("Não é possível excluir esse registro pois ele está sendo utilizado em outro lugar", e);
            }
            throw new DataBaseException("Erro ao deletar o equipamento: " + e.getMessage(), e);
        }
    }

    @Override
    public void update(Equipamento v) {
        String sql = "UPDATE equipamento SET id_modeloE = ?, numero_serie = ?, status = ? WHERE id_equipamento = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, v.getModelo().getIdModelo());
            ps.setString(2, v.getNumeroSerie());
            ps.setString(3, v.getStatus());
            ps.setInt(4, v.getIdEquipamento());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao atualizar o equipamento: " + e.getMessage(), e);
        }
    }
}

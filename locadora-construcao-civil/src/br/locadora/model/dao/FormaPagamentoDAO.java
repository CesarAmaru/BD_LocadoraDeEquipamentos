/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.dao;

import br.locadora.model.dao.interfaces.InterfaceDAO;
import br.locadora.model.entities.FormaPagamento;
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
public class FormaPagamentoDAO implements InterfaceDAO<FormaPagamento> {

    @Override
    public void inserir(FormaPagamento objeto) {
        String sql = "INSERT INTO forma_pagamento (nome_forma) VALUES (?)";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, objeto.getNomeForma());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao inserir a forma de pagamento: " + e.getMessage(), e);
        }
    }

    @Override
    public FormaPagamento buscarporID(Integer id) {
        String sql = "SELECT * FROM forma_pagamento WHERE id_formaPgmt = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    FormaPagamento fp = new FormaPagamento();
                    fp.setIdFormaPgmt(rs.getInt("id_formaPgmt"));
                    fp.setNomeForma(rs.getString("nome_forma"));
                    return fp;
                }
            }
            return null;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao buscar a forma de pagamento por ID: " + e.getMessage(), e);
        }
    }

    @Override
    public List<FormaPagamento> bucarTodos() {
        String sql = "SELECT * FROM forma_pagamento";
        List<FormaPagamento> lista = new ArrayList<>();

        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                FormaPagamento fp = new FormaPagamento();
                fp.setIdFormaPgmt(rs.getInt("id_formaPgmt"));
                fp.setNomeForma(rs.getString("nome_forma"));
                lista.add(fp);
            }
            return lista;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao listar as formas de pagamento: " + e.getMessage(), e);
        }
    }

    @Override
    public void deletar(FormaPagamento v) {
        String sql = "DELETE FROM forma_pagamento WHERE id_formaPgmt = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, v.getIdFormaPgmt());
            ps.executeUpdate();
        } catch (SQLException e) {
            if("23000".equals(e.getSQLState())){
                throw new DataBaseException("Não é possível excluir esse registro pois ele está sendo utilizado em outro lugar", e);
            }
            throw new DataBaseException("Erro ao deletar a forma de pagamento: " + e.getMessage(), e);
        }
    }

    @Override
    public void update(FormaPagamento v) {
        String sql = "UPDATE forma_pagamento SET nome_forma = ? WHERE id_formaPgmt = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, v.getNomeForma());
            ps.setInt(2, v.getIdFormaPgmt());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao atualizar a forma de pagamento: " + e.getMessage(), e);
        }
    }
}

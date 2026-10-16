/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.dao;

import br.locadora.model.dao.interfaces.InterfaceDAO;
import br.locadora.model.entities.Cliente;
import br.locadora.model.exceptions.DataBaseException;
import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.sql.Statement;

public class ClienteDAO implements InterfaceDAO<Cliente> {

    @Override
    public void inserir(Cliente objeto) {
        String sqlPessoa = "INSERT INTO pessoa (nome, doc_cpf_cnpj, email, telefone) VALUES (?, ?, ?, ?)";
        String sqlCliente = "INSERT INTO cliente (id_pessoa, limite_credito) VALUES (?, ?)";

        try (Connection cn = DAO.abrirBanco()) {
            cn.setAutoCommit(false);
            try {
                int idPessoaGerado;
                try (PreparedStatement psPessoa = cn.prepareStatement(sqlPessoa, Statement.RETURN_GENERATED_KEYS)) {
                    psPessoa.setString(1, objeto.getNome());
                    psPessoa.setString(2, objeto.getDocCpfCnpj());
                    psPessoa.setString(3, objeto.getEmail());
                    psPessoa.setString(4, objeto.getTelefone());
                    psPessoa.executeUpdate();

                    try (ResultSet rs = psPessoa.getGeneratedKeys()) {
                        if (rs.next()) {
                            idPessoaGerado = rs.getInt(1);
                        } else {
                            throw new SQLException("Falha ao obter ID da pessoa inserida.");
                        }
                    }
                }

                try (PreparedStatement psCliente = cn.prepareStatement(sqlCliente)) {
                    psCliente.setInt(1, idPessoaGerado);
                    psCliente.setDouble(2, objeto.getLimiteCredito());
                    psCliente.executeUpdate();
                }

                cn.commit();
            } catch (SQLException e) {
                cn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao inserir o cliente: " + e.getMessage(), e);
        }
    }

    @Override
    public Cliente buscarporID(Integer id) {
        String sql = "SELECT p.*, c.limite_credito FROM pessoa p "
                + "INNER JOIN cliente c ON p.id_pessoa = c.id_pessoa "
                + "WHERE p.id_pessoa = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Cliente cliente = new Cliente();
                    cliente.setIdPessoa(rs.getInt("id_pessoa"));
                    cliente.setNome(rs.getString("nome"));
                    cliente.setDocCpfCnpj(rs.getString("doc_cpf_cnpj"));
                    cliente.setEmail(rs.getString("email"));
                    cliente.setTelefone(rs.getString("telefone"));
                    cliente.setLimiteCredito(rs.getDouble("limite_credito"));
                    return cliente;
                }
            }
            return null;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao buscar o cliente por ID: " + e.getMessage(), e);
        }
    }

    @Override
    public List<Cliente> bucarTodos() {
        String sql = "SELECT p.*, c.limite_credito FROM pessoa p "
                + "INNER JOIN cliente c ON p.id_pessoa = c.id_pessoa";
        List<Cliente> lista = new ArrayList<>();

        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Cliente cliente = new Cliente();
                cliente.setIdPessoa(rs.getInt("id_pessoa"));
                cliente.setNome(rs.getString("nome"));
                cliente.setDocCpfCnpj(rs.getString("doc_cpf_cnpj"));
                cliente.setEmail(rs.getString("email"));
                cliente.setTelefone(rs.getString("telefone"));
                cliente.setLimiteCredito(rs.getDouble("limite_credito"));
                lista.add(cliente);
            }
            return lista;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao listar os clientes: " + e.getMessage(), e);
        }
    }

    @Override
    public void deletar(Cliente v) {
        String sql = "DELETE FROM pessoa WHERE id_pessoa = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, v.getIdPessoa());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao deletar o cliente: " + e.getMessage(), e);
        }
    }

    @Override
    public void update(Cliente v) {
        String sqlPessoa = "UPDATE pessoa SET nome = ?, doc_cpf_cnpj = ?, email = ?, telefone = ? WHERE id_pessoa = ?";
        String sqlCliente = "UPDATE cliente SET limite_credito = ? WHERE id_pessoa = ?";

        try (Connection cn = DAO.abrirBanco()) {
            cn.setAutoCommit(false);
            try {
                try (PreparedStatement psPessoa = cn.prepareStatement(sqlPessoa)) {
                    psPessoa.setString(1, v.getNome());
                    psPessoa.setString(2, v.getDocCpfCnpj());
                    psPessoa.setString(3, v.getEmail());
                    psPessoa.setString(4, v.getTelefone());
                    psPessoa.setInt(5, v.getIdPessoa());
                    psPessoa.executeUpdate();
                }

                try (PreparedStatement psCliente = cn.prepareStatement(sqlCliente)) {
                    psCliente.setDouble(1, v.getLimiteCredito());
                    psCliente.setInt(2, v.getIdPessoa());
                    psCliente.executeUpdate();
                }

                cn.commit();
            } catch (SQLException e) {
                cn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao atualizar o cliente: " + e.getMessage(), e);
        }
    }
}

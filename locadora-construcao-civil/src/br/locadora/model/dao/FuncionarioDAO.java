/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package br.locadora.model.dao;

import br.locadora.model.dao.interfaces.InterfaceDAO;
import br.locadora.model.entities.Funcionario;
import br.locadora.model.exceptions.DataBaseException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class FuncionarioDAO implements InterfaceDAO<Funcionario> {

    @Override
    public void inserir(Funcionario objeto) {
        String sqlPessoa = "INSERT INTO pessoa (nome, doc_cpf_cnpj, email, telefone) VALUES (?, ?, ?, ?)";
        String sqlFuncionario = "INSERT INTO funcionario (id_pessoa, salario, cargo, id_supervisor) VALUES (?, ?, ?, ?)";

        try (Connection cn = DAO.abrirBanco()) {
            cn.setAutoCommit(false); // Inicia transação

            // 1. Insere na tabela pai (pessoa)
            try (PreparedStatement psPessoa = cn.prepareStatement(sqlPessoa, Statement.RETURN_GENERATED_KEYS)) {
                psPessoa.setString(1, objeto.getNome());
                psPessoa.setString(2, objeto.getDocCpfCnpj());
                psPessoa.setString(3, objeto.getEmail());
                psPessoa.setString(4, objeto.getTelefone());
                psPessoa.executeUpdate();

                // Recupera o ID gerado para a pessoa
                try (ResultSet rs = psPessoa.getGeneratedKeys()) {
                    if (rs.next()) {
                        int idPessoaGerado = rs.getInt(1);
                        objeto.setIdPessoa(idPessoaGerado);

                        // 2. Insere na tabela filha (funcionario)
                        try (PreparedStatement psFunc = cn.prepareStatement(sqlFuncionario)) {
                            psFunc.setInt(1, idPessoaGerado);
                            psFunc.setDouble(2, objeto.getSalario());
                            psFunc.setString(3, objeto.getCargo());
                            
                            if (objeto.getSupervisor() != null && objeto.getSupervisor().getIdPessoa() != null) {
                                psFunc.setInt(4, objeto.getSupervisor().getIdPessoa());
                            } else {
                                psFunc.setNull(4, Types.INTEGER);
                            }
                            
                            psFunc.executeUpdate();
                        }
                    }
                }
                cn.commit(); // Efetiva no banco
            } catch (SQLException e) {
                cn.rollback(); // Desfaz tudo em caso de erro
                throw e;
            } finally {
                cn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao inserir funcionário: " + e.getMessage(), e);
        }
    }

    @Override
    public Funcionario buscarporID(Integer id) {
        String sql = "SELECT p.*, f.salario, f.cargo, f.id_supervisor "
                   + "FROM funcionario f "
                   + "INNER JOIN pessoa p ON f.id_pessoa = p.id_pessoa "
                   + "WHERE f.id_pessoa = ?";

        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return instanciarFuncionario(rs);
                }
            }
            return null;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao buscar funcionário por ID: " + e.getMessage(), e);
        }
    }

    @Override
    public List<Funcionario> bucarTodos() {
        String sql = "SELECT p.*, f.salario, f.cargo, f.id_supervisor "
                   + "FROM funcionario f "
                   + "INNER JOIN pessoa p ON f.id_pessoa = p.id_pessoa "
                   + "ORDER BY p.nome";
        
        List<Funcionario> lista = new ArrayList<>();

        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(instanciarFuncionario(rs));
            }
            return lista;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao listar funcionários: " + e.getMessage(), e);
        }
    }

    @Override
    public void update(Funcionario v) {
        String sqlPessoa = "UPDATE pessoa SET nome = ?, doc_cpf_cnpj = ?, email = ?, telefone = ? WHERE id_pessoa = ?";
        String sqlFuncionario = "UPDATE funcionario SET salario = ?, cargo = ?, id_supervisor = ? WHERE id_pessoa = ?";

        try (Connection cn = DAO.abrirBanco()) {
            cn.setAutoCommit(false);
            
            try (PreparedStatement psPessoa = cn.prepareStatement(sqlPessoa);
                 PreparedStatement psFunc = cn.prepareStatement(sqlFuncionario)) {
                
                // Atualiza Pessoa
                psPessoa.setString(1, v.getNome());
                psPessoa.setString(2, v.getDocCpfCnpj());
                psPessoa.setString(3, v.getEmail());
                psPessoa.setString(4, v.getTelefone());
                psPessoa.setInt(5, v.getIdPessoa());
                psPessoa.executeUpdate();

                // Atualiza Funcionário
                psFunc.setDouble(1, v.getSalario());
                psFunc.setString(2, v.getCargo());
                
                if (v.getSupervisor() != null && v.getSupervisor().getIdPessoa() != null) {
                    psFunc.setInt(3, v.getSupervisor().getIdPessoa());
                } else {
                    psFunc.setNull(3, Types.INTEGER);
                }
                psFunc.setInt(4, v.getIdPessoa());
                psFunc.executeUpdate();

                cn.commit();
            } catch (SQLException e) {
                cn.rollback();
                throw e;
            } finally {
                cn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao atualizar funcionário: " + e.getMessage(), e);
        }
    }

    @Override
    public void deletar(Funcionario v) {
        String sqlFunc = "DELETE FROM funcionario WHERE id_pessoa = ?";
        String sqlPessoa = "DELETE FROM pessoa WHERE id_pessoa = ?";

        try (Connection cn = DAO.abrirBanco()) {
            cn.setAutoCommit(false);
            
            try (PreparedStatement psFunc = cn.prepareStatement(sqlFunc);
                 PreparedStatement psPessoa = cn.prepareStatement(sqlPessoa)) {
                
                psFunc.setInt(1, v.getIdPessoa());
                psFunc.executeUpdate();
                psPessoa.setInt(1, v.getIdPessoa());
                psPessoa.executeUpdate();

                cn.commit();
            } catch (SQLException e) {
                cn.rollback();
                throw e;
            } finally {
                cn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            if("23000".equals(e.getSQLState())){
                throw new DataBaseException("Não é possível excluir esse registro pois ele está sendo utilizado em outro lugar", e);
            }
            throw new DataBaseException("Erro ao deletar funcionário: " + e.getMessage(), e);
        }
    }

    private Funcionario instanciarFuncionario(ResultSet rs) throws SQLException {
        Funcionario func = new Funcionario();
        func.setIdPessoa(rs.getInt("id_pessoa"));
        func.setNome(rs.getString("nome"));
        func.setDocCpfCnpj(rs.getString("doc_cpf_cnpj"));
        func.setEmail(rs.getString("email"));
        func.setTelefone(rs.getString("telefone"));
        func.setSalario(rs.getDouble("salario"));
        func.setCargo(rs.getString("cargo"));
        
        int idSup = rs.getInt("id_supervisor");
        if (!rs.wasNull()) {
            Funcionario supervisor = new Funcionario();
            supervisor.setIdPessoa(idSup);
            func.setSupervisor(supervisor);
        }
        
        return func;
    }
}
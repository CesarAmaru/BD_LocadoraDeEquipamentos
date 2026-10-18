/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.dao;

import br.locadora.model.dao.interfaces.InterfaceDAO;
import br.locadora.model.entities.Cliente;
import br.locadora.model.entities.Emprestimo;
import br.locadora.model.entities.Equipamento;
import br.locadora.model.entities.Funcionario;
import br.locadora.model.entities.ItemEmprestimo;
import br.locadora.model.enums.StatusEmprestimo;
import br.locadora.model.exceptions.DataBaseException;
import com.mysql.cj.jdbc.result.ResultSetImpl;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class EmprestimoDAO implements InterfaceDAO<Emprestimo> {

    @Override
    public void inserir(Emprestimo objeto) {
        String sqlEmprestimo = "INSERT INTO emprestimo (id_cliente, id_funcionario, data_emissao, data_prevista_devolucao, status_emprestimo) VALUES (?, ?, ?, ?, ?)";

        String sqlItem = "INSERT INTO item_emprestimo (id_emprestimo, id_equipamento, valor_diaria_aplicado) VALUES (?, ?, ?)";

        try (Connection cn = DAO.abrirBanco()) {
            cn.setAutoCommit(false);

            try (PreparedStatement psEmprestimo = cn.prepareStatement(sqlEmprestimo, Statement.RETURN_GENERATED_KEYS)) {

                psEmprestimo.setInt(1, objeto.getCliente().getIdPessoa());
                psEmprestimo.setInt(2, objeto.getFuncionario().getIdPessoa());
                psEmprestimo.setDate(3, Date.valueOf(objeto.getDataEmprestimo()));
                psEmprestimo.setDate(4, Date.valueOf(objeto.getDataDevolucaoPrevista()));
                psEmprestimo.setString(5, objeto.getStatus() != null ? objeto.getStatus().getStatus() : StatusEmprestimo.EM_ABERTO.getStatus());

                psEmprestimo.executeUpdate();

                try (ResultSet rs = psEmprestimo.getGeneratedKeys()) {
                    if (rs.next()) {
                        int idGerado = rs.getInt(1);
                        objeto.setIdEmprestimo(idGerado);

                        try (PreparedStatement psItem = cn.prepareStatement(sqlItem)) {
                            for (ItemEmprestimo item : objeto.getItens()) {
                                psItem.setInt(1, idGerado);
                                psItem.setInt(2, item.getEquipamento().getIdEquipamento());
                                psItem.setDouble(3, item.getValorDiariaAplicado());
                                psItem.executeUpdate();
                            }
                        }
                    }
                }
                cn.commit();
            } catch (SQLException e) {
                cn.rollback();
                throw e;
            } finally {
                cn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao inserir o empréstimo: " + e.getMessage(), e);
        }
    }

    @Override
    public Emprestimo buscarporID(Integer id) {
        String sql = "SELECT emp.*, pc.nome AS nome_cliente, pf.nome AS nome_funcionario "
                + "FROM emprestimo emp "
                + "INNER JOIN pessoa pc ON emp.id_cliente = pc.id_pessoa "
                + "INNER JOIN pessoa pf ON emp.id_funcionario = pf.id_pessoa "
                + "WHERE emp.id_emprestimo = ?";

        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Cliente cli = new Cliente();
                    cli.setIdPessoa(rs.getInt("id_cliente"));
                    cli.setNome(rs.getString("nome_cliente"));

                    Funcionario func = new Funcionario();
                    func.setIdPessoa(rs.getInt("id_funcionario"));
                    func.setNome(rs.getString("nome_funcionario"));

                    Emprestimo emp = new Emprestimo();
                    emp.setIdEmprestimo(rs.getInt("id_emprestimo"));
                    emp.setCliente(cli);
                    emp.setFuncionario(func);
                    emp.setDataEmprestimo(rs.getDate("data_emissao").toLocalDate());
                    emp.setDataDevolucaoPrevista(rs.getDate("data_prevista_devolucao").toLocalDate());
                    emp.setStatus(StatusEmprestimo.fromDescricao(rs.getString("status_emprestimo")));

                    return emp;
                }
            }
            return null;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao buscar o empréstimo por ID: " + e.getMessage(), e);
        }
    }

    @Override
    public List<Emprestimo> bucarTodos() {
        String sql = "SELECT emp.*, pc.nome AS nome_cliente, pf.nome AS nome_funcionario "
                + "FROM emprestimo emp "
                + "INNER JOIN pessoa pc ON emp.id_cliente = pc.id_pessoa "
                + "INNER JOIN pessoa pf ON emp.id_funcionario = pf.id_pessoa "
                + "ORDER BY emp.id_emprestimo DESC";

        List<Emprestimo> lista = new ArrayList<>();

        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Cliente cli = new Cliente();
                cli.setIdPessoa(rs.getInt("id_cliente"));
                cli.setNome(rs.getString("nome_cliente"));

                Funcionario func = new Funcionario();
                func.setIdPessoa(rs.getInt("id_funcionario"));
                func.setNome(rs.getString("nome_funcionario"));

                Emprestimo emp = new Emprestimo();
                emp.setIdEmprestimo(rs.getInt("id_emprestimo"));
                emp.setCliente(cli);
                emp.setFuncionario(func);
                emp.setDataEmprestimo(rs.getDate("data_emissao").toLocalDate());
                emp.setDataDevolucaoPrevista(rs.getDate("data_prevista_devolucao").toLocalDate());
                emp.setStatus(StatusEmprestimo.fromDescricao(rs.getString("status_emprestimo")));

                lista.add(emp);
            }
            return lista;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao listar os empréstimos: " + e.getMessage(), e);
        }
    }

    @Override
    public void deletar(Emprestimo v) {
        String sql = "DELETE FROM emprestimo WHERE id_emprestimo = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, v.getIdEmprestimo());
            ps.executeUpdate();
        } catch (SQLException e) {
            if ("23000".equals(e.getSQLState())) {
                throw new DataBaseException("Não é possível excluir esse registro pois ele está sendo utilizado em outro lugar", e);
            }
            throw new DataBaseException("Erro ao deletar o empréstimo: " + e.getMessage(), e);
        }
    }

    @Override
    public void update(Emprestimo v) {
        String sql = "UPDATE emprestimo SET id_cliente = ?, id_funcionario = ?, data_emissao = ?, data_prevista_devolucao = ?, status_emprestimo = ? WHERE id_emprestimo = ?";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, v.getCliente().getIdPessoa());
            ps.setInt(2, v.getFuncionario().getIdPessoa());
            ps.setDate(3, Date.valueOf(v.getDataEmprestimo()));
            ps.setDate(4, Date.valueOf(v.getDataDevolucaoPrevista()));
            ps.setString(5, v.getStatus() != null ? v.getStatus().getStatus() : StatusEmprestimo.EM_ABERTO.getStatus());
            ps.setInt(6, v.getIdEmprestimo());

            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao atualizar o empréstimo: " + e.getMessage(), e);
        }
    }

    public List<ItemEmprestimo> buscarItensPorEmprestimo(Integer idEmprestimo) {
        String sql = "SELECT ie.valor_diaria_aplicado, eq.id_equipamento, eq.numero_serie, m.nome AS nome_modelo "
                + "FROM item_emprestimo ie "
                + "INNER JOIN equipamento eq ON ie.id_equipamento = eq.id_equipamento "
                + "INNER JOIN modelo_equipamento m ON eq.id_modeloE = m.id_modeloE "
                + "WHERE ie.id_emprestimo = ?";

        List<ItemEmprestimo> lista = new ArrayList<>();

        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idEmprestimo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    br.locadora.model.entities.ModeloEquipamento mod = new br.locadora.model.entities.ModeloEquipamento();
                    mod.setNome(rs.getString("nome_modelo"));
                    Equipamento eq = new Equipamento();
                    eq.setIdEquipamento(rs.getInt("id_equipamento"));
                    eq.setNumeroSerie(rs.getString("numero_serie"));
                    eq.setModelo(mod);
                    ItemEmprestimo item = new ItemEmprestimo();
                    item.setEquipamento(eq);
                    item.setValorDiariaAplicado(rs.getDouble("valor_diaria_aplicado"));

                    lista.add(item);
                }
            }
            return lista;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao buscar itens do empréstimo: " + e.getMessage(), e);
        }
    }

    public void registrarDevolucao(Integer idEmprestimo) {
        String sqlEmprestimo = "UPDATE emprestimo SET status_emprestimo = ? WHERE id_emprestimo = ?";

        String sqlEquipamento = "UPDATE equipamento SET status = 'Disponível' "
                + "WHERE id_equipamento IN (SELECT id_equipamento FROM item_emprestimo WHERE id_emprestimo = ?)";

        try (Connection cn = DAO.abrirBanco()) {
            cn.setAutoCommit(false);

            try (PreparedStatement psEmp = cn.prepareStatement(sqlEmprestimo); PreparedStatement psEqp = cn.prepareStatement(sqlEquipamento)) {
                psEmp.setString(1, "Finalizado");
                psEmp.setInt(2, idEmprestimo);
                psEmp.executeUpdate();

                psEqp.setInt(1, idEmprestimo);
                psEqp.executeUpdate();

                cn.commit();
            } catch (SQLException e) {
                cn.rollback();
                throw e;
            } finally {
                cn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao registar a devolução: " + e.getMessage(), e);
        }
    }

    public List<Emprestimo> buscarPorFiltro(String nomeCliente, String status) {
    StringBuilder sql = new StringBuilder(
            "SELECT emp.id_emprestimo, emp.data_emissao, emp.data_prevista_devolucao, emp.status_emprestimo, "
            + "pc.id_pessoa AS id_cliente, pc.nome AS nome_cliente, "
            + "pf.id_pessoa AS id_funcionario, pf.nome AS nome_func, "
            + "COUNT(ie.id_equipamento) AS qtd_itens " 
            + "FROM emprestimo emp "
            + "INNER JOIN pessoa pc ON emp.id_cliente = pc.id_pessoa " 
            + "INNER JOIN pessoa pf ON emp.id_funcionario = pf.id_pessoa " 
            + "LEFT JOIN item_emprestimo ie ON emp.id_emprestimo = ie.id_emprestimo " 
            + "WHERE LOWER(pc.nome) LIKE ? "
    );

    boolean filtrarStatus = status != null && !status.equalsIgnoreCase("Todos") && !status.trim().isEmpty();
    if (filtrarStatus) {
        sql.append(" AND emp.status_emprestimo = ? ");
    }
    
    sql.append(" GROUP BY emp.id_emprestimo, emp.data_emissao, emp.data_prevista_devolucao, emp.status_emprestimo, ")
       .append("pc.id_pessoa, pc.nome, pf.id_pessoa, pf.nome ")
       .append("ORDER BY emp.id_emprestimo DESC");

    List<Emprestimo> lista = new ArrayList<>();
    try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql.toString())) {
        
        ps.setString(1, "%" + (nomeCliente != null ? nomeCliente.toLowerCase().trim() : "") + "%");
        
        if (filtrarStatus) {
            ps.setString(2, status.trim());
        }
        
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Cliente cli = new Cliente();
                cli.setIdPessoa(rs.getInt("id_cliente"));
                cli.setNome(rs.getString("nome_cliente"));
                
                Funcionario func = new Funcionario();
                func.setIdPessoa(rs.getInt("id_funcionario"));
                func.setNome(rs.getString("nome_func"));
                
                Emprestimo emp = new Emprestimo();
                emp.setIdEmprestimo(rs.getInt("id_emprestimo"));
                emp.setCliente(cli);
                emp.setFuncionario(func);
                emp.setDataEmprestimo(rs.getDate("data_emissao").toLocalDate());
                emp.setDataDevolucaoPrevista(rs.getDate("data_prevista_devolucao").toLocalDate());
                emp.setStatus(StatusEmprestimo.fromDescricao(rs.getString("status_emprestimo")));
                
                // Salvando o resultado da agregação no objeto
                emp.setQuantidadeItensAgregada(rs.getInt("qtd_itens")); 
                
                lista.add(emp);
            }
        }
        return lista;
    } catch (SQLException e) {
        throw new DataBaseException("Erro ao filtrar os empréstimos no banco de dados: " + e.getMessage(), e);
    }
}

    public double somarDividaAtivaDoCliente(Integer idCliente) {
        String sql = "SELECT SUM(valor_total) AS divida FROM emprestimo WHERE id_cliente = ? AND status_emprestimo = 'Aberto'";
        try (Connection cn = DAO.abrirBanco(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, idCliente);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("divida");
                }
            }
            return 0.0;
        } catch (SQLException e) {
            throw new DataBaseException("Erro ao calcular dívida do cliente.", e);
        }
    }

}

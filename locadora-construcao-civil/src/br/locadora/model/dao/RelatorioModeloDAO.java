/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.dao;

import br.locadora.model.dto.RelatorioModeloDTO;
import br.locadora.model.exceptions.DataBaseException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RelatorioModeloDAO {
    public List<RelatorioModeloDTO> listarModelosMaisAlugados() {
        String sql = "SELECT * FROM vw_modelos_mais_alugados";
        
        List<RelatorioModeloDTO> lista = new ArrayList<>();

        try (Connection cn = DAO.abrirBanco(); 
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RelatorioModeloDTO dto = new RelatorioModeloDTO();                
                dto.setCategoria(rs.getString("nome_categoria"));
                dto.setIdModelo(rs.getInt("id_modeloE"));
                dto.setNomeModelo(rs.getString("modelo"));
                dto.setMarca(rs.getString("marca"));
                dto.setValorDiariaPadrao(rs.getDouble("valor_diaria_padrao"));
                dto.setTotalLocacoes(rs.getInt("total_locacoes"));
                dto.setFaturamentoAcumulado(rs.getDouble("faturamento_acumulado"));

                lista.add(dto);
            }
            return lista;

        } catch (SQLException e) {
            throw new DataBaseException("Erro ao carregar o relatório da view: " + e.getMessage(), e);
        }
    }
}

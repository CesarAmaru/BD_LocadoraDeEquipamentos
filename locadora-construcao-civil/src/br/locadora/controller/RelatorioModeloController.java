/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.controller;

import br.locadora.model.dao.RelatorioModeloDAO;
import br.locadora.model.dto.RelatorioModeloDTO;
import java.util.List;

public class RelatorioModeloController {
   private final RelatorioModeloDAO dao;

    public RelatorioModeloController() {
        this.dao = new RelatorioModeloDAO();
    }

    public List<RelatorioModeloDTO> listarModelosMaisAlugados() {
        return dao.listarModelosMaisAlugados();
    } 
}

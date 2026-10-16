/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.dao;

import br.locadora.model.exceptions.DataBaseException;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DAO {
    private static Properties carregarPropriedades() {
        Properties props = new Properties();
        try (FileInputStream fs = new FileInputStream("config.properties")) {
            props.load(fs);
        } catch (IOException e) {
            System.err.println("Erro ao carregar arquivo de configurações: " + e.getMessage());
        }
        return props;
    }
    
    public static Connection abrirBanco()throws SQLException{
		Properties props = carregarPropriedades();
        String url = props.getProperty("db.url");
        String user = props.getProperty("db.user");
        String pw = props.getProperty("db.password");
        
		return DriverManager.getConnection(url, user, pw);
	}
}

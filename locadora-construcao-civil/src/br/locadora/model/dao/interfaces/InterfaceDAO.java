/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package br.locadora.model.dao.interfaces;

import java.util.List;

public interface InterfaceDAO<T> {
    public void inserir(T objeto);
    public T buscarporID(Integer id);
    public List<T> bucarTodos();
    public void deletar(T v);
    public void update(T v); 
}

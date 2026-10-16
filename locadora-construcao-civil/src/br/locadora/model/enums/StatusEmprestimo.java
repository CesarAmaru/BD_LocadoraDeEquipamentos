/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Enum.java to edit this template
 */
package br.locadora.model.enums;

public enum StatusEmprestimo {
    EM_ABERTO("Em Aberto"),
    FINALIZADO("Finalizado"),
    CANCELADO("Cancelado");
    
    private final String status;
    
    StatusEmprestimo(String status){
        this.status = status;
    }
    
    public String getStatus() {
        return status;
    }

    public static StatusEmprestimo fromDescricao(String texto) {
        if (texto != null) {
            for (StatusEmprestimo status : StatusEmprestimo.values()) {
                if (status.getStatus().equalsIgnoreCase(texto.trim())) {
                    return status;
                }
            }
        }
        throw new IllegalArgumentException("Status inválido retornado do banco: " + texto);
    }
    
    @Override
    public String toString() {
        return this.status; 
    }
    
}

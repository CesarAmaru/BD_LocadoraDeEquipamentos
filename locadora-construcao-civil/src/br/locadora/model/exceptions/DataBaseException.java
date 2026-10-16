/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.exceptions;

public class DataBaseException extends RuntimeException{
    public DataBaseException(String mensagem, Throwable causa){
        super(mensagem, causa);
    }
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.entities;

public class Funcionario extends Pessoa{
    private Double salario;
    private String cargo;
    private Funcionario supervisor;

    public Funcionario() {
        super();
    }

    public Funcionario(Integer idPessoa, String nome, String docCpfCnpj, String email, String telefone, Double salario, String cargo, Funcionario supervisor) {
        super(idPessoa, nome, docCpfCnpj, email, telefone);
        this.salario = salario;
        this.cargo = cargo;
        this.supervisor = supervisor;
    }

    public Double getSalario() {
        return salario;
    }

    public void setSalario(Double salario) {
        this.salario = salario;
    }

    public String getCargo() {
        return cargo;
    }

    public void setCargo(String cargo) {
        this.cargo = cargo;
    }

    public Funcionario getSupervisor() {
        return supervisor;
    }

    public void setSupervisor(Funcionario supervisor) {
        this.supervisor = supervisor;
    }
    
    @Override
    public String toString(){
        return super.getNome();
    }
}

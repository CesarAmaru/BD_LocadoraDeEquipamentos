/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package br.locadora.model.entities;

public class Pessoa {
 private Integer idPessoa;
    private String nome;
    private String docCpfCnpj;
    private String email;
    private String telefone;

    public Pessoa() {
    }

    public Pessoa(Integer idPessoa, String nome, String docCpfCnpj, String email, String telefone) {
        this.idPessoa = idPessoa;
        this.nome = nome;
        this.docCpfCnpj = docCpfCnpj;
        this.email = email;
        this.telefone = telefone;
    }

    public Integer getIdPessoa() {
        return idPessoa;
    }

    public void setIdPessoa(Integer idPessoa) {
        this.idPessoa = idPessoa;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getDocCpfCnpj() {
        return docCpfCnpj;
    }

    public void setDocCpfCnpj(String docCpfCnpj) {
        this.docCpfCnpj = docCpfCnpj;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTelefone() {
        return telefone;
    }

    public void setTelefone(String telefone) {
        this.telefone = telefone;
    }

    @Override
    public String toString() {
        return nome;
    }   
}

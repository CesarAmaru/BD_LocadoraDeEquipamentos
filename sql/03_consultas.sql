-- =============================================================================
-- 03_consultas.sql
-- Projeto Final — LABORATÓRIO DE BANCO DE DADOS
-- Domínio: Locadora de Equipamentos para Construção Civil
-- SGBD alvo: MySQL 8+
-- =============================================================================

USE locadora_equipamentos;

-- Pergunta de negócio 1: Quais são os nomes e e-mails de todas as pessoas cadastradas cujo nome começa com 'Carlos' ou contém 'Construtora', ordenados alfabeticamente pelo nome?

select nome, email
from pessoa
where nome like 'Carlos%' or nome like 'Construtora%'
Order by nome ASC;

-- Pergunta de negócio 2: Quais são os identificadores, números de série e status dos equipamentos físicos que estão atualmente com o status 'Disponível' ou 'Inativo'?

select id_equipamento, numero_serie, status
from equipamento
where status in ('Disponível', 'Inativo');

-- Pergunta de negócio 3: Quais modelos de equipamento possuem o valor da diária padrão entre R$ 100,00 e R$ 500,00, ordenados do valor mais alto para o mais baixo?

select * 
from modelo_equipamento
where valor_diaria_padrao between 100.00 and 500.00
order by valor_diaria_padrao DESC;

-- Pergunta de negócio 4: Quais pessoas cadastradas no banco de dados não forneceram um número de telefone para contato?

select id_pessoa, nome
from pessoa
where telefone is null;

-- Pergunta de negócio 5: Quais empréstimos foram registrados com o status 'Finalizado', organizados da data de emissão mais recente para a mais antiga?

select id_emprestimo, data_emissao, status_emprestimo
from emprestimo
where status_emprestimo = 'Finalizado'
order by data_emissao DESC;

-- Pergunta de negócio 6: Qual é o limite de crédito aprovado para cada cliente cadastrado, exibindo o nome completo da pessoa e o seu respectivo limite em ordem decrescente?

select p.nome, c.limite_credito
from pessoa p
inner join cliente c
	on p.id_pessoa = c.id_pessoa
order by c.limite_credito DESC;

-- Pergunta de negócio 7: Quais são todos os modelos de equipamento do catálogo e, caso já existam unidades físicas compradas para eles, quais os números de série e status dessas unidades?

select m.nome, e.numero_serie, e.status
from modelo_equipamento m
left join equipamento e
	on m.id_modeloE = e.id_modeloE;


-- Pergunta de negócio 8: Qual o nome do cliente, o nome do funcionário atendente, o número de série do equipamento alugado e a data de emissão para todos os contratos de locação já realizados?

select pC.nome as nome_cliente, pF.nome as nome_funcionario, eq.numero_serie, e.data_emissao
from emprestimo e
inner join item_emprestimo ie
	on e.id_emprestimo = ie.id_emprestimo
inner join equipamento eq
	on ie.id_equipamento = eq.id_equipamento
inner join cliente c
	on e.id_cliente = c.id_pessoa
inner join pessoa pC
	on pC.id_pessoa = c.id_pessoa
inner join funcionario f
	on e.id_funcionario = f.id_pessoa
inner join pessoa pF
	on pF.id_pessoa = f.id_pessoa;

-- Pergunta de negócio 9: Qual é a quantidade total de equipamentos físicos existentes na empresa, agrupada pelo seu status atual ('Disponível', 'Alugado', 'Inativo')?

select count(e.id_equipamento) as total_equipamentos_fisicos, e.status
from equipamento e
group by e.status;

-- Pergunta de negócio 10: Quais categorias do catálogo possuem estritamente mais de 1 modelo de equipamento vinculado a elas, exibindo o nome da categoria e a quantidade de modelos?

select c.nome_categoria, count(m.id_categoria) as quantidade_de_modelos
from categoria c
inner join modelo_equipamento m
	on c.id_categoria = m.id_categoria
group by c.id_categoria, c.nome_categoria
having count(m.id_categoria) > 1;

-- Pergunta de negócio 11: Quais modelos de equipamento possuem o valor da diária padrão superior à diária média calculada considerando exclusivamente os modelos pertencentes à sua própria categoria?

select c.nome_categoria, m.nome, m.valor_diaria_padrao
from modelo_equipamento m
inner join categoria c
	on m.id_categoria = c.id_categoria
where m.valor_diaria_padrao > (
	select avg(m2.valor_diaria_padrao)
    from modelo_equipamento m2
    where m2.id_categoria = m.id_categoria
    );

-- Pergunta de negócio 12: Quais clientes (nome e documento) possuem pelo menos um contrato de empréstimo já registrado no histórico da locadora?

select pC.nome, pC.doc_cpf_cnpj
from cliente c
inner join pessoa pC
	on c.id_pessoa = pC.id_pessoa
where exists (
	select 1
    from emprestimo e
	where e.id_cliente = c.id_pessoa
	);

-- Pergunta de negócio 13: Quais equipamentos físicos cadastrados no sistema nunca foram vinculados a nenhum empréstimo até o momento?

select m.nome, eq.id_equipamento
from equipamento eq
inner join modelo_equipamento m
	on eq.id_modeloE = m.id_modeloE
where not exists(
	select 1 
    from item_emprestimo ie
    where ie.id_equipamento = eq.id_equipamento
	);

-- Pergunta de negócio 14: Pergunta não trivial: Considerando todos os empréstimos não cancelados, qual foi o volume financeiro real (receita consolidada alocada) gerado por cada forma de pagamento cadastrada no sistema?

select fp.nome_forma, sum(efp.valor_alocado) as receita_consolidada
from emprestimo e
inner join emprestimo_forma_pagamento efp
	on e.id_emprestimo = efp.id_emprestimo
inner join forma_pagamento fp
	on efp.id_formaPgmt = fp.id_formaPgmt
where e.status_emprestimo in ('Finalizado', 'Em Aberto')
group by fp.nome_forma
order by receita_consolidada DESC;

-- Pergunta de negócio 15: Quais itens de locação comprovam a imunidade a reajustes (RN13), ou seja, onde o valor de diária cobrado no contrato (valor_diaria_aplicado) está com preço inferior ao valor de tabela atual do catálogo (valor_diaria_padrao)?

select m.nome, ie.valor_diaria_aplicado, m.valor_diaria_padrao
from equipamento e
inner join modelo_equipamento m
	on e.id_modeloE = m.id_modeloE
inner join item_emprestimo ie
	on e.id_equipamento = ie.id_equipamento
where ie.valor_diaria_aplicado < m.valor_diaria_padrao;
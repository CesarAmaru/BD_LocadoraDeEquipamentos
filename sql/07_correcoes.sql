-- =============================================================================
-- 05_correcoes_opcionais.sql  (OPCIONAL)
-- Correções em objetos que já existem no 01_ddl. NÃO alteram nenhum arquivo-fonte
-- (.java, 01_ddl, 02_carga), mas mudam o comportamento do banco depois de rodar.
-- Executar como administrador, depois do 03_seguranca_sem_alterar_codigo.sql.
-- =============================================================================
USE locadora_equipamentos;

-- 1.1 CORREÇÃO DA VIEW vw_modelos_mais_alugados
-- Problema: o filtro "status <> 'Cancelado'" estava no ON do LEFT JOIN com
-- emprestimo, o que apenas anulava as colunas de emprestimo, mas o item
-- continuava sendo contado. Resultado: locações canceladas entravam em
-- total_locacoes e faturamento_acumulado. Agora item e empréstimo são unidos
-- num join aninhado, e itens de empréstimos cancelados deixam de existir.
CREATE OR REPLACE VIEW vw_modelos_mais_alugados AS
SELECT
    cat.nome_categoria,
    me.id_modeloE,
    me.nome AS modelo,
    me.marca,
    me.valor_diaria_padrao,
    COUNT(ie.id_equipamento) AS total_locacoes,
    COALESCE(SUM(ie.valor_diaria_aplicado), 0.00) AS faturamento_acumulado
FROM modelo_equipamento me
INNER JOIN categoria cat ON me.id_categoria = cat.id_categoria
LEFT JOIN equipamento eq ON me.id_modeloE = eq.id_modeloE
LEFT JOIN (item_emprestimo ie
           INNER JOIN emprestimo emp
                   ON ie.id_emprestimo = emp.id_emprestimo
                  AND emp.status_emprestimo <> 'Cancelado')
       ON eq.id_equipamento = ie.id_equipamento
GROUP BY me.id_modeloE, me.nome, me.marca, me.valor_diaria_padrao, cat.nome_categoria
ORDER BY total_locacoes DESC, faturamento_acumulado DESC;

-- 1.3 RN20: item_emprestimo usava ON DELETE CASCADE, então um DELETE em
-- emprestimo apagava os itens e deixava os equipamentos como 'Alugado'.
-- O EmprestimoDAO.deletar já trata o erro de FK (SQLState 23000), ou seja,
-- espera RESTRICT. Empréstimo com itens passa a ser cancelado, não apagado.
ALTER TABLE item_emprestimo DROP FOREIGN KEY fk_item_emprestimo_emprestimo;
ALTER TABLE item_emprestimo ADD CONSTRAINT fk_item_emprestimo_emprestimo
    FOREIGN KEY (id_emprestimo) REFERENCES emprestimo (id_emprestimo)
    ON DELETE RESTRICT ON UPDATE CASCADE;
-- (historico_status_equipamento segue com CASCADE: só some junto com um
--  equipamento nunca usado, pois equipamento com itens já é protegido.)

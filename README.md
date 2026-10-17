# BD_LocadoraDeEquipamentos

## Sobre o Projeto

Um sistema dedicado à gestão operacional e financeira de uma Locadora de Equipamentos para Construção Civil. O negócio abrange desde o registo cadastral de clientes e funcionários até ao controlo de equipamentos, gestão do ciclo de vida de empréstimos e processamento financeiro de pagamentos.

Este projeto foi desenvolvido com foco académico na modelação de bases de dados relacionais, englobando todas as etapas de engenharia de software, desde a conceção dos requisitos de negócio e modelação concetual até à normalização e implementação de scripts estruturais e de consulta.

## Principais Funcionalidades

* **Gestão de Pessoas:** Registo centralizado utilizando herança relacional para separar Clientes e Funcionários, incluindo o mapeamento da hierarquia de supervisão interna.
* **Controlo de Acervo:** Separação lógica estrutural entre o catálogo base (Modelos e Categorias) e o inventário físico (Equipamentos reais com número de série único).
* **Operação de Locação:** Registo de empréstimos com recurso a tabelas associativas para garantir o congelamento histórico do valor da diária aplicado no momento da contratação.
* **Módulo Financeiro:** Associação de empréstimos a modalidades financeiras específicas, geração de faturação consolidada e fracionamento automático em parcelas (entidade fraca) com controlo rígido de datas de vencimento.

## Arquitetura da Base de Dados

A modelação atende a requisitos avançados da teoria relacional, incluindo:

* **Herança / Especialização:** Entidade genérica `Pessoa` subdividida em `Cliente` e `Funcionario`.
* **Autorrelacionamento:** Entidade `Funcionario` com referência interna à própria tabela para definir a hierarquia de supervisores.
* **Entidade Fraca:** `Parcela_pagamento` dependente existencialmente da entidade forte `Pagamento`, identificada por chave primária composta.
* **Relacionamentos N:N (Tabela Associativa):** Estrutura `Item_Emprestimo` contendo atributos próprios (preço negociado) para imunidade a reajustes inflacionários do catálogo.
* **Desnormalização Controlada (3FN):** Manutenção do atributo derivado `valor_total` na entidade `Emprestimo` com o objetivo de otimizar o desempenho em consultas operacionais.

## Artefatos do Projeto

A documentação técnica e os scripts estão estruturados cronologicamente de acordo com as seguintes fases de entrega:

* **relatorio-etapa1:** Relatório único em PDF reunindo os artefatos A1 a A5.
* **A2 - mer-conceitual:** Diagrama Entidade-Relacionamento desenvolvido para visualização de cardinalidades e hierarquias.
* **A3 - dicionario-dados:** Detalhamento formalizado de todas as entidades, atributos, domínios, tipagens e restrições obrigatórias.
* **A4 - modelo-logico:** Esquema em formato textual detalhando chaves primárias (PK), chaves estrangeiras (FK) e justificativas técnicas para as decisões de mapeamento e utilização de chaves substitutas numéricas (Surrogate Keys).
* **A5 - Relatório Técnico de Normalização:** Avaliação estrita das 11 tabelas de acordo com a teoria relacional, comprovando a transição até à Forma Normal de Boyce-Codd (FNBC).
* **Apresentação do Trabalho:** Documento para apresentação do Banco de Dados em sala de aula.
* **Scripts SQL de Implementação:**
  * **01_ddl.sql (A6):** Script de criação da base de dados, tabelas, constrangimentos (UNIQUE, CHECK, FOREIGN KEY) e gatilhos (Triggers) para atualização automática de estado e validação temporal.
  * **02_carga.sql (A7):** Script DML populando as tabelas com dados de teste coerentes e cenários de contorno (dados opcionais em branco, empréstimos cancelados, históricos).
  * **03_consultas.sql (A8):** Quinze consultas DQL documentadas e separadas por complexidade (Básicas, Junções/Agregação, Avançadas com subconsultas e operadores EXISTS).

---
# Aplicação Java
## Tecnologias e Ferramentas Utilizadas

* **Modelação Concetual:** brModelo (desktop)
* **SGBD Alvo e Implementação:** MySQL 8+
* **Linguagem:** SQL (DDL para criação de esquemas, DML para carga de dados, DQL para projeção e agregação analítica, e PL/SQL para Triggers).

---

## Como Executar o Projeto

Para rodar o sistema localmente na sua máquina, certifique-se de cumprir os requisitos e seguir os passos abaixo.

### Pré-requisitos
* **Java Development Kit (JDK):** Versão LTS 25 instalada na máquina.
* **MySQL Server:** Versão 8 ou superior.
* **Driver JDBC do MySQL:** Necessário para conectar a aplicação ao banco de dados.

### 1. Configuração do Banco de Dados e Credenciais
1. Execute o script `01_ddl.sql` no seu MySQL para criar o banco de dados e as tabelas.
2. Em seguida, execute o script `02_carga.sql` para popular as tabelas com os dados iniciais de teste.
3. Por questões de segurança, o arquivo de configuração do banco (`config.properties`) não é versionado neste repositório. **Você precisará criá-lo manualmente.**

Na raiz do projeto (ao lado da pasta `src` ou na mesma pasta do executável `.jar`), crie um arquivo chamado **`config.properties`** exatamente com a seguinte estrutura:

```properties
db.url=jdbc:mysql://caminhoIP:3306(<- porta padrão do MySQL)/nome_do_seu_banco
db.user=seu_usuario
db.password=sua_senha
```

### 2. Rodando o Executável (Release)
A forma mais rápida de testar o sistema é através do executável compilado.
1. Acesse a aba de **Releases** no menu lateral deste repositório no GitHub.
2. Faça o download do arquivo `.jar` ou `.zip` mais recente.
#### 3.1 UTILIZANDO `.zip` (MELHOR PARA WINDOWS)
*  3.1.1 Descompacte o `.zip` e faça os seguintes passos:
*  3.1.2 Coloque seu **Driver JDBC** dentro da pasta `drivers`
*   3.1.3 Garanta que seu `config.properties` esteja na mesma pasta que o `.exe`
*   3.1.4 Rode o executável
#### 3.2 UTILIZANDO `.jar` (S.O  EM GERAL)
*   3.2.1 Coloque o `.jar` em uma pasta de sua preferência
*  3.2.2 Crie a pasta  `drivers`
*  3.2.3 Na mesma pasta do arquivo `.jar` crie um arquivo `.bat` com as seguintes instruções:
*  **(Windows)**
   ```bat
   @echo off
   java -cp "locadora-construcao-civil.jar;drivers/*" br.locadora.view.TelaPrincipal
   pause
   ```
   **(Linux / macOS)**
   ```bash
     java -cp "locadora-construcao-civil.jar:drivers/*" br.locadora.view.TelaPrincipal
   ```
 *  3.2.4 Garanta que seu `config.properties` esteja na mesma pasta que o `.jar`
 *  3.2.5 Rode o arquivo `.bat`
   

### 3. Buildando a partir do Código-Fonte (IDE)
Se deseja abrir o código e buildar o projeto na sua própria IDE (como o NetBeans):
1. Clone o repositório e abra a pasta do projeto na sua IDE.
2. Certifique-se de adicionar a biblioteca do **MySQL JDBC Driver** ao *Classpath* (Libraries) do seu projeto.
3. Crie o arquivo `config.properties` na raiz do projeto (como explicado no passo 1).
4. Verifique se a Classe Principal está definida corretamente (ex: `br.locadora.view.TelaPrincipal`).
5. Execute a opção **Clean and Build** (Limpar e Construir) para gerar o pacote.
6. Rode o projeto.

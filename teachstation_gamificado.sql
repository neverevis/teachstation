-- =====================================================
-- TeachStation - Questionários Gamificados
-- =====================================================
-- Script ADICIONAL e INCREMENTAL: não altera, não apaga e não recria
-- nenhuma tabela ou registro existente (inclusive `questoes`).
--
-- Como executar (uma vez, manualmente, depois do teachstation.sql):
--   mysql -u root -p teachstation < teachstation_gamificado.sql
-- Pode ser executado várias vezes: CREATE TABLE IF NOT EXISTS e
-- INSERT IGNORE (chave primária fixa) evitam duplicações.
--
-- Por que tabelas novas e nenhuma linha nova em `questoes`:
-- a Avaliação Diagnóstica (FirstTestController) carrega TODAS as questões
-- da área 1 e usa a quantidade de linhas de `tentativas_atividades` do aluno
-- como posição na prova. Inserir questões ali, ou gravar tentativas
-- gamificadas naquela tabela, alteraria a avaliação diagnóstica.

SET NAMES utf8mb4;

USE `teachstation`;

-- =====================================================
-- Tabela: questoes_gamificadas
-- =====================================================
-- tipo:          ASSOCIACAO | PREENCHIMENTO | MULTIPLA_ESCOLHA
-- questao_id:    questão original em `questoes`, quando houver correspondência
--                (NULL nas questões novas, adaptadas do banco de questões).
-- conteudo_json: parte exibida ao aluno (sem gabarito).
-- gabarito_json: respostas corretas; fica somente no servidor até a questão ser resolvida.
-- origem:        simulado/questão que inspirou a adaptação (rastreabilidade).

CREATE TABLE IF NOT EXISTS `questoes_gamificadas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `questao_id` INT NULL DEFAULT NULL,
    `area_id` INT NOT NULL,
    `fase` INT NOT NULL DEFAULT 1,
    `ordem` INT NOT NULL,
    `tipo` ENUM('ASSOCIACAO', 'PREENCHIMENTO', 'MULTIPLA_ESCOLHA') NOT NULL,
    `enunciado` TEXT NOT NULL,
    `texto_apoio` TEXT NULL DEFAULT NULL,
    `conteudo_json` TEXT NOT NULL,
    `gabarito_json` TEXT NOT NULL,
    `explicacao` TEXT NULL DEFAULT NULL,
    `pontos` INT NOT NULL DEFAULT 10,
    `origem` VARCHAR(255) NULL DEFAULT NULL,

    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_questoes_gamificadas_fase_ordem` (`fase` ASC, `ordem` ASC) VISIBLE,
    INDEX `questao_id` (`questao_id` ASC) VISIBLE,
    INDEX `area_id` (`area_id` ASC) VISIBLE,

    CONSTRAINT `questoes_gamificadas_ibfk_1`
        FOREIGN KEY (`questao_id`)
        REFERENCES `questoes` (`id`)
        ON DELETE SET NULL,

    CONSTRAINT `questoes_gamificadas_ibfk_2`
        FOREIGN KEY (`area_id`)
        REFERENCES `areas_conhecimento` (`id`)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- =====================================================
-- Tabela: tentativas_gamificadas
-- =====================================================
-- Uma linha por tentativa de resposta. `rodada` permite jogar a fase de novo
-- sem apagar o histórico. A chave única impede registrar duas vezes a mesma
-- tentativa (duplo clique ou requisições simultâneas).

CREATE TABLE IF NOT EXISTS `tentativas_gamificadas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `aluno_id` INT NOT NULL,
    `questao_gamificada_id` INT NOT NULL,
    `rodada` INT NOT NULL DEFAULT 1,
    `numero_tentativa` INT NOT NULL,
    `resposta_json` TEXT NOT NULL,
    `acertou` TINYINT(1) NOT NULL,
    `pontos_obtidos` INT NOT NULL DEFAULT 0,
    `data_tentativa` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_tentativas_gamificadas`
        (`aluno_id` ASC, `questao_gamificada_id` ASC, `rodada` ASC, `numero_tentativa` ASC) VISIBLE,
    INDEX `questao_gamificada_id` (`questao_gamificada_id` ASC) VISIBLE,

    CONSTRAINT `tentativas_gamificadas_ibfk_1`
        FOREIGN KEY (`aluno_id`)
        REFERENCES `aluno` (`id`)
        ON DELETE CASCADE,

    CONSTRAINT `tentativas_gamificadas_ibfk_2`
        FOREIGN KEY (`questao_gamificada_id`)
        REFERENCES `questoes_gamificadas` (`id`)
        ON DELETE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- =====================================================
-- Questões gamificadas - Português: 1 questão por fase do overworld (fases 1 a 8;
-- as questões 9 e 10 ficam guardadas nas fases 9 e 10, ainda sem botão no mapa)
-- =====================================================
-- Todas adaptadas do banco de questões (Simulados A1 e B1, 2º semestre).
-- Nenhuma das 10 questões já cadastradas em `questoes` foi reutilizada.
-- Seguindo o padrão do teachstation.sql, os textos de apoio são versões
-- ADAPTADAS/ORIGINAIS, escritas para manter a habilidade avaliada.
--
-- Tipo de cada fase: 1 MC, 2 ASSOC, 3 PREENCH, 4 MC, 5 ASSOC,
--                    6 PREENCH, 7 MC, 8 ASSOC, 9 PREENCH, 10 MC.
-- Gabarito (derivado do próprio texto adaptado; as fotos do banco não trazem gabarito):
--   MC:     q1 = B | q4 = C | q7 = D | q10 = A
--   ASSOC e PREENCH: ver gabarito_json de cada linha.
-- Colunas: id, questao_id, area_id, fase, ordem, tipo, enunciado, texto_apoio,
--          conteudo_json, gabarito_json, explicacao, pontos, origem

INSERT IGNORE INTO `questoes_gamificadas`
(`id`, `questao_id`, `area_id`, `fase`, `ordem`, `tipo`, `enunciado`, `texto_apoio`,
 `conteudo_json`, `gabarito_json`, `explicacao`, `pontos`, `origem`)
VALUES
(1, NULL, 1, 1, 1, 'MULTIPLA_ESCOLHA', 'A visita de Clara era mais do que uma simples visita porque', 'Para Bia, foi uma novidade e tanto saber que sua prima Clara viria passar uma semana em sua casa, em Brasília. Bia ficou feliz por ter companhia no quarto.
Mas a viagem de Clara era mais do que uma simples visita: ela morava em São Paulo e tinha sido escolhida para representar sua escola numa viagem de crianças de todo o país. Lá, seria recebida pelo próprio presidente da República, e seria Clara quem iria discursar para ele.
Clara tinha só dez anos, como Bia, mas já fazia coisas de gente grande!', '{"opcoes":[{"id":"A","texto":"ela morava em São Paulo e iria conhecer Brasília pela primeira vez."},{"id":"B","texto":"ela faria um discurso para o presidente da República."},{"id":"C","texto":"ela e Bia trocariam confidências e falariam dos meninos da escola."},{"id":"D","texto":"ela deixaria Bia contente por ter uma companhia no quarto."}]}', '{"correta":"B"}', 'No texto, Clara foi escolhida para discursar para o presidente da República. Isso torna a visita especial. Ter companhia no quarto é um motivo comum a qualquer visita.', 10, 'Simulado A1 q13 (Livro 1) - texto adaptado'),
(2, NULL, 1, 2, 1, 'ASSOCIACAO', 'Conecte cada frase à palavra que ela define.', NULL, '{"esquerda":[{"id":"a","texto":"Pessoa que gasta dinheiro em excesso, sem se preocupar com o futuro."},{"id":"b","texto":"Grupo de pessoas escolhido para representar outras e agir em nome delas."},{"id":"c","texto":"Palavra muito grande e difícil de pronunciar, como “paralelepípedo”."},{"id":"d","texto":"Que chega sempre na hora certa, sem atrasos."}],"direita":[{"id":"1","texto":"palavrão"},{"id":"2","texto":"pontual"},{"id":"3","texto":"delegação"},{"id":"4","texto":"perdulário"}]}', '{"a":"4","b":"3","c":"1","d":"2"}', 'Perdulário e delegação vêm dos glossários das avaliações. Em “palavrão”, o sufixo -ão indica tamanho grande (palavra grande). Pontual descreve quem não se atrasa.', 10, 'Simulados A1 q22 e q13 (glossários), A1 q2 e B1 q15 (palavrão) - vocabulário'),
(3, NULL, 1, 3, 1, 'PREENCHIMENTO', 'Complete a frase da receita com o verbo no tempo correto.', 'Arroz doce - modo de preparo
1. Coloque o arroz para cozinhar com quatro medidas de água.
2. Complete a frase do próximo passo, logo abaixo.
3. Desligue o fogo e acrescente o leite condensado e o creme de leite.', '{"frase":"Quando o arroz {1} bem molinho, acrescente o leite de coco e deixe ferver por mais dois minutos.","opcoes":[{"id":"o1","texto":"estava"},{"id":"o2","texto":"estiver"},{"id":"o3","texto":"estará"},{"id":"o4","texto":"estaria"}]}', '{"1":"o2"}', 'Em instruções que indicam uma condição futura, usa-se o futuro do subjuntivo depois de “quando”: “quando o arroz estiver bem molinho”.', 10, 'Simulado A1 q14 (Livro 1) - receita de arroz doce'),
(4, NULL, 1, 4, 1, 'MULTIPLA_ESCOLHA', 'No texto, a expressão “vrrrum” representa', 'Dona Lia levou o neto à praça. De repente, uma moto passou pela rua — vrrrum! — e levantou a poeira.
O menino tapou o nariz e riu:
— Vovó, a moto vai tão rápido que parece um foguete!', '{"opcoes":[{"id":"A","texto":"a voz de Dona Lia."},{"id":"B","texto":"a fala do neto."},{"id":"C","texto":"o barulho da moto."},{"id":"D","texto":"o som da praça."}]}', '{"correta":"C"}', '“Vrrrum” imita o barulho da moto passando. Esse recurso, que escreve um som, chama-se onomatopeia.', 10, 'Simulado A1 q7 e q8 (Livro 1) - onomatopeia, texto adaptado'),
(5, NULL, 1, 5, 1, 'ASSOCIACAO', 'Conecte cada frase ao gênero textual que ela descreve.', NULL, '{"esquerda":[{"id":"a","texto":"Texto que traz ingredientes e modo de preparo para ensinar a fazer um prato."},{"id":"b","texto":"Texto que usa imagens e frases curtas para convencer o público a participar de uma campanha."},{"id":"c","texto":"Texto escrito em versos, que costuma brincar com os sons e com as emoções."},{"id":"d","texto":"Texto que informa os leitores sobre um fato recente."}],"direita":[{"id":"1","texto":"poema"},{"id":"2","texto":"notícia"},{"id":"3","texto":"receita"},{"id":"4","texto":"cartaz"}]}', '{"a":"3","b":"4","c":"1","d":"2"}', 'Cada gênero tem uma função: a receita instrui, o cartaz convence, o poema trabalha com versos e emoções, e a notícia informa sobre fatos.', 10, 'Simulados A1 q11, q14, q17, q18 e B1 q18 - gêneros textuais'),
(6, NULL, 1, 6, 1, 'PREENCHIMENTO', 'Complete a frase com os verbos nos tempos corretos.', NULL, '{"frase":"Na semana passada, o pediatra {1} que não se deve misturar sorvete com gripe. A partir de amanhã, as crianças {2} sorvete só depois de ficarem boas.","opcoes":[{"id":"o1","texto":"explicará"},{"id":"o2","texto":"tomarão"},{"id":"o3","texto":"explicou"},{"id":"o4","texto":"tomaram"}]}', '{"1":"o3","2":"o2"}', '“Na semana passada” pede o passado (explicou). “A partir de amanhã” pede o futuro (tomarão). Os verbos também precisam concordar: o pediatra explicou; as crianças tomarão.', 10, 'Simulado A1 q10 e B1 q17 (Livro 1 e 2) - tema do sorvete, frase nova'),
(7, NULL, 1, 7, 1, 'MULTIPLA_ESCOLHA', 'A ideia principal do texto é', 'Em 2006, os astrônomos decidiram que Plutão não é mais considerado um planeta. Eles criaram uma nova categoria, a dos “planetas-anões”, e passaram a classificar Plutão nela.
Assim, o Sistema Solar tem oito planetas: Mercúrio, Vênus, Terra, Marte, Júpiter, Saturno, Urano e Netuno.', '{"opcoes":[{"id":"A","texto":"a descoberta de Plutão no Sistema Solar."},{"id":"B","texto":"o surgimento de um novo planeta."},{"id":"C","texto":"a classificação dos satélites naturais."},{"id":"D","texto":"a nova classificação de Plutão como planeta-anão."}]}', '{"correta":"D"}', 'O texto trata da mudança na classificação de Plutão, que deixou de ser planeta e passou a ser planeta-anão.', 10, 'Simulado B1 q7 (Livro 2) - texto adaptado'),
(8, NULL, 1, 8, 1, 'ASSOCIACAO', 'Conecte cada descrição ao personagem do folclore brasileiro.', 'Todos os anos, criaturas fantásticas do folclore brasileiro se reúnem na floresta, à beira de um rio, para ver quantas histórias contam sobre a sua fama.', '{"esquerda":[{"id":"a","texto":"Menino travesso de uma perna só, que usa gorro vermelho."},{"id":"b","texto":"Homem que, nas noites de lua cheia, vira um animal parecido com um lobo."},{"id":"c","texto":"Menino da lenda gaúcha que ajuda a encontrar objetos perdidos."}],"direita":[{"id":"1","texto":"Negrinho do Pastoreiro"},{"id":"2","texto":"Saci-Pererê"},{"id":"3","texto":"Lobisomem"}]}', '{"a":"2","b":"3","c":"1"}', 'Saci-Pererê, Lobisomem e Negrinho do Pastoreiro são personagens do folclore brasileiro, citados no texto-base da avaliação.', 10, 'Simulado A1 q5 (Livro 1) - folclore brasileiro'),
(9, NULL, 1, 9, 1, 'PREENCHIMENTO', 'Complete a frase com os verbos nos tempos corretos.', NULL, '{"frase":"Quando o pai de Simbad {1}, deixou-lhe uma grande riqueza. Naquela época, Simbad {2} dinheiro sem pensar no futuro.","opcoes":[{"id":"o1","texto":"morrerá"},{"id":"o2","texto":"gastava"},{"id":"o3","texto":"morreu"},{"id":"o4","texto":"gastará"}]}', '{"1":"o3","2":"o2"}', '“Deixou-lhe” indica que o pai já tinha morrido: morreu. “Naquela época” indica um hábito do passado: gastava.', 10, 'Simulado A1 q22 (Livro 1) - história de Simbad, frase nova'),
(10, NULL, 1, 10, 1, 'MULTIPLA_ESCOLHA', 'O cartaz tem a intenção de promover a', 'LIVRE-SE DAQUELE PNEUZINHO!
Pneus velhos guardados em casa acumulam água da chuva e viram criadouros do mosquito Aedes aegypti, que transmite a dengue.
Coloque os pneus na calçada nos dias de recolhimento.
SEM PNEU, SEM MOSQUITO!', '{"opcoes":[{"id":"A","texto":"prevenção contra a dengue."},{"id":"B","texto":"doação de objetos usados."},{"id":"C","texto":"perda de gordura corporal."},{"id":"D","texto":"venda de pneus em estoque."}]}', '{"correta":"A"}', 'O cartaz pede que as pessoas descartem os pneus velhos para evitar que o mosquito da dengue se reproduza.', 10, 'Simulado A1 q18 (Livro 1) - cartaz, texto adaptado');


-- Correção para bancos que já executaram uma versão anterior deste script:
-- troca o cenário da questão 4 ("feira" -> "praça") para não repetir o cenário
-- da avaliação diagnóstica. É idempotente (pode ser executado várias vezes).
UPDATE `questoes_gamificadas`
SET `texto_apoio` = REPLACE(`texto_apoio`, 'à feira.', 'à praça.'),
    `conteudo_json` = REPLACE(`conteudo_json`, 'o som da feira.', 'o som da praça.')
WHERE `id` = 4;

-- Mesma correção para a questão 2: a palavra "inflexível" também aparece na
-- avaliação diagnóstica (trecho de Policarpo Quaresma) e foi trocada por "pontual".
UPDATE `questoes_gamificadas`
SET `conteudo_json` = REPLACE(REPLACE(`conteudo_json`,
        'Que não cede nem muda de ideia, mesmo diante de pedidos.',
        'Que chega sempre na hora certa, sem atrasos.'),
        '"texto":"inflexível"', '"texto":"pontual"'),
    `explicacao` = REPLACE(`explicacao`,
        'Inflexível descreve quem não muda de ideia.',
        'Pontual descreve quem não se atrasa.'),
    `origem` = REPLACE(`origem`, ', B1 q14 (inflexível) - vocabulário', ' - vocabulário')
WHERE `id` = 2;


-- Redistribuição: cada questão passa a ser a única questão da sua própria fase
-- (id N -> fase N, ordem 1). Serve para bancos que já executaram uma versão
-- anterior, em que as 10 questões estavam todas na fase 1. É idempotente.
UPDATE `questoes_gamificadas`
SET `fase` = `id`, `ordem` = 1
WHERE `id` BETWEEN 1 AND 10;

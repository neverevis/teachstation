-- =====================================================
-- TeachStation - Banco de Dados
-- =====================================================


SET NAMES utf8mb4;
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `teachstation`
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

USE `teachstation`;

-- =====================================================
-- Tabela: usuario
-- =====================================================

CREATE TABLE IF NOT EXISTS `usuario` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nome_completo` VARCHAR(150) NOT NULL,
    `nome_social` VARCHAR(150) NULL DEFAULT NULL,
    `email` VARCHAR(100) NOT NULL,
    `senha` VARCHAR(255) NOT NULL,
    `data_nascimento` DATE NOT NULL,
    `genero` VARCHAR(50) NULL DEFAULT NULL,
    `tipo_usuario` ENUM('ALUNO', 'PROFESSOR', 'SECRETARIA') NOT NULL,
    `data_cadastro` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),
    UNIQUE INDEX `email` (`email` ASC) VISIBLE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- =====================================================
-- Tabela: aluno
-- =====================================================

CREATE TABLE IF NOT EXISTS `aluno` (
    `id` INT NOT NULL,
    `ra` VARCHAR(20) NOT NULL,
    `telefone_responsavel` VARCHAR(20) NULL DEFAULT NULL,
    `nivel_atual` ENUM('INICIANTE', 'INTERMEDIARIO', 'AVANCADO') NULL DEFAULT 'INICIANTE',

    PRIMARY KEY (`id`),
    UNIQUE INDEX `ra` (`ra` ASC) VISIBLE,

    CONSTRAINT `aluno_ibfk_1`
        FOREIGN KEY (`id`)
        REFERENCES `usuario` (`id`)
        ON DELETE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- =====================================================
-- Tabela: professor
-- =====================================================

CREATE TABLE IF NOT EXISTS `professor` (
    `id` INT NOT NULL,
    `prontuario` VARCHAR(20) NOT NULL,
    `telefone` VARCHAR(20) NULL DEFAULT NULL,
    `area_atuacao` VARCHAR(100) NULL DEFAULT NULL,

    PRIMARY KEY (`id`),
    UNIQUE INDEX `prontuario` (`prontuario` ASC) VISIBLE,

    CONSTRAINT `professor_ibfk_1`
        FOREIGN KEY (`id`)
        REFERENCES `usuario` (`id`)
        ON DELETE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- =====================================================
-- Tabela: secretaria
-- =====================================================

CREATE TABLE IF NOT EXISTS `secretaria` (
    `id` INT NOT NULL,
    `codigo_funcionario` VARCHAR(20) NOT NULL,

    PRIMARY KEY (`id`),
    UNIQUE INDEX `codigo_funcionario` (`codigo_funcionario` ASC) VISIBLE,

    CONSTRAINT `secretaria_ibfk_1`
        FOREIGN KEY (`id`)
        REFERENCES `usuario` (`id`)
        ON DELETE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- =====================================================
-- Tabela: areas_conhecimento
-- =====================================================

CREATE TABLE IF NOT EXISTS `areas_conhecimento` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nome` VARCHAR(100) NOT NULL,
    `ativo` TINYINT(1) NULL DEFAULT 0,

    PRIMARY KEY (`id`)
)
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- =====================================================
-- Tabela: avaliacao_diagnostica
-- =====================================================

CREATE TABLE IF NOT EXISTS `avaliacao_diagnostica` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `aluno_id` INT NOT NULL,
    `data_avaliacao` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
    `nota_final` DECIMAL(5,2) NULL DEFAULT NULL,
    `nivel_classificado` ENUM('INICIANTE', 'INTERMEDIARIO', 'AVANCADO') NULL DEFAULT NULL,

    PRIMARY KEY (`id`),
    INDEX `aluno_id` (`aluno_id` ASC) VISIBLE,

    CONSTRAINT `avaliacoes_diagnosticas_ibfk_1`
        FOREIGN KEY (`aluno_id`)
        REFERENCES `aluno` (`id`)
        ON DELETE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- =====================================================
-- Tabela: questoes
-- =====================================================
-- texto_apoio: texto que o aluno lê antes de responder ("Leia o texto").
-- imagem_url:  ilustração exibida na questão (arquivos em static/images/questoes).

CREATE TABLE IF NOT EXISTS `questoes` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `area_id` INT NOT NULL,
    `enunciado` TEXT NOT NULL,
    `texto_apoio` TEXT NULL DEFAULT NULL,
    `imagem_url` VARCHAR(255) NULL DEFAULT NULL,
    `tipo` ENUM('TESTE') NOT NULL DEFAULT 'TESTE',
    `dificuldade` ENUM('INICIANTE', 'INTERMEDIARIA', 'AVANCADA') NOT NULL,
    `pontos` INT NOT NULL,

    PRIMARY KEY (`id`),
    INDEX `area_id` (`area_id` ASC) VISIBLE,

    CONSTRAINT `questoes_ibfk_1`
        FOREIGN KEY (`area_id`)
        REFERENCES `areas_conhecimento` (`id`)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- =====================================================
-- Tabela: opcoes_questoes (Opções / Alternativas / Gabarito)
-- =====================================================

CREATE TABLE IF NOT EXISTS `opcoes_questoes` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `questao_id` INT NOT NULL,
    `letra` VARCHAR(5) NULL DEFAULT NULL, -- Ex: 'A', 'B', 'C', 'D'
    `texto` TEXT NOT NULL,
    `correta` TINYINT(1) NOT NULL DEFAULT 0, -- 1 para a opção correta (Gabarito), 0 para incorreta

    PRIMARY KEY (`id`),
    INDEX `questao_id` (`questao_id` ASC) VISIBLE,

    CONSTRAINT `opcoes_questoes_ibfk_1`
        FOREIGN KEY (`questao_id`)
        REFERENCES `questoes` (`id`)
        ON DELETE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- =====================================================
-- Tabela: tentativas_atividades
-- =====================================================

CREATE TABLE IF NOT EXISTS `tentativas_atividades` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `aluno_id` INT NOT NULL,
    `questao_id` INT NOT NULL,
    `opcao_selecionada_id` INT NULL DEFAULT NULL,
    `data_tentativa` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
    `acertou` TINYINT(1) NOT NULL,
    `pontos_obtidos` INT NULL DEFAULT 0,

    PRIMARY KEY (`id`),
    INDEX `aluno_id` (`aluno_id` ASC) VISIBLE,
    INDEX `questao_id` (`questao_id` ASC) VISIBLE,
    INDEX `opcao_selecionada_id` (`opcao_selecionada_id` ASC) VISIBLE,

    CONSTRAINT `tentativas_atividades_ibfk_1`
        FOREIGN KEY (`aluno_id`)
        REFERENCES `aluno` (`id`)
        ON DELETE CASCADE,

    CONSTRAINT `tentativas_atividades_ibfk_2`
        FOREIGN KEY (`questao_id`)
        REFERENCES `questoes` (`id`)
        ON DELETE CASCADE,

    CONSTRAINT `tentativas_atividades_ibfk_3`
        FOREIGN KEY (`opcao_selecionada_id`)
        REFERENCES `opcoes_questoes` (`id`)
        ON DELETE SET NULL
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

-- =====================================================
-- POPULAÇÃO INICIAL DO BANCO
-- =====================================================

-- =====================================================
-- Usuários
-- =====================================================

-- SENHA dos usuários comuns: 123456
-- SENHA ADMIN (secretaria): 123
INSERT IGNORE INTO `usuario`
(`id`, `nome_completo`, `nome_social`, `email`, `senha`, `data_nascimento`, `genero`, `tipo_usuario`)
VALUES
(1, 'Maria Silva', NULL, 'maria@gmail.com', '$2a$10$oXCUubZy0HEMCuClALRXvu2kPrzdiBVcRV29SC9XXNEMsyOCQIEyC', '2008-05-15', 'Feminino', 'ALUNO'),
(2, 'João Santos', NULL, 'joao@gmail.com', '$2a$10$oXCUubZy0HEMCuClALRXvu2kPrzdiBVcRV29SC9XXNEMsyOCQIEyC', '2009-08-20', 'Masculino', 'ALUNO'),
(3, 'Roberta', NULL, 'roberta@gmail.com', '$2a$10$oXCUubZy0HEMCuClALRXvu2kPrzdiBVcRV29SC9XXNEMsyOCQIEyC', '2009-08-20', 'Feminino', 'ALUNO'),
(4, 'Joana', NULL, 'joana@gmail.com', '$2a$10$oXCUubZy0HEMCuClALRXvu2kPrzdiBVcRV29SC9XXNEMsyOCQIEyC', '2009-08-20', 'Feminino', 'ALUNO'),
(5, 'Ana Oliveira', 'Ana', 'ana@gmail.com', '$2a$10$oXCUubZy0HEMCuClALRXvu2kPrzdiBVcRV29SC9XXNEMsyOCQIEyC', '1985-03-10', 'Feminino', 'PROFESSOR'),
(6, 'Secretaria', NULL, 'admin@gmail.com', '$2a$10$EYiwVXTbPCJs6rPdZKbC8ustD218M1vDbftxOcxlK/LOzmlYgG9wm', '1980-11-25', 'Feminino', 'SECRETARIA');

-- =====================================================
-- Alunos
-- =====================================================

INSERT IGNORE INTO `aluno`
(`id`, `ra`, `telefone_responsavel`, `nivel_atual`)
VALUES
(1, '20260001', '(16) 99999-1111', NULL),
(2, '20260002', '(16) 99999-2222', NULL),
(3, '20260003', '(16) 99999-3333', NULL),
(4, '20260004', '(16) 99999-4444', NULL);

-- =====================================================
-- Professores
-- =====================================================

INSERT IGNORE INTO `professor`
(`id`, `prontuario`, `telefone`, `area_atuacao`)
VALUES

(5, 'AQ000124', '(16) 99999-5555', 'Língua Portuguesa');

-- =====================================================
-- Secretaria
-- =====================================================

INSERT IGNORE INTO `secretaria`
(`id`, `codigo_funcionario`)
VALUES

(6, 'SEC002');

-- =====================================================
-- Áreas de conhecimento
-- =====================================================

INSERT IGNORE INTO `areas_conhecimento`
(`id`, `nome`, `ativo`)
VALUES
(1, 'Português', 1);

-- =====================================================
-- Questões (Simulados A1 e B1 - Avaliação Diagnóstica, 2º semestre)
-- =====================================================
-- Avaliação diagnóstica: 10 questões (nota de 0 a 200), misturando os simulados A1 e B1:
--   ids 1-3   INICIANTE      (3 questões x 30 pts = 90)   - simulado A1
--   ids 4-7   INTERMEDIARIA  (4 questões x 20 pts = 80)   - simulado B1
--   ids 8-10  AVANCADA       (3 questões x 10 pts = 30)   - simulado B1
-- Níveis: <= 90 INICIANTE | <= 170 INTERMEDIARIO | > 170 AVANCADO
-- O comentário acima de cada questão indica a origem e o texto de apoio.
-- ids das opções: (id_da_questão - 1) * 4 + 1 (A) ... + 4 (D)

INSERT IGNORE INTO `questoes`
(`id`, `area_id`, `enunciado`, `texto_apoio`, `imagem_url`, `tipo`, `dificuldade`, `pontos`)
VALUES
-- A1 q9 / B1 q16 | 'Anedota' (Ziraldo)  >> texto de apoio ORIGINAL (substitui o do simulado)
(1, 1, 'Esse texto tem graça porque o moço do guichê pensou que Florisbela era o nome', 'Seu Tonico chegou ao guichê da rodoviária, sorrindo de orelha a orelha.
— Bom dia, moço! Me dá uma passagem para Florisbela, por favor.
O moço do guichê olhou a lista de viagens e coçou a cabeça:
— Florisbela? Aqui não tem nenhuma estação com esse nome.
— Mas tem a minha irmã! — explicou Seu Tonico. — Hoje ela faz aniversário e eu vou visitá-la.', '/images/questoes/q1.svg', 'TESTE', 'INICIANTE', 30),
-- A1 q12 / B1 q10 | 'O Dia da Terra é mais importante do que nunca' (nacoesunidas.org)  >> texto de apoio ORIGINAL (substitui o do simulado)
(2, 1, 'O trecho que mostra a opinião do autor do texto é:', 'Todo ano, no dia 22 de abril, as pessoas param para pensar no planeta. 22 de abril é o Dia da Terra.
A primeira vez que o Dia da Terra foi celebrado foi em 1970. Vinte milhões de pessoas, preocupadas com a poluição do ar e dos rios, foram às ruas protestar.
Elas mostraram que, quando muita gente se une, as coisas podem mudar.
Hoje o planeta ainda precisa de ajuda. Por isso, agora é hora de demonstrarmos solidariedade, cuidando da natureza todos juntos.', '/images/questoes/q2.svg', 'TESTE', 'INICIANTE', 30),
-- A1 q20 / B1 q9 | 'A brisa e a flor' (Iza Ramos de Azevedo Souza)  >> texto de apoio ORIGINAL (substitui o do simulado)
(3, 1, 'Pode-se afirmar que quem “Quis seguir”', 'Na manhã de sol, uma brisa fresca passeava pelo jardim e fazia cócegas nas pétalas da florzinha.
Um colibri parou ali perto, bebeu um golinho de néctar e saiu zumbindo.
A florzinha ficou olhando. Quis seguir o colibri pelo céu azul, mas não podia: suas raízes a prendiam à terra.', '/images/questoes/q3.svg', 'TESTE', 'INICIANTE', 30),
-- B1 q3 | Poema 'Inutilidade' (José Paulo Paes)  >> texto de apoio ORIGINAL (substitui o do simulado)
(4, 1, 'Esse texto provoca um efeito humorístico porque', 'A cadeira tem pé, mas nunca andou.
A camisa tem botão, mas não toca campainha.
A xícara tem boca, mas nunca falou.
O sofá tem braço, mas não sabe abraçar.', '/images/questoes/q4.svg', 'TESTE', 'INTERMEDIARIA', 20),
-- B1 q4 | 'Auto da compadecida' (Ariano Suassuna)  >> texto de apoio ORIGINAL (substitui o do simulado)
(5, 1, 'Na fala de Zeca, as expressões “Muito pelo contrário” e “Mas” estabelecem um efeito de', 'TONICO: — Você está com preguiça de ajudar na feira, Zeca?
ZECA: — Muito pelo contrário! Eu adoro ajudar. Mas hoje meu braço está doendo.', '/images/questoes/q5.svg', 'TESTE', 'INTERMEDIARIA', 20),
-- B1 q6 | Diálogo 'Mas, mãe! Como pode?' (Ciência Hoje das Crianças)  >> texto de apoio ORIGINAL (substitui o do simulado)
(6, 1, 'Em qual das frases do texto observa-se uma relação de causa e consequência?', '— Mãe, olha! Eu vejo a minha sombra no chão, mas não consigo pegá-la!
— É que a sombra não é uma coisa, filho. Ela só aparece porque o sol bate em você e a luz não consegue passar.
— E quando não tem sol, onde ela fica?
— Ela não fica em lugar nenhum, filho. Só fica o chão claro.', '/images/questoes/q6.svg', 'TESTE', 'INTERMEDIARIA', 20),
-- B1 q12 | Fábula 'Hierarquia' (Millôr Fernandes) - adjetivos que o leão usa contra o rato  >> texto de apoio ORIGINAL (substitui o do simulado)
(7, 1, 'Na fala do leão, as palavras “feio”, “sujo”, “fraco”, “ridículo” e “inútil” têm o objetivo de', 'O leão acordou de mau humor. Quando abriu os olhos, viu um ratinho passeando pela toca.
— Saia daqui, bicho feio, sujo, fraco, ridículo! — rugiu o leão. — Você é a coisa mais inútil que eu já vi!
O ratinho encolheu as orelhas e saiu correndo.', '/images/questoes/q7.svg', 'TESTE', 'INTERMEDIARIA', 20),
-- B1 q5 | Poema 'Desabar' (Carlos Drummond de Andrade, As impurezas do branco)  >> texto de apoio ORIGINAL (substitui o do simulado)
(8, 1, 'Ao utilizar o recurso de letras soltas no meio do poema, o texto pretende', 'Chegou a tempestade.
O vento levou o chapéu,
a janela, o varal.
Correr pra onde?

t
o
v
ã
r
o

Tudo girando, voando, caindo...
Depois, só o silêncio.', '/images/questoes/q8.svg', 'TESTE', 'AVANCADA', 10),
-- B1 q20 | Crítica 'A Mulher Rei' (CNN Brasil, Brian Lowry)  >> texto de apoio ORIGINAL (substitui o do simulado)
(9, 1, 'No trecho da crítica, o modalizador que reforça a certeza do autor é:', 'O filme “A Ilha dos Ventos” conta a história de uma menina que procura um tesouro escondido.
Embora a aventura seja cheia de mistério, a diversão está claramente em primeiro lugar: o diretor sabe o que o público quer ver.
O tema subjacente, sobre amizade e coragem, fica em segundo plano.
A emoção é aumentada por uma trilha sonora marcante.', '/images/questoes/q9.svg', 'TESTE', 'AVANCADA', 10),
-- B1 q14 | Trecho de 'Triste fim de Policarpo Quaresma' (Lima Barreto) - verbos 'rogou, instou, chorou'
(10, 1, 'Ao organizar os verbos destacados de tal maneira, o autor do texto teve a intenção de', 'O macaco ROGOU, INSTOU, CHOROU; mas a onça parecia inflexível. Simão então lembrou que a demanda fosse resolvida pelo juiz de direito. Foram a ele, o macaco sempre agarrado pela onça. É juiz de direito, entre os animais, o jabuti, cujas audiências são dadas à borda dos rios, colocando-se ele em cima de uma pedra.', '/images/questoes/q10.svg', 'TESTE', 'AVANCADA', 10);

-- =====================================================
-- Opções de Questões (Gabarito e Alternativas)
-- =====================================================

INSERT IGNORE INTO `opcoes_questoes`
(`id`, `questao_id`, `letra`, `texto`, `correta`)
VALUES
-- Questão 1 (INICIANTE) - gabarito: B
(1, 1, 'A', 'de uma mulher.', 0),
(2, 1, 'B', 'de uma estação.', 1),
(3, 1, 'C', 'da rodoviária.', 0),
(4, 1, 'D', 'da passagem.', 0),

-- Questão 2 (INICIANTE) - gabarito: C
(5, 2, 'A', '“A primeira vez que o Dia da Terra foi celebrado foi em 1970.”', 0),
(6, 2, 'B', '“Vinte milhões de pessoas [...] foram às ruas protestar”', 0),
(7, 2, 'C', '“agora é hora de demonstrarmos solidariedade”', 1),
(8, 2, 'D', '“22 de abril é o Dia da Terra.”', 0),

-- Questão 3 (INICIANTE) - gabarito: B
(9, 3, 'A', 'foi a brisa.', 0),
(10, 3, 'B', 'foi a florzinha.', 1),
(11, 3, 'C', 'foram as pétalas.', 0),
(12, 3, 'D', 'foi o colibri.', 0),

-- Questão 4 (INTERMEDIARIA) - gabarito: B
(13, 4, 'A', 'fala de coisas do nosso cotidiano.', 0),
(14, 4, 'B', 'explora os diferentes significados das palavras.', 1),
(15, 4, 'C', 'traz informações velhas e redundantes.', 0),
(16, 4, 'D', 'relembra cenas de nossa infância.', 0),

-- Questão 5 (INTERMEDIARIA) - gabarito: C
(17, 5, 'A', 'alternância.', 0),
(18, 5, 'B', 'adição.', 0),
(19, 5, 'C', 'oposição.', 1),
(20, 5, 'D', 'explicação.', 0),

-- Questão 6 (INTERMEDIARIA) - gabarito: C
(21, 6, 'A', '“Eu vejo a minha sombra no chão, mas não consigo pegá-la!”', 0),
(22, 6, 'B', '“E quando não tem sol, onde ela fica?”', 0),
(23, 6, 'C', '“Ela só aparece porque o sol bate em você e a luz não consegue passar.”', 1),
(24, 6, 'D', '“Ela não fica em lugar nenhum, filho.”', 0),

-- Questão 7 (INTERMEDIARIA) - gabarito: C
(25, 7, 'A', 'demonstrar a consideração do leão pelo rato.', 0),
(26, 7, 'B', 'retratar todos os defeitos que o rato possui.', 0),
(27, 7, 'C', 'dar ênfase ao desprezo do leão pelo rato.', 1),
(28, 7, 'D', 'indicar que o leão conhece muitos adjetivos.', 0),

-- Questão 8 (AVANCADA) - gabarito: A
(29, 8, 'A', 'ressaltar o caos provocado pela situação descrita.', 1),
(30, 8, 'B', 'reforçar a ideia de que a fuga é inevitável.', 0),
(31, 8, 'C', 'indicar a sua desorientação diante do problema.', 0),
(32, 8, 'D', 'evidenciar a existência de dois momentos distintos no poema.', 0),

-- Questão 9 (AVANCADA) - gabarito: C
(33, 9, 'A', '“embora”.', 0),
(34, 9, 'B', '“aumentada”.', 0),
(35, 9, 'C', '“claramente”.', 1),
(36, 9, 'D', '“subjacente”.', 0),

-- Questão 10 (AVANCADA) - gabarito: D
(37, 10, 'A', 'criar uma repetição de ideia a fim de deixar o leitor confuso quanto às ações e aos sentimentos do macaco.', 0),
(38, 10, 'B', 'fazer uma oposição de ideias para mostrar ao leitor como o macaco estava confuso em relação aos seus atos.', 0),
(39, 10, 'C', 'reduzir os sentimentos do macaco para demonstrar ao leitor que a personagem já tinha desistido de se explicar perante a onça.', 0),
(40, 10, 'D', 'destacar a gradação de ideias relacionadas a esses verbos a fim de demonstrar as ações e os sentimentos do macaco perante a onça.', 1);

-- =====================================================
-- Avaliações diagnósticas
-- =====================================================

/*INSERT IGNORE INTO `avaliacao_diagnostica`
(`id`, `aluno_id`, `data_avaliacao`, `nota_final`, `nivel_classificado`)
VALUES
(1, 1, '2026-09-20 10:00:00', 6.50, 'INICIANTE'),
(2, 2, '2026-09-21 10:30:00', 8.50, 'INTERMEDIARIO');

-- =====================================================
-- Tentativas de atividades
-- =====================================================

INSERT IGNORE INTO `tentativas_atividades`
(`id`, `aluno_id`, `questao_id`, `opcao_selecionada_id`, `data_tentativa`, `acertou`, `pontos_obtidos`)
VALUES
(1, 1, 1, 2, '2026-09-22 14:00:00', 1, 30),
(2, 1, 2, 7, '2026-09-22 14:05:00', 1, 30),
(3, 1, 3, 9, '2026-09-22 14:10:00', 0, 0),
(4, 2, 1, 2, '2026-09-23 15:00:00', 1, 30),
(5, 2, 3, 10, '2026-09-23 15:05:00', 1, 30);*/


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

DELETE FROM `questoes_gamificadas` WHERE `id` > 10;

INSERT INTO `questoes_gamificadas`
(`id`, `questao_id`, `area_id`, `fase`, `ordem`, `tipo`, `enunciado`, `texto_apoio`,
 `conteudo_json`, `gabarito_json`, `explicacao`, `pontos`, `origem`)
VALUES
(1, NULL, 1, 1, 1, 'MULTIPLA_ESCOLHA', 'A tromba do elefante tem uma parte maior, na ponta, que é parecida com', 'A tromba do elefante serve para levar comida e água até a boca, cheirar e fazer carinho em outros elefantes. Como não tem ossos, ela é musculosa e muito flexível. Na ponta, tem uma parte maior, parecida com dedos, que ajuda o elefante a pegar a comida.', '{"opcoes":[{"id":"A","texto":"alimentos."},{"id":"B","texto":"ossos."},{"id":"C","texto":"dedos."},{"id":"D","texto":"objetos."}]}', '{"correta":"C"}', 'O texto diz que a parte maior, na ponta da tromba, é parecida com dedos e ajuda a pegar comida.', 10, '[INICIANTE] Livro 1 q6 (foto 03)'),
(2, NULL, 1, 2, 1, 'MULTIPLA_ESCOLHA', 'O que a expressão “vrruuum!” representa no texto?', 'Um caipira andava pela estrada quando um carro passou correndo: — vrruuum! — e sumiu na curva, levantando poeira. O caipira balançou a cabeça e continuou o seu caminho, sem pressa.', '{"opcoes":[{"id":"A","texto":"O som do carro."},{"id":"B","texto":"A voz do caipira."},{"id":"C","texto":"O som do cavalo."},{"id":"D","texto":"A voz do motorista."}]}', '{"correta":"A"}', '“Vrruuum” imita o barulho do carro em alta velocidade. Esse recurso, que escreve um som, chama-se onomatopeia.', 10, '[INICIANTE] Livro 1 q7 (fotos 03-04)'),
(3, NULL, 1, 3, 1, 'MULTIPLA_ESCOLHA', 'O pato foi tocar violão de feira em feira porque queria', 'Havia um pato
que sonhava com um sapato.
Como vivia nadando,
não tinha dinheiro nenhum.
Pegou o violão
e foi tocar de feira em feira.
Juntou moedinhas,
comprou o sapato
e saiu todo faceiro.', '{"opcoes":[{"id":"A","texto":"esquecer a lagoa."},{"id":"B","texto":"comprar um sapato."},{"id":"C","texto":"comprar um pé de pato."},{"id":"D","texto":"voltar à boa vida."}]}', '{"correta":"B"}', 'O poema diz que o pato sonhava com um sapato e juntou moedinhas tocando violão para comprá-lo.', 10, '[INICIANTE] Livro 1 q17 (foto 08)'),
(4, NULL, 1, 4, 1, 'MULTIPLA_ESCOLHA', 'O efeito de humor da tirinha está contido principalmente na', 'Tirinha em 4 quadrinhos.
1º — Calvin: “Pena que o mundo vai acabar em breve.” O tigre: “Como é que é?”
2º — Calvin: “O cometa Halley está chegando. Cometas são sinal do fim do mundo.”
3º — O tigre: “Não são, não. Isso é só superstição.” Calvin: “Sério??”
4º — Calvin: “Acho melhor eu fazer aquela redação pra escola.”', '{"opcoes":[{"id":"A","texto":"preocupação de Calvin com o fim do mundo, como mostra o primeiro quadrinho."},{"id":"B","texto":"reflexão de Calvin sobre o juízo final, como fica evidente no segundo quadrinho."},{"id":"C","texto":"decepção de Calvin porque o mundo não ia acabar e ele ia ter que fazer sua redação."},{"id":"D","texto":"alegria de Calvin quando descobre que o mundo não irá acabar, que é só superstição."}]}', '{"correta":"C"}', 'No último quadrinho, Calvin percebe que o mundo não vai acabar e que ainda terá de fazer a redação. A graça está nessa decepção.', 10, '[INTERMEDIÁRIA] Livro 1 q1 (foto 01)'),
(5, NULL, 1, 5, 1, 'MULTIPLA_ESCOLHA', 'A opinião do pediatra em relação ao sorvete é a de que', 'As pessoas já não acham que o sorvete é só uma guloseima: ele é considerado alimento porque é feito com leite, frutas, cacau, gordura e açúcar. Mas é bom não abusar, pois comer muito sorvete engorda. Também é bom escovar os dentes depois de tomar sorvete, o que ajuda a evitar cáries. O pediatra diz que não se deve misturar sorvete com gripe: o gelado atrapalha as defesas da garganta e do nariz, e quem já está doente demora mais para se recuperar.', '{"opcoes":[{"id":"A","texto":"ele é considerado alimento porque é feito com leite, frutas e cacau."},{"id":"B","texto":"escovar os dentes depois de tomar sorvete ajuda a evitar cáries."},{"id":"C","texto":"por ter gordura e açúcar, sorvete engorda e é bom não abusar."},{"id":"D","texto":"é desaconselhável misturar sorvete com gripe, por causa do gelado."}]}', '{"correta":"D"}', 'A opinião do médico aparece na parte em que ele diz que não se deve misturar sorvete com gripe, porque o gelado atrapalha as defesas do corpo.', 10, '[INTERMEDIÁRIA] Livro 1 q10 (foto 05)'),
(6, NULL, 1, 6, 1, 'MULTIPLA_ESCOLHA', 'O objetivo do texto é', 'Pesquisadores anunciaram a descoberta de uma nova espécie de mamífero: o olinguito. Ele vive nas florestas nubladas da Colômbia e do Equador, tem pelos de tom marrom-alaranjado e, apesar de pertencer à ordem dos carnívoros, alimenta-se principalmente de frutas. Segundo os cientistas, a descoberta mostra que o mundo ainda não foi completamente explorado.', '{"opcoes":[{"id":"A","texto":"apresentar as principais características da fauna sul-americana."},{"id":"B","texto":"refletir sobre o conhecimento limitado que o homem possui da natureza."},{"id":"C","texto":"informar o encontro de uma nova espécie e suas principais características."},{"id":"D","texto":"analisar como um animal pode reunir características atribuídas a outras espécies."}]}', '{"correta":"C"}', 'O texto noticia a descoberta de uma espécie nova e descreve onde ela vive, sua aparência e sua alimentação.', 10, '[INTERMEDIÁRIA] Livro 1 q19 (foto 10)'),
(7, NULL, 1, 7, 1, 'MULTIPLA_ESCOLHA', 'A ideia principal do texto é', 'Em 2006, os astrônomos decidiram que Plutão não é mais considerado um planeta. Criaram uma nova categoria, a dos “planetas-anões”, e passaram a classificar Plutão nela. Assim, o Sistema Solar tem oito planetas: Mercúrio, Vênus, Terra, Marte, Júpiter, Saturno, Urano e Netuno.', '{"opcoes":[{"id":"A","texto":"o descobrimento do planeta Plutão."},{"id":"B","texto":"o surgimento de um novo planeta."},{"id":"C","texto":"uma categorização dos satélites."},{"id":"D","texto":"uma nova classificação para Plutão."}]}', '{"correta":"D"}', 'O texto trata da mudança na classificação de Plutão, que deixou de ser planeta e passou a ser planeta-anão.', 10, '[INTERMEDIÁRIA] Livro 2 q7 (foto 15)'),
(8, NULL, 1, 8, 1, 'MULTIPLA_ESCOLHA', 'Relendo o trecho “Perdi o lugar onde morava e, curiosamente, todos os grandes amigos que gostavam de mim desapareceram junto com a fortuna”, pode-se concluir que aqueles que eram chamados de amigos, na verdade, eram', 'Meu pai era o mais rico mercador da cidade de Bagdá. Quando morreu, deixou-me uma grande riqueza. Eu era jovem e comecei a esbanjar: comia e bebia num desperdício e andava com homens perdulários, achando que aquela vida ia durar para sempre.
Durante algum tempo, vivi sem preocupações, mas logo minha riqueza se acabou. Perdi o lugar onde morava e, curiosamente, todos os grandes amigos que gostavam de mim desapareceram junto com a fortuna.
Perdulário: pessoa que gasta excessivamente, que esbanja.', '{"opcoes":[{"id":"A","texto":"pessoas interessadas apenas em sua fortuna, e não em sua amizade sincera."},{"id":"B","texto":"ladrões que roubaram tudo o que o pai lhe havia deixado quando morreu."},{"id":"C","texto":"negociantes que queriam comprar toda a sua fortuna e deixá-lo na miséria."},{"id":"D","texto":"seus empregados que, como não havia pagamento, não puderam ficar."}]}', '{"correta":"A"}', 'Os amigos sumiram junto com o dinheiro. Isso mostra que só estavam interessados na fortuna, não na amizade.', 10, '[AVANÇADA] Livro 1 q22 (foto 11)'),
(9, NULL, 1, 9, 1, 'MULTIPLA_ESCOLHA', 'Os dois textos abordam o problema da seca no Brasil, diferenciando-se pela', 'Texto I — O Brasil enfrenta a maior seca das últimas sete décadas, segundo um centro de monitoramento de desastres naturais. É a primeira vez que a estiagem afeta de forma intensa uma região tão ampla, da Amazônia ao Paraná, potencializando incêndios e levando os rios a níveis muito baixos. Os números mostram uma tendência de agravamento desde os anos 1990.
Texto II — A baixa umidade do ar pode provocar desconfortos à saúde, especialmente de crianças, idosos e pessoas com doenças crônicas: problemas alérgicos e respiratórios, ressecamento da pele, sangramento pelo nariz e irritação dos olhos. A OMS alerta que índices de umidade abaixo de 60% não são ideais para a saúde humana.', '{"opcoes":[{"id":"A","texto":"perspectiva de melhora do quadro exposto em um curto período."},{"id":"B","texto":"gravidade que atribuem ao momento de estiagem vivido pelo país."},{"id":"C","texto":"atenção dada aos efeitos desse fenômeno na saúde da população."},{"id":"D","texto":"utilização de fontes confiáveis em defesa dos argumentos expostos."}]}', '{"correta":"C"}', 'O texto I trata da extensão e da gravidade da seca; o texto II dá atenção aos efeitos da baixa umidade na saúde das pessoas.', 10, '[AVANÇADA] Livro 2 q22 (foto 24)'),
(10, NULL, 1, 10, 1, 'MULTIPLA_ESCOLHA', 'Sobre o uso de plásticos, os autores dos textos lidos', 'Texto I — Notícias recentes atribuem ao plástico o papel de vilão do meio ambiente. Imaginemos um mundo sem plástico: do que seriam feitos os equipamentos dos hospitais e laboratórios, os utensílios e eletrodomésticos de nossos lares? O plástico faz parte da nossa vida e sua abolição não parece viável no médio prazo.
Texto II — É inegável a importância dos plásticos em nossas vidas. No entanto, a utilização excessiva e principalmente o descarte inadequado transformam o plástico em vilão. Ele é altamente poluidor e vem se tornando um tormento para o meio ambiente: os mares e oceanos estão invadidos de material plástico.', '{"opcoes":[{"id":"A","texto":"têm a mesma opinião sobre o assunto, ou seja, que o plástico não deve ser visto como vilão ao meio ambiente."},{"id":"B","texto":"pensam igual sobre o uso do plástico, isto é, que o uso excessivo de plástico é o grande poluidor do meio ambiente."},{"id":"C","texto":"têm a mesma visão positiva sobre o plástico, mas o autor do texto I acredita que o material tem sua parcela de culpa na poluição do meio ambiente."},{"id":"D","texto":"possuem opiniões diferentes sobre o assunto: o texto I não vê o plástico como vilão ao meio ambiente, enquanto o texto II acredita que o material tem sim sua parcela de culpa."}]}', '{"correta":"D"}', 'O texto I defende que o plástico não deve ser visto como vilão; o texto II afirma que o uso excessivo e o descarte inadequado o tornam vilão. As opiniões são diferentes.', 10, '[AVANÇADA] Livro 2 q13 (foto 19)')
ON DUPLICATE KEY UPDATE
    `questao_id` = VALUES(`questao_id`), `area_id` = VALUES(`area_id`),
    `fase` = VALUES(`fase`), `ordem` = VALUES(`ordem`), `tipo` = VALUES(`tipo`),
    `enunciado` = VALUES(`enunciado`), `texto_apoio` = VALUES(`texto_apoio`),
    `conteudo_json` = VALUES(`conteudo_json`), `gabarito_json` = VALUES(`gabarito_json`),
    `explicacao` = VALUES(`explicacao`), `pontos` = VALUES(`pontos`), `origem` = VALUES(`origem`);

-- =====================================================
-- RESTAURAÇÃO DAS VARIÁVEIS DE SESSÃO
-- =====================================================

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

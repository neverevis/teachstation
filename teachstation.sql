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
-- nivel:         INICIANTE | INTERMEDIARIO | AVANCADO. Cada aluno joga o mapa do
--                seu nível (aluno.nivel_atual, definido pela avaliação diagnóstica).

CREATE TABLE IF NOT EXISTS `questoes_gamificadas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `questao_id` INT NULL DEFAULT NULL,
    `area_id` INT NOT NULL,
    `nivel` ENUM('INICIANTE', 'INTERMEDIARIO', 'AVANCADO') NOT NULL DEFAULT 'INTERMEDIARIO',
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
    UNIQUE INDEX `uk_questoes_gamificadas_nivel_fase_ordem` (`nivel` ASC, `fase` ASC, `ordem` ASC) VISIBLE,
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

-- Atualização de bancos criados antes da coluna `nivel` (o CREATE TABLE acima não
-- altera uma tabela que já existe). Cada passo só roda se for necessário, então o
-- script continua podendo ser reexecutado:
--   1. cria a coluna `nivel` (as questões existentes ficam como INTERMEDIARIO);
--   2. remove a chave única antiga (fase, ordem), que impediria ter a mesma fase
--      em mais de um nível;
--   3. cria a chave única nova (nivel, fase, ordem).

SET @ts_existe := (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'questoes_gamificadas' AND COLUMN_NAME = 'nivel');
SET @ts_sql := IF(@ts_existe = 0,
    'ALTER TABLE `questoes_gamificadas` ADD COLUMN `nivel` ENUM(''INICIANTE'', ''INTERMEDIARIO'', ''AVANCADO'') NOT NULL DEFAULT ''INTERMEDIARIO'' AFTER `area_id`',
    'DO 0');
PREPARE ts_stmt FROM @ts_sql;
EXECUTE ts_stmt;
DEALLOCATE PREPARE ts_stmt;

SET @ts_existe := (SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'questoes_gamificadas' AND INDEX_NAME = 'uk_questoes_gamificadas_fase_ordem');
SET @ts_sql := IF(@ts_existe > 0,
    'ALTER TABLE `questoes_gamificadas` DROP INDEX `uk_questoes_gamificadas_fase_ordem`',
    'DO 0');
PREPARE ts_stmt FROM @ts_sql;
EXECUTE ts_stmt;
DEALLOCATE PREPARE ts_stmt;

SET @ts_existe := (SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'questoes_gamificadas' AND INDEX_NAME = 'uk_questoes_gamificadas_nivel_fase_ordem');
SET @ts_sql := IF(@ts_existe = 0,
    'ALTER TABLE `questoes_gamificadas` ADD UNIQUE INDEX `uk_questoes_gamificadas_nivel_fase_ordem` (`nivel`, `fase`, `ordem`)',
    'DO 0');
PREPARE ts_stmt FROM @ts_sql;
EXECUTE ts_stmt;
DEALLOCATE PREPARE ts_stmt;


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
-- Questões gamificadas - Português: mapa de 10 fases, UMA questão por fase
-- =====================================================
-- Tipo de cada fase: 1 MC, 2 ASSOCIACAO, 3 PREENCHIMENTO, 4 MC, 5 ASSOCIACAO,
--                    6 PREENCHIMENTO, 7 MC, 8 ASSOCIACAO, 9 PREENCHIMENTO, 10 MC.
-- (MC = MULTIPLA_ESCOLHA. As fases 2, 3, 5, 6, 8 e 9 NÃO devem ser múltipla escolha:
--  são as de conectar frase e palavra e de completar frase com verbos.)
-- Total: 10 questões, nenhuma está na avaliação diagnóstica. As de múltipla escolha
-- (fases 1, 4, 7 e 10) vêm do banco de questões (Livro 1 e Livro 2); as de associação e
-- preenchimento são adaptadas dos simulados A1 e B1 (ver coluna `origem`).
--
-- Seguindo o padrão das questões diagnósticas, o enunciado e as alternativas são os do
-- banco e o texto de apoio é uma versão ADAPTADA, escrita para manter a habilidade avaliada.
-- O banco original não traz gabarito: as respostas foram definidas pela equipe a
-- partir dos próprios textos (precisam de conferência do professor).
-- Pontos: 10 por questão. Id = fase, ordem = 1.
-- O script pode ser reexecutado: remove as linhas com id acima de 30 (de versões
-- anteriores, com mais de uma questão por fase) e atualiza as de id 1 a 30.
-- Colunas: id, questao_id, area_id, fase, ordem, tipo, enunciado, texto_apoio,
--          conteudo_json, gabarito_json, explicacao, pontos, origem
--
-- NÍVEIS: as questões de id 1 a 10 (logo abaixo) são as INTERMEDIÁRIAS. As de id 11 a 20
-- (INICIANTE, Livro 1) e 21 a 30 (AVANCADO, Livro 2) estão no INSERT seguinte e seguem a
-- mesma ordem de tipos por fase.

DELETE FROM `questoes_gamificadas` WHERE `id` > 30;

INSERT INTO `questoes_gamificadas`
(`id`, `questao_id`, `area_id`, `fase`, `ordem`, `tipo`, `enunciado`, `texto_apoio`,
 `conteudo_json`, `gabarito_json`, `explicacao`, `pontos`, `origem`)
VALUES
(1, NULL, 1, 1, 1, 'MULTIPLA_ESCOLHA', 'A tromba do elefante tem uma parte maior, na ponta, que é parecida com', 'A tromba do elefante serve para levar comida e água até a boca, cheirar e fazer carinho em outros elefantes. Como não tem ossos, ela é musculosa e muito flexível. Na ponta, tem uma parte maior, parecida com dedos, que ajuda o elefante a pegar a comida.', '{"opcoes":[{"id":"A","texto":"alimentos."},{"id":"B","texto":"ossos."},{"id":"C","texto":"dedos."},{"id":"D","texto":"objetos."}]}', '{"correta":"C"}', 'O texto diz que a parte maior, na ponta da tromba, é parecida com dedos e ajuda a pegar comida.', 10, '[INICIANTE] Livro 1 q6 (foto 03)'),
(2, NULL, 1, 2, 1, 'ASSOCIACAO', 'Conecte cada frase à palavra que ela define.', NULL, '{"esquerda":[{"id":"a","texto":"Pessoa que gasta dinheiro em excesso, sem se preocupar com o futuro."},{"id":"b","texto":"Grupo de pessoas escolhido para representar outras e agir em nome delas."},{"id":"c","texto":"Palavra muito grande e difícil de pronunciar, como “paralelepípedo”."},{"id":"d","texto":"Que chega sempre na hora certa, sem atrasos."}],"direita":[{"id":"1","texto":"palavrão"},{"id":"2","texto":"pontual"},{"id":"3","texto":"delegação"},{"id":"4","texto":"perdulário"}]}', '{"a":"4","b":"3","c":"1","d":"2"}', 'Perdulário e delegação vêm dos glossários das avaliações. Em “palavrão”, o sufixo -ão indica tamanho grande (palavra grande). Pontual descreve quem não se atrasa.', 10, 'Simulados A1 q22 e q13 (glossários), A1 q2 e B1 q15 (palavrão) - vocabulário'),
(3, NULL, 1, 3, 1, 'PREENCHIMENTO', 'Complete a frase da receita com o verbo no tempo correto.', 'Arroz doce - modo de preparo
1. Coloque o arroz para cozinhar com quatro medidas de água.
2. Complete a frase do próximo passo, logo abaixo.
3. Desligue o fogo e acrescente o leite condensado e o creme de leite.', '{"frase":"Quando o arroz {1} bem molinho, acrescente o leite de coco e deixe ferver por mais dois minutos.","opcoes":[{"id":"o1","texto":"estava"},{"id":"o2","texto":"estiver"},{"id":"o3","texto":"estará"},{"id":"o4","texto":"estaria"}]}', '{"1":"o2"}', 'Em instruções que indicam uma condição futura, usa-se o futuro do subjuntivo depois de “quando”: “quando o arroz estiver bem molinho”.', 10, 'Simulado A1 q14 (Livro 1) - receita de arroz doce'),
(4, NULL, 1, 4, 1, 'MULTIPLA_ESCOLHA', 'O efeito de humor da tirinha está contido principalmente na', 'Tirinha em 4 quadrinhos.
1º — Calvin: “Pena que o mundo vai acabar em breve.” O tigre: “Como é que é?”
2º — Calvin: “O cometa Halley está chegando. Cometas são sinal do fim do mundo.”
3º — O tigre: “Não são, não. Isso é só superstição.” Calvin: “Sério??”
4º — Calvin: “Acho melhor eu fazer aquela redação pra escola.”', '{"opcoes":[{"id":"A","texto":"preocupação de Calvin com o fim do mundo, como mostra o primeiro quadrinho."},{"id":"B","texto":"reflexão de Calvin sobre o juízo final, como fica evidente no segundo quadrinho."},{"id":"C","texto":"decepção de Calvin porque o mundo não ia acabar e ele ia ter que fazer sua redação."},{"id":"D","texto":"alegria de Calvin quando descobre que o mundo não irá acabar, que é só superstição."}]}', '{"correta":"C"}', 'No último quadrinho, Calvin percebe que o mundo não vai acabar e que ainda terá de fazer a redação. A graça está nessa decepção.', 10, '[INTERMEDIÁRIA] Livro 1 q1 (foto 01)'),
(5, NULL, 1, 5, 1, 'ASSOCIACAO', 'Conecte cada frase ao gênero textual que ela descreve.', NULL, '{"esquerda":[{"id":"a","texto":"Texto que traz ingredientes e modo de preparo para ensinar a fazer um prato."},{"id":"b","texto":"Texto que usa imagens e frases curtas para convencer o público a participar de uma campanha."},{"id":"c","texto":"Texto escrito em versos, que costuma brincar com os sons e com as emoções."},{"id":"d","texto":"Texto que informa os leitores sobre um fato recente."}],"direita":[{"id":"1","texto":"poema"},{"id":"2","texto":"notícia"},{"id":"3","texto":"receita"},{"id":"4","texto":"cartaz"}]}', '{"a":"3","b":"4","c":"1","d":"2"}', 'Cada gênero tem uma função: a receita instrui, o cartaz convence, o poema trabalha com versos e emoções, e a notícia informa sobre fatos.', 10, 'Simulados A1 q11, q14, q17, q18 e B1 q18 - gêneros textuais'),
(6, NULL, 1, 6, 1, 'PREENCHIMENTO', 'Complete a frase com os verbos nos tempos corretos.', NULL, '{"frase":"Na semana passada, o pediatra {1} que não se deve misturar sorvete com gripe. A partir de amanhã, as crianças {2} sorvete só depois de ficarem boas.","opcoes":[{"id":"o1","texto":"explicará"},{"id":"o2","texto":"tomarão"},{"id":"o3","texto":"explicou"},{"id":"o4","texto":"tomaram"}]}', '{"1":"o3","2":"o2"}', '“Na semana passada” pede o passado (explicou). “A partir de amanhã” pede o futuro (tomarão). Os verbos também precisam concordar: o pediatra explicou; as crianças tomarão.', 10, 'Simulado A1 q10 e B1 q17 (Livro 1 e 2) - tema do sorvete, frase nova'),
(7, NULL, 1, 7, 1, 'MULTIPLA_ESCOLHA', 'A ideia principal do texto é', 'Em 2006, os astrônomos decidiram que Plutão não é mais considerado um planeta. Criaram uma nova categoria, a dos “planetas-anões”, e passaram a classificar Plutão nela. Assim, o Sistema Solar tem oito planetas: Mercúrio, Vênus, Terra, Marte, Júpiter, Saturno, Urano e Netuno.', '{"opcoes":[{"id":"A","texto":"o descobrimento do planeta Plutão."},{"id":"B","texto":"o surgimento de um novo planeta."},{"id":"C","texto":"uma categorização dos satélites."},{"id":"D","texto":"uma nova classificação para Plutão."}]}', '{"correta":"D"}', 'O texto trata da mudança na classificação de Plutão, que deixou de ser planeta e passou a ser planeta-anão.', 10, '[INTERMEDIÁRIA] Livro 2 q7 (foto 15)'),
(8, NULL, 1, 8, 1, 'ASSOCIACAO', 'Conecte cada descrição ao personagem do folclore brasileiro.', 'Todos os anos, criaturas fantásticas do folclore brasileiro se reúnem na floresta, à beira de um rio, para ver quantas histórias contam sobre a sua fama.', '{"esquerda":[{"id":"a","texto":"Menino travesso de uma perna só, que usa gorro vermelho."},{"id":"b","texto":"Homem que, nas noites de lua cheia, vira um animal parecido com um lobo."},{"id":"c","texto":"Menino da lenda gaúcha que ajuda a encontrar objetos perdidos."}],"direita":[{"id":"1","texto":"Negrinho do Pastoreiro"},{"id":"2","texto":"Saci-Pererê"},{"id":"3","texto":"Lobisomem"}]}', '{"a":"2","b":"3","c":"1"}', 'Saci-Pererê, Lobisomem e Negrinho do Pastoreiro são personagens do folclore brasileiro, citados no texto-base da avaliação.', 10, 'Simulado A1 q5 (Livro 1) - folclore brasileiro'),
(9, NULL, 1, 9, 1, 'PREENCHIMENTO', 'Complete a frase com os verbos nos tempos corretos.', NULL, '{"frase":"Quando o pai de Simbad {1}, deixou-lhe uma grande riqueza. Naquela época, Simbad {2} dinheiro sem pensar no futuro.","opcoes":[{"id":"o1","texto":"morrerá"},{"id":"o2","texto":"gastava"},{"id":"o3","texto":"morreu"},{"id":"o4","texto":"gastará"}]}', '{"1":"o3","2":"o2"}', '“Deixou-lhe” indica que o pai já tinha morrido: morreu. “Naquela época” indica um hábito do passado: gastava.', 10, 'Simulado A1 q22 (Livro 1) - história de Simbad, frase nova'),
(10, NULL, 1, 10, 1, 'MULTIPLA_ESCOLHA', 'Sobre o uso de plásticos, os autores dos textos lidos', 'Texto I — Notícias recentes atribuem ao plástico o papel de vilão do meio ambiente. Imaginemos um mundo sem plástico: do que seriam feitos os equipamentos dos hospitais e laboratórios, os utensílios e eletrodomésticos de nossos lares? O plástico faz parte da nossa vida e sua abolição não parece viável no médio prazo.
Texto II — É inegável a importância dos plásticos em nossas vidas. No entanto, a utilização excessiva e principalmente o descarte inadequado transformam o plástico em vilão. Ele é altamente poluidor e vem se tornando um tormento para o meio ambiente: os mares e oceanos estão invadidos de material plástico.', '{"opcoes":[{"id":"A","texto":"têm a mesma opinião sobre o assunto, ou seja, que o plástico não deve ser visto como vilão ao meio ambiente."},{"id":"B","texto":"pensam igual sobre o uso do plástico, isto é, que o uso excessivo de plástico é o grande poluidor do meio ambiente."},{"id":"C","texto":"têm a mesma visão positiva sobre o plástico, mas o autor do texto I acredita que o material tem sua parcela de culpa na poluição do meio ambiente."},{"id":"D","texto":"possuem opiniões diferentes sobre o assunto: o texto I não vê o plástico como vilão ao meio ambiente, enquanto o texto II acredita que o material tem sim sua parcela de culpa."}]}', '{"correta":"D"}', 'O texto I defende que o plástico não deve ser visto como vilão; o texto II afirma que o uso excessivo e o descarte inadequado o tornam vilão. As opiniões são diferentes.', 10, '[AVANÇADA] Livro 2 q13 (foto 19)')
ON DUPLICATE KEY UPDATE
    `questao_id` = VALUES(`questao_id`), `area_id` = VALUES(`area_id`),
    `fase` = VALUES(`fase`), `ordem` = VALUES(`ordem`), `tipo` = VALUES(`tipo`),
    `enunciado` = VALUES(`enunciado`), `texto_apoio` = VALUES(`texto_apoio`),
    `conteudo_json` = VALUES(`conteudo_json`), `gabarito_json` = VALUES(`gabarito_json`),
    `explicacao` = VALUES(`explicacao`), `pontos` = VALUES(`pontos`), `origem` = VALUES(`origem`);

-- As 10 questões acima são as do nível INTERMEDIÁRIO (garante o nível mesmo em bancos antigos).
UPDATE `questoes_gamificadas` SET `nivel` = 'INTERMEDIARIO' WHERE `id` BETWEEN 1 AND 10;


-- =====================================================
-- Questões gamificadas - níveis INICIANTE (id 11 a 20) e AVANCADO (id 21 a 30)
-- =====================================================
-- Mesma ordem de tipos do nível intermediário (1, 4, 7, 10 MC; 2, 5, 8 ASSOCIACAO;
-- 3, 6, 9 PREENCHIMENTO). Iniciante vem do Livro 1 e Avançado do Livro 2 do banco de
-- questões, sem repetir as questões nem os textos já usados no nível intermediário.
-- As de múltipla escolha mantêm texto e alternativas da prova. Nas de preenchimento,
-- o próprio texto da prova é a frase, com lacunas no lugar dos verbos (sem texto de
-- apoio separado, para não entregar a resposta). Gabarito do Livro 2: oficial (resolução
-- comentada). Livro 1: definido pela equipe (precisa de conferência do professor).
-- Id = fase + 10 (iniciante) ou fase + 20 (avançado), ordem = 1. Pontos: 10 por questão.

INSERT INTO `questoes_gamificadas`
(`id`, `questao_id`, `area_id`, `nivel`, `fase`, `ordem`, `tipo`, `enunciado`, `texto_apoio`,
 `conteudo_json`, `gabarito_json`, `explicacao`, `pontos`, `origem`)
VALUES
(11, NULL, 1, 'INICIANTE', 1, 1, 'MULTIPLA_ESCOLHA', 'O que a expressão “vrruuum!” representa no texto?', 'Texto do caipira
O caipira andava ao longo da estrada seguido de dez cavalos. Nisso, veio um automóvel e o motorista gritou para o caipira:
– Você tem dez. Mas eu tenho duzentos e cinquenta cavalos! – E – vrruuum! – saiu em disparada!
O caipira continuou seu passo. E lá na frente estava o carro virado dentro do rio, ao lado da ponte.
Aí, o caipira falou pro motorista:
– Oi, cumpadre! Dando água pra tropa, é?', '{"opcoes":[{"id":"A","texto":"O som do carro."},{"id":"B","texto":"A voz do caipira."},{"id":"C","texto":"O som do cavalo."},{"id":"D","texto":"A voz do motorista."}]}', '{"correta":"A"}', '“Vrruuum!” imita o barulho do motor do automóvel quando o motorista sai em disparada. Palavras que imitam sons são chamadas de onomatopeias.', 10, '[INICIANTE] Livro 1 q7 (fotos 03-04)'),
(12, NULL, 1, 'INICIANTE', 2, 1, 'ASSOCIACAO', 'Conecte cada sinal de pontuação ao que ele mostra no texto.', 'A espada
O pai ajuda o filho a guardar os presentes que ganhou dos amigos. Nota que o filho está quieto e sério, mas pensa: “É o cansaço.” Afinal ele passou o dia correndo de um lado para o outro, comendo cachorro-quente e sorvete, brincando com os convidados por dentro e por fora da casa. Tem que estar cansado.
– Quanto presente, hein, filho?
– É.
– E esta espada. Mas que beleza. Esta eu não tinha visto.
– Pai...
– E como pesa! Parece uma espada de verdade. É de metal mesmo. Quem foi que deu?
– Era sobre isso que eu queria falar com você.', '{"esquerda":[{"id":"a","texto":"O ponto de exclamação, em “E como pesa!”"},{"id":"b","texto":"O ponto de interrogação, em “Quem foi que deu?”"},{"id":"c","texto":"As reticências, em “– Pai...”"},{"id":"d","texto":"O travessão (–), no começo de cada fala"}],"direita":[{"id":"1","texto":"indica a fala de cada personagem"},{"id":"2","texto":"mostra a surpresa do pai"},{"id":"3","texto":"faz uma pergunta"},{"id":"4","texto":"mostra hesitação, a frase fica no ar"}]}', '{"a":"2","b":"3","c":"4","d":"1"}', 'O ponto de exclamação em “E como pesa!” mostra a surpresa do pai ao perceber o peso da espada. O ponto de interrogação marca a pergunta, as reticências mostram a hesitação do filho e o travessão indica a fala de cada personagem.', 10, '[INICIANTE] Livro 1 q8 (foto 04) - adaptada para associação'),
(13, NULL, 1, 'INICIANTE', 3, 1, 'PREENCHIMENTO', 'Complete o texto com os verbos corretos.', NULL, '{"frase":"Depois do jantar, o príncipe {1} Narizinho à casa da melhor costureira do reino. Era uma aranha de Paris, que sabia fazer vestidos lindos, lindos até não poder mais! – Dona Aranha – disse o príncipe – quero que faça para esta ilustre dama o vestido mais bonito do mundo. Vou {2} uma grande festa em sua honra e quero vê-la deslumbrar a corte.","opcoes":[{"id":"o1","texto":"levar"},{"id":"o2","texto":"deu"},{"id":"o3","texto":"levou"},{"id":"o4","texto":"dar"}]}', '{"1":"o3","2":"o4"}', 'O texto conta fatos que já aconteceram: “Depois do jantar, o príncipe levou Narizinho”. Depois de “vou”, o verbo fica no infinitivo: “Vou dar uma grande festa”. É por causa dessa festa que o príncipe quer o vestido mais bonito do mundo para Narizinho.', 10, '[INICIANTE] Livro 1 q4 (foto 02) - adaptada para preenchimento'),
(14, NULL, 1, 'INICIANTE', 4, 1, 'MULTIPLA_ESCOLHA', 'O tema dos versos desse poema é', 'Um substantivo invisível que existe de verdade
Não aparece para ninguém ver, o seu nome é saudade
Só não acredita nela quem não a sentiu
Muitas dores tem causado, muitos peitos ela feriu.
[...]', '{"opcoes":[{"id":"A","texto":"os substantivos abstratos."},{"id":"B","texto":"o sentimento de saudade."},{"id":"C","texto":"as doenças que atingem o coração."},{"id":"D","texto":"os machucados no corpo ao longo da vida."}]}', '{"correta":"B"}', 'O poema apresenta a saudade como um “substantivo invisível”: ninguém a vê, mas quem a sentiu sabe o quanto ela pode doer.', 10, '[INICIANTE] Livro 1 q16 (foto 08)'),
(15, NULL, 1, 'INICIANTE', 5, 1, 'ASSOCIACAO', 'Conecte cada ação a quem a pratica ou a quem ela se refere no trecho.', 'A brisa leve, que passava pelo campo, agitou as pétalas da florzinha. Por um instante, ela pensou que ia voar como o delicado colibri. Quis seguir com a brisa, mas sua haste estava presa ao solo.', '{"esquerda":[{"id":"a","texto":"Passava pelo campo e agitou as pétalas."},{"id":"b","texto":"Quis seguir com a brisa, mas estava presa ao solo."},{"id":"c","texto":"Foram agitadas pela brisa."},{"id":"d","texto":"É delicado e sabe voar."}],"direita":[{"id":"1","texto":"o colibri"},{"id":"2","texto":"a brisa"},{"id":"3","texto":"as pétalas"},{"id":"4","texto":"a florzinha"}]}', '{"a":"2","b":"4","c":"3","d":"1"}', 'Quem “quis seguir com a brisa” foi a florzinha, a única que estava presa ao solo pela haste. A brisa é quem passava pelo campo, as pétalas foram agitadas e o colibri é o delicado animal que voa.', 10, '[INICIANTE] Livro 1 q20 (foto 10; = Livro 2 q9) - adaptada para associação'),
(16, NULL, 1, 'INICIANTE', 6, 1, 'PREENCHIMENTO', 'Complete o texto com os verbos corretos.', NULL, '{"frase":"O matuto chegou na rodoviária e {1} para o moço do guichê: – Moço, me {2} uma passagem pra Florisbela. – Não tem estação com esse nome! – Mas tem minha filha!","opcoes":[{"id":"o1","texto":"falaram"},{"id":"o2","texto":"dá"},{"id":"o3","texto":"falou"},{"id":"o4","texto":"dão"}]}', '{"1":"o3","2":"o2"}', '“O matuto” é uma pessoa só, por isso o verbo fica no singular: “falou”. Ele pede a uma pessoa só, o moço: “me dá uma passagem”. A graça da anedota está no mal-entendido: o moço pensou que Florisbela fosse o nome de uma estação, mas é o nome da filha do matuto.', 10, '[INICIANTE] Livro 1 q9 (foto 04; = Livro 2 q16) - adaptada para preenchimento'),
(17, NULL, 1, 'INICIANTE', 7, 1, 'MULTIPLA_ESCOLHA', 'Que sentido tem a expressão “— Esse é forte e dá sustança!”, usada por Dona Carmelita?', 'O saber da vovó
Na noite chuvosa, Dona Carmelita se preocupava com Maurinho: febre alta, diarreia, boca seca, suores frios. O médico estava longe daquele sertão e remédios não havia em casa.
O que fazer? — pensou Dona Carmelita.
Logo ela se lembrou de como sua avó fazia quando ela era criança. Preparava um remedinho fácil: água, açúcar, sal, limão e amido de milho misturadinhos, e oferecia-lhe em bons goles. E assim foi feito...
Amanheceu. Maurinho dormia tranquilo e Dona Carmelita preparava, no fogão a lenha, um bom mingau de fubá e dizia:
— Esse é forte e dá sustança!', '{"opcoes":[{"id":"A","texto":"Certeza do efeito do alimento para fortalecer seu filho."},{"id":"B","texto":"Dúvida de que o mingau recuperaria o menino."},{"id":"C","texto":"Incerteza do valor nutritivo do fubá."},{"id":"D","texto":"Satisfação em atender à vontade de Maurinho."}]}', '{"correta":"A"}', 'Dona Carmelita fala com confiança: o filho já dorme tranquilo e ela tem certeza de que o mingau de fubá, forte e nutritivo, vai fortalecê-lo.', 10, '[INICIANTE] Livro 1 q3 (foto 02)'),
(18, NULL, 1, 'INICIANTE', 8, 1, 'ASSOCIACAO', 'Conecte cada texto ao tipo de linguagem que ele usa.', NULL, '{"esquerda":[{"id":"a","texto":"“O gato é um animal mamífero e carnívoro, da família dos felídeos. Pesa, em média, 3 quilos e mede de 40 a 60 centímetros.”"},{"id":"b","texto":"“O elefante é o bicho de mais sorte que conheço. Já nasceu com um canudinho para tomar refresco. Ele não é caminhão, mas de vez em quando dá uma trombada.”"},{"id":"c","texto":"“Na asa do vento, voa meu cavalo azul. E as nuvens brancas, brancas, dançam de alegria, brincando com meu cavalinho.”"},{"id":"d","texto":"“Reformamos e fabricamos estofados finos sob medida. Aproveitem nossa grande promoção para o Dia das Mães. Parcelamos em até 5 vezes. Contato: 3486-8928.”"}],"direita":[{"id":"1","texto":"poética"},{"id":"2","texto":"científica"},{"id":"3","texto":"de propaganda"},{"id":"4","texto":"humorística"}]}', '{"a":"2","b":"4","c":"1","d":"3"}', 'A linguagem científica usa termos técnicos e dados exatos (“mamífero”, “felídeos”, “3 quilos”). A poética usa imagens e emoção, a de propaganda tenta vender (preço, promoção, contato) e a humorística brinca com as palavras (“dá uma trombada”).', 10, '[INICIANTE] Livro 1 q15 (foto 07) - adaptada para associação'),
(19, NULL, 1, 'INICIANTE', 9, 1, 'PREENCHIMENTO', 'Complete o texto com os verbos corretos.', NULL, '{"frase":"O jornal científico “Zookeys”, publicado nesta quinta-feira (15 de agosto de 2013), traz um artigo que demonstra a descoberta de uma nova espécie animal: o olinguito. Apesar de novos insetos e anfíbios serem descobertos com certa frequência, este {1} o primeiro mamífero carnívoro descoberto em 35 anos no Hemisfério Ocidental. Seus pelos {2} um tom marrom alaranjado e, apesar de ser de ordem carnívora, sua principal fonte de alimento são frutas.","opcoes":[{"id":"o1","texto":"são"},{"id":"o2","texto":"tem"},{"id":"o3","texto":"é"},{"id":"o4","texto":"têm"}]}', '{"1":"o3","2":"o4"}', '“Este” (o olinguito) é um só: “este é o primeiro mamífero carnívoro”. “Seus pelos” está no plural: “seus pelos têm”, com acento. O texto é uma notícia: informa a descoberta de uma nova espécie e suas características.', 10, '[INICIANTE] Livro 1 q19 (foto 10; = Livro 2 q8) - adaptada para preenchimento'),
(20, NULL, 1, 'INICIANTE', 10, 1, 'MULTIPLA_ESCOLHA', 'O trecho que mostra a opinião do autor do texto é:', 'O Dia da Terra é mais importante do que nunca
22 de abril é o Dia da Terra. [...]
A primeira vez que o Dia da Terra foi celebrado foi em 1970. Vinte milhões de pessoas, indignadas com o derramamento de óleo, a poluição atmosférica e dos rios, foram às ruas protestar contra o que reconheceram ser uma crise ambiental. Além desses resultados práticos, o evento demonstrou a força das pessoas quando se unem e demandam ações. [...]
Assim como no primeiro Dia da Terra, há 50 anos, agora é hora de demonstrarmos solidariedade, agindo e enviando uma mensagem clara para as lideranças mundiais pela ação contra a mudança climática, detendo a perda da biodiversidade e dos hábitats e garantindo que a proteção ambiental seja uma das bases para nos reconstruirmos melhor. [...]', '{"opcoes":[{"id":"A","texto":"“A primeira vez que o Dia da Terra foi celebrado foi em 1970.”"},{"id":"B","texto":"“Vinte milhões de pessoas [...] foram às ruas protestar”"},{"id":"C","texto":"“agora é hora de demonstrarmos solidariedade”"},{"id":"D","texto":"“22 de abril é o Dia da Terra.”"}]}', '{"correta":"C"}', 'A, B e D são fatos: uma data, um número de pessoas e um dia comemorativo. Só a C mostra o ponto de vista do autor, que diz o que, na opinião dele, devemos fazer agora.', 10, '[INICIANTE] Livro 1 q12 (foto 06; = Livro 2 q10)'),
(21, NULL, 1, 'AVANCADO', 1, 1, 'MULTIPLA_ESCOLHA', 'Em sua crônica, Monteiro Lobato faz uma crítica direta sobre um problema ecológico brasileiro, acusando', 'Preocupa à nossa gente civilizada conhecer em quanto fica na Europa por dia, em francos e cêntimos, um soldado em guerra; mas ninguém cuida de calcular os prejuízos de toda sorte advindos de uma assombrosa queima destas. As velhas camadas de humus destruídas; os sais preciosos que, breve, as enxurradas deitarão fora, rio abaixo, via oceano; o rejuvenescimento florestal do solo paralizado e retrogradado; a destruição das aves silvestres e o possível advento de pragas insetiformes; a alteração para piora do clima com a agravação crescente das secas; os vedos e aramados perdidos; o gado morto ou depreciado pela falta de pastos.', '{"opcoes":[{"id":"A","texto":"os desastres causados pelo contexto da guerra."},{"id":"B","texto":"a inoperância do poder público diante de desastres."},{"id":"C","texto":"o desconhecimento das riquezas naturais do país."},{"id":"D","texto":"o desinteresse com relação a problemas que assolam o país."}]}', '{"correta":"D"}', 'O texto contrapõe o interesse pelos custos das guerras europeias ao desinteresse pelo impacto das queimadas no próprio país, e lista toda a destruição que elas causam.', 10, '[AVANCADO] Livro 2 q23 (foto 25)'),
(22, NULL, 1, 'AVANCADO', 2, 1, 'ASSOCIACAO', 'O poema é engraçado porque brinca com os diferentes significados das palavras. Conecte cada palavra do poema ao outro sentido que ela tem no dia a dia.', 'Ninguém coça as costas da cadeira.
Ninguém chupa a manga da camisa.
O piano jamais abana a cauda.
Tem asa, porém não voa, a xícara.', '{"esquerda":[{"id":"a","texto":"costas, em “as costas da cadeira”"},{"id":"b","texto":"manga, em “a manga da camisa”"},{"id":"c","texto":"cauda, em “a cauda do piano”"},{"id":"d","texto":"asa, em “a asa da xícara”"}],"direita":[{"id":"1","texto":"parte do corpo de uma ave"},{"id":"2","texto":"uma fruta"},{"id":"3","texto":"parte do corpo humano"},{"id":"4","texto":"o rabo de um animal"}]}', '{"a":"3","b":"2","c":"4","d":"1"}', 'O humor vem do duplo sentido: “costas” (corpo e encosto), “manga” (fruta e parte da roupa), “cauda” (rabo e parte do piano) e “asa” (ave e alça da xícara). Os objetos ganham “partes” que, em outro sentido, pertencem a pessoas, frutas e animais.', 10, '[AVANCADO] Livro 2 q3 (foto 13) - adaptada para associação'),
(23, NULL, 1, 'AVANCADO', 3, 1, 'PREENCHIMENTO', 'Complete o texto com os verbos corretos.', NULL, '{"frase":"“Passamos mais de 15 anos {1} por água, luz e esgoto, {2} manifestações na prefeitura e esse ano o Ministério Público {3} a Sabesp. Não é que eles são bonzinhos, é que o Ministério Público reconhece que somos moradores há mais de 20 anos no mesmo local, sem saneamento básico”, diz Alessandra Moja Cunha, líder comunitária da favela.","opcoes":[{"id":"o1","texto":"lutamos"},{"id":"o2","texto":"notificou"},{"id":"o3","texto":"fizeram"},{"id":"o4","texto":"lutando"},{"id":"o5","texto":"notificaram"},{"id":"o6","texto":"fizemos"}]}', '{"1":"o4","2":"o6","3":"o2"}', 'Depois de “passamos mais de 15 anos”, usa-se o gerúndio: “lutando”. Quem fala é o grupo de moradores (nós), então “fizemos manifestações”. “O Ministério Público” é singular: “notificou”. O texto mostra que o poder público só agiu depois da pressão dos moradores, e não de forma espontânea.', 10, '[AVANCADO] Livro 2 q2 (fotos 12-13) - adaptada para preenchimento'),
(24, NULL, 1, 'AVANCADO', 4, 1, 'MULTIPLA_ESCOLHA', 'Ao organizar os verbos destacados (rogou, instou, chorou) de tal maneira, o autor do texto teve a intenção de', 'O macaco rogou, instou, chorou; mas a onça parecia inflexível. Simão então lembrou que a demanda fosse resolvida pelo juiz de direito. Foram a ele, o macaco sempre agarrado pela onça. É juiz de direito, entre os animais, o jabuti, cujas audiências são dadas à borda dos rios, colocando-se ele em cima de uma pedra.', '{"opcoes":[{"id":"A","texto":"criar uma repetição de ideia a fim de deixar o leitor confuso quanto às ações e aos sentimentos do macaco."},{"id":"B","texto":"fazer uma oposição de ideias para mostrar ao leitor como o macaco estava confuso em relação aos seus atos."},{"id":"C","texto":"reduzir os sentimentos do macaco para demonstrar ao leitor que a personagem já tinha desistido de se explicar perante a onça."},{"id":"D","texto":"destacar a gradação de ideias relacionadas a esses verbos a fim de demonstrar as ações e os sentimentos do macaco perante a onça."}]}', '{"correta":"D"}', 'Os verbos se intensificam: pedir com humildade, insistir e, por fim, chorar. Essa gradação mostra as ações e os sentimentos do macaco diante da onça.', 10, '[AVANCADO] Livro 2 q14 (foto 20)'),
(25, NULL, 1, 'AVANCADO', 5, 1, 'ASSOCIACAO', 'Conecte cada expressão da fala de João Grilo ao efeito que ela cria entre as ideias.', 'Trecho da peça “Auto da compadecida”, de Ariano Suassuna.
JOÃO GRILO: – E você deixe de conversa. Nunca vi homem mais mole do que você, Chicó. O padeiro mandou você arranjar o padre para benzer o cachorro e eu arranjei sem ter sido mandado. Que é que você quer mais?
CHICÓ: – Ih, olha como isso está pegado com o patrão! Faz gosto um empregado dessa qualidade.
JOÃO GRILO: – Muito pelo contrário, ainda hei de me vingar do que ele e a mulher me fizeram quando estive doente. Três dias passei em cima da cama para morrer e nem um copo dágua me mandara. Mas fiz esse trabalho com gosto, somente porque se trata de enganar o padre. Não vou com aquela cara.', '{"esquerda":[{"id":"a","texto":"“Muito pelo contrário” e “Mas”"},{"id":"b","texto":"“e”, em “[...] para morrer e nem um copo dágua me mandara”"},{"id":"c","texto":"“porque”, em “somente porque se trata de enganar o padre”"}],"direita":[{"id":"1","texto":"adição (soma ideias)"},{"id":"2","texto":"explicação (dá o motivo)"},{"id":"3","texto":"oposição (contrasta ideias)"}]}', '{"a":"3","b":"1","c":"2"}', '“Muito pelo contrário” e “Mas” contrastam ideias: João Grilo discorda de Chicó e depois afirma que fez o trabalho com gosto, apesar do que passou. O “e” soma uma ideia à outra, e o “porque” explica o motivo de ele ter feito o trabalho.', 10, '[AVANCADO] Livro 2 q4 (foto 13) - adaptada para associação'),
(26, NULL, 1, 'AVANCADO', 6, 1, 'PREENCHIMENTO', 'Complete o texto com os verbos corretos.', NULL, '{"frase":"– Assaltaremos a casa – prosseguiu o onço – e mataremos todos os seus moradores. A assembleia dissolveu-se, indo cada qual para sua toca sem que nenhuma daquelas feras {1} em caça naquele dia. Estavam a preparar uma fome especial para o almoço de carne humana que iam ter no dia seguinte. Os besouros espiões tudo {2} do seu galinho e lá se foram, a zumbir, dar parte à Emília dos grandes acontecimentos.","opcoes":[{"id":"o1","texto":"pensou"},{"id":"o2","texto":"ouviram"},{"id":"o3","texto":"pensasse"},{"id":"o4","texto":"ouviu"}]}', '{"1":"o3","2":"o2"}', 'Depois de “sem que”, o verbo vai para o subjuntivo: “sem que nenhuma daquelas feras pensasse em caça”. “Os besouros espiões” está no plural: “tudo ouviram”. Foram os besouros que espionaram a reunião das feras e avisaram a Emília.', 10, '[AVANCADO] Livro 2 q11 (foto 17) - adaptada para preenchimento'),
(27, NULL, 1, 'AVANCADO', 7, 1, 'MULTIPLA_ESCOLHA', 'Os dois textos abordam o problema da seca no Brasil, diferenciando-se pela', 'Texto I
O Brasil está enfrentando a maior seca das últimas sete décadas, segundo dados do Centro Nacional de Monitoramento de Desastres Naturais (Cemaden), ligado ao Ministério da Ciência e Tecnologia. É a primeira vez que a estiagem afeta de forma intensa uma região tão ampla do País, da Amazônia até o Paraná, potencializando incêndios e levando à baixa recorde dos rios. A situação ainda tende a se agravar até novembro. A série histórica da seca do Cemaden remonta a 1950. Os números dos últimos 74 anos revelam uma tendência de agravamento dos períodos de estiagem a partir do início dos anos 1990, quando esses eventos passaram a ser muito mais frequentes.
Texto II
A baixa umidade do ar pode provocar uma série de desconfortos à saúde, especialmente para crianças, idosos e pessoas com doenças crônicas. As complicações mais comuns incluem problemas alérgicos, respiratórios, ressecamento da pele e das mucosas, sangramento pelo nariz e irritação dos olhos. Na cidade de São Paulo e no interior do estado, a previsão é de que o tempo seco e o calor persistam durante esta semana. A temperatura pode chegar a 29 °C, com umidade relativa variando próximo a 30%, segundo o Inmet (Instituto Nacional de Meteorologia), o que aumenta os riscos à saúde [...]. A OMS (Organização Mundial da Saúde) alerta que índices de umidade relativa do ar abaixo de 60% não são ideais para a saúde humana.', '{"opcoes":[{"id":"A","texto":"perspectiva de melhora do quadro exposto em um curto período."},{"id":"B","texto":"gravidade que atribuem ao momento de estiagem vivido pelo país."},{"id":"C","texto":"atenção dada aos efeitos desse fenômeno na saúde da população."},{"id":"D","texto":"utilização de fontes confiáveis em defesa dos argumentos expostos."}]}', '{"correta":"C"}', 'Os dois textos tratam a estiagem com gravidade e citam fontes confiáveis (Cemaden, Inmet, OMS). A diferença está no foco: o Texto II dá atenção aos efeitos da baixa umidade na saúde da população.', 10, '[AVANCADO] Livro 2 q22 (foto 24)'),
(28, NULL, 1, 'AVANCADO', 8, 1, 'ASSOCIACAO', 'Conecte cada explicação à palavra do trecho da crítica.', 'Embora “inspirado em fatos reais”, o filme “A Mulher Rei” claramente não está amarrado a eles, usando a história subjacente de guerreiras do século 19 em um reino africano como o ponto de partida para uma ação empolgante, aumentada em vários níveis com muito melodrama.', '{"esquerda":[{"id":"a","texto":"Reforça a certeza do autor sobre o que ele afirma."},{"id":"b","texto":"Introduz um fato contrário ao que é dito depois (concessão)."},{"id":"c","texto":"Adjetivo que mostra a opinião do autor sobre a ação do filme."},{"id":"d","texto":"Adjetivo que descreve a história que está “por baixo” do filme, sem expressar opinião."}],"direita":[{"id":"1","texto":"embora"},{"id":"2","texto":"aumentada"},{"id":"3","texto":"claramente"},{"id":"4","texto":"subjacente"}]}', '{"a":"3","b":"1","c":"2","d":"4"}', '“Claramente” é um modalizador que reforça a certeza do autor. “Embora” é uma conjunção concessiva e “aumentada” expressa a opinião do autor, sem reforçar a certeza dele. “Subjacente” apenas descreve a história de base do filme.', 10, '[AVANCADO] Livro 2 q20 (foto 23) - adaptada para associação'),
(29, NULL, 1, 'AVANCADO', 9, 1, 'PREENCHIMENTO', 'Complete o texto com os verbos corretos.', NULL, '{"frase":"O problema de mobilidade urbana é crônico e não se {1} até o momento porque todos querem iniciar seus planos do zero. Querem implantar os seus modelos e não {2} sequência aos projetos que se iniciaram na gestão anterior. E não existe solução de quatro ou oito anos para um problema que {3} aí desde pelo menos 1911.","opcoes":[{"id":"o1","texto":"resolveram"},{"id":"o2","texto":"está"},{"id":"o3","texto":"dá"},{"id":"o4","texto":"resolveu"},{"id":"o5","texto":"estão"},{"id":"o6","texto":"dão"}]}', '{"1":"o4","2":"o6","3":"o2"}', '“O problema” é singular: “não se resolveu”. Quem não dá sequência aos projetos são “todos”, no plural: “não dão sequência”. “Um problema que está aí desde 1911” volta ao singular. Para o autor, a mobilidade urbana exige continuidade e constância nos projetos, e não planos que sempre recomeçam do zero.', 10, '[AVANCADO] Livro 2 q21 (foto 23) - adaptada para preenchimento'),
(30, NULL, 1, 'AVANCADO', 10, 1, 'MULTIPLA_ESCOLHA', 'No final do texto, o autor faz uso de duas possibilidades de construção de um mesmo enunciado, de acordo com a norma culta, a fim de ilustrar a opinião de que', 'Como se pode ver, é preferência individual usar ou não a vírgula antes do etc. e não uma questão de contrariedade à norma culta. Como não há definição por parte dos doutos da língua, que são meros compiladores do uso que aqueles que bem empregam a língua fazem dela, fica a critério do usuário a sua opção.
O que não é normal é alguém achar que só uma forma tem de ser a correta e tentar cercear o uso que outros fazem da segunda possibilidade. A ninguém é dado esse direito, pois ninguém pode se julgar o dono da língua, que é necessariamente uma entidade coletiva.
Em outras palavras, sempre que houver duas possibilidades de uso, que é o que ocorre em frases como “A maioria dos usuários da língua prefere essa segunda forma” ou “A maioria dos usuários da língua preferem essa segunda forma”, cabe ao autor do texto fazer sua opção e não “autoridade da verdade absoluta”.', '{"opcoes":[{"id":"A","texto":"a forma correta depende das circunstâncias em que a língua é usada."},{"id":"B","texto":"as preferências individuais são uma questão de observação à norma."},{"id":"C","texto":"o direito de cercear o uso da língua, por parte dos doutos, é indevido."},{"id":"D","texto":"o usuário escolhe a opção que melhor lhe convém para se comunicar."}]}', '{"correta":"D"}', 'Com “a maioria … prefere” e “a maioria … preferem”, o autor mostra um caso em que as duas construções são aceitas. Nesse caso, o usuário escolhe a opção que melhor lhe convém para se comunicar.', 10, '[AVANCADO] Livro 2 q1 (foto 12)')
ON DUPLICATE KEY UPDATE
    `questao_id` = VALUES(`questao_id`), `area_id` = VALUES(`area_id`), `nivel` = VALUES(`nivel`),
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

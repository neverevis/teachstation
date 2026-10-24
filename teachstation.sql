-- TeachStation - Banco de Dados

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

USE `teachstation`;

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
(1, '20260001', '(16) 99999-1111', 'INICIANTE'),
(2, '20260002', '(16) 99999-2222', 'INTERMEDIARIO'),
(3, '20260003', '(16) 99999-3333', NULL),
(4, '20260004', '(16) 99999-4444', NULL);

-- =====================================================
-- Professores
-- =====================================================

INSERT IGNORE INTO `professor`
(`id`, `prontuario`, `telefone`, `area_atuacao`)
VALUES
(3, 'P000123', '(16) 99999-3333', 'Língua Portuguesa'),
(5, 'P000124', '(16) 99999-5555', 'Língua Portuguesa');

-- =====================================================
-- Secretaria
-- =====================================================

INSERT IGNORE INTO `secretaria`
(`id`, `codigo_funcionario`)
VALUES
(4, 'SEC001'),
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

INSERT IGNORE INTO `avaliacao_diagnostica`
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
(5, 2, 3, 10, '2026-09-23 15:05:00', 1, 30);


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- TeachStation - Banco de Dados

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

CREATE TABLE IF NOT EXISTS `questoes` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `area_id` INT NOT NULL,
    `enunciado` TEXT NOT NULL,
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

INSERT IGNORE INTO `usuario`
(`id`, `nome_completo`, `nome_social`, `email`, `senha`, `data_nascimento`, `genero`, `tipo_usuario`)
VALUES
(1, 'Maria Silva', NULL, 'maria@gmail.com', '123456', '2008-05-15', 'Feminino', 'ALUNO'),
(2, 'João Santos', NULL, 'joao@gmail.com', '123456', '2009-08-20', 'Masculino', 'ALUNO'),
(3, 'Roberta', NULL, 'roberta@gmail.com', '123456', '2009-08-20', 'Feminino', 'ALUNO'),
(4, 'Joana', NULL, 'joana@gmail.com', '123456', '2009-08-20', 'Feminino', 'ALUNO'),
(5, 'Ana Oliveira', 'Ana', 'ana@gmail.com', '123456', '1985-03-10', 'Feminino', 'PROFESSOR'),
(6, 'Secretaria', NULL, 'admin@gmail.com', '123', '1980-11-25', 'Feminino', 'SECRETARIA');

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
-- Questões
-- =====================================================

INSERT IGNORE INTO `questoes`
(`id`, `area_id`, `enunciado`, `tipo`, `dificuldade`, `pontos`)
VALUES
(1, 1, 'Qual palavra está escrita corretamente?', 'TESTE', 'INICIANTE', 30),
(2, 1, 'Identifique o sujeito da frase: "Maria estudou para a prova de Português."', 'TESTE', 'INICIANTE', 30),
(3, 1, 'Qual das opções apresenta um substantivo próprio?', 'TESTE', 'INICIANTE', 10),
(4, 1, 'Assinale a alternativa em que todas as palavras são oxítonas:', 'TESTE', 'INTERMEDIARIA', 15),
(5, 1, 'Qual é o plural correto da palavra "cidadão"?', 'TESTE', 'INTERMEDIARIA', 15),
(6, 1, 'Qual frase apresenta concordância verbal CORRETA?', 'TESTE', 'INTERMEDIARIA', 15),
(7, 1, 'Assinale a alternativa em que a crase foi usada CORRETAMENTE:', 'TESTE', 'AVANCADA', 20),
(8, 1, 'Identifique a figura de linguagem na frase: "O sol sorriu para nós naquela manhã."', 'TESTE', 'AVANCADA', 20),
(9, 1, 'Qual das frases abaixo está no tempo verbal Pretérito Perfeito do Indicativo?', 'TESTE', 'AVANCADA', 20),
(10, 1, 'Qual é o sinônimo da palavra "efêmero"?', 'TESTE', 'AVANCADA', 20);

-- =====================================================
-- Opções de Questões (Gabarito e Alternativas)
-- =====================================================

INSERT IGNORE INTO `opcoes_questoes`
(`id`, `questao_id`, `letra`, `texto`, `correta`)
VALUES
-- Questão 1
(1, 1, 'A', 'Exceção', 1),
(2, 1, 'B', 'Esceção', 0),
(3, 1, 'C', 'Exseção', 0),
(4, 1, 'D', 'Eceção', 0),

-- Questão 2
(5, 2, 'A', 'prova', 0),
(6, 2, 'B', 'Maria', 1),
(7, 2, 'C', 'Português', 0),
(8, 2, 'D', 'estudou', 0),

-- Questão 3
(9, 3, 'A', 'casa', 0),
(10, 3, 'B', 'Brasil', 1),
(11, 3, 'C', 'caneta', 0),
(12, 3, 'D', 'amor', 0),

-- Questão 4
(13, 4, 'A', 'Café, cipó, caju', 1),
(14, 4, 'B', 'Mesa, lápis, régua', 0),
(15, 4, 'C', 'Lâmpada, médico, ônibus', 0),
(16, 4, 'D', 'Árvore, fácil, livro', 0),

-- Questão 5
(17, 5, 'A', 'Cidadões', 0),
(18, 5, 'B', 'Cidadãos', 1),
(19, 5, 'C', 'Cidadõeses', 0),
(20, 5, 'D', 'Cidadans', 0),

-- Questão 6
(21, 6, 'A', 'Fazem dois anos que não o vejo.', 0),
(22, 6, 'B', 'Houveram muitos problemas na reunião.', 0),
(23, 6, 'C', 'A maioria dos alunos aprovou a ideia.', 1),
(24, 6, 'D', 'Sobrou muitas vagas para o curso.', 0),

-- Questão 7
(25, 7, 'A', 'Vou á praia no final de semana.', 0),
(26, 7, 'B', 'Fui à escola ontem de manhã.', 1),
(27, 7, 'C', 'Ele começou à falar sem parar.', 0),
(28, 7, 'D', 'Entreguei o documento à ele.', 0),

-- Questão 8
(29, 8, 'A', 'Metáfora', 0),
(30, 8, 'B', 'Prosopopeia (Personificação)', 1),
(31, 8, 'C', 'Hipérbole', 0),
(32, 8, 'D', 'Antítese', 0),

-- Questão 9
(33, 9, 'A', 'Eu estudo todos os dias.', 0),
(34, 9, 'B', 'Eu estudava quando você chegou.', 0),
(35, 9, 'C', 'Eu estudei bastante ontem.', 1),
(36, 9, 'D', 'Eu estudarei amanhã.', 0),

-- Questão 10
(37, 10, 'A', 'Eterno', 0),
(38, 10, 'B', 'Passageiro', 1),
(39, 10, 'C', 'Duradouro', 0),
(40, 10, 'D', 'Forte', 0);

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
(1, 1, 1, 1, '2026-09-22 14:00:00', 1, 30),
(2, 1, 2, 6, '2026-09-22 14:05:00', 1, 30),
(3, 1, 3, 9, '2026-09-22 14:10:00', 0, 0),
(4, 2, 1, 1, '2026-09-23 15:00:00', 1, 30),
(5, 2, 3, 10, '2026-09-23 15:05:00', 1, 10);

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
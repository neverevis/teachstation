-- TeachStation - Banco de Dados
-- Modelo compatível com JPA @Inheritance(strategy = InheritanceType.JOINED)
-- As tabelas de especialização (aluno, professor e secretaria)
-- utilizam "id" como PK e FK para usuario.id.

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
-- Compatível com JOINED:
-- aluno.id -> usuario.id
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
-- Compatível com JOINED:
-- professor.id -> usuario.id
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
-- Compatível com JOINED:
-- secretaria.id -> usuario.id
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
-- aluno_id -> aluno.id
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
    `tipo` ENUM('TESTE', 'DISSERTATIVA') NOT NULL,
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
-- Tabela: tentativas_atividades
-- aluno_id -> aluno.id
-- =====================================================

CREATE TABLE IF NOT EXISTS `tentativas_atividades` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `aluno_id` INT NOT NULL,
    `questao_id` INT NOT NULL,
    `data_tentativa` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
    `acertou` TINYINT(1) NOT NULL,
    `pontos_obtidos` INT NULL DEFAULT 0,

    PRIMARY KEY (`id`),
    INDEX `aluno_id` (`aluno_id` ASC) VISIBLE,
    INDEX `questao_id` (`questao_id` ASC) VISIBLE,

    CONSTRAINT `tentativas_atividades_ibfk_1`
        FOREIGN KEY (`aluno_id`)
        REFERENCES `aluno` (`id`)
        ON DELETE CASCADE,

    CONSTRAINT `tentativas_atividades_ibfk_2`
        FOREIGN KEY (`questao_id`)
        REFERENCES `questoes` (`id`)
        ON DELETE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- =====================================================
-- Restaurar configurações do MySQL
-- =====================================================

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

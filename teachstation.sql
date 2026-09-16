-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema teachstation
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema teachstation
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `teachstation` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `teachstation` ;

-- -----------------------------------------------------
-- Table `teachstation`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `teachstation`.`usuario` (
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
  UNIQUE INDEX `email` (`email` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `teachstation`.`aluno`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `teachstation`.`aluno` (
  `usuario_id` INT NOT NULL,
  `ra` VARCHAR(20) NOT NULL,
  `telefone_responsavel` VARCHAR(20) NULL DEFAULT NULL,
  `nivel_atual` ENUM('INICIANTE', 'INTERMEDIARIO', 'AVANCADO') NULL DEFAULT 'INICIANTE',
  PRIMARY KEY (`usuario_id`),
  UNIQUE INDEX `ra` (`ra` ASC) VISIBLE,
  CONSTRAINT `alunos_ibfk_1`
    FOREIGN KEY (`usuario_id`)
    REFERENCES `teachstation`.`usuario` (`id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `teachstation`.`areas_conhecimento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `teachstation`.`areas_conhecimento` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `ativo` TINYINT(1) NULL DEFAULT '0',
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `teachstation`.`avaliacao_diagnostica`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `teachstation`.`avaliacao_diagnostica` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `aluno_id` INT NOT NULL,
  `data_avaliacao` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `nota_final` DECIMAL(5,2) NULL DEFAULT NULL,
  `nivel_classificado` ENUM('INICIANTE', 'INTERMEDIARIO', 'AVANCADO') NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `aluno_id` (`aluno_id` ASC) VISIBLE,
  CONSTRAINT `avaliacoes_diagnosticas_ibfk_1`
    FOREIGN KEY (`aluno_id`)
    REFERENCES `teachstation`.`aluno` (`usuario_id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `teachstation`.`professor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `teachstation`.`professor` (
  `usuario_id` INT NOT NULL,
  `prontuario` VARCHAR(20) NOT NULL,
  `telefone` VARCHAR(20) NULL DEFAULT NULL,
  `area_atuacao` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`usuario_id`),
  UNIQUE INDEX `prontuario` (`prontuario` ASC) VISIBLE,
  CONSTRAINT `professores_ibfk_1`
    FOREIGN KEY (`usuario_id`)
    REFERENCES `teachstation`.`usuario` (`id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `teachstation`.`questoes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `teachstation`.`questoes` (
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
    REFERENCES `teachstation`.`areas_conhecimento` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `teachstation`.`secretaria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `teachstation`.`secretaria` (
  `usuario_id` INT NOT NULL,
  `codigo_funcionario` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`usuario_id`),
  UNIQUE INDEX `codigo_funcionario` (`codigo_funcionario` ASC) VISIBLE,
  CONSTRAINT `secretaria_ibfk_1`
    FOREIGN KEY (`usuario_id`)
    REFERENCES `teachstation`.`usuario` (`id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `teachstation`.`tentativas_atividades`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `teachstation`.`tentativas_atividades` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `aluno_id` INT NOT NULL,
  `questao_id` INT NOT NULL,
  `data_tentativa` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `acertou` TINYINT(1) NOT NULL,
  `pontos_obtidos` INT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  INDEX `aluno_id` (`aluno_id` ASC) VISIBLE,
  INDEX `questao_id` (`questao_id` ASC) VISIBLE,
  CONSTRAINT `tentativas_atividades_ibfk_1`
    FOREIGN KEY (`aluno_id`)
    REFERENCES `teachstation`.`aluno` (`usuario_id`)
    ON DELETE CASCADE,
  CONSTRAINT `tentativas_atividades_ibfk_2`
    FOREIGN KEY (`questao_id`)
    REFERENCES `teachstation`.`questoes` (`id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

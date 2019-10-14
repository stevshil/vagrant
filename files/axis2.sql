GRANT ALL PRIVILEGES ON *.* TO 'student'@'%' WITH GRANT OPTION;

-- ----------------------------------------------------------------------------
-- MySQL Workbench Migration
-- Migrated Schemata: quickfix
-- Source Schemata: quickfix
-- Created: Tue Aug 19 17:40:03 2014
-- ----------------------------------------------------------------------------

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
-- Schema quickfix
-- ----------------------------------------------------------------------------
DROP SCHEMA IF EXISTS `quickfix` ;
CREATE SCHEMA IF NOT EXISTS `quickfix` ;

-- ----------------------------------------------------------------------------
-- Table quickfix.messages
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `quickfix`.`messages` (
  `beginstring` CHAR(8) NOT NULL,
  `sendercompid` VARCHAR(64) NOT NULL,
  `sendersubid` VARCHAR(64) NOT NULL,
  `senderlocid` VARCHAR(64) NOT NULL,
  `targetcompid` VARCHAR(64) NOT NULL,
  `targetsubid` VARCHAR(64) NOT NULL,
  `targetlocid` VARCHAR(64) NOT NULL,
  `session_qualifier` VARCHAR(64) NOT NULL,
  `msgseqnum` INT NOT NULL,
  `message` LONGTEXT NOT NULL,
  PRIMARY KEY (`beginstring`, `sendercompid`, `sendersubid`, `senderlocid`, `targetcompid`, `targetsubid`, `targetlocid`, `session_qualifier`, `msgseqnum`));

-- ----------------------------------------------------------------------------
-- Table quickfix.event_log
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `quickfix`.`event_log` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `time` DATETIME NOT NULL,
  `beginstring` CHAR(8) NOT NULL,
  `sendercompid` VARCHAR(64) NOT NULL,
  `sendersubid` VARCHAR(64) NOT NULL,
  `senderlocid` VARCHAR(64) NOT NULL,
  `targetcompid` VARCHAR(64) NOT NULL,
  `targetsubid` VARCHAR(64) NOT NULL,
  `targetlocid` VARCHAR(64) NOT NULL,
  `session_qualifier` VARCHAR(64) NOT NULL,
  `text` LONGTEXT NOT NULL,
  PRIMARY KEY (`id`));

-- ----------------------------------------------------------------------------
-- Table quickfix.messages_log
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `quickfix`.`messages_log` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `time` DATETIME NOT NULL,
  `beginstring` CHAR(8) NOT NULL,
  `sendercompid` VARCHAR(64) NOT NULL,
  `sendersubid` VARCHAR(64) NOT NULL,
  `senderlocid` VARCHAR(64) NOT NULL,
  `targetcompid` VARCHAR(64) NOT NULL,
  `targetsubid` VARCHAR(64) NOT NULL,
  `targetlocid` VARCHAR(64) NOT NULL,
  `session_qualifier` VARCHAR(64) NOT NULL,
  `text` LONGTEXT NOT NULL,
  PRIMARY KEY (`id`));

-- ----------------------------------------------------------------------------
-- Table quickfix.sessions
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `quickfix`.`sessions` (
  `beginstring` CHAR(8) NOT NULL,
  `sendercompid` VARCHAR(64) NOT NULL,
  `sendersubid` VARCHAR(64) NOT NULL,
  `senderlocid` VARCHAR(64) NOT NULL,
  `targetcompid` VARCHAR(64) NOT NULL,
  `targetsubid` VARCHAR(64) NOT NULL,
  `targetlocid` VARCHAR(64) NOT NULL,
  `session_qualifier` VARCHAR(64) NOT NULL,
  `creation_time` DATETIME NOT NULL,
  `incoming_seqnum` INT NOT NULL,
  `outgoing_seqnum` INT NOT NULL,
  PRIMARY KEY (`beginstring`, `sendercompid`, `sendersubid`, `senderlocid`, `targetcompid`, `targetsubid`, `targetlocid`, `session_qualifier`));
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- MySQL Workbench Migration
-- Migrated Schemata: Test
-- Source Schemata: Test
-- Created: Tue Aug 19 17:36:14 2014
-- ----------------------------------------------------------------------------

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
-- Schema Test
-- ----------------------------------------------------------------------------
DROP SCHEMA IF EXISTS `Test` ;
CREATE SCHEMA IF NOT EXISTS `Test` ;

-- ----------------------------------------------------------------------------
-- Table Test.Updates
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Test`.`Updates` (
  `DateTime` DATETIME NOT NULL,
  `Stock` VARCHAR(10) NOT NULL,
  `AskSize` INT NOT NULL,
  `AskPrice` DOUBLE NOT NULL,
  `BidSize` INT NOT NULL,
  `BidPrice` DOUBLE NOT NULL,
  PRIMARY KEY (`DateTime`, `Stock`));

-- ----------------------------------------------------------------------------
-- Table Test.Trades
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Test`.`Trades` (
  `DateTime` DATETIME NOT NULL,
  `Strategy` VARCHAR(150) NOT NULL,
  `Stock` VARCHAR(10) NOT NULL,
  `Side` VARCHAR(6) NOT NULL,
  `Size` INT NOT NULL,
  `Price` DOUBLE NOT NULL,
  PRIMARY KEY (`DateTime`, `Strategy`, `Stock`));
SET FOREIGN_KEY_CHECKS = 1;

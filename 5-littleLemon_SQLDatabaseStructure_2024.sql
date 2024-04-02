-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema little_lemon_org_database
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema little_lemon_org_database
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `little_lemon_org_database` DEFAULT CHARACTER SET utf8 ;
USE `little_lemon_org_database` ;

-- -----------------------------------------------------
-- Table `little_lemon_org_database`.`Customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_org_database`.`Customers` (
  `CustomerID` VARCHAR(45) NOT NULL,
  `FirstName` VARCHAR(45) NOT NULL,
  `LastName` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CustomerID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `little_lemon_org_database`.`Orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_org_database`.`Orders` (
  `OrderID` VARCHAR(45) NOT NULL,
  `OrderDate` DATE NOT NULL,
  `CustomerID` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`OrderID`),
  INDEX `CustomerID_idx` (`CustomerID` ASC) VISIBLE,
  CONSTRAINT `CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `little_lemon_org_database`.`Customers` (`CustomerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `little_lemon_org_database`.`Products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_org_database`.`Products` (
  `ProductID` VARCHAR(45) NOT NULL,
  `CourseName` VARCHAR(45) NOT NULL,
  `CuisineName` VARCHAR(45) NOT NULL,
  `StarterName` VARCHAR(45) NOT NULL,
  `DesertName` VARCHAR(45) NOT NULL,
  `DrinkName` VARCHAR(45) NOT NULL,
  `SidesName` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`ProductID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `little_lemon_org_database`.`DeliveryAddress`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_org_database`.`DeliveryAddress` (
  `AddressID` VARCHAR(45) NOT NULL,
  `City` VARCHAR(45) NOT NULL,
  `Country` VARCHAR(45) NOT NULL,
  `PostalCode` VARCHAR(45) NOT NULL,
  `CountryCode` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`AddressID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `little_lemon_org_database`.`OrderDetails`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_org_database`.`OrderDetails` (
  `OrderDetailsID` INT NOT NULL AUTO_INCREMENT,
  `DeliveryDate` DATE NOT NULL,
  `DeliveryCost` DECIMAL(9,2) NOT NULL,
  `Quantity` INT NOT NULL,
  `CostPrice` DECIMAL(9,2) NOT NULL,
  `SalesPrice` DECIMAL(9,2) GENERATED ALWAYS AS (CostPrice * 1.5) VIRTUAL,
  `Discount` DECIMAL(9,2) NOT NULL,
  `AddressID` VARCHAR(45) NOT NULL,
  `OrderID` VARCHAR(45) NOT NULL,
  `ProductID` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`OrderDetailsID`),
  INDEX `AddressID_idx` (`AddressID` ASC) VISIBLE,
  INDEX `OrdersID_idx` (`OrderID` ASC) VISIBLE,
  INDEX `ProductID_idx` (`ProductID` ASC) VISIBLE,
  CONSTRAINT `AddressID`
    FOREIGN KEY (`AddressID`)
    REFERENCES `little_lemon_org_database`.`DeliveryAddress` (`AddressID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `OrderID`
    FOREIGN KEY (`OrderID`)
    REFERENCES `little_lemon_org_database`.`Orders` (`OrderID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `ProductID`
    FOREIGN KEY (`ProductID`)
    REFERENCES `little_lemon_org_database`.`Products` (`ProductID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

USE `little_lemon_org_database` ;

-- -----------------------------------------------------
-- Placeholder table for view `little_lemon_org_database`.`view1`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_org_database`.`view1` (`id` INT);

-- -----------------------------------------------------
-- View `little_lemon_org_database`.`view1`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `little_lemon_org_database`.`view1`;
USE `little_lemon_org_database`;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- Manual Code Creation

-- Create a stored procedure that returns the maximum quantity of products in all order.
DROP PROCEDURE IF EXISTS GetMaxQuantity;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS GetMaxQuantity (
    OUT MaxQuantity INT)
    BEGIN 
        SELECT MAX(Quantity)  
        FROM `orderdetails`
        INTO MaxQuantity;
    END//

CALL GetMaxQuantity(@MaxQuantity);
SELECT @MaxQuantity;


-- Create a stored procedure that returns the maximum quantity of products in an order.
DROP PROCEDURE IF EXISTS GetAllMaxQuantity;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS GetAllMaxQuantity ()
    BEGIN 
        SELECT OrderID, MAX(Quantity) AS 'Max Quantity' 
        FROM `orderdetails` 
        GROUP BY OrderID;
    END//


-- Create a Virtual Table (View) that returns all rows from all tables.
DROP VIEW IF EXISTS DataFromAllTables;

CREATE VIEW DataFromAllTables AS
SELECT da.AddressID, da.City, da.Country, da.PostalCode, da.CountryCode,
p.ProductID, p.CourseName, p.CuisineName, p.StarterName, p.DesertName, p.DrinkName, p.SidesName,
c.CustomerID, c.FirstName, c.LastName,
o.OrderID, o.OrderDate,
od.OrderdetailsID, od.DeliveryDate, od.DeliveryCost, od.Quantity, od.CostPrice, od.Salesprice,
od.Discount
FROM DeliveryAddress da, Products p, Customers c, Orders o, OrderDetails od 
WHERE c.CustomerID = o.CustomerID AND da.AddressID=od.AddressID AND
o.OrderID=od.OrderID AND p.ProductID=od.ProductID;

SELECT * FROM DataFromAllTables;


-- Create a stored procedure that manages booking by selecting data of the last 5 bookings.
DROP PROCEDURE IF EXISTS ManageBooking;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS ManageBooking()
    BEGIN 
        SELECT DISTINCT (OrderID), CustomerID, OrderDate, AddressID, DeliveryDate  
        FROM `DataFromAllTables` 
        ORDER BY OrderDate DESC
        LIMIT 5;
    END;//

CALL ManageBooking();


-- Create a stored procedure that adds a booking.
DROP PROCEDURE IF EXISTS AddBooking;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS AddBooking( 
                    IN addressid VARCHAR(45), 
                    IN city VARCHAR(45),
                    IN country VARCHAR(45),
                    IN postalcode VARCHAR(45),
                    IN countrycode VARCHAR(45),

                    IN productid VARCHAR(45),
                    
                    IN customerid VARCHAR(45),
                    IN firstname VARCHAR(45),
                    IN lastname VARCHAR(45),

                    IN orderid VARCHAR(45),
                    
                    IN deliverydate DATE,
                    IN deliverycost DECIMAL,
                    IN quantity INT,
                    IN costprice DECIMAL,
                    IN discount DECIMAL)
    BEGIN
        DECLARE coursename VARCHAR(45) DEFAULT 'NULL';
        DECLARE cuisinename VARCHAR(45) DEFAULT 'NULL';
        DECLARE startername VARCHAR(45) DEFAULT 'NULL';
        DECLARE desertname VARCHAR(45) DEFAULT 'NULL';
        DECLARE drinkname VARCHAR(45) DEFAULT 'NULL';
        DECLARE sidesname VARCHAR(45) DEFAULT 'NULL';

        SELECT Products.CourseName FROM Products WHERE Products.ProductID=productid INTO coursename;
        SELECT Products.CuisineName FROM Products WHERE Products.ProductID=productid INTO cuisinename;
        SELECT Products.StarterName FROM Products WHERE Products.ProductID=productid INTO startername;
        SELECT Products.DesertName FROM Products WHERE Products.ProductID=productid INTO desertname;
        SELECT Products.DrinkName FROM Products WHERE Products.ProductID=productid INTO drinkname;
        SELECT Products.SidesName FROM Products WHERE Products.ProductID=productid INTO sidesname;
        
        IF (coursename IS NOT NULL AND cuisinename IS NOT NULL AND startername IS NOT NULL
            AND desertname IS NOT NULL AND drinkname IS NOT NULL AND sidesname IS NOT NULL)
            THEN 
                INSERT INTO DeliveryAddress
                    VALUES (addressid, city, country, postalcode, countrycode);

                INSERT INTO Customers 
                    VALUES (customerid, firstname, lastname);

                INSERT INTO Orders 
                    VALUES (orderid, now(), customerid);

                INSERT INTO OrderDetails(DeliveryDate, DeliveryCost, Quantity, CostPrice, Discount, AddressID, OrderID, ProductID) 
                    VALUES (deliverydate, deliverycost, quantity, costprice, discount, addressid, orderid, productid); 
        END IF;
    END;//

CALL AddBooking('OTTAWA-CAN-G2V4H6-1','Ottawa','Canada','G2V4H6','CA', 
'BeaTurTomIceCorPot1', 
'77-452-8703','Jon','Doe',
'99-055-2024',
'2024-04-22', 10.50, 3, 120.50, 25.00);

CALL AddBooking('TORONTO-CAN-J3F6S8-1','Toronto','Canada','J3F6S8','CA', 
'GreGreFalGreAthTap1', 
'66-444-5555','Janet','DoeDoe',
'86-001-2024',
'2024-04-10', 9.75, 8, 150.75, 57.50); 

SELECT * FROM DataFromAllTables WHERE OrderId='99-055-2024' OR OrderId='86-001-2024';


-- Create a stored procedure that updates a booking.
DROP PROCEDURE IF EXISTS UpdateBooking;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS UpdateBooking( 
                    IN orderdetailsid INT,
                    IN deliverydate DATE,
                    IN deliverycost DECIMAL,
                    IN quantity INT,
                    IN costprice DECIMAL,
                    IN discount DECIMAL,
                    IN productid VARCHAR(45))
    BEGIN
        UPDATE OrderDetails SET 
        OrderDetails.DeliveryDate=deliverydate,
        OrderDetails.DeliveryCost=deliverycost,
        OrderDetails.Quantity=quantity,
        OrderDetails.Costprice=costprice,
        OrderDetails.Discount=discount,
        OrderDetails.ProductID=productid 
        WHERE OrderDetails.OrderDetailsID = orderdetailsid;
    END;//


SELECT * FROM DataFromAllTables WHERE OrderDetailsId='21000' OR OrderDetailsId='21001';

CALL UpdateBooking(21000,'2024-05-30', 200, 19, 401.00, 12,'BeaTurTomIceCorPot1');
CALL UpdateBooking(21001,'2024-06-01', 100, 8, 300.00, 15,'GreGreFalGreAthTap1');

SELECT * FROM DataFromAllTables WHERE OrderDetailsId='21000' OR OrderDetaisId='21001';


-- Create a stored procedure that cancels a booking.
DROP PROCEDURE IF EXISTS CancelBooking;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS CancelBooking( 
                    IN orderid VARCHAR(45))
    BEGIN
        DELETE FROM Orders 
        WHERE `Orders`.`OrderID` = orderid;
    END;//

SELECT * FROM DataFromAllTables WHERE OrderId='86-001-2024';

CALL CancelBooking('86-001-2024');

SELECT * FROM DataFromAllTables WHERE OrderId='86-001-2024';


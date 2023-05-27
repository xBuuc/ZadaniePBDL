-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 27, 2023 at 08:08 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `zadaniepbl`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ShopRevenueFromDate` (IN `fromDate` DATE)   BEGIN
  SELECT SUM(p.Price) AS TotalRevenue
  FROM Transaction t
  JOIN TransactionProducts tp ON t.Id = tp.TransactionId
  JOIN Products p ON tp.ProductId = p.Id
  WHERE t.Date >= fromDate;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `StoreRevenueInCity` (IN `xcity` VARCHAR(255))   BEGIN
  SELECT s.Id, SUM(p.Price) AS Revenue
  FROM Stores s
  LEFT JOIN Transaction t ON s.Id = t.StoreId
  LEFT JOIN TransactionProducts tp ON t.Id = tp.TransactionId
  LEFT JOIN Products p ON tp.ProductId = p.Id
  WHERE s.City = xcity
  GROUP BY s.Id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `Id` int(11) NOT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`Id`, `Name`, `Price`) VALUES
(1, 'Cabbage', 5.22),
(2, 'Banana', 4.12),
(3, 'Apple', 2.22),
(4, 'Strawberry', 8.52),
(5, 'Cookies', 7.44);

-- --------------------------------------------------------

--
-- Table structure for table `stores`
--

CREATE TABLE `stores` (
  `Id` int(11) NOT NULL,
  `City` varchar(255) DEFAULT NULL,
  `Street` varchar(255) DEFAULT NULL,
  `StreetNumber` varchar(30) DEFAULT NULL,
  `PhoneNumber` varchar(13) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stores`
--

INSERT INTO `stores` (`Id`, `City`, `Street`, `StreetNumber`, `PhoneNumber`) VALUES
(1, 'Wroclaw', 'Truskawkowa 7', '12b', '+48900289123'),
(2, 'Berlin', 'Hund 3', '11', '+48456789913'),
(3, 'Wroclaw', 'Pawła 5', '4', '+48456734523'),
(4, 'London', 'Wind 3', '7s', '+48458389123');

-- --------------------------------------------------------

--
-- Stand-in structure for view `storetransactionrevenue`
-- (See below for the actual view)
--
CREATE TABLE `storetransactionrevenue` (
`StoreId` int(11)
,`NumberOfTransactions` bigint(21)
,`Revenue` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `transaction`
--

CREATE TABLE `transaction` (
  `Id` int(11) NOT NULL,
  `Date` date DEFAULT NULL,
  `StoreId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaction`
--

INSERT INTO `transaction` (`Id`, `Date`, `StoreId`) VALUES
(1, '2002-11-12', 1),
(2, '2003-08-25', 3),
(3, '2005-02-13', 4);

-- --------------------------------------------------------

--
-- Table structure for table `transactionproducts`
--

CREATE TABLE `transactionproducts` (
  `TransactionId` int(11) DEFAULT NULL,
  `ProductId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transactionproducts`
--

INSERT INTO `transactionproducts` (`TransactionId`, `ProductId`) VALUES
(1, 1),
(1, 1),
(1, 3),
(2, 1),
(2, 2),
(2, 3),
(2, 5),
(3, 1),
(3, 3),
(3, 3);

-- --------------------------------------------------------

--
-- Stand-in structure for view `transaction_view`
-- (See below for the actual view)
--
CREATE TABLE `transaction_view` (
`Id` int(11)
,`SUM(p.Price)` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Structure for view `storetransactionrevenue`
--
DROP TABLE IF EXISTS `storetransactionrevenue`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `storetransactionrevenue`  AS SELECT `s`.`Id` AS `StoreId`, count(`t`.`Id`) AS `NumberOfTransactions`, sum(`p`.`Price`) AS `Revenue` FROM (((`stores` `s` left join `transaction` `t` on(`s`.`Id` = `t`.`StoreId`)) left join `transactionproducts` `tp` on(`t`.`Id` = `tp`.`TransactionId`)) left join `products` `p` on(`tp`.`ProductId` = `p`.`Id`)) GROUP BY `s`.`Id` ;

-- --------------------------------------------------------

--
-- Structure for view `transaction_view`
--
DROP TABLE IF EXISTS `transaction_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `transaction_view`  AS SELECT `t`.`Id` AS `Id`, sum(`p`.`Price`) AS `SUM(p.Price)` FROM ((`transaction` `t` join `transactionproducts` `tp` on(`t`.`Id` = `tp`.`TransactionId`)) join `products` `p` on(`tp`.`ProductId` = `p`.`Id`)) GROUP BY `t`.`Id` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`Id`);

--
-- Indexes for table `stores`
--
ALTER TABLE `stores`
  ADD PRIMARY KEY (`Id`);

--
-- Indexes for table `transaction`
--
ALTER TABLE `transaction`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `StoreId` (`StoreId`);

--
-- Indexes for table `transactionproducts`
--
ALTER TABLE `transactionproducts`
  ADD KEY `TransactionId` (`TransactionId`),
  ADD KEY `ProductId` (`ProductId`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `transaction`
--
ALTER TABLE `transaction`
  ADD CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`StoreId`) REFERENCES `stores` (`Id`);

--
-- Constraints for table `transactionproducts`
--
ALTER TABLE `transactionproducts`
  ADD CONSTRAINT `transactionproducts_ibfk_1` FOREIGN KEY (`TransactionId`) REFERENCES `transaction` (`Id`),
  ADD CONSTRAINT `transactionproducts_ibfk_2` FOREIGN KEY (`ProductId`) REFERENCES `products` (`Id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.28-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for katering_preorder
CREATE DATABASE IF NOT EXISTS `katering_preorder` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;
USE `katering_preorder`;

-- Dumping structure for table katering_preorder.orders
CREATE TABLE IF NOT EXISTS `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `package_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `days_count` int(11) NOT NULL,
  `portions` int(11) NOT NULL,
  `delivery_address` text NOT NULL,
  `notes` text DEFAULT NULL,
  `shipping_fee` int(11) NOT NULL DEFAULT 0,
  `discount` int(11) NOT NULL DEFAULT 0,
  `subtotal` int(11) NOT NULL,
  `total` int(11) NOT NULL,
  `status` enum('pending','approved','processing','delivering','done','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_orders_user` (`user_id`),
  KEY `idx_orders_package` (`package_id`),
  CONSTRAINT `fk_orders_package` FOREIGN KEY (`package_id`) REFERENCES `packages` (`id`),
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table katering_preorder.orders: ~8 rows (approximately)
INSERT INTO `orders` (`id`, `user_id`, `package_id`, `start_date`, `end_date`, `days_count`, `portions`, `delivery_address`, `notes`, `shipping_fee`, `discount`, `subtotal`, `total`, `status`, `created_at`) VALUES
	(1, 12, 1, '2025-12-19', '2025-12-23', 5, 1, 'Cibeunying Kidul', 'pedas', 5000, 2000, 75000, 78000, 'rejected', '2025-12-19 06:34:37'),
	(2, 2, 1, '2025-12-19', '2025-12-19', 1, 2, 'bandung', '', 0, 0, 30000, 30000, 'done', '2025-12-19 09:52:14'),
	(3, 2, 1, '2025-12-19', '2025-12-19', 1, 4, 'sukajadi', 'dddd', 0, 0, 60000, 60000, 'done', '2025-12-19 10:18:53'),
	(4, 18, 3, '2025-12-19', '2025-12-19', 1, 5, 'panyileukan', 'banyak', 0, 0, 150000, 150000, 'done', '2025-12-19 12:08:56'),
	(5, 20, 4, '2026-01-17', '2026-01-17', 1, 2, 'jalan mangga no 2 bandung', '', 0, 0, 10000000, 10000000, 'approved', '2026-01-17 10:40:46'),
	(6, 21, 2, '2026-01-17', '2026-01-17', 1, 2, 'jalan mangga no 12 bandung', '', 0, 0, 100000, 100000, 'approved', '2026-01-17 11:05:55'),
	(7, 2, 4, '2026-01-17', '2026-01-17', 1, 1, 'ty', '', 0, 0, 5000000, 5000000, 'approved', '2026-01-17 11:19:44'),
	(8, 22, 2, '2026-01-17', '2026-01-17', 1, 5, 'jalan mangga no 13 bandung', '', 0, 0, 250000, 250000, 'approved', '2026-01-17 11:44:15');

-- Dumping structure for table katering_preorder.packages
CREATE TABLE IF NOT EXISTS `packages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(160) NOT NULL,
  `price_per_portion_per_day` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table katering_preorder.packages: ~4 rows (approximately)
INSERT INTO `packages` (`id`, `name`, `price_per_portion_per_day`, `description`, `is_active`, `created_at`) VALUES
	(1, 'Paket Hemat', 15000, 'Nasi + Ayam + Sayur', 1, '2025-12-18 09:51:31'),
	(2, 'Sultan', 50000, 'sultan', 1, '2025-12-19 08:35:43'),
	(3, 'Standar', 30000, 'standar', 1, '2025-12-19 08:45:51'),
	(4, 'super ultra', 5000000, 'mahal', 1, '2025-12-19 12:11:29'),
	(6, 'hemat', 5000, 'hemat', 1, '2026-01-17 11:46:08');

-- Dumping structure for table katering_preorder.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `email` varchar(191) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('client','admin') NOT NULL,
  `is_approved` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table katering_preorder.users: ~14 rows (approximately)
INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `is_approved`, `created_at`) VALUES
	(1, 'Admin', 'admin@demo.com', '$2a$10$NiePXMnVuQLlpmBBh/EV6OKAUMA9j8kMulQfj0kcALzLnIzUvALx6', 'admin', 1, '2025-12-18 06:24:51'),
	(2, 'Rikki', 'rikki@gmail.com', '$2a$10$qG/wvoMa2RV69W0EqX2mbeBK4PlYxko9Gf7pPgoERsYoXKBhB4co6', 'client', 1, '2025-12-18 06:21:22'),
	(11, 'Rikki', 'rikki1@gmail.com', '$2a$10$T1zELKTy6Zs.2rZLQPCNFOK0JIAeh0nHUAMer7I12NjTPQqXAigKm', 'admin', 1, '2025-12-18 10:17:32'),
	(12, 'Rye', 'rye@gmail.com', '$2a$10$UQIiPUA/Io9W2QFeMalzseClVYKKfNCq7pmmqfW9YFR7LoYlK7Adm', 'client', 1, '2025-12-19 06:32:14'),
	(13, 'nanda', 'nanda@gmail.com', '$2a$10$.jP6UXK0RkFg74jHFImhFOfCAUE1HQD98/Mf.82N5FMCcjA.pXvUm', 'client', 1, '2025-12-19 10:45:39'),
	(14, 'azmi', 'azmi@gmail.com', '$2a$10$0rFzJvQMwnc./QO0tEteb.Dly8Auzl5ij76YmrpMIvlziXKGVzCNi', 'client', 1, '2025-12-19 11:13:00'),
	(15, 'aji', 'aji@gmail.com', '$2a$10$kMOBfTJ.7oWUQL3blAdVguvptB44a7D0AM.mwA1SICt93jGqAIadi', 'client', 1, '2025-12-19 11:26:10'),
	(16, 'reyhan', 'reyhan@gmail.com', '$2a$10$GKR.owcPqtbQpfcmPI2WdupOJbafYFf13iwUMUt52i1sKokM026eG', 'client', 1, '2025-12-19 11:36:38'),
	(17, 'Rendi', 'rendi@gmail.com', '$2a$10$cxrJOm2aZEMtJ5jNArlDU.RebvKKgyeAlLfeMZEOq9VC3CtL7AnP2', 'client', 1, '2025-12-19 11:37:05'),
	(18, 'ziqi', 'ziqi@gmail.com', '$2a$10$IHklOCFQlmY7lSyCgsQb0.LOuswzx3wJCEoR0VAag92hsmWrexMU.', 'client', 1, '2025-12-19 12:06:42'),
	(19, 'Rangga', 'rangga@gmail.com', '$2a$10$HV3Z0MbSnZkg/uI19O9b4uYDBsRWysy2m5pXEVjqn.E2V0gUf.jMi', 'client', 1, '2026-01-17 10:33:56'),
	(20, 'Zein', 'zein@gmail.com', '$2a$10$CzeABmQnalfg6/p2I.ydOOlFFAkksPNmDFvf.TGzGXRlwKAU6yk4G', 'client', 1, '2026-01-17 10:38:42'),
	(21, 'Lemon', 'lemon@gmail.com', '$2a$10$PyiH6z4VjjUC7Bzp0e0XZ.HmlDwYroywq7EcZa4tqWrvWT0Zs86DG', 'client', 1, '2026-01-17 11:04:44'),
	(22, 'Zen', 'zen@gmail.com', '$2a$10$ffu.SVJy9IQlaWR9r1BmGOwuXy0Xi6nWYmRBn8a.U/CcN6kXOQFHW', 'client', 1, '2026-01-17 11:42:04');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

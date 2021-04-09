-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Czas generowania: 09 Kwi 2021, 19:03
-- Wersja serwera: 10.4.11-MariaDB
-- Wersja PHP: 7.4.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `essentialmode`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `m_packages`
--

CREATE TABLE `m_packages` (
  `id` int(11) NOT NULL,
  `zone` varchar(11) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  `items` longtext NOT NULL,
  `sender` varchar(255) DEFAULT NULL,
  `receiver` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `user` varchar(255) DEFAULT NULL,
  `label` varchar(255) NOT NULL DEFAULT 'Nieznana paczka'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `m_packages`
--
ALTER TABLE `m_packages`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT dla tabeli `m_packages`
--
ALTER TABLE `m_packages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;


-- Baza transakcyjna OLTP – Przychodnia lekarska


CREATE DATABASE Przychodnia_OLTP;
GO
USE Przychodnia_OLTP;
GO

CREATE TABLE dbo.Specjalizacja (
    SpecjalizacjaID INT IDENTITY(1,1) NOT NULL,
    Nazwa NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Specjalizacja PRIMARY KEY (SpecjalizacjaID),
    CONSTRAINT UQ_Specjalizacja_Nazwa UNIQUE (Nazwa)
);

CREATE TABLE dbo.StatusWizyty (
    StatusWizytyID INT IDENTITY(1,1) NOT NULL,
    Kod NVARCHAR(30) NOT NULL,
    Nazwa NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_StatusWizyty PRIMARY KEY (StatusWizytyID),
    CONSTRAINT UQ_StatusWizyty_Kod UNIQUE (Kod)
);

CREATE TABLE dbo.MetodaPlatnosci (
    MetodaPlatnosciID INT IDENTITY(1,1) NOT NULL,
    Kod NVARCHAR(30) NOT NULL,
    Nazwa NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_MetodaPlatnosci PRIMARY KEY (MetodaPlatnosciID),
    CONSTRAINT UQ_MetodaPlatnosci_Kod UNIQUE (Kod)
);

CREATE TABLE dbo.Pacjent (
    PacjentID INT IDENTITY(1,1) NOT NULL,
    Imie NVARCHAR(50) NOT NULL,
    Nazwisko NVARCHAR(80) NOT NULL,
    DataUrodzenia DATE NULL,
    Telefon NVARCHAR(30) NULL,
    Email NVARCHAR(120) NULL,
    CONSTRAINT PK_Pacjent PRIMARY KEY (PacjentID)
);

CREATE TABLE dbo.Lekarz (
    LekarzID INT IDENTITY(1,1) NOT NULL,
    Imie NVARCHAR(50) NOT NULL,
    Nazwisko NVARCHAR(80) NOT NULL,
    SpecjalizacjaID INT NOT NULL,
    NumerPWZ NVARCHAR(30) NULL,
    CONSTRAINT PK_Lekarz PRIMARY KEY (LekarzID),
    CONSTRAINT FK_Lekarz_Specjalizacja FOREIGN KEY (SpecjalizacjaID) REFERENCES dbo.Specjalizacja(SpecjalizacjaID)
);

CREATE TABLE dbo.Gabinet (
    GabinetID INT IDENTITY(1,1) NOT NULL,
    Kod NVARCHAR(30) NOT NULL,
    Opis NVARCHAR(200) NULL,
    CONSTRAINT PK_Gabinet PRIMARY KEY (GabinetID),
    CONSTRAINT UQ_Gabinet_Kod UNIQUE (Kod)
);

CREATE TABLE dbo.UslugaMedyczna (
    UslugaID INT IDENTITY(1,1) NOT NULL,
    Kod NVARCHAR(30) NOT NULL,
    Nazwa NVARCHAR(120) NOT NULL,
    CenaPodstawowa DECIMAL(10,2) NOT NULL,
    CzasTrwaniaMin INT NOT NULL,
    SpecjalizacjaID INT NULL,
    CONSTRAINT PK_UslugaMedyczna PRIMARY KEY (UslugaID),
    CONSTRAINT UQ_UslugaMedyczna_Kod UNIQUE (Kod),
    CONSTRAINT CK_Usluga_Cena CHECK (CenaPodstawowa >= 0),
    CONSTRAINT CK_Usluga_Czas CHECK (CzasTrwaniaMin > 0),
    CONSTRAINT FK_Usluga_Specjalizacja FOREIGN KEY (SpecjalizacjaID) REFERENCES dbo.Specjalizacja(SpecjalizacjaID)
);

CREATE TABLE dbo.GrafikLekarza (
    GrafikID INT IDENTITY(1,1) NOT NULL,
    LekarzID INT NOT NULL,
    GabinetID INT NOT NULL,
    DataOd DATE NOT NULL,
    GodzinaOd TIME(0) NOT NULL,
    GodzinaDo TIME(0) NOT NULL,
    CONSTRAINT PK_GrafikLekarza PRIMARY KEY (GrafikID),
    CONSTRAINT FK_GrafikLekarza_Lekarz FOREIGN KEY (LekarzID) REFERENCES dbo.Lekarz(LekarzID),
    CONSTRAINT FK_GrafikLekarza_Gabinet FOREIGN KEY (GabinetID) REFERENCES dbo.Gabinet(GabinetID),
    CONSTRAINT CK_Grafik_Godziny CHECK (GodzinaOd < GodzinaDo)
);

CREATE TABLE dbo.Wizyta (
    WizytaID INT IDENTITY(1,1) NOT NULL,
    PacjentID INT NOT NULL,
    LekarzID INT NOT NULL,
    GabinetID INT NOT NULL,
    StatusWizytyID INT NOT NULL,
    DataWizyty DATE NOT NULL,
    GodzinaOd TIME(0) NOT NULL,
    GodzinaDo TIME(0) NOT NULL,
    Uwagi NVARCHAR(300) NULL,
    CONSTRAINT PK_Wizyta PRIMARY KEY (WizytaID),
    CONSTRAINT FK_Wizyta_Pacjent FOREIGN KEY (PacjentID) REFERENCES dbo.Pacjent(PacjentID),
    CONSTRAINT FK_Wizyta_Lekarz FOREIGN KEY (LekarzID) REFERENCES dbo.Lekarz(LekarzID),
    CONSTRAINT FK_Wizyta_Gabinet FOREIGN KEY (GabinetID) REFERENCES dbo.Gabinet(GabinetID),
    CONSTRAINT FK_Wizyta_Status FOREIGN KEY (StatusWizytyID) REFERENCES dbo.StatusWizyty(StatusWizytyID),
    CONSTRAINT CK_Wizyta_Godziny CHECK (GodzinaOd < GodzinaDo)
);

CREATE TABLE dbo.WizytaUsluga (
    WizytaUslugaID INT IDENTITY(1,1) NOT NULL,
    WizytaID INT NOT NULL,
    UslugaID INT NOT NULL,
    Ilosc INT NOT NULL,
    CenaJednostkowa DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_WizytaUsluga PRIMARY KEY (WizytaUslugaID),
    CONSTRAINT FK_WizytaUsluga_Wizyta FOREIGN KEY (WizytaID) REFERENCES dbo.Wizyta(WizytaID),
    CONSTRAINT FK_WizytaUsluga_Usluga FOREIGN KEY (UslugaID) REFERENCES dbo.UslugaMedyczna(UslugaID),
    CONSTRAINT CK_WizytaUsluga_Ilosc CHECK (Ilosc > 0),
    CONSTRAINT CK_WizytaUsluga_Cena CHECK (CenaJednostkowa >= 0),
    CONSTRAINT UQ_WizytaUsluga UNIQUE (WizytaID, UslugaID)
);

CREATE TABLE dbo.Platnosc (
    PlatnoscID INT IDENTITY(1,1) NOT NULL,
    WizytaID INT NOT NULL,
    MetodaPlatnosciID INT NOT NULL,
    DataPlatnosci DATETIME2(0) NOT NULL,
    Kwota DECIMAL(10,2) NOT NULL,
    StatusPlatnosci NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_Platnosc PRIMARY KEY (PlatnoscID),
    CONSTRAINT FK_Platnosc_Wizyta FOREIGN KEY (WizytaID) REFERENCES dbo.Wizyta(WizytaID),
    CONSTRAINT FK_Platnosc_Metoda FOREIGN KEY (MetodaPlatnosciID) REFERENCES dbo.MetodaPlatnosci(MetodaPlatnosciID),
    CONSTRAINT CK_Platnosc_Kwota CHECK (Kwota >= 0),
    CONSTRAINT CK_Platnosc_Status CHECK (StatusPlatnosci IN (N'OPLACONA', N'NIEOPLACONA'))
);

CREATE TABLE dbo.Kraj (
    KrajID INT IDENTITY(1,1) NOT NULL,
    Nazwa NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Kraj PRIMARY KEY (KrajID),
    CONSTRAINT UQ_Kraj_Nazwa UNIQUE (Nazwa)
);

CREATE TABLE dbo.Miasto (
    MiastoID INT IDENTITY(1,1) NOT NULL,
    KrajID INT NOT NULL,
    Nazwa NVARCHAR(120) NOT NULL,
    CONSTRAINT PK_Miasto PRIMARY KEY (MiastoID),
    CONSTRAINT FK_Miasto_Kraj FOREIGN KEY (KrajID) REFERENCES dbo.Kraj(KrajID)
);

CREATE TABLE dbo.AdresPacjenta (
    AdresPacjentaID INT IDENTITY(1,1) NOT NULL,
    PacjentID INT NOT NULL,
    MiastoID INT NOT NULL,
    Ulica NVARCHAR(120) NOT NULL,
    NrBudynku NVARCHAR(20) NOT NULL,
    NrLokalu NVARCHAR(20) NULL,
    KodPocztowy NVARCHAR(20) NOT NULL,
    CONSTRAINT PK_AdresPacjenta PRIMARY KEY (AdresPacjentaID),
    CONSTRAINT FK_AdresPacjenta_Pacjent FOREIGN KEY (PacjentID) REFERENCES dbo.Pacjent(PacjentID),
    CONSTRAINT FK_AdresPacjenta_Miasto FOREIGN KEY (MiastoID) REFERENCES dbo.Miasto(MiastoID)
);

CREATE TABLE dbo.DokumentRozliczeniowy (
    DokumentRozliczeniowyID INT IDENTITY(1,1) NOT NULL,
    WizytaID INT NOT NULL,
    DataWystawienia DATETIME2(0) NOT NULL,
    Suma DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_DokumentRozliczeniowy PRIMARY KEY (DokumentRozliczeniowyID),
    CONSTRAINT FK_DokumentRozliczeniowy_Wizyta FOREIGN KEY (WizytaID) REFERENCES dbo.Wizyta(WizytaID),
    CONSTRAINT CK_DokumentRozliczeniowy_Suma CHECK (Suma >= 0),
    CONSTRAINT UQ_DokumentRozliczeniowy_Wizyta UNIQUE (WizytaID)
);

CREATE TABLE dbo.PozycjaRozliczenia (
    PozycjaRozliczeniaID INT IDENTITY(1,1) NOT NULL,
    DokumentRozliczeniowyID INT NOT NULL,
    UslugaID INT NOT NULL,
    Ilosc INT NOT NULL,
    CenaJednostkowa DECIMAL(10,2) NOT NULL,
    Wartosc AS (Ilosc * CenaJednostkowa) PERSISTED,
    CONSTRAINT PK_PozycjaRozliczenia PRIMARY KEY (PozycjaRozliczeniaID),
    CONSTRAINT FK_PozycjaRozliczenia_Dokument FOREIGN KEY (DokumentRozliczeniowyID) REFERENCES dbo.DokumentRozliczeniowy(DokumentRozliczeniowyID),
    CONSTRAINT FK_PozycjaRozliczenia_Usluga FOREIGN KEY (UslugaID) REFERENCES dbo.UslugaMedyczna(UslugaID),
    CONSTRAINT CK_PozycjaRozliczenia_Ilosc CHECK (Ilosc > 0),
    CONSTRAINT CK_PozycjaRozliczenia_Cena CHECK (CenaJednostkowa >= 0),
    CONSTRAINT UQ_PozycjaRozliczenia UNIQUE (DokumentRozliczeniowyID, UslugaID)
);

CREATE TABLE dbo.Ubezpieczyciel (
    UbezpieczycielID INT IDENTITY(1,1) NOT NULL,
    Nazwa NVARCHAR(150) NOT NULL,
    NIP NVARCHAR(20) NULL,
    CONSTRAINT PK_Ubezpieczyciel PRIMARY KEY (UbezpieczycielID),
    CONSTRAINT UQ_Ubezpieczyciel UNIQUE (Nazwa)
);

CREATE TABLE dbo.UbezpieczeniePacjenta (
    UbezpieczeniePacjentaID INT IDENTITY(1,1) NOT NULL,
    PacjentID INT NOT NULL,
    UbezpieczycielID INT NOT NULL,
    NumerUbezpieczenia NVARCHAR(50) NOT NULL,
    DataOd DATE NOT NULL,
    DataDo DATE NULL,
    CONSTRAINT PK_UbezpieczeniePacjenta PRIMARY KEY (UbezpieczeniePacjentaID),
    CONSTRAINT FK_UbezpieczeniePacjenta_Pacjent FOREIGN KEY (PacjentID) REFERENCES dbo.Pacjent(PacjentID),
    CONSTRAINT FK_UbezpieczeniePacjenta_Ubezpieczyciel FOREIGN KEY (UbezpieczycielID) REFERENCES dbo.Ubezpieczyciel(UbezpieczycielID),
    CONSTRAINT CK_UbezpieczeniePacjenta_Daty CHECK (DataDo IS NULL OR DataOd <= DataDo),
    CONSTRAINT UQ_UbezpieczeniePacjenta UNIQUE (PacjentID, UbezpieczycielID, NumerUbezpieczenia, DataOd)
);

CREATE TABLE dbo.CennikUslugi (
    CennikUslugiID INT IDENTITY(1,1) NOT NULL,
    UslugaID INT NOT NULL,
    Cena DECIMAL(10,2) NOT NULL,
    DataOd DATE NOT NULL,
    DataDo DATE NULL,
    CONSTRAINT PK_CennikUslugi PRIMARY KEY (CennikUslugiID),
    CONSTRAINT FK_CennikUslugi_Usluga FOREIGN KEY (UslugaID) REFERENCES dbo.UslugaMedyczna(UslugaID),
    CONSTRAINT CK_CennikUslugi_Cena CHECK (Cena >= 0),
    CONSTRAINT CK_CennikUslugi_Daty CHECK (DataDo IS NULL OR DataOd <= DataDo),
    CONSTRAINT UQ_CennikUslugi UNIQUE (UslugaID, DataOd)
);

CREATE TABLE dbo.PowodOdwolania (
    PowodOdwolaniaID INT IDENTITY(1,1) NOT NULL,
    Nazwa NVARCHAR(150) NOT NULL,
    CONSTRAINT PK_PowodOdwolania PRIMARY KEY (PowodOdwolaniaID),
    CONSTRAINT UQ_PowodOdwolania UNIQUE (Nazwa)
);

CREATE TABLE dbo.OdwolanieWizyty (
    OdwolanieWizytyID INT IDENTITY(1,1) NOT NULL,
    WizytaID INT NOT NULL,
    PowodOdwolaniaID INT NOT NULL,
    DataOdwolania DATETIME2(0) NOT NULL,
    CONSTRAINT PK_OdwolanieWizyty PRIMARY KEY (OdwolanieWizytyID),
    CONSTRAINT FK_OdwolanieWizyty_Wizyta FOREIGN KEY (WizytaID) REFERENCES dbo.Wizyta(WizytaID),
    CONSTRAINT FK_OdwolanieWizyty_Powod FOREIGN KEY (PowodOdwolaniaID) REFERENCES dbo.PowodOdwolania(PowodOdwolaniaID),
    CONSTRAINT UQ_OdwolanieWizyty UNIQUE (WizytaID)
);
GO


-- Przykładowe dane


INSERT INTO dbo.Pacjent (Imie, Nazwisko, DataUrodzenia, Telefon, Email)
VALUES
('Piotr', 'Kowalski', '1990-06-15', '500600700', 'piotr.k@gmail.com'),
('Maria', 'Kowalska', '1985-11-30', '700800900', 'maria.k@gmail.com'),
('Kamil', 'Zalewski', '1980-02-10', '600700800', 'kamil.z@gmail.com');

INSERT INTO dbo.Specjalizacja (Nazwa)
VALUES ('Medycyna rodzinna'), ('Kardiologia'), ('Ortopedia');

INSERT INTO dbo.Lekarz (Imie, Nazwisko, SpecjalizacjaID, NumerPWZ)
VALUES ('Anna', 'Nowak', 1, 'PWZ123'), ('Jan', 'Kowalski', 2, 'PWZ456');

INSERT INTO dbo.Gabinet (Kod, Opis)
VALUES ('GAB-01', 'Gabinet 1'), ('GAB-02', 'Gabinet 2');

INSERT INTO dbo.UslugaMedyczna (Kod, Nazwa, CenaPodstawowa, CzasTrwaniaMin, SpecjalizacjaID)
VALUES
('KONS-POZ', 'Konsultacja (POZ)', 120.00, 20, 1),
('KONS-KARD', 'Konsultacja kardiologiczna', 250.00, 30, 2);

INSERT INTO dbo.StatusWizyty (Kod, Nazwa)
VALUES
('ZAPLANOWANA', 'Zaplanowana'),
('ODBYTA', 'Odbyta'),
('ODWOLANA', 'Odwołana'),
('NIEOBECNOSC', 'Nieobecność');

INSERT INTO dbo.Wizyta (PacjentID, LekarzID, GabinetID, StatusWizytyID, DataWizyty, GodzinaOd, GodzinaDo)
VALUES
(1, 1, 1, 1, '2026-02-10', '10:00', '10:20'),
(2, 2, 2, 2, '2026-02-10', '11:00', '11:30');

INSERT INTO dbo.WizytaUsluga (WizytaID, UslugaID, Ilosc, CenaJednostkowa)
VALUES (2, 2, 1, 250.00);

INSERT INTO dbo.MetodaPlatnosci (Kod, Nazwa)
VALUES ('GOTOWKA', 'Gotówka'), ('KARTA', 'Karta'), ('PRZELEW', 'Przelew');

INSERT INTO dbo.Platnosc (WizytaID, MetodaPlatnosciID, DataPlatnosci, Kwota, StatusPlatnosci)
VALUES (2, 2, '2026-02-10 11:40:00', 250.00, 'OPLACONA');

INSERT INTO dbo.Ubezpieczyciel (Nazwa, NIP)
VALUES ('NFZ', '1234567890'), ('PZU', '9876543210');

INSERT INTO dbo.UbezpieczeniePacjenta (PacjentID, UbezpieczycielID, NumerUbezpieczenia, DataOd, DataDo)
VALUES
(1, 1, 'NFZ-123', '2022-01-01', NULL),
(2, 2, 'PZU-456', '2025-01-01', '2025-12-31');

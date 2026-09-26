-- ============================================================
-- Hurtownia danych OLAP – Przychodnia lekarska (model gwiazdy)
-- ============================================================

CREATE DATABASE Przychodnia_OLAP;
GO
USE Przychodnia_OLAP;
GO

CREATE TABLE dbo.DimCzas (
    CzasID INT NOT NULL,
    Rok INT NOT NULL,
    Kwartal INT NOT NULL,
    Miesiac INT NOT NULL,
    Dzien INT NOT NULL,
    CONSTRAINT PK_DimCzas PRIMARY KEY (CzasID)
);

CREATE TABLE dbo.DimPacjent (
    PacjentID INT NOT NULL,
    Imie NVARCHAR(50) NOT NULL,
    Nazwisko NVARCHAR(80) NOT NULL,
    CONSTRAINT PK_DimPacjent PRIMARY KEY (PacjentID)
);

CREATE TABLE dbo.DimGabinet (
    GabinetID INT NOT NULL,
    Kod NVARCHAR(30) NOT NULL,
    Opis NVARCHAR(200) NULL,
    CONSTRAINT PK_DimGabinet PRIMARY KEY (GabinetID)
);

CREATE TABLE dbo.StatusWizyty (
    StatusWizytyID INT NOT NULL,
    Kod NVARCHAR(30) NOT NULL,
    Nazwa NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_StatusWizyty PRIMARY KEY (StatusWizytyID),
    CONSTRAINT UQ_StatusWizyty_Kod UNIQUE (Kod)
);

CREATE TABLE dbo.Specjalizacja (
    SpecjalizacjaID INT NOT NULL,
    Nazwa NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Specjalizacja PRIMARY KEY (SpecjalizacjaID),
    CONSTRAINT UQ_Specjalizacja_Nazwa UNIQUE (Nazwa)
);

CREATE TABLE dbo.DimUbezpieczenie (
    UbezpieczenieID INT NOT NULL,
    NumerPolisy NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_DimUbezpieczenie PRIMARY KEY (UbezpieczenieID)
);

CREATE TABLE dbo.DimLekarz (
    LekarzID INT NOT NULL,
    Imie NVARCHAR(50) NOT NULL,
    Nazwisko NVARCHAR(80) NOT NULL,
    SpecjalizacjaID INT NOT NULL,
    NumerPWZ NVARCHAR(30) NULL,
    CONSTRAINT PK_DimLekarz PRIMARY KEY (LekarzID),
    CONSTRAINT FK_DimLekarz_Specjalizacja FOREIGN KEY (SpecjalizacjaID) REFERENCES dbo.Specjalizacja(SpecjalizacjaID)
);

CREATE TABLE dbo.DimUsluga (
    UslugaID INT NOT NULL,
    Kod NVARCHAR(30) NOT NULL,
    Nazwa NVARCHAR(120) NOT NULL,
    CenaPodstawowa DECIMAL(10,2) NOT NULL,
    CzasTrwaniaMin INT NOT NULL,
    SpecjalizacjaID INT NULL,
    CONSTRAINT PK_DimUsluga PRIMARY KEY (UslugaID),
    CONSTRAINT FK_DimUsluga_Specjalizacja FOREIGN KEY (SpecjalizacjaID) REFERENCES dbo.Specjalizacja(SpecjalizacjaID)
);

CREATE TABLE dbo.FaktWizyta (
    WizytaID INT NOT NULL,
    PacjentID INT NOT NULL,
    LekarzID INT NOT NULL,
    GabinetID INT NOT NULL,
    StatusWizytyID INT NOT NULL,
    CzasID INT NOT NULL,
    CzasTrwania INT NULL,
    UbezpieczenieID INT NULL,
    CONSTRAINT PK_FaktWizyta PRIMARY KEY (WizytaID),
    CONSTRAINT FK_FaktWizyta_Pacjent FOREIGN KEY (PacjentID) REFERENCES dbo.DimPacjent(PacjentID),
    CONSTRAINT FK_FaktWizyta_Lekarz FOREIGN KEY (LekarzID) REFERENCES dbo.DimLekarz(LekarzID),
    CONSTRAINT FK_FaktWizyta_Gabinet FOREIGN KEY (GabinetID) REFERENCES dbo.DimGabinet(GabinetID),
    CONSTRAINT FK_FaktWizyta_Status FOREIGN KEY (StatusWizytyID) REFERENCES dbo.StatusWizyty(StatusWizytyID),
    CONSTRAINT FK_FaktWizyta_Czas FOREIGN KEY (CzasID) REFERENCES dbo.DimCzas(CzasID),
    CONSTRAINT FK_FaktWizyta_Ubezpieczenie FOREIGN KEY (UbezpieczenieID) REFERENCES dbo.DimUbezpieczenie(UbezpieczenieID)
);

CREATE TABLE dbo.FaktUsluga (
    FaktUslugaID INT NOT NULL,
    WizytaID INT NOT NULL,
    UslugaID INT NOT NULL,
    Ilosc INT NOT NULL,
    Cena DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_FaktUsluga PRIMARY KEY (FaktUslugaID),
    CONSTRAINT FK_FaktUsluga_Wizyta FOREIGN KEY (WizytaID) REFERENCES dbo.FaktWizyta(WizytaID),
    CONSTRAINT FK_FaktUsluga_Usluga FOREIGN KEY (UslugaID) REFERENCES dbo.DimUsluga(UslugaID)
);
GO

-- ============================================================
-- Proces ETL – zasilanie hurtowni danymi z bazy OLTP
-- ============================================================

INSERT INTO dbo.Specjalizacja (SpecjalizacjaID, Nazwa)
SELECT SpecjalizacjaID, Nazwa
FROM Przychodnia_OLTP.dbo.Specjalizacja;

INSERT INTO dbo.StatusWizyty (StatusWizytyID, Kod, Nazwa)
SELECT StatusWizytyID, Kod, Nazwa
FROM Przychodnia_OLTP.dbo.StatusWizyty;

INSERT INTO dbo.DimPacjent (PacjentID, Imie, Nazwisko)
SELECT PacjentID, Imie, Nazwisko
FROM Przychodnia_OLTP.dbo.Pacjent;

INSERT INTO dbo.DimGabinet (GabinetID, Kod, Opis)
SELECT GabinetID, Kod, Opis
FROM Przychodnia_OLTP.dbo.Gabinet;

INSERT INTO dbo.DimUbezpieczenie (UbezpieczenieID, NumerPolisy)
SELECT UbezpieczeniePacjentaID, NumerUbezpieczenia
FROM Przychodnia_OLTP.dbo.UbezpieczeniePacjenta;

INSERT INTO dbo.DimLekarz (LekarzID, Imie, Nazwisko, SpecjalizacjaID, NumerPWZ)
SELECT LekarzID, Imie, Nazwisko, SpecjalizacjaID, NumerPWZ
FROM Przychodnia_OLTP.dbo.Lekarz;

INSERT INTO dbo.DimUsluga (UslugaID, Kod, Nazwa, CenaPodstawowa, CzasTrwaniaMin, SpecjalizacjaID)
SELECT UslugaID, Kod, Nazwa, CenaPodstawowa, CzasTrwaniaMin, SpecjalizacjaID
FROM Przychodnia_OLTP.dbo.UslugaMedyczna;

INSERT INTO dbo.DimCzas (CzasID, Rok, Kwartal, Miesiac, Dzien)
SELECT DISTINCT
    YEAR(DataWizyty) * 10000 + MONTH(DataWizyty) * 100 + DAY(DataWizyty) AS CzasID,
    YEAR(DataWizyty) AS Rok,
    DATEPART(QUARTER, DataWizyty) AS Kwartal,
    MONTH(DataWizyty) AS Miesiac,
    DAY(DataWizyty) AS Dzien
FROM Przychodnia_OLTP.dbo.Wizyta;

INSERT INTO dbo.FaktWizyta
(
    WizytaID, PacjentID, LekarzID, GabinetID, StatusWizytyID, CzasID, CzasTrwania, UbezpieczenieID
)
SELECT
    w.WizytaID,
    w.PacjentID,
    w.LekarzID,
    w.GabinetID,
    w.StatusWizytyID,
    YEAR(w.DataWizyty) * 10000 + MONTH(w.DataWizyty) * 100 + DAY(w.DataWizyty) AS CzasID,
    DATEDIFF(MINUTE, w.GodzinaOd, w.GodzinaDo) AS CzasTrwania,
    (
        SELECT TOP (1) up.UbezpieczeniePacjentaID
        FROM Przychodnia_OLTP.dbo.UbezpieczeniePacjenta up
        WHERE up.PacjentID = w.PacjentID
          AND w.DataWizyty >= up.DataOd
          AND (up.DataDo IS NULL OR w.DataWizyty <= up.DataDo)
        ORDER BY up.DataOd DESC
    ) AS UbezpieczenieID
FROM Przychodnia_OLTP.dbo.Wizyta w;

INSERT INTO dbo.FaktUsluga (FaktUslugaID, WizytaID, UslugaID, Ilosc, Cena)
SELECT
    WizytaUslugaID,
    WizytaID,
    UslugaID,
    Ilosc,
    CenaJednostkowa
FROM Przychodnia_OLTP.dbo.WizytaUsluga;

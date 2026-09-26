## Baza transakcyjna i hurtownia danych – przychodnia lekarska

Celem projektu było zaprojektowanie i zaimplementowanie kompletnego rozwiązania bazodanowego wspierającego zarządzanie przychodnią lekarską – zarówno w warstwie transakcyjnej (OLTP), jak i analitycznej (OLAP).

## Zakres projektu

# Baza transakcyjna (OLTP)

Wspiera codzienną pracę przychodni: rejestrację pacjentów, lekarzy i ich specjalizacji, grafiki przyjęć, wizyty, usługi medyczne, płatności, ubezpieczenia oraz dokumenty rozliczeniowe.

# Hurtownia danych (OLAP)

Zasilana danymi z bazy OLTP, zbudowana w modelu gwiazdy, umożliwia analizę:

- liczby wizyt w czasie
- wizyt odbytych i odwołanych
- wykonanych usług medycznych
- obciążenia lekarzy oraz gabinetów

## Zawartość repozytorium 

*oltp_schema.sql* -	Utworzenie bazy transakcyjnej OLTP wraz z przykładowymi danymi
*olap_schema_etl.sql* -	Utworzenie hurtowni OLAP oraz proces ETL zasilający ją z bazy OLTP

## Model danych

Baza OLTP obejmuje ok. 20 encji, m.in.: Pacjent, Lekarz, Specjalizacja, Gabinet, GrafikLekarza, Wizyta, StatusWizyty, UslugaMedyczna, WizytaUsluga, Platnosc, MetodaPlatnosci, DokumentRozliczeniowy, PozycjaRozliczenia, Ubezpieczyciel, UbezpieczeniePacjenta, AdresPacjenta, Miasto, Kraj, PowodOdwolania, OdwolanieWizyty

Hurtownia OLAP zbudowana jest w modelu gwiazdy z dwiema tabelami faktów:

- FaktWizyta - zdarzenia wizytowe (powiązane z wymiarami: pacjent, lekarz, gabinet, status, czas, ubezpieczenie)
- FaktUsluga - zdarzenie usługowe w ramach wizyt (powiązane z wymiarem usługi)






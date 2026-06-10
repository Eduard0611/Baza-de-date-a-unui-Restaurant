# Proiect Baze de Date - Managementul unui Restaurant

Acest repository conține un proiect la baze de date, axat pe modelarea și gestionarea activității unui restaurant folosind **Oracle SQL**. 

## Ce conține proiectul?

Proiectul este împărțit în trei componente principale:

1. **Documentația (Punctul forte al proiectului) **
   Vă recomand să consultați fișierul `"Managementul unui Restaurant".pdf`. Acolo se află documentația amănunțită a proiectului:
   * Diagramele conceptuale și relaționale.
   * Regulile de business.
   * Explicația detaliată a constrângerilor, tabelelor și relațiilor dintre ele.

2. **Scriptul SQL (`/BazaDeDate/script.sql`) **
   Acesta este codul care definește efectiv baza de date. Conține 12 tabele (produse, angajați, comenzi, etc.), chei primare/externe, constrângeri de integritate (`CHECK`, `UNIQUE`) și scripturi pentru a popula baza cu date de test.

3. **Interfața Web (`/InterfataWebBD`) **
   Este o aplicație simplă realizată în Node.js (Express). Are **rol strict demonstrativ**, pentru a vizualiza mai ușor datele din tabele direct din browser, fără a rula manual interogări în terminal.
   *(Notă: Focusul proiectului este pe partea de SQL, interfața web fiind construită ca un agent AI).*

## Cum rulezi proiectul

Dacă vrei să testezi proiectul local, urmează acești pași:

1. **Baza de Date:** Conectează-te la Oracle (ex: prin SQL Developer) și rulează `BazaDeDate/script.sql` pentru a crea și popula tabelele.
2. **Conexiunea la Web:** Intră în folderul `InterfataWebBD` și creează un fișier `.env` în care pui datele tale de la baza de date:
   ```env
   DB_USER=utilizatorul_tau
   DB_PASSWORD=parola_ta
   DB_CONNECT_STRING=localhost/XE  
   ```
3. **Pornirea Serverului:** Deschide un terminal în `InterfataWebBD` și rulează `npm install` urmat de `npm start`.
4. Gata! Accesează interfața în browser la `http://localhost:3000`.
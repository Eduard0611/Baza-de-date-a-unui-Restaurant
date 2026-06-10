drop table furnizori cascade constraints;
drop table ingrediente cascade constraints;
drop table produse cascade constraints;
drop table comenzi cascade constraints;
drop table angajati cascade constraints;
drop table ospatari cascade constraints;
drop table bucatari cascade constraints;
drop table clienti cascade constraints;
drop table functii cascade constraints;
drop table reteta_produs cascade constraints;
drop table detalii_comanda cascade constraints;
drop table produse_bucatari cascade constraints;


-- 1. Tabel Furnizori
create table furnizori (
    id_furnizor int primary key,
    nume_furnizor varchar2(255) not null,
    cui varchar2(50) unique not null,
    telefon varchar2(15) unique not null,
    email varchar2(255) unique not null check (email like '%@%'),
    adresa varchar2(255)
);


-- 2. Tabel Ingrediente
create table ingrediente (
    id_ingredient int primary key,
    id_furnizor int,
    denumire_ingredient varchar2(255) unique not null,
    unitate_masura varchar2(15) not null check (unitate_masura in ('g', 'kg', 'ml', 'l', 'bucati')), 
    cantitate_stoc decimal(10,3) not null check(cantitate_stoc >= 0),
    pret_unitar decimal(10, 2) not null check(pret_unitar > 0),
    
    
    constraint fk_furnizor_ingredient foreign key (id_furnizor) 
        references furnizori(id_furnizor) on delete set null
);


-- 3. Tabel Produse 
create table produse(
    id_produs int primary key,
    denumire_produs varchar2(255) unique not null,
    pret decimal(10, 2) not null check (pret > 0),
    categorie varchar2(255) not null
        check (categorie in ('mic dejun', 'preparate din peste', 'preparate din vita', 
            'preparate din pui', 'preparate din porc', 'paste', 'supe', 'pizza', 'deserturi',  'bauturi'))
);


-- 4. Tabel Clienti 
create table clienti (
    id_client int primary key, 
    nume varchar2(255) not null,
    prenume varchar2(255) not null,
    telefon varchar2(15) not null,
    email varchar2(255) unique not null check (email like '%@%')
);


-- 5. Tabel Functii
create table functii(
    id_functie int primary key, 
    denumire_functie varchar2(255) unique not null,
    salariu_minim int not null check (salariu_minim > 0),
    salariu_maxim int not null check (salariu_maxim > 0),
    
    constraint salariu_min_max check (salariu_minim <= salariu_maxim)
);


-- 6. Tabel Angajati 
create table angajati (
    id_angajat int primary key, 
    id_functie int not null,
    nume varchar2(255) not null,
    prenume varchar2(255) not null,
    data_angajarii date not null,
    telefon varchar2(15) not null,
    email varchar2(255) unique not null check (email like '%@%'),
    salariu int not null check (salariu > 0),
    
    constraint fk_angajat_functie foreign key (id_functie) references functii(id_functie) on delete cascade
);


-- 7. Tabel Ospatari 
create table ospatari (
    id_angajat int primary key,
    zona_servire varchar2(255) not null check (zona_servire in ('sala principala', 'bar', 'terasa', 'separeu')),
    nivel_experienta varchar2(255) not null check (nivel_experienta in ('junior', 'intermediar', 'profesionist')),
    
    constraint fk_ospatar_angajat foreign key (id_angajat) references angajati(id_angajat) on delete cascade
);


-- 8. Tabel Bucatari 
create table bucatari (
    id_angajat int primary key, 
    specializare varchar2(255) not null check (specializare in ('mic dejun', 'preparate din peste', 'preparate din vita',
        'preparate din pui', 'preparate din porc', 'paste', 'supe', 'pizza', 'deserturi')),
    nivel_calificare varchar2(255) not null check (nivel_calificare in ('junior', 'intermediar', 'profesionist')),
    
    constraint fk_bucatar_angajat foreign key (id_angajat) references angajati(id_angajat) on delete cascade
);

-- 9. Tabel Comenzi 
create table comenzi (
    id_comanda int primary key,
    id_client int not null,
    id_angajat int not null,
    data_comanda date not null,
    valoare_totala decimal(10, 2) not null check (valoare_totala >= 0),
    
    constraint fk_comanda_client foreign key (id_client) references clienti(id_client) on delete cascade,
    constraint fk_comanda_ospatar foreign key (id_angajat) references ospatari(id_angajat) on delete cascade  
);


-- 10. Tabel asociativ Reteta_Produs
create table reteta_produs (
    id_produs int,
    id_ingredient int, 
    cantitate decimal(10, 2) not null check (cantitate > 0),
    unitate_masura varchar2(15) not null check (unitate_masura in ('g', 'kg', 'ml', 'l', 'bucati')), 
    primary key (id_produs, id_ingredient),
    
    constraint fk_rp_produse foreign key (id_produs) references produse(id_produs) on delete cascade,
    constraint fk_rp_ingrediente foreign key (id_ingredient) references ingrediente(id_ingredient) on delete cascade
);


-- 11. Tabel asociativ Detalii_Comanda
create table detalii_comanda(
    id_produs int,
    id_comanda int,
    cantitate int not null check (cantitate > 0),
    primary key (id_produs, id_comanda),
    
    constraint fk_dc_produse foreign key (id_produs) references produse(id_produs) on delete cascade,
    constraint fk_dc_comenzi foreign key (id_comanda) references comenzi(id_comanda) on delete cascade
);


-- 12. Tabel asociativ Produse_Bucatari 
create table produse_bucatari (
    id_produs int, 
    id_angajat int,
    primary key (id_produs, id_angajat),

    constraint fk_pb_produse foreign key (id_produs) references produse(id_produs) on delete cascade,
    constraint fk_pb_bucatari foreign key (id_angajat) references bucatari(id_angajat) on delete cascade
);
  

-- Populare tabele

-- 1. Furnizori 
insert into furnizori values (1, 'Selgros', 'RO322588', '0784733633', 'contact@selgros.ro', 'Bucuresti Strada Mihai Eminescu nr. 54');
insert into furnizori values (2, 'Metro Cash and Carry', 'RO456324', '0763781234', 'info@metro.ro', 'Timisoara Strada George Enescu nr. 78');
insert into furnizori values (3, 'Coca Cola Romania', 'RO456321', '0787321566', 'contact@cocacola.ro', 'Craiova Strada Traian nr. 85');
insert into furnizori values (4, 'Malorex', 'RO456123', '0734567123', 'info@malorex.ro', 'Slatina Strada Mihai Viteazu nr. 34');
insert into furnizori values (5, 'Legume si Fructe', 'RO786122', '0764567324', 'contact@legumefructe.ro', 'Filiasi Strada Veseliei nr. 123');
insert into furnizori values (6, 'Drinks and More', 'RO456129', '0783123765', 'info@drinksandmore.ro', 'Cluj Napoca Strada Fulger nr. 56');
insert into furnizori values (7, 'Vel Pitar', 'RO452176', '0754231453', 'clienti@velpitar.ro', 'Ramnicu Valcea Strada Generalului nr. 67');
insert into furnizori values (8, 'Lactate si Branzeturi', 'RO765923', '0783657214', 'info@lapte.ro', 'Filiasi Strada Stefan cel Mare nr. 23');
insert into furnizori values (9, 'Fuchs Condimente', 'RO543912', '0784562176', 'contact@fuchs.ro', 'Slatina Strada Piperului nr. 45');
insert into furnizori values (10, 'Marigab', 'RO345987', '0712453768', 'clienti@contact.ro', 'Turceni Strada Sanatatii nr. 65');


-- 2. Ingrediente
insert into ingrediente values (1, 1, 'Oua de gaina', 'bucati', 50, 3);
insert into ingrediente values (2, 1, 'Bacon', 'kg', 2, 25);
insert into ingrediente values (3, 1, 'Ulei de florea soarelui', 'l', 10, 10);
insert into ingrediente values (4, 2, 'Pastrav proastpat', 'bucati', 10, 30);
insert into ingrediente values (5, 2, 'Antricot de vita', 'kg', 10, 60);
insert into ingrediente values (6, 3, 'Sprite', 'l', 15, 5);
insert into ingrediente values (7, 3, 'Coca Cola 0.25l sticla', 'bucati', 50, 5);
insert into ingrediente values (8, 4, 'Ceafa de porc', 'kg', 30, 33);
insert into ingrediente values (9, 4, 'Ciocolata', 'kg', 5, 30);
insert into ingrediente values (10, 5, 'Rosii', 'kg', 15, 9);
insert into ingrediente values (11, 5, 'Menta', 'kg', 1, 20);
insert into ingrediente values (12, 6, 'Aperol', 'l', 5, 40);
insert into ingrediente values (13, 7, 'Pesmet', 'kg', 5, 10);
insert into ingrediente values (14, 7, 'Spaghetii', 'kg', 10, 10);
insert into ingrediente values (15, 7, 'Faina Alba de Grau', 'kg', 20, 5);
insert into ingrediente values (16, 8, 'Pecorrino Romano', 'kg', 5, 35);
insert into ingrediente values (17, 9, 'Piper', 'kg', 5, 20);
insert into ingrediente values (18, 9, 'Sare', 'kg', 5, 15);
insert into ingrediente values (19, 10, 'Piept de pui', 'kg', 20, 30);


-- 3. Produse 
insert into produse values (1, 'Omleta', 20, 'mic dejun');
insert into produse values (2, 'Pastrav la gratar', 60, 'preparate din peste');
insert into produse values (3, 'Antricot de vita', 110, 'preparate din vita');
insert into produse values (4, 'Snitel de pui', 40, 'preparate din pui');
insert into produse values (5, 'Ceafa de porc la gratar', 50, 'preparate din porc');
insert into produse values (6, 'Paste Carbonara', 60, 'paste');
insert into produse values (7, 'Supa crema de rosii', 30, 'supe');
insert into produse values (8, 'Lava Cake', 35, 'deserturi') ;
insert into produse values (9, 'Aperol Spritz', 30, 'bauturi');
insert into produse values (10, 'Coca Cola', 15, 'bauturi');
insert into produse values (11, 'Pizza cu piept de pui', 40, 'pizza');
  
-- 4. Reteta_Produs  

-- Omleta 
insert into reteta_produs values (1, 1, 3, 'bucati'); -- Oua de gaina 
insert into reteta_produs values (1, 2, 50, 'g'); -- Bacon 
insert into reteta_produs values (1, 3, 5, 'ml'); -- Ulei de floare soarelui

-- Pastrav 
insert into reteta_produs values (2, 4, 1, 'bucati'); -- Pastrav
insert into reteta_produs values (2, 17, 5, 'g'); -- Piper
insert into reteta_produs values (2, 18, 5, 'g'); -- Sare

-- Antricot de vita
insert into reteta_produs values (3, 5, 300, 'g'); --  Antricot de vita
insert into reteta_produs values (3, 17, 5, 'g'); -- Piper
insert into reteta_produs values (3, 18, 5, 'g'); -- Sare

-- Snitel de pui 
insert into reteta_produs values (4, 19, 250, 'g'); -- Piept de pui
insert into reteta_produs values (4, 1, 3, 'bucati'); -- Oua de gaina  
insert into reteta_produs values (4, 13, 20, 'g'); -- Pesmet 
insert into reteta_produs values (4, 18, 5, 'g'); -- Sare  
  
-- Ceafa de porc 
insert into reteta_produs values (5, 8, 250, 'g'); -- Ceafa de porc 
insert into reteta_produs values (5, 17, 5, 'g'); -- Piper
insert into reteta_produs values (5, 18, 5, 'g'); -- Sare 
  
-- Paste Carbonara 
insert into reteta_produs values (6, 14, 150, 'g'); -- Spaghetii
insert into reteta_produs values (6, 16, 30, 'g'); -- Pecorrino Romano
insert into reteta_produs values (6, 2, 100, 'g'); -- Bacon 

-- Supa crema de rosii
insert into reteta_produs values (7, 10, 200, 'g'); -- Rosii
insert into reteta_produs values (7, 3, 5, 'ml'); -- Ulei de floare soarelui
insert into reteta_produs values (7, 17, 5, 'g'); -- Piper
insert into reteta_produs values (7, 18, 5, 'g'); -- Sare  

-- Lava Cake 
insert into reteta_produs values (8, 9, 150, 'g'); -- Ciocolata
insert into reteta_produs values (8, 15, 150, 'g'); -- Faina alba de grau
insert into reteta_produs values (8, 1, 2, 'bucati'); -- Oua de gaina  

-- Aperol Spritz 
insert into reteta_produs values (9, 12, 50, 'ml'); -- Aperol
insert into reteta_produs values (9, 6, 150, 'ml'); -- Sprite 
insert into reteta_produs values (9, 11, 15, 'g'); -- Menta  

-- Coca Cola
insert into reteta_produs values (10, 7, 1, 'bucati'); -- Coca Cola

-- Pizza cu piept de pui
insert into reteta_produs values (11, 15, 300, 'g'); -- Faina alba de grau
insert into reteta_produs values (11, 3, 20, 'ml'); -- Ulei de floare soarelui
insert into reteta_produs values (11, 19, 250, 'g'); -- Piept de pui
insert into reteta_produs values (11, 10, 200, 'g'); -- Rosii
insert into reteta_produs values (11, 17, 5, 'g'); -- Piper
insert into reteta_produs values (11, 18, 10, 'g'); -- Sare


-- 5. Functii
insert into functii values (1, 'Manager Restaurant', 6100, 11000);
insert into functii values (2, 'Sef de sala', 4100, 7100);
insert into functii values (3, 'Ospatar', 3100, 6100);
insert into functii values (4, 'Bucatar Sef', 5300, 8500);
insert into functii values (5, 'Bucatar ', 4300, 7500);
insert into functii values (6, 'Contabil', 3200, 5400);
insert into functii values (7, 'Personal Curatenie', 2100, 4100);
insert into functii values (8, 'Hostess', 3000, 4500);
insert into functii values (9, 'Spalator Vase', 2200, 4900);
insert into functii values (10, 'Personal Intretinere', 2500, 4800);


-- 6. Clienti
insert into clienti values (1, 'Popescu', 'Marian', '0785632580', 'popescu.marian@gmail.com');
insert into clienti values (2, 'Munteanu', 'Robert', '0730838230', 'munteanu.robert@gmail.com');
insert into clienti values (3, 'Radoi', 'Andrei', '0767890233', 'radoi.andrei@gmail.com');
insert into clienti values (4, 'Balan', 'Ciprian', '0773233480', 'balan.ciprian@gmail.com');
insert into clienti values (5, 'Popa', 'Mihaela', '0789056744', 'popa.mihaela@gmail.com');
insert into clienti values (6, 'Burtea', 'Vlad', '0789223675', 'burtea.vlad@gmail.com');
insert into clienti values (7, 'Dumitriu', 'Alexandru', '0785730883', 'dumitriu.alexandru@gmail.com');
insert into clienti values (8, 'Linca', 'Razvan', '0786234987', 'linca.razvan@gmail.com');
insert into clienti values (9, 'Lungu', 'Luca', '0787345588', 'lungu.luca@gmail.com');
insert into clienti values (10, 'Iovan', 'Razvan', '0787234577', 'iovan.razvan@gmail.com');

-- 7. Angajati

-- Manager
insert into angajati values (1, 1, 'Gavrila', 'Marcel', to_date('10-02-2015', 'DD-MM-YYYY'),'0785730633', 'gavrila.marcel@gmail.com', 10000);

-- Ospatari
insert into angajati values (2, 2, 'Popescu', 'Ion', to_date('15-06-2018', 'DD-MM-YYYY'), '0733450950', 'popescu.ion@gmail.com', 5900); -- Ospatar Sef
insert into angajati values (3, 3, 'Toma', 'Stefan', to_date('21-06-2019', 'DD-MM-YYYY'), '0785630833', 'toma.stefan@gmail.com', 6000);
insert into angajati values (4, 3, 'Ionescu', 'Cristian', to_date('11-03-2018', 'DD-MM-YYYY'), '0756789890', 'ionescu.cristian@gmail.com', 5900);
insert into angajati values (5, 3, 'Popa', 'Elena', to_date('20-03-2020', 'DD-MM-YYYY'), '0722111222', 'popa.elena@gmail.com', 4500);
  
-- Bucatari
insert into angajati values (6, 4, 'Radu', 'Andrei', to_date('05-08-2021', 'DD-MM-YYYY'), '0744333444', 'radu.andrei@gmail.com', 7000); -- Bucatar Sef
insert into angajati values (7, 5, 'Georgescu', 'Mihaela', to_date('12-09-2019', 'DD-MM-YYYY'), '0766555666', 'georgescu.mihaela@gmail.com', 5400);
insert into angajati values (8, 5, 'Stanciu', 'Victor', to_date('01-04-2022', 'DD-MM-YYYY'), '0788777888', 'stanciu.victor@gmail.com', 6000);  
insert into angajati values (9, 5, 'Mihailescu', 'Cosmin', to_date('05-09-2019', 'DD-MM-YYYY'), '0778578345', 'mihailescu.cosmin@gmail.com', 5900);  

-- Alte functii
insert into angajati values (10, 6, 'Vasilescu', 'Ana', to_date('18-11-2017', 'DD-MM-YYYY'), '0711999000', 'vasilescu.ana@gmail.com', 4000); -- Contabil
insert into angajati values (11, 7, 'Dinu', 'Gheorghe', to_date('25-01-2022', 'DD-MM-YYYY'), '0755123456', 'dinu.gheorghe@gmail.com', 2800); -- Personal Curatanie
insert into angajati values (12, 8, 'Popescu', 'Maria', to_date('03-07-2023', 'DD-MM-YYYY'), '0733888999', 'popescu.maria@gmail.com', 3500); -- Hostess
insert into angajati values (13, 9, 'Mihai', 'Florin', to_date('14-05-2023', 'DD-MM-YYYY'), '0799888777', 'mihai.florin@gmail.com', 2500); -- Spalator Vase
insert into angajati values (14, 10, 'Ion', 'Cristian', to_date('29-02-2024', 'DD-MM-YYYY'), '0777666555', 'ion.cristian@gmail.com', 3000); -- Intretinere


-- 8. Ospatari 
insert into ospatari values (2, 'sala principala', 'profesionist');
insert into ospatari values (3, 'bar', 'junior');
insert into ospatari values (4, 'terasa', 'intermediar');
insert into ospatari values (5, 'separeu', 'intermediar');

-- 9. Bucatari
insert into bucatari values (6, 'preparate din vita', 'profesionist');
insert into bucatari values (7, 'pizza', 'intermediar');
insert into bucatari values (8, 'paste', 'intermediar');
insert into bucatari values (9, 'deserturi', 'junior');


-- 10. Produse_Bucatari
insert into produse_bucatari values (2, 6);
insert into produse_bucatari values (3, 6);
insert into produse_bucatari values (4, 6);
insert into produse_bucatari values (5, 6);
insert into produse_bucatari values (1, 6);
insert into produse_bucatari values (11, 7);
insert into produse_bucatari values (7, 7);
insert into produse_bucatari values (4, 7);
insert into produse_bucatari values (1, 7);
insert into produse_bucatari values (8, 7);
insert into produse_bucatari values (6, 8);
insert into produse_bucatari values (1, 8);
insert into produse_bucatari values (2, 8);
insert into produse_bucatari values (4, 8);
insert into produse_bucatari values (7, 8);
insert into produse_bucatari values (8, 9);
insert into produse_bucatari values (5, 9);
insert into produse_bucatari values (7, 9);
insert into produse_bucatari values (6, 9);


-- 11. Comenzi 

insert into comenzi values (1, 1, 2, to_date('01-01-2026','DD-MM-YYYY'), 90);
insert into comenzi values (2, 2, 3, to_date('02-01-2026','DD-MM-YYYY'), 60);
insert into comenzi values (3, 3, 4, to_date('03-01-2026','DD-MM-YYYY'), 110);
insert into comenzi values (4, 4, 5, to_date('04-01-2026','DD-MM-YYYY'), 75);
insert into comenzi values (5, 5, 2, to_date('05-01-2026','DD-MM-YYYY'), 120);
insert into comenzi values (6, 6, 3, to_date('06-01-2026','DD-MM-YYYY'), 30);
insert into comenzi values (7, 7, 4, to_date('07-01-2026','DD-MM-YYYY'), 80);
insert into comenzi values (8, 8, 5, to_date('08-01-2026','DD-MM-YYYY'), 140);
insert into comenzi values (9, 9, 2, to_date('01-02-2026','DD-MM-YYYY'), 45);
insert into comenzi values (10, 10, 3, to_date('02-02-2026','DD-MM-YYYY'), 100);
insert into comenzi values (11, 1, 4, to_date('03-02-2026','DD-MM-YYYY'), 60);
insert into comenzi values (12, 2, 5, to_date('04-02-2026','DD-MM-YYYY'), 90);
insert into comenzi values (13, 3, 2, to_date('05-02-2026','DD-MM-YYYY'), 50);
insert into comenzi values (14, 4, 3, to_date('06-02-2026','DD-MM-YYYY'), 85);
insert into comenzi values (15, 5, 4, to_date('07-02-2026','DD-MM-YYYY'), 150);


-- 12. Detalii_Comanda

insert into detalii_comanda values (1,1,1);
insert into detalii_comanda values (4,1,1);
insert into detalii_comanda values (10,1,2);

insert into detalii_comanda values (6,2,1);

insert into detalii_comanda values (3,3,1);

insert into detalii_comanda values (8,4,1);
insert into detalii_comanda values (1,4,2);

insert into detalii_comanda values (2,5,2);

insert into detalii_comanda values (7,6,1);

insert into detalii_comanda values (11,7,2);

insert into detalii_comanda values (3,8,1);
insert into detalii_comanda values (10,8,2);

insert into detalii_comanda values (10,9,3);

insert into detalii_comanda values (5,10,2);

insert into detalii_comanda values (6,11,1);

insert into detalii_comanda values (2,12,1);
insert into detalii_comanda values (10,12,2);

insert into detalii_comanda values (5,13,1);

insert into detalii_comanda values (8,14,1);
insert into detalii_comanda values (5,14,1);

insert into detalii_comanda values (3,15,1);
insert into detalii_comanda values (1,15,2);

commit;


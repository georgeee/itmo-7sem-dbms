
    INSERT INTO Country (Id, Code) VALUES
      (1, 'ru'), (2, 'uk'), (3, 'de');
    INSERT INTO I18n (EntityType, EntityId, Key, Lang, Value) VALUES
      ('Country', 1, 'Name', 'ru', 'Россия'),
      ('Country', 1, 'Name', 'en', 'Russia'),
      ('Country', 1, 'Name', 'ge', 'Russland'),
      ('Country', 2, 'Name', 'ru', 'Великобритания'),
      ('Country', 2, 'Name', 'en', 'Great Britain'),
      ('Country', 2, 'Name', 'ge', 'Großbritannien'),
      ('Country', 3, 'Name', 'ru', 'Германия'),
      ('Country', 3, 'Name', 'en', 'Germany'),
      ('Country', 3, 'Name', 'ge', 'Deutschland');
    INSERT INTO City (Id, CountryId) VALUES
      (1, 1), (2, 1), (3, 2), (4, 3);
    
    INSERT INTO I18n (EntityType, EntityId, Key, Lang, Value) VALUES
      ('City', 1, 'Name', 'ru', 'Санкт-Петербург'),
      ('City', 1, 'Name', 'en', 'St. Petersburg'),
      ('City', 1, 'Name', 'ge', 'St. Petersburg'),
      ('City', 2, 'Name', 'ru', 'Москва'),
      ('City', 2, 'Name', 'en', 'Moscow'),
      ('City', 2, 'Name', 'ge', 'Moskau'),
      ('City', 3, 'Name', 'ru', 'Лондон'),
      ('City', 3, 'Name', 'en', 'London'),
      ('City', 3, 'Name', 'ge', 'London'),
      ('City', 4, 'Name', 'ru', 'Берлин'),
      ('City', 4, 'Name', 'en', 'Berlin'),
      ('City', 4, 'Name', 'ge', 'Berlin');
    
    INSERT INTO Venue (Id, CityId) VALUES
    	(1, 1), (2, 1), (3, 2), (4, 3), (5, 4);
    
    INSERT INTO I18n (EntityType, EntityId, Key, Lang, Value) VALUES
      ('Venue', 1, 'Name', 'ru', 'Мариинский театр'),
      ('Venue', 1, 'Name', 'en', 'Mariinsky theatre'),
      ('Venue', 1, 'Name', 'ge', 'Mariinski-Theater'),
      ('Venue', 2, 'Name', 'ru', 'Санкт-Петербургская Филармония'),
      ('Venue', 2, 'Name', 'en', 'Saint Petersburg Philharmonia'),
      ('Venue', 2, 'Name', 'ge', 'Sankt Petersburger Philharmonie'),
      ('Venue', 3, 'Name', 'ru', 'Большой театр'),
      ('Venue', 3, 'Name', 'en', 'Bolshoi theatre'),
      ('Venue', 3, 'Name', 'ge', 'Bolschoi-Theater'),
      ('Venue', 4, 'Name', 'ru', 'Ковент-Гарден'),
      ('Venue', 4, 'Name', 'en', 'Royal Opera House'),
      ('Venue', 4, 'Name', 'ge', 'Royal Opera House'),
      ('Venue', 5, 'Name', 'ru', 'Немецкая опера в Берлине'),
      ('Venue', 5, 'Name', 'en', 'German Opera House in Berlin'),
      ('Venue', 5, 'Name', 'ge', 'Deutsche Oper Berlin'),
      ('Venue', 1, 'Address', 'ru', 'Театральная площадь, 1'),
      ('Venue', 1, 'Address', 'en', '1 Theatre Square'),
      ('Venue', 1, 'Address', 'ge', 'Theaterplatz, 1'),
      ('Venue', 2, 'Address', 'ru', 'Михайловская ул., 2'),
      ('Venue', 2, 'Address', 'en', 'Mikhaylovskaya ul., 2'),
      ('Venue', 2, 'Address', 'ge', 'Michajlowskaja-Straße 2'),
      ('Venue', 3, 'Address', 'ru', 'Театральная площадь, 1'),
      ('Venue', 3, 'Address', 'en', '1 Theatre Square'),
      ('Venue', 3, 'Address', 'ge', 'Theaterplatz, 1'),
      ('Venue', 4, 'Address', 'ru', 'Bow St, London WC2E 9DD'),
      ('Venue', 4, 'Address', 'en', 'Bow St, London WC2E 9DD'),
      ('Venue', 4, 'Address', 'ge', 'Bow St, London WC2E 9DD'),
      ('Venue', 5, 'Address', 'ru', 'Биссмаркштрассе, 35'),
      ('Venue', 5, 'Address', 'en', 'Bismark street 35, 10627 Berlin, Germany'),
      ('Venue', 5, 'Address', 'ge', 'Bismarckstraße 35, 10627 Berlin, Germany');
    
    INSERT INTO Composer (Id, DateOfBirth, DateOfDeath) VALUES
      	(1, '1839-03-21', '1881-03-28'),
      	(2, '1813-05-22', '1883-02-13'),
      	(3, '1840-05-07', '1893-11-06'),
      	(4, '1891-04-23', '1953-03-05');
    
    INSERT INTO I18n (EntityType, EntityId, Key, Lang, Value) VALUES
      ('Composer', 1, 'Name', 'ru', 'Мусоргский, Модест Петрович'),
      ('Composer', 1, 'Name', 'en', 'Modest Mussorgsky'),
      ('Composer', 1, 'Name', 'ge', 'Modest Petrowitsch Mussorgski'),
      ('Composer', 2, 'Name', 'ru', 'Рихард Вагнер'),
      ('Composer', 2, 'Name', 'en', 'Richard Wagner'),
      ('Composer', 2, 'Name', 'ge', 'Richard Wagner'),
      ('Composer', 3, 'Name', 'ru', 'Чайковский, Пётр Ильич'),
      ('Composer', 3, 'Name', 'en', 'Pyotr Ilyich Tchaikovsky'),
      ('Composer', 3, 'Name', 'ge', 'Pjotr Iljitsch Tschaikowski'),
      ('Composer', 4, 'Name', 'ru', 'Прокофьев, Сергей Сергеевич'),
      ('Composer', 4, 'Name', 'en', 'Sergei Prokofiev'),
      ('Composer', 4, 'Name', 'ge', 'Sergei Prokofjew');
    
    INSERT INTO Piece (Id, Type, ComposerId, GeneralPieceId) VALUES
    	(1, 'Ballet', 3, NULL), (2, 'Opera', 2, NULL), (3, 'Opera', 1, NULL), (4, NULL, 3, NULL),
      (5, 'Symphony', 4, NULL), (6, 'Ballet', 4, NULL), (7, NULL, 4, 6);
    
    INSERT INTO I18n (EntityType, EntityId, Key, Lang, Value) VALUES
      ('Piece', 1, 'Name', 'ru', 'Спящая красавица'),
      ('Piece', 1, 'Name', 'en', 'The Sleeping Beauty'),
      ('Piece', 1, 'Name', 'ge', 'Dornröschen'),
      ('Piece', 2, 'Name', 'ru', 'Валькирия'),
      ('Piece', 2, 'Name', 'en', 'The Valkyrie'),
      ('Piece', 2, 'Name', 'ge', 'Die Walküre'),
      ('Piece', 3, 'Name', 'ru', 'Хованщина'),
      ('Piece', 3, 'Name', 'en', 'Khovanshchina'),
      ('Piece', 3, 'Name', 'ge', 'Chowanschtschina'),
      ('Piece', 4, 'Name', 'ru', 'Ромео и Джульетта, увертюра-фантазия'),
      ('Piece', 4, 'Name', 'en', 'Romeo and Juliet, an overture-fantasy'),
      ('Piece', 4, 'Name', 'ge', 'Romeo und Julia, eine Fantasie-Ouvertüre'),
      ('Piece', 5, 'Name', 'ru', 'Симфония № 2'),
      ('Piece', 5, 'Name', 'en', 'Symphony No. 2 in D minor'),
      ('Piece', 5, 'Name', 'ge', 'Sinfonie No. 2'),
      ('Piece', 6, 'Name', 'ru', 'Ромео и Джульетта'),
      ('Piece', 6, 'Name', 'en', 'Romeo and Juliet'),
      ('Piece', 6, 'Name', 'ge', 'Romeo und Julia'),
      ('Piece', 7, 'Name', 'ru', 'Отрывки из балета "Ромео и Джульетта"'),
      ('Piece', 7, 'Name', 'en', 'Excerpts from ballet "Romeo and Juliet"'),
      ('Piece', 7, 'Name', 'ge', 'Auszüge aus Ballett "Romeo und Julia"');
    
    INSERT INTO Performer (Id) VALUES
    	(1), (2), (3), (4), (5);
    
    INSERT INTO I18n (EntityType, EntityId, Key, Lang, Value) VALUES
      ('Performer', 1, 'Name', 'ru', 'Гергиев, Валерий Абисалович'),
      ('Performer', 1, 'Name', 'en', 'Valery Gergiev'),
      ('Performer', 1, 'Name', 'ge', 'Waleri Gergijev'),
      ('Performer', 2, 'Name', 'ru', 'Оркестр Мариинского театра'),
      ('Performer', 2, 'Name', 'en', 'Orchestra of Mariinsky theatre'),
      ('Performer', 2, 'Name', 'ge', 'Das Orchester des Mariinski-Theater'),
      ('Performer', 3, 'Name', 'ru', 'Ольга Бородина'),
      ('Performer', 3, 'Name', 'en', 'Olga Borodina'),
      ('Performer', 3, 'Name', 'ge', 'Olga Borodina'),
      ('Performer', 4, 'Name', 'ru', 'Синайский, Василий Серафимович'),
      ('Performer', 4, 'Name', 'en', 'Vassily Sinaysky'),
      ('Performer', 4, 'Name', 'ge', 'Wassili Sinaiski'),
      ('Performer', 5, 'Name', 'ru', 'Заслуженный оркестр Санкт-Петербургской Филармонии'),
      ('Performer', 5, 'Name', 'en', 'Honored Orchestra of Saint-Petersburg Philharmonia'),
      ('Performer', 5, 'Name', 'ge', 'Geehrt Orchester des Sankt Petersburger Philharmonie');
    
    INSERT INTO Event (Id, Time, VenueId) VALUES
      (1, '2016-01-27 19:00 MSK', 1);
    
    INSERT INTO EventPiece (EventId, PieceId) VALUES
      (1, 3); -- Khovanshschina
    
    INSERT INTO EventPerformer (Id, EventId, PerformerId, Instrument) VALUES
      (1, 1, 1, 'Conductor'), (2, 1, 3, 'Voice');
    
    INSERT INTO I18n (EntityType, EntityId, Key, Lang, Value) VALUES
      ('EventPerformer', 2, 'Role', 'ru', 'Марфа'),
      ('EventPerformer', 2, 'Role', 'en', 'Marfa'),
      ('EventPerformer', 2, 'Role', 'ge', 'Marfa');
    
    INSERT INTO PortalUser (Id, Login, Name) VALUES
      (1, 'georgeee', 'George Agapov'),
      (2, 'jagger', 'Mick Jagger'),
      (3, 'johny', 'John Lennon');
    
    INSERT INTO Subscription (EntityType, EntityId, UserId) VALUES
      ('Composer', 2, 1), ('Event', 2, 1), ('Performer', 4, 1), ('Piece', 6, 1);
    
    INSERT INTO Event (Id, Time, VenueId) VALUES
      (2, '2015-02-03 20:00 MSK', 2),
      (3, '2016-02-27 19:00 MSK', 1),
      (4, '2015-02-17 19:00 MSK', 1),
      (5, '2015-07-15 19:00 UTC', 4);
    INSERT INTO EventPiece (EventId, PieceId) VALUES
      (2, 4), -- Romeo & Juliet, fantasy-overture
      (2, 5), -- Symphony no. 2 by Prokofiev
      (5, 5), -- Symphony no. 2 by Prokofiev
      (2, 7), -- Excerpts from ballet Romeo and Juliet
      (3, 2), -- Walküre
      (4, 2); -- Walküre
    
    INSERT INTO EventPerformer (Id, EventId, PerformerId, Instrument) VALUES
     (3, 2, 4, 'Conductor'),
     (4, 3, 1, 'Conductor'), (5, 3, 3, 'Voice'),
     (6, 4, 1, 'Conductor'),
     (7, 5, 4, 'Conductor');
    INSERT INTO I18n (EntityType, EntityId, Key, Lang, Value) VALUES
      ('EventPerformer', 5, 'Role', 'ru', 'Брунгильда'),
      ('EventPerformer', 5, 'Role', 'en', 'Brünnhilde'),
      ('EventPerformer', 5, 'Role', 'ge', 'Brünnhilde');
    
    SELECT cancel_event (2) ;
    
    
    INSERT INTO Performer (Id) VALUES
      (6), (7);
    
    INSERT INTO I18n (EntityType, EntityId, Key, Lang, Value) VALUES
      ('Performer', 6, 'Name', 'en', 'Yury Temirkanov');

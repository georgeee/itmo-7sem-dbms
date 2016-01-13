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
  	(3, '1840-05-07', '1893-11-06');

INSERT INTO I18n (EntityType, EntityId, Key, Lang, Value) VALUES
  ('Composer', 1, 'Name', 'ru', 'Мусоргский, Модест Петрович'),
  ('Composer', 1, 'Name', 'en', 'Modest Mussorgsky'),
  ('Composer', 1, 'Name', 'ge', 'Modest Petrowitsch Mussorgski'),
  ('Composer', 2, 'Name', 'ru', 'Рихард Вагнер'),
  ('Composer', 2, 'Name', 'en', 'Richard Wagner'),
  ('Composer', 2, 'Name', 'ge', 'Richard Wagner'),
  ('Composer', 3, 'Name', 'ru', 'Чайковский, Пётр Ильич'),
  ('Composer', 3, 'Name', 'en', 'Pyotr Ilyich Tchaikovsky'),
  ('Composer', 3, 'Name', 'ge', 'Pjotr Iljitsch Tschaikowski');

INSERT INTO Piece (Id, Type, ComposerId, GeneralPieceId) VALUES
	(1, 'Ballet', 3, NULL), (2, 'Opera', 2, NULL), (3, 'Opera', 1, NULL), (4, NULL, 3, NULL);

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
  ('Piece', 4, 'Name', 'ge', 'Romeo und Julia, eine Fantasie-Ouvertüre');

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

INSERT INTO Event (Id, Time, VenueId, PieceId) VALUES
  (1, '2016-01-27 19:00 MSK', 1, 3), -- Khovanshschina
  (2, '2016-02-03 20:00 MSK', 2, 4); -- Romeo & Juliet

INSERT INTO EventPerformer (Id, EventId, PerformerId, Instrument) VALUES
  (1, 1, 1, 'Conductor'), (2, 1, 3, 'Voice'), (3, 2, 4, 'Conductor');

INSERT INTO I18n (EntityType, EntityId, Key, Lang, Value) VALUES
  ('EventPerformer', 2, 'Role', 'ru', 'Марфа'),
  ('EventPerformer', 2, 'Role', 'en', 'Marfa'),
  ('EventPerformer', 2, 'Role', 'ge', 'Marfa');

INSERT INTO PortalUser (Id, Login, Name) VALUES
  (1, 'georgeee', 'George Agapov'),
  (2, 'jagger', 'Mick Jagger'),
  (3, 'johny', 'John Lennon');

INSERT INTO Subscription (EntityType, EntityId, UserId) VALUES
  ('Composer', 2, 1), ('Event', 2, 1);

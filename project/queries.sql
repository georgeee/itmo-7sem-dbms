-- Users that have subscription for piece and no for composer

SELECT s.UserId, p.ComposerId FROM Subscription s
JOIN Piece p ON p.Id = s.EntityId AND s.EntityType = 'Piece'
LEFT JOIN Subscription s2 ON s2.EntityId = p.ComposerId AND s.EntityType = 'Composer' AND s2.UserId = s.UserId
WHERE s2.EntityId IS NULL;

-- Missing non-optional translations
(SELECT a.*, l.Lang FROM
  (
    SELECT 'Composer'::I18nEntity as EntityType, 'Name'::I18nKey as Key, Id as EntityId FROM Composer
    UNION
    SELECT 'Piece', 'Name', Id FROM Piece
    UNION
    SELECT 'City', 'Name', Id FROM City
    UNION
    SELECT 'Country', 'Name', Id FROM Country
    UNION
    SELECT 'Venue', 'Name', Id FROM Venue
    UNION
    SELECT 'Venue', 'Address', Id FROM Venue
    UNION
    SELECT 'Performer', 'Name', Id FROM Performer
  ) a
  CROSS JOIN (SELECT DISTINCT Lang FROM I18n) l
)
EXCEPT
SELECT EntityType, Key, EntityId, Lang FROM I18n;

-- Conductors, performing in St.Petersburg in both February 2016 and February 2015
(
  SELECT DISTINCT ep.PerformerId FROM EventPerformer ep
  JOIN Event e ON ep.EventId = e.Id
  JOIN Venue v ON v.Id = e.VenueId
  WHERE v.CityId = 1 AND e.Time >= '2016-02-01' AND e.Time < '2016-03-01'
) INTERSECT (
  SELECT DISTINCT ep.PerformerId FROM EventPerformer ep
  JOIN Event e ON ep.EventId = e.Id
  JOIN Venue v ON v.Id = e.VenueId
  WHERE v.CityId = 1 AND e.Time >= '2015-02-01' AND e.Time < '2015-03-01'
);

-- Conductors, that had performed both in St. Petersburg Philharmonia and Covent-Garden in 2015
(
  SELECT DISTINCT ep.PerformerId FROM EventPerformer ep
  JOIN Event e ON ep.EventId = e.Id
  JOIN Venue v ON v.Id = e.VenueId
  WHERE v.Id = 2 AND e.Time >= '2015-01-01' AND e.Time < '2016-01-01'
) INTERSECT (
  SELECT DISTINCT ep.PerformerId FROM EventPerformer ep
  JOIN Event e ON ep.EventId = e.Id
  JOIN Venue v ON v.Id = e.VenueId
  WHERE v.Id = 4 AND e.Time >= '2015-01-01' AND e.Time < '2016-01-01'
);

-- Repertoire of all venues in Russian
SELECT p.*, iV.Value as VenueName, iP.Value as PieceName, l.Lang FROM (
  SELECT p.Type, e.VenueId, p.Id as PieceId, MIN(e.Time) as FirstPerformed, MAX(e.Time) as LastPerformed
  FROM EventPiece ep
  JOIN Event e ON ep.EventId = e.Id
  JOIN Piece p ON ep.PieceId = p.Id
  GROUP BY e.VenueId, p.Id
) p
CROSS JOIN (SELECT DISTINCT Lang FROM I18n) l
LEFT JOIN I18n iP ON iP.EntityType = 'Piece' AND iP.EntityId = p.PieceId AND iP.Lang = l.Lang AND iP.Key = 'Name'
LEFT JOIN I18n iV ON iV.EntityType = 'Venue' AND iV.EntityId = p.VenueId AND iV.Lang = l.Lang AND iV.Key = 'Name'
WHERE l.Lang = 'ru'
;

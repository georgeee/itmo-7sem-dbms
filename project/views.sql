    
    CREATE VIEW EventInfo AS
    (
      SELECT e.*, l.Lang,
             iE.Value as EventName,
             iV.Value as VenueName,
             iVA.Value as VenueAddress,
             v.CityId,
             iCi.Value as CityName,
             ci.CountryId,
             iCu.Value as CountryName
      FROM Event e
      CROSS JOIN (SELECT DISTINCT Lang FROM I18n) l
      JOIN Venue v ON v.Id = e.VenueId
      JOIN City ci ON ci.Id = v.CityId
      JOIN Country cu ON cu.Id = ci.CountryId
      LEFT JOIN I18n iE ON iE.EntityType = 'Event' AND iE.EntityId = e.VenueId AND iE.Lang = l.Lang AND iE.Key = 'Name'
      LEFT JOIN I18n iV ON iV.EntityType = 'Venue' AND iV.EntityId = e.VenueId AND iV.Lang = l.Lang AND iV.Key = 'Name'
      LEFT JOIN I18n iVA ON iVA.EntityType = 'Venue' AND iVA.EntityId = e.VenueId AND iVA.Lang = l.Lang AND iVA.Key = 'Address'
      LEFT JOIN I18n iCi ON iCi.EntityType = 'City' AND iCi.EntityId = ci.Id AND iCi.Lang = l.Lang AND iCi.Key = 'Name'
      LEFT JOIN I18n iCu ON iCu.EntityType = 'Country' AND iCu.EntityId = ci.Id AND iCu.Lang = l.Lang AND iCu.Key = 'Name'
    );
    CREATE VIEW EventPieceInfo AS
    (
      SELECT ep.*, l.Lang,
             iP.Value as PieceName,
             iC.Value as ComposerName,
             p.Type as PieceType,
             p.GeneralPieceId,
             pg.Type as GeneralPieceType,
             iG.Value as GeneralPieceName,
             co.DateOfBirth as composerDateOfBirth,
             co.DateOfDeath as composerDateOfDeath
      FROM EventPiece ep
      CROSS JOIN (SELECT DISTINCT Lang FROM I18n) l
      JOIN Piece p ON p.Id = ep.PieceId
      JOIN Composer co ON co.Id = p.ComposerId
      LEFT JOIN Piece pg ON pg.Id = p.GeneralPieceId
      LEFT JOIN I18n iP ON iP.EntityType = 'Piece' AND iP.EntityId = ep.PieceId AND iP.Lang = l.Lang AND iP.Key = 'Name'
      LEFT JOIN I18n iG ON iG.EntityType = 'Piece' AND iG.EntityId = p.GeneralPieceId AND iG.Lang = l.Lang AND iG.Key = 'Name'
      LEFT JOIN I18n iC ON iC.EntityType = 'Composer' AND iC.EntityId = p.ComposerId AND iC.Lang = l.Lang AND iC.Key = 'Name'
    );
    CREATE VIEW EventPerformerInfo AS
    (
      SELECT ep.*, l.Lang,
             iP.Value as PerformerName,
             iR.Value as Role
      FROM EventPerformer ep
      CROSS JOIN (SELECT DISTINCT Lang FROM I18n) l
      LEFT JOIN I18n iP ON iP.EntityType = 'Performer' AND iP.EntityId = ep.PerformerId AND iP.Lang = l.Lang AND iP.Key = 'Name'
      LEFT JOIN I18n iR ON iR.EntityType = 'EventPerformer' AND iR.EntityId = ep.Id AND iR.Lang = l.Lang AND iR.Key = 'Role'
    );

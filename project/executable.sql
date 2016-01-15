    
    CREATE OR REPLACE FUNCTION cancel_event(int) RETURNS void AS $cancelEvent$
    DECLARE
      u INT;
      _canceled BOOLEAN;
    BEGIN
      SELECT Canceled FROM Event INTO _canceled WHERE Id = $1;
      IF _canceled THEN
        RAISE EXCEPTION 'already canceled';
      ELSE
        FOR u IN SELECT UserId FROM Subscription
                 WHERE EntityType = 'Event' AND EntityId = $1
        LOOP
          INSERT INTO Notification (Type, UserId) VALUES ('CANCELED_EVENT', u);
          INSERT INTO NotificationEntity (NotificationId, EntityType, EntityId)
            VALUES (currval(pg_get_serial_sequence('notification','id')), 'Event', $1);
        END LOOP;
        UPDATE Event SET Canceled = True WHERE Id = $1;
      END IF;
    END;
    $cancelEvent$ LANGUAGE plpgsql;
    
    CREATE OR REPLACE FUNCTION clear_matched() RETURNS void AS $clear_matched$
    BEGIN
      CREATE TEMP TABLE IF NOT EXISTS Matched (
        EntityType NotificationEntityType,
        EntityId INT NOT NULL,
        UserId INT NOT NULL
      ) ON COMMIT DROP;
      TRUNCATE Matched;
    END;
    
    $clear_matched$ LANGUAGE plpgsql;
    
    CREATE OR REPLACE FUNCTION event_process_matched(int) RETURNS void AS $event_process_matched$
    DECLARE
      u INT;
      n INT;
    BEGIN
      FOR u IN SELECT DISTINCT UserId FROM Matched
      LOOP
        SELECT nn.Id FROM Notification nn INTO n
          JOIN NotificationEntity nt ON nt.NotificationId = nn.Id
            AND nn.Type = 'NEW_EVENT' AND nt.EntityType = 'Event' AND nt.EntityId = $1
            AND nn.UserId = u;
        IF n IS NULL THEN
          INSERT INTO Notification (Type, UserId) VALUES ('NEW_EVENT', u);
          SELECT currval(pg_get_serial_sequence('notification','id')) INTO n;
          INSERT INTO NotificationEntity (NotificationId, EntityType, EntityId)
            SELECT n, 'Event', $1;
        END IF;
        INSERT INTO NotificationEntity (NotificationId, EntityType, EntityId)
          SELECT n, EntityType, EntityId FROM Matched;
      END LOOP;
    END;
    $event_process_matched$ LANGUAGE plpgsql;
    
    CREATE OR REPLACE FUNCTION event_insert_trigger() RETURNS trigger AS $event_insert_trigger$
    DECLARE
      u INT;
      n INT;
    BEGIN
      PERFORM clear_matched();
      INSERT INTO Matched (EntityType, EntityId, UserId)
      SELECT s.EntityType, s.EntityId, s.UserId FROM Subscription s JOIN (
        SELECT 'Venue'::NotificationEntityType as t, NEW.VenueId as Id
        UNION
        SELECT 'City'::NotificationEntityType as t, v.CityId as Id FROM Venue v WHERE v.Id = NEW.VenueId
        UNION
        SELECT 'Country'::NotificationEntityType as t, c.CountryId as Id
            FROM Venue v
            JOIN City c ON c.Id = v.CityId
            WHERE v.Id = NEW.VenueId
      ) cp ON cp.t = s.EntityType AND s.EntityId = cp.id;
      PERFORM event_process_matched(NEW.Id);
      RETURN NEW;
    END;
    $event_insert_trigger$ LANGUAGE plpgsql;
    
    CREATE TRIGGER event_insert_trigger AFTER INSERT ON Event
    FOR EACH ROW EXECUTE PROCEDURE event_insert_trigger();
    
    CREATE OR REPLACE FUNCTION event_performer_insert_trigger() RETURNS trigger AS $event_performer_insert_trigger$
    DECLARE
      u INT;
      n INT;
    BEGIN
      PERFORM clear_matched();
      INSERT INTO Matched (EntityType, EntityId, UserId)
      SELECT s.EntityType, s.EntityId, s.UserId FROM Subscription s JOIN (
        SELECT 'Performer'::NotificationEntityType as t, NEW.PerformerId as Id
      ) cp ON cp.t = s.EntityType AND s.EntityId = cp.id;
      PERFORM event_process_matched(NEW.EventId);
      RETURN NEW;
    END;
    $event_performer_insert_trigger$ LANGUAGE plpgsql;
    
    CREATE TRIGGER event_performer_insert_trigger AFTER INSERT ON EventPerformer
    FOR EACH ROW EXECUTE PROCEDURE event_performer_insert_trigger();
    
    
    CREATE OR REPLACE FUNCTION event_piece_insert_trigger() RETURNS trigger AS $event_piece_insert_trigger$
    DECLARE
      u INT;
      n INT;
    BEGIN
      PERFORM clear_matched();
      INSERT INTO Matched (EntityType, EntityId, UserId)
      SELECT s.EntityType, s.EntityId, s.UserId FROM Subscription s JOIN (
        SELECT 'Composer'::NotificationEntityType as t, c.Id FROM Composer c JOIN Piece p ON c.Id = p.ComposerId AND p.Id = NEW.PieceId
        UNION
        SELECT 'Piece', p.GeneralPieceId FROM Piece p WHERE p.Id = NEW.PieceId AND p.GeneralPieceId IS NOT NULL
        UNION
        SELECT 'Piece', NEW.PieceId
      ) cp ON cp.t = s.EntityType AND s.EntityId = cp.id;
      PERFORM event_process_matched(NEW.EventId);
      RETURN NEW;
    END;
    $event_piece_insert_trigger$ LANGUAGE plpgsql;
    
    CREATE TRIGGER event_piece_insert_trigger AFTER INSERT ON EventPiece
    FOR EACH ROW EXECUTE PROCEDURE event_piece_insert_trigger();

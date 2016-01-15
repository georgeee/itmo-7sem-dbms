    
    ALTER TABLE Piece ADD CONSTRAINT FK_Piece_ComposerId FOREIGN KEY (ComposerId) REFERENCES Composer (Id);
    ALTER TABLE Piece ADD CONSTRAINT FK_Piece_GeneralPieceId FOREIGN KEY (GeneralPieceId) REFERENCES Piece (Id);
    ALTER TABLE Venue ADD CONSTRAINT FK_Venue_CityId FOREIGN KEY (CityId) REFERENCES City (Id);
    ALTER TABLE City ADD CONSTRAINT FK_City_CountryId FOREIGN KEY (CountryId) REFERENCES Country (Id);
    ALTER TABLE Event ADD CONSTRAINT FK_Event_VenueId FOREIGN KEY (VenueId) REFERENCES Venue (Id);
    ALTER TABLE EventPiece ADD CONSTRAINT FK_EventPiece_PieceId FOREIGN KEY (PieceId) REFERENCES Piece (Id);
    ALTER TABLE EventPiece ADD CONSTRAINT FK_EventPiece_EventId FOREIGN KEY (EventId) REFERENCES Event (Id);
    ALTER TABLE EventPerformer ADD CONSTRAINT FK_EventPerformer_EventId FOREIGN KEY (EventId) REFERENCES Event (Id);
    ALTER TABLE EventPerformer ADD CONSTRAINT FK_EventPerformer_PerformerId FOREIGN KEY (PerformerId) REFERENCES Performer (Id);
    ALTER TABLE Subscription ADD CONSTRAINT FK_Subscription_UserId FOREIGN KEY (UserId) REFERENCES PortalUser (Id);
    ALTER TABLE Notification ADD CONSTRAINT FK_Notification_UserId FOREIGN KEY (UserId) REFERENCES PortalUser (Id);
    ALTER TABLE NotificationEntity ADD CONSTRAINT FK_NotificationEntity_NotificationId FOREIGN KEY (NotificationId) REFERENCES Notification (Id);

    ALTER TABLE Country ADD CONSTRAINT UN_Country_Code UNIQUE (Code);
    ALTER TABLE PortalUser ADD CONSTRAINT UN_PortalUser_Login UNIQUE (Login);
    ALTER TABLE EventPerformer ADD CONSTRAINT UN_EventPerformer_EventId_PerformerId UNIQUE (EventId, PerformerId);
    
    CREATE INDEX Ix_Event_Time ON Event (Time);
    CREATE INDEX Ix_I18n_Lang ON I18n (Lang);
   
    ALTER TABLE Composer ADD CONSTRAINT Composer_Dates CHECK (DateOfBirth < DateOfDeath);
    ALTER TABLE I18n ADD CONSTRAINT I18n_Key_EntityType CHECK ((Key = 'Name' AND EntityType != 'EventPerformer') OR (Key = 'Address' AND EntityType = 'Venue') OR (Key = 'Role' AND EntityType = 'EventPerformer'));

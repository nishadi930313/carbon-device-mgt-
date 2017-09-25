-- -----------------------------------------------------
-- Schema WSO2DM_APPM_DB
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Table APPM_PLATFORM
-- -----------------------------------------------------
CREATE TABLE APPM_PLATFORM (
ID INT UNIQUE,
IDENTIFIER VARCHAR (100) NOT NULL,
TENANT_ID INT NOT NULL ,
NAME VARCHAR (255),
FILE_BASED NUMBER (1),
DESCRIPTION VARCHAR (2048),
IS_SHARED NUMBER (1),
IS_DEFAULT_TENANT_MAPPING NUMBER (1),
ICON_NAME VARCHAR (100),
PRIMARY KEY (ID)
)
/

CREATE SEQUENCE APPM_PLATFORM_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER APPM_PLATFORM_TRIG
            BEFORE INSERT
            ON APPM_PLATFORM
            REFERENCING NEW AS NEW
            FOR EACH ROW
              BEGIN
                SELECT APPM_PLATFORM_SEQ.nextval INTO :NEW.ID FROM dual;
              END;
/


CREATE TABLE APPM_PLATFORM_PROPERTIES (
ID INT,
PLATFORM_ID INT NOT NULL,
PROP_NAME VARCHAR (100) NOT NULL,
OPTIONAL NUMBER (1),
DEFAUL_VALUE VARCHAR (255),
FOREIGN KEY(PLATFORM_ID) REFERENCES APPM_PLATFORM(ID) ON DELETE CASCADE,
PRIMARY KEY (ID, PLATFORM_ID, PROP_NAME)
)
/

CREATE SEQUENCE APPM_PLATFORM_PROPERTIES_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER APPM_PLATFORM_PROPERTIES_TRIG
            BEFORE INSERT
            ON APPM_PLATFORM_PROPERTIES
            REFERENCING NEW AS NEW
            FOR EACH ROW
              BEGIN
                SELECT APPM_PLATFORM_PROPERTIES_SEQ.nextval INTO :NEW.ID FROM dual;
              END;
/

CREATE TABLE APPM_PLATFORM_TENANT_MAPPING (
ID INT,
TENANT_ID INT NOT NULL ,
PLATFORM_ID INT NOT NULL,
FOREIGN KEY(PLATFORM_ID) REFERENCES APPM_PLATFORM(ID) ON DELETE CASCADE,
PRIMARY KEY (ID, TENANT_ID, PLATFORM_ID)
)
/

CREATE SEQUENCE APPM_TENANT_MAPPING_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER APPM_TENANT_MAPPING_TRIG
            BEFORE INSERT
            ON APPM_PLATFORM_TENANT_MAPPING
            REFERENCING NEW AS NEW
            FOR EACH ROW
              BEGIN
                SELECT APPM_TENANT_MAPPING_SEQ.nextval INTO :NEW.ID FROM dual;
              END;
/

CREATE INDEX FK_PLATFROM_TENANT_MAPPING ON APPM_PLATFORM_TENANT_MAPPING(PLATFORM_ID ASC)
/


-- -----------------------------------------------------
-- Table APPM_APPLICATION_CATEGORY
-- -----------------------------------------------------
CREATE TABLE APPM_APPLICATION_CATEGORY (
  ID INT,
  NAME VARCHAR(100) NOT NULL,
  DESCRIPTION VARCHAR(2048) NULL,
  PUBLISHED NUMBER(1) NULL,
  PRIMARY KEY (ID))
/

CREATE SEQUENCE APPM_APPLICATION_CATEGORY_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER APPM_APPLICATION_CATEGORY_TRIG
            BEFORE INSERT
            ON APPM_APPLICATION_CATEGORY
            REFERENCING NEW AS NEW
            FOR EACH ROW
              BEGIN
                SELECT APPM_APPLICATION_CATEGORY_SEQ.nextval INTO :NEW.ID FROM dual;
              END;
/

INSERT INTO APPM_APPLICATION_CATEGORY (NAME, DESCRIPTION, PUBLISHED) VALUES ('Enterprise',
'Enterprise level applications which the artifacts need to be provided', 1)
/
INSERT INTO APPM_APPLICATION_CATEGORY (NAME, DESCRIPTION, PUBLISHED) VALUES ('Public',
'Public category in which the application need to be downloaded from the public application store', 1)
/

-- -----------------------------------------------------
-- Table APPM_LIFECYCLE_STATE
-- -----------------------------------------------------
CREATE TABLE APPM_LIFECYCLE_STATE (
  ID INT,
  NAME VARCHAR(100) NOT NULL,
  IDENTIFIER VARCHAR(100) NOT NULL,
  DESCRIPTION VARCHAR(2048) NULL,
  PRIMARY KEY (ID))
/

CREATE INDEX LIFECYCLE_STATE_ID_UNIQUE ON APPM_LIFECYCLE_STATE(IDENTIFIER ASC)
/

CREATE SEQUENCE APPM_LIFECYCLE_STATE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER APPM_LIFECYCLE_STATE_TRIG
            BEFORE INSERT
            ON APPM_LIFECYCLE_STATE
            REFERENCING NEW AS NEW
            FOR EACH ROW
              BEGIN
                SELECT APPM_LIFECYCLE_STATE_SEQ.nextval INTO :NEW.ID FROM dual;
              END;
/

INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION) VALUES ('CREATED', 'CREATED',
'Application creation initial state')
/

INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('IN REVIEW', 'IN REVIEW', 'Application is in in-review state')
/

INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('APPROVED', 'APPROVED', 'State in which Application is approved after reviewing.')
/

INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('REJECTED', 'REJECTED', 'State in which Application is rejected after reviewing.')
/

INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('PUBLISHED', 'PUBLISHED', 'State in which Application is in published state.')
/

INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('UNPUBLISHED', 'UNPUBLISHED', 'State in which Application is in un published state.')
/

INSERT INTO APPM_LIFECYCLE_STATE (NAME, IDENTIFIER, DESCRIPTION)
VALUES ('RETIRED', 'RETIRED', 'Retiring an application to indicate end of life state,')
/

CREATE TABLE APPM_LC_STATE_TRANSITION (
  ID INT UNIQUE,
  INITIAL_STATE INT,
  NEXT_STATE INT,
  PERMISSION VARCHAR(1024),
  DESCRIPTION VARCHAR(2048),
  PRIMARY KEY (INITIAL_STATE, NEXT_STATE),
  FOREIGN KEY (INITIAL_STATE) REFERENCES APPM_LIFECYCLE_STATE(ID) ON DELETE CASCADE,
  FOREIGN KEY (NEXT_STATE) REFERENCES APPM_LIFECYCLE_STATE(ID) ON DELETE CASCADE
)
/

CREATE SEQUENCE APPM_LC_STATE_TRANSITION_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER APPM_LC_STATE_TRANSITION_TRIG
            BEFORE INSERT
            ON APPM_LC_STATE_TRANSITION
            REFERENCING NEW AS NEW
            FOR EACH ROW
              BEGIN
                SELECT APPM_LC_STATE_TRANSITION_SEQ.nextval INTO :NEW.ID FROM dual;
              END;
/

INSERT INTO APPM_LC_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (1, 2, null, 'Submit for review')
/
INSERT INTO APPM_LC_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (2, 1, null, 'Revoke from review')
/
INSERT INTO APPM_LC_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (2, 3, '/permission/admin/manage/device-mgt/application/review', 'APPROVE')
/
INSERT INTO APPM_LC_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (2, 4, '/permission/admin/manage/device-mgt/application/review', 'REJECT')
/
INSERT INTO APPM_LC_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (3, 4, '/permission/admin/manage/device-mgt/application/review', 'REJECT')
/
INSERT INTO APPM_LC_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (3, 5, null, 'PUBLISH')
/
INSERT INTO APPM_LC_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (5, 6, null, 'UN PUBLISH')
/
INSERT INTO APPM_LC_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (6, 5, null, 'PUBLISH')
/
INSERT INTO APPM_LC_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (4, 1, null, 'Return to CREATE STATE')
/
INSERT INTO APPM_LC_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (6, 1, null, 'Return to CREATE STATE')
/
INSERT INTO APPM_LC_STATE_TRANSITION(INITIAL_STATE, NEXT_STATE, PERMISSION, DESCRIPTION) VALUES
  (6, 7, null, 'Retire')
/

-- -----------------------------------------------------
-- Table APPM_APPLICATION
-- -----------------------------------------------------
CREATE TABLE APPM_APPLICATION (
  ID INT UNIQUE,
  UUID VARCHAR(100) NOT NULL,
  IDENTIFIER VARCHAR(255) NULL,
  NAME VARCHAR(100) NOT NULL,
  SHORT_DESCRIPTION VARCHAR(255) NULL,
  DESCRIPTION VARCHAR(2048) NULL,
  VIDEO_NAME VARCHAR(100) NULL,
  SCREEN_SHOT_COUNT INT DEFAULT 0,
  CREATED_BY VARCHAR(255) NULL,
  CREATED_AT TIMESTAMP NOT NULL,
  MODIFIED_AT TIMESTAMP NULL,
  IS_FREE NUMBER(1) NULL,
  PAYMENT_CURRENCY VARCHAR(45) NULL,
  PAYMENT_PRICE DECIMAL(10,2) NULL,
  APPLICATION_CATEGORY_ID INT NOT NULL,
  LIFECYCLE_STATE_ID INT NOT NULL,
  LIFECYCLE_STATE_MODIFIED_BY VARCHAR(255) NULL,
  LIFECYCLE_STATE_MODIFIED_AT TIMESTAMP NULL,
  TENANT_ID INT NULL,
  PLATFORM_ID INT NOT NULL,
  PRIMARY KEY (ID, APPLICATION_CATEGORY_ID, LIFECYCLE_STATE_ID, PLATFORM_ID),
  CONSTRAINT FK_APP_APP_CATEGORY FOREIGN KEY (APPLICATION_CATEGORY_ID) REFERENCES APPM_APPLICATION_CATEGORY (ID),
  CONSTRAINT FK_APP_LIFECYCLE_STATE FOREIGN KEY (LIFECYCLE_STATE_ID) REFERENCES APPM_LIFECYCLE_STATE (ID),
  CONSTRAINT FK_APPM_APP_PLATFORM FOREIGN KEY (PLATFORM_ID) REFERENCES APPM_PLATFORM (ID))
/

CREATE INDEX UUID_UNIQUE ON APPM_APPLICATION(UUID ASC)
/

CREATE INDEX FK_APP_APP_CATEGORY ON APPM_APPLICATION(APPLICATION_CATEGORY_ID ASC)
/

CREATE INDEX FK_APP_LIFECYCLE_STATE ON APPM_APPLICATION(LIFECYCLE_STATE_ID ASC)
/

CREATE INDEX FK_APPM_APP_PLATFORM ON APPM_APPLICATION(PLATFORM_ID ASC)
/

CREATE SEQUENCE APPM_APPLICATION_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER APPM_APPLICATION_TRIG
            BEFORE INSERT
            ON APPM_APPLICATION
            REFERENCING NEW AS NEW
            FOR EACH ROW
              BEGIN
                SELECT APPM_APPLICATION_SEQ.nextval INTO :NEW.ID FROM dual;
              END;
/

-- -----------------------------------------------------
-- Table APPM_APPLICATION_PROPERTY
-- -----------------------------------------------------
CREATE TABLE APPM_APPLICATION_PROPERTY (
  PROP_KEY VARCHAR(255) NOT NULL,
  PROP_VAL VARCHAR(2048) NULL,
  APPLICATION_ID INT NOT NULL,
  PRIMARY KEY (PROP_KEY, APPLICATION_ID),
  CONSTRAINT FK_APP_PROPERTY_APP
  FOREIGN KEY (APPLICATION_ID)
  REFERENCES APPM_APPLICATION (ID))
/

CREATE INDEX FK_APP_PROPERTY_APP ON APPM_APPLICATION_PROPERTY(APPLICATION_ID ASC)
/

-- -----------------------------------------------------
-- Table APPM_APPLICATION_RELEASE
-- -----------------------------------------------------
CREATE TABLE APPM_APPLICATION_RELEASE (
  ID INT UNIQUE ,
  VERSION_NAME VARCHAR(100) NOT NULL,
  RELEASE_RESOURCE VARCHAR(2048) NULL,
  RELEASE_CHANNEL VARCHAR(50) DEFAULT 'ALPHA',
  RELEASE_DETAILS VARCHAR(2048) NULL,
  CREATED_AT TIMESTAMP NOT NULL,
  APPM_APPLICATION_ID INT NOT NULL,
  IS_DEFAULT NUMBER(1) NULL,
  PRIMARY KEY (APPM_APPLICATION_ID, VERSION_NAME),
  CONSTRAINT FK_APP_VERSION_APP
  FOREIGN KEY (APPM_APPLICATION_ID)
  REFERENCES APPM_APPLICATION (ID))
/

CREATE INDEX FK_APP_VERSION_APP ON APPM_APPLICATION_RELEASE(APPM_APPLICATION_ID ASC)
/

CREATE SEQUENCE APPM_APPLICATION_RELEASE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER APPM_APPLICATION_RELEASE_TRIG
            BEFORE INSERT
            ON APPM_APPLICATION_RELEASE
            REFERENCING NEW AS NEW
            FOR EACH ROW
              BEGIN
                SELECT APPM_APPLICATION_RELEASE_SEQ.nextval INTO :NEW.ID FROM dual;
              END;
/

-- -----------------------------------------------------
-- Table APPM_RELEASE_PROPERTY
-- -----------------------------------------------------
CREATE TABLE APPM_RELEASE_PROPERTY (
  PROP_KEY VARCHAR(255) NOT NULL,
  PROP_VALUE VARCHAR(2048) NULL,
  APPLICATION_RELEASE_ID INT NOT NULL,
  PRIMARY KEY (PROP_KEY, APPLICATION_RELEASE_ID),
  CONSTRAINT FK_RP_APP_RELEASE
  FOREIGN KEY (APPLICATION_RELEASE_ID)
  REFERENCES APPM_APPLICATION_RELEASE (ID))
/

CREATE INDEX FK_RP_APP_RELEASE ON APPM_RELEASE_PROPERTY(APPLICATION_RELEASE_ID ASC)
/

CREATE TABLE APPM_APPLICATION_TAG (
  NAME VARCHAR(45) NOT NULL,
  APPLICATION_ID INT NOT NULL,
  PRIMARY KEY (APPLICATION_ID, NAME),
  CONSTRAINT FK_APPM_APP_TAG_APP
  FOREIGN KEY (APPLICATION_ID)
  REFERENCES APPM_APPLICATION (ID))
/

CREATE INDEX FK_APPM_APP_TAG_APP ON APPM_APPLICATION_TAG(APPLICATION_ID ASC)
/


CREATE TABLE APPM_PLATFORM_TAG (
  NAME VARCHAR(100) NOT NULL,
  PLATFORM_ID INT NOT NULL,
  PRIMARY KEY (PLATFORM_ID, NAME),
  CONSTRAINT FK_APPM_PLATFORM_TAG_APP
  FOREIGN KEY (PLATFORM_ID)
  REFERENCES APPM_PLATFORM (ID))
/

CREATE INDEX FK_APPM_PLATFORM_TAG_APP ON APPM_PLATFORM_TAG(PLATFORM_ID ASC)
/



-- --------- TRIGGERS -------------

-- TRIGGER 1: Un trigger cuando un camión ingrese o salga de la la empresa, que actualice el estado del viaje ------
     
    -- Trigger que se disparará cada vez que un camión llegue o salga de la empres,

    CREATE OR REPLACE TRIGGER tgr_actualizar_estado
    BEFORE UPDATE OF ID_ESTADO ON HISTORICO_VIAJES
    FOR EACH ROW
    DECLARE

    BEGIN
        
        CASE
            WHEN :OLD.id_estado = 2 THEN --Cuando un camion llegue el estado 2 es en curso, lo cambia a finalizado (5)
                :new.id_estado := 5;
            WHEN :OLD.id_estado = 1 THEN --Cuando un camion sale el estado 1 es en sin asignar, lo cambia a en curso (2)
                :new.id_estado := 2; 
            WHEN :OLD.id_estado = 3 THEN --El viaje fue cancelado (3) por lo tanto se asigna como finalizado (5) cuando llega a la empresa
                :new.id_estado := 5;
            ELSE   
                RAISE_APPLICATION_ERROR(-20007, 'Tas loco papi');
          END CASE;  
    END;
    /

        
    

    
    
    
-- TRIIGER 3: ------------------------------------ Un trigger cuando un camión ingrese a la empresa, que genere un turno de descarga

CREATE OR REPLACE TRIGGER Tgr_generar_turno_descarga
AFTER INSERT OR UPDATE ON HISTORICO_VIAJES
FOR EACH ROW

DECLARE
V_PLACA CAMIONES.PLACA%TYPE;
V_ULTIMA_HORA TIMESTAMP;
V_NUEVA_HORA TIMESTAMP;

BEGIN
    IF :new.id_estado = 5 THEN
        --Generar un id único (ya)
        --obtener el id_del camion 
        SELECT ca.id_camion
        INTO V_PLACA
        FROM CAMIONES_ASIGNADOS ca
        WHERE id_asignacion = :NEW.ID_ASIGNACION;
        --asignar una hora adecuada para el turno (sumarle 30 minutos a la hora del último turno)
        SELECT HORA_ASIGNADA
        INTO V_ULTIMA_HORA
        FROM (
            SELECT HORA_ASIGNADA
            FROM TURNOS_DESCARGA
            ORDER BY HORA_ASIGNADA DESC
        )
        WHERE ROWNUM = 1;
        
        --Aignar la hora
        IF V_ULTIMA_HORA IS NULL THEN
            V_NUEVA_HORA := SYSTIMESTAMP + NUMTODSINTERVAL(30, 'MINUTE');
        ELSE
            V_NUEVA_HORA := V_ULTIMA_HORA + NUMTODSINTERVAL(30, 'MINUTE');
        END IF;
        
        INSERT INTO TURNOS_DESCARGA (ID_CAMION, HORA_ASIGNADA)
        VALUES(V_PLACA, V_NUEVA_HORA);
    END IF;
    
END Tgr_generar_turno_descarga;
/

update historico_viajes 
set id_estado = 5
where id_historial = 27;


-- TRIIGER 5: ------------------------------------ Un trigger que lleve el control de cambios hechos en la base de datos (por cada tabla, es decir tenemos todos los triggers necesarios) 
CREATE TABLE CAMBIOS_CAMIONES_ASIGNADOS(
    ID_AUDITORIA NUMBER NOT NULL PRIMARY KEY,
    ANTIGUOID_ASIGNACION NUMBER,
    ANTIGUOID_CAMION VARCHAR2(10),
    ANTIGUOID_CONDUCTOR NUMBER,
    ANTIGUOFECHA_ASIGNACION TIMESTAMP,
    ANTIGUOELIMINADO CHAR(1),
    NUEVOID_ASIGNACION NUMBER,
    NUEVOID_CAMION VARCHAR2(10),
    NUEVOID_CONDUCTOR NUMBER,
    NUEVOFECHA_ASIGNACION TIMESTAMP,
    NUEVOELIMINADO CHAR(1),
    FECHA TIMESTAMP,
    ACCION_REALIZADA VARCHAR2(20),
    USUARIO_CAMBIO VARCHAR2(50)
);

DROP TABLE CAMBIOS_CAMIONES_ASIGNADOS;

CREATE OR REPLACE TRIGGER TRG_CAMBIOS_CAMIONES_ASIGNADOS
BEFORE INSERT OR UPDATE OR DELETE ON CAMIONES_ASIGNADOS
FOR EACH ROW
DECLARE
    ACCION VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        ACCION := 'INSERT';
    ELSIF UPDATING THEN
        ACCION := 'UPDATE';
    ELSE
        ACCION := 'DELETE';
    END IF;

    BEGIN
        -- Bloque de código principal del trigger
        INSERT INTO CAMBIOS_CAMIONES_ASIGNADOS(
            ANTIGUOID_ASIGNACION,
            ANTIGUOID_CAMION,
            ANTIGUOID_CONDUCTOR,
            ANTIGUOFECHA_ASIGNACION, 
            ANTIGUOELIMINADO,
            NUEVOID_ASIGNACION,
            NUEVOID_CAMION,
            NUEVOID_CONDUCTOR,
            NUEVOFECHA_ASIGNACION, 
            NUEVOELIMINADO,
            FECHA,
            ACCION_REALIZADA,
            USUARIO_CAMBIO
        ) VALUES (
            :OLD.ID_ASIGNACION,
            :OLD.ID_CAMION,
            :OLD.ID_CONDUCTOR,
            :OLD.FECHA_ASIGNACION,
            :OLD.FECHA_ASIGNACION,
            :OLD.ELIMINADO,
            :NEW.ID_CAMION,
            :NEW.ID_CONDUCTOR,
            SYSTIMESTAMP,
            :NEW.ELIMINADO,
            SYSDATE,
            ACCION,
            USER
        );
    EXCEPTION
        WHEN OTHERS THEN
            -- Manejo de excepciones
            DBMS_OUTPUT.PUT_LINE('Error en el trigger: ' || SQLERRM);
            
    END;
END;
/


-- TRIIGER 7: ------------------------------------Un trigger que registre los cambios hechos en la tabla historico_viajes

CREATE TABLE CAMBIOS_HISTORICO_VIAJES(
    ID_AUDITORIA NUMBER NOT NULL PRIMARY KEY,
    ANTIGUOID_HISTORIAL NUMBER,
	ANTIGUOID_VIAJE NUMBER,
	ANTIGUOID_ASIGNACION NUMBER,
	ANTIGUOID_ESTADO NUMBER, 
	ANTIGUOTIEMPO_TEORICO INTERVAL DAY TO SECOND,
	ANTIGUOTIEMPO_REAL INTERVAL DAY TO SECOND,
	ANTIGUODESCRIPCION VARCHAR2(80),
    NUEVOID_HISTORIAL NUMBER,
	NUEVOID_VIAJE NUMBER,
	NUEVOID_ASIGNACION NUMBER,
	NUEVOID_ESTADO NUMBER, 
	NUEVOTIEMPO_TEORICO INTERVAL DAY TO SECOND,
	NUEVOTIEMPO_REAL INTERVAL DAY TO SECOND,
	NUEVODESCRIPCION VARCHAR2(80),
    FECHA TIMESTAMP,
    ACCION_REALIZADA VARCHAR2(20),
    USUARIO_CAMBIO VARCHAR2(50)
);


CREATE OR REPLACE TRIGGER TRG_CAMBIOS_HISTORICO_VIAJES
BEFORE INSERT OR UPDATE OR DELETE ON HISTORICO_VIAJES
FOR EACH ROW
DECLARE
    ACCION VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        ACCION := 'INSERT';
    ELSIF UPDATING THEN
        ACCION := 'UPDATE';
    ELSE
        ACCION := 'DELETE';
    END IF;

    INSERT INTO CAMBIOS_HISTORICO_VIAJES ( --CAMBIAR
        ANTIGUOID_HISTORIAL,
        ANTIGUOID_VIAJE,
        ANTIGUOID_ASIGNACION,
        ANTIGUOID_ESTADO, 
        ANTIGUOTIEMPO_TEORICO,
        ANTIGUOTIEMPO_REAL,
        ANTIGUODESCRIPCION,
        NUEVOID_HISTORIAL,
        NUEVOID_VIAJE,
        NUEVOID_ASIGNACION,
        NUEVOID_ESTADO, 
        NUEVOTIEMPO_TEORICO,
        NUEVOTIEMPO_REAL,
        NUEVODESCRIPCION,
        FECHA,
        ACCION_REALIZADA,
        USUARIO_CAMBIO
    ) VALUES (
        :OLD.ID_HISTORIAL,
        :OLD.ID_VIAJE,
        :OLD.ID_ASIGNACION,
        :OLD.ID_ESTADO,
        :OLD.TIEMPO_TEORICO,
        :OLD.TIEMPO_REAL,
        :OLD.DESCRIPCION,
        :NEW.ID_HISTORIAL,
        :NEW.ID_VIAJE,
        :NEW.ID_ASIGNACION,
        :NEW.ID_ESTADO,
        :NEW.TIEMPO_TEORICO,
        :NEW.TIEMPO_REAL,
        :NEW.DESCRIPCION,
        SYSDATE,
        ACCION,
        USER
    );
END;
/


 --update historico_viajes 
 --set descripcion = 'Chimba de viaje so y mi pai'
 --where id_historial = 1;

 --update historico_viajes 
 --set id_estado = 6
 --where id_historial = 1;

----------  Triggers para id únicos ?  -----------------------------  

-- para la tabla camiones_visitantes

    CREATE OR REPLACE TRIGGER TgrGenIdCV
      BEFORE INSERT ON CAMIONES_VISITANTES
      FOR EACH ROW
    BEGIN 
      :NEW.ID := SEQ_CAMIONES_VISITANTES.NEXTVAL;
    END TgrGenIdCV;
    /

      
-- para la tabla cambios_historico_viajes
    CREATE OR REPLACE TRIGGER TgrGenIdCHV
      BEFORE INSERT ON CAMBIOS_HISTORICO_VIAJES
      FOR EACH ROW
    BEGIN 
      :NEW.ID_AUDITORIA := SEQ_CAMBIOS_HISTORICO_VIAJES.NEXTVAL;
    END TgrGenIdCHV;
    /
    show errors;

      
-- para la tabla cambios_camiones_asignados
    CREATE OR REPLACE TRIGGER TgrGenIdCCA
      BEFORE INSERT ON CAMBIOS_CAMIONES_ASIGNADOS
      FOR EACH ROW
    BEGIN 
      :NEW.ID_AUDITORIA := SEQ_CAMBIOS_CAMIONES_ASIGNADOS.NEXTVAL;
    END TgrGenIdCCA;
    /
    show errors;

-- para la tabla TURNOS_DESCARGA
    CREATE OR REPLACE TRIGGER TgrGenIdTD
      BEFORE INSERT ON TURNOS_DESCARGA
      FOR EACH ROW
    BEGIN 
      :NEW.ID_TURNO := SEQ_TURNOS_DESCARGA.NEXTVAL;
    END TgrGenIdTD;
    /
    show errors;    
---- SECUENCIAS para generar ids

CREATE SEQUENCE SEQ_CAMIONES_VISITANTES
  START WITH 1
  INCREMENT BY 1
  NOMAXVALUE;


CREATE SEQUENCE SEQ_CAMBIOS_HISTORICO_VIAJES
  START WITH 1
  INCREMENT BY 1
  NOMAXVALUE;

CREATE SEQUENCE SEQ_CAMBIOS_CAMIONES_ASIGNADOS
  START WITH 1
  INCREMENT BY 1
  NOMAXVALUE;
      
CREATE SEQUENCE SEQ_TURNOS_DESCARGA
  START WITH 1
  INCREMENT BY 1
  NOMAXVALUE;
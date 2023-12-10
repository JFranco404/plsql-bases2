-- --------- TRIGGERS -------------

-- TRIGGER 1: Un trigger cuando un camión ingrese a la empresa, que actualice el estado del viaje ------
     
    -- Trigger que se disparará cada vez que un camión llegue a la empresa, enviando una actualización cualquiera,
    -- que una vez en el trigger llamará al SP que asignará el valor correcto
    CREATE OR REPLACE TRIGGER tgr_actualizar_estado
    BEFORE UPDATE OF ID_ESTADO ON HISTORICO_VIAJES --Esto genera mutacion cambiarlo
    FOR EACH ROW
    DECLARE
    v_placa CAMIONES.PLACA%TYPE;
    BEGIN
    
        SELECT id_camion
        INTO v_placa
        FROM CAMIONES_ASIGNADOS
        WHERE ID_ASIGNACION = :new.ID_ASIGNACION;
        
        SP_actualizarEstado(v_placa); --Esto genera mutacion cambiarlo
    END;
    /
    

    COMMIT;
-- TRIIGER 3: ------------------------------------ Un trigger cuando un camión ingrese a la empresa, que genere un turno de descarga

CREATE OR REPLACE TRIGGER Tgr_generar_turno_descarga
AFTER INSERT OR UPDATE ON HISTORICO_VIAJES
FOR EACH ROW

DECLARE

BEGIN
    select * 
    from turnos_descarga;
-- select 
END Tgr_generar_turno_descarga;
/


-- TRIIGER 5: ------------------------------------ Un trigger que lleve el control de cambios hechos en la base de datos (por cada tabla, es decir tenemos todos los triggers necesarios) 


CREATE TABLE CAMBIOS_HISTORICO_VIAJES(
    ID_AUDITORIA NUMBER NOT NULL PRIMARY KEY,
    ANTIGUOID_HISTORIAL NUMBER NOT NULL,
	ANTIGUOID_VIAJE NUMBER NOT NULL,
	ANTIGUOID_ASIGNACION NUMBER NOT NULL,
	ANTIGUOID_ESTADO NUMBER NOT NULL, 
	ANTIGUOTIEMPO_TEORICO INTERVAL DAY TO SECOND,
	ANTIGUOTIEMPO_REAL INTERVAL DAY TO SECOND,
	ANTIGUODESCRIPCION VARCHAR2(80),
    NUEVOID_HISTORIAL NUMBER NOT NULL,
	NUEVOID_VIAJE NUMBER NOT NULL,
	NUEVOID_ASIGNACION NUMBER NOT NULL,
	NUEVOID_ESTADO NUMBER NOT NULL, 
	NUEVOTIEMPO_TEORICO INTERVAL DAY TO SECOND,
	NUEVOTIEMPO_REAL INTERVAL DAY TO SECOND,
	NUEVODESCRIPCION VARCHAR2(80),
    FECHA DATE,
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

update historico_viajes 
set id_estado = 3
where id_historial = 1;

-- TRIIGER 7: ------------------------------------Un trigger que registre los cambios hechos en la tabla historico_viajes


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

---- SECUENCIAS para generar ids


CREATE SEQUENCE SEQ_CAMIONES_VISITANTES
  START WITH 1
  INCREMENT BY 1
  NOMAXVALUE;


CREATE SEQUENCE SEQ_CAMBIOS_HISTORICO_VIAJES
  START WITH 1
  INCREMENT BY 1
  NOMAXVALUE;

      
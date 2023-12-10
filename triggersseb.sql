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
    

    COMMIT
-- TRIIGER 3: ------------------------------------ Un trigger cuando un camión ingrese a la empresa, que genere un turno de descarga

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

CREATE OR REPLACE TRIGGER TRG_CAMBIOS_ESTUDIANTES
BEFORE INSERT OR UPDATE ON TU_TABLA
FOR EACH ROW
DECLARE
    ACCION VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        ACCION := 'INSERT';
    ELSIF UPDATING THEN
        ACCION := 'UPDATE';
    END IF;

    INSERT INTO AUDITORIA_CAMBIOS_ESTUDIANTES (
        ID_AUDITORIA,
        TIPO,
        TABLA,
        FECHA,
        ANTIGUOIDESTUDIANTE,
        ANTIGUODEPARTAMENTO,
        ANTIGUOCURSO,
        ANTIGUOGRADO,
        NUEVOIDESTUDIANTE,
        NUEVODEPARTAMENTO,
        NUEVONCURSO,
        NUEVOGRADO,
        CODIGO,
        ACCION_REALIZADA,
        USUARIO_CAMBIO
    ) VALUES (
        SEQ_AUDITORIA_CAMBIOS_ESTUDIANTES.NEXTVAL,
        :OLD.TIPO,
        :OLD.TABLA,
        :OLD.FECHA,
        :OLD.ANTIGUOIDESTUDIANTE,
        :OLD.ANTIGUODEPARTAMENTO,
        :OLD.ANTIGUOCURSO,
        :OLD.ANTIGUOGRADO,
        :NEW.NUEVOIDESTUDIANTE,
        :NEW.NUEVODEPARTAMENTO,
        :NEW.NUEVONCURSO,
        :NEW.NUEVOGRADO,
        :NEW.CODIGO,
        ACCION,
        USER
    );
END;
/


-- TRIIGER 7: ------------------------------------Un trigger que registre los cambios hechos en la tabla historico_viajes
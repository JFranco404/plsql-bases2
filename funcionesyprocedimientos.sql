--  -------------------------------PROCEDIMIENTOS-------------------------------
-- Procedimiento número 5 
CREATE OR REPLACE PROCEDURE registrarEntradaCamion (
    p_placa IN VARCHAR2
)
AS
    v_idCamion NUMBER;
    v_viajeInfo VARCHAR2(255);
    v_fecha_salida CAMIONES_VISITANTES.fecha_entrada%TYPE;
    v_fecha_entrada CAMIONES_VISITANTES.fecha_entrada%TYPE;
    v_tiempo_tardado NUMBER;
    v_tiempo_teorico VIAJES.duracion_estimada%TYPE;
    
    
BEGIN
    -- Obtener el ID del camión usando la placa
    SELECT placa 
    INTO v_idCamion
    FROM CAMIONES
    WHERE placa = p_placa;
    
    --Obtener la fecha_entrada 
    SELECT fecha_entrada
    INTO v_fecha_entrada
    FROM CAMIONES_VISITANTES
    WHERE placa = v_idCamion;
    
    --Obtener la fecha_salida
    SELECT fecha_salida
    INTO v_fecha_entrada
    FROM CAMIONES_VISITANTES
    WHERE placa = v_idCamion;
    
    
    IF v_idcamion is null then --comprobar si la placa del camión está registrada en el sistema y si no lo está comprobar si va entrando o saliendo el visitante
        IF v_fecha_entrada IS NULL then
            INSERT INTO CAMIONES_VISITANTES (placa, fecha_entrada, fecha_salida)
            VALUES (p_placa, SYSDATE, null);
        ELSIF v_fecha_salida IS NULL THEN -- Si la f
            UPDATE CAMIONES_VISITANTES c set fecha_salida = SYSDATE
            WHERE c.placa = v_idCamion;
        END IF;
    ELSE -- Es un camión de la empresa por lo tanto se obtiene la información de su viaje
        -- Obtener la información del viaje
        SELECT v.ciudad_origen || ' - ' || v.ciudad_destino || ', Carga: ' || tc.descripcion AS viaje_info, (sysdate - v_fecha_salida) tiempo_viaje
        INTO v_viajeInfo, v_tiempo_tardado 
        FROM historico_viajes hv
        INNER JOIN viajes v on v.id_viaje = hv.id_viaje
        INNER JOIN tipo_carga tc ON tc.id_tipo_carga = v.id_tipo_carga
        INNER JOIN camiones_asignados ca ON ca.id_camion = p_placa;
    END IF;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE(v_viajeInfo || ' tiempo teórico: '|| v_tiempo_teorico || 'tiempo real tardado: '|| v_tiempo_tardado);
END registrarEntradaCamion;
/

CREATE TABLE CAMIONES_VISITANTES (
    id NUMBER PRIMARY KEY,
    placa VARCHAR2(20) NOT NULL,
    fecha_entrada DATE,
    fecha_salida DATE
);

DROP TABLE CAMIONES_VISITANTES;

ALTER TABLE HISTORICO_VIAJES ADD FECHA_SALIDA DATE;
-- Procedimiento 7 ---------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE actualizar_conductor(
    p_placa IN CAMIONES_ASIGNADOS.ID_CAMION%TYPE,
    p_nuevo_conductor IN CAMIONES_ASIGNADOS.ID_CONDUCTOR%TYPE
)
AS
v_id_camion CAMIONES_ASIGNADOS.ID_CAMION%TYPE;
v_id_conductor CAMIONES_ASIGNADOS.ID_CONDUCTOR%TYPE;
BEGIN
--comprobar si existen ambos parámetros, camión y conductor

SELECT id_camion, id_conductor 
INTO v_id_camion, v_id_conductor
FROM CAMIONES_ASIGNADOS
WHERE id_camion = p_placa and id_conductor = p_nuevo_conductor;

IF v_id_camion IS NOT NULL and v_id_conductor IS NOT NULL then
    UPDATE CAMIONES_ASIGNADOS set id_camion = p_placa, id_conductor = p_nuevo_conductor;
ELSE
    RAISE_APPLICATION_ERROR(-20001, 'El conductor no está registrado en nuestro sistema, o el camión no se encuentra');
END IF;
END actualizar_conductor;
/

-- procedimiento 9 ---------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE SP_actualizarEstado (
    P_placa IN CAMIONES.PLACA%TYPE
)
AS 

V_estado HISTORICO_VIAJES.IDESTADO%TYPE;

BEGIN

SELECT ca.idestado
INTO v_estado --Obtener el estado del viaje del camión que ingresa o sale
FROM historico_viajes hv
INNER JOIN camiones_asignados ca ON ca.id_asignacion = hv.id_asignacion
where ca.id_camion = P_placa;


CASE
    WHEN v_estado = 1 THEN --Cuando un camion llegue el estado 1 es en curso, lo cambia a finalizado
        UPDATE historico_viajes 
        SET idestado = 2;
    WHEN v_estado = 3 THEN --Cuando un camion sale el estado 3 es en sin asignar, lo cambia a en cuurso
        UPDATE historico_viajes 
        SET idestado = 1;
    ELSE   
        RAISE_APPLICATION_ERROR(-20007, 'Tas loco papi');
  END CASE;

END SP_estadofinalizado;
/



-- Trigger máx id de CAMIONES_VISITANTES
      CREATE OR REPLACE TRIGGER TgrGenIdCV
      BEFORE INSERT ON CAMIONES_VISITANTES
      FOR EACH ROW
      
      BEGIN 
      SELECT MAX(ID)+1
      INTO :NEW.ID
      FROM CAMIONES_VISITANTES;
      END TgrGenId;
      /
      show errors;
      
      
      
--  -----------------------------FUNCIONES--------------------------------------

-- Funcion almacenada 1 --------------------------------------------------------

CREATE OR REPLACE FUNCTION FnOrigenViaje
(
Vplaca IN CAMIONES.PLACA%TYPE
)
RETURN VARCHAR2
AS
Origen VARCHAR2(50);

BEGIN

SELECT CIUDAD_ORIGEN 
INTO Origen
FROM CAMIONES_ASIGNADOS CA
INNER JOIN HISTORICO_VIAJES HV ON CA.ID_ASIGNACION = HV.ID_ASIGNACION
INNER JOIN VIAJES V ON V.ID_VIAJE = HV.ID_VIAJE
WHERE CA.ID_CAMION = Vplaca;

RETURN Origen;
END FnOrigenViaje;
/
SHOW ERRORS;

SELECT FNFiltro('HIS',101,'A')
FROM DUAL;

-- Funcion almacenada 3 --------------------------------------------------------

CREATE OR REPLACE FUNCTION FnDetalleCarga
(
    Vplaca IN CAMIONES.PLACA%TYPE
)
RETURN CLOB
AS
    carga CLOB:='';
BEGIN
    -- tipo de carga, peso y destino.
    SELECT 'Tipo carga: '|| TC.descripcion || ' || '||'Peso: '|| V.PESO_CARGA_KG || ' || ' || V.CIUDAD_DESTINO
    INTO carga
    FROM CAMIONES_ASIGNADOS CA
    INNER JOIN HISTORICO_VIAJES HV ON CA.ID_ASIGNACION = HV.ID_ASIGNACION
    INNER JOIN VIAJES V ON V.ID_VIAJE = HV.ID_VIAJE
    INNER JOIN TIPO_CARGA TC ON V.ID_TIPO_CARGA = TC.ID_TIPO_CARGA
    WHERE CA.ID_CAMION = Vplaca;
    
    RETURN carga; 
END FnDetalleCarga;
/
SHOW ERRORS;
--Cambios
ALTER TABLE VIAJES ADD PESO_CARGA_KG NUMBER;

-- Funcion almacenada 5 --------------------------------------------------------
    --El trigger TR_CALCULAR_TIEMPO_TEORICO ya cumple esa función
-- Funcion almacenada 7 --------------------------------------------------------
    -- Una función almacenada que me permita conocer cuál es la ciudad de donde vienen la mayor cantidad de viajes

    CREATE OR REPLACE FUNCTION FnCiudadMasViajes
    RETURN VARCHAR2
    AS
        ciudad VIAJES.CIUDAD_DESTINO%TYPE;
    BEGIN
        -- ciudad con más viajes
        SELECT ciudad_origen 
        INTO ciudad
        FROM (
            SELECT v.ciudad_origen, count(*) AS CANTIDAD_VIAJES
            FROM VIAJES V
            WHERE v.ciudad_destino = 'Manizales' 
            GROUP BY v.ciudad_origen
            ORDER BY count(*) DESC
            )
        WHERE ROWNUM = 1;
        
        RETURN ciudad; 
    END FnCiudadMasViajes;
    /
     
    SHOW ERRORS;
-- Funcion almacenada 9 --------------------------------------------------------
    -- Una función almacenada que me permita conocer cuál es la carga que más se transporta en la empresa
    CREATE OR REPLACE FUNCTION FnCargaMasTransportada
    RETURN VIAJES.ID_TIPO_CARGA%TYPE
    AS
        carga VIAJES.ID_TIPO_CARGA%TYPE;
    BEGIN
        -- carga mas transportada
        SELECT id_tipo_carga --, peso_carga_kg, CANTIDAD por si se quiere devolver algo más que solo el id del más buscado (se necesitan más variables)
        INTO carga
        FROM (
            SELECT v.id_tipo_carga, v.peso_carga_kg, count(*) AS CANTIDAD
            FROM VIAJES V
            GROUP BY v.peso_carga_kg, v.id_tipo_carga
            ORDER BY count(*) DESC
            )
        WHERE ROWNUM = 1;
        
        RETURN carga; 
    END FnCargaMasTransportada;
    /
    SHOW ERRORS;
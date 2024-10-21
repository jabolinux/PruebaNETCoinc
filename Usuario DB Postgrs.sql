--
-- PostgreSQL database dump
--

-- Dumped from database version 14.13 (Ubuntu 14.13-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.13 (Ubuntu 14.13-0ubuntu0.22.04.1)

-- Started on 2024-10-21 17:54:15 -05

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 220 (class 1255 OID 103560)
-- Name: actualizar_ubicacion(integer, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actualizar_ubicacion(IN p_idubicacion integer, IN p_idpais integer, IN p_iddepartamento integer, IN p_idmunicipio integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE Ubicacion 
    SET IdPais = p_idpais,
        IdDepartamento = p_iddepartamento,
        IdMunicipio = p_idmunicipio
    WHERE IdUbicacion = p_idubicacion;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ubicación con ID % no encontrada', p_idubicacion;
    END IF;
END;
$$;


ALTER PROCEDURE public.actualizar_ubicacion(IN p_idubicacion integer, IN p_idpais integer, IN p_iddepartamento integer, IN p_idmunicipio integer) OWNER TO postgres;

--
-- TOC entry 219 (class 1255 OID 103561)
-- Name: actualizar_usuario(integer, character varying, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actualizar_usuario(IN p_idusuario integer, IN p_nombre character varying, IN p_telefono character varying, IN p_direccion character varying, IN p_idubicacion integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE Usuario 
    SET Nombre = p_nombre,
        Telefono = p_telefono,
        Direccion = p_direccion,
        IdUbicacion = p_idubicacion
    WHERE IdUsuario = p_idusuario;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Usuario con ID % no encontrado', p_idusuario;
    END IF;
END;
$$;


ALTER PROCEDURE public.actualizar_usuario(IN p_idusuario integer, IN p_nombre character varying, IN p_telefono character varying, IN p_direccion character varying, IN p_idubicacion integer) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 103559)
-- Name: eliminar_ubicacion(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.eliminar_ubicacion(IN p_idubicacion integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_count integer;
BEGIN
    -- Verificar si la ubicación está siendo utilizada
    SELECT COUNT(*) INTO v_count
    FROM Usuario
    WHERE IdUbicacion = p_idubicacion;
    
    IF v_count > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar la ubicación porque está siendo utilizada por % usuario(s)', v_count;
    END IF;

    DELETE FROM Ubicacion 
    WHERE IdUbicacion = p_idubicacion;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ubicación con ID % no encontrada', p_idubicacion;
    END IF;
END;
$$;


ALTER PROCEDURE public.eliminar_ubicacion(IN p_idubicacion integer) OWNER TO postgres;

--
-- TOC entry 221 (class 1255 OID 103562)
-- Name: eliminar_usuario(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.eliminar_usuario(IN p_idusuario integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Usuario 
    WHERE IdUsuario = p_idusuario;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Usuario con ID % no encontrado', p_idusuario;
    END IF;
END;
$$;


ALTER PROCEDURE public.eliminar_usuario(IN p_idusuario integer) OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 103554)
-- Name: insertar_ubicacion(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insertar_ubicacion(IN p_idpais integer, IN p_iddepartamento integer, IN p_idmunicipio integer, OUT p_idubicacion integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_pais_existente INT;
    v_departamento_existente INT;
BEGIN
    -- Verificar si el Departamento ya está asociado a un país diferente
    SELECT IdPais INTO v_pais_existente
    FROM Departamento
    WHERE IdDepartamento = p_iddepartamento;

    IF v_pais_existente IS NOT NULL AND v_pais_existente <> p_idpais THEN
        RAISE EXCEPTION 'El Departamento ya está asociado a un País diferente. Por favor elimine o actualice primero.';
    END IF;

    -- Verificar si el Municipio ya está asociado a un Departamento diferente
    SELECT IdDepartamento INTO v_departamento_existente
    FROM Municipio
    WHERE IdMunicipio = p_idmunicipio;

    IF v_departamento_existente IS NOT NULL AND v_departamento_existente <> p_iddepartamento THEN
        RAISE EXCEPTION 'El Municipio ya está asociado a un Departamento diferente. Por favor elimine o actualice primero.';
    END IF;

    -- Verificar si la ubicación ya existe
    SELECT IdUbicacion INTO p_idubicacion
    FROM Ubicacion
    WHERE IdPais = p_idpais
      AND IdDepartamento = p_iddepartamento
      AND IdMunicipio = p_idmunicipio;

    -- Si la ubicación no existe, insertarla
    IF p_idubicacion IS NULL THEN
        INSERT INTO Ubicacion (IdPais, IdDepartamento, IdMunicipio)
        VALUES (p_idpais, p_iddepartamento, p_idmunicipio)
        RETURNING IdUbicacion INTO p_idubicacion;
    END IF;
END;
$$;


ALTER PROCEDURE public.insertar_ubicacion(IN p_idpais integer, IN p_iddepartamento integer, IN p_idmunicipio integer, OUT p_idubicacion integer) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 103555)
-- Name: insertar_usuario(character varying, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insertar_usuario(IN p_nombre character varying, IN p_telefono character varying, IN p_direccion character varying, IN p_idubicacion integer, OUT p_idusuario integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_ubicacion_exists boolean;
BEGIN
    -- Verificar si la ubicación ya existe
    SELECT EXISTS(SELECT 1 FROM Ubicacion WHERE IdUbicacion = p_idubicacion) INTO v_ubicacion_exists;

    -- Si no existe la ubicación, retornar un error
    IF NOT v_ubicacion_exists THEN
        RAISE EXCEPTION 'La ubicación con IdUbicacion % no existe.', p_idubicacion;
    END IF;

    -- Verificar si el usuario ya existe
    SELECT IdUsuario INTO p_idusuario
    FROM Usuario
    WHERE Nombre = p_nombre
      AND Telefono = p_telefono
      AND Direccion = p_direccion
      AND IdUbicacion = p_idubicacion;

    -- Si no existe el usuario, insertarlo
    IF p_idusuario IS NULL THEN
        INSERT INTO Usuario (Nombre, Telefono, Direccion, IdUbicacion)
        VALUES (p_nombre, p_telefono, p_direccion, p_idubicacion)
        RETURNING IdUsuario INTO p_idusuario;
    END IF;
END;
$$;


ALTER PROCEDURE public.insertar_usuario(IN p_nombre character varying, IN p_telefono character varying, IN p_direccion character varying, IN p_idubicacion integer, OUT p_idusuario integer) OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 103558)
-- Name: obtener_informacion_usuario(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.obtener_informacion_usuario(p_idusuario integer) RETURNS TABLE(nombre character varying, telefono character varying, direccion character varying, pais character varying, departamento character varying, municipio character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.Nombre,
        u.Telefono,
        u.Direccion,
        p.NombrePais,
        d.NombreDepartamento,
        m.NombreMunicipio
    FROM Usuario u
    JOIN Ubicacion ub ON u.IdUbicacion = ub.IdUbicacion
    JOIN Pais p ON ub.IdPais = p.IdPais
    JOIN Departamento d ON ub.IdDepartamento = d.IdDepartamento
    JOIN Municipio m ON ub.IdMunicipio = m.IdMunicipio
    WHERE u.IdUsuario = p_IdUsuario;
END;
$$;


ALTER FUNCTION public.obtener_informacion_usuario(p_idusuario integer) OWNER TO postgres;

--
-- TOC entry 225 (class 1255 OID 103479)
-- Name: obtenerinformacionusuario(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.obtenerinformacionusuario(p_idusuario integer) RETURNS TABLE(nombre character varying, telefono character varying, direccion character varying, pais character varying, departamento character varying, municipio character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.Nombre,
        u.Telefono,
        u.Direccion,
        p.NombrePais,
        d.NombreDepartamento,
        m.NombreMunicipio
    FROM Usuario u
    JOIN Ubicacion ub ON u.IdUbicacion = ub.IdUbicacion
    JOIN Pais p ON ub.IdPais = p.IdPais
    JOIN Departamento d ON ub.IdDepartamento = d.IdDepartamento
    JOIN Municipio m ON ub.IdMunicipio = m.IdMunicipio
    WHERE u.IdUsuario = p_IdUsuario;
END;
$$;


ALTER FUNCTION public.obtenerinformacionusuario(p_idusuario integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 214 (class 1259 OID 103498)
-- Name: departamento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departamento (
    iddepartamento integer NOT NULL,
    nombredepartamento character varying(100) NOT NULL,
    idpais integer
);


ALTER TABLE public.departamento OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 103497)
-- Name: departamento_iddepartamento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departamento_iddepartamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.departamento_iddepartamento_seq OWNER TO postgres;

--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 213
-- Name: departamento_iddepartamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departamento_iddepartamento_seq OWNED BY public.departamento.iddepartamento;


--
-- TOC entry 216 (class 1259 OID 103510)
-- Name: municipio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.municipio (
    idmunicipio integer NOT NULL,
    nombremunicipio character varying(100) NOT NULL,
    iddepartamento integer
);


ALTER TABLE public.municipio OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 103509)
-- Name: municipio_idmunicipio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.municipio_idmunicipio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.municipio_idmunicipio_seq OWNER TO postgres;

--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 215
-- Name: municipio_idmunicipio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.municipio_idmunicipio_seq OWNED BY public.municipio.idmunicipio;


--
-- TOC entry 212 (class 1259 OID 103491)
-- Name: pais; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pais (
    idpais integer NOT NULL,
    nombrepais character varying(100) NOT NULL
);


ALTER TABLE public.pais OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 103490)
-- Name: pais_idpais_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pais_idpais_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pais_idpais_seq OWNER TO postgres;

--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 211
-- Name: pais_idpais_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pais_idpais_seq OWNED BY public.pais.idpais;


--
-- TOC entry 218 (class 1259 OID 103522)
-- Name: ubicacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ubicacion (
    idubicacion integer NOT NULL,
    idpais integer,
    iddepartamento integer,
    idmunicipio integer
);


ALTER TABLE public.ubicacion OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 103521)
-- Name: ubicacion_idubicacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ubicacion_idubicacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ubicacion_idubicacion_seq OWNER TO postgres;

--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 217
-- Name: ubicacion_idubicacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ubicacion_idubicacion_seq OWNED BY public.ubicacion.idubicacion;


--
-- TOC entry 210 (class 1259 OID 103484)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    idusuario integer NOT NULL,
    nombre character varying(100) NOT NULL,
    telefono character varying(20),
    direccion character varying(200),
    idubicacion integer
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 103483)
-- Name: usuario_idusuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_idusuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usuario_idusuario_seq OWNER TO postgres;

--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 209
-- Name: usuario_idusuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_idusuario_seq OWNED BY public.usuario.idusuario;


--
-- TOC entry 3361 (class 2604 OID 103501)
-- Name: departamento iddepartamento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamento ALTER COLUMN iddepartamento SET DEFAULT nextval('public.departamento_iddepartamento_seq'::regclass);


--
-- TOC entry 3362 (class 2604 OID 103513)
-- Name: municipio idmunicipio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.municipio ALTER COLUMN idmunicipio SET DEFAULT nextval('public.municipio_idmunicipio_seq'::regclass);


--
-- TOC entry 3360 (class 2604 OID 103494)
-- Name: pais idpais; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pais ALTER COLUMN idpais SET DEFAULT nextval('public.pais_idpais_seq'::regclass);


--
-- TOC entry 3363 (class 2604 OID 103525)
-- Name: ubicacion idubicacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ubicacion ALTER COLUMN idubicacion SET DEFAULT nextval('public.ubicacion_idubicacion_seq'::regclass);


--
-- TOC entry 3359 (class 2604 OID 103487)
-- Name: usuario idusuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN idusuario SET DEFAULT nextval('public.usuario_idusuario_seq'::regclass);


--
-- TOC entry 3530 (class 0 OID 103498)
-- Dependencies: 214
-- Data for Name: departamento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departamento (iddepartamento, nombredepartamento, idpais) FROM stdin;
1	Buenos Aires	1
2	Córdoba	1
3	São Paulo	2
4	Rio de Janeiro	2
5	Santiago	3
6	Valparaíso	3
7	Bogotá	4
8	Antioquia	4
9	Valle del Cauca	4
\.


--
-- TOC entry 3532 (class 0 OID 103510)
-- Dependencies: 216
-- Data for Name: municipio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.municipio (idmunicipio, nombremunicipio, iddepartamento) FROM stdin;
1	Capital Federal	1
2	Villa Carlos Paz	2
3	Campinas	3
4	Niterói	4
5	Santiago	5
6	Viña del Mar	6
7	Bogotá	7
8	Medellín	8
9	Cali	9
\.


--
-- TOC entry 3528 (class 0 OID 103491)
-- Dependencies: 212
-- Data for Name: pais; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pais (idpais, nombrepais) FROM stdin;
1	Argentina
2	Brasil
3	Chile
4	Colombia
\.


--
-- TOC entry 3534 (class 0 OID 103522)
-- Dependencies: 218
-- Data for Name: ubicacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ubicacion (idubicacion, idpais, iddepartamento, idmunicipio) FROM stdin;
1	1	1	1
2	1	2	2
3	2	3	3
4	2	4	4
5	3	5	5
6	3	6	6
7	4	7	7
8	4	8	8
9	4	9	9
\.


--
-- TOC entry 3526 (class 0 OID 103484)
-- Dependencies: 210
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (idusuario, nombre, telefono, direccion, idubicacion) FROM stdin;
1	Juan Pérez	123456789	Calle Falsa 123	1
2	María González	987654321	Avenida Siempreviva 456	2
3	Carlos López	456789123	Diagonal Norte 789	3
4	Luisa Martínez	321654987	Carrera 50 #20-30	7
5	Pedro Sánchez	654987321	Calle 10 #15-20	8
6	Ana Jiménez	789321654	Calle 72 #22-15	9
7	Jorge Herrera	852741963	Carrera 30 #80-10	5
8	Laura Ruiz	963258741	Calle 13 #100-25	6
\.


--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 213
-- Name: departamento_iddepartamento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departamento_iddepartamento_seq', 9, true);


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 215
-- Name: municipio_idmunicipio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.municipio_idmunicipio_seq', 9, true);


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 211
-- Name: pais_idpais_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pais_idpais_seq', 4, true);


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 217
-- Name: ubicacion_idubicacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ubicacion_idubicacion_seq', 9, true);


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 209
-- Name: usuario_idusuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_idusuario_seq', 8, true);


--
-- TOC entry 3369 (class 2606 OID 103503)
-- Name: departamento departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT departamento_pkey PRIMARY KEY (iddepartamento);


--
-- TOC entry 3371 (class 2606 OID 103515)
-- Name: municipio municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_pkey PRIMARY KEY (idmunicipio);


--
-- TOC entry 3367 (class 2606 OID 103496)
-- Name: pais pais_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pais
    ADD CONSTRAINT pais_pkey PRIMARY KEY (idpais);


--
-- TOC entry 3373 (class 2606 OID 103527)
-- Name: ubicacion ubicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ubicacion
    ADD CONSTRAINT ubicacion_pkey PRIMARY KEY (idubicacion);


--
-- TOC entry 3375 (class 2606 OID 103549)
-- Name: ubicacion uc_ubicacion; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ubicacion
    ADD CONSTRAINT uc_ubicacion UNIQUE (idpais, iddepartamento, idmunicipio);


--
-- TOC entry 3377 (class 2606 OID 103553)
-- Name: ubicacion uc_ubicaciondpunique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ubicacion
    ADD CONSTRAINT uc_ubicaciondpunique UNIQUE (iddepartamento, idpais);


--
-- TOC entry 3379 (class 2606 OID 103551)
-- Name: ubicacion uc_ubicacionmd; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ubicacion
    ADD CONSTRAINT uc_ubicacionmd UNIQUE (iddepartamento, idmunicipio);


--
-- TOC entry 3365 (class 2606 OID 103489)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (idusuario);


--
-- TOC entry 3381 (class 2606 OID 103504)
-- Name: departamento departamento_idpais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT departamento_idpais_fkey FOREIGN KEY (idpais) REFERENCES public.pais(idpais);


--
-- TOC entry 3380 (class 2606 OID 103543)
-- Name: usuario fk_usuario_ubicacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_usuario_ubicacion FOREIGN KEY (idubicacion) REFERENCES public.ubicacion(idubicacion);


--
-- TOC entry 3382 (class 2606 OID 103516)
-- Name: municipio municipio_iddepartamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_iddepartamento_fkey FOREIGN KEY (iddepartamento) REFERENCES public.departamento(iddepartamento);


--
-- TOC entry 3384 (class 2606 OID 103533)
-- Name: ubicacion ubicacion_iddepartamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ubicacion
    ADD CONSTRAINT ubicacion_iddepartamento_fkey FOREIGN KEY (iddepartamento) REFERENCES public.departamento(iddepartamento);


--
-- TOC entry 3385 (class 2606 OID 103538)
-- Name: ubicacion ubicacion_idmunicipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ubicacion
    ADD CONSTRAINT ubicacion_idmunicipio_fkey FOREIGN KEY (idmunicipio) REFERENCES public.municipio(idmunicipio);


--
-- TOC entry 3383 (class 2606 OID 103528)
-- Name: ubicacion ubicacion_idpais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ubicacion
    ADD CONSTRAINT ubicacion_idpais_fkey FOREIGN KEY (idpais) REFERENCES public.pais(idpais);


-- Completed on 2024-10-21 17:54:15 -05

--
-- PostgreSQL database dump complete
--


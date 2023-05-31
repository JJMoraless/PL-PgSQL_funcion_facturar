-- SELECT factura('1','1','1','1','1','1','1','3');

CREATE OR REPLACE FUNCTION factura( wid_cliente tab_clientes.id_cliente%TYPE,
                                    wfor_pago   tab_enc_fact.for_pago%TYPE,
                                    wid_prod1 tab_det_fact.id_prod%TYPE,
                                    wid_prod2 tab_det_fact.id_prod%TYPE,
                                    wid_prod3 tab_det_fact.id_prod%TYPE,
                                    wcant_prod1 tab_det_fact.cant_prod%TYPE,
                                    wcant_prod2 tab_det_fact.cant_prod%TYPE,
                                    wcant_prod3 tab_det_fact.cant_prod%TYPE)
                                    RETURNS BOOLEAN AS
$$
    DECLARE 
        varId_ciudad SMALLINT;
        varId_cliente BIGINT;
        fecha_hoy DATE;
        id_fac INTEGER;
        varid_empresa SMALLINT;
        varValor_total BIGINT;

		--PRODUCTOS
        varValorProduct1 INTEGER;
        varValorProduct2 INTEGER;
        varValorProduct3 INTEGER;
		--VALOR BRUTO PRODUCTOS
        valorBruto1 BIGINT;
        valorBruto2 BIGINT;
        valorBruto3 BIGINT;
		--IVA PRODUCTO
		isIva1	BOOLEAN;
		isIva2	BOOLEAN;
		isIva3	BOOLEAN;
		
		--
		_products         		INTEGER[][];
		
		_isIva 		      		BOOLEAN;
		_isPromo				BOLEAN;	
		
		_porce_iva		  		DECIMAL(2,0);
		_porce_descue			DECIMAL(3,0);
		_porce_product			DECIMAL(3,0);
		
		_valor_iva		  		BIGINT;	
		_valor_porce			BIGINT;
		
		_precio_venta_producto  BIGINT;
		_valor_bruto	  		INTEGER; 
		_stock_producto   		INTEGER;		
		
		
    BEGIN
		--id_empresa
        SELECT id_empresa INTO varid_empresa FROM tab_pmtros;
		
		-- valor total
        varValor_total = 0;
		
		-- fecha hoy
        fecha_hoy := CURRENT_DATE;
		
		--ciudad
        SELECT id_ciudad INTO varId_ciudad FROM tab_clientes WHERE id_cliente = wid_cliente;
		
		--id factura
        SELECT num_factura INTO id_fac FROM tab_pmtros;
		id_fac = id_fac + 1 ;
		UPDATE tab_pmtros SET num_factura = id_fac WHERE id_empresa = varid_empresa;
		
-- 		--ENCABEZADO FACTURA
		INSERT INTO tab_enc_fact VALUES(id_fac,wid_cliente,fecha_hoy,varId_ciudad,wfor_pago,varValor_total); 




        --  REFACTORIZADO CON UN FOR (NO PROBADO)
        SELECT val_preciovta INTO varValorProduct1 FROM tab_prod WHERE id_prod = wid_prod1;
        SELECT val_preciovta INTO varValorProduct2 FROM tab_prod WHERE id_prod = wid_prod2;
        SELECT val_preciovta INTO varValorProduct3 FROM tab_prod WHERE id_prod = wid_prod3;

        valorBruto1 = varValorProduct1 * wcant_prod1;
        valorBruto2 = varValorProduct2 * wcant_prod2;
        valorBruto3 = varValorProduct3 * wcant_prod3;
			
		_products := ARRAY[
			ARRAY[wid_prod1,wcant_prod1 ],
			ARRAY[wid_prod2,wcant_prod2 ],
			ARRAY[wid_prod3,wcant_prod3]
		 ];
		--        _porce_iva
			SELECT por_iva INTO _porce_iva  FROM tab_pmtros;
			SELECT por_desc INTO _porce_descue  FROM tab_pmtros;
			
			
		FOR i IN 1..3 LOOP
			SELECT ind_iva INTO _isIva FROM tab_prod WHERE id_prod = _products[I][1];
			SELECT ind_promocion INTO _isPromo FROM tab_prod WHERE id_prod = _products[I][1];
			SELECT val_preciovta INTO _precio_venta_producto FROM tab_prod WHERE id_prod = _products[I][1];
			

			_valor_bruto = _precio_venta_producto * _products[I][2];

			IF ind_iva THEN
				_valor_iva := _valor_bruto * (_porce_iva / 100);
			ELSE
				_valor_iva := 0;
			END IF;
			
			
			IF ind_promocion THEN
				_valor_porce := _valor_bruto * (_porce_product / 100);
			ELSE
				_valor_iva := 0;
			END IF;
			
			

-- 			INSERT INTO tab_det_fact VALUES(id_fac,_products[I][1],_products[I][2],);
			
			
			
		END LOOP;


		RETURN TRUE;
    END;
$$
LANGUAGE PLPGSQL;
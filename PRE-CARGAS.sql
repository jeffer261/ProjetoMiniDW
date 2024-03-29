
use MINIDW
--TABELAS DIMENSAO
--DIMENSAO MATERIAL
SELECT A.COD_MAT,
       A.DESCRICAO,
       A.PRECO_UNIT,
	   A.ID_FOR,
	   B.DESC_TIP_MAT 
	  -- INTO D_MATERIAL
FROM MINIERP.DBO.MATERIAL A
INNER JOIN MINIERP.DBO.TIPO_MAT B
ON A.COD_TIP_MAT=B.COD_TIP_MAT

--DIMENSAO CLIENTE

SELECT A.ID_CLIENTE,
       A.RAZAO_CLIENTE,
	   A.TIPO_CLIENTE,
	   A.COD_CIDADE
	--   INTO D_CLIENTES
       FROM MINIERP.DBO.CLIENTES A
--DIMENSAO FORNECEDORES
SELECT A.ID_FOR,
       A.RAZAO_FORNEC,
	   A.TIPO_FORNEC,
	   A.COD_CIDADE
	 -- INTO D_FORNECEDORES
       FROM MINIERP.DBO.FORNECEDORES A
--DIMENSAO VENDEDORES
SELECT A.ID_VEND,
       A.MATRICULA,B.NOME
   --   INTO D_VENDEDORES
 FROM MINIERP.DBO.VENDEDORES A
 INNER JOIN MINIERP.DBO.FUNCIONARIO B
 ON A.MATRICULA=B.MATRICULA
--DIMENSAO GERENTES
SELECT A.ID_GER,
       A.MATRICULA,B.NOME
    --  INTO D_GERENTES
 FROM MINIERP.DBO.GERENTES A
 INNER JOIN MINIERP.DBO.FUNCIONARIO B
 ON A.MATRICULA=B.MATRICULA

--DIMENSAO CANAL_VENDAS
SELECT * 
--INTO D_CANAL_VENDAS
FROM MINIERP.DBO.V_CANAL_VENDAS

--DIMENSAO CONDICOES DE PAGTO
SELECT A.COD_PAGTO,
       A.NOME_CP,
	   B.DIAS,
	   B.PCT,
	   B.PARC
	   --INTO D_COND_PAGTO
 FROM  MINIERP.DBO.COND_PAGTO A
 INNER JOIN MINIERP.DBO.COND_PAGTO_DET B
 ON A.COD_PAGTO=B.COD_PAGTO

--FATOS
--CRIACAO TABELA FATO DE FATURAMENTO
IF OBJECT_ID ('MINIDW.dbo.F_FATURAMENTO') IS NOT NULL
DROP TABLE F_FATURAMENTO

SELECT A.NUM_NF,
       A.DATA_EMISSAO,
       A.ID_CLIFOR ID_CLIENTE,
	   A.COD_MAT,
       A.QTD,
	   A.VAL_UNIT,
	   A.TOTAL
	   INTO F_FATURAMENTO
	   FROM MINIERP.DBO.V_FATURAMENTO A


--CONTAS RECEBER
IF OBJECT_ID ('MINIDW.dbo.F_CONTAS_RECEBER') IS NOT NULL
DROP TABLE F_CONTAS_RECEBER

SELECT A.ID_DOC,
       A.ID_CLIENTE,
	   A.PARC,
	   A.DATA_VENC,
	   A.DATA_PAGTO,
	   A.VALOR,
	   A.SITUACAO,
	   A.MSG,
	   A.DIAS_ATRASO
	   INTO F_CONTAS_RECEBER
      FROM MINIERP.DBO.V_CONTAS_RECEBER A

-- CONTAS PAGAR
IF OBJECT_ID ('MINIDW.dbo.F_CONTAS_PAGAR') IS NOT NULL
DROP TABLE F_CONTAS_PAGAR

SELECT A.ID_DOC,
       A.ID_FOR,
	   A.PARC,
	   A.DATA_VENC,
	   A.DATA_PAGTO,
	   A.VALOR,
	   A.SITUACAO,
	   A.MSG
	  INTO F_CONTAS_PAGAR
      FROM MINIERP.DBO.V_CONTAS_PAGAR A

--PED_VENDAS

SELECT A.NUM_PEDIDO,
       A.ID_CLIENTE,
	   A.COD_PAGTO,
	   A.DATA_PEDIDO,
       A.DATA_ENTREGA,
	   A.SITUACAO,
	   A.TOTAL_PED
	   --INTO F_PED_VENDAS
	   FROM MINIERP.DBO.PED_VENDAS A

--PED_COMPRAS
SELECT A.NUM_PEDIDO,
       A.ID_FOR,
	   A.COD_PAGTO,
	   A.DATA_PEDIDO,
       A.DATA_ENTREGA,
	   A.SITUACAO,
	   A.TOTAL_PED
	 --  INTO F_PED_COMPRAS
	   FROM MINIERP.DBO.PED_COMPRAS A


--ESTOQUE
SELECT A.COD_MAT,
       QTD_SALDO 
	--   INTO F_ESTOQUE
    FROM MINIERP.DBO.ESTOQUE A

--META

SELECT  A.ID_VEND,A.ANO,A.MES,A.VALOR
--  INTO F_META_VENDA
FROM MINIERP.DBO.META_VENDAS A

--FATO META X FATO 2017
SELECT A.ID_VEND,
       B.NOME_VEND,
	   A.ANO,
	   A.MES,
	   A.VALOR META,
	   SUM(ISNULL(C.TOTAL,0))REALIZ,
       CAST(100/A.VALOR*SUM(ISNULL(C.TOTAL,0)) AS DECIMAL(10,2))PCT
	 --  INTO F_META_VENDA_2017
  FROM MINIERP.DBO.META_VENDAS A
  LEFT JOIN MINIERP.DBO.V_CANAL_VENDAS B
  ON A.ID_VEND=B.ID_VEND
  LEFT JOIN  MINICRM.DBO.V_CRM_FAT_RESUMO C
  ON B.ID_CLIENTE=C.ID_CLIFOR
  AND A.MES=C.MES
  AND A.ANO=C.ANO
  WHERE A.ANO=2017
  GROUP BY  A.ID_VEND,
       B.NOME_VEND,
	   A.ANO,
	   A.MES,
	   A.VALOR,
	   100/A.VALOR



--CRM
--AGENDAS RESUMO
SELECT A.MATRICULA,
       A.NOME_VEND,
	   A.RAZAO_CLIENTE,
	   A.SITUACAO,
	   A.QTD_VISITAS,
	   A.GEROU_VENDA
    --   INTO F_AGENDAS_RESUMO
FROM MINICRM.DBO.V_CRM_AGENDAS_RESUMO A

--AGENDA DETALHE

SELECT A.ID_AGENDA,
       A.MATRICULA,
       A.NOME_VEND,
	   A.RAZAO_CLIENTE,
	   A.DATA_VISITA,
	   A.SITUACAO,
	   1 QTD_VISITAS,
	   A.GEROU_VENDA 
	  -- INTO F_AGENDA_DETALHE
FROM MINICRM.DBO.V_CRM_AGENDAS_DETALHE A
----FLUXO DE CAIXA


SELECT SYSTEM_USER
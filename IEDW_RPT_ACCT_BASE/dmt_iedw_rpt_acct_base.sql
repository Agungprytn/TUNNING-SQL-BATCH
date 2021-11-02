-- sqlplus  $DBUSER/$DBPASS@$DBNAME @/ihobis/dw/batch/datamart/dmt_iedw_rpt_acct_base.sql JDMT000200 20170222
-- sqlplus misadm/inni0821@INOANMIS @/inoan/dw/batch/datamart/dmt_iedw_rpt_acct_base.sql JDMT000200 20170222
 --------------------------------------------------------------------------------
 -- Program Name : IEDW_RPT_ACCT_BASE
 -- Description  :
 -- Parameters   : 1. JOB ID
 --------------------------------------------------------------------------------
 -- Created Date : 2015. 11.
 -- Creator      :
 --------------------------------------------------------------------------------
 -- Memo         :
 --------------------------------------------------------------------------------
 SET SERVEROUTPUT ON SIZE 1000000
 SET LINESIZE 200
 SET TIMING   ON
 SET TERMOUT  ON

 BEGIN
      DECLARE
             i       NUMBER;

             --------------------------------------------------------------------
             -- 변수선언부
             --------------------------------------------------------------------
             -- 로그관리용 변수
             V_PROC_DT                    VARCHAR2(8)  ;
             V_BAT_JOB_ID                 VARCHAR2(10) ;
             V_RUN_SEQ_NO                 NUMBER(5)    ;
             V_PROC_ST_CD                 CHAR(1)      ;
             V_ERR_MSG_CTT                VARCHAR2(500);
             V_PROC_CNT                   NUMBER(10)   ;
             V_BAT_PGM_ID                 VARCHAR2(10) ;
             V_PROC_BASC_DT               VARCHAR2(8)  ;
             V_PGM_FILE_PATH              VARCHAR2(100);
             V_PARM_INFO_CTT              VARCHAR2(100);


						 V_TABLE_OWNER                VARCHAR2(30); -- 테이블 OWNER
             V_TABLE_NAME                 VARCHAR2(30); -- 테이블명
             V_PARTITION_NAME             VARCHAR2(30); -- 파티션명

             V_LST_SEQ_NO                 NUMBER   ;
             V_PROC_EOM_DT                VARCHAR2(8);       --당월말일(Calendar)
             V_EOM_BIZ_DT                 VARCHAR2(8);       --당월말영업일

             V_RPT_CYC_CD                 CHAR(1)      ;     --보고주기코드

     BEGIN

             DBMS_output.put_line('====================================================================');
             DBMS_output.put_line('--A.배치작업 HEAD START');
             DBMS_output.put_line('====================================================================');
             --------------------------------------------------------------------
             -- 변수설정부
             --------------------------------------------------------------------

             --------------------------------------------------------------------
             DBMS_output.put_line('--[HEAD] STEP1 파라미터설정');
             --------------------------------------------------------------------
             V_PARM_INFO_CTT := '&1' || ' ' || '&2'  ;  --파라미터정보(JOB ID)
             V_BAT_JOB_ID    := '&1';                 --JOB ID
             V_PROC_BASC_DT  := '&2';             --보고서주기코드
						
             DBMS_output.put_line('V_PROC_BASC_DT : ' || V_PROC_BASC_DT);
             DBMS_output.put_line('V_RPT_CYC_CD   : ' || V_RPT_CYC_CD);


             --------------------------------------------------------------------
             DBMS_output.put_line('--[HEAD] STEP2 변수설정');
             --------------------------------------------------------------------
             V_PROC_DT         := TO_CHAR(SYSDATE,'YYYYMMDD'); --처리일(시스템일)
             V_PROC_CNT        := 0;                           --처리건수(초기화)

             --------------------------------------------------------------------
             DBMS_output.put_line('--[HEAD] STEP3 연산변수설정');
             --------------------------------------------------------------------


             V_PROC_EOM_DT  := TO_CHAR(LAST_DAY(TO_DATE( V_PROC_BASC_DT,   'YYYYMMDD')  ), 'YYYYMMDD') ;
             V_EOM_BIZ_DT   := TO_CHAR(GET_BIZ_DAY_F(TO_DATE(V_PROC_EOM_DT,'YYYYMMDD'),0), 'YYYYMMDD') ;

             DBMS_output.put_line('V_PROC_EOM_DT  : ' || V_PROC_EOM_DT);
             DBMS_output.put_line('V_EOM_BIZ_DT   : ' || V_EOM_BIZ_DT );

						 V_TABLE_OWNER    := 'MISADM';
             V_TABLE_NAME     := 'IEDW_RPT_ACCT_BASE';
             V_PARTITION_NAME := 'IEDW_RPT_ACCT_BASE_' || SUBSTR(V_PROC_BASC_DT ,3 );  -- IEDW_RPT_ACCT_BAL_YYMMDD (IEDW_RPT_ACCT_BAL_210308)
						 
						 DBMS_output.put_line('V_TABLE_OWNER    : ' || V_TABLE_OWNER    );
             DBMS_output.put_line('V_TABLE_NAME     : ' || V_TABLE_NAME     );	
						 DBMS_output.put_line('V_PARTITION_NAME : ' || V_PARTITION_NAME );	
							
						 
             --마지막영업일이면 보고서주기코드를 M(월)로 변경
             IF V_EOM_BIZ_DT = V_PROC_BASC_DT THEN

                V_RPT_CYC_CD    := 'M';                 --보고서주기코드
                DBMS_output.put_line('마지막영업일이면 보고서주기코드를 M(월)로 자동변경' );
                DBMS_output.put_line('V_RPT_CYC_CD   : ' || V_RPT_CYC_CD );

             END IF;


             --------------------------------------------------------------------
             DBMS_output.put_line('--[HEAD] STEP4 실행순번채번');
             --------------------------------------------------------------------
             --로그실행순번채번
             V_RUN_SEQ_NO := GET_LOG_SEQ_F(V_BAT_JOB_ID);


             --------------------------------------------------------------------
             DBMS_output.put_line('--[HEAD] 로그 INSERT : 처리중');
             --------------------------------------------------------------------
             V_PROC_ST_CD := '1'; --(1:처리중 2:처리완료 3:에러발생)
             IEDW_BAT_JOB_LOG_P( V_PROC_DT, V_BAT_JOB_ID, V_RUN_SEQ_NO, V_PROC_ST_CD, V_ERR_MSG_CTT, V_PROC_CNT,  V_PROC_BASC_DT,  V_PARM_INFO_CTT);

             DBMS_output.put_line('====================================================================');
             DBMS_output.put_line('--B.배치작업 BODY START');
             DBMS_output.put_line('====================================================================');

             --------------------------------------------------------------------
             DBMS_output.put_line('--[BODY] STEP1. Delete data.                '||V_PARTITION_NAME||'            '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
             --DELETE
             --FROM  IEDW_RPT_ACCT_BASE
             --WHERE  BASC_DT = V_PROC_BASC_DT
             --;
             
             
					   -- PARTITION TRUNCATE
             SP_TABLE_PARTITION_TRUNCATE (V_TABLE_OWNER, V_TABLE_NAME, V_PARTITION_NAME);
						 
             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);


             --------------------------------------------------------------------
             DBMS_output.put_line('--2-1. IEDW_RPT_ACCT_BASE                      '||V_PARTITION_NAME||'         '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------

			             INSERT /*+ APPEND */ INTO IEDW_RPT_ACCT_BASE (
			                    BASC_DT
			             ,      SUBJ_CD
			             ,      REF_NO
			             ,      ISYS_UPD_DTM
			             ,      ACT_DV_CD
			             ,      CUST_NO
			             ,      CUST_NM
			             ,      LN_ORG_USG_CD
			             ,      LN_SID_BIZ_SCTR_CD
			             ,      LN_LBU_BIZ_SCTR_CD
			             ,      PRD_CD
			             ,      PRD_DTLS_CD
			             ,      CLS_DT 
			             ,      BR_CD 
			             ,      CUR_CD
			             ,      SUGT_EMP_NO
			             ,      APV_NO
			             )
			             SELECT
			                    V_PROC_BASC_DT    AS BASC_DT
			             ,      A.SUBJ_CD         AS SUBJ_CD
			             ,      A.REF_NO          AS REF_NO
			             ,      SYSDATE           AS ISYS_UPD_DTM
			             ,      CASE WHEN A.CUST_NO = '0200999999' THEN '2' -- except andara link toal account 
			                         ELSE A.ACT_DV_CD 
			                    END     AS ACT_DV_CD
			             ,      A.CUST_NO         AS CUST_NO
			             ,      B.CUST_ENM        AS CUST_NM
			             ,      NULL              AS LN_ORG_USG_CD
			             ,      NULL              AS LN_SID_BIZ_SCTR_CD
			             ,      NULL              AS LN_LBU_BIZ_SCTR_CD
			             ,      A.PRD_CD          AS PRD_CD
			             ,      A.PRD_DTLS_CD     AS PRD_DTLS_CD 
			             ,      A.CLS_DT          AS CLS_DT    
			             ,      A.BR_CD           AS BR_CD    
			             ,      A.CUR_CD          AS CUR_CD    
			             ,      A.SUGT_EMP_NO     AS SUGT_EMP_NO
			             ,      A.APV_NO          AS APV_NO
			             FROM   (
						           SELECT 
						                  CASE WHEN A.SUBJ_CD IN ('11','12','13','14')
			 					               THEN 'DP'
			                                   WHEN A.SUBJ_CD = 'LN'
			 					               AND  A.PRD_CD  LIKE '0309%'
			 					               THEN 'GT'
			                                   WHEN A.SUBJ_CD = 'FD'
			 					               THEN 'FE'
			                                   ELSE SUBJ_CD
										  END  AS   SUBJ_CD
								   ,      A.REF_NO              AS REF_NO
								   ,      CASE WHEN A.STS IN ('0','2')
			                                   THEN '1'
			                                   ELSE '2'
			                              END                   AS ACT_DV_CD
			                       ,      A.CIX_NO              AS CUST_NO
			                       ,      1                     AS SEQ
			                       ,      PRD_CD                AS PRD_CD
			                       ,      CASE WHEN A.SUBJ_CD IN ('11','12','13','14')
			 					               THEN A.SUBJ_CD
										  END                   AS PRD_DTLS_CD
								   ,      TO_CHAR(A.CONT_END_DT,'YYYYMMDD')  AS CLS_DT 		   
								   ,      A.MGNT_BR_NO                       AS BR_CD 		   
								   ,      A.CUR_CD                           AS CUR_CD 		   
								   ,      A.SUGT_EMP_NO                      AS SUGT_EMP_NO
								   ,      A.LIM_APV_NO                       AS APV_NO
								   FROM   IDSS_ACOM_CONT_BASE A
								   WHERE  A.BASC_DT = V_PROC_BASC_DT
								   AND    A.STS    !=  '1'
								   AND    A.SUBJ_CD != 'DP' --  Pseudo Account
								   AND    NVL(A.CONT_END_DT,SYSDATE) > ADD_MONTHS(TO_DATE(V_PROC_BASC_DT,'YYYYMMDD'),-12)
					               UNION ALL
								   --DEPOSIT AND LOAN
								   SELECT 
								          'LN'  AS SUBJ_CD
								   ,      B.REF_NO              AS REF_NO
								   ,      CASE WHEN B.STS IN ('0','2')
			                                   THEN '1'
			                                   ELSE '2'
			                              END                   AS ACT_DV_CD
			                       ,      B.CIX_NO              AS CUST_NO
			                       ,      ROW_NUMBER() OVER (PARTITION BY A.ACCT_NO ORDER BY A.LON_CONT_IL DESC, A.STS  ) AS SEQ
			                       ,      PRD_CD                AS PRD_CD
			                       ,      B.SUBJ_CD             AS PRD_DTLS_CD 
			                       ,      TO_CHAR(B.CONT_END_DT,'YYYYMMDD')  AS CLS_DT 
			                       ,      B.MGNT_BR_NO                       AS BR_CD 	
								   ,      B.CUR_CD                           AS CUR_CD 	
								   ,      B.SUGT_EMP_NO                      AS SUGT_EMP_NO	   
								   ,      B.LIM_APV_NO                       AS APV_NO  
								   FROM   IDSS_ADST_DPB_LNIF A
			                       ,      IDSS_ACOM_CONT_BASE B
			                       WHERE  A.BASC_DT = V_PROC_BASC_DT
			                       AND    A.BASC_DT = B.BASC_DT
			                       AND    A.ACCT_NO = B.REF_NO
			                       AND    B.STS != '1'
								   AND    NVL(B.CONT_END_DT,SYSDATE) > ADD_MONTHS(TO_DATE(V_PROC_BASC_DT,'YYYYMMDD'),-12)
			                     ) A
			             ,       IDSS_ACOM_CIX_BASE B
						 WHERE   A.CUST_NO  = B.CIX_NO
						 AND     B.BASC_DT = V_PROC_BASC_DT
						 AND     A.SEQ           = 1
						 ;


						 DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;


             COMMIT;


             --------------------------------------------------------------------
              DBMS_output.put_line('--[BODY] STEP-000  PRE_GATHER_TABLE_STATS  [START]      '||V_PARTITION_NAME||'       '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
						 
             DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>V_TABLE_OWNER, TABNAME=>V_TABLE_NAME, PARTNAME=>V_PARTITION_NAME, DEGREE=>8, ESTIMATE_PERCENT=>5, CASCADE=>TRUE, METHOD_OPT=>'FOR ALL INDEXED COLUMNS', GRANULARITY=>'PARTITION', NO_INVALIDATE=>FALSE);
             

             --------------------------------------------------------------------
              DBMS_output.put_line('--[BODY] STEP-000  PRE_GATHER_TABLE_STATS  [ END ]      '||V_PARTITION_NAME||'       '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
						 

             -- 13314201 Government Bond Reverse Repo HTM  2016.07  
             -- DBI0888216016004
             -- DBI0888216016005 
             
             UPDATE IEDW_RPT_ACCT_BASE
             SET    CUST_NO = '0000019854'	--BANK INDONESIA
             ,      SUBJ_CD = 'FB'
             ,      NEW_DT  = '20160728'	
             ,      FST_NEW_DT  = '20160728'	
             ,      EXP_DT  = '20160811'	
             ,      FST_EXP_DT  = '20160811'	
             WHERE  BASC_DT = V_PROC_BASC_DT
             AND    MAN_COA_CD = '13314201' --Government Bond Reverse Repo HTM  2016.07 
             AND    REF_NO IN ( 'DBI0888216016004'
                              , 'DBI0888216016005'
                              )
             ;
             
             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;


             COMMIT;

			     ------------------------------------------------------------------------------------------
		       DBMS_output.put_line('--2-2. IEDW_RPT_ACCT_BASE   UPDATE            '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
			     DBMS_output.put_line('       LN_ORG_USG_CD                          ');
			     DBMS_output.put_line('       LN_SID_BIZ_SCTR_CD                     ');
			     DBMS_output.put_line('		  LN_LBU_BIZ_SCTR_CD                     ');
			     ------------------------------------------------------------------------------------------


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                    SELECT 
                           A.BASC_DT 
                    ,      A.SUBJ_CD 
                    ,      A.REF_NO   
                    -- 
                    ,      B.LN_ORG_USG_CD                     AS NEW_LN_ORG_USG_CD
                    ,      B.LN_SID_BIZ_SCTR_CD                AS NEW_LN_SID_BIZ_SCTR_CD
                    ,      B.LN_LBU_BIZ_SCTR_CD                AS NEW_LN_LBU_BIZ_SCTR_CD
                    FROM   IEDW_RPT_ACCT_BASE A
                    ,      (
                            SELECT /*+ ORDERED USE_HASH(A B) INDEX(A ADST_LNB_LRPT_PK ) INDEX(B ADST_LNB_LRPT_PK )*/
                                   DISTINCT    -- @@@ 중복발생 추가함
                                   A.REF_NO         AS REF_NO
                            ,      A.ORT_USG        AS LN_ORG_USG_CD
                            ,      A.ECON_SECT      AS LN_SID_BIZ_SCTR_CD
                            ,      A.ECO_SCTR       AS LN_LBU_BIZ_SCTR_CD
			                      FROM   IDSS_ADST_LNB_LRPT A
                            ,      IDSS_ADST_LNB_BASE B
                            WHERE  A.BASC_DT  = V_PROC_BASC_DT
                            AND    A.BASC_DT  = B.BASC_DT
							              AND    A.REF_NO   = B.AGR_REF_NO
                            AND    A.ORT_USG IN ('1','2','9')  --1.EKSPOR, 2.IMPOR, 9.OTHERS
                           ) B
                    WHERE  A.BASC_DT          = V_PROC_BASC_DT
                    AND    A.REF_NO           = B.REF_NO
                    AND    A.SUBJ_CD          = 'LN'
                  
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.LN_ORG_USG_CD         = B.NEW_LN_ORG_USG_CD   
             ,            A.LN_SID_BIZ_SCTR_CD    = B.NEW_LN_SID_BIZ_SCTR_CD 
             ,            A.LN_LBU_BIZ_SCTR_CD    = B.NEW_LN_LBU_BIZ_SCTR_CD 
             ;


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;



             -------------------------------------------------------------------
             DBMS_output.put_line('--2-3.  PRD_NM (상품명)        UPDATE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             -------------------------------------------------------------------


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (                         
                    SELECT
                           A.BASC_DT 
                    ,      A.SUBJ_CD 
                    ,      A.REF_NO   
                    ,      NVL(B.PRD_ENG_NM,B.PRD_NM)     AS NEW_PRD_NM
                    FROM   IEDW_RPT_ACCT_BASE  A
                    ,      IEDW_UNFY_PRD_BASE  B
                    WHERE  A.PRD_CD  = B.PRD_CD
                    AND    A.SUBJ_CD  = B.SUBJ_CD
                    AND    A.BASC_DT = V_PROC_BASC_DT
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.PRD_NM         = B.NEW_PRD_NM    
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;


             -------------------------------------------------------------------
             DBMS_output.put_line('--2-4.  PRD_DTLS_CD UPDATE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             -------------------------------------------------------------------
             -- IP



             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (                         
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     ,      B.IP_CD  AS NEW_PRD_DTLS_CD
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFEX_IPB_BASE     B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'IP'
                     ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.PRD_DTLS_CD         = B.NEW_PRD_DTLS_CD    
             ;
 


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

             -- XP
	           /* UPDATE BYPASS에서 MERGE로 변경 - 20170309 유윤식 */
             /*
             UPDATE *+ BYPASS_UJVC *  (
                     SELECT A.SUBJ_CD
                     ,      A.REF_NO
                     ,      A.PRD_DTLS_CD
                     ,      B.NEGO_GB||B.XP_GB||B.TENOR_GB  AS NEW_PRD_DTLS_CD
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFEX_XPB_BASE      B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'XP'
             )
             SET     PRD_DTLS_CD = NEW_PRD_DTLS_CD
             ;
	     */


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --  
                     ,      B.NEGO_GB||B.XP_GB||B.TENOR_GB  AS NEW_PRD_DTLS_CD
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFEX_XPB_BASE     B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'XP'
              
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.PRD_DTLS_CD         = B.NEW_PRD_DTLS_CD    
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

             -- FB



             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --  
                     ,      C.BOND_TYPE        AS NEW_PRD_DTLS_CD
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFIF_FBH_BUY      B
                     ,      IDSS_AFIF_FBH_BASE     C
                     WHERE  A.BASC_DT      = B.BASC_DT
                     AND    B.BASC_DT      = C.BASC_DT
                     AND    A.REF_NO       = B.REF_NO
                     AND    B.SECURITY_ID  = C.SECURITY_ID
                     AND    A.BASC_DT      = V_PROC_BASC_DT
                     AND    A.SUBJ_CD      = 'FB'
              
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.PRD_DTLS_CD         = B.NEW_PRD_DTLS_CD    
             ;




             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;


             -- MM


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --   
                     ,      B.BORROW_LON_GB  AS NEW_PRD_DTLS_CD
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFIF_MMH_BASE     B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'MM'
              
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.PRD_DTLS_CD         = B.NEW_PRD_DTLS_CD    
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

             -- FE




             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --    
                     ,      B.DEAL_TYPE        AS NEW_PRD_DTLS_CD
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFIF_FEH_BASE     B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'FE'
              
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.PRD_DTLS_CD         = B.NEW_PRD_DTLS_CD    
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

             -- FN



             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --    
                     ,      B.LEND_GB        AS NEW_PRD_DTLS_CD
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFIF_FNH_BASE      B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'FN'
              
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.PRD_DTLS_CD         = B.NEW_PRD_DTLS_CD    
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;


             --------------------------------------------------------------------
             DBMS_output.put_line('--2-5. BR_CD               '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     MAN_COA_CD          '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     MAN_COA_NM          '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     BAL_DTLS_DV_CD UPDATE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
	  

             -- Don't Delete HINT , If you want change Hint , Ask to Manager first (SJH)
             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                   SELECT /*+ ORDERED USE_HASH(A B) */
                          A.BASC_DT 
                   ,      A.SUBJ_CD 
                   ,      A.REF_NO   
                   -- 
                   ,      B.BR_CD          AS NEW_BR_CD
                   ,      B.MAN_COA_CD     AS NEW_MAN_COA_CD
                   ,      B.MAN_COA_NM     AS NEW_MAN_COA_NM
                   ,      B.BAL_DTLS_DV_CD AS NEW_BAL_DTLS_DV_CD
                   FROM   IEDW_RPT_ACCT_BASE A
                   ,      (
                           SELECT /*+ ORDERED USE_HASH(A B C D) */
                                  A.REF_NO         AS REF_NO  
                           ,      C.BR_NO          AS BR_CD  
                           ,      A.SUBJ_CD        AS SUBJ_CD
                           ,      B.BAL_DTLS_DV_CD AS BAL_DTLS_DV_CD
                           ,      C.ATIT_CD        AS MAN_COA_CD
                           ,      D.COA_NM         AS MAN_COA_NM
                           ,      ROW_NUMBER() OVER (PARTITION BY A.SUBJ_CD, A.REF_NO ORDER BY B.MAPP_BAL_TYP_CD, C.BAL_AMT DESC ,C.APCL_STR_DT DESC ) AS SEQ
                           FROM   IEDW_RPT_ACCT_BASE A
                           ,      IEDW_SUBJ_BAL_REL B
                           ,      INRT_AACT_TRX_BAL C
                           ,      IEDW_UNFY_GLCOA_BASE D
                           WHERE  A.SUBJ_CD          = B.SUBJ_CD
                           AND    B.BAL_DTLS_DV_CD   = C.DTLS_BAL_DV_CD
                           AND    A.REF_NO           = C.REF_NO
                           AND    C.ATIT_CD          = D.COA_CD
                           AND    A.BASC_DT          = V_PROC_BASC_DT
                           AND    D.COA_GRP_CD       = '1'
                           AND    C.APCL_STR_DT     <= TO_DATE(V_PROC_BASC_DT,'YYYYMMDD')
                           AND    C.APCL_END_DT     >= TO_DATE(V_PROC_BASC_DT,'YYYYMMDD')
                           AND    SUBSTR(C.ATIT_CD,1,1)||NVL(A.SUBJ_CD,'XX') NOT IN ('1DP','2LN')
                          ) B
                  WHERE   A.SUBJ_CD = B.SUBJ_CD
                  AND     A.REF_NO  = B.REF_NO
                  AND     A.BASC_DT = V_PROC_BASC_DT
                  AND     B.SEQ     = 1
              
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.BR_CD          =  B.NEW_BR_CD
             ,            A.MAN_COA_CD     =  B.NEW_MAN_COA_CD
             ,            A.MAN_COA_NM     =  B.NEW_MAN_COA_NM
             ,            A.BAL_DTLS_DV_CD =  B.NEW_BAL_DTLS_DV_CD
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;
             
 
             -------------------------------------------------------------------
             DBMS_output.put_line('--2-6.  PRD_GRP_CD UPDATE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--      PRD_GRP_NM UPDATE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             -------------------------------------------------------------------



             MERGE  INTO IEDW_RPT_ACCT_BASE A
             USING (     
                     
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --  
                     ,      B.PRD_GRP_CD  AS NEW_PRD_GRP_CD
                     ,      C.PRD_GRP_NM  AS NEW_PRD_GRP_NM
                     FROM   IEDW_RPT_ACCT_BASE    A
                     ,      IEDW_UNFY_PRDGRP_MAP  B
                     ,      IEDW_UNFY_PRDGRP_BASE C
                     WHERE  A.BASC_DT    = V_PROC_BASC_DT
                     AND    A.PRD_CD     = B.PRD_CD
                     AND    B.PRD_GRP_CD = C.PRD_GRP_CD
                     AND    SUBSTR(A.MAN_COA_CD,1,1)||SUBSTR(B.PRD_GRP_CD,1,1) NOT IN ('7D','1D','2L')
                     AND    B.PRD_GRP_CD NOT LIKE  'D9%'
                     AND    B.PRD_GRP_CD NOT LIKE  'L9%'
                     AND    A.MAN_COA_CD IS NOT NULL
             
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.PRD_GRP_CD      =  B.NEW_PRD_GRP_CD
             ,            A.PRD_GRP_NM      =  B.NEW_PRD_GRP_NM 
             ;




             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

            
             
            --------------------------------------------------------------------
             DBMS_output.put_line('--2-8. NEW_DT               '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     FST_NEW_DT           '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     EXP_DT               '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     FST_EXP_DT           '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     NEW_AMT              '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     INT_RT      UPDATE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
           
           	
           	 --------------------------------------------------------------------
           	 DBMS_output.put_line('-- 2-8-1    Deposit           '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
           	 --------------------------------------------------------------------
             
             -- DP	  

             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --  
                     ,      TO_CHAR(NVL(B.ROLL_OVER_IL, B.OPN_IL)      ,'YYYYMMDD') AS NEW_NEW_DT    
                     ,      TO_CHAR(B.OPN_IL           ,'YYYYMMDD') AS NEW_FST_NEW_DT
                     ,      TO_CHAR(B.DPT_MAN_IL       ,'YYYYMMDD') AS NEW_EXP_DT    
                     ,      TO_CHAR(B.DPT_MAN_IL       ,'YYYYMMDD') AS NEW_FST_EXP_DT
                     ,      B.OPEN_AMT                              AS NEW_NEW_AMT    
                     ,      NVL(B.DPT_BASIC_RT,0) + NVL(B.DPT_NEGO_RT,0)  AS NEW_INT_RT
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_ADST_DPB_BASE     B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.ACCT_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'DP' 
            
             
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.NEW_DT      = B.NEW_NEW_DT    
             ,            A.FST_NEW_DT  = B.NEW_FST_NEW_DT
             ,            A.EXP_DT      = B.NEW_EXP_DT    
             ,            A.FST_EXP_DT  = B.NEW_FST_EXP_DT
             ,            A.NEW_AMT     = B.NEW_NEW_AMT    
             ,            A.INT_RT      = B.NEW_INT_RT  
             ;


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;


			 --------------------------------------------------------------------
           	 DBMS_output.put_line('-- 2-8-2     LN (Non - Deposit Loan)           '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
           	 --------------------------------------------------------------------

             -- LN (Non - Deposit Loan)
			 
			 
			  MERGE /*+ LEADING(A B) USE_HASH(A B) PARALLEL(A 4) FULL(A) PARALLEL(B 4) FULL(B) */ 
				INTO IEDW_RPT_ACCT_BASE A
			  USING  IDSS_ADST_LNB_BASE B
				ON      ( A.BASC_DT  = V_PROC_BASC_DT   AND  
						  A.BASC_DT  = B.BASC_DT        AND            
						  A.SUBJ_CD  = 'LN'             AND
						  A.REF_NO   = B.REF_NO                         
						)                 
				WHEN MATCHED THEN   
					UPDATE SET   A.NEW_DT      = TO_CHAR(B.OPEN_IL      ,'YYYYMMDD')    
					     ,       A.FST_NEW_DT  = TO_CHAR(B.OPEN_IL      ,'YYYYMMDD') 
					     ,       A.EXP_DT      = TO_CHAR(B.TOT_EXP_IL   ,'YYYYMMDD') 
					     ,       A.FST_EXP_DT  = TO_CHAR(B.TOT_EXP_IL   ,'YYYYMMDD') 
					     ,       A.NEW_AMT     = B.FST_LON_AMT                       
					     ,       A.INT_RT      = B.LST_RT         
					
				;

            -- MERGE INTO IEDW_RPT_ACCT_BASE A
            -- USING (     
            --        
            --         SELECT  /*+ LEADING(B A) USE_HASH(B A) */
            --                A.BASC_DT 
            --         ,      A.SUBJ_CD 
            --         ,      A.REF_NO   
            --         --   
            --         ,      TO_CHAR(B.OPEN_IL      ,'YYYYMMDD') AS NEW_NEW_DT    
            --         ,      TO_CHAR(B.OPEN_IL      ,'YYYYMMDD') AS NEW_FST_NEW_DT
            --         ,      TO_CHAR(B.TOT_EXP_IL   ,'YYYYMMDD') AS NEW_EXP_DT    
            --         ,      TO_CHAR(B.TOT_EXP_IL   ,'YYYYMMDD') AS NEW_FST_EXP_DT
            --         ,      B.FST_LON_AMT                       AS NEW_NEW_AMT    
            --         ,      B.LST_RT                            AS NEW_INT_RT
            --         FROM   IEDW_RPT_ACCT_BASE     A
            --         ,      IDSS_ADST_LNB_BASE     B
            --         WHERE  A.BASC_DT = B.BASC_DT
            --         AND    A.REF_NO  = B.REF_NO
            --         AND    A.BASC_DT = V_PROC_BASC_DT
            --         AND    A.SUBJ_CD = 'LN' 
            -- 
            --    ) B
            -- ON      ( A.BASC_DT            = B.BASC_DT        AND 
            --           A.SUBJ_CD            = B.SUBJ_CD        AND
            --           A.REF_NO             = B.REF_NO  )   
            --               
            -- WHEN MATCHED THEN   
            -- UPDATE SET   A.NEW_DT      = B.NEW_NEW_DT    
            -- ,            A.FST_NEW_DT  = B.NEW_FST_NEW_DT
            -- ,            A.EXP_DT      = B.NEW_EXP_DT    
            -- ,            A.FST_EXP_DT  = B.NEW_FST_EXP_DT
            -- ,            A.NEW_AMT     = B.NEW_NEW_AMT    
            -- ,            A.INT_RT      = B.NEW_INT_RT  
            -- ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;



	           --------------------------------------------------------------------
           	 DBMS_output.put_line('-- 2-8-3     LN (Deposit Loan)           '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
           	 --------------------------------------------------------------------
            
             -- LN (Deposit Loan)
	     

             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --    
                     ,      TO_CHAR(B.LON_CONT_IL      ,'YYYYMMDD') AS NEW_NEW_DT    
                     ,      TO_CHAR(B.LON_CONT_IL      ,'YYYYMMDD') AS NEW_FST_NEW_DT
                     ,      TO_CHAR(B.LON_MAN_IL       ,'YYYYMMDD') AS NEW_EXP_DT    
                     ,      TO_CHAR(B.LON_MAN_IL       ,'YYYYMMDD') AS NEW_FST_EXP_DT
                     ,      B.LON_SNG_AMT                           AS NEW_NEW_AMT    
                     ,      B.LON_RT                                AS NEW_INT_RT
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      ( SELECT A.*
                              ,      ROW_NUMBER() OVER (PARTITION BY ACCT_NO ORDER BY LON_CONT_IL DESC, STS  ) AS SEQ
                              FROM   IDSS_ADST_DPB_LNIF A
                              WHERE  BASC_DT = V_PROC_BASC_DT
                            ) B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.ACCT_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'LN' 
                     AND    B.SEQ     = 1
             
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.NEW_DT      = B.NEW_NEW_DT    
             ,            A.FST_NEW_DT  = B.NEW_FST_NEW_DT
             ,            A.EXP_DT      = B.NEW_EXP_DT    
             ,            A.FST_EXP_DT  = B.NEW_FST_EXP_DT
             ,            A.NEW_AMT     = B.NEW_NEW_AMT    
             ,            A.INT_RT      = B.NEW_INT_RT  
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;
             
             
	           --------------------------------------------------------------------
           	 DBMS_output.put_line('-- 2-8-4     LN (Agree)          '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
           	 --------------------------------------------------------------------

             -- LN (Agree)
	    


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --   
                     ,      TO_CHAR(B.CONTRACT_IL      ,'YYYYMMDD') AS NEW_NEW_DT    
                     ,      TO_CHAR(B.CONTRACT_IL      ,'YYYYMMDD') AS NEW_FST_NEW_DT
                     ,      TO_CHAR(B.TOT_EXP_IL       ,'YYYYMMDD') AS NEW_EXP_DT    
                     ,      TO_CHAR(B.TOT_EXP_IL       ,'YYYYMMDD') AS NEW_FST_EXP_DT
                     ,      B.CONTRACT_AMT                             AS NEW_NEW_AMT    
                     ,      NULL                                    AS NEW_INT_RT
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_ADST_LNB_AGR      B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'LN'  
             
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.NEW_DT      = B.NEW_NEW_DT    
             ,            A.FST_NEW_DT  = B.NEW_FST_NEW_DT
             ,            A.EXP_DT      = B.NEW_EXP_DT    
             ,            A.FST_EXP_DT  = B.NEW_FST_EXP_DT
             ,            A.NEW_AMT     = B.NEW_NEW_AMT    
             ,            A.INT_RT      = B.NEW_INT_RT  
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;



	           --------------------------------------------------------------------
           	 DBMS_output.put_line('-- 2-8-5     GT (Agree)          '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
           	 --------------------------------------------------------------------
           	 
             -- GT (Agree)
	     



             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --  
                     ,      TO_CHAR(B.OPEN_IL          ,'YYYYMMDD') AS NEW_NEW_DT    
                     ,      TO_CHAR(B.OPEN_IL          ,'YYYYMMDD') AS NEW_FST_NEW_DT
                     ,      TO_CHAR(B.TOT_EXP_IL       ,'YYYYMMDD') AS NEW_EXP_DT    
                     ,      TO_CHAR(B.TOT_EXP_IL       ,'YYYYMMDD') AS NEW_FST_EXP_DT
                     ,      B.FST_GT_AMT                               AS NEW_NEW_AMT    
                     ,      B.LST_RT                                    AS NEW_INT_RT
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_ADST_GTB_BASE      B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'GT'  
              
             
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.NEW_DT      = B.NEW_NEW_DT    
             ,            A.FST_NEW_DT  = B.NEW_FST_NEW_DT
             ,            A.EXP_DT      = B.NEW_EXP_DT    
             ,            A.FST_EXP_DT  = B.NEW_FST_EXP_DT
             ,            A.NEW_AMT     = B.NEW_NEW_AMT    
             ,            A.INT_RT      = B.NEW_INT_RT  
             ;


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

	           --------------------------------------------------------------------
           	 DBMS_output.put_line('-- 2-8-6     IP          '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
           	 --------------------------------------------------------------------
             -- IP
	    


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --   
                     ,      TO_CHAR(B.OPEN_IL      ,'YYYYMMDD') AS NEW_NEW_DT    
                     ,      TO_CHAR(B.OPEN_IL      ,'YYYYMMDD') AS NEW_FST_NEW_DT
                     ,      TO_CHAR(B.EXP_IL       ,'YYYYMMDD') AS NEW_EXP_DT    
                     ,      TO_CHAR(B.EXP_IL       ,'YYYYMMDD') AS NEW_FST_EXP_DT
                     ,      B.OPEN_AMT                          AS NEW_NEW_AMT    
                     ,      B.TC_FRT                                    AS NEW_INT_RT
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFEX_IPB_BASE     B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'IP' 
              
             
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.NEW_DT      = B.NEW_NEW_DT    
             ,            A.FST_NEW_DT  = B.NEW_FST_NEW_DT
             ,            A.EXP_DT      = B.NEW_EXP_DT    
             ,            A.FST_EXP_DT  = B.NEW_FST_EXP_DT
             ,            A.NEW_AMT     = B.NEW_NEW_AMT    
             ,            A.INT_RT      = B.NEW_INT_RT  
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;
 
 
 
	           --------------------------------------------------------------------
           	 DBMS_output.put_line('-- 2-8-7     XP          '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
           	 -------------------------------------------------------------------- 
             -- XP
	    

             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --   
                     ,      TO_CHAR(B.NEGO_IL      ,'YYYYMMDD') AS NEW_NEW_DT    
                     ,      TO_CHAR(B.NEGO_IL      ,'YYYYMMDD') AS NEW_FST_NEW_DT
                     ,      TO_CHAR(NVL(B.HMAN_IL, B.YMAN_IL), 'YYYYMMDD')  AS NEW_EXP_DT    
                     ,      TO_CHAR(NVL(B.HMAN_IL, B.YMAN_IL), 'YYYYMMDD')  AS NEW_FST_EXP_DT
                     ,      B.NEGO_AMT  AS NEW_NEW_AMT    
                     ,      B.INT_RT                                    AS NEW_INT_RT
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFEX_XPB_BASE     B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'XP' 
              
             
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.NEW_DT      = B.NEW_NEW_DT    
             ,            A.FST_NEW_DT  = B.NEW_FST_NEW_DT
             ,            A.EXP_DT      = B.NEW_EXP_DT    
             ,            A.FST_EXP_DT  = B.NEW_FST_EXP_DT
             ,            A.NEW_AMT     = B.NEW_NEW_AMT    
             ,            A.INT_RT      = B.NEW_INT_RT  
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;



	           --------------------------------------------------------------------
           	 DBMS_output.put_line('-- 2-8-8     FB          '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
           	 --------------------------------------------------------------------
             -- FB
	   

             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --   
                     ,      TO_CHAR(B.VALUE_IL, 'YYYYMMDD') AS NEW_NEW_DT    
                     ,      TO_CHAR(B.VALUE_IL, 'YYYYMMDD') AS NEW_FST_NEW_DT
                     ,      TO_CHAR(B.EXP_IL  , 'YYYYMMDD') AS NEW_EXP_DT    
                     ,      TO_CHAR(B.EXP_IL  , 'YYYYMMDD') AS NEW_FST_EXP_DT
                     ,      CASE WHEN C.COUPON_STYLE = '1'
                                 AND  C.DISCOUNT_RT != 0   --SBI
                                 THEN B.BUY_AMT
                                 ELSE (B.NOMINAL_AMT * B.BUY_PRICE / 100)
                            END AS NEW_NEW_AMT    
                     ,      D.TOTAL_RT                                    AS NEW_INT_RT
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFIF_FBH_BUY      B
                     ,      IDSS_AFIF_FBH_BASE     C
                     ,      ( 
                             SELECT DISTINCT
                                    REF_NO
                             ,      TOTAL_RT
                             ,      ROW_NUMBER() OVER (PARTITION BY REF_NO ORDER BY PROCESS_YN  DESC ) AS SEQ 
                             FROM   IDSS_AFIF_FBH_INT
                             WHERE  BASC_DT      =  (SELECT MAX(BASC_DT) FROM IDSS_AFIF_FBH_INT)
                             AND    STS          = '0'
                             AND    INT_FROM_IL <= TO_DATE(V_PROC_BASC_DT,'YYYYMMDD')
                             AND    INT_TO_IL    >  TO_DATE(V_PROC_BASC_DT,'YYYYMMDD') 
                             AND    CCY          IS NOT NULL 
                            ) D 
                     WHERE  A.BASC_DT      = B.BASC_DT
                     AND    A.REF_NO       = B.REF_NO
                     AND    B.BASC_DT      = C.BASC_DT
                     AND    B.SECURITY_ID  = C.SECURITY_ID
                     AND    A.REF_NO       = D.REF_NO (+)
                     AND    D.SEQ(+)       = 1
                     AND    A.BASC_DT      = V_PROC_BASC_DT
                     AND    A.SUBJ_CD      = 'FB' 
              
             
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.NEW_DT      = B.NEW_NEW_DT    
             ,            A.FST_NEW_DT  = B.NEW_FST_NEW_DT
             ,            A.EXP_DT      = B.NEW_EXP_DT    
             ,            A.FST_EXP_DT  = B.NEW_FST_EXP_DT
             ,            A.NEW_AMT     = B.NEW_NEW_AMT    
             ,            A.INT_RT      = B.NEW_INT_RT  
             ;


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;


	           --------------------------------------------------------------------
           	 DBMS_output.put_line('-- 2-8-9     MM          '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
           	 --------------------------------------------------------------------
             -- MM
	   


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --   
                     ,      TO_CHAR(B.VALUE_IL, 'YYYYMMDD') AS NEW_NEW_DT    
                     ,      TO_CHAR(B.VALUE_IL, 'YYYYMMDD') AS NEW_FST_NEW_DT
                     ,      TO_CHAR(B.EXP_IL  , 'YYYYMMDD')  AS NEW_EXP_DT    
                     ,      TO_CHAR(B.EXP_IL  , 'YYYYMMDD')  AS NEW_FST_EXP_DT
                     ,      B.PRINCIPAL_AMT AS NEW_NEW_AMT    
                     ,      B.TOTAL_RT                                    AS NEW_INT_RT
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFIF_MMH_BASE      B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'MM' 
              
             
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.NEW_DT      = B.NEW_NEW_DT    
             ,            A.FST_NEW_DT  = B.NEW_FST_NEW_DT
             ,            A.EXP_DT      = B.NEW_EXP_DT    
             ,            A.FST_EXP_DT  = B.NEW_FST_EXP_DT
             ,            A.NEW_AMT     = B.NEW_NEW_AMT    
             ,            A.INT_RT      = B.NEW_INT_RT  
             ;



	           --------------------------------------------------------------------
           	 DBMS_output.put_line('-- 2-8-10    FE          '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
           	 --------------------------------------------------------------------
           	 

             -- FE
	   



             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --   
                     ,      TO_CHAR(B.NEAR_VALUE_IL, 'YYYYMMDD') AS NEW_NEW_DT    
                     ,      TO_CHAR(B.NEAR_VALUE_IL, 'YYYYMMDD') AS NEW_FST_NEW_DT
                     ,      TO_CHAR(NVL(B.FAR_VALUE_IL  , B.NEAR_VALUE_IL)  , 'YYYYMMDD')  AS NEW_EXP_DT    
                     ,      TO_CHAR(NVL(B.FAR_VALUE_IL  , B.NEAR_VALUE_IL)  , 'YYYYMMDD')  AS NEW_FST_EXP_DT
                     ,      CASE WHEN B.BASE_CCY = B.NEAR_BUY_CCY 
                                 THEN B.NEAR_BUY_AMT  
                                 ELSE B.NEAR_SELL_AMT  
                            END AS NEW_NEW_AMT    
                     ,      NULL                                    AS NEW_INT_RT
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFIF_FEH_BASE     B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'FE' 
              
             
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.NEW_DT      = B.NEW_NEW_DT    
             ,            A.FST_NEW_DT  = B.NEW_FST_NEW_DT
             ,            A.EXP_DT      = B.NEW_EXP_DT    
             ,            A.FST_EXP_DT  = B.NEW_FST_EXP_DT
             ,            A.NEW_AMT     = B.NEW_NEW_AMT    
             ,            A.INT_RT      = B.NEW_INT_RT  
             ;


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

	           --------------------------------------------------------------------
           	 DBMS_output.put_line('-- 2-8-11    FN          '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
           	 --------------------------------------------------------------------
             -- FN
	    
             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --  
                     ,      TO_CHAR(B.CONTRACT_IL, 'YYYYMMDD') AS NEW_NEW_DT    
                     ,      TO_CHAR(B.CONTRACT_IL, 'YYYYMMDD') AS NEW_FST_NEW_DT
                     ,      TO_CHAR(B.EXP_IL  , 'YYYYMMDD')  AS NEW_EXP_DT    
                     ,      TO_CHAR(B.EXP_IL  , 'YYYYMMDD')  AS NEW_FST_EXP_DT
                     ,      B.CONTRACT_AMT AS NEW_NEW_AMT    
                     ,      NULL                                    AS NEW_INT_RT
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      IDSS_AFIF_FNH_BASE     B
                     WHERE  A.BASC_DT = B.BASC_DT
                     AND    A.REF_NO  = B.REF_NO
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'FN' 
              
             
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.NEW_DT      = B.NEW_NEW_DT    
             ,            A.FST_NEW_DT  = B.NEW_FST_NEW_DT
             ,            A.EXP_DT      = B.NEW_EXP_DT    
             ,            A.FST_EXP_DT  = B.NEW_FST_EXP_DT
             ,            A.NEW_AMT     = B.NEW_NEW_AMT    
             ,            A.INT_RT      = B.NEW_INT_RT  
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

	           --------------------------------------------------------------------
             DBMS_output.put_line('[2-8-2. LCF Deposit  INT_RT ACR     '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
            


             -- Don't Delete HINT , If you want change Hint , Ask to Manager first (SJH)
             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                      SELECT /*+ ORDERED USE_HASH(A B) */
                             A.BASC_DT 
                      ,      A.SUBJ_CD 
                      ,      A.REF_NO   
                      --  
                      ,      B.INT_RT  AS NEW_INT_RT
                      FROM   IEDW_RPT_ACCT_BASE A
                      ,      (
                              SELECT /*+ INDEX(A INRT_AACT_ACR_HIS_I1) */
                                     AC_IL
                              ,      REL_REFNO AS REF_NO
                              ,      INT_RT
                              ,      ROW_NUMBER() OVER (PARTITION BY REL_REFNO ORDER BY AC_IL DESC ) AS SEQ  
                              FROM   INRT_AACT_ACR_HIS A
                              WHERE  RVS_GB   != 'R'
                              AND    AC_IL    >= TO_DATE(GET_DATE_F(V_PROC_BASC_DT,'BF1B'),'YYYYMMDD')
                              AND    AC_IL    <= TO_DATE(V_PROC_BASC_DT,'YYYYMMDD')
                              AND    BIZ_GB    = 'DP'
                              AND    SUBSTR(REL_REFNO,-2) IN ('11','12') 
                             ) B
                      WHERE  A.REF_NO         = B.REF_NO
                      AND    A.BASC_DT        = V_PROC_BASC_DT
                      AND    A.SUBJ_CD        = 'DP' 
                      AND    A.PRD_DTLS_CD   IN ('11','12')
                      AND    NVL(A.INT_RT ,0) = 0 
                      AND    B.SEQ            = 1
                    
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.INT_RT         = B.NEW_INT_RT   
             ;

             
             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT
             ;
             
             -- OLD INT_RT (~BF1MLB)

	     /* UPDATE BYPASS에서 MERGE로 변경 - 20170309 유윤식 */
             /*
             UPDATE *+BYPASS_UJVC *
                   (
                      SELECT *+ ORDERED USE_HASH(A B) *
                             A.REF_NO
                      ,      A.INT_RT  AS INT_RT  
                      ,      B.INT_RT  AS NEW_INT_RT
                      FROM   IEDW_RPT_ACCT_BASE A
                      ,      (
                              SELECT A.REF_NO
                              ,      A.INT_RT  AS INT_RT  
                              ,      ROW_NUMBER() OVER (PARTITION BY A.REF_NO ORDER BY A.BASC_DT DESC) AS SEQ
                              FROM   IEDW_RPT_ACCT_BASE A
                              WHERE  A.BASC_DT >= GET_DATE_F(V_PROC_BASC_DT,'BF1MLB')
                              AND    A.BASC_DT <= GET_DATE_F(V_PROC_BASC_DT,'BF1B')
                              AND    A.SUBJ_CD = 'DP' 
                              AND    A.PRD_DTLS_CD IN ('11','12')
                              AND    NVL(A.INT_RT ,0) != 0 
                             ) B
                      WHERE  A.REF_NO = B.REF_NO
                      AND    A.BASC_DT = V_PROC_BASC_DT
                      AND    A.SUBJ_CD = 'DP' 
                      AND    B.SEQ = 1 
                      AND    A.PRD_DTLS_CD IN ('11','12')
                      AND    NVL(A.INT_RT ,0) = 0 
                   )
             SET   INT_RT =  NEW_INT_RT
             ;
	     */



	           --------------------------------------------------------------------
             DBMS_output.put_line('[2-8-3. LCF Deposit  INT_RT  BASE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
             
             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                      SELECT /*+ LEADING(A B) USE_HASH(A B) FULL(A) */
                             A.BASC_DT 
                      ,      A.SUBJ_CD 
                      ,      A.REF_NO   
                      --   
                      ,      B.INT_RT  AS NEW_INT_RT
                      FROM   IEDW_RPT_ACCT_BASE A
                      ,      (
                              SELECT  /*+ FULL(A) PARALLEL(A 8) */
                                     A.REF_NO
                              ,      A.INT_RT  AS INT_RT  
                              ,      ROW_NUMBER() OVER (PARTITION BY A.REF_NO ORDER BY A.BASC_DT DESC) AS SEQ
                              FROM   IEDW_RPT_ACCT_BASE A
                              WHERE  A.BASC_DT        >= GET_DATE_F(V_PROC_BASC_DT,'BF1MLB')
                              AND    A.BASC_DT        <= GET_DATE_F(V_PROC_BASC_DT,'BF1B')
                              AND    A.SUBJ_CD         = 'DP' 
                              AND    A.PRD_DTLS_CD    IN ('11','12')
                              AND    NVL(A.INT_RT ,0) != 0 
                             ) B
                      WHERE  A.REF_NO       = B.REF_NO
                      AND    A.BASC_DT      = V_PROC_BASC_DT
                      AND    A.SUBJ_CD      = 'DP' 
                      AND    B.SEQ          = 1 
                      AND    A.PRD_DTLS_CD IN ('11','12')
                      AND    NVL(A.INT_RT ,0) = 0 
                    
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.INT_RT         = B.NEW_INT_RT   
             ;

             
             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT
             ;
             
             --------------------------------------------------------------------
             DBMS_output.put_line('--2-9. EXT_DT DP              '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
             -- DP
	   


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT 
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --  
                     ,      CASE WHEN B.ROLL_OVER_IL = B.OPN_IL
                                 OR   B.ROLL_OVER_IL = TO_DATE(A.CLS_DT,'YYYYMMDD')
                                 THEN NULL
                                 ELSE TO_CHAR(B.ROLL_OVER_IL,'YYYYMMDD') 
                            END                                  AS NEW_EXT_DT
                     FROM   IEDW_RPT_ACCT_BASE A
                     ,      IDSS_ADST_DPB_BASE B
                     WHERE  A.BASC_DT     = V_PROC_BASC_DT
                     AND    A.BASC_DT     = B.BASC_DT
                     AND    A.REF_NO      = B.ACCT_NO
                     AND    A.PRD_DTLS_CD = '13' --정기예금 
                     AND    B.ROLL_OVER_IL IS NOT NULL
                     AND    A.SUBJ_CD     = 'DP'
              
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.EXT_DT         = B.NEW_EXT_DT   
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;
             
             --------------------------------------------------------------------
             DBMS_output.put_line('--2-9. EXT_DT LN              '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------          
             -- LN
	    

             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT 
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     -- 
                     ,      B.LST_EXT_DT                         AS NEW_EXT_DT
                     FROM   IEDW_RPT_ACCT_BASE A
                     ,      (
                             SELECT /*+ USE_HASH(A B) */
                                    A.REF_NO
                             ,      TO_CHAR(MAX(A.BF_TOT_EXP_IL),'YYYYMMDD') AS LST_EXT_DT
                             ,      TO_CHAR(MIN(CASE WHEN TO_CHAR(A.BF_TOT_EXP_IL,'YYYYMMDD') > '20100101'
                                                     THEN A.BF_TOT_EXP_IL
                                                END ),'YYYYMMDD') AS AF2010_MIN_EXT_DT
                             FROM   INRT_ADST_LNB_ITM  A
                             ,      INRT_ADST_LNB_HIS B
                             WHERE  B.TR_CD          = 'LN41'
                             AND    B.STS            = '0'
                             AND    A.REF_NO         = B.REF_NO
                             AND    A.HIS_NO         = B.HIS_NO
                             AND    A.BF_TOT_EXP_IL != A.AF_TOT_EXP_IL
                             --AND    A.BF_TOT_EXP_IL >= TO_DATE('20100101','YYYYMMDD')
                             GROUP BY A.REF_NO
                            ) B
                     WHERE  A.REF_NO  = B.REF_NO  
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.SUBJ_CD = 'LN'
           
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.EXT_DT         = B.NEW_EXT_DT   
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;
           
             --------------------------------------------------------------------
             DBMS_output.put_line('--2-10. CUR_CD               '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     FEX_AMT              '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     CVT_AMT              '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     MM_AVG_BAL     '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     CVT_MM_AVG_BAL    UPDATE '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     YY_AVG_BAL     '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--     CVT_YY_AVG_BAL    UPDATE '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
            


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT  
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     -- 
                     ,      B.CUR_CD             AS NEW_CUR_CD    
                     ,      B.FEX_AMT            AS NEW_FEX_AMT   
                     ,      B.CVT_AMT            AS NEW_CVT_AMT   
                     ,      B.MM_AVG_BAL         AS NEW_MM_AVG_BAL 
                     ,      B.CVT_MM_AVG_BAL     AS NEW_CVT_MM_AVG_BAL 
                     ,      B.YY_AVG_BAL         AS NEW_YY_AVG_BAL 
                     ,      B.CVT_YY_AVG_BAL     AS NEW_CVT_YY_AVG_BAL 
                     FROM   IEDW_RPT_ACCT_BASE     A
                     ,      (
                             SELECT REF_NO
                             ,      BAL_DTLS_DV_CD 
                             ,      MAX(CUR_CD ) AS CUR_CD 
                             ,      SUM(DECODE(TERM_DV_CD,'A',FEX_BAL_AMT  )) AS FEX_AMT
                             ,      SUM(DECODE(TERM_DV_CD,'A',CVT_BAL_AMT  )) AS CVT_AMT
                             ,      SUM(DECODE(TERM_DV_CD,'A',FEX_AVG_AMT  )) AS MM_AVG_BAL
                             ,      SUM(DECODE(TERM_DV_CD,'A',CVT_AVG_AMT  )) AS CVT_MM_AVG_BAL
                             ,      SUM(DECODE(TERM_DV_CD,'D',FEX_AVG_AMT  )) AS YY_AVG_BAL
                             ,      SUM(DECODE(TERM_DV_CD,'D',CVT_AVG_AMT  )) AS CVT_YY_AVG_BAL
                             FROM   IEDW_UNFY_ACCT_AVG      
                             WHERE  BASC_DT = DECODE(V_PROC_BASC_DT,V_EOM_BIZ_DT, V_PROC_EOM_DT, V_PROC_BASC_DT)
                             AND    TERM_DV_CD IN ( 'A', 'D')    
                             GROUP BY REF_NO
                             ,      BAL_DTLS_DV_CD  
                             HAVING COUNT(DISTINCT CUR_CD)  <= 1
                            )B
                     WHERE  A.REF_NO         = B.REF_NO
                     --AND    A.MAN_COA_CD  = B.COA_CD
                     AND    A.BAL_DTLS_DV_CD = B.BAL_DTLS_DV_CD
                     AND    A.BASC_DT        = V_PROC_BASC_DT
              
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.CUR_CD          = B.NEW_CUR_CD    
             ,            A.FEX_AMT         = B.NEW_FEX_AMT   
             ,            A.CVT_AMT         = B.NEW_CVT_AMT   
             ,            A.MM_AVG_BAL      = B.NEW_MM_AVG_BAL 
             ,            A.CVT_MM_AVG_BAL  = B.NEW_CVT_MM_AVG_BAL 
             ,            A.YY_AVG_BAL      = B.NEW_YY_AVG_BAL 
             ,            A.CVT_YY_AVG_BAL  = B.NEW_CVT_YY_AVG_BAL 
             ;


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;
             
             --------------------------------------------------------------------
             DBMS_output.put_line('--2-11. CLS_AMT              '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
            


             -- Don't Delete HINT , If you want change Hint , Ask to Manager first (SJH)
             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT /*+ ORDERED USE_HASH(A B) */
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     --  
                     ,      B.CLS_AMT AS NEW_CLS_AMT 
                     FROM   IEDW_RPT_ACCT_BASE A
                     ,      (
                             SELECT /*+ ORDERED USE_HASH (A B) */
                                    A.SUBJ_CD
                             ,      A.REF_NO 
                             ,      B.COA_CD
                             ,      B.FEX_AMT   AS CLS_AMT
                             ,      ROW_NUMBER() OVER (PARTITION BY A.SUBJ_CD, A.REF_NO ORDER BY B.COA_CD, B.FEX_AMT DESC) AS SEQ
                             FROM   IEDW_RPT_ACCT_BASE A
                             ,      IEDW_UNFY_ACCT_BAL B
                             WHERE  A.BASC_DT        = V_PROC_BASC_DT
                             AND    B.BASC_DT        = GET_DATE_F(V_PROC_BASC_DT,'BF1MLB')
                             AND    A.REF_NO         = B.REF_NO 
                             AND    A.BAL_DTLS_DV_CD = B.BAL_DTLS_DV_CD
                             AND    A.CUR_CD         = B.CUR_CD
                             AND    A.BR_CD          =  B.BR_CD
                             AND    A.CLS_DT    IS NOT NULL
                             AND    SUBSTR(B.COA_CD,1,1)||A.SUBJ_CD NOT IN ('1DP','2LN')
                             AND    SUBSTR(B.COA_CD,1,1) NOT IN ('7','9')
                            ) B
                     WHERE  A.SUBJ_CD = B.SUBJ_CD
                     AND    A.REF_NO  = B.REF_NO         
                     AND    B.SEQ     = 1
                     AND    A.BASC_DT = V_PROC_BASC_DT
                     AND    A.CLS_DT IS NOT NULL
              
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.CLS_AMT     = B.NEW_CLS_AMT   
             ;


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;
             
             --------------------------------------------------------------------
             DBMS_output.put_line('--2-12.  ATSD_GRD_CD    UPDATE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             -------------------------------------------------------------------
            

             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                    SELECT 
                           A.BASC_DT 
                    ,      A.SUBJ_CD 
                    ,      A.REF_NO   
                    --  
                    ,      C.AF_COLLECT_CD   AS NEW_ATSD_GRD_CD
                    FROM   IEDW_RPT_ACCT_BASE A
                          , INRT_ACOM_COMH_REFCOLHIS C
                    WHERE   A.BASC_DT = V_PROC_BASC_DT
                    AND     A.REF_NO  = C.REF_NO
                    AND     C.MAKE_IL = (SELECT MAX(MAKE_IL) FROM INRT_ACOM_COMH_REFCOLHIS
                                          WHERE MAKE_IL <= TO_DATE(V_PROC_BASC_DT,'YYYYMMDD')
                                          AND SEQ_NO  = 0 )   
                    AND     C.SEQ_NO = 0
                    AND     A.SUBJ_CD NOT IN ('DP')
                    AND     ( A.BAL_DTLS_DV_CD  IN (
                                                  SELECT BAL_DTLS_DV_CD
                                                  FROM   IEDW_SUBJ_BAL_REL
                                                 )
                              OR
                              A.MAN_COA_CD IN ('15421001','15422001','15421011','15422011')
                             )
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.ATSD_GRD_CD     = B.NEW_ATSD_GRD_CD   
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);
             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

             -------------------------------------------------------------------
             DBMS_output.put_line('--2-13.  PFMC_ORG_CD UPDATE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             -------------------------------------------------------------------
           
             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                    SELECT 
                           A.BASC_DT 
                    ,      A.SUBJ_CD 
                    ,      A.REF_NO   
                    --  
                    ,      CASE WHEN A.SUBJ_CD    = 'LN'
                                AND  B.PFMC_BR_CD = 'FI'
                                THEN 'COB'
                                -- Requested by Dosbert as per Mr. Konstantinus Liem instruction
                                --WHEN A.CUST_NO IN ('0000020093',                -- PT Bank KEB Hana Indonesia, requested by Christine
                                --                   '0000006527', '0000007221',
                                --                   '0000020949', '0000019361')
                                --THEN '0888'
                                --WHEN A.ATSD_GRD_CD = '5'
                                --THEN '0888'
                                -- Exception for Oleos. Requested by Dosbert.
                                --WHEN A.CUST_NO = '0090007262'
                                --THEN '1101'
                                --WHEN A.PRD_CD IN ( '010100002001'	-- ESCROW
                                --                 , '010200005001'	-- SAVING DEPOSIT - KEB HANA EMPLOYEE SAVING
                                --                 )
                                --THEN '0888'
                                ELSE NVL(B.PFMC_BR_CD,A.BR_CD)
                           END                                                            AS  NEW_PFMC_ORG_CD
                    FROM   IEDW_RPT_ACCT_BASE      A
                    ,      (
                            SELECT REF_NO
                            ,      PFMC_BR_CD
                            ,      ROW_NUMBER() OVER (PARTITION BY REF_NO ORDER BY PRIORITY_SEQ) AS SEQ
                            FROM   (
                                    SELECT 01 AS PRIORITY_SEQ --From account share.
                                    ,      REF_NO
                                    ,      SHAR_BR_CD  AS PFMC_BR_CD
                                    FROM   (
                                            SELECT REF_NO
                                            ,      SHAR_BR_CD
                                            ,      SHAR_RTO
                                            ,      ROW_NUMBER() OVER (PARTITION BY REF_NO ORDER BY SHAR_RTO DESC) AS SEQ
                                            FROM   IEDW_KPI_SHAR_PTCL
                                           )
                                    WHERE  SEQ = 1
                                    UNION ALL
                                    SELECT 
                                           11 AS PRIORITY_SEQ --From HOBIS CH74
                                    ,      A.REF_NO
                                    ,      NVL(B.PFMC_BR_CD,A.BR_CD) AS PFMC_BR_CD
                                    FROM   IEDW_RPT_ACCT_BASE      A
                                    ,      (
                                            SELECT CIX_NO         AS CUST_NO
                                            ,      BUSI_TP        AS PFMC_BR_CD
                                            ,      TO_CHAR(BUSI_TP_STR_DT,'YYYYMMDD') AS FR_DT
                                            ,      TO_CHAR(BUSI_TP_END_DT,'YYYYMMDD') AS TO_DT
                                            ,      ROW_NUMBER() OVER (PARTITION BY CIX_NO ORDER BY BUSI_TP_END_DT DESC) AS SEQ
                                            FROM   INRT_ACOM_CIX_BSTYPE
                                            WHERE  STS = '0'
                                            AND    CIX_NO != '0090004826'
                                           )  B
                                    WHERE  A.CUST_NO       = B.CUST_NO
                                    AND    A.BASC_DT       = V_PROC_BASC_DT
                                     
                                    UNION ALL
                                    SELECT 
                                           21 AS PRIORITY_SEQ --Loan owner takes all
                                    ,      A.REF_NO
                                    ,      NVL(B.BR_CD,A.BR_CD) AS PFMC_BR_CD
                                    FROM   IEDW_RPT_ACCT_BASE      A
                                    ,      (
                                            SELECT 
                                                   A.CUST_NO
                                            ,      CASE WHEN B.PB_RM_OFFCR_CD IN (
                                                                                  SELECT PFMC_ORG_CD
                                                                                  FROM   IEDW_PFMC_ORG_BASE
                                                                                  WHERE  USE_YN = 'Y'
                                                                                  AND    BASC_YY = SUBSTR(V_PROC_BASC_DT,1,4)
                                                                                  AND    KPI_ORG_DV_CD IN ('5')
                                                                                 )
                                                        THEN B.PB_RM_OFFCR_CD
                                                        ELSE A.BR_CD
                                                   END  AS BR_CD
                                            ,      A.CVT_AMT
                                            ,      ROW_NUMBER() OVER (PARTITION BY A.CUST_NO ORDER BY CVT_AMT DESC) AS SEQ
                                            FROM   IEDW_RPT_ACCT_BASE A
                                            ,      IDSS_ACOM_CONT_BASE B
                                            WHERE  A.BASC_DT = V_PROC_BASC_DT
                                            AND    A.BASC_DT = B.BASC_DT
                                            AND    A.REF_NO  = B.REF_NO
                                            AND    A.ACT_DV_CD = '1'
                                            AND    A.FEX_AMT IS NOT NULL
                                            AND    A.MAN_COA_CD IN ('15421001','15422001','15421011','15422011')
                                            AND    A.PRD_GRP_CD IN (
                                                                    SELECT PRD_GRP_CD
                                                                    FROM   IEDW_UNFY_PRDGRP_BASE
                                                                    WHERE  UP_PRD_GRP_CD = 'L1100' --Corporate / Commercial / SME Loan
                                                                   )
                                            AND    A.BR_CD != '0888'                                           
                                            ) B
                                    WHERE  A.BASC_DT       = V_PROC_BASC_DT
                                    AND    A.CUST_NO       = B.CUST_NO
                                    AND    B.SEQ = 1
                                    UNION ALL
                                    SELECT 
                                           31 AS PRIORITY_SEQ --Only Deposit. From input when opening account.
                                    ,      REF_NO
                                    ,      PB_RM_OFFCR_CD AS PFMC_BR_CD
                                    FROM   IDSS_ACOM_CONT_BASE A
                                    WHERE  BASC_DT        = V_PROC_BASC_DT
                                    AND    SUBJ_CD IN ('11', '12', '13', '14')
                                    AND    PB_RM_OFFCR_CD IN (
                                                              SELECT PFMC_ORG_CD
                                                              FROM   IEDW_PFMC_ORG_BASE
                                                              WHERE  KPI_ORG_DV_CD IN ( '5')
                                                              AND    BASC_YY = SUBSTR(V_PROC_BASC_DT,1,4)
                                                              AND    USE_YN  = 'Y'
                                                             )
                                    UNION ALL
                                    SELECT 
                                           41 AS PRIORITY_SEQ --All ex-KEB goes to KRD
                                    ,      REF_NO
                                    ,      'KRD' AS PFMC_BR_CD
                                    FROM   IDSS_ACOM_CONT_BASE A
                                    WHERE  BASC_DT        = V_PROC_BASC_DT
                                    AND    BRFC_CD LIKE '113%'
                                   )
                           ) B
                    WHERE  A.REF_NO  = B.REF_NO (+)
                    AND    A.BASC_DT = V_PROC_BASC_DT
                    AND    B.SEQ(+) = 1
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.PFMC_ORG_CD     = B.NEW_PFMC_ORG_CD   
             ;


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;          
          
             -------------------------------------------------------------------
             DBMS_output.put_line('--2-13.  ADTN_PFMC_ORG_CD UPDATE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             -------------------------------------------------------------------
           


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                    SELECT  
                           A.BASC_DT 
                    ,      A.SUBJ_CD 
                    ,      A.REF_NO   
                    -- 
                    ,      CASE WHEN C.REF_NO IS NOT NULL 
                                THEN SHAR_BR_CD 
                                WHEN B.ADTN_PFMC_BR_CD = 'FI'
                                AND  A.SUBJ_CD != 'DP'
                                THEN 'COB' 
                                ELSE B.ADTN_PFMC_BR_CD  
                           END  AS NEW_ADTN_PFMC_ORG_CD    
                    FROM   IEDW_RPT_ACCT_BASE A  
                    ,      IEDW_MART_CUST_BASE B      
                    ,      ( 
                            SELECT REF_NO
                            ,      SHAR_BR_CD 
                            ,      SHAR_RTO 
                            ,      ROW_NUMBER() OVER (PARTITION BY REF_NO ORDER BY SHAR_RTO DESC) AS SEQ      
                            FROM   IEDW_KPI_SHAR_PTCL  
                           ) C
                    WHERE  A.BASC_DT = B.BASC_DT 
                    AND    A.CUST_NO = B.CUST_NO 
                    AND    A.REF_NO  = C.REF_NO (+)
                    AND    A.BASC_DT = V_PROC_BASC_DT
                    AND    C.SEQ (+) = 1  
                   
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.ADTN_PFMC_ORG_CD     = B.NEW_ADTN_PFMC_ORG_CD   
             ;


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;          

             --------------------------------------------------------------------
             DBMS_output.put_line('--2-14.  DLQY_STRT_DT(연체시작일)      UPDATE   ');
             DBMS_output.put_line('--                DLQY_DV_CD  (원금연체구분코드)UPDATE   ');
             -------------------------------------------------------------------
            


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                    SELECT /*+ USE_NL(A B ) */
                           A.BASC_DT 
                    ,      A.SUBJ_CD 
                    ,      A.REF_NO   
                    --   
                    ,      B.DLQY_STR_DT   AS NEW_DLQY_STR_DT    -- 연체시작일
                    ,      B.DLQY_DV_CD    AS NEW_DLQY_DV_CD      -- 원금연체구분코드
                    FROM   IEDW_RPT_ACCT_BASE A
                    ,      (
                            SELECT REF_NO            AS  REF_NO
                            ,      'Y'               AS  DLQY_YN
                            ,      MIN(DLQY_STRT_DT) AS  DLQY_STR_DT
                            ,      CASE WHEN MAX(DLQY_DV_CD) != MIN(DLQY_DV_CD)
                                        THEN '3'
                                        ELSE MAX(DLQY_DV_CD)
                                   END               AS  DLQY_DV_CD
                            FROM   IEDW_MART_DLQY_BASE
                            WHERE  BASC_DT    =  V_PROC_BASC_DT
                            GROUP BY REF_NO
                            ) B
                    WHERE   A.REF_NO       = B.REF_NO
                    AND     A.BASC_DT      = V_PROC_BASC_DT
                    AND     A.SUBJ_CD NOT IN ('DP')
                    AND     A.BAL_DTLS_DV_CD  IN (
                                                  SELECT BAL_DTLS_DV_CD
                                                  FROM   IEDW_SUBJ_BAL_REL
                                                 )
                    
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.DLQY_STR_DT     = B.NEW_DLQY_STR_DT  
             ,            A.DLQY_DV_CD      = B.NEW_DLQY_DV_CD  
             ;


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);
             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

             --------------------------------------------------------------------
             DBMS_output.put_line('--2-15.  NTB_YN(New To Bank)   UPDATE   ');
             -------------------------------------------------------------------
           

             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                    SELECT A.BASC_DT 
                    ,      A.SUBJ_CD 
                    ,      A.REF_NO   
                    --  
                    ,      CASE WHEN A.FST_NEW_DT = B.OPEN_DT
                                THEN 'Y'
                           END                   AS NEW_NTB_YN         
                    FROM  IEDW_RPT_ACCT_BASE  A
                    ,     IEDW_MART_CUST_BASE B
                    WHERE A.BASC_DT = B.BASC_DT
                    AND   A.CUST_NO = B.CUST_NO 
                    AND   A.BASC_DT = V_PROC_BASC_DT
                     
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.NTB_YN         = B.NEW_NTB_YN  
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);
             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;


             --------------------------------------------------------------------
             DBMS_output.put_line('--2-15.Exchange Rate  UPDATE '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             -------------------------------------------------------------------
	   


             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                    SELECT A.BASC_DT 
                    ,      A.SUBJ_CD 
                    ,      A.REF_NO   
                    -- 
                    ,      B.IDR_CVT_APLY_EXRT      AS NEW_IDR_CVT_APLY_EXRT
                    FROM   IEDW_RPT_ACCT_BASE A
                    ,      (
                            SELECT A.CUR_CD             AS CUR_CD
                            ,      A.IDR_CVT_APLY_EXRT  AS IDR_CVT_APLY_EXRT
                            FROM   IEDW_UNFY_EXRT_BASE A
                            WHERE  A.BASC_DT    = V_PROC_BASC_DT
                            AND    A.EXRT_DV_CD = '1' 
                           ) B
                     WHERE  A.CUR_CD    = B.CUR_CD 
                     AND    A.BASC_DT   = V_PROC_BASC_DT
                      
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.IDR_CVT_APLY_EXRT         = B.NEW_IDR_CVT_APLY_EXRT  
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

            -------------------------------------------------------------------
             DBMS_output.put_line('--[BODY] STEP25.  AGR_NO (약정번호)   UPDATE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--                AGR_AMT(약정금액)   UPDATE   ');
             -------------------------------------------------------------------
           
			MERGE INTO IEDW_RPT_ACCT_BASE A
			   USING (     
					SELECT /*+ LEADING(C B) USE_HASH(C B) PARALLEL(C 4) FULL(C) PARALLEL(B 4) FULL(B) */
						B.REF_NO
					,   B.BASC_DT    
					,   B.AGR_REF_NO       AS NEW_AGR_NO  -- 약정번호
					,   C.CONTRACT_AMT     AS NEW_AGR_AMT -- 약정금액
					FROM   
						IDSS_ADST_LNB_BASE  B
					,   IDSS_ADST_LNB_AGR   C
					WHERE  B.BASC_DT    = V_PROC_BASC_DT    
					AND    B.BASC_DT    = C.BASC_DT   
					AND    B.AGR_REF_NO = C.REF_NO  
					) B
			   ON ( A.BASC_DT = B.BASC_DT   AND 
			   	    A.SUBJ_CD = 'LN'        AND
			   	    A.REF_NO  = B.REF_NO )                  
              
			  WHEN MATCHED THEN   
               UPDATE SET  A.AGR_NO  = B.NEW_AGR_NO 
                      ,    A.AGR_AMT = B.NEW_AGR_AMT   
				;
				
        --     MERGE INTO IEDW_RPT_ACCT_BASE A
        --     USING (     
        --            
        --            SELECT 
        --                   A.BASC_DT 
        --            ,      A.SUBJ_CD 
        --            ,      A.REF_NO   
        --            -- 
        --            ,      B.AGR_REF_NO       AS NEW_AGR_NO     -- 약정번호
        --            ,      C.CONTRACT_AMT     AS NEW_AGR_AMT    -- 약정금액
        --            FROM   IEDW_RPT_ACCT_BASE   A
        --            ,      IDSS_ADST_LNB_BASE  B
        --            ,      IDSS_ADST_LNB_AGR   C
        --            WHERE  A.REF_NO     = B.REF_NO
        --            AND    A.BASC_DT    = B.BASC_DT
        --            AND    A.BASC_DT    = C.BASC_DT
        --            AND    B.AGR_REF_NO = C.REF_NO
        --            AND    A.BASC_DT    = V_PROC_BASC_DT
        --            AND    A.SUBJ_CD    = 'LN'
        --            --AND    A.BAL_DTLS_DV_CD  IN (
        --            --                             SELECT BAL_DTLS_DV_CD
        --            --                             FROM   IEDW_SUBJ_BAL_REL
        --            --                            )
        --           
        --            
        --        ) B
        --     ON      ( A.BASC_DT            = B.BASC_DT        AND 
        --               A.SUBJ_CD            = B.SUBJ_CD        AND
        --               A.REF_NO             = B.REF_NO  )   
        --                   
        --     WHEN MATCHED THEN   
        --     UPDATE SET   A.AGR_NO         = B.NEW_AGR_NO 
        --     ,            A.AGR_AMT        = B.NEW_AGR_AMT
        --     ;


             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;


            
             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                    SELECT 
                           A.BASC_DT 
                    ,      A.SUBJ_CD 
                    ,      A.REF_NO   
                    --  
                    ,      B.AGR_REF_NO       AS NEW_AGR_NO     -- 약정번호
                    ,      B.LON_SNG_AMT      AS NEW_AGR_AMT    -- 약정금액
                    FROM   IEDW_RPT_ACCT_BASE   A
                    ,      IDSS_ADST_DPB_LNIF  B
                    WHERE  A.REF_NO  = B.ACCT_NO
                    AND    A.BASC_DT = B.BASC_DT
                    AND    A.BASC_DT = V_PROC_BASC_DT
                    AND    A.SUBJ_CD = 'LN'
                    AND    B.STS != '1'            -- @@@ 원래는 막혀있었음 ( 중복발생 )
                    
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.AGR_NO         = B.NEW_AGR_NO 
             ,            A.AGR_AMT        = B.NEW_AGR_AMT
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;

 
          
             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     -- 
                     ,      B.AGR_REF_NO       AS NEW_AGR_NO
                     ,      C.CONTRACT_AMT     AS NEW_AGR_AMT
                     FROM   IEDW_RPT_ACCT_BASE  A
                     ,      IDSS_ADST_GTB_BASE  B
                     ,      IDSS_ADST_LNB_AGR   C
                     WHERE  A.REF_NO     = B.REF_NO
                     AND    B.AGR_REF_NO = C.REF_NO
                     AND    A.SUBJ_CD    = 'GT'
                     AND    A.BASC_DT    = V_PROC_BASC_DT
                     AND    B.BASC_DT    = V_PROC_BASC_DT
                     AND    C.BASC_DT    = V_PROC_BASC_DT
                     
                      
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.AGR_NO         = B.NEW_AGR_NO 
             ,            A.AGR_AMT        = B.NEW_AGR_AMT
             ;



             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;
             --------------------------------------------------------------------
             DBMS_output.put_line('--[BODY] STEP26. SME_PFMC_YN (SME상품여부)    UPDATE'||TO_CHAR(SYSDATE,'HH24:MI:SS'));                                                            
             --------------------------------------------------------------------
          

             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                     SELECT
                            A.BASC_DT 
                     ,      A.SUBJ_CD 
                     ,      A.REF_NO   
                     -- 
                     ,      CASE WHEN B.CUST_DV_CD != 'I1'
                                 THEN 'Y'
                                 WHEN C.SME_PRD_YN = 'Y'
                                 THEN 'Y'
                                 ELSE 'N'
                            END  AS NEW_SME_PFMC_YN     
                     FROM   IEDW_RPT_ACCT_BASE A
                     ,      IEDW_MART_CUST_BASE B
                     ,      IEDW_UNFY_PRD_BASE  C
                     WHERE  A.BASC_DT  = B.BASC_DT
                     AND    A.CUST_NO  = B.CUST_NO 
                     AND    A.BASC_DT  = V_PROC_BASC_DT
                     AND    A.SUBJ_CD  = C.SUBJ_CD
                     AND    A.PRD_CD   = C.PRD_CD
                     AND    A.SUBJ_CD IN ('DP','LN','FN','GT') 
                      
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.SME_PFMC_YN        = B.NEW_SME_PFMC_YN   
             ;

 
             
             
             DBMS_output.put_line('ROW_CNT : ' || SQL%ROWCOUNT);
             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;
             
             COMMIT
             ;               

             -- Back To Back Loan 
             
             UPDATE IEDW_RPT_ACCT_BASE A
             SET    A.SME_PFMC_YN = 'Y'
             WHERE  A.BASC_DT     = V_PROC_BASC_DT
             AND    A.SME_PFMC_YN = 'N'
             AND    A.PRD_DTLS_CD = '13' -- 13.Time Deposit
             --AND    A.CVT_AMT != 0 
             AND    A.REF_NO IN ( 
                                 SELECT DISTINCT GET_MAP_CD_F('PSD_NO',D.DPST_ACCT_NO,'ACCT_NO') 
                                 FROM   IEDW_RPT_ACCT_BASE  A
                                 ,      IEDW_CLTR_PLDG_SHAR B
                                 ,      IEDW_CLTR_PLDG_INFO C 
                                 ,      IEDW_CLTR_BASE_INFO D 
                                 WHERE  A.BASC_DT      = B.BASC_DT                                            
                                 AND    A.APV_NO       = B.APV_NO                                               
                                 --                                                                                 
                                 AND    B.BASC_DT      = C.BASC_DT                                          
                                 AND    B.PLDG_NO      = C.PLDG_NO                                            
                                 AND    C.BASC_DT      = D.BASC_DT                                         
                                 AND    C.CLTR_NO      = D.CLTR_NO   
                                 AND    A.BASC_DT      = V_PROC_BASC_DT
                                 AND    A.SME_PFMC_YN  = 'Y'
                                 AND    A.SUBJ_CD IN ('LN','FN')
                                 AND    A.CVT_AMT     != 0
                                 AND    B.APV_ST_CD    = '1'
                                 AND    C.ACT_DV_CD    = '1'
                                 AND    D.ACT_DV_CD    = '1'
                                 AND    D.CLTR_DV_CD   = '03'  -- 03. Deposit
                                 AND    D.DPST_ACCT_NO IS NOT NULL
             --                     AND    D.OUR_DPST_YN  = 'Y'
                                )  
             ; 
             
             DBMS_output.put_line('ROW_CNT : ' || SQL%ROWCOUNT);
             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;
             
             COMMIT
             ;               
             
             -------------------------------------------------------------------
             DBMS_output.put_line('--[BODY] STEP26.  BLOCK_YN   UPDATE   '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             DBMS_output.put_line('--                BLOCK_AMT  UPDATE   ');
             -------------------------------------------------------------------
            

             MERGE INTO IEDW_RPT_ACCT_BASE A
             USING (     
                    
                      SELECT A.BASC_DT 
                      ,      A.SUBJ_CD 
                      ,      A.REF_NO   
                      --  
                      ,      B.BLOCK_YN       AS NEW_BLOCK_YN
                      ,      B.BLOCK_AMT      AS NEW_BLOCK_AMT
                      FROM   IEDW_RPT_ACCT_BASE A
                      ,      (
                              SELECT ACCT_NO           AS ACCT_NO
                              ,      AF_NO             AS BLOCK_AMT
                              ,      CASE WHEN ( REMARK LIKE '%CG45%' OR AF_NO = 1000) THEN 'Y'
                                          ELSE 'N'
                                     END               AS BLOCK_YN  
                              ,      REMARK
                              ,      PROCESS_CD
                              FROM   INRT_ADST_DPB_DROK  
														  WHERE  PROCESS_CD ='7003' 
														  AND    ( REMARK LIKE '%CG45%'
																	  OR AF_NO = 1000)
															AND    STS = '0'		  
			                      ) B
                      WHERE  A.BASC_DT       = V_PROC_BASC_DT
                      AND    A.REF_NO        = B.ACCT_NO(+) 
                      AND    A.PRD_CD        = '010100001005' --PREMIUM ACCOUNT  
                      AND    A.SUBJ_CD       = 'DP'     
                      --AND    A.FEX_AMT      != 0 
                    
                ) B
             ON      ( A.BASC_DT            = B.BASC_DT        AND 
                       A.SUBJ_CD            = B.SUBJ_CD        AND
                       A.REF_NO             = B.REF_NO  )   
                           
             WHEN MATCHED THEN   
             UPDATE SET   A.BLOCK_YN        = B.NEW_BLOCK_YN  
             ,            A.BLOCK_AMT       = B.NEW_BLOCK_AMT  
             ;


              

             DBMS_output.put_line(TO_CHAR(SYSDATE,'HH24:MI:SS')||' ROW_CNT : ' || SQL%ROWCOUNT);

             V_PROC_CNT := V_PROC_CNT + SQL%ROWCOUNT;

             COMMIT;
             
             
 						 
             --------------------------------------------------------------------
             DBMS_output.put_line('--[BODY] STEP54. 파티션 Reorganization          '||V_PARTITION_NAME||'    '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
             -- 테이블 파티션 Reorg
             SP_TABLE_PARTITION_MOVE (V_TABLE_OWNER, V_TABLE_NAME, V_PARTITION_NAME);
             
             --------------------------------------------------------------------
             DBMS_output.put_line('--[BODY] STEP55. 인덱스 REBUILD              '||V_PARTITION_NAME||'     '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
             -- Non-Unique 인덱스 REBUILD
             SP_INDEX_PARTITION_REBUILD (V_TABLE_OWNER, V_TABLE_NAME, V_PARTITION_NAME);

            
             --------------------------------------------------------------------
              DBMS_output.put_line('--[BODY] STEP-999 GATHER_TABLE_STATS  [START]      '||V_PARTITION_NAME||'     '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
						 
             DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>V_TABLE_OWNER, TABNAME=>V_TABLE_NAME, PARTNAME=>V_PARTITION_NAME, DEGREE=>8, ESTIMATE_PERCENT=>10, CASCADE=>TRUE, METHOD_OPT=>'FOR ALL INDEXED COLUMNS', GRANULARITY=>'PARTITION', NO_INVALIDATE=>FALSE);
             
             
             
             COMMIT;
             
             --------------------------------------------------------------------
             DBMS_output.put_line('--[BODY] STEP-999 GATHER_TABLE_STATS  [ END ]       '||V_PARTITION_NAME||'  '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
             --------------------------------------------------------------------
  
             
             DBMS_output.put_line('====================================================================');
             DBMS_output.put_line('--C.배치작업 FOOTER START');
             DBMS_output.put_line('====================================================================');

             --------------------------------------------------------------------
             DBMS_output.put_line('--[FOOT] STEP1 로그 UPDATE : 처리완료');
             --------------------------------------------------------------------
             V_PROC_ST_CD := '2'; --(1:처리중 2:처리완료 3:에러발생)
             IEDW_BAT_JOB_LOG_P( V_PROC_DT, V_BAT_JOB_ID, V_RUN_SEQ_NO, V_PROC_ST_CD, V_ERR_MSG_CTT, V_PROC_CNT,  V_PROC_BASC_DT,  V_PARM_INFO_CTT);

      EXCEPTION   WHEN OTHERS THEN
          DBMS_output.put_line('====================================================================');
          DBMS_output.put_line('--X.배치작업 EXCEPTION');
          DBMS_output.put_line('====================================================================');

          V_ERR_MSG_CTT := to_char(sqlcode)|| ' '|| sqlerrm;
          DBMS_output.put_line('Error  ');
          DBMS_output.put_line(V_ERR_MSG_CTT);

          --------------------------------------------------------------------
          DBMS_output.put_line('--[ERR] 로그 UPDATE : 에러발생');
          --------------------------------------------------------------------
          V_PROC_ST_CD := '3'; --(1:처리중 2:처리완료 3:에러발생)
          IEDW_BAT_JOB_LOG_P( V_PROC_DT, V_BAT_JOB_ID, V_RUN_SEQ_NO, V_PROC_ST_CD, V_ERR_MSG_CTT, V_PROC_CNT,  V_PROC_BASC_DT,  V_PARM_INFO_CTT);
      END;

 END;
 /
 exit
 /



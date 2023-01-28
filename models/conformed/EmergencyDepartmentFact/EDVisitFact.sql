/*********************************************************************************************************************************************************
Name: EDVisitFactMetricIsTransferOut
Description: Gets outside transfer alternate flag for the ED visit
History:
Date		    User	  ADO#		    Description
--------	  ------	--------	  -------------------------------------------------------------------------------------------------------------------------------
20220411    bs234   160568      original binding
*********************************************************************************************************************************************************/

SELECT
	COALESCE(emtla.EdVisitKey, otrn.EdVisitKey, otrna.EdVisitKey) AS EdVisitKey
,	MAX(emtla.EMTALAFlowsheetCompletedFLG) AS EMTALAFlowsheetCompletedFLG
,	MAX(otrn.EDDischargeDispositionOutsideTransferFLG) AS EDDischargeDispositionOutsideTransferFLG
,	MAX(otrna.EDDischargeDispositionOutsideTransferAlternateFLG) AS EDDischargeDispositionOutsideTransferAlternateFLG
,	1 AS IsTransferOut
FROM
			    EpicMart.Stage.EDVisitFactMetricEMTALAFlowsheetCompletedFLG emtla
FULL JOIN	EpicMart.Stage.EDVisitFactMetricEDDischargeDispositionOutsideTransferFLG otrn ON emtla.EdVisitKey = otrn.EdVisitKey
FULL JOIN	EpicMart.Stage.EDVisitFactMetricEDDischargeDispositionOutsideTransferAlternateFLG otrna ON emtla.EdVisitKey = otrna.EdVisitKey
GROUP BY
	COALESCE(emtla.EdVisitKey, otrn.EdVisitKey, otrna.EdVisitKey)
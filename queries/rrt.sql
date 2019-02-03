-- Renal Replacement Treatment
WITH
  cv_ce AS (
  SELECT
    ie.icustay_id,
    MAX(
      CASE
        WHEN ce.itemid IN (152, 148, 149, 146, 147, 151, 150) AND value IS NOT NULL THEN 1
        WHEN ce.itemid IN (229,
        235,
        241,
        247,
        253,
        259,
        265,
        271)
      AND value = 'Dialysis Line' THEN 1
        WHEN ce.itemid = 466 AND value = 'Dialysis RN' THEN 1
        WHEN ce.itemid = 927
      AND value = 'Dialysis Solutions' THEN 1
        WHEN ce.itemid = 6250 AND value = 'dialys' THEN 1
        WHEN ce.itemid = 917
      AND value IN ('+ INITIATE DIALYSIS',
        'BLEEDING FROM DIALYSIS CATHETER',
        'FAILED DIALYSIS CATH.',
        'FEBRILE SYNDROME;DIALYSIS',
        'HYPOTENSION WITH HEMODIALYSIS',
        'HYPOTENSION.GLOGGED DIALYSIS',
        'INFECTED DIALYSIS CATHETER') THEN 1
        WHEN ce.itemid = 582 AND value IN ('CAVH Start', 'CAVH D/C', 'CVVHD Start', 'CVVHD D/C', 'Hemodialysis st', 'Hemodialysis end') THEN 1
        ELSE 0
      END ) AS RRT
  FROM
    `physionet-data.mimiciii_clinical.icustays` AS ie --from icustays ie
  INNER JOIN
    `physionet-data.mimiciii_clinical.chartevents` AS ce --chartevents ce
  ON
    ie.icustay_id = ce.icustay_id
    AND ce.itemid IN ( 152 -- "Dialysis Type";61449
      ,
      148 -- "Dialysis Access Site";60335
      ,
      149 -- "Dialysis Access Type";60030
      ,
      146 -- "Dialysate Flow ml/hr";57445
      ,
      147 -- "Dialysate Infusing";56605
      ,
      151 -- "Dialysis Site Appear";37345
      ,
      150 -- "Dialysis Machine";27472
      ,
      7949 -- "Calcium for CVVH"
      ,
      229 -- INV Line#1 [Type]
      ,
      235 -- INV Line#2 [Type]
      ,
      241 -- INV Line#3 [Type]
      ,
      247 -- INV Line#4 [Type]
      ,
      253 -- INV Line#5 [Type]
      ,
      259 -- INV Line#6 [Type]
      ,
      265 -- INV Line#7 [Type]
      ,
      271 -- INV Line#8 [Type]
      ,
      582 -- Procedures
      ,
      466 -- Nursing Consultation
      ,
      917 -- Diagnosis/op
      ,
      927 -- Allergy 2
      ,
      6250 -- lt av fistula
      )
    AND ce.value IS NOT NULL
  WHERE
    ie.dbsource = 'carevue'
    -- exclude rows marked as error
    --and ce.error IS DISTINCT FROM 1
  GROUP BY
    ie.icustay_id ),
  cv_ie AS (
  SELECT
    icustay_id,
    1 AS RRT
  FROM
    `physionet-data.mimiciii_clinical.inputevents_cv` --from inputevents_cv
  WHERE
    itemid IN ( 40788 -- PD dialysate in | Free Form Intake | inputevents_cv
      ,
      40907 -- dialysate | Free Form Intake | inputevents_cv
      ,
      41063 -- PD Dialysate Intake | Free Form Intake | inputevents_cv
      ,
      41147 -- Dialysate instilled | Free Form Intake | inputevents_cv
      ,
      41307 -- Peritoneal Dialysate | Free Form Intake | inputevents_cv
      ,
      41460 -- capd dialysate | Free Form Intake | inputevents_cv
      ,
      41620 -- dialysate in | Free Form Intake | inputevents_cv
      ,
      41711 -- CAPD dialysate dwell | Free Form Intake | inputevents_cv
      ,
      41791 -- 2.5% dialysate in | Free Form Intake | inputevents_cv
      ,
      41792 -- 1.5% dialysate | Free Form Intake | inputevents_cv
      ,
      42562 -- pos. dialysate intak | Free Form Intake | inputevents_cv
      ,
      43829 -- PERITONEAL DIALYSATE | Free Form Intake | inputevents_cv
      ,
      44037 -- Dialysate Instilled | Free Form Intake | inputevents_cv
      ,
      44188 -- rep.+dialysate | Free Form Intake | inputevents_cv
      ,
      44526 -- dialysate 1.5% dex | Free Form Intake | inputevents_cv
      ,
      44527 -- dialysate 2.5% | Free Form Intake | inputevents_cv
      ,
      44584 -- Dialysate IN | Free Form Intake | inputevents_cv
      ,
      44591 -- dialysate 4.25% | Free Form Intake | inputevents_cv
      ,
      44698 -- peritoneal dialysate | Free Form Intake | inputevents_cv
      ,
      44927 -- CRRT HEPARIN | Free Form Intake | inputevents_cv
      ,
      44954 -- OR CVVHDF |  | inputevents_cv
      ,
      45157 -- ca+ gtt for cvvh | Free Form Intake | inputevents_cv
      ,
      45268 -- CALCIUM FOR CVVHD | Free Form Intake | inputevents_cv
      ,
      45352 -- CA GLUC for CVVH | Free Form Intake | inputevents_cv
      ,
      45353 -- KCL for CVVH | Free Form Intake | inputevents_cv
      ,
      46012 -- CA GLUC CVVHDF | Free Form Intake | inputevents_cv
      ,
      46013 -- KCL CVVHDF | Free Form Intake | inputevents_cv
      ,
      46172 -- CVVHDF CA GLUC | Free Form Intake | inputevents_cv
      ,
      46173 -- CVVHDF KCL | Free Form Intake | inputevents_cv
      ,
      46250 -- EBL  CVVH |  | inputevents_cv
      ,
      46262 -- dialysate 2.5% in | Free Form Intake | inputevents_cv
      ,
      46292 -- CRRT Irrigation | Free Form Intake | inputevents_cv
      ,
      46293 -- CRRT Citrate | Free Form Intake | inputevents_cv
      ,
      46311 -- crrt irrigation | Free Form Intake | inputevents_cv
      ,
      46389 -- CRRT FLUSH | Free Form Intake | inputevents_cv
      ,
      46574 -- CRRT rescue line NS | Free Form Intake | inputevents_cv
      ,
      46681 -- CRRT Rescue Flush | Free Form Intake | inputevents_cv
      ,
      46720 -- PD Dialysate | Free Form Intake | inputevents_cv
      ,
      46769 -- cvvdh rescue line | Free Form Intake | inputevents_cv
      ,
      46773 -- CVVHD NS line flush | Free Form Intake | inputevents_cv
      )
    AND amount > 0 -- also ensures it's not null
  GROUP BY
    icustay_id ),
  cv_oe AS (
  SELECT
    icustay_id,
    1 AS RRT
  FROM
    `physionet-data.mimiciii_clinical.outputevents` -- from outputevents
  WHERE
    itemid IN ( 40386 -- hemodialysis
      ,
      40425 -- dialysis output
      ,
      40426 -- dialysis out
      ,
      40507 -- Dialysis out
      ,
      40613 -- DIALYSIS OUT
      ,
      40624 -- dialysis
      ,
      40690 -- DIALYSIS
      ,
      40745 -- Dialysis
      ,
      40789 -- PD dialysate out
      ,
      40881 -- Hemodialysis
      ,
      40910 -- PERITONEAL DIALYSIS
      ,
      41016 -- hemodialysis out
      ,
      41034 -- dialysis in
      ,
      41069 -- PD Dialysate Output
      ,
      41112 -- Dialysys out
      ,
      41250 -- HEMODIALYSIS OUT
      ,
      41374 -- Dialysis Out
      ,
      41417 -- Hemodialysis Out
      ,
      41500 -- hemodialysis output
      ,
      41527 -- HEMODIALYSIS
      ,
      41623 -- dialysate out
      ,
      41635 -- Hemodialysis removal
      ,
      41713 -- dialyslate out
      ,
      41750 -- dialysis  out
      ,
      41829 -- HEMODIALYSIS OUTPUT
      ,
      41842 -- Dialysis Output.
      ,
      41897 -- CVVH OUTPUT FROM OR
      ,
      42289 -- dialysis off
      ,
      42388 -- DIALYSIS OUTPUT
      ,
      42464 -- hemodialysis ultrafe
      ,
      42524 -- HemoDialysis
      ,
      42536 -- Dialysis output
      ,
      42868 -- hemodialysis off
      ,
      42928 -- HEMODIALYSIS.
      ,
      42972 -- HEMODIALYSIS OFF
      ,
      43016 -- DIALYSIS TOTAL OUT
      ,
      43052 -- DIALYSIS REMOVED
      ,
      43098 -- hemodialysis crystal
      ,
      43115 -- dialysis net
      ,
      43687 -- crystalloid/dialysis
      ,
      43941 -- dialysis/intake
      ,
      44027 -- dialysis fluid off
      ,
      44085 -- DIALYSIS OFF
      ,
      44193 -- Dialysis.
      ,
      44199 -- HEMODIALYSIS O/P
      ,
      44216 -- Hemodialysis out
      ,
      44286 -- Dialysis indwelling
      ,
      44567 -- Hemodialysis.
      ,
      44843 -- peritoneal dialysis
      ,
      44845 -- Dialysis fluids
      ,
      44857 -- dialysis- fluid off
      ,
      44901 -- Dialysis Removed
      ,
      44943 -- fluid removed dialys
      ,
      45479 -- Dialysis In
      ,
      45828 -- Hemo dialysis out
      ,
      46230 -- Dialysis 1.5% IN
      ,
      46232 -- dialysis flush
      ,
      46394 -- Peritoneal dialysis
      ,
      46464 -- Hemodialysis OUT
      ,
      46712 -- CALCIUM-DIALYSIS
      ,
      46713 -- KCL-10 MEQ-DIALYSIS
      ,
      46715 -- Citrate - dialysis
      ,
      46741 -- dialysis removed
      )
    AND value > 0 -- also ensures it's not null
  GROUP BY
    icustay_id ),
  mv_ce AS (
  SELECT
    icustay_id,
    1 AS RRT
  FROM
    `physionet-data.mimiciii_clinical.chartevents` AS ce -- from chartevents ce
  WHERE
    itemid IN (
      -- Checkboxes
      226118 -- | Dialysis Catheter placed in outside facility      | Access Lines - Invasive | chartevents        | Checkbox
      ,
      227357 -- | Dialysis Catheter Dressing Occlusive              | Access Lines - Invasive | chartevents        | Checkbox
      ,
      225725 -- | Dialysis Catheter Tip Cultured                    | Access Lines - Invasive | chartevents        | Checkbox
      -- Numeric values
      ,
      226499 -- | Hemodialysis Output                               | Dialysis                | chartevents        | Numeric
      ,
      224154 -- | Dialysate Rate                                    | Dialysis                | chartevents        | Numeric
      ,
      225810 -- | Dwell Time (Peritoneal Dialysis)                  | Dialysis                | chartevents        | Numeric
      ,
      227639 -- | Medication Added Amount  #2 (Peritoneal Dialysis) | Dialysis                | chartevents        | Numeric
      ,
      225183 -- | Current Goal                     | Dialysis | chartevents        | Numeric
      ,
      227438 -- | Volume not removed               | Dialysis | chartevents        | Numeric
      ,
      224191 -- | Hourly Patient Fluid Removal     | Dialysis | chartevents        | Numeric
      ,
      225806 -- | Volume In (PD)                   | Dialysis | chartevents        | Numeric
      ,
      225807 -- | Volume Out (PD)                  | Dialysis | chartevents        | Numeric
      ,
      228004 -- | Citrate (ACD-A)                  | Dialysis | chartevents        | Numeric
      ,
      228005 -- | PBP (Prefilter) Replacement Rate | Dialysis | chartevents        | Numeric
      ,
      228006 -- | Post Filter Replacement Rate     | Dialysis | chartevents        | Numeric
      ,
      224144 -- | Blood Flow (ml/min)              | Dialysis | chartevents        | Numeric
      ,
      224145 -- | Heparin Dose (per hour)          | Dialysis | chartevents        | Numeric
      ,
      224149 -- | Access Pressure                  | Dialysis | chartevents        | Numeric
      ,
      224150 -- | Filter Pressure                  | Dialysis | chartevents        | Numeric
      ,
      224151 -- | Effluent Pressure                | Dialysis | chartevents        | Numeric
      ,
      224152 -- | Return Pressure                  | Dialysis | chartevents        | Numeric
      ,
      224153 -- | Replacement Rate                 | Dialysis | chartevents        | Numeric
      ,
      224404 -- | ART Lumen Volume                 | Dialysis | chartevents        | Numeric
      ,
      224406 -- | VEN Lumen Volume                 | Dialysis | chartevents        | Numeric
      ,
      226457 -- | Ultrafiltrate Output             | Dialysis | chartevents        | Numeric
      ,
      225959 -- | Medication Added Amount  #1 (Peritoneal Dialysis) | Dialysis | chartevents | Numeric
      -- Text values
      ,
      224135 -- | Dialysis Access Site | Dialysis | chartevents | Text
      ,
      224139 -- | Dialysis Site Appearance | Dialysis | chartevents | Text
      ,
      224146 -- | System Integrity | Dialysis | chartevents | Text
      ,
      225323 -- | Dialysis Catheter Site Appear | Access Lines - Invasive | chartevents | Text
      ,
      225740 -- | Dialysis Catheter Discontinued | Access Lines - Invasive | chartevents | Text
      ,
      225776 -- | Dialysis Catheter Dressing Type | Access Lines - Invasive | chartevents | Text
      ,
      225951 -- | Peritoneal Dialysis Fluid Appearance | Dialysis | chartevents | Text
      ,
      225952 -- | Medication Added #1 (Peritoneal Dialysis) | Dialysis | chartevents | Text
      ,
      225953 -- | Solution (Peritoneal Dialysis) | Dialysis | chartevents | Text
      ,
      225954 -- | Dialysis Access Type | Dialysis | chartevents | Text
      ,
      225956 -- | Reason for CRRT Filter Change | Dialysis | chartevents | Text
      ,
      225958 -- | Heparin Concentration (units/mL) | Dialysis | chartevents | Text
      ,
      225961 -- | Medication Added Units #1 (Peritoneal Dialysis) | Dialysis | chartevents | Text
      ,
      225963 -- | Peritoneal Dialysis Catheter Type | Dialysis | chartevents | Text
      ,
      225965 -- | Peritoneal Dialysis Catheter Status | Dialysis | chartevents | Text
      ,
      225976 -- | Replacement Fluid | Dialysis | chartevents | Text
      ,
      225977 -- | Dialysate Fluid | Dialysis | chartevents | Text
      ,
      227124 -- | Dialysis Catheter Type | Access Lines - Invasive | chartevents | Text
      ,
      227290 -- | CRRT mode | Dialysis | chartevents | Text
      ,
      227638 -- | Medication Added #2 (Peritoneal Dialysis) | Dialysis | chartevents | Text
      ,
      227640 -- | Medication Added Units #2 (Peritoneal Dialysis) | Dialysis | chartevents | Text
      ,
      227753 -- | Dialysis Catheter Placement Confirmed by X-ray | Access Lines - Invasive | chartevents | Text
      )
    AND ce.valuenum > 0 -- also ensures it's not null
    -- exclude rows marked as error
    --and ce.error IS DISTINCT FROM 1
  GROUP BY
    icustay_id ),
  mv_ie AS (
  SELECT
    icustay_id,
    1 AS RRT
  FROM
    `physionet-data.mimiciii_clinical.inputevents_mv` --from inputevents_mv
  WHERE
    itemid IN ( 227536 --        KCl (CRRT)        Medications        inputevents_mv        Solution
      ,
      227525 --        Calcium Gluconate (CRRT)        Medications        inputevents_mv        Solution
      )
    AND amount > 0 -- also ensures it's not null
  GROUP BY
    icustay_id ),
  mv_de AS (
  SELECT
    icustay_id,
    1 AS RRT
  FROM
    `physionet-data.mimiciii_clinical.datetimeevents` -- from datetimeevents
  WHERE
    itemid IN (
      -- TODO: unsure how to handle "Last dialysis"
      --  225128 -- | Last dialysis                                     | Adm History/FHPA        | datetimeevents     | Date time
      225318 -- | Dialysis Catheter Cap Change                      | Access Lines - Invasive | datetimeevents     | Date time
      ,
      225319 -- | Dialysis Catheter Change over Wire Date           | Access Lines - Invasive | datetimeevents     | Date time
      ,
      225321 -- | Dialysis Catheter Dressing Change                 | Access Lines - Invasive | datetimeevents     | Date time
      ,
      225322 -- | Dialysis Catheter Insertion Date                  | Access Lines - Invasive | datetimeevents     | Date time
      ,
      225324 -- | Dialysis CatheterTubing Change                    | Access Lines - Invasive | datetimeevents     | Date time
      )
  GROUP BY
    icustay_id ),
  mv_pe AS (
  SELECT
    icustay_id,
    1 AS RRT
  FROM
    `physionet-data.mimiciii_clinical.procedureevents_mv` --from procedureevents_mv
  WHERE
    itemid IN ( 225441 -- | Hemodialysis                                      | 4-Procedures            | procedureevents_mv | Process
      ,
      225802 -- | Dialysis - CRRT                                   | Dialysis                | procedureevents_mv | Process
      ,
      225803 -- | Dialysis - CVVHD                                  | Dialysis                | procedureevents_mv | Process
      ,
      225805 -- | Peritoneal Dialysis                               | Dialysis                | procedureevents_mv | Process
      ,
      224270 -- | Dialysis Catheter                                 | Access Lines - Invasive | procedureevents_mv | Process
      ,
      225809 -- | Dialysis - CVVHDF                                 | Dialysis                | procedureevents_mv | Process
      ,
      225955 -- | Dialysis - SCUF                                   | Dialysis                | procedureevents_mv | Process
      ,
      225436 -- | CRRT Filter Change               | Dialysis | procedureevents_mv | Process
      )
  GROUP BY
    icustay_id )
SELECT
 -- ie.subject_id,
 -- ie.hadm_id,
  ie.icustay_id,
  CASE
    WHEN cv_ce.RRT = 1 THEN 1
    WHEN cv_ie.RRT = 1 THEN 1
    WHEN cv_oe.RRT = 1 THEN 1
    WHEN mv_ce.RRT = 1 THEN 1
    WHEN mv_ie.RRT = 1 THEN 1
    WHEN mv_de.RRT = 1 THEN 1
    WHEN mv_pe.RRT = 1 THEN 1
    ELSE 0
  END AS RRT
FROM
  `physionet-data.mimiciii_clinical.icustays` AS ie --from icustays ie
LEFT JOIN
  cv_ce
ON
  ie.icustay_id = cv_ce.icustay_id
LEFT JOIN
  cv_ie
ON
  ie.icustay_id = cv_ie.icustay_id
LEFT JOIN
  cv_oe
ON
  ie.icustay_id = cv_oe.icustay_id
LEFT JOIN
  mv_ce
ON
  ie.icustay_id = mv_ce.icustay_id
LEFT JOIN
  mv_ie
ON
  ie.icustay_id = mv_ie.icustay_id
LEFT JOIN
  mv_de
ON
  ie.icustay_id = mv_de.icustay_id
LEFT JOIN
  mv_pe
ON
  ie.icustay_id = mv_pe.icustay_id
ORDER BY
  ie.icustay_id;
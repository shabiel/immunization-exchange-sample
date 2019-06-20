VOFEVNT;gpl/sam - immunization events ;Jun 20, 2019@15:13
 ;;0.2;FHIR INTERFACE;;Feb 07, 2019;Build 13
 ;
 ;   Copyright 2019 George Lilly
 ;
 ;  Licensed under the Apache License, Version 2.0 (the "License");
 ;  you may not use this file except in compliance with the License.
 ;  You may obtain a copy of the License at
 ;
 ;      http://www.apache.org/licenses/LICENSE-2.0
 ;
 ;  Unless required by applicable law or agreed to in writing, software
 ;  distributed under the License is distributed on an "AS IS" BASIS,
 ;  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ;  See the License for the specific language governing permissions and
 ;  limitations under the License.
 q
 ;
PCE ;
 N PXKCO,IMM,VST
 I $D(^TMP("PXKCO",$J)) D  ;
 . K ^GPL("VO")
 . M ^GPL("VO")=^TMP("PXKCO",$J)
 . M PXKCO=^TMP("PXKCO",$J)
 D ^ZTER
 I '$D(PXKCO) Q  ;
 
 Q
 ;
IMMFHIR(BNDL,IMM) ; adds a FHIR Immunization to a bundle
 ;
 N ENT S ENT=$$NXTENTRY(BNDL)
 s @BNDL@("entry",ENT,"resource","encounter","reference")="urn:uuid:3977a0cb-6abd-4ac7-ae6f-c156b24438a6"
 s @BNDL@("entry",ENT,"resource","meta","profile",1)="http://standardhealthrecord.org/fhir/StructureDefinition/shr-immunization-Immunization"
 s @BNDL@("entry",ENT,"resource","notGiven")="false"
 s @BNDL@("entry",ENT,"resource","patient","reference")="urn:uuid:86f003d6-9b10-4e27-9563-f4cff3cd6385"
 s @BNDL@("entry",ENT,"resource","primarySource")="true"
 s @BNDL@("entry",ENT,"resource","resourceType")="Immunization"
 s @BNDL@("entry",ENT,"resource","status")="completed"
 s @BNDL@("entry",ENT,"resource","vaccineCode","coding",1,"code")="08"
 s @BNDL@("entry",ENT,"resource","vaccineCode","coding",1,"display")="Hep B, adolescent or pediatric"
 s @BNDL@("entry",ENT,"resource","vaccineCode","coding",1,"system")="http://hl7.org/fhir/sid/cvx"
 s @BNDL@("entry",ENT,"resource","vaccineCode","text")="Hep B, adolescent or pediatric"
 q
 ;
ENCFHIR(BNDL,ENC) ; add a FHIR Encounter entry to a Bundle
 ;
 N ENT S ENT=$$NXTENTRY(BNDL)
 S @BNDL@("entry",ENT,"fullUrl")="urn:uuid:3977a0cb-6abd-4ac7-ae6f-c156b24438a6"
 S @BNDL@("entry",ENT,"resource","class","code")="outpatient"
 S @BNDL@("entry",ENT,"resource","id")="3977a0cb-6abd-4ac7-ae6f-c156b24438a6"
 S @BNDL@("entry",ENT,"resource","meta","profile",1)="http://standardhealthrecord.org/fhir/StructureDefinition/shr-encounter-Encounter"
 S @BNDL@("entry",ENT,"resource","period","end")="2016-03-01T17:50:05-05:00"
 S @BNDL@("entry",ENT,"resource","period","start")="2016-03-01T16:50:05-05:00"
 S @BNDL@("entry",ENT,"resource","resourceType")="Encounter"
 S @BNDL@("entry",ENT,"resource","serviceProvider","reference")="urn:uuid:c33d234b-9914-4ae4-8bb3-0a0f8fcdb4b3"
 S @BNDL@("entry",ENT,"resource","status")="finished"
 S @BNDL@("entry",ENT,"resource","subject","reference")="urn:uuid:86f003d6-9b10-4e27-9563-f4cff3cd6385"
 S @BNDL@("entry",ENT,"resource","type",1,"coding",1,"code")=170258001
 S @BNDL@("entry",ENT,"resource","type",1,"coding",1,"code","\s")=""
 S @BNDL@("entry",ENT,"resource","type",1,"coding",1,"system")="http://snomed.info/sct"
 S @BNDL@("entry",ENT,"resource","type",1,"text")="Outpatient Encounter"
 ;
 q
 ;
PATFHIR(BNDL,PAT) ; add a FHIR Patient entry to a Bundle
 ;
 N ENT S ENT=$$NXTENTRY(BNDL)
 S @BNDL@("entry",ENT,"fullUrl")="urn:uuid:86f003d6-9b10-4e27-9563-f4cff3cd6385"
 S @BNDL@("entry",ENT,"resource","identifier",1,"system")="https://github.com/synthetichealth/synthea"
 S @BNDL@("entry",ENT,"resource","identifier",1,"value")="5c8367d5-368d-44e7-825c-09574775760b"
 S @BNDL@("entry",ENT,"resource","identifier",2,"system")="http://hl7.org/fhir/sid/us-ssn"
 S @BNDL@("entry",ENT,"resource","identifier",2,"type","coding",1,"code")="SB"
 S @BNDL@("entry",ENT,"resource","identifier",2,"type","coding",1,"system")="http://hl7.org/fhir/identifier-type"
 S @BNDL@("entry",ENT,"resource","identifier",2,"value")=999326482
 S @BNDL@("entry",ENT,"resource","resourceType")="Patient"
 ;
 q
 ;
NXTENTRY(BNDL) ; extrinsic returns the next entry in the bundle
 q $o(@BNDL@("entry",""),-1)+1
 ;
wsGETIMM(RTN,FILTER) ; build and return a FHIR bundle for Immunizations
 ;
 n rtmp
 s rtmp("type")="collection"
 s rtmp("resourceType")="Bundle"
 d PATFHIR("rtmp")
 d ENCFHIR("rtmp")
 d IMMFHIR("rtmp")
 d encode^%webjson("rtmp","RTN")
 q
 ;

VOEVNT ; OSEHRA/SMH - Test Sending Immunization HL7 Messages from VistA;Jun 20, 2019@15:13; 6/2/19 12:14pm
 ;;0.0;OSEHRA MODIFICATIONS;
 ;   Copyright 2019 Sam Habiel
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
 ;
 ; ^ZZSAM(12,"IMM",1,0,"AFTER")="1020^43^12^1^^^0"
 ; ^ZZSAM(12,"IMM",1,0,"BEFORE")=""
 ; ^ZZSAM(12,"IMM",1,12,"AFTER")="^^^^3190602.163144^1^^^^^^^^^^^^^^^3190602.163144"
 ; ^ZZSAM(12,"IMM",1,12,"BEFORE")=""
 ; ^ZZSAM(12,"IMM",1,13,"AFTER")=""
 ; ^ZZSAM(12,"IMM",1,13,"BEFORE")=""
 ; ^ZZSAM(12,"IMM",1,16,"AFTER")=""
 ; ^ZZSAM(12,"IMM",1,16,"BEFORE")=""
 ; ^ZZSAM(12,"IMM",1,811,"AFTER")=""
 ; ^ZZSAM(12,"IMM",1,811,"BEFORE")=""
 ; ^ZZSAM(12,"IMM",1,812,"AFTER")="^35^36"
 ; ^ZZSAM(12,"IMM",1,812,"BEFORE")=""
 ;
PCE ; [Public] Immunization HL7 Message 2.5 VXU Implementation
 ;
 ; Initialize Destination Server
 N HL,HLA,RXA,RXR D INIT^HLFNC2("BOO FOO",.HL)
 I $G(HL)'="" D APPERROR^%ZTER("VOHL7MSG - VAFC A04 SERVER NOT DEFINED PROPERLY") QUIT
 ;
 N FS,CS
 S FS=HL("FS"),CS=$E(HL("ECH"))
 ;
 new ien    set ien=$order(^TMP("PXKCO",$J,0))
 new vimm  set vimm=$order(^TMP("PXKCO",$J,ien,"IMM",0))
 if '$D(^AUPNVIMM(vimm,0)) quit
 ;
 ; TOD: Handle Delete. For now, quit
 if ^TMP("PXKCO",$J,ien,"IMM",vimm,0,"AFTER")="" quit
 ;
 S HLA("HLS",1)=$$PID(vimm,.HL)
 S HLA("HLS",2)=$$RXA(vimm,.HL)
 S HLA("HLS",3)=$$RXR(vimm,.HL)
 quit
 ;
 ;
 ; Now that we have the V Imm, use that to construct the RXA and RXR segment
 ;
PID(INDA,HL) ; [$$ Private] PID Segement for a V Immunization
 N FS,CS,ECH
 S FS=$G(HL("FS"),"|")
 S ECH=$G(HL("ECH"),"^&~\")
 S CS=$E(ECH)
 ;
 I '$D(HLECH) N HLECH S HLECH=ECH
 I '$D(HLFS)  N HLFS S HLFS=FS
 N DFN S DFN=$P(^AUPNVIMM(INDA,0),U,2)
 Q $$EN^VAFCPID(DFN)
 ;
ORC(INDA,HL) ; [$$ Private] ORC Segment for a V Immunization
 N FS,CS,ECH
 S FS=$G(HL("FS"),"|")
 S ECH=$G(HL("ECH"),"^&~\")
 S CS=$E(ECH)
 ;
 N ORC
 S $P(ORC,U,1)="ORC"
 S $P(ORC,U,2)="RE"
 S $P(ORC,U,3)=INDA_"-"_$$GET1^DIQ(9000010.11,INDA,"VISIT:LOC. OF ENCOUNTER")
 S $P(ORC,U,4)=$$FMTHL7^XLFDT($$GET1^DIQ(9000010.11,INDA,"VISIT","I"))_"-"
 ; TODO: Continue...
 ;
RXA(INDA,HL) ; [$$ Private] RXA Segment for a V Immunization
 ; Get
 ; X0 & X12 V Imm Nodes
 ; Z0 & Z1  Imm Nodes
 ; V0 & V21 Visit Nodes
 ; T        Service Category
 N FS,CS,ECH
 S FS=$G(HL("FS"),"|")
 S ECH=$G(HL("ECH"),"^&~\")
 S CS=$E(ECH)
 ;
 N X0,X12,X13,Z0,Z1,V0,V21,T
 S X0=^AUPNVIMM(INDA,0)
 S X12=$G(^AUPNVIMM(INDA,12))
 S X13=$G(^AUPNVIMM(INDA,13))
 S Z0=$G(^AUTTIMM(+X0,0))
 S V0=$G(^AUPNVSIT(+$P(X0,U,3),0))
 S V21=$G(^AUPNVSIT(+$P(X0,U,3),21))
 S T=$P(V0,U,7)
 ;
 N RXA
 S $P(RXA,FS,1)="RXA"                     ;RXA
 S $P(RXA,FS,2)=1                         ;admin subid
 S $P(RXA,FS,3)=$$FMTHL7^XLFDT($P(X12,U,5))  ;admin date/time
 S $P(RXA,FS,4)=$$FMTHL7^XLFDT($P(X12,U,5))  ;date/time entered
 S $P(RXA,FS,5)=$P(Z0,U,3)_CS_$P(Z0,U)_CS_"CVX" ; CVX Code + Immunization Name
 S $P(RXA,FS,6)=$$GET1^DIQ(9000010.11,INDA,1312) ; dose
 S $P(RXA,FS,7)=$$GET1^DIQ(9000010.11,INDA,"1313:1")_CS_$$GET1^DIQ(9000010.11,INDA,"1313:.01")_CS_"UCUM"
 ;
 ; 9 - Source of record
 N CB,VIS,HX1,HX2 ; VIS = Vaccine Information Statement; CB = created by
 S CB=$P(V0,U,23)
 S VIS=$O(^AUPNVIMM(INDA,2,0))
 I CB=.5 S HX1="02"
 E  I T="E"!('VIS) S HX1="01"
 E  S HX1="00"
 S HX2=$S(HX1="00":"NEW IMMUNIZATION RECORD",HX1="01":"HISTORICAL INFORMATION - SOURCE UNSPECIFIED",HX1="02":"HISTORICAL INFORMATION - OTHER PROVIDER",1:"")
 S $P(RXA,FS,9)=HX1_CS_HX2_CS_"NIP001"
 ;
 ; Provider as XCN in piece 10
 S $P(RXA,FS,10)=$$XCN^LA7VHLU9($P(X12,U,4),$P(V0,U,6),FS,ECH)
 ;
 ; LA2 - Location  ; TODO: Very basic; needs more work
 I V21'="" S $P(RXA,FS,11)=CS_CS_CS_$P(V21,U)
 E  S $P(RXA,FS,11)=CS_CS_CS_$P(^DIC(4,$P(V0,U,6),0),U)
 ;
 ; Lot number
 S $P(RXA,FS,15)=$$GET1^DIQ(9000010.11,INDA,1207)
 ;
 ; Expiration Date
 S $P(RXA,FS,16)=$$FMTHL7^XLFDT($$GET1^DIQ(9000010.11,INDA,"1207:.09","I"))
 ;
 ; Manufacturer
 S $P(RXA,FS,17)=$$GET1^DIQ(9000010.11,INDA,"1207:.02:.02")_CS_$$GET1^DIQ(9000010.11,INDA,"1207:.02:.01")_CS_"MVX"
 ;
 ; Completion Status
 S $P(RXA,FS,20)="CP"
 ;
 ; Action Code: A = Add; U = Update; D = Delete
 S $P(RXA,FS,21)="A"
 ;
 ; Date/time recorded
 S $P(RXA,FS,22)=$$FMTHL7^XLFDT($$GET1^DIQ(9000010.11,INDA,1205,"I"))
 Q RXA
 ;-----
RXR(INDA,HL) ; [$$ Private] RXR Segment for a V Immunization
 N FS,CS,ECH
 S FS=$G(HL("FS"),"|")
 S ECH=$G(HL("ECH"),"^&~\")
 S CS=$E(ECH)
 ;
 N RXR
 ;
 ; Route of Administration
 S $P(RXR,FS)="RXR"
 S $P(RXR,FS,2)=$$GET1^DIQ(9000010.11,INDA,"1302:.02")_CS_$$GET1^DIQ(9000010.11,INDA,"1302")_CS_"HL70162"
 ;
 ; Site of Administration
 S $P(RXR,FS,3)=$$GET1^DIQ(9000010.11,INDA,"1303:.02")_CS_$$GET1^DIQ(9000010.11,INDA,"1303")_CS_"HL70163"
 Q RXR
 ;
TEST ;
 W $$RXA(2),!
 W $$RXR(2),!
 W $$PID(2),!
 QUIT

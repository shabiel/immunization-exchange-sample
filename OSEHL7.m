OSEHL7 ; OSE/SMH - Sample HL7 Message Processing;Jun 20, 2019@15:15
 ;;0.0;SAMPLES;
 ;
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
ADTA04 ; Process an external ADT-A04 message
 ; ZEXCEPT: HLNEXT,HLNODE,HL
 N I,J,X,PID
 F I=1:1 X HLNEXT Q:HLQUIT'>0  D
 . I $P(HLNODE,HL("FS"))="PID" D
 .. S PID=$P(HLNODE,HL("FS"),2,9999)
 .. F J=0:0 S J=$O(HLNODE(J)) Q:'J  S PID=PID_HLNODE(J)
 .. N DFN S DFN=$$PROCESS(PID)
 .. N HLA
 .. S HLA("HLA",1)="MSA"_HL("FS")_"AA"_HL("FS")_HL("MID")_HL("FS")_"DFN: "_DFN
 .. D GENACK^HLMA1(HL("EID"),HLMTIENS,HL("EIDS"),"LM",1)
 QUIT
 ;
PROCESS(PID) ; Add a patient to VistA
 N ARR
 N CS S CS=$E(HL("ECH"))
 S ARR("PRFCLTY")=$P($$SITE^VASITE(),U,3)
 S ARR("NAME")=$$UP^XLFSTR($TR($P($P(PID,HL("FS"),5),CS,1,3),CS,","))
 S ARR("MMN")=$$UP^XLFSTR($TR($P($P(PID,HL("FS"),6),CS,1,3),CS,","))
 S ARR("GENDER")=$P(PID,HL("FS"),8)
 S ARR("DOB")=$$HL7TFM^XLFDT($P(PID,HL("FS"),7))
 S ARR("SSN")=$P($P(PID,HL("FS"),3),CS)
 S ARR("SRVCNCTD")="N"
 S ARR("TYPE")="NON-VETERAN (OTHER)"
 S ARR("VET")="N"
 S ARR("FULLICN")=$$EN2^MPIFAPI() ; Create a new ICN
 D ADD^VAFCPTAD(.ZZZ,.ARR)
 QUIT $P(ZZZ(1),U,2)

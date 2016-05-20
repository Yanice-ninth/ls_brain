
FO1=[];FO2=[];FH1=[];FH2=[];
CO1=[];PO1=[];RO1=[];
CO2=[];PO2=[];RO2=[];
CH1=[];PH1=[];RH1=[];
CH2=[];PH2=[];RH2=[];
clear FOA FOC FHA FHC
%names={ 'C4' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12'};%no timing for C1 C2 C3,%missing files for C5 C12
names={ 'C4' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12'};%no timing for C1 C2 C3,%missing files for C5 C1
sync_manual=Csync_manual;
aG=CG;
no_subj=1:numel(names);
co_subj=1:numel(names);
count=0;
fnirspreproc

controls=NIRS.copy;
delete(findprop(controls,'T2')),delete(findprop(controls,'T3')),delete(findprop(controls,'T4')),delete(findprop(controls,'T5')),delete(findprop(controls,'T6')),delete(findprop(controls,'T9')),delete(findprop(controls,'T10')),delete(findprop(controls,'T7'))
controls.combine_subjects


names={ 'T2' 'T3' 'T5' 'T6' 'T7' 'T9' 'T10' };%bad timing for T7 T8 and no hbbb for T1
sync_manual=Tsync_manual;
aG=TG;
no_subj=1:numel(names);
pa_subj=co_subj(end)+1:co_subj(end)+numel(names);
fnirspreproc

patients=NIRS.copy;
delete(findprop(patients,'C4')),delete(findprop(patients,'C6')),delete(findprop(patients,'C7')),delete(findprop(patients,'C8')),delete(findprop(patients,'C9')),delete(findprop(patients,'C10')),delete(findprop(patients,'C11')),delete(findprop(patients,'C12'))
patients.combine_subjects

  
subjects={'C4' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12' 'T2' 'T3' 'T5' 'T6' 'T7' 'T9' 'T10'};
metanirseegdeci3

% groupplotscontrols
% groupplotspatients
A=[...
    mean(Ciaverage_nirsAMf)...
    mean(Tiaverage_nirsAMf)...
    mean(Ciaverage_nirsIMf)...
    mean(Tiaverage_nirsIMf)...
    ];

Ao=[...
    mean(Ciaverage_nirsAMo)...
    mean(Tiaverage_nirsAMo)...
    mean(Ciaverage_nirsIMo)...
    mean(Tiaverage_nirsIMo)...
    ];


Ad=[...
    mean(Ciaverage_nirsAMd)...
    mean(Tiaverage_nirsAMd)...
    mean(Ciaverage_nirsIMd)...
    mean(Tiaverage_nirsIMd)...
    ];

B=[Ciaverage_nirsAMf; Tiaverage_nirsAMf; Ciaverage_nirsIMf; Tiaverage_nirsIMf];
Bo=[Ciaverage_nirsAMo; Tiaverage_nirsAMd; Ciaverage_nirsIMo; Tiaverage_nirsIMo];
Bd=[Ciaverage_nirsAMd; Tiaverage_nirsAMo; Ciaverage_nirsIMd; Tiaverage_nirsIMd];
% windowplots2
% lattable
% lCAM
% lCIM
% lTAM
% lTIM

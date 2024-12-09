% VAR and SVAR previous tests
clear
clc
dataProc = databank.fromCSV("output\Processed_data.csv");
%% VAR
data = databank.fromCSV("output\VAR.csv"); 

% VAR Object
v1 = VAR(fieldnames(data));
startHist = data.D4L_REM.Range(1);
endHist = data.D4L_REM.Range(end-1);
p = 4;

% initial VAR
[v, vd] = estimate(v1, data,...
                    startHist:endHist,...
                    'order=',p);
% Store transition matrices
VARMat.A = get(v, 'A*');
VARMat.C = get(v, 'K');
VARMat.Omg = get(v, 'Omega');

%% Basic SVAR GDP, INFLATION, INTEREST RATE

BasicSvar.v1 = dataProc.L_gdp_gap_hp;
BasicSvar.v2 = dataProc.D4L_cpi;
BasicSvar.v3 = dataProc.i;

% VAR Object
vB = VAR(fieldnames(BasicSvar));
startHist = BasicSvar.v3.Range(1);
endHist = BasicSvar.v3.Range(end);

% VAR
[vB, vdB] = estimate(vB, BasicSvar,startHist:endHist,'order=',2);
[sB, ~, Bb, ~]= SVAR(vB, vdB, 'method','chol'); 
[sdB,sdcB] = srf(sB,1:100,'presample',true);

yNames = get(sB,'yNames');
eNames = get(sB, 'eNames');

figure();
count=0;
for i = 1:length(yNames)
    for j = length(eNames)
        count = count +1;
        subplot(2,2,count)      
        plot(0:100, sdB.(yNames{i}){:,j}.cumsum);
        grid on;
        grfun.zeroline();
        title(['Response in ', yNames{i}, ' to shock in ',eNames{j}],...
            'interpreter','none');
    end
end

grfun.ftitle('IRF Basic');

%% SVAR 1 
data2 = databank.fromCSV("output\SVAR.csv");
dataSVAR.v1 = data2.i_star;
dataSVAR.v2 = data2.gdp_gap_star;
dataSVAR.v3 = data2.D4L_pce_core;
dataSVAR.v4 = data2.gdp_gap;
dataSVAR.v5 = data2.D4L_cpi;
dataSVAR.v6 = data2.i;

% VAR Object
v2 = VAR(fieldnames(dataSVAR));
startHist = dataSVAR.v3.Range(1);
endHist = dataSVAR.v3.Range(end);
p = 2;
rest = nan(6,6,2);
rest(1:3, 4:6, :) = 0;


% initial VAR
[v2, vd2] = estimate(v2, dataSVAR,...
                    startHist:endHist,...
                    'order=',p,...
                    'A', rest);

% SVAR 'ordering', {'i_star','gdp_gap_star', 'D4L_pce_core','gdp_gap', 'D4L_cpi', 'i'}
[s, ~, B, ~]= SVAR(v2, vd2, 'method','chol'); 

% IRF
[sd,sdc] = srf(s,1:100,'presample',true);

%%

% varNames = {'v_y_star','v_fpi','i_star','v_y','v_cpi_sub', 'v_s', 'v_b_bm','i'};%
yNames = get(s,'yNames');
eNames = get(s, 'eNames');

figure();
count=0;
for i = 1:length(yNames)
    for j = length(eNames)
        count = count +1;
        subplot(2,4,count)
        
        plot(0:100, sd.(yNames{i}){:,j});
%         axis tigth;
        grid on;
        grfun.zeroline();
        title(['Response in ', yNames{i}, ' to shock in ',eNames{j}],...
            'interpreter','none');
    end
end

grfun.ftitle('IRF');

%{
Note: if I use the gdp_gap filtered with Hamilton I get counterintuitive
response of the gap.
%}

%%
% External Variables
dataSVAR2.v1 = dataProc.i_star;
dataSVAR2.v2 = dataProc.D4L_gdp_index_star;
dataSVAR2.v3 = dataProc.D4L_cpi_core_star;
% Variables of interest
dataSVAR2.v4 = dataProc.D4L_gdp_index;
dataSVAR2.v5 = dataProc.D4L_cpi;
% Policy Instrument
dataSVAR2.v6 = dataProc.i;
% Other variables
dataSVAR2.v7 = dataProc.D4L_MB;
% dataSVAR2.v7 = dataProc.D4L_ner;

% VAR Object
v3 = VAR(fieldnames(dataSVAR2));
startHist = dataSVAR2.v3.Range(1);
endHist = dataSVAR2.v3.Range(end);
p = 2;

rest = nan(v3.NumEndogenous,v3.NumEndogenous,p);
rest(1:3, 4:v3.NumEndogenous, :) = 0;


% initial VAR
[v3, vd3] = estimate(v3, dataSVAR2,...
                    startHist:endHist,...
                    'order=',p,...
                    'A', rest);
% Identification
[s2, ~, B2, ~]= SVAR(v3, vd3, 'method','chol'); 

% IRF
[sd2,sdc2] = srf(s2,1:100,'presample',true);

%%

% varNames = {'v_y_star','v_fpi','i_star','v_y','v_cpi_sub', 'v_s', 'v_b_bm','i'};%
yNames = get(s2,'yNames');
eNames = get(s2, 'eNames');

figure();
count=0;
for i = 1:length(yNames)
    for j = 6%length(eNames)
        count = count +1;
        subplot(2,4,count)
        
        plot(0:100, sd2.(yNames{i}){:,j});
%         axis tigth;
        grid on;
        grfun.zeroline();
        title(['Response in ', yNames{i}, ' to shock in ',eNames{j}],...
            'interpreter','none');
    end
end

grfun.ftitle('IRF 2');
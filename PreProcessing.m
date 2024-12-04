%% Monthly Data
clear all;
clc;

raw = databank.fromCSV('raw\dataBase.csv');

list1 = {'vm_cpi','va_cpi','va_cpi_core','i','i_star'};
list = fieldnames(raw)-list1;
% Creating data_m struct and adding logs
data_m = databank.apply(raw, @(x) 100*log(x),'SourceNames',list,'Prepend',"L_");
% Adding Y-o-Y Differences and M-o-M differences
data_m = databank.apply(data_m, @(x) x.diff(-12), 'startsWith','L_', 'Prepend','D4L_','RemoveStart',true);
data_m = databank.apply(data_m, @(x) 12*x.diff(-1), 'startsWith','L_', 'Prepend','DLA_','RemoveStart',true);

return
%% GDP -> GDP_GAPS for GT and EEUU

% data_m = databank.withEmpty('l_gdp_m');
% data_m.l_gdp_m = log(raw.gdp_index);
data_m.L_gdp_sa = data_m.L_gdp_index.x12;
data_m.L_gdp_index_star = data_m.L_gdp_index_star.x12; 

% HP Filters
[data_m.YT_hp, data_m.L_gdp_gap_hp] = hpf(data_m.L_gdp_sa);
[data_m.YT_star_hp, data_m.L_gdp_gap_star_hp] = hpf(data_m.L_gdp_index_star);
% Hamilton Filters
[Y, GAP] = hfilter(data_m.L_gdp_sa.data);
data_m.YT_ham = Series(data_m.L_gdp_sa.Range(1),Y);
data_m.L_gdp_gap_ham = Series(data_m.L_gdp_sa.Range(1),GAP);

[Y, GAP] = hfilter(data_m.L_gdp_index_star.data);
data_m.YT_star_ham = Series(data_m.L_gdp_index_star.Range(1),Y);
data_m.L_gdp_star_gap_ham = Series(data_m.L_gdp_index_star.Range(1),GAP);

% Graphical check up
% Monthly Filterded growth measures
figure;
subplot(2,1,1);
plot([data_m.L_gdp_sa, data_m.YT_hp, data_m.YT_ham]);
legend({'Y sa','HP','Hamilton'}, 'location','NW');
subplot(2,1,2);
plot([data_m.L_gdp_gap_hp, data_m.L_gdp_gap_ham]);
legend({'HP','Hamilton'}, 'location','NW');
zeroline;


figure;
subplot(2,1,1);
plot([data_m.L_gdp_index_star, data_m.YT_star_hp, data_m.YT_star_ham]);
legend({'Y sa','HP','Hamilton'}, 'location','NW');
subplot(2,1,2);
plot([data_m.L_gdp_gap_star_hp, data_m.L_gdp_star_gap_ham]);
legend({'HP','Hamilton'}, 'location','NW');
zeroline;

return
%% Saving Monthly Database

databank.toCSV(data_m, 'output/Processed_data.csv',Inf);

%% Data on the First VAR model in VAR-plus

%{
vardata = [unemp gdp inv cons lab tfp lab_prod lab_share infl ffr]; 
series_names = {'Unemployment',.. 1
                'Output', ... 2
                'Investment',... 3
                'Consumption',... 4
                'Hours',... 5
                'TFP',... 6
                'Labor Productivity',... 7
                'Labor Share',...8   
                'Inflation',... 9
                 'FFR'}; 10

First Approach for us
Modification on SVAR50?
    1. Output Gap EEUU
    2. Transable Prices -> Pet Prices
    3. FFR
    4. Remittances???
    5. Output Gap
    6. Inflation
    7. NER
    8. Money Base
    9. Interest Rate

%}

listVAR = {'L_gdp_star_gap_ham', 'D4L_pet', 'i_star','D4L_REM' ,...
        'L_gdp_gap_hp','D4L_cpi','D4L_ner','D4L_MB','i'}; 


data_var = data_m*listVAR;

dbplot(data_var)
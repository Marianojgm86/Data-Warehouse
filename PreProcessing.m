raw = databank.fromCSV('raw\dataBase.csv');

list1 = {'vm_cpi','va_cpi','va_cpi_core','i','i_star'};
list = fieldnames(raw)-list1;
% Creating data_m struct and adding logs
data_m = databank.apply(raw, @(x) log(x),'SourceNames',list,'Prepend',"L_");
% Adding Y-o-Y Differences and M-o-M differences
data_m = databank.apply(data_m, @(x) x.diff(-12), 'startsWith','L_', 'Prepend','D4L_','RemoveStart',true);
data_m = databank.apply(data_m, @(x) x.diff(-1), 'startsWith','L_', 'Prepend','DLA_','RemoveStart',true);


%% GDP -> GDP_GAPS for GT and EEUU

% data_m = databank.withEmpty('l_gdp_m');
data_m.l_gdp_m = log(raw.gdp_index);
data_m.l_gdp_m_sa = data_m.l_gdp_m.x12;
data_m.d4l_gdp_m = data_m.l_gdp_m_sa.diff(-12);
data_m.dla_gdp_m = data_m.l_gdp_m_sa.diff(-1);

data_m.l_gdp_m_star = log(raw.gdp_index_star);
data_m.d4l_gdp_m_star = data_m.l_gdp_m_star.diff(-12);
data_m.dla_gdp_m_star = data_m.l_gdp_m_star.diff(-1);

% HP Filters
[data_m.YT_hp, data_m.l_gdp_gap_hp] = hpf(data_m.l_gdp_m_sa);
[data_m.YT_star_hp, data_m.l_gdp_gap_star_hp] = hpf(data_m.l_gdp_m_star);
% Hamilton Filters
[Y, GAP] = hfilter(data_m.l_gdp_m_sa.data);
data_m.YT_ham = Series(data_m.l_gdp_m_sa.Range(1),Y);
data_m.l_gdp_gap_ham = Series(data_m.l_gdp_m_sa.Range(1),GAP);

[Y, GAP] = hfilter(data_m.l_gdp_m_star.data);
data_m.YT_star_ham = Series(data_m.l_gdp_m_star.Range(1),Y);
data_m.l_gdp_star_gap_ham = Series(data_m.l_gdp_m_star.Range(1),GAP);

% Graphical check up
% Monthly Filterded growth measures
figure;
subplot(2,1,1);
plot([data_m.l_gdp_m_sa, data_m.YT_hp, data_m.YT_ham]);
legend({'Y sa','HP','Hamilton'}, 'location','NW');
subplot(2,1,2);
plot([data_m.l_gdp_gap_hp, data_m.l_gdp_gap_ham]);
legend({'HP','Hamilton'}, 'location','NW');
zeroline;


figure;
subplot(2,1,1);
plot([data_m.l_gdp_m_star, data_m.YT_star_hp, data_m.YT_star_ham]);
legend({'Y sa','HP','Hamilton'}, 'location','NW');
subplot(2,1,2);
plot([data_m.l_gdp_gap_star_hp, data_m.l_gdp_star_gap_ham]);
legend({'HP','Hamilton'}, 'location','NW');
zeroline;


%% Saving Monthly Database

databank.toCSV(data_m, 'output/Processed_data.csv',Inf);
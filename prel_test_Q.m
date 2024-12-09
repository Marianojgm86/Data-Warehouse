% VAR and SVAR previous tests
clear
clc
dataProc = databank.fromCSV("output\Processed_data.csv");

%% Quarterly Basic GDP, Inf, Interest Rate
BQ.v1 = convert(dataProc.L_gdp_gap_hp, 'Q', 'method=','last');
BQ.v2 = convert( dataProc.D4L_cpi, 'Q', 'method=','last');
BQ.v3 = convert( dataProc.i, 'Q', 'method=','mean');

startHist = BQ.v3.Range(1);
endHist = BQ.v3.Range(end);

% VAR Object
vBQ = VAR(fieldnames(BQ));
[vBQ, vdBQ] = estimate(vBQ, BQ,startHist:endHist,'order=',2);
[sBQ, ~, BBQ, ~]= SVAR(vBQ, vdBQ, 'method','chol'); 
[sdBQ,sdcBQ] = srf(sBQ,1:100,'presample',true);

yNames = get(sBQ,'yNames');
eNames = get(sBQ, 'eNames');

figure();
count=0;
for i = 1:length(yNames)
    for j = length(eNames)
        count = count +1;
        subplot(2,2,count)      
        plot(0:100, sdBQ.(yNames{i}){:,j});
        grid on;
        grfun.zeroline();
        title(['Response in ', yNames{i}, ' to shock in ',eNames{j}],...
            'interpreter','none');
    end
end

grfun.ftitle('IRF Basic Quarterly');

%% Controling for the price puzzle
% Quarterly Basic GDP, Inf, Interest Rate
BQ1.v1 = convert(dataProc.DLA_pet, 'Q', 'method=','last');
BQ1.v2 = convert(dataProc.L_gdp_gap_hp, 'Q', 'method=','last');
BQ1.v3 = convert( dataProc.DLA_cpi, 'Q', 'method=','last');
BQ1.v4 = convert( dataProc.i, 'Q', 'method=','mean');


startHist = BQ.v3.Range(1);
endHist = BQ.v3.Range(end);
p = 2;


% VAR Object
vBQ1 = VAR(fieldnames(BQ1));

rest = nan(vBQ1.NumEndogenous,vBQ1.NumEndogenous,p);
rest(1, 2:vBQ1.NumEndogenous, :) = 0;

[vBQ1, vdBQ1] = estimate(vBQ1, BQ1,startHist:endHist,'order=',p,'A', rest);
[sBQ1, ~, BBQ1, ~]= SVAR(vBQ1, vdBQ1, 'method','chol'); 
[sdBQ1,sdcBQ1] = srf(sBQ1,1:100,'presample',true);

yNames = get(sBQ1,'yNames');
eNames = get(sBQ1, 'eNames');

figure();
count=0;
for i = 1:length(yNames)
    for j = length(eNames)
        count = count +1;
        subplot(2,2,count)      
        plot(0:100, sdBQ1.(yNames{i}){:,j});
        grid on;
        grfun.zeroline();
        title(['Response in ', yNames{i}, ' to shock in ',eNames{j}],...
            'interpreter','none');
    end
end

grfun.ftitle('IRF Basic Quarterly');
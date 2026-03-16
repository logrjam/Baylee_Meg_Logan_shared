% determine why variable streamflow response to climate across catchments
clear
close all

% monthly precipitation
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJanP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allFebP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allMarP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allAprP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allMayP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJunP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJulP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allAugP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allSepP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allOctP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allNovP
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allDecP

% load monthly temperature files
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJanT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allFebT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allMarT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allAprT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allMayT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJunT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allJulT
% load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allAugT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allSepT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allOctT
% load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allNovT
load F:\BoxSync\LoganThesisDatasets\SLCandWEBER/allDecT


wintert = (allDecT + allJanT + allFebT)./3;
springt = (allMarT + allAprT + allMayT)./3;
winterp = allDecP + allJanP + allFebP;
springp = allMarP + allAprP + allMayP;
snowP = winterp + allMarP;
snowT = (allDecT +allJanT + allFebT + allMarT +allAprT + allMayT)./6;
% load melt dynamics data- determined via threshold
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allmeltrate.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allmeltraterising.mat %MR rising limb only
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allmeltdur.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allmeltstart.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allmeltend.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allspringrh.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allwinterrh.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allstreamflow.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allprecip.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/alltemperature.mat
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/allbaseflow.mat
diffT = nanmean(t(85:end,:))-nanmean(t(1:84,:));

%load melt data- determined via change pt
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltstartcp.mat 
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltdurcp.mat 
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltratecp.mat 
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltraterisingcp.mat 
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/meltendcp.mat 
% load monthly mean PET data
load F:\BoxSync\LoganThesisDatasets\LoganUpdatedMeltMetrics/monthlymeanPET.mat 

% load landscaper characteristics: columns slc -> wr
% rows: 1area, 2elevation, 3,4,5temp (mean,sd,change post 1985)
% 6,7precip (mean,SD), 8,9streamflow (mean,SD), 10,11WY(mean,SD),
% 12aspectN,13E,14S,15W,16slopeangle
lscape = csvread('F:\BoxSync\LoganThesisDatasets\LandscapeCharacteristics.csv',1,1);
% add rows for CV of T,P,Q,WY,  mean winter p, mean annual PET, PET/P, & delta Temp 
lscape = [lscape; lscape(4,:)./lscape(3,:); lscape(7,:)./lscape(6,:);...
    lscape(9,:)./lscape(8,:); lscape(11,:)./lscape(10,:); nanmean(winterp);...
    sum(monthlymeanPET); sum(monthlymeanPET)./lscape(6,:); diffT];
% add rows for %N+E and S+W and winter/spring T
lscape = [lscape; (lscape(12,:)+lscape(13,:)); (lscape(14,:)+lscape(15,:)); nanmean(snowT)];
RoW = nan(1,12);%calculate more precise rate of warming since 1985
for i =1:12
    tempB = regress(t(85:end,i),[(85:118)' ones(118-84,1)]);
    RoW(i) = tempB(1);
end
lscape(5,:)=RoW;
%create string array with catchment abbreviations
catchnames = [string('J-CC'),string('J-RB'),string('J-EC'),string('J-PC')...
    string('J-MC'), string('J-BC'),string('J-LC'), string('W-ECJ'),string('W-CC')...
    ,string('W-LC'),string('W-OSF'), string('W-WO')];
ncatch = size(catchnames,2);
catchnamesfullrec =[catchnames(1:7) catchnames(9) catchnames(11:12)];
%normalize melt rate for winter p - commented out
% allmeltrate = allmeltrate./winterp;

% water yield
wy = q./p;
%normalize melt rate for winter P
nmr = allmeltrate./snowP;
nmrcp = meltratecp./snowP;

%z-score metrics
zwy = (wy-nanmean(wy))./nanstd(wy);
zp = (p-nanmean(p))./nanstd(p);
zt = (t-nanmean(t))./nanstd(t);
zsnowp = (snowP-nanmean(snowP))./nanstd(snowP);
zq = (q-nanmean(q))./nanstd(q);
zbf = (allbaseflow-nanmean(allbaseflow))./nanstd(allbaseflow);
zmr = (allmeltrate-nanmean(allmeltrate))./nanstd(allmeltrate);
zms = (allmeltstart-nanmean(allmeltstart))./nanstd(allmeltstart);
zmd = (allmeltdur-nanmean(allmeltdur))./nanstd(allmeltdur);
zmrcp = (meltratecp-nanmean(meltratecp))./nanstd(meltratecp);
znmr = (nmr-nanmean(nmr))./nanstd(nmr);
znmrcp = (nmrcp-nanmean(nmrcp))./nanstd(nmrcp);

%% regress melt rate vs winter p: one way of normalizing
Bmrwp = nan(2,ncatch);
Rmrwp = nan(118,ncatch);
Rmrcpwp=nan(118,ncatch);
Smrwp = nan(4,ncatch);
Smrcpwp = nan(4,ncatch);
for i=1:ncatch
    [Bmrwp(:,i),~,Rmrwp(:,i),~,Smrwp(:,i)] = regress(allmeltrate(:,i),[snowP(:,i) ones(118,1)]);
    [~,~,Rmrcpwp(:,i),~,Smrcpwp(:,i)] = regress(meltratecp(:,i),[snowP(:,i) ones(118,1)]);
end
meltraten = Rmrwp; meltratecpn = Rmrcpwp; %easier to remember names

zn2mr = (meltratecpn-nanmean(meltratecpn))./nanstd(meltratecpn); %z score residuals of MR snow P regression
% regress z scored melt rate vs winter P and then winter P + storage
Bzmrwp1 = nan(2,ncatch);
Rzmrwp1 = nan(118,ncatch);
Szmrwp1 = nan(4,ncatch);
Bzmrwp2 = nan(3,ncatch);
Rzmrwp2 = nan(118,ncatch);
Szmrwp2 = nan(4,ncatch);
for i=1:ncatch
    [Bzmrwp1(:,i),~,Rzmrwp1(:,i),~,Szmrwp1(:,i)] = regress(zmr(:,i),[zsnowp(:,i) ones(118,1)]);
    [Bzmrwp2(:,i),~,Rzmrwp2(:,i),~,Szmrwp2(:,i)] = regress(zmr(:,i),[zsnowp(:,i) zbf(:,i) ones(118,1)]);
end
%% regress p, bf, and melt rate for all catchments. plot coefficients
Ball = nan(4,ncatch);
Sall = nan(4,ncatch);
for i = 1:ncatch
    if i~=8
    [Ball(:,i),~,~,~,Sall(:,i)] = regress(q(:,i),[p(:,i) allbaseflow(:,i)...
        allmeltrate(:,i) ones(118,1)]);
    else
        [Ball(1:3,i),~,~,~,Sall(:,i)] = regress(q(:,i),[p(:,i)...
        allmeltrate(:,i) ones(118,1)]);
    end
end
Ball(3,8)= Ball(2,8); Ball(2,8)=0; %fix ECJ coefficients


%% regress z-scored p, bf, and melt rate for all catchments. plot coefficients
Bzall = nan(4,ncatch);
Szall = nan(4,ncatch);
for i = 1:ncatch
    if i~=8
    [Bzall(:,i),~,~,~,Szall(:,i)] = regress(zq(:,i),[zp(:,i) zbf(:,i)...
        zmr(:,i) ones(118,1)]);
    else
        [Bzall(1:3,i),~,~,~,Szall(:,i)] = regress(zq(:,i),[zp(:,i)...
        zmr(:,i) ones(118,1)]);
    end
end
Bzall(3,8)= Bzall(2,8); Bzall(2,8)=0; %fix ECJ coefficients

% do the same, but with melt rate normalized for winter p (MR/P)
Bzallnmr = nan(4,ncatch);
Szallnmr = nan(4,ncatch);
for i = 1:ncatch
        [Bzallnmr(:,i),~,~,~,Szallnmr(:,i)] = regress(zq(:,i),[zp(:,i) zbf(:,i) znmr(:,i) ones(118,1)]);
end
%% regress zscored q vs each var to determine predictability added
%precip
Bzp = nan(2,ncatch);
Rzp = nan(118,ncatch);
Szp = nan(4,ncatch);
for i =1:ncatch
    [Bzp(:,i),~,Rzp(:,i),~,Szp(:,i)] = regress(zq(:,i),[zp(:,i) ones(118,1)]);
end
% storage pred added
Bzs = nan(3,ncatch);
Rzs = nan(118,ncatch);
Szs = nan(4,ncatch);
for i =1:ncatch
    [Bzs(:,i),~,Rzs(:,i),~,Szs(:,i)] = regress(zq(:,i),[zp(:,i) znmrcp(:,i) ones(118,1)]);
end

%melt rate pred added
Bzmr = nan(4,ncatch);
Rzmr = nan(118,ncatch);
Szmr = nan(4,ncatch);
for i =1:ncatch
    [Bzmr(:,i),~,Rzmr(:,i),~,Szmr(:,i)] = regress(zq(:,i),[zp(:,i) zbf(:,i) zmr(:,i) ones(118,1)]);
end

%melt rate norm for winter p pred added
Bznmr = nan(4,ncatch);
Rznmr = nan(118,ncatch);
Sznmr = nan(4,ncatch);
for i =1:ncatch
    [Bznmr(:,i),~,Rznmr(:,i),~,Sznmr(:,i)] = regress(zq(:,i),[zp(:,i) zbf(:,i) znmrcp(:,i) ones(118,1)]);
end


% predictability added
r2add = [Szp(1,:); Szs(1,:)-Szp(1,:); Sznmr(1,:)-Szs(1,:)];
r2add(2,8)=0; %fix ECJ storage to add 0 predictability

% calculate fraction of residual variance added:
% storage- after precip is accounted for
% melt rate - after precip and storage accounted for
r2fracresid = [(Szs(1,:)-Szp(1,:))./(1-Szp(1,:)); (Szmr(1,:)-Szp(1,:))./(1-Szp(1,:))];
r2fracresid(1,8)=0;
r2frac2 = [(Szs(1,:)-Szp(1,:))./(1-Szp(1,:)); (Sznmr(1,:)-Szp(1,:))./(1-Szp(1,:))];

r2fracresidnmr = [(Szs(1,:)-Szp(1,:))./(1-Szp(1,:)); (Sznmr(1,:)-Szs(1,:))./(1-Szp(1,:))];
r2fracresidnmr(1,8)=0;
%% regress z scored WY to determine predictability added

% storage pred added
Bzwys = nan(3,ncatch);
Rzwys = nan(118,ncatch);
Szwys = nan(4,ncatch);
for i =1:ncatch
    [Bzwys(:,i),~,Rzwys(:,i),~,Szwys(:,i)] = regress(zwy(:,i),[zp(:,i) zbf(:,i) ones(118,1)]);
end


%melt rate norm for winter p pred added
Bzwymr = nan(3,ncatch);
Rzwymr = nan(118,ncatch);
Szwymr = nan(4,ncatch);
for i =1:ncatch
    [Bzwymr(:,i),~,Rzwymr(:,i),~,Szwymr(:,i)] = regress(zwy(:,i),[zp(:,i) znmrcp(:,i) ones(118,1)]);
end

%melt rate norm for winter p pred added- without storage
Bzwymr1 = nan(2,ncatch);
Rzwymr1 = nan(118,ncatch);
Szwymr1 = nan(4,ncatch);
for i =1:ncatch
    [Bzwymr1(:,i),~,Rzwymr1(:,i),~,Szwymr1(:,i)] = regress(zwy(:,i),[znmrcp(:,i) ones(118,1)]);
end


% predictability added
r2add1 = [Szwys(1,:); Szwymr(1,:)-Szwys(1,:)];
r2add1(2,8)=0; %fix ECJ storage to add 0 predictability
r2addnmr1 = [Szwys(1,:); Szwymr(1,:)-Szwys(1,:)];
r2add2 = [Szwys(1,:) - Szp(1,:); Szwymr(1,:)-Szp(1,:)];
% calculate fraction of residual variance added:
% storage- after precip is accounted for
% melt rate - after precip and storage accounted for
r2fracresid1 = [Szwys(1,:); (Szwymr(1,:)-Szwys(1,:))./(1-Szwys(1,:))];
% fraction of residual for both (storage added after mr accounted and vice versa)
r2fracresid2 = [(Szwymr(1,:)-Szwymr1(1,:))./(1-Szwymr1(1,:)); (Szwymr(1,:)-Szwys(1,:))./(1-Szwys(1,:))];

%% bar chart to show sensitivity of storage and melt predictability added- basic way
% r2addsmr = r2add([3 2],:)'; % switch order because when I negate things, negative one will show up first
r2addsmr = r2fracresidnmr([2 1],:)';
r2addsmr(:,2) = (r2addsmr(:,2).*-1) - r2addsmr(:,1); % negate storage vals first, then subtract out mr vals so it plots correctly

% organize columns by PET/P (low to high)
% new order is 7,6,12,5,11,1,2,4,3,8,10,9
newr2add = r2addsmr([7 6 12 5 11 1 2 4 3 8 10 9],:);
newcatchnames = catchnames([7 6 12 5 11 1 2 4 3 8 10 9]); % reorganize catchnames
% newr2add(10,:)=[];
newcatchnames2 = newcatchnames; newcatchnames2(10)=[];%remove ECJ from these analyses
figure;
barh(newr2add,'stacked','facecolor','b','edgecolor','b')
xticklabels([0.6 0.4 0.2 0 0.2 0.4 0.6]) % reset tick labels so all are positive
yticklabels(newcatchnames)
title('Residual Variance Explained') 
xlabel('Storage                           Melt')


%% bar chart to plot beta coefficients
newB = Bznmr(1:3,:)'; % pick out coefficients except intercept
newB(8,:) = [0.7034 0 0.395]; %W-ECJ, use coefficients from just precip and melt
newB = newB([7 6 12 5 11 1 2 4 3 8 10 9],:);

figure; bar(newB,'stacked')
xticklabels(newcatchnames)
ylabel('\beta','FontWeight','bold')
legend('Precipitation','Storage','Melt Rate')

%% bar chart to show sensitivity of storage and melt predictability added

y = [-r2add2(1,:)' r2add2(2,:)']; % set MR added to negative so bars go in opposite directions from 0
figure;
barh(y)
xticklabels([0.6 0.4 0.2 0 0.2 0.4 0.6 0.8 1]) % reset tick labels so all are positive
legend('Storage', 'Melt Rate')
title('Independent r2 added')

y2 = [-r2fracresid1(1,:)' r2fracresid1(2,:)']; % set MR added to negative so bars go in opposite directions from 0
figure;
barh(y2)
xticklabels([0.6 0.4 0.2 0 0.2 0.4 0.6 0.8 1]) % reset tick labels so all are positive
legend('Storage', 'Melt Rate')
title('Independent r2 add (storage), fraction residual explained (melt)')

y3 = [-r2fracresid2(1,:)' r2fracresid2(2,:)']; % set MR added to negative so bars go in opposite directions from 0
figure;
barh(y3)
xticklabels([0.6 0.4 0.2 0 0.2 0.4 0.6 0.8 1]) % reset tick labels so all are positive
legend('Storage', 'Melt Rate')
title('Fraction residual explained (both)')


% organize columns by PET/P (low to high)
% new order is 7,6,12,5,11,1,2,4,3,8,10,9
newy = y([7 6 12 5 11 1 2 4 3 8 10 9],:);
newy2 = y2([7 6 12 5 11 1 2 4 3 8 10 9],:);
newy3 = y3([7 6 12 5 11 1 2 4 3 8 10 9],:);
newcatchnames = catchnames([7 6 12 5 11 1 2 4 3 8 10 9]); % reorganize catchnames

figure;
barh(newy)
% xticklabels([0.6 0.4 0.2 0 0.2 0.4 0.6 0.8 1]) % reset tick labels so all are positive
yticklabels(newcatchnames)
legend('Storage', 'Melt Rate')
title('Independent r2 added')

figure;
barh(newy2)
xticklabels([0.6 0.4 0.2 0 0.2 0.4 0.6 0.8 1]) % reset tick labels so all are positive
yticklabels(newcatchnames)
legend('Storage', 'Melt Rate')
title('Independent r2 add (storage), fraction residual explained (melt)')

figure;
barh(newy3)
xticklabels([0.6 0.4 0.2 0 0.2 0.4 0.6 0.8 1]) % reset tick labels so all are positive
yticklabels(newcatchnames)
legend('Storage', 'Melt Rate')
title('Fraction residual explained (both)')

%% calculate partial correlations for each variable in MLR model and plot as bar chart
partials = nan(2,12);
for i =1:12
    rho = partialcorr([zwy(:,i) zp(:,i) zbf(:,i) znmrcp(:,i)],'rows','complete');
    partials(:,i) = rho([3 4])';
end

ppart = partials'; ppart(:,2) = (ppart(:,2).*-1)-ppart(:,1);

% organize columns by PET/P (low to high)
% new order is 7,6,12,5,11,1,2,4,3,8,10,9
newppart = ppart([7 6 12 5 11 1 2 4 3 8 10 9],:);
figure;
barh(newppart,'stacked')
xticklabels([1 0.8 0.6 0.4 0.2 0 0.2 0.4 0.6 0.8]) % reset tick labels so all are positive
yticklabels(newcatchnames)

%% estimate water yield using P + BF + MR
%melt rate pred added
Bzwy1 = nan(3,ncatch);
Rzwy1 = nan(118,ncatch);
Szwy1 = nan(4,ncatch);
for i =1:ncatch
    [Bzwy1(:,i),~,Rzwy1(:,i),~,Szwy1(:,i)] = regress(zwy(:,i),[zp(:,i) zbf(:,i) ones(118,1)]);
end

Bzwy2 = nan(3,ncatch);
Rzwy2 = nan(118,ncatch);
Szwy2 = nan(4,ncatch);
for i =1:ncatch
    [Bzwy2(:,i),~,Rzwy2(:,i),~,Szwy2(:,i)] = regress(zwy(:,i),[zp(:,i) zmr(:,i) ones(118,1)]);
end

Bzwy3 = nan(4,ncatch);
Rzwy3 = nan(118,ncatch);
Szwy3 = nan(4,ncatch);
for i =1:ncatch
    [Bzwy3(:,i),~,Rzwy3(:,i),~,Szwy3(:,i)] = regress(zwy(:,i),[zp(:,i) zbf(:,i) zmr(:,i) ones(118,1)]);
end

estwy1 = zp.*Bzwy1(1,:) + zbf.*Bzwy1(2,:) + Bzwy1(3,:);
estwy2 = zp.*Bzwy2(1,:) + zmr.*Bzwy2(2,:) + Bzwy2(3,:);
estwy3 = zp.*Bzwy3(1,:) + zbf.*Bzwy3(2,:) + zmr.*Bzwy3(3,:) + Bzwy3(4,:);

%% estimate water yield using P + BF + MR (normalized for winter P)

%p and nmr
Bznwy2 = nan(3,ncatch);
Rznwy2 = nan(118,ncatch);
Sznwy2 = nan(4,ncatch);
for i =1:ncatch
    [Bznwy2(:,i),~,Rznwy2(:,i),~,Sznwy2(:,i)] = regress(zwy(:,i),[zp(:,i) znmr(:,i) ones(118,1)]);
end

Bznwy3 = nan(4,ncatch);
Rznwy3 = nan(118,ncatch);
Sznwy3 = nan(4,ncatch);
for i =1:ncatch
    [Bznwy3(:,i),~,Rznwy3(:,i),~,Sznwy3(:,i)] = regress(zwy(:,i),[zp(:,i) zbf(:,i) znmr(:,i) ones(118,1)]);
end

estnwy2 = zp.*Bznwy2(1,:) + znmr.*Bznwy2(2,:) + Bznwy2(3,:);
estnwy3 = zp.*Bznwy3(1,:) + zbf.*Bznwy3(2,:) + znmr.*Bznwy3(3,:) + Bznwy3(4,:);

%% estimate water yield using P + BF + MR (changepoint melt and normalized for winter P)

%p and nmr
Bznwy2cp = nan(3,ncatch);
Rznwy2cp = nan(118,ncatch);
Sznwy2cp = nan(4,ncatch);
for i =1:ncatch
    [Bznwy2cp(:,i),~,Rznwy2cp(:,i),~,Sznwy2cp(:,i)] = regress(zwy(:,i),[zp(:,i) znmrcp(:,i) ones(118,1)]);
end

Bznwy3cp = nan(4,ncatch);
Rznwy3cp = nan(118,ncatch);
Sznwy3cp = nan(4,ncatch);
for i =1:ncatch
    [Bznwy3cp(:,i),~,Rznwy3cp(:,i),~,Sznwy3cp(:,i)] = regress(zwy(:,i),[zp(:,i) zbf(:,i) znmrcp(:,i) ones(118,1)]);
end

estnwy2cp = zp.*Bznwy2cp(1,:) + znmrcp.*Bznwy2cp(2,:) + Bznwy2cp(3,:);
estnwy3cp = zp.*Bznwy3cp(1,:) + zbf.*Bznwy3cp(2,:) + znmrcp.*Bznwy3cp(3,:) + Bznwy3cp(4,:);
%% timeseries plots- averages across all catchments, z scores 
% water yield and precipitation
figure; 
subplot(4,1,1)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(zp,2),'LineWidth',2);
legend('Runoff Efficiency', 'Precipitation')
% water yield and P + BF
subplot(4,1,2)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estwy1,2),'LineWidth',2);
legend('Runoff Efficiency', 'Precipitation + Storage')
% water yield and P + MR
subplot(4,1,3)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estwy2,2),'LineWidth',2);
legend('Runoff Efficiency', 'Precipitation + Melt Rate')
% water yield and P + BF + MR
subplot(4,1,4)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estwy3,2),'LineWidth',2);
legend('Runoff Efficiency', 'Precipitation + Storage + Melt Rate')


%% timeseries plots- averages across all catchments, z scores - will probably use these
figure; 
% water yield and MR
subplot(3,1,1)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(zmr,2),'LineWidth',2);
set(gca,'xticklabel',[]); ylabel('z-score');
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Melt Rate')
% water yield and P + MR
subplot(3,1,2)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estwy2,2),'LineWidth',2);
set(gca,'xticklabel',[]); ylabel('z-score');
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Precipitation + Melt Rate')
% water yield and P + BF + MR
subplot(3,1,3)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estwy3,2),'LineWidth',2);
ylabel('z-score');
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Precipitation + Storage + Melt Rate')

%% timeseries plots- averages across all catchments, z scores - will probably use these
% MR normalized for winter p
figure; 
% water yield and MR
subplot(3,1,1)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(znmr,2),'LineWidth',2);
set(gca,'xticklabel',[]); ylabel('z-score'); ylim([-3 3])
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Melt Rate (norm for winter P)','location','southeast')
% water yield and P + MR
subplot(3,1,2)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estnwy2,2),'LineWidth',2);
set(gca,'xticklabel',[]); ylabel('z-score'); ylim([-3 3])
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Precipitation + Melt Rate (norm for winter P)')
% water yield and P + BF + MR
subplot(3,1,3)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estnwy3,2),'LineWidth',2);
ylabel('z-score'); ylim([-3 3])
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Precipitation + Storage + Melt Rate (norm for winter P)')

%% timeseries plots- averages across all catchments, z scores -
% changepoint MR normalized for winter p
figure; 
% water yield and MR
subplot(3,1,1)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(znmrcp,2),'LineWidth',2);
set(gca,'xticklabel',[]); ylabel('z-score'); ylim([-3 3])
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Melt Rate ( CP, norm for winter P)','location','southeast')
% water yield and P + MR
subplot(3,1,2)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estnwy2cp,2),'LineWidth',2);
set(gca,'xticklabel',[]); ylabel('z-score'); ylim([-3 3])
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Precipitation + Melt Rate (CP, norm for winter P)')
% water yield and P + BF + MR
subplot(3,1,3)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estnwy3cp,2),'LineWidth',2);
ylabel('z-score'); ylim([-3 3])
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Precipitation + Storage + Melt Rate (CP, norm for winter P)')
%% timeseries plots- averages across all catchments, z scores - might use these
figure; 
% water yield and MR
subplot(4,1,1)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(zmr,2),'LineWidth',2);
set(gca,'xticklabel',[]); ylabel('z-score');
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Melt Rate')
% water yield and P + MR
subplot(4,1,2)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estwy2,2),'LineWidth',2);
set(gca,'xticklabel',[]); ylabel('z-score');
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Precipitation + Melt Rate')
% water yield and MR (norm for winter P)
subplot(4,1,3)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(znmr,2),'LineWidth',2);
set(gca,'xticklabel',[]); ylabel('z-score'); ylim([-2 4])
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Melt Rate (norm for Winter P')
% water yield and P + BF + MR
subplot(4,1,4)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(estwy3,2),'LineWidth',2);
ylabel('z-score');
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Precipitation + Storage + Melt Rate')

%% timeseries plots- averages across all catchments, z scores - probably don't use this method
% on these, plot residuals of P/storage regression on melt rate
figure; 
% water yield and MR
subplot(3,1,1)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(zmr,2),'LineWidth',2);
set(gca,'xticklabel',[]); ylabel('z-score');
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Melt Rate')
% water yield and P + MR
subplot(3,1,2)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(Rzmrwp1,2),'LineWidth',2);
set(gca,'xticklabel',[]); ylabel('z-score');
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Precipitation + Melt Rate')
% water yield and P + BF + MR
subplot(3,1,3)
plot(1901:2018,nanmean(zwy,2),'LineWidth',2); hold on
plot(1901:2018, nanmean(Rzmrwp2,2),'LineWidth',2);
ylabel('z-score');
ax = gca;
ax.FontSize = 14;
legend('Runoff Efficiency', 'Precipitation + Storage + Melt Rate')
%% bar plot to show coefficients and predictability added
figure; 
subplot(3,3,3);
bar(Bzall(1,:),'b'); ylabel('Coefficient'); 
set(gca,'xticklabel',catchnames,'FontSize',11,'FontWeight','bold','xticklabelrotation',45);
title('Precipitation \beta')
subplot(3,3,6);
bar(Bzall(2,:),'c'); ylabel('Coefficient');
set(gca,'xticklabel',catchnames,'FontSize',11,'FontWeight','bold','xticklabelrotation',45);
title('Winter Baseflow \beta')
subplot(3,3,9);
bar(Bzall(3,:),'y'); ylabel('Coefficient');
set(gca,'xticklabel',catchnames,'FontSize',11,'FontWeight','bold','xticklabelrotation',45);
title('Melt Rate \beta')
subplot(3,3,[1,2,4,5,7,8]);
bar(r2add','stacked');
set(gca,'xticklabel',catchnames,'FontSize',13,'FontWeight','bold','xticklabelrotation',45);
title('Predictability (R^{2}) Added'); legend('Precipitation','Winter Baseflow','Melt Rate');

%% determine correlations between basic catchment characteristics and resdiual r2 added
[qcorR, qrhoR] = corr(lscape',r2add');
[qcorB,qrhoB] = corr(lscape',Bzall(1:3,:)');
[qcorRfr, qrhoRfr] = corr(lscape',r2fracresid');
[qcorRfrnmr, qrhoRfrnmr] = corr(lscape',r2fracresidnmr');

Rsigr2 = qcorR; Rsigr2(qrhoR>0.05)=0;
Bsigr2 = qcorB; Bsigr2(qrhoB>0.05)=0;
Rsigr2fr = qcorRfr; Rsigr2fr(qrhoRfr>0.05)=0;
Rsigr2frnmr = qcorRfrnmr; Rsigr2frnmr(qrhoRfrnmr>0.05)=0;

%% determine correlations btwn catchment char and average P, storage, MR and melt start, dur
[Pcor, Prho] = corr(lscape',nanmean(p)');
[BFcor, BFrho] = corr(lscape',nanmean(allbaseflow)');
[MRcor, MRrho] = corr(lscape',nanmean(allmeltrate)');
[nMRcor, nMRrho] = corr(lscape',nanmean(meltraten)');
[MScor, MSrho] = corr(lscape',nanmean(allmeltstart)');
[MDcor, MDrho] = corr(lscape',nanmean(allmeltdur)');
[MScpcor, MScprho] = corr(lscape',nanmean(meltstartcp)');
[MDcpcor, MDcprho] = corr(lscape',nanmean(meltdurcp)');
[MRcpcor, MRcprho] = corr(lscape',nanmean(meltratecp)');
[nMRcpcor, nMRcprho] = corr(lscape',nanmean(meltratecpn)');
% other way of normalizing MR for winter p: MR./snowP
[nMRcor2, nMRrho2] = corr(lscape',nanmean(nmr)');
[nMRcpcor2, nMRcprho2] = corr(lscape',nanmean(nmrcp)');

Psig = Pcor; Psig(Prho>0.05)=0;
BFsig = BFcor; BFsig(BFrho>0.05)=0;
MRsig = MRcor; MRsig(MRrho>0.05)=0;
nMRsig = nMRcor; nMRsig(nMRrho>0.05)=0;
MSsig = MScor; MSsig(MSrho>0.05)=0;
MDsig = MDcor; MDsig(MDrho>0.05)=0;
MScpsig = MScpcor; MScpsig(MScprho>0.05)=0;
MDcpsig = MDcpcor; MDcpsig(MDcprho>0.05)=0;
MRcpsig = MRcpcor; MRcpsig(MRcprho>0.05)=0;
nMRcpsig = nMRcpcor; nMRcpsig(nMRcprho>0.05)=0;
nMRsig2 = nMRcor2; nMRsig2(nMRrho2>0.05)=0;
nMRcpsig2 = nMRcpcor2; nMRcpsig2(nMRcprho2>0.05)=0;

sigfactors = [Psig BFsig MRsig];

mrsigfacts = [MRsig nMRsig MRcpsig nMRcpsig];
mrsigfacts2 = [MRsig nMRsig2 MRcpsig nMRcpsig2];

%% plot scatters showing significant relationships- for melt- normalized for winter P
figure;
subplot(3,4,1);
plot(lscape(2,:),nanmean(allmeltstart),'ob'); hold on; plot(lscape(2,:),nanmean(meltstartcp),'sr');
xlabel('Elevation (m)'); ylabel('Day');
subplot(3,4,2);
plot(lscape(27,:),nanmean(allmeltstart),'ob'); hold on; plot(lscape(27,:),nanmean(meltstartcp),'sr');
xlabel('Winter/Spring Temperature (^{o}C)'); ylabel('Day');
subplot(3,4,3);
% plot(lscape(21,:),nanmean(allmeltstart),'bo'); hold on;
plot(lscape(21,:),nanmean(meltstartcp),'sr');
xlabel('Winter Precip (mm)'); ylabel('Day');
subplot(3,4,4);
plot(lscape(23,:),nanmean(allmeltstart),'bo'); hold on;
plot(lscape(23,:),nanmean(meltstartcp),'sr');
xlabel('PET/P'); ylabel('Day');
% subplot(3,4,9);
% plot(lscape(2,:),nanstd(allmeltstart),'ob'); ylim([10 23]);
% hold on; plot(lscape(2,:),(nanstd(meltstartcp)./nanmean(meltstartcp)),'s');
% xlabel('Elevation (m)'); ylabel('SD Melt Start Day');
% subplot(3,3,4);
% plot(lscape(2,:),nanmean(allmeltdur),'ob'); %hold on; plot(lscape(2,:),nanmean(meltdurcp),'s');
% xlabel('Elevation (m)'); ylabel('Days');
% subplot(3,3,5);
% plot(lscape(3,:),nanmean(allmeltdur),'ob'); hold on; plot(lscape(3,:),nanmean(meltdurcp),'sr');
% xlabel('Mean Temperature (^{o}C)'); ylabel('Days');
subplot(3,4,5);
plot(lscape(2,:),nanmean(nmr),'ob'); hold on; plot(lscape(2,:),nanmean(nmrcp),'sr');
xlabel('Elevation (m)'); ylabel('mm/day');
subplot(3,4,6);
plot(lscape(27,:),nanmean(nmr),'ob'); hold on; plot(lscape(27,:),nanmean(nmrcp),'sr');
xlabel('Winter/Spring Temperature (^{o}C)'); ylabel('mm/day');
subplot(3,4,7);
plot(lscape(21,:),nanmean(nmr),'ob'); hold on; plot(lscape(21,:),nanmean(nmrcp),'sr');
xlabel('Winter Precip (mm)'); ylabel('mm/day');
subplot(3,4,8);
plot(lscape(23,:),nanmean(nmr),'ob'); hold on; plot(lscape(23,:),nanmean(nmrcp),'sr');
xlabel('PET/P'); ylabel('mm/day');
subplot(3,4,9);
plot(lscape(2,:),(nanstd(nmr)./nanmean(nmr)),'ob'); 
hold on; plot(lscape(2,:),(nanstd(nmrcp)./nanmean(nmrcp)),'sr');
xlabel('Elevation (m)'); ylabel('CV Melt Rate');
legend('Threshold','Change Point','location','northeast');
tx=annotation('textbox','str','a) Melt Start');
tx2=annotation('textbox','str','b) Melt Rate');
tx3=annotation('textbox','str','c) Melt Variability');
tx.FontSize=12; tx.LineStyle='none'; tx.Position = [0.05 0.78 0.3 0.2];
tx2.FontSize=12; tx2.LineStyle='none'; tx2.Position = [0.05 0.48 0.3 0.2];
tx3.FontSize=12; tx3.LineStyle='none'; tx3.Position = [0.05 0.18 0.3 0.2];

%% plot scatters showing significant relationships- for MLR- with regression lines
% lscape rows: 1area, 2elevation, 3,4,5temp (mean,sd,change post 1985)
% 6,7precip (mean,SD), 8,9streamflow (mean,SD), 10,11WY(mean,SD),
% 12aspectN,13E,14S,15W,16slopeangle,17cvT,18cvP,19cvQ,20cvWY,21winterP,
% 22PET, 23PET/P, 24deltaT, 25aspectN+E, 26aspectS+W, 27springT
figure;
subplot(3,3,1); 
plot(lscape(10,:),r2add(1,:),'o'); lsline; xlim([0.1 0.7]); ylim([0.4 0.8]);
xlabel('Mean Water Yield'); ylabel('R^{2} Added'); ax = gca; ax.FontSize=12;
subplot(3,3,2);
plot(lscape(2,:),Bzall(1,:),'o'); lsline; xlim([1800 2800]); ylim([0 0.4]);
xlabel('Elevation (m)'); ylabel('\beta'); ax = gca; ax.FontSize=12;
subplot(3,3,3);
plot(lscape(3,:),Bzall(1,:),'o'); lsline; xlim([2 7]); ylim([0 0.4]);
xlabel('Mean Temperature (^{o}C)'); ylabel('\beta'); ax = gca; ax.FontSize=12;
subplot(3,3,4);
plot(lscape(10,:),r2add(2,:),'o'); lsline; xlim([0.1 0.7]); ylim([0 0.4]);
xlabel('Mean Water Yield'); ylabel('R^{2} Added'); ax = gca; ax.FontSize=12;
subplot(3,3,7);
plot(lscape(2,:),r2add(3,:),'o'); lsline; xlim([1800 2800]); ylim([0 0.4]);
xlabel('Elevation (m)'); ylabel('R^{2} Added'); ax = gca; ax.FontSize=12;
subplot(3,3,8);
plot(lscape(3,:),r2add(3,:),'o'); lsline; xlim([2 7]); ylim([0.1 0.3]);
xlabel('Mean Temperature (^{o}C)'); ylabel('R^{2} Added'); ax = gca; ax.FontSize=12;
subplot(3,3,9);
plot(lscape(12,:),r2add(3,:),'o'); lsline; xlim([15 40]); ylim([0.1 0.3]);
xlabel('Northerly Slope Aspect (%)'); ylabel('R^{2} Added'); ax = gca; ax.FontSize=12;

%% plot scatters showing significant relationships- for MLR (precip only)
%- with regression lines
figure;
subplot(2,2,1); 
plot(lscape(10,:),r2add(1,:),'o'); lsline; xlim([0.1 0.7]); ylim([0.4 0.8]);
xlabel('Mean Water Yield'); ylabel('R^{2}'); ax = gca; ax.FontSize=12;
subplot(2,2,3);
plot(lscape(2,:),Bzall(1,:),'o'); lsline; xlim([1800 2800]); ylim([0 0.4]);
xlabel('Elevation (m)');  ax = gca; ax.FontSize=12; ylabel('\beta_{precip}','FontSize',16);
subplot(2,2,4);
plot(lscape(3,:),Bzall(1,:),'o'); lsline; xlim([2 7]); ylim([0 0.4]);
xlabel('Mean Temperature (^{o}C)'); ax = gca; ax.FontSize=12; ylabel('\beta_{precip}','FontSize',16);
%% plot scatters showing sig relationships for fraction of residual variance 
% (Winter BF and MR only)
% with regression lines
figure;
subplot(2,3,1);
plot(lscape(10,:),r2fracresid(1,:),'o'); lsline; xlim([0.1 0.7]); 
xlabel('Mean Water Yield'); ylabel({'Fraction of Residual';'Variance Explained'}); ax = gca; ax.FontSize=12;
subplot(2,3,4);
plot(lscape(2,:),r2fracresid(2,:),'o'); lsline; xlim([1800 2800]);ylim([0.6 1]); 
xlabel('Elevation (m)'); ylabel({'Fraction of Residual';'Variance Explained'}); ax = gca; ax.FontSize=12;
subplot(2,3,5);
plot(lscape(3,:),r2fracresid(2,:),'o'); lsline; xlim([2 7]); ylim([0.6 1]);
xlabel('Mean Temperature (^{o}C)'); ax = gca; ax.FontSize=12;
subplot(2,3,6);
plot(lscape(12,:),r2fracresid(2,:),'o'); lsline; xlim([15 40]); ylim([0.6 1]);
xlabel('Northerly Slope Aspect (%)'); ax = gca; ax.FontSize=12;

%% Same but using MR normalized for winter p (MR/p)
% don't include winter baseflow
figure;
subplot(1,3,1);
plot(lscape(2,:),r2fracresidnmr(2,:),'o'); lsline; ylim([0.3 1]); xlim([1800 2800]);
% ylim([0.6 1]); 
xlabel('Elevation (m)'); ylabel({'Fraction of Residual';'Variance Explained'}); ax = gca; ax.FontSize=12;
subplot(1,3,2);
plot(lscape(27,:),r2fracresidnmr(2,:),'o'); lsline; ylim([0.3 1]); xlim([-4 3]);
% lim([0.6 1]);
xlabel('Winter/Spring Temperature (^{o}C)'); ax = gca; ax.FontSize=12;
subplot(1,3,3);
plot(lscape(23,:),r2fracresidnmr(2,:),'o'); lsline; ylim([0.3 1]); xlim([0.3 1]); 
% ylim([0.6 1]);
xlabel('Mean PET/P'); ax = gca; ax.FontSize=12;

%% z score mean landscape/climate characteristics for comparison on how each impacts melt
zlscape = (lscape-mean(lscape,2))./std(lscape,0,2);
zmr2 = nanmean(allmeltrate); zmr2 = (zmr2-mean(zmr2))./std(zmr2); % z score average melt rate
zmrcp2 = nanmean(meltratecp); zmrcp2 = (zmrcp2-mean(zmrcp2))./std(zmrcp2);
zms2 = nanmean(allmeltstart); zms2 = (zms2-mean(zms2))./std(zms2); % z score average melt start
zmscp2 = nanmean(meltstartcp); zmscp2 = (zmscp2-mean(zmscp2))./std(zmscp2);

%% calculate regressions
[Bzlscape,~,Rzlscape,~,Szlscape] = regress(zmr2',[ zlscape(21,:)'  zlscape(27,:)' ones(12,1)]);% melt rate
[Bzlscape2,~,Rzlscape2,~,Szlscape2] = regress(zmrcp2',[ zlscape(21,:)' zlscape(23,:)' zlscape(27,:)' ones(12,1)]);
[Bzlscape3,~,Rzlscape3,~,Szlscape3] = regress(zms2',[zlscape(2,:)' ones(12,1)]);% melt start
[Bzlscape4,~,Rzlscape4,~,Szlscape4] = regress(zmscp2',[zlscape(2,:)'  ones(12,1)]);


% figure; plot(Bzlscape(1).*zlscape(2,:) + Bzlscape(2).*zlscape(21,:) + Bzlscape(3).*zlscape(23,:) + Bzlscape(4).*zlscape(27,:) + Bzlscape(5),zmr2,'o')
% [Bzlscape Bzlscape2 Bzlscape3 Bzlscape4]
[Szlscape; Szlscape2; Szlscape3; Szlscape4]
%% stepwise to determine what should go into model
stepwise([zlscape(2,:)' zlscape(21,:)' zlscape(23,:)' zlscape(27,:)'],zms2')
% stepwise indicates the models as such:
% MR: winterP + winter/springT, MRcp: PET/P
% MS (both): elevation


%% Repeat with MR normalized for winter P
% z score mean landscape/climate characteristics for comparison on how each impacts melt
znmr2 = nanmean(nmr); znmr2 = (znmr2-mean(znmr2))./std(znmr2); % z score average melt rate
znmrcp2 = nanmean(nmrcp); znmrcp2 = (znmrcp2-mean(znmrcp2))./std(znmrcp2);


%% calculate regressions
[Bnzlscape,~,Rnzlscape,~,Snzlscape] = regress(znmr2',[zlscape(2,:)' zlscape(21,:)'  ones(12,1)]);% melt rate
[Bnzlscape2,~,Rnzlscape2,~,Snzlscape2] = regress(znmrcp2',[zlscape(2,:)' zlscape(21,:)'   ones(12,1)]);



% figure; plot(Bzlscape(1).*zlscape(2,:) + Bzlscape(2).*zlscape(21,:) + Bzlscape(3).*zlscape(23,:) + Bzlscape(4).*zlscape(27,:) + Bzlscape(5),zmr2,'o')
% [Bzlscape Bzlscape2 Bzlscape3 Bzlscape4]
[Snzlscape; Snzlscape2;]
%% stepwise to determine what should go into model- MR norm for winterP
stepwise([zlscape(2,:)' zlscape(21,:)' zlscape(23,:)' zlscape(27,:)'],znmrcp2')
% stepwise indicates the models as such:
% MR: elev, winterP, MRcp: elev


%% repeat similar procedure but for predictability added by melt rate (normalized for winterP)

[Bzr2lscape,~,Rzr2lscape,~,Szr2lscape] = regress(r2fracresidnmr(2,:)',[ zlscape(2,:)'  zlscape(23,:)'  ones(12,1)]);% melt rate
Szr2lscape
Bzr2lscape
%% stepwise for pred added by MR
stepwise([ zlscape(2,:)'  zlscape(23,:)' zlscape(27,:)'],r2fracresidnmr(2,:))

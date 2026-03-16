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

% set colors of plots- RGB triplets
c = {[1 0 1],[1 0 0],[0 1 0],[0 1 1],[0 0 1],[.8 .7 .1],[0 0 0],[.75 0 .5],...
    [1 .5 0],[0 .75 .5],[0 .5 1],[.5 0 1]};
cmat = [1 0 1;1 0 0;0 1 0;0 1 1;0 0 1;.8 .7 .1;0 0 0;.75 0 .5;...
    1 .5 0;0 .75 .5;0 .5 1;.5 0 1]; %matrix of colors codes

% water yield
wy = q./p;

% only use CP melt rate from here on out

%z-score metrics
zwy = (wy-nanmean(wy))./nanstd(wy);
zp = (p-nanmean(p))./nanstd(p);
zt = (t-nanmean(t))./nanstd(t);
zsnowp = (snowP-nanmean(snowP))./nanstd(snowP);
zq = (q-nanmean(q))./nanstd(q);
zbf = (allbaseflow-nanmean(allbaseflow))./nanstd(allbaseflow);
zms = (allmeltstart-nanmean(allmeltstart))./nanstd(allmeltstart);
zmd = (allmeltdur-nanmean(allmeltdur))./nanstd(allmeltdur);
zmr = (meltratecp-nanmean(meltratecp))./nanstd(meltratecp);

%normalize melt rate for winter P by regressing and taking residuals
% normalize z scored mr for winter p
Bmrwp = nan(2,ncatch);
Rmrwp = nan(118,ncatch);
Smrwp = nan(4,ncatch);
for i=1:ncatch
    [Bmrwp(:,i),~,Rmrwp(:,i),~,Smrwp(:,i)] = regress(zmr(:,i),[zsnowp(:,i) ones(118,1)]);
end
znmr = Rmrwp;

%% regress each variable against P v Q residuals 
% first storage then melt and then vice versa
% everything z scored

% pick out p v q residuals
Bpq = nan(2,ncatch);
Rpq = nan(118,ncatch);
Spq = nan(4,ncatch);
for i=1:ncatch
    [Bpq(:,i),~,Rpq(:,i),~,Spq(:,i)] = regress(zq(:,i),[zp(:,i) ones(118,1)]);
end


% regress storage agains p q residuals
Bs = nan(2,ncatch);
Rs = nan(118,ncatch);
Ss = nan(4,ncatch);
for i=1:ncatch
    [Bs(:,i),~,Rs(:,i),~,Ss(:,i)] = regress(Rpq(:,i),[zbf(:,i) ones(118,1)]);
end

% regress mr against p q residuals
Bmr = nan(2,ncatch);
Rmr = nan(118,ncatch);
Smr = nan(4,ncatch);
for i=1:ncatch
    [Bmr(:,i),~,Rmr(:,i),~,Smr(:,i)] = regress(Rpq(:,i),[znmr(:,i) ones(118,1)]);
end

% regress storage and mr against p q residuals
% regress mr against p q residuals
Bsmr = nan(3,ncatch);
Rsmr = nan(118,ncatch);
Ssmr = nan(4,ncatch);
for i=1:ncatch
    [Bsmr(:,i),~,Rsmr(:,i),~,Ssmr(:,i)] = regress(Rpq(:,i),[zbf(:,i) znmr(:,i) ones(118,1)]);
end

% calculate r2 added in each order
r2sfirst = [Ss(1,:); Ssmr(1,:)-Ss(1,:)];
r2mrfirst = [Ssmr(1,:)-Smr(1,:); Smr(1,:)];

%% stepwise regression against residuals of p-q regression
for i =1:12
    stepwise([zbf(:,i) znmr(:,i)],Rpq(:,i))
end
% order to load (in reverse, W-WO -> J-CC):
% ms,ms,sm,sm,none,ms,sm,sm,ms,ms,ms,sm

% reorder (J-cc -> W-WO): sm,ms,ms,ms,sm,sm,ms,none,sm,sm,ms,ms

% this is consistent with figure showing r2 of each variable against p-q
% resgressions. However, in W-ECJ, neither var was loaded into model as 
% neither had sig relationship with p-q residuals.


%% bar plot showing r2 added by storage and MR individually
figure;
bar([Ss(1,:)' Smr(1,:)']);
ylabel('R^2')
xticklabels(catchnames)
legend('Storage','Melt Rate')

%% bar plot showing r2 added by storage and MR individually (panel 1)
% and regression coefficients (panel 2)
figure;
subplot(2,1,1)
bar([Ss(1,:)' Smr(1,:)']);
ylabel('R^2')
xticklabels(catchnames)
legend('Storage','Melt Rate')

subplot(2,1,2)
bar(Bsmr(1:2,:)');
ylabel('Beta Coefficient')
xticklabels(catchnames)
legend('Storage','Melt Rate')

%% calculate new metric of melt/storage dominance relative to the other
% Ratio of beta coef melt to beta coef storage
msratio = Bsmr(1,:)./Bsmr(2,:);

% is this related to landscape/climate characteristics?
% determine correlations between basic catchment characteristics and beta ratios.
% nothing is.
[mscorR, msrhoR] = corr(lscape',msratio');
Rsigms = mscorR; Rsigms(msrhoR>0.05)=0;


figure;
plot(lscape(11,:),msratio,'o')
%% bar plot showing residual r2 accounted for- storage regressed first
% this is for residuals of p-q regression
figure;
bar(r2sfirst');
ylabel('R^2 added')
xticklabels(catchnames)
legend('Storage','Melt Rate')

%% bar plot showing  r2 added- melt regressed first
% this is for residuals of p-q regression
figure;
bar(r2mrfirst');
ylabel('R^2 added')
xticklabels(catchnames)
legend('Storage','Melt Rate')

%% repeat regressions but this time include p in regressions of q
% i.e. regress all variables against q, not p-q residuals

% regress storage + p
Bs1 = nan(3,ncatch);
Rs1 = nan(118,ncatch);
Ss1 = nan(4,ncatch);
for i=1:ncatch
    [Bs1(:,i),~,Rs1(:,i),~,Ss1(:,i)] = regress(zq(:,i),[zp(:,i) zbf(:,i) ones(118,1)]);
end

% regress mr + p
Bmr1 = nan(3,ncatch);
Rmr1 = nan(118,ncatch);
Smr1 = nan(4,ncatch);
for i=1:ncatch
    [Bmr1(:,i),~,Rmr1(:,i),~,Smr1(:,i)] = regress(zq(:,i),[zp(:,i) znmr(:,i) ones(118,1)]);
end

% regress storage and mr + p
Bsmr1 = nan(4,ncatch);
Rsmr1 = nan(118,ncatch);
Ssmr1 = nan(4,ncatch);
for i=1:ncatch
    [Bsmr1(:,i),~,Rsmr1(:,i),~,Ssmr1(:,i)] = regress(zq(:,i),[zp(:,i) zbf(:,i) znmr(:,i) ones(118,1)]);
end

% calculate fraction of residual variance accounted for in each order
r2sfirst1 = [(Ss1(1,:)-Spq(1,:))./(1-Spq(1,:)); (Ssmr1(1,:)-Ss1(1,:))./(1-Spq(1,:))];
r2mrfirst1 = [(Ssmr1(1,:)-Smr1(1,:))./(1-Spq(1,:)); (Smr1(1,:)-Spq(1,:))./(1-Spq(1,:))];

% calculate fraction of residual variance accounted for AFTER precip AND
% storage/melt accounted for. 
r2bothvars = [(Ssmr1(1,:)-Smr1(1,:))./(1-Smr1(1,:)); (Ssmr1(1,:)-Ss1(1,:))./(1-Ss1(1,:))];



%% load variables in MLR in the order indicated by stepwise and calculate fraction of residual var explained by each
% order (J-CC -> W-WO): sm,ms,ms,ms,sm,sm,ms,none,sm,sm,ms,ms

sfracresid = [(Ss1(1,1)-Spq(1,1))./(1-Spq(1,1)) (Ssmr1(1,2:4)-Smr1(1,2:4))./(1-Smr1(1,2:4)) (Ss1(1,5:6)-Spq(1,5:6))./(1-Spq(1,5:6))...
    (Ssmr1(1,7)-Smr1(1,7))./(1-Smr1(1,7)) 0 (Ss1(1,9:10)-Spq(1,9:10))./(1-Spq(1,9:10)) (Ssmr1(1,11:12)-Smr1(1,11:12))./(1-Smr1(1,11:12))];
mrfracresid = [(Ssmr1(1,1)-Ss1(1,1))./(1-Ss1(1,1)) (Smr1(1,2:4)-Spq(1,2:4))./(1-Spq(1,2:4)) (Ssmr1(1,5:6)-Ss1(1,5:6))./(1-Ss1(1,5:6))...
    (Smr1(1,7:8)-Spq(1,7:8))./(1-Spq(1,7:8)) (Ssmr1(1,9:10)-Ss1(1,9:10))./(1-Ss1(1,9:10)) (Smr1(1,11:12)-Spq(1,11:12))./(1-Spq(1,11:12))];

fracresid = [sfracresid; mrfracresid];
%% bar plot showing fraction of residual variance explained (panel 2) when loaded in according to stepwise procedure
% and regression coefficients (panel 1)
figure;

% exclude beta for storage in ECJ and use just melt instead
beta = Bsmr1; beta(2:3,8) = [0; Bmr1(2,8)];
subplot(2,1,1)
b = bar(beta(1:3,:)');
b(2).FaceColor = [.2 .6 .5];
ylabel('Beta Coefficient')
xticklabels(catchnames)
legend('Precipitation','Storage','Melt Rate')

subplot(2,1,2)
b = bar([sfracresid' mrfracresid']);
b(1).FaceColor = [.2 .6 .5];
ylabel({'Fraction of Residual'; 'Variance Explained'})
xticklabels(catchnames)
legend('Storage','Melt Rate')


%% determine correlations between basic catchment characteristics and resdiual r2 added (from following stepwise procedure)
[scor, srho] = corr(lscape',fracresid(1,:)');
[mrcor,mrrho] = corr(lscape',fracresid(2,:)');

ssigr2 = scor; ssigr2(srho>0.05)=0;
mrsigr2 = mrcor; mrsigr2(mrrho>0.05)=0;

% plot significant relationships
figure;
subplot(1,2,1)
plot(lscape(27,:),mrfracresid,'o'); lsline 
ylabel({'Fraction of Residual'; 'Variance Explained'});
xlabel({'Mean Winter/Spring'; 'Temperature'});


subplot(1,2,2)
plot(lscape(22,:),mrfracresid,'o'); lsline
ylabel({'Fraction of Residual'; 'Variance Explained'});
xlabel('Mean PET');


%% plot relationships from above using scatter, diff color markers
figure;
subplot(1,2,1)
scatter(lscape(27,:),mrfracresid,[],cmat,'filled');  
ylabel({'Fraction of Residual'; 'Variance Explained'});
xlabel({'Mean Winter/Spring'; 'Temperature'});
ls = lsline; ls.LineWidth = 1;

subplot(1,2,2)
scatter(lscape(22,:),mrfracresid,[],cmat,'filled'); 
ylabel({'Fraction of Residual'; 'Variance Explained'});
xlabel('Mean PET');
ls = lsline; ls.LineWidth = 1;


%% do any climate/landscape variables explain residuals of PET - fracresid regression above?
[Bpet,~,Rpet,~,Spet] = regress(mrfracresid',[lscape(22,:)' ones(12,1)]);

[petcor,petrho] = corr(lscape',Rpet);

petsig = petcor; petsig(petrho>0.05)=0;

%% bootstrap  correlation coefficients
ci = bootci(1000,@corr,lscape(27,:)',mrfracresid')
rhos1000 = bootstrp(1000,'corr',lscape(27,:)',mrfracresid');
histogram(rhos1000)
%% bootstrap regression coefficients from above
%bootstrap 1000 times to find distribution of beta coefficients
x = nanmean(meltstartcp)'; y = nanmean(meltratecp)';
n = length(x);
for i=1:1000 % use randsample
  %disp(i);
  si = randsample(n,n,'true'); 
  bb = regress(y(si),[x(si) ones(n,1)]); 
  s(i) = bb(1); 
end;

%plot the distribution of b1 and the 95% and 99% confidence intervals
figure(1); 
h = histogram(s); 
hold on;
yl = get(gca,'ylim'); yl = yl(2); 
plot([prctile(s,97.5) prctile(s,97.5)],[0 yl],'r-','linewidth',1.5); 
plot([prctile(s,2.5) prctile(s,2.5)],[0 yl],'r-','linewidth',1.5);
xlabel('Beta Coefficient'); ylabel('Occurances');
% xlim([0 .03]); 
ylim([0 yl])
width = 300; height = 200;
set(gcf,'position',[100,100,width,height])

ci = [prctile(s,2.5) prctile(s,97.5)]

%% frac resid of just melt vs p-q
mrfr = [(Smr1(1,:)-Spq(1,:))./(1-Spq(1,:))];
[mrcor1, mrrho1] = corr(lscape',mrfr');
mrsig = mrcor1; mrsig(mrrho1>0.05)=0;

%% frac resid of  melt vs s+p -q
mrfr1 = [(Ssmr1(1,:)-Ss1(1,:))./(1-Ss1(1,:))];
[mrcor2, mrrho2] = corr(lscape',mrfr1');
mrsig1 = mrcor2; mrsig1(mrrho2>0.05)=0;

%% bar plot showing r2 added by storage and MR individually
% to predict q, including p in regression
figure;
bar([Ss1(1,:)' Smr1(1,:)']);
ylabel('R^2')
xticklabels(catchnames)
legend('Storage','Melt Rate')

%% bar plot showing residual r2 accounted for- storage regressed first
% to predict q, including p in regression
figure;
bar(r2sfirst1');
ylabel('Fraction Residual Var Explained')
xticklabels(catchnames)
legend('Storage','Melt Rate')

%% bar plot showing residual r2 accounted for- melt regressed first
% to predict q, including p in regression
figure;
bar(r2mrfirst1');
ylabel('Fraction Residual Var Explained'); ylim([0 .7])
xticklabels(catchnames)
legend('Storage','Melt Rate')

%% bar plot showing residual r2 accounted for- after storage AND melt accounted for
% to predict q, including p in regression
figure;
bar(r2bothvars');
ylabel('Fraction Residual Var Explained'); ylim([0 0.7])
xticklabels(catchnames)
legend('Storage','Melt Rate')


%% regress storage and melt rate against q, not accounting for p
% regress storage 
Bsq = nan(2,ncatch);
Rsq = nan(118,ncatch);
Ssq = nan(4,ncatch);
for i=1:ncatch
    [Bsq(:,i),~,Rsq(:,i),~,Ssq(:,i)] = regress(zq(:,i),[zbf(:,i) ones(118,1)]);
end

% regress mr 
Bmrq = nan(2,ncatch);
Rmrq = nan(118,ncatch);
Smrq = nan(4,ncatch);
for i=1:ncatch
    [Bmrq(:,i),~,Rmrq(:,i),~,Smrq(:,i)] = regress(zq(:,i),[znmr(:,i) ones(118,1)]);
end

%% bar plot showing r2 added by precip, storage and MR individually
% to predict q, not normalized for p
figure;
bar([Spq(1,:)' Ssq(1,:)' Smrq(1,:)']);
ylabel('R^2')
xticklabels(catchnames)
legend('Precipitation','Storage','Melt Rate')
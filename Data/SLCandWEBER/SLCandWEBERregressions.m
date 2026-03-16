% Recreate Andrews Multiple Linear Regression for all creeks WEBER and SLC

close all 
clear all
% load Salt Lake City climate metrics
load('hydro_vars1.mat');
hydro_vars=hydro_vars1;
%load slat lake city baseflow in january
load('janbaseflow.mat');
load('base1.mat');

%SLC data stars in 1901 and goes to 2014, need to add in 4 rows of nan's at
%the end of the data set

%load Weber River Basin Climate metrics and streamflow
WRWbaseflow=csvread('WRWbaseflow.csv');
WRWmeltduration=csvread('WRWmeltduration.csv');
WRWmeltrate=csvread('WRWmeltrate.csv');
WRWprecipitation=csvread('WRWprecipitation.csv');
WRWstreamflow=csvread('WRWstreamflow.csv');
WRWtemperature=csvread('WRWtemperature.csv');
%%load monthly P vals
WRWJanP=csvread('JanPmm.csv');
WRWFebP=csvread('FebPmm.csv');
WRWMarP=csvread('MarPmm.csv');
WRWAprP=csvread('AprPmm.csv');
WRWMayP=csvread('MayPmm.csv');
WRWJunP=csvread('JunPmm.csv');
WRWJulP=csvread('JulPmm.csv');
WRWAugP=csvread('AugPmm.csv');
WRWSepP=csvread('SepPmm.csv');
WRWOctP=csvread('OctPmm.csv');
WRWNovP=csvread('NovPmm.csv');
WRWDecP=csvread('DecPmm.csv');
%load monthly T vals for Weber River

WRWJanT=csvread('JanMeanT_trimmed.csv',1,1);
WRWFebT=csvread('FebMeanT_trimmed.csv',1,1);
WRWMarT=csvread('MarMeanT_trimmed.csv',1,1);
WRWAprT=csvread('AprMeanT_trimmed.csv',1,1);
WRWMayT=csvread('MayMeanT_trimmed.csv',1,1);
WRWJunT=csvread('JunMeanT_trimmed.csv',1,1);
WRWJulT=csvread('JulMeanT_trimmed.csv',1,1);
WRWAugT=csvread('AugMeanT_trimmed.csv',1,1);
WRWSepT=csvread('SepMeanT_trimmed.csv',1,1);
WRWOctT=csvread('OctMeanT_trimmed.csv',1,1);
WRWNovT=csvread('NovMeanT_trimmed.csv',1,1);
WRWDecT=csvread('DecMeanT_trimmed.csv',1,1);

%WRW data starts in 1905 and goes to 2018, add in 4 rows of nans to make
%data start in 1901

x = nan(4,5);
WRWbaseflow=[x;WRWbaseflow];
WRWmeltrate=[x;WRWmeltrate];
WRWmeltduration=[x;WRWmeltduration];
WRWprecipitation=[x;WRWprecipitation];
WRWstreamflow=[x;WRWstreamflow];
WRWtemperature=[x;WRWtemperature];

WRWJanP=[x;WRWJanP];
WRWFebP=[x;WRWFebP];
WRWMarP=[x;WRWMarP];
WRWAprP=[x;WRWAprP];
WRWMayP=[x;WRWMayP];
WRWJunP=[x;WRWJunP];
WRWJulP=[x;WRWJulP];
WRWAugP=[x;WRWAugP];
WRWSepP=[x;WRWSepP];
WRWOctP=[x;WRWOctP];
WRWNovP=[x;WRWNovP];
WRWDecP=[x;WRWDecP];

WRWJanT=[x;WRWJanT];
WRWFebT=[x;WRWFebT];
WRWMarT=[x;WRWMarT];
WRWAprT=[x;WRWAprT];
WRWMayT=[x;WRWMayT];
WRWJunT=[x;WRWJunT];
WRWJulT=[x;WRWJulT];
WRWAugT=[x;WRWAugT];
WRWSepT=[x;WRWSepT];
WRWOctT=[x;WRWOctT];
WRWNovT=[x;WRWNovT];
WRWDecT=[x;WRWDecT];


%%
ncatch=12;
ColorSet=varycolor(ncatch);
slcncatch=7;
for i= 1:slcncatch
    %PULL OUT VALUES FROM HYDROVARS DATA AND PUT INTO INDIVIDUAL VARIABLES
    %FOR Annual P, Melt Rate,  Melt Duration , Baseflow
precip(:,i)=hydro_vars{1,i}.AnnualP;
baseflow(:,i)=base1(:,i) %hydro_vars{1,i}.Baseflow %
MeltRate(:,i)=hydro_vars{1,i}.MeltRate;
MeltDuration(:,i)=hydro_vars{1,i}.MeltDuration;
SLCStreamflow(:,i)=hydro_vars{1,i}.Streamflow;
%CREATE SLC WATER YIELD VAR
WaterYield(:,i)=(SLCStreamflow(:,i)./precip(:,i))
SLCannualT(:,i)=(hydro_vars{1,i}.AnnualT)
SLCJanP(:,i)=(hydro_vars{1,i}.JanP);
SLCFebP(:,i)=(hydro_vars{1,i}.FebP);
SLCMarP(:,i)=(hydro_vars{1,i}.MarP);
SLCAprP(:,i)=(hydro_vars{1,i}.AprP);
SLCMayP(:,i)=(hydro_vars{1,i}.MayP);
SLCJunP(:,i)=(hydro_vars{1,i}.JunP);
SLCJulP(:,i)=(hydro_vars{1,i}.JulP);
SLCAugP(:,i)=(hydro_vars{1,i}.AugP);
SLCSepP(:,i)=(hydro_vars{1,i}.SepP);
SLCOctP(:,i)=(hydro_vars{1,i}.OctP);
SLCNovP(:,i)=(hydro_vars{1,i}.NovP);
SLCDecP(:,i)=(hydro_vars{1,i}.DecP);


SLCJanT(:,i)=(hydro_vars{1,i}.JanT);
SLCFebT(:,i)=(hydro_vars{1,i}.FebT);
SLCMarT(:,i)=(hydro_vars{1,i}.MarT);
SLCAprT(:,i)=(hydro_vars{1,i}.AprT);
SLCMayT(:,i)=(hydro_vars{1,i}.MayT);
SLCJunT(:,i)=(hydro_vars{1,i}.JunT);
SLCJulT(:,i)=(hydro_vars{1,i}.JulT);
SLCAugT(:,i)=(hydro_vars{1,i}.AugT);
SLCSepT(:,i)=(hydro_vars{1,i}.SepT);
SLCOctT(:,i)=(hydro_vars{1,i}.OctT);
SLCNovT(:,i)=(hydro_vars{1,i}.NovT);
SLCDecT(:,i)=(hydro_vars{1,i}.DecT);
end
%% CREATE WATER YieLD VARIABLE FOR WRW
for i=1:5
WRWWaterYield(:,i)=(WRWstreamflow(:,i)./WRWprecipitation(:,i));
end
%% ADD IN EXTRA NANS AND END OF SLC WATERSHEDS TO MAKE LENGTHS THE SAME
addx=(nan(4,7));
precip=[precip;addx];
baseflow=[baseflow;addx];
MeltRate=[MeltRate;addx];
MeltDuration=[MeltDuration;addx];
WaterYield=[WaterYield;addx];
SLCstreamflow=[SLCStreamflow;addx];

SLCJanP=[SLCJanP;addx];
SLCFebP=[SLCFebP;addx];
SLCMarP=[SLCMarP;addx];
SLCAprP=[SLCAprP;addx];
SLCMayP=[SLCMayP;addx];
SLCJunP=[SLCJunP;addx];
SLCJulP=[SLCJulP;addx];
SLCAugP=[SLCAugP;addx];
SLCSepP=[SLCSepP;addx];
SLCOctP=[SLCOctP;addx];
SLCNovP=[SLCNovP;addx];
SLCDecP=[SLCDecP;addx];

SLCJanT=[SLCJanT;addx];
SLCFebT=[SLCFebT;addx];
SLCMarT=[SLCMarT;addx];
SLCAprT=[SLCAprT;addx];
SLCMayT=[SLCMayT;addx];
SLCJunT=[SLCJunT;addx];
SLCJulT=[SLCJulT;addx];
SLCAugT=[SLCAugT;addx];
SLCSepT=[SLCSepT;addx];
SLCOctT=[SLCOctT;addx];
SLCNovT=[SLCNovT;addx];
SLCDecT=[SLCDecT;addx];
%%
SLCannualT=[SLCannualT;addx];
%%
%%CONCATOANTE SLC WATERSHEDS WITH WRW W;ATERSHEDS
allprecip=[precip,WRWprecipitation];
allbaseflow=[baseflow,WRWbaseflow];
allmeltrate=[MeltRate,WRWmeltrate];
allmeltduration=[MeltDuration,WRWmeltduration];
allstreamflow=[SLCstreamflow,WRWstreamflow];
allyield=[WaterYield,WRWWaterYield];
alltemp=[SLCannualT,WRWtemperature];

allJanP=[SLCJanP,WRWJanP];
allFebP=[SLCFebP,WRWFebP];
allMarP=[SLCMarP,WRWMarP];
allAprP=[SLCAprP,WRWAprP];
allMayP=[SLCMayP,WRWMayP];
allJunP=[SLCJunP,WRWJunP];
allJulP=[SLCJulP,WRWJulP];
allAugP=[SLCAugP,WRWAugP];
allSepP=[SLCSepP,WRWSepP];
allOctP=[SLCOctP,WRWOctP];
allNovP=[SLCNovP,WRWNovP];
allDecP=[SLCDecP,WRWDecP];

allJanT=[SLCJanT,WRWJanT];
allJanT=[SLCJanT,WRWJanT];
allFebT=[SLCFebT,WRWFebT];
allMarT=[SLCMarT,WRWMarT];
allAprT=[SLCAprT,WRWAprT];
allMayT=[SLCMayT,WRWMayT];
allJunT=[SLCJunT,WRWJunT];
allJulT=[SLCJulT,WRWJulT];
allAugT=[SLCAugT,WRWAugT];
allSepT=[SLCSepT,WRWSepT];
allOctT=[SLCOctT,WRWOctT];
allNovT=[SLCNovT,WRWNovT];
allDecT=[SLCDecT,WRWDecT];




save('allprecip.mat','allprecip');
save('allbaseflow.mat','allbaseflow');
save('allmeltrate.mat','allmeltrate');
save('allmeltduration.mat','allmeltduration');
save('allstreamflow.mat','allstreamflow');
save('allyield.mat','allyield');
save('alltemp.mat','alltemp');

save('allJanP.mat','allJanP');
save('allFebP.mat','allFebP');
save('allMarP.mat','allMarP');
save('allAprP.mat','allAprP');
save('allMayP.mat','allMayP');
save('allJunP.mat','allJunP');
save('allJulP.mat','allJulP');
save('allAugP.mat','allAugP');
save('allSepP.mat','allSepP');
save('allOctP.mat','allOctP');
save('allNovP.mat','allNovP');
save('allDecP.mat','allDecP');


save('allJanT.mat','allJanT');
save('allFebT.mat','allFebT');
save('allMarT.mat','allMarT');
save('allAprT.mat','allAprT');
save('allMayT.mat','allMayT');
save('allJunT.mat','allJunT');
save('allJulT.mat','allJulT');
save('allSepT.mat','allSepT');
save('allOctT.mat','allOctT');
save('allDecT.mat','allDecT');

%% Predict Streamflow MLR
%%
catchnames = [string('SLC CC'),string('SLC RB'),string('SLC EC'),string('SLC PC')...
    string('SLC MC'),string('SLC BC'),string('SLC LC'),string('WR ECJ'), string('WR CC'),...
    string('WR LC'),string('WR OSF'),string('WR WO')];
ncatch=12;
nyears=1:118;
x1=ones(118,1);

for i= 1:ncatch

%regress all creeks SLC and WRW with streamflow vs annual P, baseflow, meltrate and melt duration

[BetaMLR(:,i),~,~,~,statsMLR(:,i)]=regress((allstreamflow(:,i)),[allprecip(:,i),allbaseflow(:,i),allmeltrate(:,i),allmeltduration(:,i),x1]); %regress all creeks SLC and WRW with streamflow vs annual P, baseflow, meltrate and melt duration
%Row 1 in Beta is Annualp
%Row 2 in Beta is Baseflow
%Row 3 in Beta is Melt Rate
%row 4 in beta is Melt Duration

NewPredictedStreamflow(:,i)=(((BetaMLR(1,i)).*allprecip(:,i))+(BetaMLR(2,i).*allbaseflow(:,i))+(BetaMLR(3,i).*allmeltrate(:,i))+(BetaMLR(4,i).*allmeltduration(:,i))+(BetaMLR(5,i)))


end
%save('NewPredictedStreamflow.mat')
%PredictedStreamflow(:,1)=(((B1precip(1,1).*precip(:,1))+(B1baseflow(1,1).*baseflow(:,1))+(B1MeltRate(1,1).*MeltRate(:,1))+(B1MeltDuration(1,1).*MeltDuration(:,1))))
%%  MLR with B5 included

figure;
for i=1:ncatch
    hold on
        plot(NewPredictedStreamflow(:,i),allstreamflow(:,i),'.','Color',ColorSet(i,:),'MarkerSize',15)
   
title('Annual Predicted Streamflow vs Observed Streamflow','FontSize',20);
xlabel('Annual Predicted Streamflow (mm)','FontSize',20);
ylabel('Annual Observed Streamflow (mm)','FontSize',20);

ylim([0 1800]);
xlim([0 1800]);
%legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),...
    %catchnames(:,8),catchnames(:,9),catchnames(:,10),catchnames(:,11),catchnames(:,12),'fontsize',20)
predictedStreamOnes{1,i}=[NewPredictedStreamflow(:,i),x1];
[B1predictedstreamflow(:,i),~,~,~,statspredictedstreamflow(:,i)]=regress(allstreamflow(:,i),predictedStreamOnes{1,i});
set(gca, 'fontsize',20)
end
hlegend=legend(['SLCC R^2:',sprintf('%.2f',statspredictedstreamflow(1,1))],...
      ['SLRB R^2:',sprintf('%.2f',statspredictedstreamflow(1,2))],...
      ['SLEC R^2:',sprintf('%.2f',statspredictedstreamflow(1,3))],...
      ['SLPC R^2:',sprintf('%.2f',statspredictedstreamflow(1,4))],...
      ['SLMC R^2:',sprintf('%.2f',statspredictedstreamflow(1,5))],...
      ['SLBC R^2:',sprintf('%.2f',statspredictedstreamflow(1,6))],...
      ['SLLC R^2:',sprintf('%.2f',statspredictedstreamflow(1,7))],...
      ['WRECJ R^2:',sprintf('%.2f',statspredictedstreamflow(1,8))],...
      ['WRCC R^2:',sprintf('%.2f',statspredictedstreamflow(1,9))],...
      ['WRLC R^2:',sprintf('%.2f',statspredictedstreamflow(1,10))],...
      ['WROSF R^2:',sprintf('%.2f',statspredictedstreamflow(1,11))],...
   ['WRWO R^2:',sprintf('%.2f',statspredictedstreamflow(1,12))],'location','northwest')
hlegend.NumColumns=4

    %%
        %% Plot just SLC
    %%  MLR 

figure;
for i=1:ncatch
    hold on
    if i <=7
        plot(NewPredictedStreamflow(:,i),allstreamflow(:,i),'*','MarkerSize',12)
    end
        
%plot(NewPredictedYield(:,i),allyield(:,i),'o','MarkerSize',12)
%lsline
    
title('Annual Predicted Streamflow vs Observed Streamflow','FontSize',20)
xlabel('Annual Predicted Streamflow (mm)','FontSize',20)
ylabel('Annual Observed Streamflow (mm)','FontSize',20)
set(gca,'fontsize',20)
%ylim([0 1800])
%xlim([0 1800])
legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7))
predictedStreamOnes{1,i}=[NewPredictedStreamflow(:,i),x1];
[B1predictedstreamflow(:,i),~,~,~,statspredictedstreamflow(:,i)]=regress(allstreamflow(:,i),predictedStreamOnes{1,i});

end
legend(['SLC CC R^2:',sprintf('%.2f',statspredictedstreamflow(1,1))],...
     ['SLC RB R^2:',sprintf('%.2f',statspredictedstreamflow(1,2))],...
     ['SLC EC R^2:',sprintf('%.2f',statspredictedstreamflow(1,3))],...
     ['SLC PC R^2:',sprintf('%.2f',statspredictedstreamflow(1,4))],...
     ['SLC MC R^2:',sprintf('%.2f',statspredictedstreamflow(1,5))],...
     ['SLC BC R^2:',sprintf('%.2f',statspredictedstreamflow(1,6))],...
     ['SLC LC R^2:',sprintf('%.2f',statspredictedstreamflow(1,7))],'location','northeastoutside')
    

    %% Predict Water Yeild
    
    for i= 1:ncatch

%regress all creeks SLC and WRW with streamflow vs annual P, baseflow, meltrate and melt duration

[BetaMLRYield(:,i),~,~,~,statsMLRYeild(:,i)]=regress((allyield(:,i)),[allbaseflow(:,i),allmeltrate(:,i),allmeltduration(:,i),x1]); %regress all creeks SLC and WRW with streamflow vs annual P, baseflow, meltrate and melt duration

%Row 1 in Beta is Baseflow
%Row 2 in Beta is Melt Rate
%row 3 in beta is Melt Duration

NewPredictedYield(:,i)=(((BetaMLRYield(1,i)).*allbaseflow(:,i))+(BetaMLRYield(2,i).*allmeltrate(:,i))+(BetaMLRYield(3,i).*allmeltduration(:,i))+(BetaMLRYield(4,i)))


end
%save('NewPredictedStreamflow.mat')
%PredictedStreamflow(:,1)=(((B1precip(1,1).*precip(:,1))+(B1baseflow(1,1).*baseflow(:,1))+(B1MeltRate(1,1).*MeltRate(:,1))+(B1MeltDuration(1,1).*MeltDuration(:,1))))
%%  MLR 

figure;
for i=1:ncatch
    hold on
    if i <=7
        plot(NewPredictedYield(:,i),allyield(:,i),'*','MarkerSize',12)
    else
        
plot(NewPredictedYield(:,i),allyield(:,i),'o','MarkerSize',12)
%lsline
    end
title('Annual Predicted Water Yield vs Observed WaterYield','FontSize',20)
xlabel('Annual Predicted Yield (mm)','FontSize',20)
ylabel('Annual Observed Yield (mm)','FontSize',20)
set(gca,'fontsize',20)
%ylim([0 1800])
%xlim([0 1800])
legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),...
    catchnames(:,8),catchnames(:,9),catchnames(:,10),catchnames(:,11),catchnames(:,12))
predictedyieldOnes{1,i}=[NewPredictedYield(:,i),x1];
[B1predictedyeild(:,i),~,~,~,statspredictedyield(:,i)]=regress(allyield(:,i),predictedyieldOnes{1,i});

end
legend(['SLCC R^2:',sprintf('%.2f',statspredictedyield(1,1))],...
     ['SLRB R^2:',sprintf('%.2f',statspredictedyield(1,2))],...
     ['SLEC R^2:',sprintf('%.2f',statspredictedyield(1,3))],...
     ['SLPC R^2:',sprintf('%.2f',statspredictedyield(1,4))],...
     ['SLMC R^2:',sprintf('%.2f',statspredictedyield(1,5))],...
     ['SLBC R^2:',sprintf('%.2f',statspredictedyield(1,6))],...
     ['SLLC R^2:',sprintf('%.2f',statspredictedyield(1,7))],...
     ['WRECJ R^2:',sprintf('%.2f',statspredictedyield(1,8))],...
     ['WRCC R^2:',sprintf('%.2f',statspredictedyield(1,9))],...
     ['WRLC R^2:',sprintf('%.2f',statspredictedyield(1,10))],...
     ['WROSF R^2:',sprintf('%.2f',statspredictedyield(1,11))],...
    ['WRWO R^2:',sprintf('%.2f',statspredictedyield(1,12))],'location','northeastoutside')


        %% Predict Q With Just  P
    
h=zeros(1,12);

figure;
for i=1:ncatch
    hold on
   
         plot(allprecip(:,i),allstreamflow(:,i),'.','Color',ColorSet(i,:),'MarkerSize',8)
    
    
%lsline
    
title('Annual Precipitation vs Annual Streamflow','FontSize',20)
xlabel('Annual Precipitation (mm)','FontSize',20)
ylabel('Annual Streamflow (mm)','FontSize',20)

ylim([0 1800])
xlim([0 1800])
%regress all creeks PvQ
set(gca, 'fontsize',20)
[BetaPvQ(:,i),~,~,~,statsPvQ(:,i)]=regress(allstreamflow(:,i),[allprecip(:,i),x1]); %regress all creeks SLC and WRW with streamflow vs P

end
%legend(['SLCC R^2:',sprintf('%.2f',statsPvQ(1,1))],...
%      ['SLRB R^2:',sprintf('%.2f',statsPvQ(1,2))],...
%      ['SLEC R^2:',sprintf('%.2f',statsPvQ(1,3))],...
%      ['SLPC R^2:',sprintf('%.2f',statsPvQ(1,4))],...
%      ['SLMC R^2:',sprintf('%.2f',statsPvQ(1,5))],...
%      ['SLBC R^2:',sprintf('%.2f',statsPvQ(1,6))],...
%      ['SLLC R^2:',sprintf('%.2f',statsPvQ(1,7))],...
%      ['WRECJ R^2:',sprintf('%.2f',statsPvQ(1,8))],...
%      ['WRCC R^2:',sprintf('%.2f',statsPvQ(1,9))],...
%      ['WRLC R^2:',sprintf('%.2f',statsPvQ(1,10))],...
%      ['WROSF R^2:',sprintf('%.2f',statsPvQ(1,11))],...
%     ['WRWO R^2:',sprintf('%.2f',statsPvQ(1,12))],'location','northeastoutside')
lsline
%% Just SLC
h=zeros(1,12);

figure;
for i=1:ncatch
    hold on
     if i <=7
         plot(allprecip(:,i),allstreamflow(:,i),'*','MarkerSize',8)
     end
   %lsline  
title('Annual Precipitation vs Annual Streamflow','FontSize',20)
xlabel('Annual Precipitation (mm)','FontSize',20)
ylabel('Annual Streamflow (mm)','FontSize',20)
ylim([0 1300])
xlim([0 1300])
%regress all creeks PvQ
set(gca, 'fontsize',20)
[BetaPvQ(:,i),~,~,~,statsPvQ(:,i)]=regress(allstreamflow(:,i),[allprecip(:,i),x1]); %regress all creeks SLC and WRW with streamflow vs P

end
legend((['SLC CC R^2:',sprintf('%.2f',statsPvQ(1,1))]),...
     ['SLC RB R^2:',sprintf('%.2f',statsPvQ(1,2))],...
     ['SLC EC R^2:',sprintf('%.2f',statsPvQ(1,3))],...
     ['SLC PC R^2:',sprintf('%.2f',statsPvQ(1,4))],...
     ['SLC MC R^2:',sprintf('%.2f',statsPvQ(1,5))],...
     ['SLC BC R^2:',sprintf('%.2f',statsPvQ(1,6))],...
     ['SLC LC R^2:',sprintf('%.2f',statsPvQ(1,7))],'location','northeast')
lsline

%%
% plot baseflow over time

    

figure;
for i= 1:ncatch
    hold on
    
        plot(nyears,allbaseflow(:,i),'Color',ColorSet(i,:),'linewidth',1)
   
    
    end
   
%%
year= 1901:2018;
%Plot mean smoothed baseflow over time
for i= 1: ncatch
    %calculate meansmooth function for baseflow. download mean_smooth.m
    %function into working directory 
meansmoothBF(:,i)=mean_smooth(allbaseflow(:,i),length(allbaseflow(:,1)),3,1)';
end
figure;
for i= 1:ncatch
    hold on
   
        plot(year,meansmoothBF(:,i),'Color',ColorSet(i,:),'linewidth',3)
    
    hold on
  
    
%title('?S Over Time','FontSize',20)
xlabel('Year','FontSize',20)
ylabel('?S(mm)','FontSize',20)
set(gca, 'fontsize',20)
end
legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12), 'location', 'northeastoutside')

%% Plot Deviation from mean over time
DVmeanbase=allbaseflow-nanmean(allbaseflow)
figure;
for i=1:12
DVmeansmooth(:,i)=mean_smooth(DVmeanbase(:,i),length(DVmeanbase(:,i)),1,1)'

plot(year,DVmeansmooth(:,i),'linewidth',2,'Color',ColorSet(i,:))
hold on
xlabel('Year','FontSize',20)
ylabel('S Deviation from Mean(mm)','FontSize',20)

set(gca,'fontsize',20)
ylim([-0.3 0.6])
end

hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=4
%% Just SLC
figure;
for i=1:7
DVmeansmooth(:,i)=mean_smooth(DVmeanbase(:,i),length(DVmeanbase(:,i)),3,1)'
plot(year,DVmeansmooth,'linewidth',2)
xlabel('Year','FontSize',20)
ylabel('?S Deviation from Mean(mm)','FontSize',20)
set(gca,'fontsize',20)
end
legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7), 'location', 'northeastoutside','FontSize',20)

%% plot Temperature over time
%years= 1901:2018
figure;
for i=1:12

plot(year,alltemp(:,i),'linewidth',2,'Color',ColorSet(i,:))
hold on
xlabel('Year','FontSize',20)
ylabel('Temperature(C)','FontSize',20)
set(gca,'fontsize',20)
ylim([0 12])
end
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=4
%%
%% plot streamflow over time
%years= 1901:2018
figure;
for i=1:12

plot(year,allstreamflow(:,i),'linewidth',2,'Color',ColorSet(i,:))
hold on
xlabel('Year','FontSize',20)
ylabel('Discharge(mm)','FontSize',20)
set(gca,'fontsize',20)
end
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=4

%% plot precip over time
%years= 1901:2018
figure;
for i=1:12

plot(year,allprecip(:,i),'linewidth',2,'Color',ColorSet(i,:))
hold on
xlabel('Year','FontSize',20)
ylabel('Precipitation(mm)','FontSize',20)
set(gca,'fontsize',20)
end
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=4
%% %does january P control january Q
figure;
%does january P control january Q
allbaseflow(allbaseflow == 0) = NaN
allJanP(allJanP == 0) = NaN
allJanT(allJanT == 0) = NaN
for i= 1:12
    plot(allJanP(:,i),allbaseflow(:,i),'.','Color',ColorSet(i,:),'MarkerSize',14)
    hold on
    ax=gca
    xlabel('Mean January Precipitation (mm)','fontsize',24)
    ylabel('Mean January Discharge (mm)','fontsize',24)
    %title('Precipitation vs Discharge','fontsize',24)
    ax.XAxis.FontSize=18
    ax.YAxis.FontSize=18
    [~,~,~,~,stats(:,i)]=regress(allbaseflow(:,i),[allJanP(:,i) ones(length(allJanP(:,1)),1)])
    
end
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=4

janPvQR=stats(1,:) %january PvQ R2= row 1 of stats output
janPvQPval=stats(3,:) %january PvQ R2= row 1 of stats output

figure;
%does January T control january Q
for i= 1:12
    plot(allJanT(:,i),allbaseflow(:,i),'.','Color',ColorSet(i,:),'MarkerSize',14)
    hold on
    xlabel('Mean January Temperature (C) ','fontsize',20)
    ylabel('Mean January Discharge (mm) ','fontsize',20)
      %title('Temperature vs Discharge','fontsize',24)
      ax=gca
       ax.XAxis.FontSize=18
    ax.YAxis.FontSize=18
      [~,~,~,~,stats(:,i)]=regress(allbaseflow(:,i),[allJanT(:,i) ones(length(allJanT(:,1)),1)])
end
janTvQR=stats(1,:) %january TvQ R2= row 1 of stats output
janTvQPval=stats(3,:) %january PvQ R2= row 1 of stats output
hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=4

%% Why is baseflow important
%% Yes we can use January baseflow as a metric for groundwater discharge
%little to no influence from currrent precipitation(rain events) or
%temperature (melt events)
% dos an increase in baseflow account for the same amount of increase in
% streamflow (ie. is it just addative) or does above average baseflow
% predispose a stream to have above average streamflow

%Storage vairbilty influence on annual variability correlation plot
for i= 1:12
meanofmeanJanQ=nanmean(allbaseflow); %calculate the mean of baseflow (should be one value for each column)
meanofAnnualQ=nanmean(allstreamflow);%calculate annual mean streamflow
end
for i= 1:12
ZscoreBase(:,i)=allbaseflow(:,i)-meanofmeanJanQ(:,i); %calculate deviation from the mean for baseflow
ZscoreAnnualQ(:,i)=allstreamflow(:,i)-meanofAnnualQ(:,i);%calculate deviation from the mean for annual Q
end
%mulitple the January Q variabilty by *365
% meanJanQNEW is the variability in the "daily discharge" that would
% come out of the stream in any jnaury given the year
% Zscore of that is the above or below average daily component
% if we multiple that by 365 we get the annual contribution of above or
% below average discharge
ZscoreAnnualBaseflow=ZscoreBase.*365;

%%
figure;
%plot the variability of storage that contributes to variability in
%streamflow

x=[400;-400]
y=[400;-400]

%plot(x,y)
%lsline
hold on
for i= 1:12
plot(ZscoreAnnualBaseflow(:,i),ZscoreAnnualQ(:,i),'.','Color',ColorSet(i,:),'MarkerSize',14)
hold on
%set(lsline,'LineWidth',2) % set a thicker regression line
xlabel('Anomoly in Storage (mm)','fontsize',20)
ylabel('Anomoly in Annual Streamflow (mm)','fontsize',20)
title('Storage Contribution to Annual Streamflow Variability  ','fontsize',24)

set(gca,'FontSize',20);% to alter axis font size
xlim([-400 400])
ylim([-400 400])
%Storage vairbilty influence on annual variability correlation plot
[slopeDM(:,i),~,~,~,statsDM(:,i)]=regress(ZscoreAnnualQ(:,i),[ZscoreAnnualBaseflow(:,i) ones(length(ZscoreAnnualBaseflow),1)])
%regress you need regress(y,[x ones]) needs a column of ones after the x variable
end

hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=2

%% CDF's of precipitation
%% Distribution of precipitation Fall P Winter P Spring P Summer P Percentage CDF

for i= 1:ncatch
JanPMean(:,i)=nanmean(allJanP(:,i))
FebPMean(:,i)=nanmean(allFebP(:,i))
MarPMean(:,i)=nanmean(allMarP(:,i))
AprPMean(:,i)=nanmean(allAprP(:,i))
MayPMean(:,i)=nanmean(allMayP(:,i))
JunPMean(:,i)=nanmean(allJunP(:,i))
JulPMean(:,i)=nanmean(allJulP(:,i))
AugPMean(:,i)=nanmean(allAugP(:,i))
SepPMean(:,i)=nanmean(allSepP(:,i))
OctPMean(:,i)=nanmean(allOctP(:,i))
NovPMean(:,i)=nanmean(allNovP(:,i))
DecPMean(:,i)=nanmean(allDecP(:,i))
end
%%porportion of annual precipitation that each month contributes to
%%
for i= 1:ncatch
        %october is first month 1: 12=september
PorpofannualP(1,i)=OctPMean(:,i)/nanmean(allprecip(:,i));
PorpofannualP(2,i)=NovPMean(:,i)/nanmean(allprecip(:,i));
PorpofannualP(3,i)=DecPMean(:,i)/nanmean(allprecip(:,i));
PorpofannualP(4,i)=JanPMean(:,i)/nanmean(allprecip(:,i));
PorpofannualP(5,i)=FebPMean(:,i)/nanmean(allprecip(:,i));
PorpofannualP(6,i)=MarPMean(:,i)/nanmean(allprecip(:,i));
PorpofannualP(7,i)=AprPMean(:,i)/nanmean(allprecip(:,i));
PorpofannualP(8,i)=MayPMean(:,i)/nanmean(allprecip(:,i));
PorpofannualP(9,i)=JunPMean(:,i)/nanmean(allprecip(:,i));
PorpofannualP(10,i)=JulPMean(:,i)/nanmean(allprecip(:,i));
PorpofannualP(11,i)=AugPMean(:,i)/nanmean(allprecip(:,i));
PorpofannualP(12,i)=SepPMean(:,i)/nanmean(allprecip(:,i));
end
for i=1:ncatch
 annualPper(:,i)=[PorpofannualP(1,i);...
     (PorpofannualP(1,i)+PorpofannualP(2,i));...
     (PorpofannualP(1,i)+PorpofannualP(2,i)+PorpofannualP(3,i));...
     (PorpofannualP(1,i)+PorpofannualP(2,i)+PorpofannualP(3,i)+PorpofannualP(4,i));...
    (PorpofannualP(1,i)+PorpofannualP(2,i)+PorpofannualP(3,i)+PorpofannualP(4,i))+PorpofannualP(5,i);...
    (PorpofannualP(1,i)+PorpofannualP(2,i)+PorpofannualP(3,i)+PorpofannualP(4,i))+PorpofannualP(5,i)+PorpofannualP(6,i);...
    (PorpofannualP(1,i)+PorpofannualP(2,i)+PorpofannualP(3,i)+PorpofannualP(4,i))+PorpofannualP(5,i)+PorpofannualP(6,i)+PorpofannualP(7,i);...
    (PorpofannualP(1,i)+PorpofannualP(2,i)+PorpofannualP(3,i)+PorpofannualP(4,i))+PorpofannualP(5,i)+PorpofannualP(6,i)+PorpofannualP(7,i)+PorpofannualP(8,i);...
   (PorpofannualP(1,i)+PorpofannualP(2,i)+PorpofannualP(3,i)+PorpofannualP(4,i))+PorpofannualP(5,i)+PorpofannualP(6,i)+PorpofannualP(7,i)+PorpofannualP(8,i)+PorpofannualP(9,i);...
   (PorpofannualP(1,i)+PorpofannualP(2,i)+PorpofannualP(3,i)+PorpofannualP(4,i))+PorpofannualP(5,i)+PorpofannualP(6,i)+PorpofannualP(7,i)+PorpofannualP(8,i)+PorpofannualP(9,i)+PorpofannualP(10,i);...
   (PorpofannualP(1,i)+PorpofannualP(2,i)+PorpofannualP(3,i)+PorpofannualP(4,i))+PorpofannualP(5,i)+PorpofannualP(6,i)+PorpofannualP(7,i)+PorpofannualP(8,i)+PorpofannualP(9,i)+PorpofannualP(10,i)+PorpofannualP(11,i);...
   (PorpofannualP(1,i)+PorpofannualP(2,i)+PorpofannualP(3,i)+PorpofannualP(4,i))+PorpofannualP(5,i)+PorpofannualP(6,i)+PorpofannualP(7,i)+PorpofannualP(8,i)+PorpofannualP(9,i)+PorpofannualP(10,i)+PorpofannualP(11,i)+PorpofannualP(12,i)];
end
 names = {'Oct'; 'Nov'; 'Dec'; 'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep'};
 figure
 for i= 1:ncatch
 plot(1:12',annualPper(:,i),'linewidth',3,'Color',ColorSet(i,:));
 hold on
 set(gca,'xtick',[1:12],'xticklabel',names,'fontsize',14);
 ylabel('Fraction of Annual Precipitation','fontsize',14');
 ylim([0 1]);
 xlim([1 12]);
 end
 hlegend=legend(catchnames(:,1),catchnames(:,2),catchnames(:,3),catchnames(:,4),catchnames(:,5),catchnames(:,6),catchnames(:,7),catchnames(:,8),catchnames(:,9),...
    catchnames(:,10),catchnames(:,11),catchnames(:,12),'location','northwest');
hlegend.NumColumns=2
% Pfraction=[fPPMean;(wPPMean);(sPPMean);(suPPMean)]


%% Data Tables for Stats outputs
%CV = nanstd(x)/nanmean(x)
MeanP=nanmean(allprecip);
CVP=nanstd(allprecip)./nanmean(allprecip);
MeanT=nanmean(alltemp);
CVT=nanstd(alltemp)./nanmean(alltemp);
MeanB=nanmean(allbaseflow);
CVB=nanstd(allbaseflow)./nanmean(allbaseflow);
MeanQ=nanmean(allstreamflow);
CVQ=nanstd(allstreamflow)./nanmean(allstreamflow);
PTQB=[MeanP',CVP',MeanT',CVT',MeanQ',CVQ',MeanB',CVB']
MinP=min(allprecip);
MaxP=max(allprecip);
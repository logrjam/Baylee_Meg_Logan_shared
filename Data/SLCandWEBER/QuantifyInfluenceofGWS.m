    close all
clear all

disp('All Creeks Predict P with bump from baseflow ')
disp('Feb 2020 ')
disp(' Meg Wolf')
disp(' P + change in groundwter storage to predict dischrage')

load('allprecip.mat')
load('allbaseflow.mat')
load('allmeltrate.mat')
load('allmeltduration.mat')
load('allstreamflow.mat')
load('allyield.mat')
load('alltemp.mat')
load('allJanP.mat')
load('allJanT.mat')

load('PredictedStorage.mat') %%=PS

AnnualPS=PS*365;

%load('meltRate.mat') %melt rate Spring of one year before
catchnames = [string('SLC CC'),string('SLC RB'),string('SLC EC'),string('SLC PC')...
    string('SLC MC'),string('SLC BC'),string('SLC LC'),string('WR ECJ'), string('WR CC'),...
    string('WR LC'),string('WR OSF'),string('WR WO')];
ncatch=12;
nyears=1:118;
x1=ones(118,1);
%nCreeks = width(JanQO)-1; % Create width of 7 creeks -1 for the year column
%statsoutput = [];

% Create X variable with variable from Previous Year, 2 years prior, 3 years
% prior...

%% Predict Q With Just  P
    
h=zeros(1,12);

figure;
for i=1:ncatch
    hold on
         plot(allprecip(:,i),allstreamflow(:,i),'*','MarkerSize',8)
   
%lsline
    
title('Annual Precipitation vs Annual Streamflow','FontSize',20)
xlabel('Annual Precipitation (mm)','FontSize',20)
ylabel('Annual Streamflow (mm)','FontSize',20)

ylim([0 1800])
xlim([0 1800])
%regress all creeks PvQ
set(gca, 'fontsize',20)
[BetaPvQ(:,i),~,~,~,statsPvQ(:,i)]=regress(allstreamflow(:,i),[allprecip(:,i),x1]); %regress all creeks SLC and WRW with streamflow vs P
NewPredictedQWithP(:,i)=(((BetaPvQ(1,i)).*allprecip(:,i))+(BetaPvQ(2,i)))

end
legend(['SLCC R^2:',sprintf('%.2f',statsPvQ(1,1))],...
     ['SLRB R^2:',sprintf('%.2f',statsPvQ(1,2))],...
     ['SLEC R^2:',sprintf('%.2f',statsPvQ(1,3))],...
     ['SLPC R^2:',sprintf('%.2f',statsPvQ(1,4))],...
     ['SLMC R^2:',sprintf('%.2f',statsPvQ(1,5))],...
     ['SLBC R^2:',sprintf('%.2f',statsPvQ(1,6))],...
     ['SLLC R^2:',sprintf('%.2f',statsPvQ(1,7))],...
     ['WRECJ R^2:',sprintf('%.2f',statsPvQ(1,8))],...
     ['WRCC R^2:',sprintf('%.2f',statsPvQ(1,9))],...
     ['WRLC R^2:',sprintf('%.2f',statsPvQ(1,10))],...
     ['WROSF R^2:',sprintf('%.2f',statsPvQ(1,11))],...
    ['WRWO R^2:',sprintf('%.2f',statsPvQ(1,12))],'location','northeastoutside')
lsline


%%
%% Predicted sotrage only has 11 vas since ECJ is removed

% for i= 1:1
% Y(:,i)=(BetaPvQ(1,i).*(allprecip(:,i)+(BetaPvQ(2,i)+AnnualPS(:,i))))
% end
% %%
% figure;
% for i=1:1
%     hold on
%          plot(allprecip(:,i),allstreamflow(:,i),'*','MarkerSize',8)
%    hold on
%    plot(allprecip(:,i),Y(:,i),'o')
% %lsline
%     
% title('Annual Precipitation vs Annual Streamflow','FontSize',20)
% xlabel('Annual Precipitation (mm)','FontSize',20)
% ylabel('Annual Streamflow (mm)','FontSize',20)
% 
% ylim([0 1800])
% xlim([0 1800])
% %regress all creeks PvQ
% set(gca, 'fontsize',20)
% 
% end

%% Predict Streamflow MLR with P and baseflow
%%

for i= 1:ncatch

%regress all creeks SLC and WRW with streamflow vs annual P, baseflow,
[BetaMLRB(:,i),~,~,~,statsMLRB(:,i)]=regress((allstreamflow(:,i)),[allprecip(:,i),allbaseflow(:,i),x1]); %regress all creeks SLC and WRW with streamflow vs annual P, baseflow, meltrate and melt duration
%Row 1 in Beta is Annualp
%Row 2 in Beta is Baseflow
NewPredictedStreamflowWithBase(:,i)=(((BetaMLRB(1,i)).*allprecip(:,i))+(BetaMLRB(2,i).*allbaseflow(:,i))+(BetaMLRB(3,i)))

end
%%
%% Predict Streamflow MLR with P and predicted baseflow
%%
Z=nan(118,1)
PS=[PS(:,1:7),Z,PS(:,8:11)]
for i= 1:ncatch

%regress all creeks SLC and WRW with streamflow vs annual P, Predicted baseflow, 

[BetaMLRPB(:,i),~,~,~,statsMLRPB(:,i)]=regress((allstreamflow(:,i)),[allprecip(:,i),PS(:,i),x1]); %regress all creeks SLC and WRW with streamflow vs annual P, baseflow, meltrate and melt duration
%Row 1 in Beta is Annualp
%Row 2 in Beta is Baseflow
NewPredictedStreamflowWithPredictedBase(:,i)=(((BetaMLRPB(1,i)).*allprecip(:,i))+(BetaMLRPB(2,i).*PS(:,i))+(BetaMLRPB(3,i)))

end
%%
figure;
for i=1:1
    hold on
         plot(NewPredictedQWithP(:,i),allstreamflow(:,i),'.','MarkerSize',20)
   hold on
   plot(NewPredictedStreamflowWithBase(:,i),allstreamflow(:,i),'.','MarkerSize',20)
   hold on
    plot(NewPredictedStreamflowWithPredictedBase(:,i),allstreamflow(:,i),'.','MarkerSize',20)
%lsline
    
title('Predicted vs Observed Discharge','FontSize',20)
xlabel('Predicted Q(mm)','FontSize',20)
ylabel('Observed Q(mm)','FontSize',20)

ylim([0 1000])
xlim([0 1000])
%regress all creeks PvQ
set(gca, 'fontsize',20)
legend(['Predicted Q using just precip SLCC R^2:',sprintf('%.2f',statsPvQ(1,1))],...
     ['Predicted Q using P+Change in GWS SLCC R^2:',sprintf('%.2f',statsMLRB(1,1))],...
     ['Predicted Q using P+ Predicted Change in GWS SLCC R^2:',sprintf('%.2f',statsMLRPB(1,1))],'location','northeast')
 
end
%%
% if CC got 100mm of precip how much Q do we get
Y(1,1)=(BetaPvQ(1,1).*(1000+(BetaPvQ(2,1))))
Y(2,1)=(BetaMLRB(1,1).*(1000)+BetaMLRB(2,1).*(PS(23,1))+(BetaMLRB(3,1)))
Y(3,1)=(BetaMLRPB(1,1).*(1000)+BetaMLRPB(2,1).*(PS(23,1))+(BetaMLRPB(3,1)))
%(((BetaMLRPB(1,i)).*allprecip(:,i))+(BetaMLRPB(2,i).*PS(:,i))+(BetaMLRPB(3,i)))
clear all, close all, clc
set(0,'DefaultTextFontSize',22)
set(0,'DefaultLineLineWidth',2);
set(0,'DefaultTextInterpreter','latex')
set(0,'DefaultAxesFontSize',16)

%% scenario settings
parameters.xmin = -1.5; parameters.ymin = -1.5;
parameters.xmax =  7; parameters.ymax =  4;
parameters.samplingTime = 5; %s

parameters.numberOfAP = 6;
parameters.mainSTA = 2;
parameters.sigmaQ = .1; % m
parameters.sigmaTDOA = .7; %m

%% EXTRACT DATA
load('Project_data.mat');

AP =  AP(:,1:2);% ignore z direction

for tag=1:4
    meassurements = rho{tag}'; % measurements of tag x
    
    %% DATA PREP
    % to eliminiate invalid values, outliers and visualize the data

    figure(tag); hold on
    for i=1:parameters.numberOfAP-1
        % to eliminate Nan values
        meassurements(:,i) = interpolateNaN(meassurements(:,i));
        % to smooth the curves
        meassurements(:,i) = ignoreOutliers(meassurements(:,i));
        plot(meassurements(:,i));
        [t,s] = title(sprintf('TDOA meassurements of tag %d',tag));
        t.FontSize = 16;
    end
    rho{tag} = -meassurements; % di-dj instead of dj-di 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tracking by EKF

R = buildCovarianceMatrix( parameters );

% MODELS and EFK

%% MODEL 1 NCP
MODEL = 'NCP';
figure(11)
for tag=1:4
    rho_tag = rho{tag};
    parameters.simulationTime = length(rho_tag); %s
    [F,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCP(parameters);
    [xhat_NCP] =EKF(parameters,F,Q,UE_init,UE_init_COV,x_hat,P_hat,R,rho_tag,AP,MODEL);
    % display
    plotTrayectory(parameters, AP, xhat_NCP)
end

%% MODEL 2 NCV
MODEL = 'NCV';
figure(12)
for tag=1:4
    rho_tag = rho{tag};
    parameters.simulationTime = length(rho_tag); %s
    [F,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCV(parameters);
    [xhat_NCV] =EKF(parameters,F,Q,UE_init,UE_init_COV,x_hat,P_hat,R,rho_tag,AP,MODEL);
    % display
    plotTrayectory(parameters, AP, xhat_NCV)
end

%% PLOT ALL TRAYECTORies
figure(13),hold on
plotTrayectory(parameters, AP, xhat_NCP)
plotTrayectory(parameters, AP, xhat_NCV)




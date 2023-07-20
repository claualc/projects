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
parameters.sigmaTDOA = 0.5; %m
parameters.sigma_driving = 0.5; % m/s^2

%% Load and Analyzing Data
load('Project_data.mat');

AP =  AP(:,1:2);% ignore z direction

f = figure(1);
line = 0;
for tag = 1:4
    meassurements = rho{tag}'; % measurements of tag x

    % Data Preparation: eliminate invalid values, outliers, and visualize the data
    subplot(4, 2, tag+line);
    hold on;
    for i = 1:parameters.numberOfAP - 1
        plot(meassurements(:, i),'DisplayName', sprintf('Before measurements of tag %d', tag));
    end
    xlabel('Time');
    ylabel('TDOA');
    hold off;
    subplot(4, 2, tag+line+1);
    hold on;
    for i = 1:parameters.numberOfAP - 1
        % Eliminate NaN values
        meassurements(:, i) = interpolateNaN(meassurements(:, i));
        % Smooth the curves
        meassurements(:, i) = ignoreOutliers(meassurements(:, i));
        plot(meassurements(:, i),'DisplayName', sprintf('After Tag %d', tag));
    end
    xlabel('Time');
    ylabel('TDOA');
    hold off;
    line = line +1;

    rho{tag} = -meassurements; 
end
sgtitle('TDOA Measurements of Different Tags Before and After Data Prep');


%% MODEL 1 NCP: EFK 
%{ 
    EFK is due to not linear meassurements and gaussian noise
%}
MODEL = 'NCV';
parameters.sigma_driving = 0.00001; % m/s^2
parameters.sigmaQ = 0.5; % m

NCP_paths_EKF = {}; % final coordenates of the EFK algo
tags = [1,2,3,4]; % each tag represents one of the motion sensors
figsid = 10; % figure parameters

% Compute the path obtained by EFK and Kf for each one of the tags

for id=1:length(tags)
    tag = tags(id);
    rho_tag = rho{tag};
    parameters.simulationTime = length(rho_tag); %s

    %%% EFK
    [F,R,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCP(parameters);
    if MODEL == 'NCV'
        [F,R,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCV(parameters);
    end
    [xhat_NCP_EKF] =EKF(parameters,F,R,Q,UE_init,UE_init_COV,x_hat,P_hat,rho_tag,AP,MODEL,tag, true);
    NCP_paths_EKF{tag}=xhat_NCP_EKF;
end
tittle = sprintf("Path estimated %s-EFK", MODEL);
plotTrayectories(parameters,AP,tags,NCP_paths_EKF, tittle);

%{ 
    For a specific tag compare how the the path calculated changes
    chaning the simulations parameters such as the variance Q of the
    covariance matrix
%} 

%{ 
    how the covariance matrix changes the meassurements prior
%}

tag=2;
% can represent the Q values or the sigma drving values dependening on the
% model being computed


Q_values = [1,0.5, 0.001, 0.00001]; %m (for the NCP)
if MODEL == 'NCV'
    % actually, sigmanDriving values
    Q_values = [0.001,0.00000001,0.0000000000001,0.00000000000000001]; %m
end


rho_tag = rho{tag};
parameters.simulationTime = length(rho_tag); %s
for sigId =1:length(Q_values)

    parameters.sigmaQ = Q_values(sigId);
    [F,R,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCP(parameters);

    if MODEL == 'NCV'
        [F,R,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCV(parameters);
        parameters.sigma_driving = Q_values(sigId);
    end

    [xhat_NCP] = EKF(parameters, F,R, Q, UE_init, UE_init_COV, x_hat, P_hat, rho_tag, AP, MODEL,tag,false);
    path_of_sigma{sigId} = xhat_NCP;
end

tittle = 'Q Variations NCP - EKF';
if MODEL == 'NCV'
        tittle = 'SigmaDriving Variations NCV - EKF';
end
plotSigmaTests(parameters, Q_values, path_of_sigma,xhat_NCP,AP, tittle,MODEL);
hold off;




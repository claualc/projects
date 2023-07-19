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
parameters.sigmaQ = 1; % m
parameters.sigmaTDOA = .5; %m
parameters.sigma_driving = 0.1; % m/s^2

%% EXTRACT and PROCESS DATA
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


%% MODEL 1 NCP: EFK and KF
MODEL = 'NCP';

NCP_paths_EKF = {}; % final coordenates of the EFK algo
NCP_paths_KF = {};  % final coordenates of the KF algo
tags = [2,3,4]; % each tag represents one of the sensors of motion

% figure parameters
figsid = 10;
subTitle= sprintf("sigmaTDOA=%.1f sigmaQ=%.1f", parameters.sigmaTDOA,parameters.sigmaQ);

% Compute the path obtained by EFK and Kf for each one of the tags
for id=1:length(tags)
    tag = tags(id);
    rho_tag = rho{tag};
    parameters.simulationTime = length(rho_tag); %s

    %%% EFK
    [F,R,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCP(parameters);
    [xhat_NCP_EKF] =EKF(parameters,F,R,Q,UE_init,UE_init_COV,x_hat,P_hat,rho_tag,AP,MODEL);
    NCP_paths_EKF{tag}=xhat_NCP_EKF;

    %%% KF
    [xhat_NCP_KF] =KF(parameters,F,R,Q,UE_init,UE_init_COV,x_hat,P_hat,rho_tag,AP,MODEL);
    NCP_paths_KF{tag}=xhat_NCP_KF;

    
    %{ 
        For a specific tag compare how the the path calculated changes
        chaning the simulations parameters such as the variance Q of the
        covariance matrix
    %} 
    if tag==2
        sigma_values = [.5,2,4];
        path_of_sigma = {};
        TYPE = "TDOA";
        for sigId =1:length(sigma_values)
            % testing different values for sigmaTDOA
            parameters.sigmaTDOA = sigma_values(sigId);
            [F,R, Q, UE_init, UE_init_COV, x_hat, P_hat] = NCP(parameters);
            [xhat_NCP] = EKF(parameters, F,R, Q, UE_init, UE_init_COV, x_hat, P_hat, rho_tag, AP, MODEL);
            path_of_sigma{sigId} = xhat_NCP;
        end
        plotSigmaTests(parameters, sigma_values, path_of_sigma, AP, 'SigmaTDOA Variations NCP - EKF', TYPE);
        
        % Evaluate how the Q sigma affects the estimated path
        path_of_sigma = {};
        TYPE = "Q";
        for sigId =1:length(sigma_values)
            % testing different values for sigmaQ
            parameters.sigmaQ = sigma_values(sigId);
            [F,R, Q, UE_init, UE_init_COV, x_hat, P_hat] = NCP(parameters);
            [xhat_NCP] = EKF(parameters, F,R, Q, UE_init, UE_init_COV, x_hat, P_hat, rho_tag, AP, MODEL);
            path_of_sigma{sigId} = xhat_NCP;
        end
        plotSigmaTests(parameters, sigma_values, path_of_sigma, AP, 'SigmaQ Variations NCP - EKF', TYPE);
    end
end

plotTrayectories(parameters,AP,tags,NCP_paths_EKF,"Path estimated NCP-EFK",subTitle);
plotTrayectories(parameters,AP,tags,NCP_paths_KF,"Path estimated NCP-KF",subTitle);

%% MODEL 2 NCV
MODEL = 'NCV';

NCV_paths_EKF = {};
NCV_paths_KF = {};
tags = [2,3,4];
sigmaDrivingValues = [0.001,0.0001,.00001];
parameters.sigmaTDOA = .5; %m
parameters.sigma_driving = 0.0001; % m/s^2
subTitle= sprintf("sigmaTDOA=%.1f sigmaW=%.4f", parameters.sigmaTDOA,parameters.sigma_driving );
for id=1:length(tags)
    tag = tags(id);
    rho_tag = rho{tag};
    parameters.simulationTime = length(rho_tag); %s
    [F,R,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCV(parameters);
    [xhat_NCV_EKF] =EKF(parameters,F,R,Q,UE_init,UE_init_COV,x_hat,P_hat,rho_tag,AP,MODEL);
    NCV_paths_EKF{tag}=xhat_NCV_EKF;

    [xhat_NCV_KF] =KF(parameters,F,R,Q,UE_init,UE_init_COV,x_hat,P_hat,rho_tag,AP,MODEL);
    NCV_paths_KF{tag}=xhat_NCV_KF;
    
    if tag==2
        % Evaluate how the TDOA sigma affects the estimated path
        % % sigma_values = [.5,2,4];
        % % path_of_sigma = {};
        % % TYPE = "TDOA";
        % % for sigId =1:length(sigma_values)
        % %     % testing different values for sigmaTDOA
        % %     parameters.sigmaTDOA = sigma_values(sigId);
        % %     [F,R, Q, UE_init, UE_init_COV, x_hat, P_hat] = NCV(parameters);
        % %     [xhat_NCV] = EKF(parameters, F,R, Q, UE_init, UE_init_COV, x_hat, P_hat, rho_tag, AP, MODEL);
        % %     path_of_sigma{sigId} = xhat_NCV;
        % % end
        % % plotSigmaTests(parameters, sigma_values, path_of_sigma, AP, 'SigmaTDOA Variations NCV - EKF', TYPE);
        
        % Evaluate how the sigma_driving affects the estimated path
        path_of_sigma = {};
        TYPE = "sigmaDriving";
        for sigId =1:length(sigmaDrivingValues)
            % testing different values for sigmaQ
            parameters.sigma_driving = sigmaDrivingValues(sigId);
            [F,R, Q, UE_init, UE_init_COV, x_hat, P_hat] = NCV(parameters);
            [xhat_NCV] = EKF(parameters, F,R, Q, UE_init, UE_init_COV, x_hat, P_hat, rho_tag, AP, MODEL);
            path_of_sigma{sigId} = xhat_NCV;
        end
        plotSigmaTests(parameters, sigmaDrivingValues, path_of_sigma, AP, 'SigmaQ Variations NCV - EKF', TYPE);
    end
end

plotTrayectories(parameters,AP,tags,NCV_paths_EKF,"Path estimated NCV-EFK",subTitle);
plotTrayectories(parameters,AP,tags,NCV_paths_KF,"Path estimated NCV-FK",subTitle);

% figure(4)
% for tag=1:4
%     rho_tag = rho{tag};
%     parameters.simulationTime = length(rho_tag); %s
%     [F,R,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCV(parameters);
%     [xhat_NCV] =EKF(parameters,F,R,Q,UE_init,UE_init_COV,x_hat,P_hat,rho_tag,AP,MODEL);
%     % display
%     plotTrayectory(parameters, AP, xhat_NCV)
% end

%% PLOT ALL TRAYECTORies
% figure(13),hold on
% plotTrayectory(parameters, AP, xhat_NCP)
% plotTrayectory(parameters, AP, xhat_NCV)




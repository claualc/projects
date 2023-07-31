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

%% Load and Analyzing Data
load('Project_data.mat');

AP =  AP(:,1:2);% ignore z direction

f = figure(1);
xlim([0 600]);
ylim([-4 4]);
line = 0;
for tag = 1:4
    meassurements = rho{tag}'; % measurements of tag x

    % Data Preparation: eliminate invalid values, outliers, and visualize the data
    subplot(4, 2, tag+line);
    hold on;
    for i = 1:parameters.numberOfAP - 1
        p1=plot(meassurements(:, i),'DisplayName', sprintf('ap %d', i));
        ylabel(sprintf('Tag %d dist [m]', tag));
        if tag < 4
            if tag == 1
                title('Before')
            end
            if tag == 4
                title('After')
            end
            set(gca,'XTick',[])
        else
            xlabel("[s]")
        end
        
    end
    hold off;

    subplot(4, 2, tag+line+1);
    hold on;
    for i = 1:parameters.numberOfAP - 1
        % Eliminate NaN values
        meassurements(:, i) = interpolateNaN(meassurements(:, i));
        % Smooth the curves
        meassurements(:, i) = ignoreOutliers(meassurements(:, i),tag);
        p2 = plot(meassurements(:, i),'DisplayName', sprintf('ap %d', i));
        if tag == 2 || tag ==3
            set(gca,'XTick',[])
        else
            xlabel("[s]")
        end
    end

    hold off;
    line = line +1;

    rho{tag} = -meassurements; 
end
sgtitle('TDOA Measurements Before and After Data Prep');


%% MODEL 1 NCP: EFK 
%{ 
    EFK is due to not linear meassurements and gaussian noise
%}
MODEL = 'NCV';
parameters.sigma_driving = 1e-6; % m/s^2
parameters.sigmaQ = 0.001; % m

xhat_EKF = {}; % final coordenates of the EFK algo
tags = [1,2,3,4]; % each tag represents one of the motion sensors
figsid = 10; % figure parameters

 % figure to plot the NCV velocity
if MODEL == 'NCV'
    figure(1000); %x axis
    figure(1001); %x axis
    hold on;
    box on;
end

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
    [xhat_EKF] =EKF(parameters,F,R,Q,UE_init,UE_init_COV,x_hat,P_hat,rho_tag,AP,MODEL,tag, true);
    paths_EKF{tag}=xhat_EKF;

    if MODEL == 'NCV'
        figure(1000);
        hold on;
        box on;
        name = sprintf("tag %d", tag);
        plot(xhat_EKF(:,3), "DisplayName",name);
        xlim([0 610]);
        ylim([-0.1 0.4]);
        ylabel('[m/s]'), xlabel('[s]');
        subTitle= sprintf("sigmaTDOA=%.1f sigmaDriv=%.1e", parameters.sigmaTDOA,parameters.sigma_driving);
        title("Velocity X axis (NCV)",subTitle);
        legend('show');

        figure(1001);
        plot(xhat_EKF(:,4), "DisplayName",name);
        xlim([0 610]);
        ylim([-0.1 0.1]);
        ylabel('[m/s]'), xlabel('[s]');
        hold on;
        box on;
        subTitle= sprintf("sigmaTDOA=%.1f sigmaDriv=%.1e", parameters.sigmaTDOA,parameters.sigma_driving);
        title("Velocity Y axis (NCV)",subTitle);
        legend('show');
    end
end

tittle = sprintf("Path estimated %s-EFK", MODEL);
plotTrayectories(parameters,AP,tags,paths_EKF, tittle,MODEL);

%{ 
    For a specific tag compare how the the path calculated changes
    changing the values of the covariance matrix
%} 

Q_values = [1, 0.001,0.0003, 0.00001]; %m (for the NCP)
if MODEL == 'NCV'
    Q_values = [1e-3,1e-6,1e-9,1e-12]; %m/s^2
end

tag=2;
rho_tag = rho{tag};
parameters.simulationTime = length(rho_tag); %s
for sigId =1:length(Q_values)

    parameters.sigmaQ = Q_values(sigId);
    [F,R,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCP(parameters);

    if MODEL == 'NCV'
        parameters.sigma_driving = Q_values(sigId);
        [F,R,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCV(parameters);
    end

    [xhat] = EKF(parameters, F,R, Q, UE_init, UE_init_COV, x_hat, P_hat, rho_tag, AP, MODEL,tag,false);
    path_of_sigma{sigId} = xhat;
end

tittle = 'Q Variations NCP - EKF';
if MODEL == 'NCV'
        tittle = 'SigmaDriving Variations NCV - EKF';
end
plotSigmaTests(parameters, Q_values, path_of_sigma,xhat,AP, tittle,MODEL);
hold off;




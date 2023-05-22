clear all, close all, clc
set(0,'DefaultTextFontSize',22)
set(0,'DefaultLineLineWidth',2);
set(0,'DefaultTextInterpreter','latex')
set(0,'DefaultAxesFontSize',16)


%% generate measurements
rng(1)
parameters.sigmaTDOA = 3;

load('Project_data.mat');
% ignore z direction
AP =  AP(:,1:2);
meassurements_x = cell2mat(rho(2))'; % pick first experiment
meassurements_y = cell2mat(rho(3))';
meassurements_z = cell2mat(rho(4))';

%% scenario settings
parameters.xmin = -1.5; parameters.ymin = -1.5;
parameters.xmax =  7; parameters.ymax =  4;
parameters.simulationTime = 655; %s
parameters.samplingTime = 2; %s
parameters.sigmaTDOA = 1; %m
parameters.numberOfAP = 6;
parameters.mainSTA = 2;


T   = parameters.simulationTime; %s
NA  = parameters.numberOfAP;
sigma = parameters.sigmaTDOA;


for i=1:parameters.numberOfAP-1
    % to eliminate Nan values
    meassurements_x(:,i) = interpolateNaN(meassurements_x(:,i));
    meassurements_y(:,i) = interpolateNaN(meassurements_y(:,i));
    meassurements_z(:,i) = interpolateNaN(meassurements_z(:,i));

    % to smooth the curves
    meassurements_x(:,i) = ignoreOutliers(meassurements_x(:,i));
    meassurements_y(:,i) = ignoreOutliers(meassurements_y(:,i));
    meassurements_z(:,i) = ignoreOutliers(meassurements_z(:,i));
end

rho = -meassurements_x;


%% Tracking by EKF
%initialization
UE_init = [0.1,0.1];
UE_init_COV = diag([100^2,100^2]); %must be as large as possible to for not bias the model

%motion model
x_hat = NaN( parameters.simulationTime , 2);
P_hat = NaN( 2 , 2 , parameters.simulationTime );
Q = diag([ .1 , .1]); % m

%prediction model
F = [1 , 0 ; 0  1];
R = Copy_of_buildCovarianceMatrix( parameters );

%update over time
for time = 1:T
    %prediction
    if time == 1
        x_pred =  UE_init';
        P_pred = UE_init_COV;
    else
        x_pred = F * x_hat(time-1,:)';
        P_pred = F * P_hat(:,:,time-1) *F' + Q;
    end
    H = Copy_of_buildJacobianMatrixH(parameters,x_pred',AP);

    %update
    G = P_pred * H' * inv( H*P_pred*H' + R);
    x_hat(time,:) = x_pred + G*(rho(time,:)' - Copy_of_measurementModel( parameters , x_pred' , AP )' );
    P_hat(:,:,time) = P_pred - G * H * P_pred;
end

% plot estimated trajectory
figure,hold on
plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor','red','MarkerFaceColor',[1 .6 .6]), hold on
plot( x_hat(:,1) , x_hat(:,2) , '-o','Color','b','MarkerIndices',1:20:T)
legend('UE true','KF est.')
xlabel('[m]'), ylabel('[m]');
xlim([parameters.xmin parameters.xmax])
ylim([parameters.ymin parameters.ymax])
axis equal
grid on


% distance error
% % DeltaPosition_KF = UE(:,1:2) - x_hat(:,1:2);
% % err_EKF = sqrt( sum ( DeltaPosition_KF.^2,2 ) );
% % 
% % figure
% % plot( parameters.samplingTime:parameters.samplingTime:parameters.samplingTime*parameters.simulationTime , err_EKF ), hold on
% % xlabel('time [s]'), ylabel('m'), title('Position error')
% % 



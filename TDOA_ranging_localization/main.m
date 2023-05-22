clear all, clc, close all
set(0,'DefaultTextFontSize',22)
set(0,'DefaultLineLineWidth',2);
set(0,'DefaultTextInterpreter','latex')
set(0,'DefaultAxesFontSize',16)

% defines AP and rho
load('Project_data.mat');
% ignore z direction
AP =  AP(:,1:2);
meassurements_x = cell2mat(rho(2))'; % pick first experiment
meassurements_y = cell2mat(rho(3))';
meassurements_z = cell2mat(rho(4))';

%% scenario settings
parameters.xmin = -7; parameters.ymin = -7;
parameters.xmax =  7; parameters.ymax =  7;
parameters.simulationTime = 655; %s
parameters.samplingTime = 2; %s
parameters.sigmaTDOA = 1; %m
parameters.numberOfAP = 6;
parameters.mainSTA = 2;

% figure(9); hold on
% legends = [];
% for i=1:parameters.numberOfAP-1
%     plot(meassurements_x(:,i));
%     legends = [legends;"AP "+num2str(i)]
% end
% xlabel('[m]'), ylabel('[m]');
% legend(legends)
% box on

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



% figure(1); hold on
% for i=1:parameters.numberOfAP-1
%     plot(meassurements_x(:,i));
% end
% box on
% % 
% % figure(2); hold on
% for i=1:parameters.numberOfAP-1
%     plot(meassurements_y(:,i));
% end
% box on
% 
% figure(3); hold on
% for i=1:parameters.numberOfAP-1
%     plot(meassurements_z(:,i));
% end
% box on


% DISPLAY AP POSITIONS
% figure(11); hold on
% plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor',[147,0,0]./255,'MarkerFaceColor',[147,0,0]./255)
% xlabel('[m]'), ylabel('[m]');
% legend('AP')
% box on
% axis equal

%% x = [ux uy]
%% model: static position

%%% STATIC MODEL
% initialization
UE_init = [0.1,0.1];
UE_init_COV = diag([100^2,100^2]); % as large as possible
x_hat = NaN( parameters.simulationTime , 2);
P_hat = NaN( 2 , 2 , parameters.simulationTime );

% figure(11); hold on
% title('Time: ' , num2str(0) )
% plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor',[0.64,0.08,0.18],'MarkerFaceColor',[0.64,0.08,0.18] ), hold on
% plot( UE_init(1) , UE_init(2) , 'x','MarkerSize',10 )
% plotCovariance( UE_init_COV , UE_init(1,1) , UE_init(1,2)  , 3 ,'Initialization');
% xticks( [parameters.xmin:20:parameters.xmax] )  , yticks( [parameters.xmin:20:parameters.xmax] )
% xlim( [parameters.xmin-15 parameters.xmax+15] ) , ylim( [parameters.ymin-15 parameters.ymax+15] )
% xlabel('meter','FontSize',26) , ylabel('meter','FontSize',26)
% axis equal
% box on
% legend('AP','True UE','UE est = init.','Cov. prior')

%%% FIFLTERS
% motion model

R = diag( repmat( parameters.sigmaTDOA.^2 , 1 , parameters.numberOfAP -1) );
% meassurements model
Q = diag([ 1, 1]); % m
F = [1  0 ; 0  1];

% EKM
for time = 1 :1 %parameters.simulationTime

    %prediction
    if time == 1
        x_pred =  UE_init';
        P_pred = UE_init_COV;
    else
        x_pred = F * x_hat(time-1,:)';
        P_pred = F * P_hat(:,:,time-1) *F' + Q;
    end
    H = buildJacobianMatrixH(parameters,x_pred',AP);
    
    %update
    G = P_pred * H' * inv( H*P_pred*H' + R);
    x_hat(time,:) = x_pred + G * (meassurements_x( time , : )'  -  measurementModel( parameters , x_pred',AP) );
    P_hat(:,:,time) = P_pred - G * H * P_pred;

    x = linspace( parameters.xmin , parameters.xmax , 100);
    y = linspace( parameters.ymin , parameters.ymax , 100);
    likelihood = zeros(parameters.numberOfAP , length(x) , length(y) );
    
    rho_line = meassurements_x( time , : );
    rho_line= [ rho_line(1), 0,  rho_line(2:5)] ;
    for a = 1:parameters.numberOfAP
         if a~=parameters.mainSTA
              rhoo = rho_line(a)
         end
        for i = 1:1:length(x)
            for j = 1:1:length(y)
                if a~=parameters.mainSTA
                    likelihood(a,i,j) = evaluateLikelihoodTDOA ( parameters , rhoo , AP(parameters.mainSTA,:) , AP(a,:) , [x(i) , y(j)]);
                end
            end %j
        end %i
    end %a
    %plot2Dlikelihood( parameters, AP , x_hat(time,:) , x , y , likelihood );
    
    maximumLikelihood = ones(length(x),length(y));
    for a=1:parameters.numberOfAP
        if a~= 2
            maximumLikelihood = maximumLikelihood .* squeeze(likelihood(a,:,:));
        end
    end
    TYPE='TDOA';
    plotMaximumlikelihood( parameters, AP , x_hat(time,:) , x , y , maximumLikelihood , TYPE);

    
    %plot evolution
    figure(11);
    plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor',[0.64,0.08,0.18],'MarkerFaceColor',[0.64,0.08,0.18] ), hold on
    plotCovariance( P_pred  , x_pred(1) , x_pred(2)  , 3 , 'Prior');
    axis equal
    xticks( [parameters.xmin:20:parameters.xmax] )  , yticks( [parameters.xmin:20:parameters.xmax] )
    xlim( [parameters.xmin parameters.xmax] ) , ylim( [parameters.ymin parameters.ymax] )
    xlabel('meter','FontSize',26) , ylabel('meter','FontSize',26)
    legend('AP','True UE (all)','True UE (current)','Cov. pred.')
    title('Time: ' , num2str(time) )
    pause(1)
    plot( x_hat(:,1) , x_hat(:,2) , '-g','Marker','s')
    plotCovariance( P_hat(:,:,time)  , x_hat(time,1) , x_hat(time,2)  , 3 , 'Update');
    legend('AP','True UE (all)','True UE (current)','Cov. pred.','KF est.','Cov. upd.')
    box on
    hold off
end

% plot estimated trajectory
% figure,hold on
% plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor',[0.64,0.08,0.18],'MarkerFaceColor',[0.64,0.08,0.18] ), hold on
% plot( x_hat(:,1) , x_hat(:,2) , '-g','Marker','s')
% legend('UE true','KF est.')
% xlabel('[m]'), ylabel('[m]');
% xlim([parameters.xmin parameters.xmax])
% ylim([parameters.ymin parameters.ymax])
% axis equal
% grid on

%   
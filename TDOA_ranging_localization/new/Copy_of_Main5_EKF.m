clear all, close all, clc
set(0,'DefaultTextFontSize',22)
set(0,'DefaultLineLineWidth',2);
set(0,'DefaultTextInterpreter','latex')
set(0,'DefaultAxesFontSize',16)


%% scenario settings
parameters.xmin = -50; parameters.ymin = -50;
parameters.xmax =  100; parameters.ymax =  100;

%% position of the Access Points
parameters.numberOfAP = 4;
AP(1,1) = -50 ; AP(1,2) = -50;
AP(2,1) = 50 ;  AP(2,2) = -50;
AP(3,1) = 50 ;  AP(3,2) = 100;
AP(4,1) = -50 ; AP(4,2) = 100;

%% parameters
parameters.simulationTime = 20; %s
parameters.samplingTime = 2; %s
parameters.mainSTA = 2;

%% generate UE trajectory
[ UE ] = generateUEtrajectory_ZigZag(parameters); % moving
%[ UE ] = generateUEtrajectory_Static(parameters); % stationary

 
% % figure(); hold on
% % plot( UE(:,1) , UE(:,2) , 'o','MarkerSize',10,'MarkerEdgeColor',[0.30,0.75,0.93],'MarkerFaceColor',[0.30,0.75,0.93] )
% % plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor',[0.64,0.08,0.18],'MarkerFaceColor',[0.64,0.08,0.18] )
% % legend('UE','AP')
% % for time = 1:parameters.simulationTime
% %    text(UE(time,1)+1,UE(time,2),sprintf('Time %d ', time), 'fontsize',12)
% % end
% % xlabel('[m]'), ylabel('[m]');
% % xlim([parameters.xmin parameters.xmax])
% % ylim([parameters.ymin parameters.ymax])
% % axis equal
% % grid on
% % box on

% in the past lab the meassurements were created adding a gaussian noise
% to the actual position. In this case, they are not gaussian (ideal)
% the measurements are created from an ideal ranging method
%% generate measurements
rng(1)
TYPE = 'TDOA';
parameters.sigmaTDOA = 3;


T   = parameters.simulationTime; %s
NA  = parameters.numberOfAP;
sigma = parameters.sigmaTDOA;
rho = [];

for time=1:parameters.simulationTime
    rho_line = [];
    for a=1:parameters.numberOfAP
        if a ~= parameters.mainSTA
            diff=sqrt(sum([UE(time,:)-AP(a,:)].^2,2))'- sqrt(sum([UE(time,:)-AP(parameters.mainSTA,:)].^2,2))' + sigma.*randn(1);
            rho_line = [rho_line,diff]; 
        end
    end
    rho = [rho;rho_line];
end


R = Copy_of_buildCovarianceMatrix( parameters );


%% Tracking by EKF

%initialization
UE_init = [0,0];
UE_init_COV = diag([100^2,100^2]); %must be as large as possible to for not bias the model
x_hat = NaN( parameters.simulationTime , 2);
P_hat = NaN( 2 , 2 , parameters.simulationTime );

% % figure(11); hold on
% % title('Time: ' , num2str(0) )
% % plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor',[0.64,0.08,0.18],'MarkerFaceColor',[0.64,0.08,0.18] ), hold on
% % plot( UE(:,1) , UE(:,2) , 'o','MarkerSize',10,'MarkerEdgeColor',[0.30,0.75,0.93],'MarkerFaceColor',[0.30,0.75,0.93] )
% % plot( UE_init(1) , UE_init(2) , 'x','MarkerSize',10 )
% % plotCovariance( UE_init_COV , UE_init(1,1) , UE_init(1,2)  , 3 ,'Initialization');
% % xticks( [parameters.xmin:20:parameters.xmax] )  , yticks( [parameters.xmin:20:parameters.xmax] )
% % xlim( [parameters.xmin-15 parameters.xmax+15] ) , ylim( [parameters.ymin-15 parameters.ymax+15] )
% % xlabel('meter','FontSize',26) , ylabel('meter','FontSize',26)
% % axis equal
% % box on
% % legend('AP','True UE','UE est = init.','Cov. prior')

% the motion model: static position
% Q is the covariance of the position/motion model
% uncertainty of 10 meters
Q = diag([ 10 , 10]); % 100, 10, 2, 0.5
F = [1 , 0 ; 0  1];


%update over time
for time = 1 :parameters.simulationTime

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


    %plot evolution
    fh=figure(11);
    fh.WindowState = 'maximized';
    plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor',[0.64,0.08,0.18],'MarkerFaceColor',[0.64,0.08,0.18] ), hold on
    plot( UE(:,1) , UE(:,2) , 'o','MarkerSize',10,'MarkerEdgeColor',[0.30,0.75,0.93],'MarkerFaceColor',[0.30,0.75,0.93] ), hold on
    plot( UE(time,1) , UE(time,2) , 'o','MarkerSize',10,'MarkerEdgeColor',[0.30,0.75,0.93],'MarkerFaceColor',[0.50,0,0] ),
    plotCovariance( P_pred  , x_pred(1) , x_pred(2)  , 3 , 'Prior');
    axis equal
    xticks( [parameters.xmin:20:parameters.xmax] )  , yticks( [parameters.xmin:20:parameters.xmax] )
    xlim( [parameters.xmin-15 parameters.xmax+15] ) , ylim( [parameters.ymin-15 parameters.ymax+15] )
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
% plot( UE(:,1) , UE(:,2) , 'o','MarkerSize',10,'MarkerEdgeColor',[0.30,0.75,0.93],'MarkerFaceColor',[0.30,0.75,0.93] )
% plot( x_hat(:,1) , x_hat(:,2) , '-g','Marker','s')
% legend('UE true','KF est.')
% xlabel('[m]'), ylabel('[m]');
% xlim([parameters.xmin parameters.xmax])
% ylim([parameters.ymin parameters.ymax])
% axis equal
% grid on


% distance error
% % DeltaPosition_KF = UE(:,1:2) - x_hat(:,1:2);
% % err_EKF = sqrt( sum ( DeltaPosition_KF.^2,2 ) );
% % 
% % figure
% % plot( parameters.samplingTime:parameters.samplingTime:parameters.samplingTime*parameters.simulationTime , err_EKF ), hold on
% % xlabel('time [s]'), ylabel('m'), title('Position error')
% % 



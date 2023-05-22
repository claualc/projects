function plotMaximumlikelihood( parameters, AP , UE , x , y , maximumLikelihood , TYPE)



%% plot ML in 2D
fig = figure();
%fig.WindowState = 'maximized';
subplot(1, 3, [1 2])
hold on
imagesc( x , y  ,maximumLikelihood');

plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor',[0.64,0.08,0.18],'MarkerFaceColor',[0.64,0.08,0.18] )
plot( UE(:,1) , UE(:,2) , 'o','MarkerSize',10,'MarkerEdgeColor',[0.30,0.75,0.93],'MarkerFaceColor',[0.30,0.75,0.93] )
colorbar;
xlim([parameters.xmin parameters.xmax]) , ylim([parameters.ymin parameters.ymax])
xlabel('[m]','FontSize',26), ylabel('[m]','FontSize',26);
axis equal
colorbar;
box on
switch TYPE
    case 'TOA'
        title(['Maximum Likelihood ',num2str(TYPE),', $N_{AP}$ = ',num2str(parameters.numberOfAP),' , $\sigma $ = ',num2str(parameters.sigmaTOA),' m '],'Interpreter','Latex')
    case 'RSS'
        title(['Maximum Likelihood ',num2str(TYPE),', $N_{AP}$ = ',num2str(parameters.numberOfAP),' , $\sigma $ = ',num2str(parameters.sigmaRSS),' m '],'Interpreter','Latex')
    case 'AOA'
        title(['Maximum Likelihood ',num2str(TYPE),', $N_{AP}$ = ',num2str(parameters.numberOfAP),' , $\sigma $ = ',num2str(rad2deg(parameters.sigmaAOA)),' deg '],'Interpreter','Latex')
    case 'TDOA'
        title(['Maximum Likelihood ',num2str(TYPE),', ${AP}$ = 1-',num2str(parameters.numberOfAP),' , $\sigma $ = ',num2str(parameters.sigmaTDOA),' m '],'Interpreter','Latex')
end

%% plot ML in 3D
subplot(1,3,3)
surf(  x, y , maximumLikelihood ),hold on
shading flat
colorbar;
xlabel('[m]'), ylabel('[m]');
xlim([parameters.xmin parameters.xmax]) , ylim([parameters.ymin parameters.ymax])

%plot3( AP(:,1) , AP(:,2) ,0.001+zeros(1,size(AP,1)), '^','MarkerSize',10,'MarkerEdgeColor',[0.64,0.08,0.18],'MarkerFaceColor',[0.64,0.08,0.18] )
% plot3( UE(:,1) , UE(:,2) ,0.001, 'o','MarkerSize',10,'MarkerEdgeColor',[0.30,0.75,0.93],'MarkerFaceColor',[0.30,0.75,0.93] )

switch TYPE
    case 'TOA'
        title(['Maximum Likelihood ',num2str(TYPE),', $N_{AP}$ = ',num2str(parameters.numberOfAP),' , $\sigma $ = ',num2str(parameters.sigmaTOA),' m '],'Interpreter','Latex')
    case 'RSS'
        title(['Maximum Likelihood ',num2str(TYPE),', $N_{AP}$ = ',num2str(parameters.numberOfAP),' , $\sigma $ = ',num2str(parameters.sigmaRSS),' m '],'Interpreter','Latex')
    case 'AOA'
        title(['Maximum Likelihood ',num2str(TYPE),', $N_{AP}$ = ',num2str(parameters.numberOfAP),' , $\sigma $ = ',num2str(rad2deg(parameters.sigmaAOA)),' deg '],'Interpreter','Latex')
    case 'TDOA'
        title(['Maximum Likelihood ',num2str(TYPE),', ${AP}$ = 1-',num2str(parameters.numberOfAP),' , $\sigma $ = ',num2str(parameters.sigmaTDOA),' m '],'Interpreter','Latex')
end

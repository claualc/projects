function plot2Dlikelihood(parameters, AP , UE , x , y , likelihood , TYPE)


for a = 1:parameters.numberOfAP
    
    figure();
    imagesc( x , y ,   (   ( squeeze(  likelihood(a,:,:) )' )  ) )   ;  hold on

    set(gca,'YDir','normal')

    plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor',[0.64,0.08,0.18],'MarkerFaceColor',[0.64,0.08,0.18] );    hold on
    plot( AP(a,1) , AP(a,2) , '^','MarkerSize',10,'MarkerEdgeColor',[102,254,0]./255,'MarkerFaceColor',[102,254,0]./255 )
    plot( UE(:,1) , UE(:,2) , 'o','MarkerSize',10,'MarkerEdgeColor',[0.30,0.75,0.93],'MarkerFaceColor',[0.30,0.75,0.93] )


    colorbar;
    axis equal
    xlim([parameters.xmin parameters.xmax]) , ylim([parameters.ymin parameters.ymax])
    xlabel('[m]','FontSize',26)
    ylabel('[m]','FontSize',26);
   

      title(['Likelihood ',', ${AP}$ = 1-',num2str(a),' ,   $\sigma $ = ',num2str(parameters.sigmaTDOA),' dB '],'Interpreter','Latex')

     
end
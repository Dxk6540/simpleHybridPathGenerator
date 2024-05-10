function displaySigmoidParasAlongY(obj,type)
if (type==1) % % % Original data
    figure('Name','Sigmoid paras')
    subplot(2,2,1);
    plot(obj.sigmoidParas(:,end),obj.sigmoidParas(:,1));
    xlabel('y [mm]')
    ylabel('the scaling parameter')
    title('zoom para');
    subplot(2,2,2);
    plot(obj.sigmoidParas(:,end),obj.sigmoidParas(:,2));
    xlabel('y [mm]')
    ylabel('the stretching parameter')
    title('moving para');
    subplot(2,2,3);
    plot(obj.sigmoidParas(:,end),obj.sigmoidParas(:,3));
    xlabel('y [mm]')
    ylabel('the position of symmetry axis')
    title('symmetry para');
    subplot(2,2,4);
    plot(obj.sigmoidParas(:,end),obj.sigmoidParas(:,4));
    xlabel('y [mm]')
    ylabel('the shifting parameter')
    title('height');

elseif (type==2) % % % Smoothed data
    figure('Name','Smoothed sigmoid paras')
    subplot(2,2,1);
    plot(obj.smoothedSigmoidParas(:,end),obj.smoothedSigmoidParas(:,1),'LineWidth',2);
    xlabel('y [mm]')
    ylabel('the scaling parameter')
    title('zoom para');
    subplot(2,2,2);
    plot(obj.smoothedSigmoidParas(:,end),obj.smoothedSigmoidParas(:,2),'LineWidth',2);
    xlabel('y [mm]')
    ylabel('the stretching parameter')
    title('moving para');
    subplot(2,2,3);
    plot(obj.smoothedSigmoidParas(:,end),obj.smoothedSigmoidParas(:,3),'LineWidth',2);
    xlabel('y [mm]')
    ylabel('the position of symmetry axis')
    title('symmetry para');
    subplot(2,2,4);
    plot(obj.smoothedSigmoidParas(:,end),obj.smoothedSigmoidParas(:,4),'LineWidth',2);
    xlabel('y [mm]')
    ylabel('the shifting parameter')
    title('height');
end
end
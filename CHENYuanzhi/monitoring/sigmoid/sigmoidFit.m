function [v] = sigmoidFit(X,Z,show)
%% Sigmoid fit
zoom_par = 10;
moving_par =-1;
symmetry_axis = (min(X)+max(X))/2;
height = max(Z);
v0 = [zoom_par,moving_par,symmetry_axis,height];
% output_z = sigmoid_cal(X,v0,Reference_profile);
% figure('Name','Direct sigmoid fit')
% hold all;
% p1=plot(X,Reference_profile,'r-');
% p2=plot(X,output_z,'b-.');
% legend([p1,p2],'Fitted curve','Extracted profile')
%% optimize the fitting process
move_lim = [10,2,5,0.01];% Variable range
ub = v0 + move_lim;
lb = v0 - move_lim;
Aeq = [];
beq = [];
A = [];
b = [];
v = [];
nonlcon = [];
options = optimoptions('fmincon','Display','none');
v_previous = v0;
%% Fit the sigmoid curve
Reference_profile_local = Z;
if(std(Z(round(length(Z)*0.35):round(length(Z)*0.65)))<0.05) % The precision of the camera is 0.05 mm
    v=[0 0 0 0 0 0];
    return;
end

[v,fval,exitflag,output] = fmincon(@(v)sigmoid_fit(X, v, Reference_profile_local,v_previous),v0,A,b,Aeq,beq,lb,ub,nonlcon,options);%% To output an optimized para: v
%% calculate the result
% error=sigmoid_fit(X, v, Reference_profile_local,v_previous);
% disp(['Standard error is ', num2str(error), ' mm.']);
sigmoid_fit(X, v, Reference_profile_local,v_previous);
local_y = sigmoid_cal(X,v,Reference_profile_local);
% finalize the output parameter
Opt_Z = local_y';
%% Width extraction
XX=min(X):0.001:max(X);
symmetryIndex=find(XX>v(3),1);
X_1 = v(1)*(XX(1:symmetryIndex-1) - v(2)-v(3));
X_2=v(1)*(v(3)-XX(symmetryIndex:end) - v(2));
X_12=[X_1,X_2];
Z_0 = sigmoid_equa(X_12);
Z_1 = Z_0 / max(Z_0) * v(4);
startIdx=find(Z_1>0.01,1);
width=2*(v(3)-XX(startIdx));
if (isempty(width))
    width=-999;
end
area=sum(Z_1*0.001);%% Calsulate the area
% figure('Name','test');
% plot(XX,Z_1,'r','LineWidth',1.2);
v=[v,width,area];
%% Display the sigmoid figure
if(show)
    title=sprintf('Sigmoid curve');
    figure('Name',title);
    p1 = plot(X,Z,'b-.','LineWidth',1.4);
    hold on;
    p2 = plot(X,Opt_Z,'r','LineWidth',1.2);
    if (~isempty(startIdx))
        plot(XX(startIdx),0.01,'*','Color','black','LineWidth',2);
    end
    xlabel('Width [mm]')
    ylabel('Height [mm]')
    legend([p1,p2],'Geometry profile','Fitted curve');
end
end
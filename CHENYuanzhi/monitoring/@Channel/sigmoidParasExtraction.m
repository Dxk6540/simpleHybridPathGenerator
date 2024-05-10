function [sigmoidParas] = sigmoidParasExtraction(obj,Y)
flag_extractMethod=1; %% 1-extract w,h from each cross-sectional plane; 2 - Overlay 5 patterns; 3 - 5 results were weighted
errorNum=0;
%% Find the certain positions' width, height, area.
if isempty(Y)
    Yindices=1:size(obj.mesh_y,1);
else
    Yindices=zeros(length(Y),1);
    for i=1:length(Y)
        Ytemp=abs(obj.mesh_y(:,1)-Y(i));
        Yindices(i)=find(Ytemp==min(Ytemp),1);
    end
end
if flag_extractMethod==1
    for j=1:length(Yindices)
    % % %For test
%     for j=round(linspace(round(size(obj.mesh_y,1))*0.2,round(size(obj.mesh_y,1))*0.8,10))
        %% Realign the Z data
        jj=Yindices(j);
        X=obj.mesh_x(jj,:);
        Z=obj.mesh_smoothedZ(jj,:);
        middleX=mean(X);
        xIndices=((X>(min(X)+(max(X)-min(X))*0.1))+(X<(middleX-2))+(X>(middleX+2))+(X<(max(X)-(max(X)-min(X))*0.1)))>2;
%         xIndices=((X<(middleX-2))+(X>(middleX+2)))>0;
        zAlign = polyfit(X(xIndices), Z(xIndices), 0);
        %         % show the fit line
        %         figure('Name','Line fit');
        %         scatter(X(xIndices), Z(xIndices));
        %         hold on;
        %         plot(X(xIndices), X(xIndices)*0+zAlign);
        Z=Z-zAlign;
        paras=sigmoidFit(X,Z,false);
        if paras(5)<0
            errorNum=errorNum+1;
            if ~isempty(obj.sigmoidParas)
                paras=obj.sigmoidParas(end,:);
            end
        end
        obj.sigmoidParas=[obj.sigmoidParas;paras];
    end
elseif flag_extractMethod==2
    accumNum=4;
    for j=(1+accumNum/2):(size(obj.mesh_y,1)-(accumNum/2))
        % % %For test
        %     for j=round(linspace(round(size(obj.mesh_y,1))*0.4,round(size(obj.mesh_y,1))*0.6,10))
        %% Realign the Z data
        X=[];
        Z=[];
        for i=(1:accumNum)-accumNum/2
            X=[X,obj.mesh_x(j+i,:)];
            Z=[Z,obj.mesh_smoothedZ(j+i,:)];
        end
        middleX=mean(X);
        xIndices=((X<(middleX-2))+(X>(middleX+2)))>0;
        zAlign = polyfit(X(xIndices), Z(xIndices), 0);
        %         % show the fit line
        %         figure('Name','Line fit');
        %         scatter(X(xIndices), Z(xIndices));
        %         hold on;
        %         plot(X(xIndices), X(xIndices)*0+zAlign);
        Z=Z-zAlign;
        paras=sigmoidFit(X,Z,false);
        obj.sigmoidParas=[obj.sigmoidParas;paras];
        if paras(5)<0
            errorNum=errorNum+1;
        end
    end
    for i=1:(accumNum/2)
        obj.sigmoidParas=[obj.sigmoidParas(1,:);obj.sigmoidParas;obj.sigmoidParas(end,:)];
    end
elseif flag_extractMethod==3
    for j=3:(size(obj.mesh_y,1)-2)
        % % %For test
        %     for j=round(linspace(round(size(obj.mesh_y,1))*0.4,round(size(obj.mesh_y,1))*0.6,10))
        %% Realign the Z data
        X_total=[obj.mesh_x(j-2,:);obj.mesh_x(j-1,:);obj.mesh_x(j,:);obj.mesh_x(j+1,:);obj.mesh_x(j+2,:)];
        Z_total=[obj.mesh_smoothedZ(j-2,:);obj.mesh_smoothedZ(j-1,:);obj.mesh_smoothedZ(j,:);obj.mesh_smoothedZ(j+1,:);obj.mesh_smoothedZ(j+2,:)];
        paras_total=[];
        for i=1:size(X_total,1)
            X=X_total(i,:);
            Z=Z_total(i,:);
            middleX=mean(X);
            xIndices=((X<(middleX-2))+(X>(middleX+2)))>0;
            zAlign = polyfit(X(xIndices), Z(xIndices), 0);
            %             % show the fit line
            %             figure('Name','Line fit');
            %             scatter(X(xIndices), Z(xIndices));
            %             hold on;
            %             plot(X(xIndices), X(xIndices)*0+zAlign);
            Z=Z-zAlign;
            paras=sigmoidFit(X,Z,false);
            paras_total=[paras_total;paras];
        end
        paras=[0.1 0.2 0.4 0.2 0.1]*paras_total;
        if paras(5)<0
            errorNum=errorNum+1;
        end
        obj.sigmoidParas=[obj.sigmoidParas;paras];
    end
    obj.sigmoidParas=[obj.sigmoidParas(1,:);obj.sigmoidParas(1,:);obj.sigmoidParas;obj.sigmoidParas(end,:);obj.sigmoidParas(end,:)];
end
sigmoidParas=obj.sigmoidParas;
fprintf('The error number is %d. \n',errorNum);
end
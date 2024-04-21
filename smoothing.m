function [U_final,Alpha_final] = smoothing(input,U_temp,Alpha_temp,color_model)
    [rows,cols,~] = size(input);
    [Num_layer,~,~,~] = size(U_temp);
    U_final = U_temp;
    Alpha_final = zeros(size(Alpha_temp));

    for i = 1:Num_layer
        alpha = squeeze(Alpha_temp(i,:,:,:));
        Alpha_final(i,:,:,:) = imguidedfilter(alpha,input,"NeighborhoodSize",60,"DegreeOfSmoothing",0.0001);
    end
    normal = sum(Alpha_final,1);
    normal = repmat(normal, [Num_layer,1, 1]);
    Alpha_final = Alpha_final ./ normal;
    
    for r = 1:rows
        for c= 1:cols
            if any(Alpha_temp(:,r,c,:)==1)
                Alpha_final(:,r,c,:) = Alpha_temp(:,r,c,:);
            end
        end
    end

    normal = zeros(size(input));
    for i = 1:Num_layer
        layer_u = color_model((i-1)*3+1:(i-1)*3+3,1);
        for r = 1:rows
            for c = 1:cols
                if Alpha_final(i,r,c) ~= 0 && all(U_temp(i,r,c,:)==0) 
                        U_final(i,r,c,:) = layer_u;
                end
                normal(r,c,:) = squeeze(normal(r,c,:)) + squeeze(U_final(i,r,c,:)) * Alpha_final(i,r,c);
            end
        end
    end
    % hi = zeros(size(input));
    normal = input ./ normal;
    normal(isnan(normal)) = 0; % todo this is right
    for k = 1:size(U_final, 1)
        U_final(k, :, :, :) = squeeze(U_final(k, :, :, :)) .* normal;
        u = squeeze(U_final(k,:,:,:));
        Alpha = squeeze(Alpha_final(k,:,:,:));
        % imwrite(u, sprintf('result_self%02d.png',k), 'png', 'Alpha', Alpha);
        % hi = hi + squeeze(U_final(k, :, :, :)) .* squeeze(repmat(Alpha_final(k,:,:,:),[1,1,1,3]));
        % imshow(sprintf('result_self%02d.png',k));
    end
    % imshow(uint8(hi.*255));
end

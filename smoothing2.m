function [U_final,Alpha_final] = smoothing2(input, U_temp, Alpha_temp, color_model, save_name_format)
    [rows,cols,~] = size(input);
    [Num_layer,~,~,~] = size(U_temp);
    U_final = U_temp;
    Alpha_final = zeros(size(Alpha_temp));

    for i = 1:Num_layer
        alpha = squeeze(Alpha_temp(i,:,:,:));
        Alpha_final(i,:,:,:) = imguidedfilter(alpha,input, "NeighborhoodSize", 60, "DegreeOfSmoothing", 0.0001);
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
    stretched_normal = zeros(1, rows, cols, 3);
    stretched_normal(1, :, :, :) = normal;
    stretched_normal = repmat(stretched_normal, [Num_layer, 1, 1, 1]);
    U_final = U_final .* stretched_normal;
end

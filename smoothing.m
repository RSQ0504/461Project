function [U_final,Alpha_final] = smoothing(input,U_temp,Alpha_temp)
    [Num_layer,~,~,~] = size(U_temp);
    U_final = zeros(size(U_temp));
    Alpha_final = zeros(size(Alpha_temp));

    for i = 1:Num_layer
        alpha = squeeze(Alpha_temp(i,:,:,:));
        Alpha_final(i,:,:,:) = imguidedfilter(alpha,input,"NeighborhoodSize",60,"DegreeOfSmoothing",0.0001);
    end
    normal = sum(Alpha_final,1);
    normal = repmat(normal, [5,1, 1]);
    Alpha_final = Alpha_final .* normal;
end

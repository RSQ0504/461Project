function [color_model,seed_pixels] = estimate_color_model(image, tau)
    color_model = [];
    seed_pixels = [];
    [rows, cols, ~] = size(image);
    bins_mask = zeros(1000, rows,cols);
    representation_score = ones(rows, cols) * (2*tau^2);
    has_vote = true;
    while has_vote
        [votes,bins_mask] = calculate_votes(image, bins_mask,representation_score,tau);
        [max_votes, max_bin] = max(votes(:));
        
        if max_votes <= 0
            has_vote = false;
            continue;
        end


        color_bin_mask = bins_mask(max_bin,:,:);
        
        [seed_pixel_x,seed_pixel_y] = select_seed_pixel(image, color_bin_mask);
        seed_pixel = reshape(image(seed_pixel_x,seed_pixel_y,:),[3,1]); % ?
        seed_pixels = [seed_pixels seed_pixel];
        
        % The paper is saying that after they select the color bin they want to add to the color model, they select the seed pixel using Eq. 11. After they have the seed pixel, they compute the weights of a guided filter centered at that pixel and use that to fit the normal distribution. The guided filter will have higher weights for pixels that are close in color and proximity to the center pixel. So basically they are determining the parameters of the normal distribution based on a local neighborhood of similar pixels around the seed pixel if that makes sense. (edited) 
        epsilon = 0.1;
        new = get_new_layer(image,seed_pixel_x,seed_pixel_y, epsilon);
        color_model = [color_model; new];
        showResult(image,seed_pixel_x,seed_pixel_y);
        representation_score = weight_pixel(image,color_model);
    end
end


function new = get_new_layer(image,seed_pixel_x,seed_pixel_y, epsilon)
    neighborhood = image(max(1, seed_pixel_x - 10) : min(size(image, 1), seed_pixel_x + 10), ...
                    max(1, seed_pixel_y - 10) : min(size(image, 2), seed_pixel_y + 10),:);
   center = reshape(image(seed_pixel_x, seed_pixel_y,:),[3,1]);
   center_colors = [];
   for color = 1 : 3
       center_colors(:,:,color) = ones(size(neighborhood(: , :, color))) .* center(color);
   end
   diff = sum((center_colors - neighborhood).^2, 3);
   mask = (diff < epsilon);
   [rows,cols] = size(mask);
   pixels = [];
   % center = zeros(size(neighborhood)) .* center;
   for r = 1:rows
       for c = 1:cols
           if mask(r,c) ==0
               continue
           end
           pixels = [pixels reshape(neighborhood(r, c, :),[3,1])];
       end
   end
    weighted_mean = mean(pixels, 2);
    weighted_std = std(pixels,0, 2);
    new = [weighted_mean,weighted_std];


end

function [votes,bins_mask] = calculate_votes(image, bins_mask,representation_score,tau)
    votes = zeros(10, 10, 10);
    [rows, cols, ~] = size(image);
    for i = 1:rows
        for j = 1:cols
            rp = representation_score(i,j);
            pixel = image(i, j, :);
            r = pixel(1);
            g = pixel(2);
            b = pixel(3);
            bin_r = max(ceil(r / 0.1),1);
            bin_g = max(ceil(g / 0.1),1);
            bin_b = max(ceil(b / 0.1),1);
            index = sub2ind(size(votes), bin_r, bin_g, bin_b);
            if rp < tau^2
                bins_mask(index,i,j) = 0;
                continue
            end
            bins_mask(index,i,j) = 1;
            grad_image = 4 * image(i, j) - image(max(i-1,1), j) - image(min(i+1,rows), j) - image(i, max(j-1,1)) - image(i, min(j+1,cols));
            votes(bin_r, bin_g, bin_b) = votes(bin_r, bin_g, bin_b) + exp(-norm(grad_image)) * (1 - exp(-rp));
        end
    end
end

function representation_score_map = weight_pixel(image,color_model)
    [rows, cols, ~] = size(image);
    representation_score_map = zeros(rows, cols);
    num_mode = size(color_model,1);
    for r = 1:rows
        for c = 1: cols 
            pixel = image(r,c,:);
            pixel = reshape(pixel,[3,1]);
            if num_mode == 3
                model1 = color_model;
                model2 = color_model;
                ui = model1(:,1);
                stdi = model1(:,2);
                uj= model2(:,1);
                stdj = model2(:,2);
                cost = layer_color_cost(pixel, ui, stdi);
                representation_score_map(r,c) = cost;
            else
                for i = 1:3: num_mode
                    for j = i+3 :3: num_mode
                        model1 = color_model(i:i+2,:);
                        model2 = color_model(j:j+2,:);
                        ui = model1(:,1);
                        stdi = model1(:,2);
                        uj= model2(:,1);
                        stdj = model2(:,2);
                        cost = layer_color_cost(pixel, ui, stdi);
                        project_score = projected_unmix(ui, stdi, uj, stdj, pixel);
                        representation_score_map(r,c) = min([representation_score_map(r,c),cost,project_score]);
                    end
                end
            end
        end
    end
end

function [seed_pixel_x,seed_pixel_y] = select_seed_pixel(image, color_bin_mask)
    [~,tar_x,tar_y] = size(color_bin_mask);
    color_bin_mask = reshape(color_bin_mask, [tar_x, tar_y]);
    [rows, cols, ~] = size(image);
    best_score = -inf;
    for r = 1:rows
        for c = 1: cols 
            if color_bin_mask(r,c) == 0
                continue
            end
            grad_image = 4 * image(r, c) - image(max(r-1,1), c) - image(min(r+1,rows), c) - image(r, max(c-1,1)) - image(r, min(c+1,cols));
            neighbor = color_bin_mask( ...
                max(r-10,1):min(rows,r+10), ...
                max(c-10,1):min(cols,c+10));
            Sp = sum(neighbor(:) == 1);
            score = Sp + exp(-norm(grad_image));
            if score > best_score
                best_score = score;
                seed_pixel_x = r;
                seed_pixel_y = c;
            end
        end
    end

end

function hi = showResult(image,seed_pixel_r, seed_pixel_c)
        imshow(image);
        hold on;
        scatter(seed_pixel_r, seed_pixel_c, 100, 'blue', 'filled');
        hold off;
end
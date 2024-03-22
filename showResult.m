function hi = showResult(image,seed_pixel_r, seed_pixel_c)
        imshow(image);
        hold on;
        scatter(seed_pixel_c,seed_pixel_r, 10, 'red', 'filled');
        hold off;
end
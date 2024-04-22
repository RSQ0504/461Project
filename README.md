## Main function / executable file

```matlab
main.m
```

## Project structure


```C++
.
├── alpha_add_to_overlay.m  // Convert photo alpha values for import into photoshop
├── estimate_color_model.m  // Estimate color model
├── extract_layers.m    // Genterate color layers without smoothing based on color model
├── full                // Original image folder
├── get_layers.m
├── layer_color_cost.m  //  Squared Mahalanobis Distance
├── main.m              // Our main function / executable file
├── projected_unmix.m   // Calculate the projected color unmixing energy using each pair of two layers for each pixel
├── results
│   └── alpha_add       // Folder of output layers with smoothing (*.png)
├── showResult.m        // Visualization results: show seed_pixels
├── smoothing.m         // Layer Smoothing, including alpha smoothing using guided filter and normalize both color values and alpha values
├── test_hsv.m          // Color Editing using MATLAB Code instead of PhotoShop
└── weight_pixel.m      // Implementation of Projected Color Unmixing
```
% Step 1: Synthetic Data Generation
num_images_per_class = 100; 
image_size = [256, 256]; 

kyphosis_images = generate_synthetic_images(num_images_per_class, 'kyphosis', image_size);
lordosis_images = generate_synthetic_images(num_images_per_class, 'lordosis', image_size);
normal_images = generate_synthetic_images(num_images_per_class, 'normal', image_size);

synthetic_images = [kyphosis_images; lordosis_images; normal_images];
synthetic_labels = [repmat("kyphosis", num_images_per_class, 1); ...
                    repmat("lordosis", num_images_per_class, 1); ...
                    repmat("normal", num_images_per_class, 1)];

idx = randperm(size(synthetic_images, 1));
synthetic_images = synthetic_images(idx, :);
synthetic_labels = synthetic_labels(idx);

% Step 2: Feature Extraction
features = compute_features(synthetic_images);


classifier = fitcecoc(features, synthetic_labels);

%Read and preprocess
% the input image
input_image = imread('m.jpeg');
gray_input_image = rgb2gray(input_image);
enhanced_input_image = imadjust(gray_input_image);
edge_input_image = edge(enhanced_input_image, 'Canny');
se = strel('disk', 5);
cleaned_edge_input_image = imclose(edge_input_image, se);

% Segment the spinal region using active contours
initial_contour = zeros(size(cleaned_edge_input_image));
initial_contour(50:end-50, 50:end-50) = 1;
snake_contour = activecontour(enhanced_input_image, initial_contour, 500, 'Chan-Vese');

% Extract features from the segmented spinal region
input_features = compute_features({snake_contour});

predicted_label = predict(classifier, input_features);

% Display the input image with the predicted label
imshow(input_image);
hold on;
text(10, 10, ['Predicted spinal curvature: ', char(predicted_label)], 'Color', 'red', 'FontSize', 12);
hold off;






figure;
imshow(input_image);
title('Select a reference object with a known length');
roi = drawline; % Use drawline, drawrectangle, or other ROI tools as appropriate
reference_length_pixels = norm(roi.Position(2,:) - roi.Position(1,:));


reference_length_cm = 23; 
pixel_to_cm_conversion = reference_length_cm / reference_length_pixels;

title('Select the region containing the human');
roi_human = drawrectangle; 
human_height_pixels = roi_human.Position(4); 

% Calculate the height of the human in meters
human_height_cm = human_height_pixels * pixel_to_cm_conversion;

% Display the estimated human height
disp(['Estimated height of the human: ', num2str(human_height_cm), ' cm']);

% Helper functions
function synthetic_images = generate_synthetic_images(num_images, curvature_type, image_size)
    synthetic_images = cell(num_images, 1);
    for i = 1:num_images
        switch curvature_type
            case 'kyphosis'
                synthetic_images{i} = create_kyphosis_image(image_size);
            case 'lordosis'
                synthetic_images{i} = create_lordosis_image(image_size);
            case 'normal'
                synthetic_images{i} = create_normal_image(image_size);
        end
    end
end

function synthetic_image = create_kyphosis_image(image_size)
    [x, y] = meshgrid(1:image_size(2), 1:image_size(1));
    synthetic_image = uint8(255 * exp(-(x - 0.5 * image_size(2)).^2 / (100^2) - (y - 0.75 * image_size(1)).^2 / (50^2)));
end

function synthetic_image = create_lordosis_image(image_size)
    synthetic_image = create_kyphosis_image(image_size);
end

function synthetic_image = create_normal_image(image_size)
    synthetic_image = uint8(255 * ones(image_size));
end

function features = compute_features(images)
    num_images = numel(images);
    features = zeros(num_images, 3); % Example: 3 features (length, width, area)
    for i = 1:num_images
        features(i, :) = [size(images{i}, 1), size(images{i}, 2), sum(images{i}(:))];
    end
end

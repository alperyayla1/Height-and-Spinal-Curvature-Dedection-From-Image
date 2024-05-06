% Read the image
img = imread('s.jpeg');

% Display the image
imshow(img);
title('Select the reference object using the ROI tool');

% Use the ROI tool to select the reference object (e.g., a person)
roi = drawrectangle;

% Get the coordinates of the selected region
reference_bbox = round(roi.Position);
% Measure the height of the reference object (in pixels)
reference_height_pixels = reference_bbox(4);

imshow(img);
title('Select the head of the reference object using the ROI tool');

roi2 = drawrectangle;
reference_bbox2 = round(roi2.Position);
reference_head_pixels = reference_bbox2(4);
average_head_cm = 23;

% Calculate the scale factor
pixels_per_cm = average_head_cm / reference_head_pixels;


% You can use similar steps as above to select and measure the object


% Calculate the actual height of the object (in meters)
object_height_cm = reference_height_pixels * pixels_per_cm;

% Display the estimated height of the object
disp(['Estimated Height of the Object: ', num2str(object_height_cm), ' cm']);

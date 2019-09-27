%function f = visiontest(I1, I2)
close all;
%clear all;
clc;

%% Read Images
%I1 = imread('0.jpg');
figure; imshow(I1); title('Object of searching');
%I2 = imread('1.jpg');
figure; imshow(I2); title('Scene');

%% Detect Features
points1 = detectSURFFeatures(rgb2gray(I1));
points2 = detectSURFFeatures(rgb2gray(I2));

%% Extraxt Features
[feats1, validpts1] = extractFeatures(rgb2gray(I1), points1);
[feats2, validpts2] = extractFeatures(rgb2gray(I2), points2);

%% Display Features
figure; imshow(I1); hold on; plot(validpts1, 'showOrientation', true);
title('Detected Features');

%% Match Features
index_pairs = matchFeatures(feats1, feats2, ...
                                                              'Prenormalized', true);
matched_pts1 = validpts1(index_pairs(:, 1));
matched_pts2 = validpts2(index_pairs(:, 2));
figure; showMatchedFeatures(I1, I2, matched_pts1, matched_pts2, 'montage');
title('Initial Matches');

% Define locaition of object in image
boxpolygon = [1, 1; ... %top-left
    size(I1, 2), 1; ...        %top-right
    size(I1, 2), size(I1, 1);...  %bottom-right
    1, size(I1, 1);...          %bottom-left
    1, 1];

%% Remove outliers while estimating geometric transform using RANSAC
[tform, inlierPoint1, inlierPoints2]...
    = estimateGeometricTransform(matched_pts1, matched_pts2, 'affine');
figure; showMatchedFeatures(I1, I2, inlierPoints1,...
    inlierPoints2, 'montage'); title('Filtered Matches');

%% Use estimated transform to locate object
newBoxPolygon = transnformPointsForward(tform, boxPolygon);
figure; imsgow(I2);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'q', 'LineWidth', 5);
title('Detected objects');

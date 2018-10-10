% Script for recording frames of an animation for Science on a sphere
clear; close all; clc;
% Loading in .mat file. 
load('Results.mat');

% Start unpacking final_density_grid_truth
% Rows - Latitude values, 5 deg resolution
% Cols - Local Sidereal time, 5 deg resolution

densField = final_density_grid_truth; % Kind of a mouthful

% Getting latitude and LST grids
[numLat, numLST] = size(densField);
latVec = linspace(-90, 90, numLat);
LSTvec = linspace(-180, 180, numLST);
[latMesh, LSTMesh] = meshgrid(latVec, LSTvec);
latMesh = latMesh';
LSTMesh = LSTMesh';


%% Setting up the ground track and animation timing 
numSats = true_state_all_times(end, 2);
lenSat = length(true_state_all_times)/numSats;
satIDX = lenSat+1:2*lenSat; % Indices of a single satellite 
t_f = true_state_all_times(satIDX(end), 1); % [s] - time vector for satellite

tDays = t_f/86400;    % [day] Sim days
numSteps = lenSat;    % Number of rows in ground track path
degsSim = 360*tDays;  % total degress rotated over simulation time
degPerStep = degsSim/numSteps;

Oct10_Jan0 = datenum([2018, 10, 10, 0, 0, 0]); % Days to Oct 10, 2018 from Jan 0, 0000
sat_t = true_state_all_times(satIDX, 1)/86400 + Oct10_Jan0; % adding epoch 
sat_t = datevec(sat_t); % converting to date-time standard output. 


%% Getting pos data into lat/long (for a single sat for now)
satPosXYZ = true_state_all_times(satIDX, 3:5)*1000; % [m] XYZ in ECI;
satPosLLA = eci2lla(satPosXYZ, sat_t);  % [deg] Lat, long
satLat = satPosLLA(:, 1);
satLon = satPosLLA(:, 2);

%% Manufacturing temporal effects in the density field (as an example)
% I'm thinking just do a sinusoidal thing and modify based on that. 

% Purposely setting numFields to a different number than the number of 
% ground track elements to practice having different numbers here.
numFields = 100; 

% Sinusoidal variation to be applied to density field
densModVec = 1 + 0.2*sin(linspace(0, 6*pi, numFields)); 
densFieldVary = zeros(numLat, numLST, numFields);
% Polulate time-varying field with values with clumsy for loop. 
for i = 1:numFields
    densFieldVary(:, :, i) = densField*densModVec(i);
end

%% Creating axis to plot to
figure
set(gca, 'xlim', [-2.721, 2.721], 'ylim', [-1.571, 1.571]);
ax = axesm('MapProjection', 'eqdcylin', 'grid', 'on');
currentSurf = surfm(latMesh, LSTMesh, densFieldVary(:, :, 1), ...
            'facecolor', 'interp', ...
            'parent', ax);
% Setting limits on color axis. 
densMin = min(min(min(densFieldVary))); 
densMax = max(max(max(densFieldVary)));
caxis([densMin, densMax]);
% So the color axis doesn't update when I plot a new field in
% the animation
caxis manual 

%% Plotting and animating (officially)
% Initializing variables and loading coastline data. 
load coastlines
pCoast      = [];
pPath       = [];
pSat        = [];

j = 1; % For iterating through density field variations. 

for i = 1:numSteps % 1 step = 180 sec;
    
    %% Plotting density field variations
    % Plotting Density field as it updates with temporal effects.
    % Timing is driven by ground track atm since it's the only part with a
    % real time associated with it. 
    %
    % To spread the density field out over the entire sim, only update
    % every ~integer multiple of the number of ground track points divided
    % the number of density fields (numField is set arbitrarily by me).
    
    if ~mod(i, floor(numSteps/numFields)) && j < size(densFieldVary, 3)
        delete(currentSurf);
        currentSurf = surfm(latMesh, LSTMesh, densFieldVary(:, :, j), ...
            'facecolor', 'interp', ...
            'parent', ax);
        j = j + 1; % To iterate this at its own rate apart from i
    end
    
    %% Animating the coastlines and ground track (and anything else that isn't density)
    % Shifting longitudes with each time step and wrapping back to -180deg.
    coastlon = coastlon + degPerStep;
    overLapC = coastlon > 180;
    coastlon(overLapC) = coastlon(overLapC) - 360;
    
    satLon = satLon + degPerStep;
    overLapS = satLon > 180;
    satLon(overLapS) = satLon(overLapS) - 360;
    
    % Clear old coastlines/tracks before plotting new, shifted ones.
    delete(pCoast); 
    delete(pPath);
    delete(pSat);
    
    % Coastline overlay
    pCoast = plotm(coastlat, coastlon, 'k', 'parent', ax);
    % Groundtrack overlay
    pPath = plotm(satLat(1:i), satLon(1:i), 'r', 'parent', ax);

    frames(:, :, :, i) = getframe(ax);

    %% Update plot
    drawnow % Update plot (updates the plot)
end
%% Writing frames to file.
fileName = char('Densplot_uncompressed');
v = VideoWriter(fileName, 'Uncompressed AVI');
open(v);
writeVideo(v,frames);
close(v);



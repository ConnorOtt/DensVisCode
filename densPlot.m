%--------------------------------------------------------------------------
% densPlot is a script with the capability of plotting a density field on a
% sphere. densPlot will read in the data file and plot the data. 
%
%
% Created: 9/3/2018 - Connor Ott
% Last Modified: 9/26/2018 - Connor Ott
%--------------------------------------------------------------------------

function [] = densPlot(fileName, handles)

% Loading in .mat file. 
load(fileName);

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
numSats = 9;
lenSat = length(true_state_all_times)/numSats;
satIDX = lenSat+1:2*lenSat; % Indices of a single satellite 
t_f = true_state_all_times(satIDX(end), 1); % [s] - time vector for satellite

tDays = t_f/86400;    % [day] Sim days
numSteps = lenSat;    % Number of rows in ground track path
degsSim = 360*tDays;  % total degress rotated over simulation time
degPerStep = degsSim/numSteps;

% Seconds to UTC
sat_t = seconds(true_state_all_times(satIDX, 1));
sat_t = datevec(sat_t);
sat_t(:, 1) = 2018; % MADE UP NEED REAL DATE THANKS
sat_t(:, 2) = 9; % NEEEED REEEALL DATE
findMN = find(abs(diff(sat_t(:, 4))) == 23); % looking for midnight (increment day count)
sat_t(:, 3) = 1;
% Making Days increment - this probably needs its own function
for i = 1:length(findMN)-1 
    sat_t(findMN(i)+1:findMN(i+1), 3) = 1 + i;
end

%% Getting pos data into lat/long (for a single sat for now);
satPosXYZ = true_state_all_times(satIDX, 3:5)*1000; % [m] XYZ in ECI;
satPosLLA = eci2lla(satPosXYZ, sat_t);
satLat = satPosLLA(:, 1);
satLon = satPosLLA(:, 2);


%% Manufacturing temporal effects in the density field (as an example)
% % I'm thinking just do a sinusoidal thing and modify by that. 

% Purposely setting this to a different number than the number of ground
% track elements
numFields = 100; 
% Sinusoidal variation to be applied to density field
densModVec = 1 + 0.2*sin(linspace(0, 6*pi, numFields)); 
densFieldVary = zeros(numLat, numLST, numFields);
% Polulate time-varying field with values
for i = 1:numFields
    densFieldVary(:, :, i) = densField*densModVec(i);
end

%% Animating to GUI
% 2D Plot - Animated by moving coastlines under 0 deg LST
ax = axesm('MapProjection','robinson','Frame','on', 'grid', 'on'); % Map axis
set(ax, 'parent', handles.uipanel3);
currentSurf = surfm(latMesh, LSTMesh, densField, ...
                    'facecolor', 'interp', ...
                    'parent', ax);
cBar = colorbar;
cBar.Label.String = 'Atmospheric Density [kg/km^3]'; 

densFloor = min(min(min(densFieldVary)));
densMax = max(max(max(densFieldVary)));
caxis([densFloor, densMax]);
caxis manual
xlabel('Local Sidereal Time [deg]')
ylabel('Latitude [deg]');

% Initializing variables and loading coastline data. 
load coastlines
pCoast = [];
pPath = [];
pSat = [];
densTimeEffects = 1;
j = 1; % For iterating through density field variations. 
for i = 1:numSteps % 1 step = 180 sec;
    
    % Plotting Density field as it updates with temporal effects.
    if densTimeEffects
        if ~mod(i, floor(numSteps/numFields))
            delete(currentSurf);
            currentSurf = surfm(latMesh, LSTMesh, densFieldVary(:, :, j), ...
                                'facecolor', 'interp', ...
                                'parent', ax);
            j = j + 1;
        end
    end
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
    
    % Plot items if checkbox is toggled on. 
    if handles.showCoast.Value
        % Coastline overlay
        pCoast = plotm(coastlat, coastlon, 'k', 'parent', ax); 
    end
    if handles.showTrack.Value
        % Groundtrack overlay
        pPath = plotm(satLat(1:i), satLon(1:i), 'r', 'parent', ax);
        pSat = plotm(satLat(i), satLon(i), 'k.', 'linewidth', 25);
    end
    
    % Update clock to show current simualation time
    set(handles.timeUpdate, 'string', datestr(sat_t(i, :), 31));
    drawnow % Update plot
    
%     pause(0.05) % Moves a little quick without this. 
end









%% Density at satellite observation times

% latMeas = lat_lst_meas_array(:, 1)*180/pi;
% LSTMeas = lat_lst_meas_array(:, 2)*180/pi - 360;
% obsDens = truth_xyz(:, 7);
% 

%% Save this for the future
% % Creating polar coordinates to plot density field on
% theta = linspace(0, 2*pi, 73);
% phi = linspace(0, pi, 37);
% [theta,phi] = meshgrid(theta,phi); % making theta-phi grid
% x = sin(phi).*cos(theta);
% y = sin(phi).*sin(theta);
% z = cos(phi);
% 
% % % 3D Plot
% set(0, 'defaulttextinterpreter', 'latex')
% 
% % Map axis so as to add the map plot overlay
% ax = axesm('globe','Grid', 'on');
% title('Spherical Density Field Plot');
% sphPlot = surf(x, y, z, densField, 'edgecolor', 'none');
% 
% view(0, -23.5);
% axis equal
% c = colorbar;
% c.Label.String = 'Density kg/km^3';
% 
% load coastlines
% plotm(coastlat,coastlon, 'k') % Coastline overlay

end
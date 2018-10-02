%--------------------------------------------------------------------------
% densPlot is a function built to manage and plot data from SSA Space 
% Weather algorithm to a densVisGui.
%   
%   Inputs:
%       fileName - Name of the data file containing the data to be
%                  visualized. For the sake of simplicity, this should be 
%                  in the same directory as densPlot.m. Will update to pull
%                  from path.
%       handles -  Struct containing handles of all GUI elements in
%                  densVisGui. This is not user specified, it is only used
%                  by the densVisGui.m file which builds the GUI and calls
%                  this function.
%       
%   Outputs:
%       densPlot plots to the densViGui GUI. There are no other outputs
%       besided the visualization. 
%
% Created: 9/3/2018 - Connor Ott
% Last Modified: 9/28/2018 - Connor Ott
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

% Converting seconds to UTC
sat_t = seconds(true_state_all_times(satIDX, 1)); % start time
sat_t = datevec(sat_t); % converting to date-time standard output. 

% This is where its a little messy for the sake of example. Optimally, I
% would have an observation date/time in UTC that I could just go off of,
% but I have to make my own date up for this example. Using 9/1/18. 
sat_t(:, 1) = 2018;
sat_t(:, 2) = 9; 
% looking for midnight indices (to increment day count)
findMN = find(abs(diff(sat_t(:, 4))) == 23); 
sat_t(:, 3) = 1;
% Making Days increment - this probably needs its own function
for i = 1:length(findMN)-1 
    sat_t(findMN(i)+1:findMN(i+1), 3) = 1 + i;
end

%% Getting pos data into lat/long (for a single sat for now)
satPosXYZ = true_state_all_times(satIDX, 3:5)*1000; % [m] XYZ in ECI;
satPosLLA = eci2lla(satPosXYZ, sat_t);  % [deg] Lat, long
satLat = satPosLLA(:, 1);
satLon = satPosLLA(:, 2);

%% Manufacturing temporal effects in the density field (as an example)
% % I'm thinking just do a sinusoidal thing and modify based on that. 

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
densFieldDiff = diff(densFieldVary, 1, 3);

%% Setting up axis
% Plot will be animated by moving coastlines, ground tracks, and 
% Determine which tab and panel to initialize to.
currentTab = handles.tgroup.SelectedTab; 
currentPan = get(currentTab, 'children');
switch(currentTab.Title) % choose plotting method based on panel title
    case '2D Projection'
        ax = axesm('MapProjection', 'robinson', ...
                   'Frame', 'on', ...
                   'grid', 'on');
    case '3D Projection'
        ax = axesm('globe', 'grid', 'on');
        view(30, 23.5);
        rotate3d on; % allow the user to pan
        axis equal
    case 'Other tabs?...'
end
% Setting axis to plot to and plotting. 
set(ax, 'parent', currentPan);
currentSurf = surfm(latMesh, LSTMesh, densField, ...
    'facecolor', 'interp', ...
    'parent', ax);
% Building a quick colormap that I want
gCol = linspace(0, 1, 30)';
bCol = linspace(0, 1, 30)';
rCol = ones(30, 1);
map = [rCol, gCol, bCol];

% Set up colorbar
cBar = colorbar;
cBar.Label.String = 'Atmospheric Density [kg/km^3]';
% Need to set minimum and maximum colorbar scale or else it'll all look the
% same with my example. 
densMin = min(min(min(densFieldVary))); 
densMax = max(max(max(densFieldVary)));
caxis([densMin, densMax]);

% So the color axis doesn't update when I plot a new field in
% the animation
caxis manual 

% Debating on including these, they're a little wied looking honestly.
% I have to put them in somehow but this is not a good way. 
% xlabel('Local Sidereal Time [deg]')
% ylabel('Latitude [deg]');

%% Generating spherical coordinates for "lumpy sphere plot"
theta = linspace(0, 2*pi, numLST);
phi = linspace(0, pi, numLat);
[theta,phi] = meshgrid(theta,phi); % making theta-phi grid

% Generating radii for each point that can change with things
d_densMax = max(max(max(abs(densFieldDiff))));
% Zero change is seen as radius of 1, with maximum change as 1.15, 0.85
radMat = 1 + 5.^(densFieldDiff/d_densMax * 0.5);

%% Plotting and animating (officially)
% Initializing variables and loading coastline data. 
load coastlines
pCoast = [];
pPath = [];
pSat = [];
j = 1; % For iterating through density field variations. 

for i = 1:numSteps % 1 step = 180 sec;
    %% Switching between tabs
    % If the panel has changed
    if handles.tgroup.SelectedTab ~= currentTab      
        % Get new tab and panel handle
        currentTab = handles.tgroup.SelectedTab;
        currentPan = get(currentTab, 'children');
        
        % Remove current surface and axis so they can be remade with new 
        % method
        delete(currentSurf);
        delete(ax);
        switch(currentTab.Title)
            case '2D Projection'
                ax = axesm('MapProjection', 'robinson', ...
                           'Frame', 'on', ...
                           'grid', 'on'); 
            case '3D Projection'
                ax = axesm('globe', 'grid', 'on');
                view(0, 23.5);
                rotate3d on;
                axis equal
                
        end
        % Set parent of ax to new panel. 
        set(ax, 'Parent', currentPan);
       
        % Reinitialize colorbar and color axis properties (since I deleted 
        % them lol)
        cBar = colorbar;
        cBar.Label.String = 'Atmospheric Density [kg/km^3]';
        caxis([densMin, densMax]);
        caxis manual
%         plotm(0, 0, 'rx', 'linewidth', 10);
    end
    
    %% Plotting density field variations
    % Plotting Density field as it updates with temporal effects.
    % Timing is driven by ground track atm since it's the only part with a
    % real time associated with it. 
    %
    % To spread the density field out over the entire sim, only update
    % every ~integer multiple of the number of ground track points divided
    % the number of density fields (numField is set arbitrarily by me).
    
    if ~mod(i, floor(numSteps/numFields)) && j < size(densFieldVary, 3)
        if handles.showChange.Value % Requires a different 3D plotting method
            handles.showCoast.Value = 0;
            handles.showCoast.Enable = 'off';
            
            x = radMat(:, :, j).*sin(phi).*cos(theta);
            y = radMat(:, :, j).*sin(phi).*sin(theta);
            z = radMat(:, :, j).*cos(phi);
            
            delete(currentSurf);
            currentSurf = surf(x, y, z, densFieldVary(:, :, j), ...
                                           'edgecolor', 'none', ...
                                           'facecolor', 'interp', ...
                                           'parent', ax);
            caxis([densMin, densMax]);
            caxis manual;
            j = j + 1;
        else % Plot normally without changing radius
            delete(currentSurf);
            currentSurf = surfm(latMesh, LSTMesh, densFieldVary(:, :, j), ...
                'facecolor', 'interp', ...
                'parent', ax);
            %         colormap('cool');
            j = j + 1; % To iterate this at its own rate apart from i
        end
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

    
    %% Clock
    % Update clock to show current simualation time
    set(handles.timeUpdate, 'string', datestr(sat_t(i, :), 31));

    pause(0.05);
    %% Update plot
    drawnow % Update plot (updates the plot)
end

%%%%% Pieces of Code that I decided weren't necessary at this point. %%%%%%
%% Density at satellite observation times

% latMeas = lat_lst_meas_array(:, 1)*180/pi;
% LSTMeas = lat_lst_meas_array(:, 2)*180/pi - 360;
% obsDens = truth_xyz(:, 7);

end
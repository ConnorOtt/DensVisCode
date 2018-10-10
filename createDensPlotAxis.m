function axHandle = createDensPlotAxis(proj, field, currentPan)

if strcmp(proj, 'robinson')
    axHandle = axesm('MapProjection', 'robinson', ...
                     'Frame', 'on', ...
                     'grid', 'on');
elseif strcmp(proj, 'globe')
    % Create a globe projection with directional vectors. 
    axHandle = axesm('globe', 'grid', 'on');
    view(0, 23.5);
    rotate3d on;
    axis equal
    
    % Creating directional vectors and labels
    quiver3(0, 0, 0, 0, 0, 1.8, 'k', 'linewidth', 1.1);
    text(0, 0, 1.8, '\omega_{E}');
    quiver3(0, 0, 0, 1.8, 0, 0, 'r', 'linewidth', 1.1);
    text(1.8, 0, 0, 'to Sun');
end

set(axHandle, 'Parent', currentPan);

% Setting limits for 
if size(field) > 1
    cMin = min(min(min(field)));
    cMax = max(max(max(field)));
else
    cMin = min(min(field));
    cMax = max(max(field)); 
end

% Creating colorbar for our guy since I delete it every time
caxis([cMin, cMax]);
cBar = colorbar;
cBar.Label.String = 'Atmospheric Density [kg/km^3]';
cBar.Parent = currentPan;
caxis([cMin, cMax]);
caxis manual

end